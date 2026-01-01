#!/bin/bash

# ===============================================
#  NJANFLAME - PAID VPS 24/7 TUNNEL ACCEPTOR
#  Accept Multiple IDX VPS Tunnels
#  Automatic Setup & Management
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

# Paths
CONFIG_DIR="/etc/njanflame"
USERS_FILE="${CONFIG_DIR}/idx-users.conf"
SSH_CONFIG="/etc/ssh/sshd_config"

print_banner() {
    clear
    echo -e "${ORANGE}    ╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗ ${CYAN}██████╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██╔════╝${CYAN}██╔═══██╗${CYAN}██╔══██╗${CYAN}██╔══██╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██████╔╝${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║     ${CYAN}██║   ██║${CYAN}██╔══██╗${NC}${CYAN}██║  ██║${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}╚██████╗╚██████╔╝${CYAN}██║  ██║${NC}${CYAN}██████╔╝${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚═════╝ ╚═════╝ ╚═╝  ╚═╝${NC}${CYAN}╚═════╝${NC}       ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${MAGENTA}         ★  PAID VPS - 24/7 TUNNEL ACCEPTOR  ★${NC}"
    echo ""
}

# Initialize config directory
init_config() {
    mkdir -p "$CONFIG_DIR"
    touch "$USERS_FILE"
}

# Add a new IDX VPS user
add_idx_user() {
    echo ""
    echo -e "${YELLOW}[*] Adding new IDX VPS user...${NC}"
    echo ""

    echo -e "${YELLOW}Username (e.g., idxvps1):${NC}"
    read -r username </dev/tty 2>/dev/null || read -r username

    if [ -z "$username" ]; then
        echo -e "${RED}[✗] Username required!${NC}"
        return 1
    fi

    # Check if user exists
    if id "$username" &>/dev/null; then
        echo -e "${RED}[✗] User already exists!${NC}"
        return 1
    fi

    echo -e "${YELLOW}Password:${NC}"
    read -s password </dev/tty 2>/dev/null || read -s password
    echo ""

    # Generate available ports
    last_port=$(grep -o "PORT=[0-9]*" "$USERS_FILE" | cut -d'=' -f2 | sort -n | tail -1)
    base_port=$((last_port + 1))
    if [ "$base_port" -lt 3389 ]; then
        base_port=3389
    fi

    rdp_port=$base_port
    http_port=$((base_port + 1))
    https_port=$((base_port + 2))

    # Create user
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd

    # Add to config
    cat >> "$USERS_FILE" << EOF
USER=$username
PASS=$password
RDP_PORT=$rdp_port
HTTP_PORT=$http_port
HTTPS_PORT=$https_port
EOF

    echo ""
    echo -e "${GREEN}[✓] User '$username' created!${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  CONNECTION INFO FOR '$username'${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Paid VPS IP:${NC} $(hostname -I | awk '{print $1}')"
    echo -e "${WHITE}SSH User:${NC} $username"
    echo -e "${WHITE}SSH Port:${NC} 22"
    echo -e "${WHITE}Password:${NC} $password"
    echo ""
    echo -e "${WHITE}SSH Tunnel Command:${NC}"
    echo -e "${CYAN}ssh -R ${rdp_port}:localhost:3389 \\"
    echo -e "${CYAN}    -R ${http_port}:localhost:8000 \\"
    echo -e "${CYAN}    -R ${https_port}:localhost:8443 \\"
    echo -e "${CYAN}    -N -f -o ServerAliveInterval=60 \\"
    echo -e "${CYAN}    ${username}@$(hostname -I | awk '{print $1}')${NC}"
    echo ""
    echo -e "${WHITE}Access After Connection:${NC}"
    echo -e "${WHITE}RDP:    ${NC}$(hostname -I | awk '{print $1}'):$rdp_port"
    echo -e "${WHITE}HTTP:   ${NC}http://$(hostname -I | awk '{print $1}'):$http_port"
    echo -e "${WHITE}HTTPS:  ${NC}https://$(hostname -I | awk '{print $1}'):$https_port"
    echo ""
}

