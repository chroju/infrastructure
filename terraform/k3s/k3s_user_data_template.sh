#!/bin/bash

apt update
apt install awscli git binutils rustc cargo pkg-config libssl-dev gettext python3-pip -y

# Build and install amazon-efs-utils from source (Ubuntu 22.04 recommended method)
cd /tmp
git clone https://github.com/aws/efs-utils
cd efs-utils

# Apply workaround for Cargo lockfile issue (https://github.com/aws/efs-utils/issues/293)
# Modify build-deb.sh to use the -Znext-lockfile-bump flag
sed -i 's/cargo build --release/cargo build --release -Znext-lockfile-bump/' build-deb.sh

if ./build-deb.sh; then
    apt-get install -y ./build/amazon-efs-utils*.deb
    echo "amazon-efs-utils installed successfully"
    
    # Install botocore for CloudWatch monitoring
    pip3 install --target /usr/lib/python3/dist-packages botocore
    
    EFS_MOUNT_METHOD="efs-utils"
else
    echo "Failed to build amazon-efs-utils, falling back to NFS"
    apt install -y nfs-common
    EFS_MOUNT_METHOD="nfs"
fi


# add instance name
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=k3s --region ap-northeast-1

# swap
dd if=/dev/zero of=/swapfile bs=128M count=16
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

# Install k3s
curl -Ls https://github.com/k3s-io/k3s/releases/download/${k3s_version}/k3s-arm64 -o /usr/local/bin/k3s
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
curl -Ls https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-arm64.deb -o /tmp/cloudflared.deb
dpkg -i /tmp/cloudflared.deb

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

# mount EFS with retry logic and automatic mounting

mkdir -p /data/pvs

# Configure mounting based on available method
if [ "$EFS_MOUNT_METHOD" = "efs-utils" ]; then
    echo "Using EFS mount helper"
    # Add to /etc/fstab for automatic mounting on reboot
    echo "${efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/ /data/pvs efs tls,_netdev 0 0" >> /etc/fstab
    
    # Mount with retry logic
    for i in {1..5}; do
        echo "Attempting EFS mount with efs-utils (attempt $i/5)..."
        if mount -t efs -o tls ${efs_file_system_id}:/ /data/pvs; then
            echo "EFS mount successful with efs-utils"
            break
        else
            echo "EFS mount failed, retrying in 10 seconds..."
            sleep 10
            if [ $i -eq 5 ]; then
                echo "Failed to mount EFS with efs-utils after 5 attempts"
                # Log error details
                echo "EFS mount failure at $(date)" >> /var/log/efs-mount-error.log
                tail -20 /var/log/amazon/efs/mount.log >> /var/log/efs-mount-error.log 2>/dev/null || true
            fi
        fi
    done
else
    echo "Using NFS mount"
    # Add to /etc/fstab for automatic mounting on reboot (NFS method)
    echo "${efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/ /data/pvs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0" >> /etc/fstab
    
    # Mount with retry logic using NFS
    for i in {1..5}; do
        echo "Attempting EFS mount with NFS (attempt $i/5)..."
        if mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_file_system_id}.efs.ap-northeast-1.amazonaws.com:/ /data/pvs; then
            echo "EFS mount successful with NFS"
            break
        else
            echo "EFS mount failed, retrying in 10 seconds..."
            sleep 10
            if [ $i -eq 5 ]; then
                echo "Failed to mount EFS with NFS after 5 attempts"
                echo "EFS NFS mount failure at $(date)" >> /var/log/efs-mount-error.log
            fi
        fi
    done
fi

# Set permissions only if mount successful
if mountpoint -q /data/pvs; then
    chown -R root:root /data/pvs
    chmod -R 755 /data/pvs
    echo "EFS mount and permissions set successfully"
else
    echo "EFS mount failed - skipping permission changes"
fi

# apply application set

kubectl apply -f /tmp/application-set.yaml
ARGO_CD_PASSWORD=$(kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/argo_cd_password --type SecureString --overwrite --value "$ARGO_CD_PASSWORD"
aws ssm put-parameter --region ap-northeast-1 --name /chroju/k3s/instance_id --type String --overwrite --value "$INSTANCE_ID"
