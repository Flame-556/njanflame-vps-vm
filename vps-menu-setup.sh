#!/bin/bash

# ===============================================
# VPS (24/7 Server) - Menu Setup for Multiple VMs
# Run this on your 24/7 VPS
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
#       ██████╗ ██████╗ ██████╗ ██████╗
#      ██╔════╝██╔═══██╗██╔══██╗██╔══██╗
#      ██║     ██║   ██║██████╔╝██║  ██║
#      ██║     ██║   ██║██╔══██╗██║  ██║
#      ╚██████╗╚██████╔╝██║  ██║██████╔╝
#       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝
#    ╔════════════════════════════════════╗
#    ║   ULTIMATE NJANFLAME VPS MANAGER   ║
#    ║        24/7 RELAY SYSTEM           ║
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

# Animated line
echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
sleep 0.2
echo ""
echo -e "${MAGENTA}        ★  ★  ★  ULTIMATE EDITION  ★  ★  ★${NC}"
echo ""
sleep 0.3
echo -e "${GREEN}            [ LOADING SYSTEM... ]${NC}"
sleep 0.5

# Loading animation
for i in {1..10}; do
    echo -ne "${GREEN}            █${NC}"
    sleep 0.05
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

# Function to install FRP Server
install_frp_server() {
    echo -e "${YELLOW}[*] Installing FRP Server...${NC}"

    FRP_VERSION="0.52.3"
    FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"

    cd /tmp
    wget -q "${FRP_URL}" -O frp.tar.gz
    tar -xzf frp.tar.gz
    rm frp.tar.gz

    mkdir -p /opt/frp
    cp frp_${FRP_VERSION}_linux_amd64/frps /opt/frp/
    cp frp_${FRP_VERSION}_linux_amd64/frps.ini /opt/frp/
    chmod +x /opt/frp/frps

    # Ask for password and token
    echo ""
    echo -e "${YELLOW}Enter dashboard password:${NC}"
    read -s DASH_PWD
    echo ""
    echo -e "${YELLOW}Enter secret token:${NC}"
    read -s TOKEN

    # Create FRP config
    cat > /opt/frp/frps.ini << EOF
[common]
bind_port = 7000
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = ${DASH_PWD}
vhost_http_port = 80
vhost_https_port = 443
log_file = /var/log/frps.log
log_level = info
log_max_days = 3
token = ${TOKEN}
max_pool_count = 50
max_ports_per_client = 0
subdomain_host = your-domain.com
EOF

    # Create systemd service
    cat > /etc/systemd/system/frps.service << EOF
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

    # Open firewall ports
    ufw allow 22/tcp 2>/dev/null || true
    ufw allow 80/tcp 2>/dev/null || true
    ufw allow 443/tcp 2>/dev/null || true
    ufw allow 3389/tcp 2>/dev/null || true
    ufw allow 7000:7100/tcp 2>/dev/null || true
    ufw allow 7500/tcp 2>/dev/null || true

    systemctl daemon-reload
    systemctl enable frps
    systemctl start frps

    echo -e "${GREEN}[✓] FRP Server installed and started!${NC}"
    echo ""
    echo -e "${YELLOW}DASHBOARD:${NC} http://$(hostname -I | awk '{print $1}'):7500"
    echo -e "${YELLOW}User:${NC} admin"
    echo -e "${YELLOW}Pass:${NC} ${DASH_PWD}"
    echo ""
}

