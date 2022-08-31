#!/bin/bash

# Install k3s
curl -Ls https://github.com/k3s-io/k3s/releases/download/${k3s_version}/k3s -o /usr/local/bin/k3s
chmod +x /usr/local/bin/k3s
ln -s /usr/local/bin/k3s /usr/local/bin/kubectl

cat > /etc/systemd/system/k3s.service <<EOF
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
Environment=K3S_KUBECONFIG_MODE=644
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=/bin/sh -xc '! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service'
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s server
EOF

systemctl daemon-reload
systemctl enable k3s
systemctl start k3s

# Register kubeconfig
apt update
apt install awscli -y

KUBE_CONFIG=$(cat /etc/rancher/k3s/k3s.yaml)
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/kube_config --type SecureString --overwrite --value "$KUBE_CONFIG"

# Install cloudflared for kubectl (Kubernetes API)
curl -Ls https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
dpkg -i ./tmp/cloudflared.deb

mkdir -p /root/.cloudflared
cat > /root/.cloudflared/${cloudflare_tunnel.kubectl.id}.json <<EOF
{
  "AccountTag": "${cloudflare_account_id}",
  "TunnelSecret": "${cloudflare_tunnel.kubectl.secret}",
  "TunnelID": "${cloudflare_tunnel.kubectl.id}"
}
EOF

cat > /root/.cloudflared/config.yaml <<EOF
tunnel: ${cloudflare_tunnel.kubectl.id}
credentials-file: /root/.cloudflared/${cloudflare_tunnel.kubectl.id}.json

ingress:
  - hostname: ${cloudflare_tunnel.kubectl.hostname}
    service: tcp://127.0.0.1:6443
    originRequest:
      proxyType: socks
  - service: http_status:404
EOF

cloudflared service install

# Install ArgoCD and use with cloudflared

cat > /tmp/argo-cd-helm-chart.yaml <<EOF
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: argo-cd
  namespace: kube-system
spec:
  repo: https://argoproj.github.io/argo-helm
  chart: argo-cd
  targetNamespace: argo-cd
  valuesContent: |-
    server:
      extraArgs:
        - --insecure # HTTPSを無効化しないとArgo Tunnelから繋がらない
EOF

cat > /tmp/cloudflare-tunnel.json <<EOF
{
  "AccountTag": "${cloudflare_account_id}",
  "TunnelSecret": "${cloudflare_tunnel.argo_cd.secret}",
  "TunnelID": "${cloudflare_tunnel.argo_cd.id}"
}
EOF

cat > /tmp/cloudflare-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argo-cd-tunnel
  namespace: argo-cd
spec:
  selector:
    matchLabels:
      app: argo-cd-tunnel
  template:
    metadata:
      labels:
        app: argo-cd-tunnel
    spec:
      volumes:
      - name: cloudflared-auth-volume
        secret:
          secretName: cloudflared-auth
      - name: cloudflared-config
        configMap:
          name: cloudflared-config
          items:
            - key: config.yaml
              path: config.yaml
      containers:
      - name: cloudflared-tunnel
        image: cloudflare/cloudflared:${cloudflared_version}-amd64
        args:
        - tunnel
        - --config
        - /etc/cloudflared/config.yaml
        - run
        volumeMounts:
          - name: cloudflared-auth-volume
            mountPath: /etc/cloudflared/tunnel.json
            subPath: cloudflare-tunnel.json
            readOnly: true
          - name: cloudflared-config
            mountPath: /etc/cloudflared/config.yaml
            subPath: config.yaml
            readOnly: true
        env:
          - name: TUNNEL_NAME
            value: argo_cd_tunnel
EOF

cat > /tmp/cloudflare-configmap.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudflared-config
  namespace: argo-cd
data:
  config.yaml: |
    tunnel: ${cloudflare_tunnel.argo_cd.id}
    credentials-file: /etc/cloudflared/tunnel.json
    no-autoupdate: true
    
    ingress:
      - hostname: ${cloudflare_tunnel.argo_cd.hostname}
        service: http://argo-cd-argocd-server.argo-cd
      - service: http_status:404
EOF

kubectl create ns argo-cd
kubectl apply -f /tmp/argo-cd-helm-chart.yaml

kubectl create secret -n argo-cd generic cloudflared-auth \
  --from-file=./tmp/cloudflare-tunnel.json
kubectl apply -f /tmp/cloudflare-configmap.yaml
kubectl apply -f /tmp/cloudflare-deployment.yaml

# Apply ApplicationSet

curl https://raw.githubusercontent.com/chroju/infrastructure/main/kubernetes/application-set/application-set.yaml -o /tmp/application-set.yaml
while true
do
    # Argo CD ApplicationSet Controllerの起動を待つ
    kubectl get deployment/argo-cd-argocd-applicationset-controller -n argo-cd | grep 1/1
    if [[ "$?" == '0' ]]; then
        break
    fi
    sleep 10
done

kubectl apply -f /tmp/application-set.yaml
ARGO_CD_PASSWORD=$(kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/argo_cd_password --type SecureString --overwrite --value "$ARGO_CD_PASSWORD"
