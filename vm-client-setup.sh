#!/bin/bash

# ===============================================
# Ubuntu VM Client - Connect to VPS Relay
# Run this on your NON-24/7 Ubuntu VM
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN} VM Client - VPS Relay Setup${NC}"
echo -e "${GREEN}======================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Run with sudo${NC}"
    exit 1
fi

# Prompt for VPS details
echo ""
echo -e "${YELLOW}Enter your VPS details:${NC}"
read -p "VPS IP or Domain: " VPS_IP
read -p "FRP Port [7000]: " FRP_PORT
FRP_PORT=${FRP_PORT:-7000}
read -p "Token (from VPS frps.ini): " TOKEN
read -p "VM Name/ID [vm-001]: " VM_NAME
VM_NAME=${VM_NAME:-vm-001}

echo -e "\n${YELLOW}[1/6] Installing desktop and RDP...${NC}"
apt-get update
apt-get upgrade -y

# Install GUI, RDP, and tools
apt-get install -y \
    ubuntu-desktop \
    xrdp \
    xorg \
    xdotool \
    wget \
    curl

echo -e "\n${YELLOW}[2/6] Configuring XRDP...${NC}"

# Set default desktop session for RDP
echo "gnome-session" > ~/.xsession
cp ~/.xsession /root/.xsession

# Restart XRDP
systemctl enable xrdp
systemctl restart xrdp

echo -e "\n${YELLOW}[3/6] Installing FRP Client...${NC}"

# Download FRP
FRP_VERSION="0.52.3"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"

cd /tmp
wget -q "${FRP_URL}" -O frp.tar.gz
tar -xzf frp.tar.gz
rm frp.tar.gz

# Install FRP client
mkdir -p /opt/frp
cp frp_${FRP_VERSION}_linux_amd64/frpc /opt/frp/
chmod +x /opt/frp/frpc

# Create FRP client config
cat > /opt/frp/frpc.ini << EOF
[common]
server_addr = ${VPS_IP}
server_port = ${FRP_PORT}
token = ${TOKEN}
log_file = /var/log/frpc.log
log_level = info
log_max_days = 3

[${VM_NAME}-rdp]
type = tcp
local_ip = 127.0.0.1
local_port = 3389
remote_port = 3389
use_encryption = true
use_compression = true

[${VM_NAME}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 2222
use_encryption = true
use_compression = true
EOF

echo -e "\n${YELLOW}[4/6] Creating auto-reconnect service...${NC}"

# Create systemd service that auto-restarts
cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=FRP Client (Connect to VPS)
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/opt/frp/frpc -c /opt/frp/frpc.ini
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frpc
systemctl start frpc

echo -e "\n${YELLOW}[5/6] Installing Tailscale (backup connection)...${NC}"

# Install Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list
apt-get update
apt-get install -y tailscale

systemctl enable tailscaled
systemctl start tailscaled

echo -e "\n${YELLOW}[6/6] Configuring 24/7 behavior (when VM is on)...${NC}"

# Disable sleep/suspend
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false

# Create no-sleep service
cat > /etc/systemd/system/nosleep.service << 'EOF'
[Unit]
Description=Prevent system from sleeping

[Service]
Type=simple
ExecStart=/usr/bin/systemd-inhibit --what=sleep:idle --who=vm-keepalive --why=Keeping-VM-awake --mode=block /bin/bash -c "while true; do sleep 3600; done"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nosleep
systemctl start nosleep

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN} VM Client Setup Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}CONNECT FROM ANYWHERE:${NC}"
echo ""
echo -e "   RDP to your VPS IP on port 3389:"
echo "   ${GREEN}mstsc /v: ${VPS_IP}:3389${NC}"
echo ""
echo -e "   This will tunnel you to this VM via the VPS relay!"
echo ""
echo -e "${YELLOW}USEFUL COMMANDS:${NC}"
echo "   systemctl status frpc      - Check FRP connection"
echo "   systemctl restart frpc     - Reconnect to VPS"
echo "   tailscale up               - Connect via Tailscale"
echo ""
echo -e "${YELLOW}ON YOUR VPS (24/7):${NC}"
echo "   Check dashboard: http://${VPS_IP}:7500"
echo "   You'll see '${VM_NAME}-rdp' in the proxy list"
echo ""