# Function to add a VM
add_vm() {
    echo ""
    echo -e "${YELLOW}[*] Adding new VM...${NC}"
    echo ""
    echo "Available slots:"

    # Check which ports are already used
    PORTS=(3389 3390 3391 3392 3393 3394)
    NAMES=("vm-001" "vm-002" "vm-003" "vm-004" "vm-005" "vm-006")

    for i in "${!PORTS[@]}"; do
        PORT=${PORTS[$i]}
        NAME=${NAMES[$i]}
        if grep -q "\[${NAME}-rdp\]" /opt/frp/frps.ini 2>/dev/null; then
            echo -e "   ${RED}$((i+1)). ${NAME} : Port ${PORT} - ${RED}ALREADY ADDED${NC}"
        else
            echo -e "   ${GREEN}$((i+1)). ${NAME} : Port ${PORT} - ${GREEN}AVAILABLE${NC}"
        fi
    done

    echo ""
    echo -e "${YELLOW}Enter VM number [1-6]:${NC}"
    read SELECTION

    case $SELECTION in
        1) VM_NAME="vm-001"; RDP_PORT=3389 ;;
        2) VM_NAME="vm-002"; RDP_PORT=3390 ;;
        3) VM_NAME="vm-003"; RDP_PORT=3391 ;;
        4) VM_NAME="vm-004"; RDP_PORT=3392 ;;
        5) VM_NAME="vm-005"; RDP_PORT=3393 ;;
        6) VM_NAME="vm-006"; RDP_PORT=3394 ;;
        *) echo -e "${RED}Invalid selection!${NC}"; return ;;
    esac

    # Check if already exists
    if grep -q "\[${VM_NAME}-rdp\]" /opt/frp/frps.ini 2>/dev/null; then
        echo -e "${RED}VM ${VM_NAME} already exists!${NC}"
        return
    fi

    # Get token from existing config
    TOKEN=$(grep "^token = " /opt/frp/frps.ini 2>/dev/null | cut -d' ' -f3)

    # Add VM to frps.ini
    cat >> /opt/frp/frps.ini << EOF

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

    # Open firewall
    ufw allow ${RDP_PORT}/tcp 2>/dev/null || true
    ufw allow $((RDP_PORT + 100))/tcp 2>/dev/null || true

    systemctl restart frps

    echo -e "${GREEN}[✓] VM ${VM_NAME} added successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Tell the VM owner:${NC}"
    echo "   VPS IP: $(hostname -I | awk '{print $1}')"
    echo "   FRP Port: 7000"
    echo "   Token: ${TOKEN}"
    echo "   VM Name: ${VM_NAME}"
    echo "   RDP Port: ${RDP_PORT}"
    echo ""
}

# Function to list VMs
list_vms() {
    echo ""
    echo -e "${YELLOW}[*] Connected VMs:${NC}"
    echo ""

    # Try to get status from FRP dashboard API
    TOKEN=$(grep "^token = " /opt/frp/frps.ini 2>/dev/null | cut -d' ' -f3)
    DASH_PWD=$(grep "^dashboard_pwd = " /opt/frp/frps.ini 2>/dev/null | cut -d' ' -f3)

    echo -e "   ${YELLOW}VM Name${NC}     | ${YELLOW}RDP Port${NC} | ${YELLOW}SSH Port${NC} | ${YELLOW}Status${NC}"
    echo "   -------------------------------------------"

    for i in "${!NAMES[@]}"; do
        NAME=${NAMES[$i]}
        RDP_PORT=${PORTS[$i]}
        SSH_PORT=$((RDP_PORT + 100))

        if grep -q "\[${NAME}-rdp\]" /opt/frp/frps.ini 2>/dev/null; then
            # Try to get proxy status
            STATUS=$(curl -s "http://127.0.0.1:7500/api/proxy/tcp" 2>/dev/null | grep -o "\"status\":\"[^\"]*\"" | head -1 | cut -d'"' -f4 || echo "unknown")
            if [ "$STATUS" = "online" ]; then
                echo -e "   ${GREEN}${NAME}${NC}     | ${GREEN}${RDP_PORT}${NC}      | ${GREEN}${SSH_PORT}${NC}     | ${GREEN}ONLINE${NC}"
            else
                echo -e "   ${NAME}     | ${RDP_PORT}      | ${SSH_PORT}     | ${YELLOW}OFFLINE${NC}"
            fi
        fi
    done
    echo ""
}

