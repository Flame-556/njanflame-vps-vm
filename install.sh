#!/bin/bash

# ===============================================
#  NjanFlame One-Line Installer
#  Run: curl -sL https://bit.ly/njanflame | bash
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

echo -e "${ORANGE}"
echo "╔════════════════════════════════════════════╗"
echo "║  ★  NJANFLAME ULTIMATE VPS+VM MANAGER ★    ║"
echo "║            One-Line Installer              ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

echo -e "${YELLOW}[*] Installing...${NC}"
echo ""

# GitHub raw URL
GITHUB_BASE="https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main"

# Detect if we're on VPS or VM
echo -e "${CYAN}[*] Where are you installing?${NC}"
echo ""
echo -e "   ${GREEN}[1]${NC} 24/7 VPS Server (Relay/Entry point)"
echo -e "   ${GREEN}[2]${NC} Ubuntu VM (Non-24/7, needs to connect)"
echo -e "   ${GREEN}[3]${NC} Both scripts (download only)"
echo ""
echo -e "${YELLOW}Enter choice [1-3]:${NC}"
read choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}[*] Installing VPS Manager...${NC}"
        curl -sL "${GITHUB_BASE}/vps-menu-setup.sh" -o /usr/local/bin/njan-vps
        chmod +x /usr/local/bin/njan-vps
        echo -e "${GREEN}[✓] Installed! Run: sudo njan-vps${NC}"
        ;;
    2)
        echo ""
        echo -e "${GREEN}[*] Installing VM Client...${NC}"
        curl -sL "${GITHUB_BASE}/vm-client-menu-setup.sh" -o /usr/local/bin/njan-vm
        chmod +x /usr/local/bin/njan-vm
        echo -e "${GREEN}[✓] Installed! Run: sudo njan-vm${NC}"
        ;;
    3)
        echo ""
        echo -e "${GREEN}[*] Downloading both scripts...${NC}"
        curl -sL "${GITHUB_BASE}/vps-menu-setup.sh" -o ./vps-menu-setup.sh
        curl -sL "${GITHUB_BASE}/vm-client-menu-setup.sh" -o ./vm-client-menu-setup.sh
        chmod +x ./vps-menu-setup.sh ./vm-client-menu-setup.sh
        echo -e "${GREEN}[✓] Downloaded to current folder!${NC}"
        ;;
    *)
        echo -e "${RED}[✗] Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  ★  INSTALLATION COMPLETE!  ★             ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}Usage:${NC}"
echo ""
if [ "$choice" != "3" ]; then
    if [ "$choice" = "1" ]; then
        echo -e "${GREEN}  sudo njan-vps${NC}    # Run on your 24/7 VPS"
    else
        echo -e "${GREEN}  sudo njan-vm${NC}     # Run on your Ubuntu VM"
    fi
    echo ""
    echo -e "${CYAN}Then select [7] for Help to get started!${NC}"
fi
echo ""
echo -e "${CYAN}Made with ❤️  by NjanFlame${NC}"
echo ""
