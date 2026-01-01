#!/bin/bash

# ===============================================
# Ubuntu VM Client - Menu Setup with Auto-Refresh
# Run this on your NON-24/7 Ubuntu VM
# ===============================================

set -e

# NjanFlame Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m'

# Clear screen
clear

# ===============================================
#       ██╗   ██╗ ██████╗ ██╗██████╗
#       ██║   ██║██╔═══██╗██║██╔══██╗
#       ██║   ██║██║   ██║██║██║  ██║
#       ╚██╗ ██╔╝██║   ██║██║██║  ██║
#        ╚████╔╝ ╚██████╔╝██║██████╔╝
#         ╚═══╝   ╚═════╝ ╚═╝╚═════╝
#    ╔════════════════════════════════════╗
#    ║   ULTIMATE NJANFLAME VM CLIENT     ║
#    ║      AUTO-REFRESH • 24/7 RELAY     ║
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

# Animated line
echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 0.2
echo ""
echo -e "${MAGENTA}        ★  ★  ★  ULTIMATE EDITION  ★  ★  ★${NC}"
echo ""
sleep 0.3
echo -e "${GREEN}            [ INITIALIZING... ]${NC}"
sleep 0.5

# Loading animation
for i in {1..10}; do
    echo -ne "${GREEN}            █${NC}"
    sleep 0.05
done
echo ""
sleep 0.3
echo -e "${GREEN}            [ SYSTEM ONLINE ]${NC}"
echo ""
sleep 0.3
echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}        Made with ❤️  by NjanFlame${NC}"
echo -e "${CYAN}        https://github.com/njanflame${NC}"
echo ""
sleep 0.5

# Arrays for VMs
VM_OPTIONS=("vm-001" "vm-002" "vm-003" "vm-004" "vm-005" "vm-006")
VM_RDP_PORTS=(3389 3390 3391 3392 3393 3394)

# Function to setup RDP
setup_rdp() {
    echo -e "${YELLOW}[*] Installing Desktop and RDP...${NC}"

    apt-get update
    apt-get upgrade -y

    apt-get install -y \
        ubuntu-desktop \
        xrdp \
        xorg \
        firefox \
        xdotool \
        wget \
        curl

    # Configure XRDP
    echo "gnome-session" > ~/.xsession
    cp ~/.xsession /root/.xsession

    systemctl enable xrdp
    systemctl restart xrdp

    echo -e "${GREEN}[✓] RDP installed!${NC}"
}

# Function to setup FRP client
setup_frp() {
    echo ""
    echo -e "${YELLOW}[*] Setting up FRP Client...${NC}"
    echo ""

    echo -e "${YELLOW}VPS IP or Domain:${NC}"
    read VPS_IP </dev/tty 2>/dev/null || read VPS_IP

    echo -e "${YELLOW}FRP Port [7000]:${NC}"
    read FRP_PORT </dev/tty 2>/dev/null || read FRP_PORT
    FRP_PORT=${FRP_PORT:-7000}

    echo -e "${YELLOW}Token (from VPS):${NC}"
    read TOKEN </dev/tty 2>/dev/null || read TOKEN

    echo -e "${YELLOW}Select VM Name:${NC}"
    echo "   1. vm-001 (RDP Port 3389)"
    echo "   2. vm-002 (RDP Port 3390)"
    echo "   3. vm-003 (RDP Port 3391)"
    echo "   4. vm-004 (RDP Port 3392)"
    echo "   5. vm-005 (RDP Port 3393)"
    echo "   6. vm-006 (RDP Port 3394)"
    echo ""
    echo -e "${YELLOW}Enter number [1-6]:${NC}"
    read VM_NUM </dev/tty 2>/dev/null || read VM_NUM

    case $VM_NUM in
        1) VM_NAME="vm-001"; RDP_PORT=3389 ;;
        2) VM_NAME="vm-002"; RDP_PORT=3390 ;;
        3) VM_NAME="vm-003"; RDP_PORT=3391 ;;
        4) VM_NAME="vm-004"; RDP_PORT=3392 ;;
        5) VM_NAME="vm-005"; RDP_PORT=3393 ;;
        6) VM_NAME="vm-006"; RDP_PORT=3394 ;;
        *) VM_NAME="vm-001"; RDP_PORT=3389 ;;
    esac

    echo ""
    echo -e "${YELLOW}[*] Downloading FRP...${NC}"

    FRP_VERSION="0.52.3"
    FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"

    cd /tmp
    wget -q "${FRP_URL}" -O frp.tar.gz
    tar -xzf frp.tar.gz
    rm frp.tar.gz

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
remote_port = ${RDP_PORT}
use_encryption = true
use_compression = true