# Function to remove a VM
remove_vm() {
    echo ""
    echo -e "${YELLOW}[*] Remove a VM:${NC}"
    echo ""
    echo "   1. vm-001"
    echo "   2. vm-002"
    echo "   3. vm-003"
    echo "   4. vm-004"
    echo "   5. vm-005"
    echo "   6. vm-006"
    echo ""
    echo -e "${YELLOW}Enter VM number to remove [1-6]:${NC}"
    read SELECTION

    case $SELECTION in
        1) VM_NAME="vm-001"; RDP_PORT=3389 ;;
        2) VM_NAME="vm-002"; RDP_PORT=3390 ;;
        3) VM_NAME="vm-003"; RDP_PORT=3391 ;;
        4) VM_NAME="vm-004"; RDP_PORT=3392 ;;
        5) VM_NAME="vm-005"; RDP_PORT=3393 ;;
        6) VM_NAME="vm-006"; RDP_PORT=3394 ;;
        *) echo -e "${RED}Invalid selection!${NC}"; return ;;
    esac

    # Remove from config (remove both rdp and ssh sections)
    sed -i "/\[${VM_NAME}-rdp\]/,/^$/d" /opt/frp/frps.ini
    sed -i "/\[${VM_NAME}-ssh\]/,/^$/d" /opt/frp/frps.ini

    systemctl restart frps

    echo -e "${GREEN}[✓] VM ${VM_NAME} removed!${NC}"
}

# Function to show connection info
show_info() {
    VPS_IP=$(hostname -I | awk '{print $1}')
    TOKEN=$(grep "^token = " /opt/frp/frps.ini 2>/dev/null | cut -d' ' -f3)

    echo ""
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}   CONNECTION INFO FOR VM OWNERS     ${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo ""
    echo -e "${YELLOW}VPS IP:${NC} ${VPS_IP}"
    echo -e "${YELLOW}FRP Port:${NC} 7000"
    echo -e "${YELLOW}Token:${NC} ${TOKEN}"
    echo ""
    echo -e "${YELLOW}RDP Ports (for users to connect):${NC}"
    echo "   vm-001 → Port 3389"
    echo "   vm-002 → Port 3390"
    echo "   vm-003 → Port 3391"
    echo "   vm-004 → Port 3392"
    echo "   vm-005 → Port 3393"
    echo "   vm-006 → Port 3394"
    echo ""
    echo -e "${YELLOW}Dashboard:${NC} http://${VPS_IP}:7500"
    echo ""
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
    echo -e "${YELLOW}    FRP (Fast Reverse Proxy)${NC} allows your VMs"
    echo -e "${YELLOW}    to be accessed through this VPS even if${NC}"
    echo -e "${YELLOW}    they don't have a public IP address.${NC}"
    echo ""
    echo -e "${WHITE}    Think of it like a bridge:${NC}"
    echo "       You (anywhere) → VPS (24/7) → Your VM"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ How This Works ─────────────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    Step 1:${NC} Install FRP Server (Run this first!)"
    echo "           → Creates the 'bridge' on your VPS"
    echo ""
    echo -e "${GREEN}    Step 2:${NC} Give VM info to your friends"
    echo "           → VPS IP, Port 7000, Token, VM Name"
    echo ""
    echo -e "${GREEN}    Step 3:${NC} They run vm-client-setup.sh on their VM"
    echo "           → Their VM connects to your VPS"
    echo ""
    echo -e "${GREEN}    Step 4:${NC} Anyone can RDP to: vps-ip:port"
    echo "           → Connected directly to the VM!"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ What Each Option Does ──────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    [1] Install FRP Server${NC}"
    echo "        → Installs FRP on this VPS"
    echo "        → Opens firewall ports"
    echo "        → Creates dashboard at port 7500"
    echo ""
    echo -e "${GREEN}    [2] Add a VM${NC}"
    echo "        → Reserves a port (3389, 3390, etc.)"
    echo "        → Generates config for that VM"
    echo "        → Shows info to give to VM owner"
    echo ""
    echo -e "${GREEN}    [3] List connected VMs${NC}"
    echo "        → Shows which VMs are online"
    echo "        → Shows their ports and status"
    echo ""
    echo -e "${GREEN}    [4] Remove a VM${NC}"
    echo "        → Removes a VM from the list"
    echo "        → Frees up the port for new VM"
    echo ""
    echo -e "${GREEN}    [5] Show connection info${NC}"
    echo "        → Shows VPS IP, Token, Port"
    echo "        → Copy this info to VM owners"
    echo ""
    echo -e "${GREEN}    [6] Restart FRP Server${NC}"
    echo "        → Fixes connection issues"
    echo "        → Reloads configuration"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Quick Start Guide ──────────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    For VPS Owner:${NC}"
    echo "       1. Run this script"
    echo "       2. Select [1] to install FRP Server"
    echo "       3. Select [2] to add VMs (vm-001, vm-002, etc.)"
    echo "       4. Select [5] and give the info to VM owners"
    echo ""
    echo -e "${GREEN}    For VM Owner:${NC}"
    echo "       1. Download vm-client-menu-setup.sh"
    echo "       2. Run: sudo ./vm-client-menu-setup.sh"
    echo "       3. Select [7] for Quick Start"
    echo "       4. Enter the info from VPS owner"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Connecting via RDP ─────────────────╮${NC}"
    echo ""
    echo -e "${GREEN}    From Windows:${NC}"
    echo "       Open Remote Desktop (mstsc)"
    echo "       Connect to: your-vps-ip:3389"
    echo ""
    echo -e "${GREEN}    From macOS:${NC}"
    echo "       Microsoft Remote Desktop app"
    echo "       PC Name: your-vps-ip:3389"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}    ╭─ Troubleshooting ────────────────────╮${NC}"
    echo ""
    echo -e "${RED}    VM not connecting?${NC}"
    echo "       → Check VPS firewall allows port 7000"
    echo "       → Make sure token matches"
    echo "       → Run [6] to restart FRP"
    echo ""
    echo -e "${RED}    Can't access dashboard?${NC}"
    echo "       → Check VPS IP: curl ifconfig.me"
    echo "       → Make sure port 7500 is open"
    echo ""
    echo -e "${RED}    RDP not working?${NC}"
    echo "       → Check VM has xrdp installed"
    echo "       → Run: systemctl status xrdp"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${MAGENTA}    ★ Still stuck? Ask for help! ★${NC}"
    echo ""
}

