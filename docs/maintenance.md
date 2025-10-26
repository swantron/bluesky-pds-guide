# Maintenance & Updates

Keep your PDS running smoothly with regular maintenance and updates.

## Regular Maintenance Tasks

### Weekly
- ✅ Check server health
- ✅ Review disk space usage
- ✅ Check for PDS updates

### Monthly
- ✅ Update PDS to latest version
- ✅ Review logs for errors
- ✅ Verify backups
- ✅ Update server packages

### Quarterly
- ✅ Full backup
- ✅ Security audit
- ✅ Performance review

---

## Updating Your PDS

### Check Current Version

```bash
# Check PDS version
curl https://yourdomain.com/xrpc/_health

# Should return something like:
# {"version":"0.4.0"}
```

### Update Using pdsadmin (Recommended)

The easiest way to update:

```bash
sudo pdsadmin update
```

This will:
1. Pull the latest PDS image
2. Restart the containers
3. Verify the update

### Manual Update

If `pdsadmin` doesn't work:

```bash
# Navigate to PDS directory
cd /pds

# Pull latest images
docker compose pull

# Restart containers
docker compose down
docker compose up -d

# Verify
systemctl status pds
```

### Verify Update

```bash
# Check new version
curl https://yourdomain.com/xrpc/_health

# Check logs
journalctl -u pds -n 50
```

---

## Monitoring Server Health

### Check Service Status

```bash
# PDS service
systemctl status pds

# Docker service
systemctl status docker
```

### Check Resource Usage

```bash
# Memory and CPU
htop

# Or simpler
top

# Disk space
df -h

# Check /pds directory size
du -sh /pds/*
```

### Check Container Health

```bash
# List running containers
docker ps

# Check container stats
docker stats --no-stream

# Check specific container logs
docker logs pds --tail 50
docker logs caddy --tail 50
```

---

## Disk Space Management

### Check Current Usage

```bash
# Overall disk usage
df -h

# PDS data directory
du -sh /pds
du -sh /pds/*

# Breakdown by subdirectory
du -h /pds/ --max-depth=1
```

### What Uses Space

| Directory | Contents | Typical Size |
|-----------|----------|--------------|
| `/pds/blocks/` | Media files (images, videos) | Largest |
| `/pds/accounts.sqlite` | User data | Small-Medium |
| Docker images | PDS and Caddy containers | ~500 MB |
| Docker logs | Container logs | Grows over time |

### Clean Up Docker

```bash
# Remove unused Docker images
docker image prune -a

# Remove unused Docker volumes
docker volume prune

# Remove unused Docker containers
docker container prune
```

**Warning:** Don't delete PDS data in `/pds/` - it contains your users' data!

### Expanding Disk Space

If running out of space:

1. **Upgrade VPS plan** (easiest)
2. **Add block storage** (DigitalOcean Volumes)
3. **Move media to object storage** (advanced)

---

## Backups

### What to Back Up

**Essential:**
- `/pds/accounts.sqlite` - User accounts and data
- `/pds/blocks/` - Media files
- `/pds/pds.env` - Configuration

**Optional:**
- `/pds/compose.yaml` - Docker configuration (can be regenerated)
- `/pds/caddy/` - Caddy data (can be regenerated)

### Manual Backup

```bash
# Create backup directory
mkdir -p ~/backups/$(date +%Y%m%d)

# Backup SQLite database
cp /pds/accounts.sqlite ~/backups/$(date +%Y%m%d)/

# Backup configuration
cp /pds/pds.env ~/backups/$(date +%Y%m%d)/

# Backup blocks (media files)
# Warning: Can be very large!
tar -czf ~/backups/$(date +%Y%m%d)/blocks.tar.gz /pds/blocks/
```

### Automated Daily Backup Script

Create a backup script:

```bash
sudo nano /usr/local/bin/backup-pds.sh
```

Add this content:

```bash
#!/bin/bash
BACKUP_DIR="/root/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup database
cp /pds/accounts.sqlite "$BACKUP_DIR/"

# Backup config
cp /pds/pds.env "$BACKUP_DIR/"

# Optional: Backup blocks (can be very large)
# tar -czf "$BACKUP_DIR/blocks.tar.gz" /pds/blocks/

# Keep only last 7 days of backups
find /root/backups/ -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $BACKUP_DIR"
```

Make it executable:

```bash
sudo chmod +x /usr/local/bin/backup-pds.sh
```

### Schedule with Cron

```bash
# Edit crontab
sudo crontab -e

# Add daily backup at 2 AM
0 2 * * * /usr/local/bin/backup-pds.sh >> /var/log/pds-backup.log 2>&1
```

### DigitalOcean Snapshots

1. Go to your droplet in DigitalOcean
2. Click **Snapshots**
3. Click **Take snapshot**
4. Wait 5-10 minutes

**Cost:** ~$0.05/GB/month

### Download Backups Locally

```bash
# From your local machine
scp root@yourdomain.com:/root/backups/20241026/* ./local-backups/

# Or entire backup directory
rsync -avz root@yourdomain.com:/root/backups/ ./local-backups/
```