[${VM_NAME}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = $((RDP_PORT + 100))
use_encryption = true
use_compression = true
EOF

    # Create systemd service
    cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=FRP Client
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

    echo -e "${GREEN}[✓] FRP Client configured!${NC}"
}

# Function to setup auto-refresh (keeps VM awake)
setup_autorefresh() {
    echo ""
    echo -e "${YELLOW}[*] Setting up Auto-Refresh (Keep VM Active)...${NC}"
    echo ""

    echo -e "${YELLOW}Enter URL to refresh [e.g., https://google.com]:${NC}"
    echo "   (Leave empty to refresh localhost:3389)"
    read AUTO_URL </dev/tty 2>/dev/null || read AUTO_URL

    if [ -z "$AUTO_URL" ]; then
        # Create auto-refresh for RDP session
        cat > /opt/frp/auto-refresh.sh << 'EOF'
#!/bin/bash
# Auto-refresh script to keep VM active
# Runs every 5 minutes to simulate user activity

REFRESH_INTERVAL=300  # 5 minutes in seconds

while true; do
    # Simulate user activity - press a key
    xdotool key --delay 1000 Caps_Lock 2>/dev/null || true

    # Open and refresh a page in Firefox if available
    if command -v firefox &> /dev/null; then
        # Create a simple HTML refresh page
        cat > /tmp/keepalive.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="300">
    <title>Keep Alive</title>
    <style>
        body { background: #1a1a2e; color: white; font-family: sans-serif;
               display: flex; justify-content: center; align-items: center;
               height: 100vh; margin: 0; }
        .status { text-align: center; }
        .dot { height: 20px; width: 20px; background-color: #4CAF50;
               border-radius: 50%; display: inline-block; margin: 10px;
               animation: pulse 2s infinite; }
        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 1; }
            50% { transform: scale(1); opacity: 0.7; }
            100% { transform: scale(0.95); opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="status">
        <h1>VM Keep-Alive Active</h1>
        <p>Auto-refreshing every 5 minutes...</p>
        <div class="dot"></div>
    </div>
</body>
</html>
HTMLEOF

        # Use Firefox in headless mode if available
        DISPLAY=:0 firefox /tmp/keepalive.html --headless 2>/dev/null || true
    fi

    sleep $REFRESH_INTERVAL
done
EOF
    else
        # Custom URL refresh
        cat > /opt/frp/auto-refresh.sh << EOF
#!/bin/bash
# Auto-refresh script with custom URL

REFRESH_INTERVAL=300  # 5 minutes

while true; do
    # Simulate user activity - press a key
    xdotool key --delay 1000 Caps_Lock 2>/dev/null || true

    # Open URL in Firefox and refresh
    if command -v firefox &> /dev/null; then
        DISPLAY=:0 firefox "${AUTO_URL}" --new-tab 2>/dev/null || true
    fi

    sleep $REFRESH_INTERVAL
done
EOF
    fi

    chmod +x /opt/frp/auto-refresh.sh

    # Create systemd service
    cat > /etc/systemd/system/autorefresh.service << 'EOF'
[Unit]
Description=Auto Refresh - Keep VM Active
After=graphical.target

[Service]
Type=simple
ExecStart=/opt/frp/auto-refresh.sh
Restart=always
RestartSec=10
User=root
Environment=DISPLAY=:0

[Install]
WantedBy=graphical.target
EOF

    systemctl daemon-reload
    systemctl enable autorefresh
    systemctl start autorefresh

    echo -e "${GREEN}[✓] Auto-refresh enabled!${NC}"
    echo "   - Will refresh every 5 minutes"
    echo "   - Will simulate key presses"
}

