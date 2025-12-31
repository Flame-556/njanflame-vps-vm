#!/bin/bash

# Ubuntu VM with RDP and Tailscale - 24/7 Setup Script
# Run this on a fresh Ubuntu install (server or desktop)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN} Ubuntu VM with RDP + Tailscale Setup${NC}"
echo -e "${GREEN}======================================${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}Note: Some commands need sudo. You'll be prompted for password.${NC}"
fi

# Function to run command with sudo if needed
run_cmd() {
    if [[ $EUID -eq 0 ]]; then
        eval "$@"
    else
        sudo "$@"
    fi
}

echo -e "\n${YELLOW}[1/6] Updating system...${NC}"
run_cmd apt-get update
run_cmd apt-get upgrade -y

echo -e "\n${YELLOW}[2/6] Installing desktop environment, XRDP and tools...${NC}"
# Install Ubuntu Desktop (GUI), RDP server, and nosleep tools
run_cmd apt-get install -y \
    ubuntu-desktop \
    xrdp \
    xorg \
    xdotool \
    caffeine \
    unzip

echo -e "\n${YELLOW}[3/6] Configuring XRDP...${NC}"
# Set default desktop session for RDP
echo "xfce4-session" > ~/.xsession
run_cmd cp /root/.xsession /root/.xsession.bak 2>/dev/null || true
run_cmd cp ~/.xsession /root/.xsession

# Configure XRDP to use XFCE or default desktop
if [ -f /etc/xrdp/startwm.sh ]; then
    run_cmd cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak
    # Make sure it starts the desktop properly
    run_cmd sed -i 's|test -x /etc/X11/Xsession|/usr/bin/gnome-session|g' /etc/xrdp/startwm.sh 2>/dev/null || true
fi

# Create xrdp certificate for secure connections
run_cmd mkdir -p /etc/xrdp
run_cmd openssl req -x509 -newkey rsa:2048 -keyout /etc/xrdp/key.pem -out /etc/xrdp/cert.pem -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" 2>/dev/null || true

# Restart XRDP service
run_cmd systemctl enable xrdp
run_cmd systemctl restart xrdp

echo -e "\n${YELLOW}[4/6] Installing Tailscale...${NC}"
# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    run_cmd apt-get install -y apt-transport-https ca-certificates
    run_cmd curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg -o /usr/share/keyrings/tailscale-archive-keyring.gpg
    run_cmd curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list -o /etc/apt/sources.list.d/tailscale.list
    run_cmd apt-get update
    run_cmd apt-get install -y tailscale
fi

echo -e "\n${YELLOW}[5/6] Configuring Tailscale for 24/7...${NC}"
# Enable IP forwarding for better connectivity
run_cmd sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true
run_cmd sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true

# Make IP forwarding persistent
if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf 2>/dev/null; then
    run_cmd sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
    run_cmd sh -c 'echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf'
fi

# Start and enable Tailscale service
run_cmd systemctl enable tailscaled
run_cmd systemctl start tailscaled

echo -e "\n${YELLOW}[6/6] Configuring for 24/7 operation - Preventing Sleep/Suspend...${NC}"

# ========== DISABLE SLEEP AND SUSPEND ==========

# Disable sleep when AC power is connected
run_cmd gsettings set org.gnome.desktop.session idle-delay 0
run_cmd gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
run_cmd gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# Disable screen blanking
run_cmd gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
run_cmd gsettings set org.gnome.desktop.screensaver lock-enabled false

# Set power profile to high performance (never sleep)
run_cmd gsettings set org.gnome.settings-daemon.plugins.power power-profile 'performance' 2>/dev/null || true

# Create overrides to disable sleep completely via dconf
run_cmd mkdir -p /etc/dconf/db/local.d/00-sleep-override

cat > /tmp/sleep-override << 'EOF'
[daemon]
IdleAction=ignore
IdleActionTimeout=0

[org/gnome/desktop/screensaver]
idle-activation-enabled=false
lock-enabled=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-timeout=0
sleep-inactive-battery-timeout=0
EOF
run_cmd cp /tmp/sleep-override /etc/dconf/db/local.d/00-sleep-override
run_cmd dconf update

# Also configure logind.conf to never suspend
run_cmd mkdir -p /etc/systemd/logind.conf.d
cat > /tmp/logind-override.conf << 'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
SuspendMode=none
HibernateMode=none
EOF
run_cmd cp /tmp/logind-override.conf /etc/systemd/logind.conf.d/99-never-suspend.conf