# Main menu
while true; do
    echo ""
    echo -e "${ORANGE}    ╔════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}     ${WHITE}★  NJANFLAME VPS MENU  ★${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  ⚡ Install FRP Server"
    echo -e "       ${GREEN}[2]${NC}  ➕ Add a VM (1-6)"
    echo -e "       ${GREEN}[3]${NC}  📊 List connected VMs"
    echo -e "       ${GREEN}[4]${NC}  ➖ Remove a VM"
    echo -e "       ${GREEN}[5]${NC}  🔗 Show connection info"
    echo -e "       ${GREEN}[6]${NC}  🔄 Restart FRP Server"
    echo -e "       ${GREEN}[7]${NC}  ❓ Help (Read this first!)"
    echo -e "       ${GREEN}[8]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}    Enter your choice [1-8]: ${NC}"

    # Read from /dev/tty if available (interactive terminal), otherwise use stdin
    if [ -t 0 ] || [ -e /dev/tty ]; then
        read -r choice </dev/tty 2>/dev/null || read -r choice
    else
        read -r choice
    fi

    # Trim whitespace
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
        1) install_frp_server ;;
        2) add_vm ;;
        3) list_vms ;;
        4) remove_vm ;;
        5) show_info ;;
        6) systemctl restart frps; echo -e "${GREEN}    [✓] FRP Server restarted!${NC}" ;;
        7) show_help ;;
        8) echo ""; echo -e "${MAGENTA}    ★ Thanks for using NjanFlame! ★${NC}"; echo ""; exit 0 ;;
        *) echo -e "${RED}    [✗] Invalid choice!${NC}" ;;
    esac

    echo ""
    echo -e "${YELLOW}    Press Enter to continue...${NC}"
    if [ -t 0 ] || [ -e /dev/tty ]; then
        read </dev/tty 2>/dev/null || true
    fi
done
