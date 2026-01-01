#!/bin/bash

# ===============================================
# VPS (24/7 Server) - Setup as Relay/Entry Point
# Run this on your 24/7 VPS
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN} VPS Server - Relay Setup${NC}"
echo -e "${GREEN}======================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Run with sudo${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[1/4] Installing FRP Server (Fast Reverse Proxy)...${NC}"

# Download FRP
FRP_VERSION="0.52.3"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"

cd /tmp
wget -q "${FRP_URL}" -O frp.tar.gz
tar -xzf frp.tar.gz
rm frp.tar.gz

# Install FRP server
mkdir -p /opt/frp
cp frp_${FRP_VERSION}_linux_amd64/frps /opt/frp/
cp frp_${FRP_VERSION}_linux_amd64/frps.ini /opt/frp/
chmod +x /opt/frp/frps

# Create FRP config
cat > /opt/frp/frps.ini << 'EOF'
[common]
bind_port = 7000
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = CHANGE_THIS_PASSWORD
vhost_http_port = 80
vhost_https_port = 443
log_file = /var/log/frps.log
log_level = info
log_max_days = 3
token = CHANGE_THIS_SECRET_TOKEN
max_pool_count = 50
max_ports_per_client = 0
subdomain_host = your-domain.com
EOF

# Create systemd service
cat > /etc/systemd/system/frps.service << 'EOF'
[Unit]
Description=FRP Server (Fast Reverse Proxy)
After=network.target

[Service]
Type=simple
ExecStart=/opt/frp/frps -c /opt/frp/frps.ini
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

echo -e "\n${YELLOW}[2/4] Configuring firewall...${NC}"

# Allow ports
ufw allow 22/tcp 2>/dev/null || true
ufw allow 80/tcp 2>/dev/null || true
ufw allow 443/tcp 2>/dev/null || true
ufw allow 3389/tcp 2>/dev/null || true
ufw allow 7000/tcp 2>/dev/null || true
ufw allow 7500/tcp 2>/dev/null || true

# Allow through firewall (alternative)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 3389 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 7000 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 7500 -j ACCEPT 2>/dev/null || true

echo -e "\n${YELLOW}[3/4] Starting FRP Server...${NC}"

systemctl daemon-reload
systemctl enable frps
systemctl start frps

echo -e "\n${YELLOW}[4/4] Installing Tailscale (backup)...${NC}"

# Install Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get install -y tailscale

systemctl enable tailscaled
systemctl start tailscaled

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN} VPS Setup Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Edit /opt/frp/frps.ini and change:${NC}"
echo "   - dashboard_pwd to a secure password"
echo "   - token to a secret token"
echo ""
echo -e "${YELLOW}Then run:${NC}"
echo "   systemctl restart frps"
echo ""
echo -e "${YELLOW}Get your VM setup credentials:${NC}"
echo "   VPS_IP: $(hostname -I | awk '{print $1}')"
echo "   FRP_PORT: 7000"
echo "   TOKEN: (what you set in frps.ini)"
echo ""
echo -e "${YELLOW}To connect via RDP:${NC}"
echo "   rdp://<vps-ip>:3389"
echo ""
echo -e "${YELLOW}Dashboard (monitor connections):${NC}"
echo "   http://<vps-ip>:7500"
echo ""
