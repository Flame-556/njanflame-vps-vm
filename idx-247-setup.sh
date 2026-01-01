#!/bin/bash

# ===============================================
#  NJANFLAME - ULTIMATE 24/7 IDX VPS MANAGER
#  True 24/7 Connection with Auto-Reconnect
#  Boot Persistence & Health Monitoring
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
CONFIG_FILE="/etc/njanflame/idx-vps.conf"
SSH_SERVICE="/etc/systemd/system/idx-tunnel.service"
MONITOR_SERVICE="/etc/systemd/system/idx-monitor.service"
HEALTH_SCRIPT="/usr/local/bin/idx-health-check.sh"

print_banner() {
    clear
    echo -e "${ORANGE}    ╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██╗   ██╗${CYAN} ██████╗ ${CYAN}██╗██████╗ ${CYAN}██╗   ██╗${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██╔═══██╗${NC}${CYAN}██║██╔══██╗${CYAN}██║   ██║${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}██║   ██║${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${CYAN}██║   ██║${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN} ╚██╗ ██╔╝${CYAN}██║   ██║${NC}${CYAN}██║██║  ██║${CYAN}╚██╗ ██╔╝${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}  ╚████╔╝ ${CYAN}╚██████╔╝${NC}${CYAN}██║██████╔╝${NC}${CYAN} ╚████╔╝${NC}     ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ║${NC}   ${CYAN}   ╚═══╝   ${CYAN}╚═════╝ ${NC}${CYAN}╚═╝╚═════╝${NC} ${CYAN} ╚═══╝${NC}      ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${MAGENTA}              ★  ULTIMATE 24/7 EDITION  ★${NC}"
    echo ""
}

# Setup configuration
setup_config() {
    echo ""
    echo -e "${YELLOW}[*] Setting up 24/7 IDX VPS Configuration...${NC}"
    echo ""

    # Create config directory
    mkdir -p /etc/njanflame

    # Get VPS details
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}Existing config found. Press Enter to use it or type new values.${NC}"
        . "$CONFIG_FILE"
    fi

    echo -e "${YELLOW}Paid VPS IP or Domain [${PAID_VPS_IP:-}]:${NC}"
    read -r NEW_PAID_IP </dev/tty 2>/dev/null || read -r NEW_PAID_IP
    PAID_VPS_IP="${NEW_PAID_IP:-$PAID_VPS_IP}"

    echo -e "${YELLOW}SSH User [${SSH_USER:-idxvps}]:${NC}"
    read -r NEW_SSH_USER </dev/tty 2>/dev/null || read -r NEW_SSH_USER
    SSH_USER="${NEW_SSH_USER:-$SSH_USER}"

    echo -e "${YELLOW}SSH Port [${SSH_PORT:-22}]:${NC}"
    read -r NEW_SSH_PORT </dev/tty 2>/dev/null || read -r NEW_SSH_PORT
    SSH_PORT="${NEW_SSH_PORT:-$SSH_PORT}"

    echo -e "${YELLOW}SSH Password [hidden]:${NC}"
    read -s SSH_PASS </dev/tty 2>/dev/null || read -s SSH_PASS
    echo ""

    echo -e "${YELLOW}Enable Tailscale backup? [y/N]${NC}"
    read -r ENABLE_TAILSCALE </dev/tty 2>/dev/null || read -r ENABLE_TAILSCALE

    echo -e "${YELLOW}Local RDP Port [${RDP_PORT:-3389}]:${NC}"
    read -r NEW_RDP_PORT </dev/tty 2>/dev/null || read -r NEW_RDP_PORT
    RDP_PORT="${NEW_RDP_PORT:-$RDP_PORT}"

    echo -e "${YELLOW}Local HTTP Port [${HTTP_PORT:-8000}]:${NC}"
    read -r NEW_HTTP_PORT </dev/tty 2>/dev/null || read -r NEW_HTTP_PORT
    HTTP_PORT="${NEW_HTTP_PORT:-$HTTP_PORT}"

    echo -e "${YELLOW}Local HTTPS Port [${HTTPS_PORT:-8443}]:${NC}"
    read -r NEW_HTTPS_PORT </dev/tty 2>/dev/null || read -r NEW_HTTPS_PORT
    HTTPS_PORT="${NEW_HTTPS_PORT:-$HTTPS_PORT}"

    # Validate
    if [ -z "$PAID_VPS_IP" ]; then
        echo -e "${RED}[✗] VPS IP is required!${NC}"
        return 1
    fi

    # Save config
    cat > "$CONFIG_FILE" << EOF