# Configure systemd sleep to do nothing
run_cmd mkdir -p /etc/systemd/system/sleep.target.wants
cat > /tmp/systemd-sleep.conf << 'EOF'
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowSuspendThenHibernate=no
AllowHybridSleep=no
EOF
run_cmd cp /tmp-systemd-sleep.conf /etc/systemd/sleep.conf 2>/dev/null || run_cmd mkdir -p /etc/systemd && cp /tmp/systemd-sleep.conf /etc/systemd/sleep.conf

# Disable sleep services
run_cmd systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true

# Create a no-sleep service that simulates user activity
cat > /tmp/nosleep.service << 'EOF'
[Unit]
Description=Prevent system from sleeping

[Service]
Type=simple
ExecStart=/bin/bash -c "while true; do xdotool key --delay 60000 Caps_Lock 2>/dev/null || echo 'dummy' > /dev/null; sleep 60; done"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
run_cmd cp /tmp/nosleep.service /etc/systemd/system/nosleep.service

# Alternative nosleep using systemd inhibitor
cat > /tmp/nosleep-inhibit.service << 'EOF'
[Unit]
Description=Inhibit sleep/suspend via systemd

[Service]
Type=simple
ExecStart=/usr/bin/systemd-inhibit --what=sleep:idle --who=nosleep --why=Keeping-VM-awake --mode=block /bin/bash -c "while true; do sleep 3600; done"
Restart=always

[Install]
WantedBy=multi-user.target
EOF
run_cmd cp /tmp/nosleep-inhibit.service /etc/systemd/system/nosleep-inhibit.service

# Enable the sleep inhibitors
run_cmd systemctl enable nosleep.service
run_cmd systemctl enable nosleep-inhibit.service
run_cmd systemctl start nosleep.service
run_cmd systemctl start nosleep-inhibit.service

# Create a health check script
cat > /tmp/healthcheck.sh << 'EOF'
#!/bin/bash
# Health check script - keep VM responsive

# Check if XRDP is running, restart if not
if ! systemctl is-active --quiet xrdp; then
    systemctl restart xrdp
fi

# Check if Tailscale is running, restart if not
if ! systemctl is-active --quiet tailscaled; then
    systemctl restart tailscaled
fi
EOF
run_cmd chmod +x /tmp/healthcheck.sh
run_cmd cp /tmp/healthcheck.sh /usr/local/bin/healthcheck.sh

# Create timer for health checks
cat > /tmp/healthcheck.timer << 'EOF'
[Unit]
Description=Run health check every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF
run_cmd cp /tmp/healthcheck.timer /etc/systemd/system/healthcheck.timer
run_cmd systemctl enable healthcheck.timer
run_cmd systemctl start healthcheck.timer

echo -e "\n${GREEN}======================================${NC}"
echo -e "${GREEN} Installation Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}24/7 SLEEP PREVENTION IS NOW ACTIVE!${NC}"
echo "   - Sleep/suspend disabled"
echo "   - Screen blanking disabled"
echo "   - Systemd sleep masked"
echo "   - No-sleep services running"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo ""
echo -e "1. ${GREEN}Connect to Tailscale:${NC}"
echo "   Run: sudo tailscale up"
echo "   Copy the authentication URL and open it in your browser"
echo ""
echo -e "2. ${GREEN}Get your Tailscale IP:${NC}"
echo "   Run: tailscale ip -4"
echo ""
echo -e "3. ${GREEN}Connect via RDP:${NC}"
echo "   Use any RDP client and connect to:"
echo "   <your-tailscale-ip>:3389"
echo ""
echo -e "4. ${GREEN}For 24/7 operation:${NC}"
echo "   - VM host MUST auto-start on power on"
echo "   - Configure hypervisor: Start VM on host boot"
echo "   - Enable Wake-on-LAN in VM settings if available"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "   tailscale status       - See connected devices"
echo "   tailscale down         - Disconnect from Tailscale"
echo "   tailscale up           - Reconnect to Tailscale"
echo "   systemctl status nosleep-inhibit  - Check no-sleep status"
echo "   systemctl status xrdp             - Check RDP status"
echo ""
echo -e "${YELLOW}VERIFY 24/7 IS WORKING:${NC}"
echo "   systemctl status nosleep-inhibit"
echo "   systemctl status nosleep"
echo ""
