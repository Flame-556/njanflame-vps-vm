# NjanFlame - TRUE 24/7 IDX VPS System

## Overview

This is the **ULTIMATE** 24/7 IDX VPS solution with:
- ✅ **Auto-reconnect** - Automatically reconnects if disconnected
- ✅ **Boot persistence** - Starts automatically on system boot
- ✅ **Health monitoring** - Checks every 30 seconds
- ✅ **SSH key auth** - Passwordless, secure connections
- ✅ **Multiple IDX VPS** - Support for multiple connections
- ✅ **Zero downtime** - Auto-restart on crash

## Files

### 1. `idx-247-setup.sh` - IDX VPS Side (Run on your IDX VPS)

**Features:**
- SSH tunnel systemd service
- Health monitoring service
- SSH key authentication
- Tailscale backup (optional)
- Auto-reconnect on boot
- Auto-restart on failure

**Quick Start:**
```bash
curl -sL https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main/idx-247-setup.sh | sudo bash quick
```

**Interactive Menu:**
```bash
curl -sL https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main/idx-247-setup.sh | sudo bash
```

### 2. `paid-247-acceptor.sh` - Paid VPS Side (Run on your Paid VPS)

**Features:**
- Create multiple IDX VPS users
- Auto-assign unique ports (3389, 3390, 3391, etc.)
- Manage existing connections
- Show connection status
- Generate connection info

**Quick Start:**
```bash
curl -sL https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main/paid-247-acceptor.sh | sudo bash quick
```

**Interactive Menu:**
```bash
curl -sL https://raw.githubusercontent.com/njanflame/njanflame-vps-vm/main/paid-247-acceptor.sh | sudo bash
```

## Setup Guide

### Step 1: Setup Paid VPS (24/7 Server)

Run on your paid 24/7 VPS:

```bash
sudo ./paid-247-acceptor.sh
```

1. Select `1` - Quick Start
2. Create a user (e.g., `idxvps1`)
3. Note the connection info provided

### Step 2: Setup IDX VPS

Run on your IDX VPS:

```bash
sudo ./idx-247-setup.sh
```

1. Select `1` - Quick Start
2. Enter the Paid VPS IP from Step 1
3. Enter the user/password from Step 1
4. Script automatically:
   - Sets up SSH keys (passwordless!)
   - Creates systemd services
   - Starts the tunnel
   - Enables boot persistence

### Step 3: Verify Connection

On Paid VPS:
```bash
sudo ./paid-247-acceptor.sh
# Select [7] - Show Status
```

On IDX VPS:
```bash
sudo ./idx-247-setup.sh status
```

## 24/7 Features Explained

### 1. Boot Persistence
- Systemd service `idx-tunnel` auto-starts on boot
- Systemd service `idx-monitor` auto-starts on boot
- No manual intervention needed

### 2. Auto-Reconnect
If the SSH tunnel disconnects:
- Health monitor detects disconnection
- Automatically restarts the tunnel
- Reconnects in <10 seconds

### 3. Health Monitoring
Runs every 30 seconds:
- Checks if SSH tunnel is alive
- Checks if systemd service is running
- Verifies local ports are accessible
- Logs everything to `/var/log/idx-health-check.log`

### 4. Keep-Alive Heartbeat
SSH configuration includes:
- `ServerAliveInterval=30` - Sends heartbeat every 30s
- `ServerAliveCountMax=3` - After 3 failures, reconnect
- `ExitOnForwardFailure=yes` - Auto-restart on failure
- `Restart=always` - Systemd auto-restarts

### 5. SSH Key Authentication
- No more password prompts
- ED25519 keys (most secure)
- Auto-copied to remote server
- Stored in `/root/.ssh/id_ed25519`

## Command Reference

### IDX VPS Commands (idx-247-setup.sh)

```bash
sudo idx-247-setup              # Interactive menu
sudo idx-247-setup quick        # Full setup
sudo idx-247-setup status       # Show status
sudo idx-247-setup start       # Start services
sudo idx-247-setup stop        # Stop services
sudo idx-247-setup restart     # Restart services
sudo idx-247-setup setup       # Update config
sudo idx-247-setup tailscale   # Install Tailscale
```