# NjanFlame IDX VPS 24/7 Configuration
PAID_VPS_IP="$PAID_VPS_IP"
SSH_USER="${SSH_USER:-idxvps}"
SSH_PORT="${SSH_PORT:-22}"
SSH_PASS="$SSH_PASS"
RDP_PORT="${RDP_PORT:-3389}"
HTTP_PORT="${HTTP_PORT:-8000}"
HTTPS_PORT="${HTTPS_PORT:-8443}"
ENABLE_TAILSCALE="${ENABLE_TAILSCALE:-n}"
EOF

    chmod 600 "$CONFIG_FILE"

    echo -e "${GREEN}[✓] Configuration saved to $CONFIG_FILE${NC}"
}

# Setup SSH keys for passwordless authentication
setup_ssh_keys() {
    echo ""
    echo -e "${YELLOW}[*] Setting up SSH keys for passwordless authentication...${NC}"

    . "$CONFIG_FILE"

    # Create SSH directory
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    # Generate key if doesn't exist
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -q
    fi

    # Copy key to remote server
    echo ""
    echo -e "${YELLOW}Copying SSH key to $PAID_VPS_IP...${NC}"
    echo -e "${YELLOW}You'll need to enter the password one time.${NC}"
    echo ""

    sshpass -p "$SSH_PASS" ssh-copy-id -o StrictHostKeyChecking=no \
        -p "${SSH_PORT:-22}" \
        -i ~/.ssh/id_ed25519.pub \
        "${SSH_USER:-idxvps}@${PAID_VPS_IP}" || {
        echo -e "${RED}[✗] Failed to copy SSH key. Installing sshpass...${NC}"
        apt-get install -y sshpass >/dev/null 2>&1 || apt-get update && apt-get install -y sshpass
        sshpass -p "$SSH_PASS" ssh-copy-id -o StrictHostKeyChecking=no \
            -p "${SSH_PORT:-22}" \
            -i ~/.ssh/id_ed25519.pub \
            "${SSH_USER:-idxvps}@${PAID_VPS_IP}"
    }

    echo -e "${GREEN}[✓] SSH keys configured!${NC}"
}

# Create SSH tunnel systemd service
create_tunnel_service() {
    echo ""
    echo -e "${YELLOW}[*] Creating SSH Tunnel systemd service...${NC}"

    . "$CONFIG_FILE"

    cat > "$SSH_SERVICE" << EOF
[Unit]
Description=IDX VPS SSH Tunnel to Paid VPS
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/ssh -i /root/.ssh/id_ed25519 \\
    -N \\
    -o ServerAliveInterval=30 \\
    -o ServerAliveCountMax=3 \\
    -o ExitOnForwardFailure=yes \\
    -o StrictHostKeyChecking=no \\
    -p ${SSH_PORT:-22} \\
    -R ${RDP_PORT:-3389}:localhost:${RDP_PORT:-3389} \\
    -R ${HTTP_PORT:-8000}:localhost:${HTTP_PORT:-8000} \\
    -R ${HTTPS_PORT:-8443}:localhost:${HTTPS_PORT:-8443} \\
    ${SSH_USER:-idxvps}@${PAID_VPS_IP}

Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=idx-tunnel

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable idx-tunnel

    echo -e "${GREEN}[✓] SSH Tunnel service created and enabled!${NC}"
}

# Create health check script
create_health_check() {
    echo ""
    echo -e "${YELLOW}[*] Creating health check script...${NC}"

    . "$CONFIG_FILE"

    cat > "$HEALTH_SCRIPT" << 'HEALTH_EOF'
#!/bin/bash

# NjanFlame IDX VPS Health Check
# Runs every 30 seconds to ensure tunnel is alive

CONFIG_FILE="/etc/njanflame/idx-vps.conf"
LOG_FILE="/var/log/idx-health-check.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Load config
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    log "ERROR: Config file not found!"
    exit 1
fi

# Check if tunnel is running
if ! systemctl is-active --quiet idx-tunnel; then
    log "Tunnel is NOT running. Starting..."
    systemctl start idx-tunnel
    sleep 5
fi

# Check if SSH process is alive
if ! pgrep -f "ssh.*-R.*${PAID_VPS_IP}" > /dev/null; then
    log "SSH process died. Restarting service..."
    systemctl restart idx-tunnel
fi

# Test connectivity to local ports
if ! nc -z localhost "${RDP_PORT:-3389}" 2>/dev/null; then
    log "WARNING: Local RDP port ${RDP_PORT:-3389} not accessible!"
fi

if ! nc -z localhost "${HTTP_PORT:-8000}" 2>/dev/null; then
    log "WARNING: Local HTTP port ${HTTP_PORT:-8000} not accessible!"
fi

if ! nc -z localhost "${HTTPS_PORT:-8443}" 2>/dev/null; then
    log "WARNING: Local HTTPS port ${HTTPS_PORT:-8443} not accessible!"
fi

log "Health check completed - System healthy"
HEALTH_EOF

    chmod +x "$HEALTH_SCRIPT"

    echo -e "${GREEN}[✓] Health check script created!${NC}"
}

