#!/bin/bash

# ===============================================
# NjanFlame - PAID VPS (24/7) - Accept Tunnels
# Run this on your PAID 24/7 VPS
#
# Usage:
#   curl ... | sudo bash              # Auto-install SSH
#   curl ... | sudo bash install      # Install SSH only
#   curl ... | sudo bash info         # Show connection info
#   curl ... | sudo bash tailscale    # Install Tailscale only
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

# Get VPS IP
VPS_IP=$(hostname -I | awk '{print $1}')

print_banner() {
    clear
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██╔════╝${CYAN}██╔═══██╗${CYAN}██╔══██╗${CYAN}██╔══██╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██████╔╝${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██╔══██╗${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}╚██████╗╚██████╔╝${CYAN}██║  ██║${NC}${CYAN}██████╔╝${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚═════╝ ╚═════╝ ╚═╝  ╚═╝${NC}${CYAN}╚═════╝${NC}       ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
}

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
    echo -e "${GREEN}[✓] SSH Server Installed!${NC}"
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
    echo -e "${GREEN}[✓] Tailscale Installed!${NC}"
}

check_connection() {
    echo ""
    echo -e "${YELLOW}[*] Checking Connections...${NC}"
    echo ""

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
    echo -e "${CYAN}ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 \${NC}"
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
    echo ""
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
    echo -e "${WHITE}Usage (Command Line):${NC}"
    echo ""
    echo "   curl ... | sudo bash           # Auto-install SSH"
    echo "   curl ... | sudo bash install   # Install SSH only"
    echo "   curl ... | sudo bash info      # Show connection info"
    echo "   curl ... | sudo bash tailscale # Install Tailscale"
    echo "   curl ... | sudo bash check     # Check connections"
    echo "   curl ... | sudo bash help      # Show this help"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
    echo -e "${WHITE}Steps (Manual Menu):${NC}"
    echo ""
    echo "   1. Run this script on PAID VPS"
    echo "   2. Select [1] Install SSH"
    echo "   3. Select [4] Show Info"
    echo "   4. Copy SSH command"
    echo "   5. Run command in IDX VPS terminal"
    echo "   6. Enter password: njan123"
    echo "   7. KEEP TERMINAL OPEN!"
    echo ""
}

# Interactive menu
show_menu() {
    print_banner

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
}

# Check if running interactively
is_interactive() {
    [ -t 0 ] && return 0
    [ -e /dev/tty ] && return 0
    return 1
}

# Main
case "${1:-}" in
    install|i)
        print_banner
        install_ssh
        echo ""
        echo -e "${GREEN}[✓] Done! Run with 'info' to see connection details.${NC}"
        ;;
    tailscale|tailscale)
        print_banner
        install_tailscale
        ;;
    info|c|i)
        print_banner
        show_info
        ;;
    check|status)
        print_banner
        check_connection
        ;;
    help|h|--help)
        print_banner
        show_help
        ;;
    "")
        # No arguments - run interactively or auto-install SSH
        if is_interactive; then
            # Interactive mode
            while true; do
                show_menu
                echo -e "${YELLOW}    Enter [1-6]: ${NC}"
                read -r choice </dev/tty 2>/dev/null || read -r choice
                choice=$(echo "$choice" | tr -d '[:space:]')

                case $choice in
                    1) install_ssh; show_info ;;
                    2) install_tailscale ;;
                    3) check_connection ;;
                    4) show_info ;;
                    5) show_help ;;
                    6) echo ""; echo -e "${MAGENTA}★ Thanks! ★${NC}"; exit 0 ;;
                    *) echo -e "${RED}[✗] Invalid choice${NC}" ;;
                esac

                echo ""
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read </dev/tty 2>/dev/null || true
            done
        else
            # Non-interactive - auto install SSH
            print_banner
            echo ""
            echo -e "${YELLOW}[*] Auto-installing SSH Server...${NC}"
            echo ""
            install_ssh
            echo ""
            echo -e "${GREEN}[✓] SSH Server Installed!${NC}"
            echo ""
            show_info
            echo ""
            echo -e "${CYAN}Now go to your IDX VPS and run:${NC}"
            echo ""
            echo -e "${YELLOW}curl -sL https://raw.githubusercontent.com/Flame-556/njanflame-vps-vm/main/idx-vps-connect.sh | sudo bash${NC}"
            echo ""
        fi
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "   install   - Install SSH Server"
        echo "   tailscale - Install Tailscale VPN"
        echo "   info      - Show connection info"
        echo "   check     - Check connections"
        echo "   help      - Show help"
        echo ""
        echo "Or run without arguments for interactive menu"
        ;;
esac
