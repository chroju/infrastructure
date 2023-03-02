#!/bin/bash

apt update
apt install awscli -y

# attach EBS
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 attach-volume --volume-id ${ebs_volume_id} --device /dev/sdf --instance-id $INSTANCE_ID --region ap-northeast-1

# add instance name
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=k3s --region ap-northeast-1

# swap
dd if=/dev/zero of=/swapfile bs=128M count=16
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

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

# Install ArgoCD

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

kubectl create ns argo-cd
kubectl apply -f /tmp/argo-cd-helm-chart.yaml

# Apply ApplicationSet

curl https://raw.githubusercontent.com/chroju/infrastructure/main/kubernetes/bootstrap/app-of-application-set.yaml -o /tmp/application-set.yaml
while true
do
    # Argo CD ApplicationSet Controllerの起動を待つ
    kubectl get deployment/argo-cd-argocd-applicationset-controller -n argo-cd | grep 1/1
    if [[ "$?" == '0' ]]; then
        break
    fi
    sleep 10
done

file -s /dev/nvme1n1 | grep ext4
if [[ "$?" != '0' ]]; then
    mkfs -t ext4 /dev/nvme1n1
fi
mkdir -p /data/pvs
mount /dev/nvme1n1 /data/pvs
chown -R root:root /data/pvs
chmod -R 755 /data/pvs

kubectl apply -f /tmp/application-set.yaml
ARGO_CD_PASSWORD=$(kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/argo_cd_password --type SecureString --overwrite --value "$ARGO_CD_PASSWORD"
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/instance_id --type String --overwrite --value "$INSTANCE_ID"