# Create monitor service
create_monitor_service() {
    echo ""
    echo -e "${YELLOW}[*] Creating monitor systemd service...${NC}"

    cat > "$MONITOR_SERVICE" << EOF
[Unit]
Description=IDX VPS Health Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=$HEALTH_SCRIPT
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal
SyslogIdentifier=idx-monitor

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable idx-monitor

    echo -e "${GREEN}[✓] Monitor service created and enabled!${NC}"
}

# Install Tailscale
install_tailscale() {
    echo ""
    echo -e "${YELLOW}[*] Installing Tailscale (backup VPN)...${NC}"

    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list

    apt-get update -qq
    apt-get install -y tailscale >/dev/null 2>&1

    systemctl enable tailscaled
    systemctl start tailscaled

    echo -e "${GREEN}[✓] Tailscale installed!${NC}"
    echo ""
    echo -e "${YELLOW}Run: sudo tailscale up${NC}"
}

# Start all services
start_services() {
    echo ""
    echo -e "${YELLOW}[*] Starting all 24/7 services...${NC}"

    systemctl restart idx-tunnel
    systemctl restart idx-monitor

    sleep 3

    systemctl status idx-tunnel --no-pager | head -10
    echo ""
    systemctl status idx-monitor --no-pager | head -10
}

# Show status
show_status() {
    echo ""
    echo -e "${ORANGE}    ╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}    ║${NC}        ${WHITE}★  24/7 STATUS  ★${NC}           ${ORANGE}║${NC}"
    echo -e "${ORANGE}    ╚═══════════════════════════════════════════════╝${NC}"
    echo ""

    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
        echo -e "${YELLOW}Target VPS:${NC} ${PAID_VPS_IP}"
        echo -e "${YELLOW}SSH User:${NC} ${SSH_USER:-idxvps}"
    fi

    echo ""
    echo -e "${YELLOW}SSH Tunnel Service:${NC}"
    systemctl status idx-tunnel --no-pager | head -10

    echo ""
    echo -e "${YELLOW}Monitor Service:${NC}"
    systemctl status idx-monitor --no-pager | head -10

    echo ""
    echo -e "${YELLOW}SSH Process:${NC}"
    if pgrep -f "ssh.*-R" > /dev/null; then
        echo -e "${GREEN}✓ Running${NC}"
        pgrep -a -f "ssh.*-R" | head -5
    else
        echo -e "${RED}✗ Not running${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Local Ports:${NC}"
    for port in "${RDP_PORT:-3389}" "${HTTP_PORT:-8000}" "${HTTPS_PORT:-8443}"; do
        if nc -z localhost "$port" 2>/dev/null; then
            echo -e "   ${GREEN}✓ Port $port${NC} - Open"
        else
            echo -e "   ${RED}✗ Port $port${NC} - Closed"
        fi
    done

    echo ""
    echo -e "${YELLOW}Recent Logs:${NC}"
    if [ -f "/var/log/idx-health-check.log" ]; then
        tail -5 /var/log/idx-health-check.log
    else
        echo "   No logs yet"
    fi

    echo ""
}

# Stop all services
stop_services() {
    echo ""
    echo -e "${YELLOW}[*] Stopping all 24/7 services...${NC}"

    systemctl stop idx-tunnel
    systemctl stop idx-monitor

    echo -e "${GREEN}[✓] Services stopped!${NC}"
}

