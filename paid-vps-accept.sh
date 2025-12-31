#!/bin/bash

# ===============================================
# NjanFlame - PAID VPS (24/7) - Accept Tunnels
# Run this on your PAID 24/7 VPS
# ===============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m'

clear

echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██╔════╝${CYAN}██╔═══██╗${CYAN}██╔══██╗${CYAN}██╔══██╗${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██████╔╝${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██╔══██╗${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}╚██████╗╚██████╔╝${CYAN}██║  ██║${NC}${CYAN}██████╔╝${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚═════╝ ╚═════╝ ╚═╝  ╚═╝${NC}${CYAN}╚═════╝${NC}       ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 0.2
echo ""
echo -e "${MAGENTA}        ★  ★  ★  ULTIMATE EDITION  ★  ★  ★${NC}"
echo ""
sleep 0.3
echo -e "${GREEN}            [ LOADING... ]${NC}"
sleep 0.5

for i in {1..15}; do
    echo -ne "${GREEN}            █${NC}"
    sleep 0.03
done
echo ""
sleep 0.3
echo -e "${GREEN}            [ READY ]${NC}"
echo ""
sleep 0.3
echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}        Made with ❤️  by NjanFlame${NC}"
echo ""
sleep 0.5

VPS_IP=$(hostname -I | awk '{print $1}')

install_ssh() {
    echo ""
    echo -e "${YELLOW}[*] Setting up SSH Server...${NC}"

    apt-get update 2>/dev/null || sudo apt-get update 2>/dev/null || true
    apt-get install -y openssh-server ufw 2>/dev/null || sudo apt-get install -y openssh-server ufw 2>/dev/null || true

    # Enable tunneling
    if ! grep -q "AllowTcpForwarding yes" /etc/ssh/sshd_config; then
        echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
        echo "GatewayPorts yes" >> /etc/ssh/sshd_config
        echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
        echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
    fi

    # Create user for IDX VPS
    useradd -m -s /bin/bash idxvps 2>/dev/null || true
    echo "idxvps:njan123" | chpasswd 2>/dev/null || echo "idxvps:njan123" | sudo chpasswd 2>/dev/null || true

    # Firewall
    ufw allow 22/tcp 2>/dev/null || sudo ufw allow 22/tcp 2>/dev/null || true
    ufw allow 3389/tcp 2>/dev/null || sudo ufw allow 3389/tcp 2>/dev/null || true
    ufw allow 8000/tcp 2>/dev/null || sudo ufw allow 8000/tcp 2>/dev/null || true
    ufw allow 8443/tcp 2>/dev/null || sudo ufw allow 8443/tcp 2>/dev/null || true

    systemctl restart ssh 2>/dev/null || sudo systemctl restart ssh 2>/dev/null || true

    echo ""
    echo -e "${GREEN}[✓] SSH Ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Give this info to IDX VPS:${NC}"
    echo ""
    echo -e "${YELLOW}Host:${NC} ${VPS_IP}"
    echo -e "${YELLOW}Port:${NC} 22"
    echo -e "${YELLOW}User:${NC} idxvps"
    echo -e "${YELLOW}Pass:${NC} njan123"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

install_tailscale() {
    echo ""
    echo -e "${YELLOW}[*] Installing Tailscale...${NC}"

    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null || sudo curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null || true
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list 2>/dev/null || sudo curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list 2>/dev/null || true

    apt-get update 2>/dev/null || sudo apt-get update 2>/dev/null || true
    apt-get install -y tailscale 2>/dev/null || sudo apt-get install -y tailscale 2>/dev/null || true

    systemctl enable tailscaled 2>/dev/null || sudo systemctl enable tailscaled 2>/dev/null || true
    systemctl start tailscaled 2>/dev/null || sudo systemctl start tailscaled 2>/dev/null || true

    echo ""
    echo -e "${GREEN}[✓] Tailscale installed!${NC}"
    echo ""
    echo -e "${YELLOW}To connect:${NC}"
    echo "   sudo tailscale up"
    echo ""
    echo -e "${YELLOW}Get IP:${NC}"
    echo "   tailscale ip -4"
}

check_connection() {
    echo ""
    echo -e "${YELLOW}[*] Checking Connections...${NC}"
    echo ""

    # Check SSH tunnel
    echo -e "${WHITE}SSH Tunnels:${NC}"
    if ss -tuln 2>/dev/null | grep -q ":3389 "; then
        echo -e "   ${GREEN}✓ Port 3389 (RDP) - LISTENING${NC}"
    else
        echo -e "   ${YELLOW}○ Port 3389 - WAITING${NC}"
    fi

    if ss -tuln 2>/dev/null | grep -q ":8000 "; then
        echo -e "   ${GREEN}✓ Port 8000 (HTTP) - LISTENING${NC}"
    else
        echo -e "   ${YELLOW}○ Port 8000 - WAITING${NC}"
    fi

    if ss -tuln 2>/dev/null | grep -q ":8443 "; then
        echo -e "   ${GREEN}✓ Port 8443 (Pterodactyl) - LISTENING${NC}"
    else
        echo -e "   ${YELLOW}○ Port 8443 - WAITING${NC}"
    fi

    echo ""

    # Check Tailscale
    echo -e "${WHITE}Tailscale:${NC}"
    if command -v tailscale &> /dev/null; then
        if systemctl is-active --quiet tailscaled 2>/dev/null; then
            TS_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
            echo -e "   ${GREEN}✓ Connected: ${TS_IP}${NC}"
        else
            echo -e "   ${YELLOW}○ Run: sudo tailscale up${NC}"
        fi
    else
        echo -e "   ${YELLOW}○ Not installed${NC}"
    fi

    echo ""
    echo -e "${YELLOW}VPS IP:${NC} ${VPS_IP}"
}

show_info() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}     ${WHITE}★  CONNECTION INFO  ★${NC}         ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}SSH Tunnel (IDX VPS connects here):${NC}"
    echo "   Host: ${VPS_IP}"
    echo "   Port: 22"
    echo "   User: idxvps"
    echo "   Pass: njan123"
    echo ""
    echo -e "${CYAN}ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 \\${NC}"
    echo -e "${CYAN}    -N -f -o ServerAliveInterval=60 idxvps@${VPS_IP}${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Access After IDX Connects:${NC}"
    echo "   Pterodactyl: http://${VPS_IP}:8443"
    echo "   RDP: ${VPS_IP}:3389"
    echo "   HTTP: http://${VPS_IP}:8000"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP  ★${NC}                 ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${WHITE}How It Works:${NC}"
    echo ""
    echo "   IDX VPS ── SSH Tunnel ──► PAID VPS ──► YOU"
    echo "      │                         │"
    echo "      │                         └── Always Online (24/7)"
    echo "      └── Tunnel connects"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""

    echo -e "${WHITE}Steps:${NC}"
    echo ""
    echo "   1. Run this script on PAID VPS"
    echo "   2. Select [1] Install SSH"
    echo "   3. Select [3] Install Tailscale (optional)"
    echo "   4. Select [4] Show Info"
    echo "   5. Copy SSH command"
    echo "   6. Run command in IDX VPS terminal"
    echo "   7. Enter password: njan123"
    echo "   8. KEEP TERMINAL OPEN!"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""

    echo -e "${WHITE}24/7 Check:${NC}"
    echo ""
    echo "   ✓ PAID VPS is 24/7"
    echo "   ✓ IDX VPS connects via SSH tunnel"
    echo "   ✓ Users connect to PAID VPS (not IDX directly)"
    echo "   ✓ As long as tunnel is open = 24/7!"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""
}

while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${WHITE}★  PAID VPS - 24/7 RELAY  ★${NC}    ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  ⚡ Install SSH Server"
    echo -e "       ${GREEN}[2]${NC}  🛡️  Install Tailscale (VPN)"
    echo -e "       ${GREEN}[3]${NC}  📊 Check Connections"
    echo -e "       ${GREEN}[4]${NC}  🔗 Show Connection Info"
    echo -e "       ${GREEN}[5]${NC}  ❓ Help"
    echo -e "       ${GREEN}[6]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter [1-6]: ${NC}"
    read -r choice

    # Trim whitespace
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
        1) install_ssh ;;
        2) install_tailscale ;;
        3) check_connection ;;
        4) show_info ;;
        5) show_help ;;
        6) echo ""; echo -e "${MAGENTA}★ Thanks! ★${NC}"; exit 0 ;;
        *) echo -e "${RED}[✗] Invalid!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter...${NC}"
    read
done