---

## Restoring from Backup

### Restore Database

```bash
# Stop PDS
systemctl stop pds

# Restore database
cp ~/backups/20241026/accounts.sqlite /pds/accounts.sqlite

# Set proper permissions
chown root:root /pds/accounts.sqlite

# Start PDS
systemctl start pds
```

### Restore Configuration

```bash
cp ~/backups/20241026/pds.env /pds/pds.env
systemctl restart pds
```

### Full Server Restore

If server is lost:

1. Create new droplet
2. Install PDS
3. Stop PDS service
4. Restore `/pds/` directory from backup
5. Start PDS service

---

## Security Updates

### Update Ubuntu Packages

```bash
# Update package list
apt update

# Upgrade packages
apt upgrade -y

# Reboot if kernel updated
reboot
```

### Automatic Security Updates

Enable unattended upgrades:

```bash
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
```

Select "Yes" to enable automatic security updates.

---

## Monitoring & Alerts

### Check Logs

```bash
# PDS logs (real-time)
journalctl -u pds -f

# Last 100 lines
journalctl -u pds -n 100

# Errors only
journalctl -u pds -p err

# Docker logs
docker logs pds --tail 100 -f
```

### Set Up Email Alerts (Optional)

Install monitoring tools:

```bash
# Install monitoring
apt install sysstat -y

# For email notifications
apt install mailutils -y
```

### External Monitoring

Free uptime monitoring services:

- [UptimeRobot](https://uptimerobot.com) - Free for 50 monitors
- [StatusCake](https://statuscake.com) - Free tier available
- [Pingdom](https://pingdom.com) - 30-day trial

Monitor URL: `https://yourdomain.com/xrpc/_health`

---

## Performance Optimization

### Check Performance

```bash
# CPU and memory
htop

# Disk I/O
iotop

# Network usage
iftop
```

### Optimize Docker

```bash
# Set Docker log rotation
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Restart Docker
systemctl restart docker
```

### Database Optimization

```bash
# Vacuum SQLite database (reclaim space)
sqlite3 /pds/accounts.sqlite "VACUUM;"
```

---

## Common Maintenance Tasks

### Restart PDS

```bash
systemctl restart pds
```

### View Active Users

```bash
# List accounts
sqlite3 /pds/accounts.sqlite "SELECT handle FROM actors;"
```

### Check Account Count

```bash
sqlite3 /pds/accounts.sqlite "SELECT COUNT(*) FROM actors;"
```

### Generate Invite Codes

```bash
sudo pdsadmin create-invite-code
```

### View Invite Codes

```bash
sudo pdsadmin list-invite-codes
```

---

## Upgrading Server Resources

### When to Upgrade

Upgrade when:
- CPU usage consistently > 80%
- Memory usage consistently > 90%
- Disk space < 20% free
- Slow response times

### DigitalOcean Resize

1. Go to droplet in DigitalOcean
2. Click **Resize**
3. Choose new size
4. Click **Resize Droplet**

**Note:** Requires brief downtime (2-5 minutes)

### Recommended Sizes by User Count

| Users | RAM | CPU | Disk | Monthly Cost |
|-------|-----|-----|------|--------------|
| 1-20 | 1 GB | 1 core | 25 GB | $7 |
| 20-50 | 2 GB | 1 core | 50 GB | $12 |
| 50-100 | 2 GB | 2 cores | 60 GB | $18 |
| 100+ | 4 GB | 2 cores | 80 GB | $24 |

---

## Troubleshooting Updates

### Update Failed

```bash
# Check Docker status
systemctl status docker

# Try manual update
cd /pds
docker compose pull
docker compose up -d

# Check logs
journalctl -u pds -n 100
```

### Service Won't Start After Update

```bash
# Check configuration
cat /pds/pds.env

# Validate Docker compose
cd /pds
docker compose config

# Restart fresh
docker compose down
docker compose up -d
```

### Rollback to Previous Version

```bash
cd /pds

# Stop current version
docker compose down

# Edit compose.yaml to use specific version
nano compose.yaml

# Find line with image and change:
# FROM: image: ghcr.io/bluesky-social/pds:latest
# TO:   image: ghcr.io/bluesky-social/pds:0.3.5

# Start with pinned version
docker compose up -d
```

---

## Maintenance Checklist

### Before Updates
- [ ] Create backup
- [ ] Check disk space (> 20% free)
- [ ] Verify current version
- [ ] Note current status

### During Updates
- [ ] Run update command
- [ ] Monitor logs
- [ ] Wait for completion

### After Updates
- [ ] Verify new version
- [ ] Test health endpoint
- [ ] Check service status
- [ ] Test creating account
- [ ] Monitor logs for errors

---

## Getting Help

If you encounter issues:

1. Check logs: `journalctl -u pds -n 100`
2. Check [Troubleshooting guide](troubleshooting.md)
3. Search [GitHub issues](https://github.com/bluesky-social/pds/issues)
4. Ask in [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)

---

**Next:** [Troubleshooting →](troubleshooting.md)
