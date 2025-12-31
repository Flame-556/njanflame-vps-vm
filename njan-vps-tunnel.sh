#!/bin/bash

# ===============================================
# NjanFlame VPS - Accept IDX/GitHub Tunnels
# Run this on your 24/7 PAID VPS
# ===============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m'

clear

# ===============================================
#       ██████╗ ██████╗ ██████╗ ██████╗
#      ██╔════╝██╔═══██╗██╔══██╗██╔══██╗
#      ██║     ██║   ██║██████╔╝██║  ██║
#      ██║     ██║   ██║██╔══██╗██║  ██║
#      ╚██████╗╚██████╔╝██║  ██║██████╔╝
#       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝
#    ╔════════════════════════════════════╗
#    ║   NJANFLAME VPS TUNNEL MANAGER     ║
#    ║   Accept IDX/GitHub Connections    ║
#    ╚════════════════════════════════════╝
# ===========================================

sleep 0.3
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
echo -e "${GREEN}            [ LOADING SYSTEM... ]${NC}"
sleep 0.5

for i in {1..15}; do
    echo -ne "${GREEN}            █${NC}"
    sleep 0.03
done
echo ""
sleep 0.3
echo -e "${GREEN}            [ SYSTEM READY ]${NC}"
echo ""
sleep 0.3
echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}        Made with ❤️  by NjanFlame${NC}"
echo -e "${CYAN}        https://github.com/njanflame${NC}"
echo ""
sleep 0.5

# ===============================================
# FUNCTIONS
# ===============================================

install_ssh() {
    echo ""
    echo -e "${YELLOW}[*] Installing SSH Server...${NC}"

    apt-get update
    apt-get install -y openssh-server ufw

    # Configure SSH for tunneling
    if ! grep -q "AllowTcpForwarding yes" /etc/ssh/sshd_config; then
        echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
        echo "GatewayPorts yes" >> /etc/ssh/sshd_config
        echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
        echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
    fi

    # Create tunnel user
    useradd -m -s /bin/bash tunneluser 2>/dev/null || true
    echo "tunneluser:njanflame123" | chpasswd

    # Firewall
    ufw allow 22/tcp
    ufw allow 3389/tcp
    ufw allow 8000/tcp
    ufw allow 8001/tcp
    ufw allow 8002/tcp
    ufw allow 8003/tcp
    ufw allow 8004/tcp
    ufw allow 8005/tcp
    ufw allow 8006/tcp

    # Restart SSH
    systemctl restart ssh

    echo ""
    echo -e "${GREEN}[✓] SSH Server Ready!${NC}"
    echo ""
    echo -e "${YELLOW}Credentials for IDX/GitHub:${NC}"
    echo "   Host: $(hostname -I | awk '{print $1}')"
    echo "   Port: 22"
    echo "   User: tunneluser"
    echo "   Password: njanflame123"
}

add_workspace() {
    echo ""
    echo -e "${YELLOW}[*] Add Workspace Slot${NC}"
    echo ""

    echo -e "${WHITE}Available Slots:${NC}"
    echo "   1. idx-001     → RDP:3389  HTTP:8000"
    echo "   2. idx-002     → RDP:3390  HTTP:8001"
    echo "   3. idx-003     → RDP:3391  HTTP:8002"
    echo "   4. idx-004     → RDP:3392  HTTP:8003"
    echo "   5. github-001  → RDP:3393  HTTP:8004"
    echo "   6. github-002  → RDP:3394  HTTP:8005"
    echo "   7. github-003  → RDP:3395  HTTP:8006"
    echo ""

    echo -e "${YELLOW}Enter slot [1-7]:${NC}"
    read sel

    case $sel in
        1) WS="idx-001"; RDP=3389; HTTP=8000 ;;
        2) WS="idx-002"; RDP=3390; HTTP=8001 ;;
        3) WS="idx-003"; RDP=3391; HTTP=8002 ;;
        4) WS="idx-004"; RDP=3392; HTTP=8003 ;;
        5) WS="github-001"; RDP=3393; HTTP=8004 ;;
        6) WS="github-002"; RDP=3394; HTTP=8005 ;;
        7) WS="github-003"; RDP=3395; HTTP=8006 ;;
        *) echo -e "${RED}Invalid!${NC}"; return ;;
    esac

    VPS_IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${GREEN}[✓] ${WS} Ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}SSH Tunnel Command (run in IDX/GitHub terminal):${NC}"
    echo ""
    echo -e "${CYAN}ssh -N -f -o ServerAliveInterval=60 \\${NC}"
    echo -e "${CYAN}    -R ${RDP}:localhost:3389 \\${NC}"
    echo -e "${CYAN}    -R ${HTTP}:localhost:8000 \\${NC}"
    echo -e "${CYAN}    tunneluser@${VPS_IP}${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}After Connected - Access Via:${NC}"
    echo "   RDP: ${VPS_IP}:${RDP}"
    echo "   HTTP: http://${VPS_IP}:${HTTP}"
}

