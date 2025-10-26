# PDS Installation

Install and configure your Bluesky Personal Data Server.

## Prerequisites

Before starting:
- ✅ Ubuntu server running (see [DigitalOcean Setup](digitalocean-setup.md))
- ✅ DNS configured and propagated (see [DNS Configuration](dns-configuration.md))
- ✅ SSH access to your server
- ✅ Ports 80 and 443 open in firewall

---

## Step 1: SSH to Your Server

```bash
ssh root@yourdomain.com
# Or use the IP address
ssh root@142.93.123.45
```

---

## Step 2: Download Installer

```bash
# Download the official installer script
curl -fsSL https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh -o installer.sh

# Make it executable
chmod +x installer.sh
```

---

## Step 3: Run Installer

```bash
sudo bash installer.sh
```

The installer will:
1. Install Docker and Docker Compose
2. Download the PDS container
3. Set up Caddy web server (for HTTPS)
4. Configure the PDS
5. Start the service

---

## Step 4: Answer Installer Prompts

The installer will ask you several questions:

### 1. Hostname
```
Enter your PDS hostname (e.g., example.com):
```
**Enter:** `yourdomain.com` (your actual domain)

Example: `jswan.dev`

### 2. Admin Email
```
Enter your email address:
```
**Enter:** Your email address

This is used for:
- TLS certificate notifications
- Account recovery
- Server notifications

### 3. Data Directory (Optional)
```
Where should we store PDS data? [/pds]:
```
**Press Enter** to use default (`/pds`)

Or specify a custom path if you have a mounted volume.

### 4. Confirm Configuration
```
The following configuration will be used:
  Hostname: yourdomain.com
  Email: you@example.com
  Data Directory: /pds

Is this correct? (yes/no):
```
**Enter:** `yes`

---

## Step 5: Wait for Installation

The installer will now:

```
[✓] Installing Docker...
[✓] Installing Docker Compose...
[✓] Downloading PDS image...
[✓] Configuring Caddy...
[✓] Setting up systemd service...
[✓] Starting PDS...
```

This takes 2-5 minutes depending on your server speed.

---

## Step 6: Verify Installation

### Check Service Status

```bash
systemctl status pds
```

Should show:
```
● pds.service - Bluesky PDS
   Loaded: loaded
   Active: active (running)
```

Press `q` to exit.

### Check Health Endpoint

```bash
curl https://yourdomain.com/xrpc/_health
```

Should return:
```json
{"version":"0.4.0"}
```

### Test in Browser

Visit: `https://yourdomain.com/xrpc/_health`

You should see the JSON response with no certificate warnings.

### Verify WebSocket

Install WebSocket testing tool:
```bash
pip3 install websocket-client
```

Test WebSocket connection:
```bash
wsdump "wss://yourdomain.com/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
```

This should connect without errors (may show no output until events occur).

Press `Ctrl+C` to exit.

---

## Step 7: Create Your Account {#create-account}

### Using pdsadmin

```bash
sudo pdsadmin account create
```

You'll be prompted for:

1. **Handle** (username)
   ```
   Enter handle (e.g., alice):
   ```
   Enter your desired username (e.g., `swan`, `admin`, `yourname`)
   
   Your full handle will be: `@yourname.yourdomain.com`

2. **Email**
   ```
   Enter email:
   ```
   Enter your email address

3. **Password**
   ```
   Enter password:
   ```
   Choose a strong password (minimum 8 characters)

### Example

```bash
$ sudo pdsadmin account create
Enter handle (e.g., alice): swan
Enter email: swan@jswan.dev
Enter password: ********
Confirm password: ********

✓ Account created successfully!
  Handle: @swan.jswan.dev
  DID: did:plc:abc123xyz456
```

---

## Step 8: Connect Bluesky App {#connect-app}

### Web App

