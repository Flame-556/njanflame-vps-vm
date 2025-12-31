#!/bin/bash

# ===============================================
# NjanFlame - IDX VPS Connect to Paid VPS
# Run this on your IDX VPS (created with script)
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
echo -e "${ORANGE}    ║${NC}   ${CYAN}██╗   ██╗${CYAN} ██████╗ ${CYAN}██╗██████╗${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██╔═══██╗${NC}${CYAN}██║██╔══██╗${NC}     ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${NC}     ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚██╗ ██╔╝${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${NC}     ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}  ╚████╔╝ ${CYAN}╚██████╔╝${NC}${CYAN}██║██████╔╝${NC}     ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ║${NC}   ${CYAN}   ╚═══╝   ${CYAN}╚═════╝ ${NC}${CYAN}╚═╝╚═════╝${NC}      ${ORANGE}║${NC}"
sleep 0.1
echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 0.2
echo ""
echo -e "${MAGENTA}        ★  ★  ★  ULTIMATE EDITION  ★  ★  ★${NC}"
echo ""
sleep 0.3
echo -e "${GREEN}            [ CONNECTING... ]${NC}"
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

connect() {
    echo ""
    echo -e "${YELLOW}[*] Connect to Paid VPS${NC}"
    echo ""

    echo -e "${WHITE}Enter Paid VPS Details:${NC}"
    echo ""

    echo -e "${YELLOW}Paid VPS IP:${NC}"
    read PAID_IP

    echo -e "${YELLOW}User [idxvps]:${NC}"
    read USER
    USER=${USER:-idxvps}

    echo ""
    echo -e "${YELLOW}[*] Creating SSH Tunnel...${NC}"
    echo ""

    # SSH tunnel with all ports for Pterodactyl
    SSH_CMD="ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 -N -f -o ServerAliveInterval=60 -o StrictHostKeyChecking=no ${USER}@${PAID_IP}"

    echo -e "${CYAN}Command:${NC}"
    echo "   $SSH_CMD"
    echo ""

    echo -e "${YELLOW}Enter password when prompted:${NC}"
    echo -e "${YELLOW}Password: njan123${NC}"
    echo ""

    $SSH_CMD 2>&1 || true

    # Save connection info for auto-reconnect
    echo "${PAID_IP}:${USER}" > ~/.idx-connection

    echo ""
    echo -e "${GREEN}[✓] Connected!${NC}"
    echo ""
    echo -e "${WHITE}Your IDX VPS is now 24/7 via Paid VPS!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Access Via Paid VPS:${NC}"
    echo "   Pterodactyl: http://${PAID_IP}:8443"
    echo "   RDP: ${PAID_IP}:3389"
    echo "   HTTP: http://${PAID_IP}:8000"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}⚠️  KEEP THIS TERMINAL OPEN!${NC}"
    echo -e "${YELLOW}If disconnected, select [2] Auto-Reconnect${NC}"
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
        # Read connection info
        if [ -f ~/.idx-connection ]; then
            IFS=':' read -r PAID_IP USER < ~/.idx-connection
            ssh -R 3389:localhost:3389 -R 8000:localhost:8000 -R 8443:localhost:8443 -N -f -o ServerAliveInterval=60 -o StrictHostKeyChecking=no ${USER}@${PAID_IP} 2>/dev/null
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
    echo ""
    echo -e "${YELLOW}To check status:${NC}"
    echo "   ps aux | grep auto-reconnect"
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
    echo -e "${GREEN}[✓] Tailscale installed!${NC}"
    echo ""
    echo -e "${YELLOW}To connect:${NC}"
    echo "   sudo tailscale up"
    echo ""
    echo -e "${YELLOW}Get your Tailscale IP:${NC}"
    echo "   tailscale ip -4"
    echo ""
    echo -e "${WHITE}Use this IP in Termius to connect directly!${NC}"
}