# List all IDX VPS users
list_users() {
    echo ""
    echo -e "${ORANGE}    ╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  CONNECTED IDX VPSs  ★${NC}        ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚═══════════════════════════════════════════════╝${NC}"
    echo ""

    if [ ! -s "$USERS_FILE" ]; then
        echo -e "${YELLOW}No IDX VPS users configured yet.${NC}"
        echo ""
        return
    fi

    echo -e "${CYAN}User      RDP Port  HTTP Port  HTTPS Port  Status${NC}"
    echo -e "${CYAN}────────────────────────────────────────────────${NC}"

    VPS_IP=$(hostname -I | awk '{print $1}')

    while IFS= read -r line; do
        if [[ "$line" =~ ^USER= ]]; then
            user=$(echo "$line" | cut -d'=' -f2)
        elif [[ "$line" =~ ^RDP_PORT= ]]; then
            rdp=$(echo "$line" | cut -d'=' -f2)
        elif [[ "$line" =~ ^HTTP_PORT= ]]; then
            http=$(echo "$line" | cut -d'=' -f2)
        elif [[ "$line" =~ ^HTTPS_PORT= ]]; then
            https=$(echo "$line" | cut -d'=' -f2)
            # Check if port is listening
            if ss -tuln 2>/dev/null | grep -q ":${rdp} "; then
                status="${GREEN}ONLINE${NC}"
            else
                status="${YELLOW}OFFLINE${NC}"
            fi

            printf "%-10s %-10s %-10s %-11s ${status}\n" \
                "$user" "$rdp" "$http" "$https"
        fi
    done < "$USERS_FILE"

    echo ""
}

# Remove IDX VPS user
remove_idx_user() {
    echo ""
    echo -e "${YELLOW}[*] Remove IDX VPS user...${NC}"
    echo ""

    # Show users
    if [ ! -s "$USERS_FILE" ]; then
        echo -e "${RED}No users configured yet.${NC}"
        return
    fi

    echo -e "${WHITE}Available users:${NC}"
    users=$(grep "^USER=" "$USERS_FILE" | cut -d'=' -f2 | nl -w2 -s'. ')
    echo "$users"

    echo ""
    echo -e "${YELLOW}Enter username to remove:${NC}"
    read -r username </dev/tty 2>/dev/null || read -r username

    if [ -z "$username" ]; then
        echo -e "${RED}[✗] Username required!${NC}"
        return 1
    fi

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}[✗] User doesn't exist!${NC}"
        return 1
    fi

    # Kill SSH processes
    pkill -u "$username" ssh 2>/dev/null || true

    # Delete user
    userdel -r "$username"

    # Remove from config
    sed -i "/^USER=$username$/,/^$/d" "$USERS_FILE"

    echo -e "${GREEN}[✓] User '$username' removed!${NC}"
}

# Setup SSH server for tunnels
setup_ssh_server() {
    echo ""
    echo -e "${YELLOW}[*] Setting up SSH Server for tunnels...${NC}"

    # Install SSH
    apt-get update -qq
    apt-get install -y openssh-server >/dev/null 2>&1

    # Enable tunneling
    if ! grep -q "AllowTcpForwarding yes" "$SSH_CONFIG"; then
        echo "AllowTcpForwarding yes" >> "$SSH_CONFIG"
        echo "GatewayPorts yes" >> "$SSH_CONFIG"
        echo "ClientAliveInterval 60" >> "$SSH_CONFIG"
        echo "ClientAliveCountMax 3" >> "$SSH_CONFIG"
        echo "PermitTunnel yes" >> "$SSH_CONFIG"
    fi

    # Restart SSH
    systemctl restart sshd 2>/dev/null || systemctl restart ssh

    # Configure firewall
    ufw allow 22/tcp 2>/dev/null || iptables -A INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || true

    echo -e "${GREEN}[✓] SSH Server configured!${NC}"
}