1. Go to [bsky.app](https://bsky.app)
2. Click **Create a new account**
3. Select **Custom** hosting provider
4. Enter your PDS URL: `https://yourdomain.com`
5. Enter your handle (just the username part, e.g., `swan`)
6. Enter your email and password
7. Complete signup

### Mobile App

#### iPhone
1. Download [Bluesky on App Store](https://apps.apple.com/us/app/bluesky-social/id6444370199)
2. Open app → **Create new account**
3. Choose **Custom** server
4. Enter: `https://yourdomain.com`
5. Complete signup

#### Android
1. Download [Bluesky on Play Store](https://play.google.com/store/apps/details?id=xyz.blueskyweb.app)
2. Open app → **Create new account**
3. Choose **Custom** server
4. Enter: `https://yourdomain.com`
5. Complete signup

---

## Step 9: Create Additional Accounts (Optional)

### Generate Invite Codes

```bash
sudo pdsadmin create-invite-code
```

Output:
```
Invite code: bsky-social-abc123-xyz456
```

Share this code with friends/family to create accounts on your PDS.

### Using Invite Codes

When creating an account in the Bluesky app:
1. Select your PDS as the hosting provider
2. Enter the invite code when prompted
3. Complete account creation

---

## Configuration Files

### Main Configuration

Located at: `/pds/pds.env`

```bash
# View current configuration
cat /pds/pds.env
```

Common settings:
```bash
PDS_HOSTNAME=yourdomain.com
PDS_DATA_DIRECTORY=/pds
PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks
PDS_DID_PLC_URL=https://plc.directory
PDS_CRAWLERS=https://bsky.network
```

### Docker Compose

Located at: `/pds/compose.yaml`

```bash
# View Docker configuration
cat /pds/compose.yaml
```

---

## Managing the PDS Service

### Check Status
```bash
systemctl status pds
```

### Start Service
```bash
systemctl start pds
```

### Stop Service
```bash
systemctl stop pds
```

### Restart Service
```bash
systemctl restart pds
```

### View Logs
```bash
# Real-time logs
journalctl -u pds -f

# Last 100 lines
journalctl -u pds -n 100

# Docker logs
docker logs pds
```

---

## Troubleshooting

### PDS won't start

```bash
# Check Docker status
systemctl status docker

# Check logs for errors
journalctl -u pds -n 50

# Restart Docker
systemctl restart docker
systemctl restart pds
```

### Health endpoint returns error

**Check DNS:**
```bash
dig yourdomain.com +short
# Should return your server IP
```

**Check firewall:**
```bash
ufw status
# Ensure 80 and 443 are allowed
```

**Check Caddy:**
```bash
docker logs caddy
```

### Certificate errors

Caddy automatically provisions TLS certificates. If you see certificate errors:

1. **Wait 30-60 seconds** - First-time certificate provisioning takes time
2. **Check DNS** - Must be properly configured
3. **Check Caddy logs:**
   ```bash
   docker logs caddy
   ```

### Can't create account

**Check service is running:**
```bash
systemctl status pds
```

**Check health endpoint:**
```bash
curl https://yourdomain.com/xrpc/_health
```

**View pdsadmin logs:**
```bash
sudo pdsadmin account create --verbose
```

---

## First Steps After Installation

1. **Create your account** (done above)
2. **Make your first post** to test federation
3. **Set up email** (optional, see [Email Setup](email-setup.md))
4. **Create backups** (see [Maintenance](maintenance.md))
5. **Join the community** ([AT Protocol Discord](https://discord.gg/e7hpHxRfBP))

---

## What's Running?

After installation, you have:

```
┌─────────────────────────────────────┐
│  Docker Containers                  │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │  pds                         │   │
│  │  - Main PDS service          │   │
│  │  - Port 3000 (internal)      │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  caddy                       │   │
│  │  - Reverse proxy             │   │
│  │  - HTTPS/TLS                 │   │
│  │  - Ports 80, 443             │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Data Storage                       │
├─────────────────────────────────────┤
│  /pds/                              │
│  ├── blocks/        (media files)   │
│  ├── pds.env        (config)        │
│  ├── compose.yaml   (docker config) │
│  └── accounts.sqlite (user data)    │
└─────────────────────────────────────┘
```

---

## Next Steps

✅ PDS installed and running  
✅ Account created  
✅ Connected to Bluesky app  

**Optional Next Steps:**
- [Set up email/SMTP →](email-setup.md)
- [Learn about maintenance →](maintenance.md)
- [Read troubleshooting tips →](troubleshooting.md)

---

**Questions?** Join the [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)