# Quick start (full setup)
quick_start() {
    print_banner
    echo -e "${CYAN}    ══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}         ★ 24/7 ULTIMATE SETUP ★${NC}"
    echo ""
    echo -e "${CYAN}    ══════════════════════════════════════════════${NC}"
    echo ""

    # Install dependencies
    echo -e "${YELLOW}[1/7] Installing dependencies...${NC}"
    apt-get update -qq
    apt-get install -y openssh-client openssh-server net-tools netcat sshpass >/dev/null 2>&1

    # Setup config
    echo -e "${YELLOW}[2/7] Setting up configuration...${NC}"
    setup_config

    # Setup SSH keys
    echo -e "${YELLOW}[3/7] Setting up SSH keys...${NC}"
    setup_ssh_keys

    # Create tunnel service
    echo -e "${YELLOW}[4/7] Creating SSH tunnel service...${NC}"
    create_tunnel_service

    # Create health check
    echo -e "${YELLOW}[5/7] Creating health check...${NC}"
    create_health_check

    # Create monitor service
    echo -e "${YELLOW}[6/7] Creating monitor service...${NC}"
    create_monitor_service

    # Install Tailscale if requested
    . "$CONFIG_FILE"
    if [[ "$ENABLE_TAILSCALE" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[7/7] Installing Tailscale...${NC}"
        install_tailscale
    else
        echo -e "${YELLOW}[7/7] Skipping Tailscale (disabled)${NC}"
    fi

    # Start services
    echo ""
    echo -e "${YELLOW}[STARTING SERVICES]${NC}"
    start_services

    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] 24/7 SETUP COMPLETE!${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo ""

    show_status

    echo ""
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${ORANGE}║${NC}          ${WHITE}★ ACCESS INFO ★${NC}            ${ORANGE}║${NC}"
    echo -e "${ORANGE}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Your IDX VPS is now accessible via:${NC}"
    echo ""
    echo -e "${WHITE}RDP:    ${PAID_VPS_IP}:${RDP_PORT:-3389}"
    echo -e "${WHITE}HTTP:   http://${PAID_VPS_IP}:${HTTP_PORT:-8000}"
    echo -e "${WHITE}HTTPS:  https://${PAID_VPS_IP}:${HTTPS_PORT:-8443}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}The tunnel will:${NC}"
    echo -e "${GREEN}  ✓ Auto-start on boot${NC}"
    echo -e "${GREEN}  ✓ Auto-reconnect if disconnected${NC}"
    echo -e "${GREEN}  ✓ Monitor health every 30 seconds${NC}"
    echo -e "${GREEN}  ✓ Keep alive with heartbeat (30s interval)${NC}"
    echo -e "${GREEN}  ✓ Restart automatically if it crashes${NC}"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${WHITE}Useful commands:${NC}"
    echo -e "${CYAN}  idx-247 status${NC}    - Check status"
    echo -e "${CYAN}  idx-247 restart${NC}   - Restart tunnel"
    echo -e "${CYAN}  idx-247 stop${NC}      - Stop tunnel"
    echo -e "${CYAN}  idx-247 start${NC}     - Start tunnel"
    echo -e "${CYAN}  journalctl -u idx-tunnel -f${NC}  - View logs"
    echo -e "${CYAN}  tail -f /var/log/idx-health-check.log${NC}  - View health logs"
    echo ""
}

# Show help
show_help() {
    print_banner
    echo ""
    echo -e "${WHITE}Usage: $0 [command]${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo ""
    echo -e "  ${CYAN}setup${NC}         - Interactive configuration setup"
    echo -e "  ${CYAN}start${NC}         - Start all 24/7 services"
    echo -e "  ${CYAN}stop${NC}          - Stop all 24/7 services"
    echo -e "  ${CYAN}restart${NC}       - Restart all 24/7 services"
    echo -e "  ${CYAN}status${NC}        - Show detailed status"
    echo -e "  ${CYAN}quick${NC}         - Quick start (full setup)"
    echo -e "  ${CYAN}install${NC}       - Install and configure everything"
    echo -e "  ${CYAN}tailscale${NC}     - Install Tailscale"
    echo -e "  ${CYAN}help${NC}          - Show this help message"
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════════${NC}"
    echo ""
}

# Interactive menu
show_menu() {
    print_banner

    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "       ${GREEN}[1]${NC}  ⚡ Quick Start (Full Setup)"
    echo -e "       ${GREEN}[2]${NC}  ⚙️  Setup/Update Configuration"
    echo -e "       ${GREEN}[3]${NC}  🔐  Setup SSH Keys"
    echo -e "       ${GREEN}[4]${NC}  ▶️  Start Services"
    echo -e "       ${GREEN}[5]${NC}  ⏹️  Stop Services"
    echo -e "       ${GREEN}[6]${NC}  🔄 Restart Services"
    echo -e "       ${GREEN}[7]${NC}  📊 Show Status"
    echo -e "       ${GREEN}[8]${NC}  🛡️  Install Tailscale"
    echo -e "       ${GREEN}[9]${NC}  ❓ Help"
    echo -e "       ${GREEN}[0]${NC}  🚪 Exit"
    echo ""
    echo -e "${CYAN}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Enter your choice [0-9]: ${NC}"

    read -r choice </dev/tty 2>/dev/null || read -r choice
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
        1)
            quick_start
            ;;
        2)
            setup_config
            ;;
        3)
            setup_ssh_keys
            ;;
        4)
            start_services
            ;;
        5)
            stop_services
            ;;
        6)
            systemctl restart idx-tunnel idx-monitor
            echo -e "${GREEN}[✓] Services restarted!${NC}"
            ;;
        7)
            show_status
            ;;
        8)
            install_tailscale
            ;;
        9)
            show_help
            ;;
        0)
            echo ""
            echo -e "${MAGENTA}    ★ Thanks for using NjanFlame 24/7! ★${NC}"
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

# Main
check_root

case "${1:-}" in
    setup)
        setup_config
        ;;
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        systemctl restart idx-tunnel idx-monitor
        echo -e "${GREEN}[✓] Services restarted!${NC}"
        ;;
    status)
        show_status
        ;;
    quick|install)
        quick_start
        ;;
    tailscale)
        install_tailscale
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