# Show connection status
show_status() {
    VPS_IP=$(hostname -I | awk '{print $1}')

    print_banner

    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${WHITE}Paid VPS Information:${NC}"
    echo -e "   IP: ${VPS_IP}"
    echo ""

    echo -e "${WHITE}SSH Server:${NC}"
    if systemctl is-active --quiet sshd 2>/dev/null || systemctl is-active --quiet ssh 2>/dev/null; then
        echo -e "   ${GREEN}✓ Running${NC}"
    else
        echo -e "   ${RED}✗ Not running${NC}"
    fi

    echo ""
    echo -e "${WHITE}Active SSH Tunnels (Forwarded):${NC}"

    # Count listening ports
    tunnel_count=$(ss -tuln 2>/dev/null | grep -c ":33[0-9][0-9] " || echo 0)

    if [ "$tunnel_count" -gt 0 ]; then
        echo -e "   ${GREEN}✓ $tunnel_count tunnel(s) active${NC}"
        echo ""
        echo -e "${CYAN}Port       Status${NC}"
        echo -e "${CYAN}────────────────${NC}"

        for port in 3389 3390 3391 3392 3393 3394 3395 3396 3397 3398 3399; do
            if ss -tuln 2>/dev/null | grep -q ":$port "; then
                echo -e "${GREEN}$port       LISTENING${NC}"
            fi
        done
    else
        echo -e "   ${YELLOW}○ No tunnels active${NC}"
    fi

    echo ""
    list_users
}

# Generate connection info for a user
generate_info() {
    echo ""
    echo -e "${YELLOW}[*] Generate Connection Info...${NC}"
    echo ""

    echo -e "${YELLOW}Username:${NC}"
    read -r username </dev/tty 2>/dev/null || read -r username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}[✗] User doesn't exist!${NC}"
        return 1
    fi

    # Get port info
    rdp=$(grep -A5 "^USER=$username$" "$USERS_FILE" | grep "RDP_PORT=" | cut -d'=' -f2)
    http=$(grep -A5 "^USER=$username$" "$USERS_FILE" | grep "HTTP_PORT=" | cut -d'=' -f2)
    https=$(grep -A5 "^USER=$username$" "$USERS_FILE" | grep "HTTPS_PORT=" | cut -d'=' -f2)
    pass=$(grep -A5 "^USER=$username$" "$USERS_FILE" | grep "PASS=" | cut -d'=' -f2)

    VPS_IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}║${NC}     ${WHITE}★  CONNECTION INFO FOR '$username'  ★${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Paid VPS Details:${NC}"
    echo -e "${WHITE}  IP:       ${VPS_IP}"
    echo -e "${WHITE}  SSH Port: 22"
    echo -e "${WHITE}  User:     $username"
    echo -e "${WHITE}  Password: $pass"
    echo ""
    echo -e "${YELLOW}Run this on IDX VPS:${NC}"
    echo -e "${CYAN}curl -sL https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main/idx-247-setup.sh | sudo bash${NC}"
    echo ""
    echo -e "${YELLOW}Or use command line:${NC}"
    echo -e "${CYAN}curl ... | sudo bash quick${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}After connection, access via:${NC}"
    echo -e "${WHITE}  RDP:    ${VPS_IP}:${rdp}"
    echo -e "${WHITE}  HTTP:   http://${VPS_IP}:${http}"
    echo -e "${WHITE}  HTTPS:  https://${VPS_IP}:${https}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Quick start setup
quick_start() {
    print_banner

    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}         ★ PAID VPS 24/7 ACCEPTOR SETUP ★${NC}"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${YELLOW}[1/3] Initializing configuration...${NC}"
    init_config

    echo -e "${YELLOW}[2/3] Setting up SSH Server...${NC}"
    setup_ssh_server

    echo -e "${YELLOW}[3/3] Creating first IDX VPS user...${NC}"
    add_idx_user

    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] PAID VPS SETUP COMPLETE!${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo ""

    show_status
}

