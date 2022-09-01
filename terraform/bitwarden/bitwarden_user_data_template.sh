#!/bin/bash

hostnamectl set-hostname bitwarden

#####
## Prepare to install bitwarden
#####

# manage user and group
groupadd docker
usermod -aG docker ubuntu

# download bitwarden install script
curl -Lso /home/ubuntu/bitwarden.sh https://go.btwrdn.co/bw-sh && chmod 700 /home/ubuntu/bitwarden.sh && chown ubuntu:ubuntu /home/ubuntu/bitwarden.sh

#####
## mount EBS
#####

file -s /dev/nvme1n1 | grep ext4
if [[ "$?" != '0' ]]; then
    mkfs -t ext4 /dev/nvme1n1
fi
mkdir /home/ubuntu/bwdata
mount /dev/nvme1n1 /home/ubuntu/bwdata
chown -R ubuntu:ubuntu /home/ubuntu/bwdata
echo '/dev/nvme1n1   /home/ubuntu/bwdata       ext4    defaults,nofail   0   2' >> /etc/fstab

#####
# Install Docker
#####

# https://docs.docker.com/engine/install/ubuntu/

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


#####
# cloudflared
#####

# Install cloudflared for bitwarden
curl -Ls https://github.com/cloudflare/cloudflared/releases/download/${cloudflared_version}/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
dpkg -i ./tmp/cloudflared.deb

mkdir -p /root/.cloudflared
cat > /root/.cloudflared/${cloudflare_tunnel.bitwarden.id}.json <<EOF
{
  "AccountTag": "${cloudflare_account_id}",
  "TunnelSecret": "${cloudflare_tunnel.bitwarden.secret}",
  "TunnelID": "${cloudflare_tunnel.bitwarden.id}"
}
EOF

cat > /root/.cloudflared/config.yaml <<EOF
tunnel: ${cloudflare_tunnel.bitwarden.id}
credentials-file: /root/.cloudflared/${cloudflare_tunnel.bitwarden.id}.json

ingress:
  - hostname: ${cloudflare_tunnel.bitwarden.hostname}
    service: http://127.0.0.1:80
  - service: http_status:404
EOF

cloudflared service install

#####
## crontab
#####

cat >> /tmp/crontab <<EOF
0 21 * * * /home/ubuntu/bitwarden.sh updateself
30 21 * * * /home/ubuntu/bitwarden.sh update
30 22 * * * docker image prune -f
30 23 * * * docker container prune -f
EOF
crontab -u bitwarden /tmp/crontab

sudo -u ubuntu /home/ubuntu/bitwarden.sh start

#####
# Mackerel
#####

wget -q -O - https://mackerel.io/file/script/setup-all-apt-v2.sh | MACKEREL_APIKEY='${mackerel_api_key}' sh
apt-get update
apt-get install mackerel-agent


cat >> /etc/mackerel-agent/mackerel-agent.conf <<EOF
[plugin.checks.bitwarden]
command = ['/etc/mackerel-agent/mackerel-bitwarden.sh']
check_interval = 1
timeout_seconds = 45
max_check_attempts = 3
memo = "Bitwarden containers are unhealthy"
EOF

cat >> /etc/mackerel-agent/mackerel-bitwarden.sh << 'EOF'
#!/bin/bash
HEALTHY_CONTAINERS=$(docker ps  --format "{{.Status}}" | awk '{print $NF}' | grep '(healthy)' | wc -l)

if [[ $HEALTHY_CONTAINERS != '11' ]]; then
  exit 2
else
  exit 0
fi
EOF
chmod +x /etc/mackerel-agent/mackerel-bitwarden.sh

systemctl reload mackerel-agent
systemctl start mackerel-agent
systemctl enable mackerel-agent