list_tunnels() {
    echo ""
    echo -e "${YELLOW}[*] Active Tunnels${NC}"
    echo ""

    VPS_IP=$(hostname -I | awk '{print $1}')

    echo -e "${WHITE}Slot         | RDP Port | HTTP Port | Status${NC}"
    echo "   ──────────────────────────────────────────"

    declare -A PORTS=(
        ["idx-001"]="3389:8000"
        ["idx-002"]="3390:8001"
        ["idx-003"]="3391:8002"
        ["idx-004"]="3392:8003"
        ["github-001"]="3393:8004"
        ["github-002"]="3394:8005"
        ["github-003"]="3395:8006"
    )

    for ws in "${!PORTS[@]}"; do
        rdp=$(echo ${PORTS[$ws]} | cut -d: -f1)
        http=$(echo ${PORTS[$ws]} | cut -d: -f2)

        if ss -tuln 2>/dev/null | grep -q ":${rdp} "; then
            echo -e "   ${GREEN}${ws}${NC}     | ${GREEN}${rdp}${NC}     | ${GREEN}${http}${NC}     | ${GREEN}CONNECTED${NC}"
        else
            echo -e "   ${ws}     | ${rdp}     | ${http}     | ${YELLOW}WAITING${NC}"
        fi
    done

    echo ""
    echo -e "${YELLOW}VPS IP:${NC} ${VPS_IP}"
}

show_info() {
    VPS_IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}     ${WHITE}★  CONNECTION INFO  ★${NC}         ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}VPS IP:${NC} ${VPS_IP}"
    echo -e "${YELLOW}SSH Port:${NC} 22"
    echo -e "${YELLOW}User:${NC} tunneluser"
    echo -e "${YELLOW}Password:${NC} njanflame123"
    echo ""
    echo -e "${WHITE}Access Slots:${NC}"
    echo "   idx-001     → RDP:3389  HTTP:8000"
    echo "   idx-002     → RDP:3390  HTTP:8001"
    echo "   idx-003     → RDP:3391  HTTP:8002"
    echo "   idx-004     → RDP:3392  HTTP:8003"
    echo "   github-001  → RDP:3393  HTTP:8004"
    echo "   github-002  → RDP:3394  HTTP:8005"
    echo "   github-003  → RDP:3395  HTTP:8006"
}

show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP  ★${NC}                 ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${WHITE}╭─ How It Works ─────────────────────────────╮${NC}"
    echo ""
    echo "    IDX/GitHub Workspace"
    echo "           │"
    echo "           │ SSH Reverse Tunnel"
    echo "           │ (connects to VPS)"
    echo "           ▼"
    echo "    Your 24/7 VPS (this server)"
    echo "           │"
    echo "           │ Forward to users"
    echo "           ▼"
    echo "    Users connect via RDP/HTTP"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}╭─ Setup Steps ─────────────────────────────────╮${NC}"
    echo ""
    echo "    1. Run this script on your 24/7 VPS"
    echo "    2. Select [1] to install SSH"
    echo "    3. Select [2] to add workspace slot"
    echo "    4. Copy SSH command"
    echo "    5. Give command to IDX/GitHub user"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}╭─ For IDX/GitHub User ───────────────────────╮${NC}"
    echo ""
    echo "    1. Open terminal in workspace"
    echo "    2. Paste SSH command"
    echo "    3. Enter password: njanflame123"
    echo "    4. Keep terminal OPEN"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ===============================================
# MAIN MENU
# ===============================================

while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}    ${WHITE}★  NJANFLAME VPS  ★${NC}            ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  ⚡ Install SSH Server"
    echo -e "       ${GREEN}[2]${NC}  ➕ Add Workspace Slot"
    echo -e "       ${GREEN}[3]${NC}  📊 List Active Tunnels"
    echo -e "       ${GREEN}[4]${NC}  🔗 Show Connection Info"
    echo -e "       ${GREEN}[5]${NC}  🔄 Restart SSH"
    echo -e "       ${GREEN}[6]${NC}  ❓ Help"
    echo -e "       ${GREEN}[7]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter choice [1-7]: ${NC}"
    read choice

    case $choice in
        1) install_ssh ;;
        2) add_workspace ;;
        3) list_tunnels ;;
        4) show_info ;;
        5) systemctl restart ssh; echo -e "${GREEN}[✓] SSH restarted!${NC}" ;;
        6) show_help ;;
        7) echo ""; echo -e "${MAGENTA}★ Thanks! ★${NC}"; exit 0 ;;
        *) echo -e "${RED}[✗] Invalid!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter...${NC}"
    read
done