# Interactive menu
show_menu() {
    print_banner

    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  ⚡ Quick Start (First Time Setup)"
    echo -e "       ${GREEN}[2]${NC}  ➕ Add IDX VPS User"
    echo -e "       ${GREEN}[3]${NC}  📊 List Connected IDX VPSs"
    echo -e "       ${GREEN}[4]${NC}  ➖ Remove IDX VPS User"
    echo -e "       ${GREEN}[5]${NC}  🔗 Generate Connection Info"
    echo -e "       ${GREEN}[6]${NC}  ⚙️  Setup SSH Server"
    echo -e "       ${GREEN}[7]${NC}  📈 Show Status"
    echo -e "       ${GREEN}[8]${NC}  ❓ Help"
    echo -e "       ${GREEN}[0]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Enter your choice [0-8]: ${NC}"

    read -r choice </dev/tty 2>/dev/null || read -r choice
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
        1)
            quick_start
            ;;
        2)
            init_config
            add_idx_user
            ;;
        3)
            init_config
            list_users
            ;;
        4)
            init_config
            remove_idx_user
            ;;
        5)
            init_config
            generate_info
            ;;
        6)
            setup_ssh_server
            ;;
        7)
            init_config
            show_status
            ;;
        8)
            echo ""
            echo -e "${WHITE}HELP:${NC}"
            echo ""
            echo -e "${GREEN}What this does:${NC}"
            echo "  • Accept SSH reverse tunnels from IDX VPSs"
            echo "  • Makes IDX VPS accessible via your paid VPS"
            echo "  • Manage multiple IDX VPS connections"
            echo ""
            echo -e "${GREEN}Workflow:${NC}"
            echo "  1. Run this on your Paid VPS"
            echo "  2. Select [1] to do quick start"
            echo "  3. Create a user for each IDX VPS"
            echo "  4. Give connection info to IDX VPS owner"
            echo "  5. They run idx-247-setup.sh on their IDX VPS"
            echo "  6. Access their IDX VPS via: paid-vps-ip:port"
            echo ""
            echo -e "${GREEN}24/7 Features:${NC}"
            echo "  • Auto-reconnect on IDX VPS side"
            echo "  • Health monitoring"
            echo "  • Boot persistence"
            echo ""
            ;;
        0)
            echo ""
            echo -e "${MAGENTA}    ★ Thanks for using NjanFlame Paid VPS! ★${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}[✗] Invalid choice!${NC}"
            ;;
    esac

    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read </dev/tty 2>/dev/null || true
}

# Check if root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[✗] This script must be run as root or with sudo${NC}"
        exit 1
    fi
}

# Show help
show_help() {
    echo ""
    echo -e "${WHITE}Usage: $0 [command]${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo ""
    echo -e "  ${CYAN}quick${NC}      - Quick start (first time setup)"
    echo -e "  ${CYAN}add${NC}         - Add new IDX VPS user"
    echo -e "  ${CYAN}list${NC}        - List all IDX VPS users"
    echo -e "  ${CYAN}remove${NC}      - Remove IDX VPS user"
    echo -e "  ${CYAN}info${NC}        - Generate connection info"
    echo -e "  ${CYAN}setup-ssh${NC}   - Setup SSH server"
    echo -e "  ${CYAN}status${NC}      - Show status"
    echo -e "  ${CYAN}help${NC}        - Show this help"
    echo ""
}

# Main
check_root

# Check if script is being piped (no arguments provided)
if [ $# -eq 0 ] && [ ! -t 0 ]; then
    # No terminal and no args - auto-run quick start when piped
    quick_start
    exit 0
fi

case "${1:-}" in
    quick|install)
        quick_start
        ;;
    add)
        init_config
        add_idx_user
        ;;
    list)
        init_config
        list_users
        ;;
    remove)
        init_config
        remove_idx_user
        ;;
    info)
        init_config
        generate_info
        ;;
    setup-ssh)
        setup_ssh_server
        ;;
    status)
        init_config
        show_status
        ;;
    help|--help)
        show_help
        ;;
    "")
        # Interactive menu
        while true; do
            show_menu
        done
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
