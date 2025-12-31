#!/bin/bash

# ===============================================
# NjanFlame - Connect IDX/GitHub to Your VPS
# Run this INSIDE your IDX or GitHub Workspace
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
#       ██╗   ██╗ ██████╗ ██╗██████╗
#       ██║   ██║██╔═══██╗██║██╔══██╗
#       ██║   ██║██║   ██║██║██║  ██║
#       ╚██╗ ██╔╝██║   ██║██║██║  ██║
#        ╚████╔╝ ╚██████╔╝██║██████╔╝
#         ╚═══╝   ╚═════╝ ╚═╝╚═════╝
#    ╔════════════════════════════════════╗
#    ║   NJANFLAME WORKSPACE CONNECTOR    ║
#    ║   Connect to Your 24/7 VPS         ║
#    ╚════════════════════════════════════╝
# ===========================================

sleep 0.3
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
echo -e "${CYAN}        https://github.com/njanflame${NC}"
echo ""
sleep 0.5

# ===============================================
# FUNCTIONS
# ===============================================

connect_vps() {
    echo ""
    echo -e "${YELLOW}[*] Connect to VPS${NC}"
    echo ""

    echo -e "${WHITE}VPS Details:${NC}"
    echo ""

    echo -e "${YELLOW}VPS IP:${NC}"
    read VPS_IP

    echo -e "${YELLOW}SSH Port [22]:${NC}"
    read PORT
    PORT=${PORT:-22}

    echo -e "${YELLOW}User [tunneluser]:${NC}"
    read USER
    USER=${USER:-tunneluser}

    echo -e "${YELLOW}Slot Name [idx-001]:${NC}"
    read SLOT
    SLOT=${SLOT:-idx-001}

    echo ""
    echo -e "${YELLOW}[*] Creating SSH Tunnel...${NC}"
    echo ""

    SSH_CMD="ssh -N -f -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -R 3389:localhost:3389 -R 8000:localhost:8000 ${USER}@${VPS_IP} -p ${PORT}"

    echo -e "${CYAN}Command:${NC}"
    echo "   $SSH_CMD"
    echo ""

    echo -e "${YELLOW}Enter VPS password when prompted:${NC}"
    echo -e "${YELLOW}Password: njanflame123${NC}"
    echo ""

    $SSH_CMD

    echo ""
    echo -e "${GREEN}[✓] Connected!${NC}"
    echo ""
    echo -e "${WHITE}Access your workspace via:${NC}"
    echo "   RDP: ${VPS_IP}:3389"
    echo "   HTTP: http://${VPS_IP}:8000"
    echo ""
    echo -e "${RED}⚠️  KEEP THIS TERMINAL OPEN!${NC}"
}

setup_keepalive() {
    echo ""
    echo -e "${YELLOW}[*] Auto-Reconnect Setup...${NC}"

    # Create keepalive script
    cat > ~/keepalive.sh << 'EOF'
#!/bin/bash
while true; do
    if ! pgrep -f "ssh.*-N" > /dev/null; then
        echo "[$(date)] Reconnecting..."
    fi
    sleep 30
done
EOF

    chmod +x ~/keepalive.sh

    echo ""
    echo -e "${GREEN}[✓] Auto-reconnect enabled!${NC}"
}

setup_rdp() {
    echo ""
    echo -e "${YELLOW}[*] RDP Server Setup...${NC}"

    # Install xrdp if not installed
    if ! command -v xrdp &> /dev/null; then
        apt-get update 2>/dev/null || sudo apt-get update 2>/dev/null || true
        apt-get install -y xrdp 2>/dev/null || sudo apt-get install -y xrdp 2>/dev/null || true
    fi

    echo "gnome-session" > ~/.xsession 2>/dev/null || true

    if command -v systemctl &> /dev/null; then
        sudo systemctl start xrdp 2>/dev/null || true
    fi

    echo ""
    echo -e "${GREEN}[✓] RDP Ready!${NC}"
    echo "   Port: 3389"
}

