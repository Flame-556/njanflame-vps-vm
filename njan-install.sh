#!/bin/bash

# ===============================================
#  NjanFlame Ultimate VPS+VM Manager Installer
#  Install scripts as system commands
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

echo -e "${ORANGE}"
echo "╔════════════════════════════════════════════╗"
echo "║  ★  NJANFLAME INSTALLER  ★                 ║"
echo "║     Installing System Commands             ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're running from GitHub or locally
GITHUB_BASE="https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main"

echo -e "${YELLOW}[*] Choose installation method:${NC}"
echo ""
echo -e "   ${GREEN}[1]${NC} Install from local files (current folder)"
echo -e "   ${GREEN}[2]${NC} Install from GitHub"
echo -e "   ${GREEN}[3]${NC} Create .sh files only (don't install as command)"
echo ""
echo -e "${YELLOW}Enter choice [1-3]:${NC}"
read -r choice

# Trim whitespace
choice=$(echo "$choice" | tr -d '[:space:]')

case $choice in
    1)
        echo ""
        echo -e "${CYAN}[*] Installing from local files...${NC}"

        if [ ! -f "$SCRIPT_DIR/vps-menu-setup.sh" ]; then
            echo -e "${RED}[✗] vps-menu-setup.sh not found in current folder!${NC}"
            exit 1
        fi

        if [ ! -f "$SCRIPT_DIR/vm-client-menu-setup.sh" ]; then
            echo -e "${RED}[✗] vm-client-menu-setup.sh not found in current folder!${NC}"
            exit 1
        fi

        # Copy scripts to /usr/local/bin
        cp "$SCRIPT_DIR/vps-menu-setup.sh" /usr/local/bin/njan-vps
        cp "$SCRIPT_DIR/vm-client-menu-setup.sh" /usr/local/bin/njan-vm

        # Make executable
        chmod +x /usr/local/bin/njan-vps
        chmod +x /usr/local/bin/njan-vm

        echo -e "${GREEN}[✓] Installed njan-vps command${NC}"
        echo -e "${GREEN}[✓] Installed njan-vm command${NC}"
        ;;
    2)
        echo ""
        echo -e "${CYAN}[*] Downloading from GitHub...${NC}"

        # Download scripts
        curl -sL "${GITHUB_BASE}/vps-menu-setup.sh" -o /usr/local/bin/njan-vps
        curl -sL "${GITHUB_BASE}/vm-client-menu-setup.sh" -o /usr/local/bin/njan-vm

        # Make executable
        chmod +x /usr/local/bin/njan-vps
        chmod +x /usr/local/bin/njan-vm

        echo -e "${GREEN}[✓] Downloaded and installed njan-vps${NC}"
        echo -e "${GREEN}[✓] Downloaded and installed njan-vm${NC}"
        ;;
    3)
        echo ""
        echo -e "${CYAN}[*] Creating .sh files in current folder...${NC}"
        cp "$SCRIPT_DIR/vps-menu-setup.sh" ./vps-menu-setup.sh 2>/dev/null || \
            curl -sL "${GITHUB_BASE}/vps-menu-setup.sh" -o ./vps-menu-setup.sh
        cp "$SCRIPT_DIR/vm-client-menu-setup.sh" ./vm-client-menu-setup.sh 2>/dev/null || \
            curl -sL "${GITHUB_BASE}/vm-client-menu-setup.sh" -o ./vm-client-menu-setup.sh
        chmod +x ./vps-menu-setup.sh ./vm-client-menu-setup.sh
        echo -e "${GREEN}[✓] Files created in current folder!${NC}"
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
echo -e "${WHITE}Commands installed:${NC}"
echo ""
echo -e "${GREEN}  njan-vps${NC}  - Run on your 24/7 VPS server"
echo "              Usage: sudo njan-vps"
echo ""
echo -e "${GREEN}  njan-vm${NC}   - Run on your Ubuntu VM"
echo "              Usage: sudo njan-vm"
echo ""
echo -e "${YELLOW}To use:${NC}"
echo "  sudo njan-vps      # On your 24/7 VPS"
echo "  sudo njan-vm       # On your Ubuntu VM"
echo ""
echo -e "${CYAN}Made with ❤️  by NjanFlame${NC}"
echo ""