# Function to setup Tailscale
setup_tailscale() {
    echo ""
    echo -e "${YELLOW}[*] Installing Tailscale...${NC}"

    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list
    apt-get update
    apt-get install -y tailscale

    systemctl enable tailscaled
    systemctl start tailscaled

    echo -e "${GREEN}[✓] Tailscale installed!${NC}"
    echo ""
    echo -e "${YELLOW}To connect:${NC}"
    echo "   sudo tailscale up"
    echo ""
}

# Function to setup sleep prevention
setup_nosleep() {
    echo ""
    echo -e "${YELLOW}[*] Disabling Sleep/Suspend...${NC}"

    # Disable GNOME sleep
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false

    # Create systemd inhibitor
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

    echo -e "${GREEN}[✓] Sleep disabled!${NC}"
}

# Function to show status
show_status() {
    echo ""
    echo -e "${YELLOW}[*] System Status:${NC}"
    echo ""

    echo "FRP Client:"
    systemctl status frpc --no-pager 2>/dev/null | head -3 || echo "   Not installed"

    echo ""
    echo "Auto-Refresh:"
    systemctl status autorefresh --no-pager 2>/dev/null | head -3 || echo "   Not installed"

    echo ""
    echo "No-Sleep:"
    systemctl status nosleep --no-pager 2>/dev/null | head -3 || echo "   Not installed"

    echo ""
    echo "XRDP:"
    systemctl status xrdp --no-pager 2>/dev/null | head -3 || echo "   Not installed"
}

# Function to show help
show_help() {
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  HELP & GUIDE  ★${NC}          ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ What is FRP? ───────────────────────╮${NC}"
    echo ""
    echo -e "${YELLOW}    FRP (Fast Reverse Proxy)${NC} is a tool that lets"
    echo -e "${YELLOW}    your VM connect to a 24/7 server (VPS).${NC}"
    echo -e "${YELLOW}    This way people can access your VM even${NC}"
    echo -e "${YELLOW}    if your VM doesn't have a public IP!${NC}"
    echo ""
    echo -e "${WHITE}    Think of it like a tunnel:${NC}"
    echo "       Your VM ←────tunnel────→ VPS (24/7)"
    echo "                                    ↓"
    echo "                            Users connect here"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ How to Use This Script ─────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    Step 1:${NC} Get info from VPS owner"
    echo "           → VPS IP address"
    echo "           → FRP Port (usually 7000)"
    echo "           → Token (secret password)"
    echo "           → VM Name (vm-001, vm-002, etc.)"
    echo ""
    echo -e "${GREEN}    Step 2:${NC} Run this script"
    echo "           → sudo ./vm-client-menu-setup.sh"
    echo ""
    echo -e "${GREEN}    Step 3:${NC} Select option [7] Quick Start"
    echo "           → Installs everything at once!"
    echo "           → Enter the info from Step 1"
    echo ""
    echo -e "${GREEN}    Step 4:${NC} Tell people to connect!"
    echo "           → RDP to: vps-ip:port"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ What Each Option Does ──────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    [1] Setup Desktop & RDP${NC}"
    echo "        → Installs Ubuntu Desktop"
    echo "        → Installs RDP server"
    echo "        → Lets you connect remotely"
    echo ""
    echo -e "${GREEN}    [2] Setup FRP Client${NC}"
    echo "        → Connects your VM to the VPS"
    echo "        → Creates the tunnel"
    echo ""
    echo -e "${GREEN}    [3] Setup Auto-Refresh${NC}"
    echo "        → Refreshes a page every 5 minutes"
    echo "        → Keeps your VM 'awake'"
    echo "        → Prevents session timeout"
    echo ""
    echo -e "${GREEN}    [4] Setup Tailscale${NC}"
    echo "        → Alternative VPN connection"
    echo "        → Backup if FRP stops working"
    echo ""
    echo -e "${GREEN}    [5] Disable Sleep/Suspend${NC}"
    echo "        → Stops Ubuntu from sleeping"
    echo "        → Keeps VM running 24/7"
    echo ""
    echo -e "${GREEN}    [6] Show Connection Status${NC}"
    echo "        → Check if everything is working"
    echo "        → Shows FRP, RDP, Auto-Refresh status"
    echo ""
    echo -e "${GREEN}    [7] Run ALL Setup (Quick Start)${NC}"
    echo "        → Does options 1, 2, 3, and 5"
    echo "        → Easiest way to set up everything!"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Auto-Refresh Feature ───────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    What it does:${NC}"
    echo "       → Opens Firefox with a keep-alive page"
    echo "       → Refreshes every 5 minutes"
    echo "       → Simulates key presses"
    echo ""
    echo -e "${GREEN}    Why you need it:${NC}"
    echo "       → Prevents RDP session from timing out"
    echo "       → Keeps browser tabs fresh"
    echo "       → Makes VM look 'active'"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Connecting to Your VM ──────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    From Windows:${NC}"
    echo "       1. Open Remote Desktop (mstsc)"
    echo "       2. Connect to: vps-ip:rdp-port"
    echo "          Example: 123.45.67.89:3389"
    echo "       3. Login with your VM username/password"
    echo ""
    echo -e "${GREEN}    From macOS:${NC}"
    echo "       1. Download Microsoft Remote Desktop"
    echo "       2. Add PC: vps-ip:rdp-port"
    echo "       3. Connect!"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Troubleshooting ────────────────────╮${NC}"
    echo ""
    echo -e "${RED}    Can't connect to VPS?${NC}"
    echo "       → Check VPS IP is correct"
    echo "       → Make sure port 7000 is open on VPS"
    echo "       → Check token matches"
    echo ""
    echo -e "${RED}    RDP says wrong password?${NC}"
    echo "       → Use your VM's username/password"
    echo "       → Not your VPS credentials!"
    echo ""
    echo -e "${RED}    VM keeps disconnecting?${NC}"
    echo "       → Make sure Auto-Refresh is on"
    echo "       → Check FRP is running: systemctl status frpc"
    echo "       → Restart FRP: systemctl restart frpc"
    echo ""
    echo -e "${RED}    Screen goes black?${NC}"
    echo "       → Auto-Refresh should prevent this"
    echo "       → Check nosleep is running"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${MAGENTA}    ★ Still stuck? Ask the VPS owner for help! ★${NC}"
    echo ""
}