show_status() {
    echo ""
    echo -e "${YELLOW}[*] Connection Status${NC}"
    echo ""

    # Check SSH tunnel
    echo -e "${WHITE}SSH Tunnel:${NC}"
    if pgrep -f "ssh.*-R" > /dev/null; then
        echo -e "${GREEN}✓ Connected to Paid VPS${NC}"
        ps aux | grep "ssh.*-R" | grep -v grep | head -1
    else
        echo -e "${RED}✗ Not Connected${NC}"
    fi

    echo ""

    # Check auto-reconnect
    echo -e "${WHITE}Auto-Reconnect:${NC}"
    if pgrep -f "auto-reconnect" > /dev/null; then
        echo -e "${GREEN}✓ Running in Background${NC}"
    else
        echo -e "${YELLOW}○ Not Running (select [2] to enable)${NC}"
    fi

    echo ""

    # Check Tailscale
    echo -e "${WHITE}Tailscale:${NC}"
    if command -v tailscale &> /dev/null; then
        if systemctl is-active --quiet tailscaled 2>/dev/null; then
            TS_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
            echo -e "${GREEN}✓ Connected: ${TS_IP}${NC}"
        else
            echo -e "${YELLOW}○ Run: sudo tailscale up${NC}"
        fi
    else
        echo -e "${YELLOW}○ Not installed${NC}"
    fi
}

show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP  ★${NC}                 ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${WHITE}What This Does:${NC}"
    echo ""
    echo "   IDX VPS ── SSH Tunnel ──► PAID VPS (24/7) ──► YOU"
    echo "      │                         │"
    echo "      │                         └── Always Online"
    echo "      └── Creates tunnel"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""

    echo -e "${WHITE}How It Becomes 24/7:${NC}"
    echo ""
    echo "   ✓ Users don't connect to IDX directly"
    echo "   ✓ Users connect to PAID VPS (always online)"
    echo "   ✓ PAID VPS forwards to IDX via tunnel"
    echo "   ✓ As long as tunnel is open = 24/7!"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""

    echo -e "${WHITE}Steps:${NC}"
    echo ""
    echo "   1. Run script on PAID VPS first → Install SSH"
    echo "   2. Get SSH command from PAID VPS"
    echo "   3. Run this script on IDX VPS"
    echo "   4. Select [1] Connect to Paid VPS"
    echo "   5. Enter Paid VPS IP"
    echo "   6. Enter password: njan123"
    echo "   7. KEEP TERMINAL OPEN!"
    echo "   8. (Optional) Select [2] Auto-Reconnect"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""

    echo -e "${WHITE}Access Your Pterodactyl:${NC}"
    echo ""
    echo "   Browser: http://PAID-VPS-IP:8443"
    echo ""
    echo -e "${CYAN}    ─────────────────────────────────────────${NC}"
    echo ""
}

disconnect() {
    echo ""
    echo -e "${YELLOW}[*] Disconnecting...${NC}"

    pkill -f "ssh.*-R" 2>/dev/null || true
    pkill -f "auto-reconnect" 2>/dev/null || true

    rm -f ~/.idx-connection

    echo ""
    echo -e "${GREEN}[✓] Disconnected!${NC}"
    echo ""
    echo -e "${MAGENTA}★ Thanks! ★${NC}"
    exit 0
}

while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}  ${WHITE}★  IDX VPS - 24/7 CONNECTOR  ★${NC}  ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  🔗 Connect to Paid VPS"
    echo -e "       ${GREEN}[2]${NC}  🔄 Auto-Reconnect (Keep Alive)"
    echo -e "       ${GREEN}[3]${NC}  🛡️  Install Tailscale (VPN)"
    echo -e "       ${GREEN}[4]${NC}  📊 Status"
    echo -e "       ${GREEN}[5]${NC}  ❓ Help"
    echo -e "       ${GREEN}[6]${NC}  🚪 Disconnect & Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter [1-6]: ${NC}"
    read choice

    case $choice in
        1) connect ;;
        2) auto_reconnect ;;
        3) setup_tailscale ;;
        4) show_status ;;
        5) show_help ;;
        6) disconnect ;;
        *) echo -e "${RED}[✗] Invalid!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter...${NC}"
    read
done
