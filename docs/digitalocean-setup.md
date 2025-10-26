# DigitalOcean Server Setup

This guide walks through creating a DigitalOcean droplet for your Bluesky PDS.

## Step 1: Create DigitalOcean Account

1. Go to [DigitalOcean](https://digitalocean.com)
2. Sign up for an account
3. Verify your email
4. Add a payment method

**New users:** Often get $200 credit for 60 days

## Step 2: Create SSH Key (Recommended)

SSH keys are more secure than passwords.

### On macOS/Linux

```bash
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Press Enter to accept default location
# Optionally set a passphrase

# Display your public key
cat ~/.ssh/id_ed25519.pub
```

### On Windows

Using PowerShell:
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

Copy the entire output (starts with `ssh-ed25519`).

### Add SSH Key to DigitalOcean

1. Click your profile → **Settings**
2. Go to **Security** → **SSH Keys**
3. Click **Add SSH Key**
4. Paste your public key
5. Name it (e.g., "My Laptop")
6. Click **Add SSH Key**

## Step 3: Create Droplet

1. Click **Create** → **Droplets**

2. **Choose Region:**
   - Select closest to you or your users
   - Example: New York, San Francisco, London

3. **Choose an Image:**
   - Click **OS** tab
   - Select **Ubuntu 24.04 LTS x64**

4. **Choose Size:**
   - Click **Droplet Type** → **Basic**
   - Select **Regular** (not Premium)
   - Choose **$6/month** plan:
     - 1 GB RAM
     - 1 vCPU
     - 25 GB SSD
     - 1000 GB transfer

5. **Choose Authentication:**
   - Select **SSH Key** (if you set one up)
   - OR select **Password** (less secure)

6. **Advanced Options (Important):**
   
   Click **Advanced Options** and check **Add Initialization scripts**
   
   Paste this script:
   ```bash
   #!/bin/bash
   # Configure firewall
   ufw allow 22/tcp
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw --force enable
   
   # Update system
   apt-get update
   apt-get upgrade -y
   ```

7. **Finalize Details:**
   - **Hostname**: `bluesky-pds` or `pds-server`
   - **Tags**: (optional) `bluesky`, `pds`
   - **Project**: Default or create new

8. Click **Create Droplet**

## Step 4: Get Droplet Information

Wait ~60 seconds for droplet to be created.

1. Click on your new droplet name
2. **Copy the IPv4 address** (e.g., `142.93.123.45`)
3. Save this IP - you'll need it for DNS configuration

Example:
```
IPv4: 142.93.123.45
```

## Step 5: Test SSH Connection

### Using SSH Key

```bash
ssh root@142.93.123.45
```

### Using Password

```bash
ssh root@142.93.123.45
# Enter the password sent to your email
```

**First time connecting:**
```
The authenticity of host '142.93.123.45' can't be established.
ED25519 key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```
Type `yes` and press Enter.

### Success!

You should see something like:
```
Welcome to Ubuntu 24.04 LTS
...
root@bluesky-pds:~#
```

## Step 6: Verify Firewall (Optional)

```bash
# Check firewall status
ufw status

# Should show:
# Status: active
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW       Anywhere
# 80/tcp                     ALLOW       Anywhere
# 443/tcp                    ALLOW       Anywhere
```

If firewall is not configured, run:
```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

## Troubleshooting

### Can't SSH to server

**Problem:** Connection timeout
- Check that SSH (port 22) is allowed in DigitalOcean's firewall
- Verify you're using the correct IP address
- Wait a few minutes for droplet to fully boot

**Problem:** Permission denied
- Check you're using the correct SSH key
- Try password authentication instead
- Verify SSH key was added to DigitalOcean correctly

### Firewall issues

**Problem:** Ports not open
```bash
# Manually configure firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## Alternative: Vultr Setup

If using Vultr instead of DigitalOcean:

1. Go to [Vultr](https://vultr.com)
2. Click **Deploy** → **Deploy New Server**
3. **Choose Server:**
   - Cloud Compute - Shared CPU
4. **Location:** Choose nearest
5. **Server Image:** Ubuntu 24.04 LTS x64
6. **Server Size:** $6/month (1 GB RAM)
7. **Additional Features:**
   - Enable IPv4
   - Add startup script (same as above)
8. **Deploy Now**

Process is nearly identical to DigitalOcean.

## Cost Summary

| Item | Cost |
|------|------|
| Droplet (1 GB) | $6/month |
| Bandwidth | Included (1 TB) |
| Backups (optional) | +20% ($1.20/month) |
| **Total** | **$6-7.20/month** |

## Next Steps

Now that you have:
- ✅ A running Ubuntu server
- ✅ The server's IP address
- ✅ SSH access to the server
- ✅ Firewall configured

**Next:** [Configure DNS →](dns-configuration.md)

---

**Need help?** Check the [troubleshooting guide](troubleshooting.md) or ask in the [AT Protocol Discord](https://discord.gg/e7hpHxRfBP).
