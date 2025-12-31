# 🚀 NjanFlame Ultimate VPS + VM Manager

**Create a 24/7 relay system like .idx/.dev - connect your Ubuntu VM through a 24/7 VPS!**

---

## ⚡ Quick Install (One-Line)

### On your 24/7 VPS:
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | bash
```
Then select option `1`

### On your Ubuntu VM:
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | bash
```
Then select option `2`

---

## 📦 Manual Install

### Download scripts:
```bash
# On VPS (24/7 server)
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/vps-menu-setup.sh
chmod +x vps-menu-setup.sh
sudo ./vps-menu-setup.sh

# On Ubuntu VM
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/vm-client-menu-setup.sh
chmod +x vm-client-menu-setup.sh
sudo ./vm-client-menu-setup.sh
```

---

## 📋 Commands

| Command | Where to Run | Description |
|---------|--------------|-------------|
| `sudo njan-vps` | 24/7 VPS | Manage FRP server & VMs |
| `sudo njan-vm` | Ubuntu VM | Connect VM to VPS |

---

## 🎮 How It Works

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   YOU       │ ─RDP──► │   VPS       │ ─tunnel► │   VM        │
│  (Anywhere) │ :3389   │  (24/7)     │ :7000    │  (On/Off)   │
└─────────────┘         └─────────────┘         └─────────────┘
                                │
                           FRP Server
                                │
                           FRP Client
                           (auto-connect)
```

---

## 📖 Usage Guide

### Step 1: Setup VPS (24/7 Server)

1. SSH into your VPS
2. Run the installer
3. Select `[1]` to install FRP Server
4. Select `[2]` to add VMs (vm-001, vm-002, etc.)
5. Select `[5]` and copy the info to give to VM owners

### Step 2: Setup Ubuntu VM

1. Open terminal in your Ubuntu VM
2. Run the installer
3. Select `[7]` for Quick Start
4. Enter the info from VPS owner

### Step 3: Connect via RDP

From anywhere, use Remote Desktop:
```
mstsc /v: your-vps-ip:3389
```

---

## 📂 Files

| File | Description |
|------|-------------|
| `install.sh` | One-line installer |
| `vps-menu-setup.sh` | VPS server manager |
| `vm-client-menu-setup.sh` | VM client setup |
| `README.md` | This file |

---

## 🎨 Features

- ✨ NjanFlame Ultimate branding with animations
- 🎛️ Interactive menu system
- ❓ Built-in help ([7] or [8])
- 🔄 Auto-refresh (keeps VM active every 5 min)
- 💤 Sleep/suspend prevention
- 🛡️ Tailscale backup
- 👥 Support for up to 6 VMs

---

## 🔧 Menu Options

### VPS Menu:
```
[1] Install FRP Server
[2] Add a VM (1-6)
[3] List connected VMs
[4] Remove a VM
[5] Show connection info
[6] Restart FRP Server
[7] Help
[8] Exit
```

### VM Menu:
```
[1] Setup Desktop & RDP
[2] Setup FRP Client
[3] Setup Auto-Refresh
[4] Setup Tailscale
[5] Disable Sleep/Suspend
[6] Show Connection Status
[7] Run ALL Setup (Quick Start)
[8] Help
[9] Exit
```

---

## 📝 License

Made with ❤️ by NjanFlame

---

## 🔗 Links

- GitHub: https://github.com/njanflame/njanflame-vps-vm

