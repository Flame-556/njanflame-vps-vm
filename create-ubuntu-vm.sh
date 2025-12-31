#!/bin/bash

# Script to create Ubuntu VM on macOS with UTM or VirtualBox
# and install RDP + Tailscale for 24/7 access

set -e

echo "======================================"
echo " Ubuntu VM Creator for macOS"
echo "======================================"
echo ""
echo "Choose your virtualization platform:"
echo "1) UTM (Apple Silicon/Intel Mac)"
echo "2) VirtualBox (Intel Mac only)"
echo "3) VMware Fusion (Intel Mac only)"
echo ""

read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "For UTM:"
        echo "1. Download Ubuntu Server ISO from https://ubuntu.com/download/server"
        echo "2. Open UTM and create a new VM"
        echo "3. Select 'Virtualize' > 'Linux'"
        echo "4. Assign at least: 2 CPU, 4GB RAM, 40GB storage"
        echo "5. Mount the Ubuntu ISO and start the VM"
        echo "6. During installation, create a user: ubuntu/password"
        echo "7. After install, reboot and run: curl -sL https://raw.githubusercontent.com/YOUR_REPO/setup-rdp-vm.sh | sudo bash"
        ;;
    2)
        echo ""
        echo "For VirtualBox:"
        brew install --cask virtualbox 2>/dev/null || echo "Install VirtualBox manually from https://www.virtualbox.org"
        echo ""
        echo "Then download Ubuntu Desktop ISO and create a VM with:"
        echo "- Type: Linux"
        echo "- Version: Ubuntu (64-bit)"
        echo "- RAM: 4096 MB"
        echo "- CPU: 2"
        echo "- Storage: 40 GB"
        ;;
    3)
        echo ""
        echo "For VMware Fusion:"
        echo "Download from VMware website and create VM with:"
        echo "- RAM: 4096 MB"
        echo "- CPU: 2"
        echo "- Storage: 40 GB"
        ;;
esac

echo ""
echo "======================================"
echo "After VM is installed, copy setup-rdp-vm.sh to your VM and run:"
echo ""
echo "  chmod +x setup-rdp-vm.sh"
echo "  sudo ./setup-rdp-vm.sh"
echo ""
echo "Then follow the on-screen instructions!"
echo "======================================"