# Main menu
while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}     ${WHITE}★  NJANFLAME VM MENU  ★${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  🖥️  Setup Desktop & RDP"
    echo -e "       ${GREEN}[2]${NC}  🔗 Setup FRP Client (connect to VPS)"
    echo -e "       ${GREEN}[3]${NC}  🔄 Setup Auto-Refresh (keeps VM active)"
    echo -e "       ${GREEN}[4]${NC}  🛡️  Setup Tailscale (backup VPN)"
    echo -e "       ${GREEN}[5]${NC}  💤 Disable Sleep/Suspend"
    echo -e "       ${GREEN}[6]${NC}  📊 Show Connection Status"
    echo -e "       ${GREEN}[7]${NC}  ⚡ Run ALL Setup (Quick Start)"
    echo -e "       ${GREEN}[8]${NC}  ❓ Help (Read this first!)"
    echo -e "       ${GREEN}[9]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter your choice [1-9]: ${NC}"

    # Read from /dev/tty if available (interactive terminal), otherwise use stdin
    if [ -t 0 ] || [ -e /dev/tty ]; then
        read -r choice </dev/tty 2>/dev/null || read -r choice
    else
        read -r choice
    fi

    # Trim whitespace
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
        1) setup_rdp ;;
        2) setup_frp ;;
        3) setup_autorefresh ;;
        4) setup_tailscale ;;
        5) setup_nosleep ;;
        6) show_status ;;
        7)
            echo ""
            echo -e "${YELLOW}    [*] Running full setup...${NC}"
            setup_rdp
            setup_frp
            setup_autorefresh
            setup_nosleep
            echo ""
            echo -e "${GREEN}    [✓] Full setup complete!${NC}"
            ;;
        8) show_help ;;
        9) echo ""; echo -e "${MAGENTA}    ★ Thanks for using NjanFlame! ★${NC}"; echo ""; exit 0 ;;
        *) echo -e "${RED}    [✗] Invalid choice!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}    Press Enter to continue...${NC}"
    if [ -t 0 ] || [ -e /dev/tty ]; then
        read </dev/tty 2>/dev/null || true
    fi
done