setup_http() {
    echo ""
    echo -e "${YELLOW}[*] HTTP Server Setup...${NC}"

    mkdir -p ~/public_html

    cat > ~/public_html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>NjanFlame 24/7</title>
    <style>
        body { background: #1a1a2e; color: white; font-family: sans-serif;
               display: flex; justify-content: center; align-items: center;
               height: 100vh; margin: 0; }
        h1 { color: #4CAF50; }
    </style>
</head>
<body>
    <h1>🚀 NjanFlame 24/7 Workspace</h1>
    <p>Connected via VPS Tunnel</p>
</body>
</html>
EOF

    cd ~/public_html
    python3 -m http.server 8000 > /dev/null 2>&1 &

    echo ""
    echo -e "${GREEN}[✓] HTTP Ready!${NC}"
    echo "   Port: 8000"
}

show_status() {
    echo ""
    echo -e "${YELLOW}[*] Status${NC}"
    echo ""

    if pgrep -f "ssh.*-N" > /dev/null; then
        echo -e "${GREEN}[✓] Tunnel: CONNECTED${NC}"
    else
        echo -e "${RED}[✗] Tunnel: NOT CONNECTED${NC}"
    fi

    if pgrep -f "xrdp" > /dev/null; then
        echo -e "${GREEN}[✓] RDP: RUNNING${NC}"
    fi

    if pgrep -f "python.*8000" > /dev/null; then
        echo -e "${GREEN}[✓] HTTP: RUNNING${NC}"
    fi
}

show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP  ★${NC}                 ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${WHITE}╭─ What This Does ─────────────────────────────╮${NC}"
    echo ""
    echo "    Connects your IDX/GitHub workspace to your 24/7 VPS"
    echo "    making it accessible 24/7 through the VPS!"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}╭─ Usage ─────────────────────────────────────╮${NC}"
    echo ""
    echo "    1. Get VPS info from owner (IP, user, password)"
    echo "    2. Run this script"
    echo "    3. Select [1] Connect to VPS"
    echo "    4. Enter VPS details"
    echo "    5. Enter password: njanflame123"
    echo "    6. KEEP TERMINAL OPEN!"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}╭─ Access ────────────────────────────────────╮${NC}"
    echo ""
    echo "    After connection:"
    echo "       RDP: VPS-IP:3389"
    echo "       HTTP: http://VPS-IP:8000"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

disconnect() {
    echo ""
    echo -e "${YELLOW}[*] Disconnecting...${NC}"

    pkill -f "ssh.*-N" 2>/dev/null || true
    pkill -f "xrdp" 2>/dev/null || true
    pkill -f "python.*8000" 2>/dev/null || true

    echo -e "${GREEN}[✓] Disconnected!${NC}"
    exit 0
}

# ===============================================
# MAIN MENU
# ===============================================

while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${WHITE}★  CONNECTOR MENU  ★${NC}           ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  🔗 Connect to VPS"
    echo -e "       ${GREEN}[2]${NC}  🔄 Auto-Reconnect"
    echo -e "       ${GREEN}[3]${NC}  💻 Setup RDP"
    echo -e "       ${GREEN}[4]${NC}  🌐 Setup HTTP"
    echo -e "       ${GREEN}[5]${NC}  📊 Status"
    echo -e "       ${GREEN}[6]${NC}  ❓ Help"
    echo -e "       ${GREEN}[7]${NC}  🚪 Disconnect & Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter choice [1-7]: ${NC}"
    read choice

    case $choice in
        1) connect_vps ;;
        2) setup_keepalive ;;
        3) setup_rdp ;;
        4) setup_http ;;
        5) show_status ;;
        6) show_help ;;
        7) disconnect ;;
        *) echo -e "${RED}[✗] Invalid!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter...${NC}"
    read
done