**View Logs:**
```bash
journalctl -u idx-tunnel -f        # SSH tunnel logs
journalctl -u idx-monitor -f        # Monitor logs
tail -f /var/log/idx-health-check.log  # Health check logs
```

### Paid VPS Commands (paid-247-acceptor.sh)

```bash
sudo paid-247-acceptor           # Interactive menu
sudo paid-247-acceptor quick    # First time setup
sudo paid-247-acceptor add      # Add IDX VPS user
sudo paid-247-acceptor list     # List users
sudo paid-247-acceptor remove   # Remove user
sudo paid-247-acceptor info     # Generate connection info
sudo paid-247-acceptor status   # Show status
```

## Accessing IDX VPS

After setup, access your IDX VPS via:

### RDP Access
```
mstsc /v: paid-vps-ip:3389
```

### HTTP Access
```
http://paid-vps-ip:8000
```

### HTTPS Access
```
https://paid-vps-ip:8443
```

### SSH Access
```bash
ssh -p 3389 root@paid-vps-ip
```

## Multiple IDX VPS

You can connect multiple IDX VPS to one Paid VPS:

1. On Paid VPS: `sudo paid-247-acceptor add`
2. Create user `idxvps2`, `idxvps3`, etc.
3. Each gets unique ports:
   - idxvps1: 3389, 3390, 3391
   - idxvps2: 3392, 3393, 3394
   - idxvps3: 3395, 3396, 3397

## Troubleshooting

### IDX VPS not connecting?

Check status:
```bash
sudo ./idx-247-setup.sh status
```

Check logs:
```bash
journalctl -u idx-tunnel -n 50
```

Restart manually:
```bash
sudo ./idx-247-setup.sh restart
```

### Can't access ports on Paid VPS?

Check firewall:
```bash
sudo ufw status
sudo ufw allow 3389:3400/tcp
```

Check if ports are listening:
```bash
ss -tuln | grep LISTEN
```

### Tunnel keeps disconnecting?

Check health logs:
```bash
tail -20 /var/log/idx-health-check.log
```

Increase ServerAliveInterval in:
```bash
sudo nano /etc/systemd/system/idx-tunnel.service
# Change ServerAliveInterval to 15
sudo systemctl daemon-reload
sudo systemctl restart idx-tunnel
```

### Want to change connection details?

```bash
sudo ./idx-247-setup.sh setup
```

## File Locations

### IDX VPS
- Config: `/etc/njanflame/idx-vps.conf`
- SSH Keys: `/root/.ssh/id_ed25519`
- SSH Service: `/etc/systemd/system/idx-tunnel.service`
- Monitor Service: `/etc/systemd/system/idx-monitor.service`
- Health Script: `/usr/local/bin/idx-health-check.sh`
- Logs: `/var/log/idx-health-check.log`

### Paid VPS
- Config: `/etc/njanflame/idx-users.conf`
- SSH Config: `/etc/ssh/sshd_config`

## Security Notes

1. **SSH Keys**: Passwordless auth with ED25519 keys
2. **User Isolation**: Each IDX VPS gets separate user
3. **Config Protection**: Config files have 600 permissions
4. **Firewall**: Configure to only allow necessary ports
5. **SSH Config**: Disables weak ciphers, enables forwarding

## Best Practices

1. **Always use SSH keys** - Don't rely on passwords
2. **Monitor logs regularly** - Check `/var/log/idx-health-check.log`
3. **Test failover** - Stop tunnel manually to verify auto-reconnect
4. **Keep Paid VPS online** - This is your relay!
5. **Use Tailscale backup** - Install if SSH tunnel fails

## Support

For issues or questions:
- Check logs: `journalctl -u idx-tunnel -f`
- Check health: `sudo ./idx-247-setup.sh status`
- Verify ports: `ss -tuln`

---

Made with ❤️ by NjanFlame
