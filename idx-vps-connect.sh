#!/bin/bash

# ===============================================
# NjanFlame - IDX VPS Connect to Paid VPS
# Run this on your IDX VPS
#
# Usage:
#   curl ... | sudo bash              # Interactive menu
#   curl ... | sudo bash connect IP   # Connect to VPS
#   curl ... | sudo bash auto         # Enable auto-reconnect
#   curl ... | sudo bash status       # Check status
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

print_banner() {
    clear
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██╗   ██╗${CYAN} ██████╗ ${CYAN}██╗██████╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██╔═══██╗${NC}${CYAN}██║██╔══██╗${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚██╗ ██╔╝${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}  ╚████╔╝ ${CYAN}╚██████╔╝${NC}${CYAN}██║██████╔╝${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}   ╚═══╝   ${CYAN}╚═════╝ ${NC}${CYAN}╚═╝╚═════╝${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
}

connect_to_vps() {
    local PAID_IP="$1"
    local USER="${2:-idxvps}"

    if [ -z "$PAID_IP" ]; then
        echo ""
        echo -e "${RED}[✗] Please provide VPS IP${NC}"
        echo "Usage: $0 connect <VPS-IP> [username]"
        return 1
    fi

    print_banner
    echo ""
    echo -e "${YELLOW}[*] Connecting to Paid VPS...${NC}"
    echo ""
    echo -e "${WHITE}VPS IP:${NC} $PAID_IP"
    echo -e "${WHITE}User:${NC} $USER"
    echo -e "${WHITE}Password:${NC} njan123"
    echo ""

    # Create SSH tunnel
    ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 \
        -N -f -o ServerAliveInterval=60 -o StrictHostKeyChecking=no \
        ${USER}@${PAID_IP}

    # Save connection info
    echo "${PAID_IP}:${USER}" > ~/.idx-connection

    echo ""
    echo -e "${GREEN}[✓] Connected Successfully!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Access your IDX VPS via:${NC}"
    echo "   RDP: ${PAID_IP}:3389"
    echo "   HTTP: http://${PAID_IP}:8000"
    echo "   Pterodactyl: http://${PAID_IP}:8443"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}⚠️  KEEP THIS TERMINAL OPEN!${NC}"
    echo ""
}

auto_reconnect() {
    echo ""
    echo -e "${YELLOW}[*] Setting Up Auto-Reconnect...${NC}"

    # Create auto-reconnect script
    cat > ~/auto-reconnect.sh << 'EOF'
#!/bin/bash
while true; do
    if ! pgrep -f "ssh.*-R" > /dev/null; then
        echo "[$(date)] Tunnel disconnected. Reconnecting..."
        if [ -f ~/.idx-connection ]; then
            IFS=':' read -r PAID_IP USER < ~/.idx-connection
            ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 \
                -N -f -o ServerAliveInterval=60 -o StrictHostKeyChecking=no \
                ${USER}@${PAID_IP} 2>/dev/null
        fi
    fi
    sleep 30
done
EOF

    chmod +x ~/auto-reconnect.sh

    # Start in background
    nohup bash ~/auto-reconnect.sh > ~/reconnect.log 2>&1 &

    echo ""
    echo -e "${GREEN}[✓] Auto-Reconnect Enabled!${NC}"
    echo ""
    echo -e "${WHITE}What it does:${NC}"
    echo "   ✓ Checks every 30 seconds"
    echo "   ✓ Reconnects if tunnel drops"
    echo "   ✓ Runs in background"
}

setup_tailscale() {
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
    echo ""
    echo -e "${YELLOW}Run: sudo tailscale up${NC}"
}

show_status() {
    echo ""
    echo -e "${YELLOW}[*] Connection Status${NC}"
    echo ""

    echo -e "${WHITE}SSH Tunnel:${NC}"
    if pgrep -f "ssh.*-R" > /dev/null; then
        echo -e "${GREEN}✓ Connected${NC}"
    else
        echo -e "${RED}✗ Not Connected${NC}"
    fi

    echo ""
    echo -e "${WHITE}Auto-Reconnect:${NC}"
    if pgrep -f "auto-reconnect" > /dev/null; then
        echo -e "${GREEN}✓ Running${NC}"
    else
        echo -e "${YELLOW}○ Not Running${NC}"
    fi
}

show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP  ★${NC}                 ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Usage:${NC}"
    echo ""
    echo "   curl ... | sudo bash              # Interactive menu"
    echo "   curl ... | sudo bash connect IP   # Connect to VPS"
    echo "   curl ... | sudo bash auto         # Enable auto-reconnect"
    echo "   curl ... | sudo bash status       # Check status"
    echo ""
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
    echo -e "${WHITE}Quick Connect:${NC}"
    echo ""
    echo "   1. Get info from PAID VPS"
    echo "   2. Run: curl ... | sudo bash connect <VPS-IP>"
    echo "   3. Enter password: njan123"
    echo "   4. KEEP TERMINAL OPEN!"
}

# Check if running interactively
is_interactive() {
    [ -t 0 ] && return 0
    [ -e /dev/tty ] && return 0
    return 1
}

# Interactive menu
show_menu() {
    print_banner

    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  🔗 Connect to Paid VPS"
    echo -e "       ${GREEN}[2]${NC}  🔄 Auto-Reconnect"
    echo -e "       ${GREEN}[3]${NC}  🛡️  Install Tailscale"
    echo -e "       ${GREEN}[4]${NC}  📊 Status"
    echo -e "       ${GREEN}[5]${NC}  ❓ Help"
    echo -e "       ${GREEN}[6]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Main
case "${1:-}" in
    connect|c)
        connect_to_vps "${2:-}" "${3:-}"
        ;;
    auto|a|reconnect)
        auto_reconnect
        ;;
    tailscale|tailscale)
        setup_tailscale
        ;;
    status|s)
        show_status
        ;;
    help|h|--help)
        print_banner
        show_help
        ;;
    "")
        # No arguments
        if is_interactive; then
            while true; do
                show_menu
                echo -e "${YELLOW}Enter [1-6]: ${NC}"
                read -r choice </dev/tty 2>/dev/null || read -r choice
                choice=$(echo "$choice" | tr -d '[:space:]')

                case $choice in
                    1)
                        echo ""
                        echo -e "${YELLOW}VPS IP:${NC}"
                        read -r PAID_IP </dev/tty 2>/dev/null || read -r PAID_IP
                        echo -e "${YELLOW}User [idxvps]:${NC}"
                        read -r USER </dev/tty 2>/dev/null || read -r USER
                        connect_to_vps "$PAID_IP" "$USER"
                        ;;
                    2) auto_reconnect ;;
                    3) setup_tailscale ;;
                    4) show_status ;;
                    5) show_help ;;
                    6) echo ""; echo -e "${MAGENTA}★ Thanks! ★${NC}"; exit 0 ;;
                    *) echo -e "${RED}[✗] Invalid${NC}" ;;
                esac

                echo ""
                echo -e "${YELLOW}Press Enter to continue...${NC}"
                read </dev/tty 2>/dev/null || true
            done
        else
            print_banner
            echo ""
            echo -e "${RED}[✗] Interactive mode required${NC}"
            echo ""
            echo "Usage: $0 connect <VPS-IP>"
            echo ""
            echo "Or run in interactive terminal:"
            echo "   curl ... | sudo bash"
        fi
        ;;
    *)
        echo -e "${RED}Unknown: $1${NC}"
        echo ""
        echo "Usage: $0 [command]"
        echo "Commands: connect, auto, status, tailscale, help"
        ;;
esac
