# Troubleshooting

Common issues and solutions for your Bluesky PDS.

## Quick Diagnostics

Run these commands to gather information:

```bash
# Check PDS service status
systemctl status pds

# Check health endpoint
curl https://yourdomain.com/xrpc/_health

# Check DNS
dig yourdomain.com +short

# Check Docker containers
docker ps

# Check recent logs
journalctl -u pds -n 50

# Check disk space
df -h
```

---

## Installation Issues

### Installer fails with "Docker not found"

**Symptom:** Installer can't find Docker

**Solution:**
```bash
# Install Docker manually
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker
systemctl start docker
systemctl enable docker

# Re-run installer
sudo bash installer.sh
```

### Permission denied errors

**Symptom:** Can't create directories or files

**Solution:**
```bash
# Make sure you're running as root
sudo -i

# Or use sudo with each command
sudo bash installer.sh
```

### DNS resolution errors during install

**Symptom:** Can't download packages or images

**Solution:**
```bash
# Test DNS
ping google.com

# If fails, set DNS manually
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

---

## DNS Issues

### Domain doesn't resolve

**Check DNS propagation:**
```bash
# Check from server
dig yourdomain.com +short

# Check from different DNS servers
dig yourdomain.com @8.8.8.8 +short
dig yourdomain.com @1.1.1.1 +short
```

**Solution:**
1. Verify A records are correct in DNS provider
2. Wait 10-30 minutes for propagation
3. Clear local DNS cache
4. Check [whatsmydns.net](https://whatsmydns.net)

### Wildcard subdomain not working

**Check wildcard:**
```bash
dig test.yourdomain.com +short
dig anything.yourdomain.com +short
```

Both should return your server IP.

**Solution:**
1. Verify wildcard A record (`*`) exists
2. Remove conflicting CNAME records
3. If using Cloudflare, ensure proxy is OFF (gray cloud)

### Certificate errors

**Symptom:** Browser shows "not secure" or certificate errors

**Common causes:**
1. DNS not properly configured
2. Caddy still provisioning certificate (wait 60 seconds)
3. Firewall blocking port 80 (needed for validation)

**Solution:**
```bash
# Check Caddy logs
docker logs caddy

# Restart Caddy
docker restart caddy

# Check port 80 is open
curl http://yourdomain.com/.well-known/acme-challenge/test
```

---

## Service Issues

### PDS won't start

**Check service status:**
```bash
systemctl status pds
```

**Common causes:**

#### 1. Docker not running
```bash
systemctl status docker
systemctl start docker
systemctl start pds
```

#### 2. Configuration error
```bash
# Check config syntax
cat /pds/pds.env

# Look for common issues:
# - Missing quotes around values
# - Incorrect hostname
# - Invalid SMTP URL
```

#### 3. Port conflict
```bash
# Check if ports are in use
netstat -tulpn | grep :443
netstat -tulpn | grep :80

# If something else is using these ports
# Find and stop the conflicting service
```

### Service stops unexpectedly

**Check logs:**
```bash
journalctl -u pds -n 200
```

**Common causes:**

#### 1. Out of memory
```bash
# Check memory usage
free -h

# Check Docker memory
docker stats --no-stream
```

**Solution:** Upgrade server RAM

#### 2. Disk full
```bash
df -h
```

**Solution:** Free up space or upgrade storage

#### 3. Crash or error
```bash
# Check Docker container logs
docker logs pds --tail 100
```

Look for error messages and stack traces.

---

## Connection Issues

### Can't access health endpoint

**Test connectivity:**
```bash
# From server
curl http://localhost:3000/xrpc/_health

# If this works but HTTPS doesn't, problem is Caddy
docker logs caddy

# From outside
curl https://yourdomain.com/xrpc/_health
```

**Solutions:**

#### Caddy not running
```bash
docker ps | grep caddy
docker restart caddy
```

#### Firewall blocking
```bash
# Check firewall
ufw status

# Open ports
ufw allow 80/tcp
ufw allow 443/tcp
```

#### Wrong hostname in config
```bash
cat /pds/pds.env | grep HOSTNAME
# Should match your actual domain
```

### WebSocket connection fails

**Test WebSocket:**
```bash
# Install wsdump
pip3 install websocket-client

# Test connection
wsdump "wss://yourdomain.com/xrpc/com.atproto.sync.subscribeRepos?cursor=0"
```

**Common causes:**
1. Cloudflare proxy enabled (must be DNS only)
2. Firewall blocking WebSocket upgrade
3. Caddy misconfiguration

---

## Account Issues

### Can't create account

**Check PDS is running:**
```bash
systemctl status pds
curl https://yourdomain.com/xrpc/_health
```

**Try verbose mode:**
```bash
sudo pdsadmin account create --verbose
```

**Common issues:**

#### Invalid handle
- Must be lowercase
- No spaces or special characters
- 3-20 characters

#### Email already used
- Each email can only be used once
- Use different email or delete old account

#### Database locked
```bash
# Check database permissions
ls -la /pds/accounts.sqlite

# Should be readable/writable
chmod 644 /pds/accounts.sqlite
```

### Can't login to existing account

**From Bluesky app:**
1. Verify you're using correct PDS URL
2. Check username and password
3. Try password reset (if email configured)

**From server:**
```bash
# List accounts
sqlite3 /pds/accounts.sqlite "SELECT handle FROM actors;"

# Verify account exists
```

### Password reset not working

**Check email configuration:**
```bash
cat /pds/pds.env | grep EMAIL
```

**Test email:**
```bash
# Check logs for SMTP errors
journalctl -u pds | grep -i smtp
journalctl -u pds | grep -i email
```

See [Email Setup guide](email-setup.md) for email troubleshooting.

---

## Email Issues

### Emails not sending

**Check configuration:**
```bash
cat /pds/pds.env | grep EMAIL

# Should have:
# PDS_EMAIL_SMTP_URL=smtps://...
# PDS_EMAIL_FROM_ADDRESS=...
```

**Check logs:**
```bash
journalctl -u pds -f

# Trigger email (create account or reset password)
# Watch for SMTP errors
```

**Common issues:**

#### Authentication failed
- Wrong username/password
- Need to URL encode special characters
- Wrong SMTP host/port

#### Connection timeout
- Firewall blocking outbound SMTP (port 465/587)
- Wrong SMTP server address

#### TLS/SSL errors
- Try different scheme (`smtps://` vs `smtp+starttls://`)
- Try different port (465 vs 587)

### Emails going to spam

**Solutions:**
1. Use dedicated email service (Resend, SendGrid)
2. Set up SPF record in DNS
3. Set up DKIM record in DNS
4. Verify domain with email provider

---

## Performance Issues

### Slow response times

**Check resource usage:**
```bash
# Overall system
htop

# Docker containers
docker stats

# Disk I/O
iotop
```

**Common causes:**

#### High CPU usage
- Too many users for server size
- Upgrade server or limit users

#### High memory usage
- Restart PDS to clear memory
- Upgrade RAM

#### Slow disk I/O
- Upgrade to SSD (if on HDD)
- Add more disk space
- Use faster storage tier

### Database issues

**Optimize database:**
```bash
# Vacuum to reclaim space
sqlite3 /pds/accounts.sqlite "VACUUM;"

# Check integrity
sqlite3 /pds/accounts.sqlite "PRAGMA integrity_check;"
```

### High bandwidth usage

**Check media storage:**
```bash
du -sh /pds/blocks/
```

Large media files from posts can use significant bandwidth.

**Solution:**
- Set up CDN (advanced)
- Limit user count
- Upgrade bandwidth allocation

---

## Update Issues

### Update fails

**Check Docker:**
```bash
systemctl status docker
docker version
```

**Try manual update:**
```bash
cd /pds
docker compose pull
docker compose down
docker compose up -d
```

**Check logs:**
```bash
journalctl -u pds -n 100
```

### Service won't start after update

**Check configuration:**
```bash
# Validate compose file
cd /pds
docker compose config

# Check for syntax errors
cat /pds/pds.env
```

**Rollback if needed:**
```bash
# Edit compose.yaml
nano /pds/compose.yaml

# Change to previous version
# image: ghcr.io/bluesky-social/pds:0.3.5

docker compose up -d
```

---

## Data Issues

### Lost data / corrupted database

**Check database:**
```bash
sqlite3 /pds/accounts.sqlite "PRAGMA integrity_check;"
```

**Restore from backup:**
```bash
systemctl stop pds
cp /root/backups/YYYYMMDD/accounts.sqlite /pds/accounts.sqlite
systemctl start pds
```

### Disk full

**Check usage:**
```bash
df -h
du -sh /pds/*
```

**Free up space:**
```bash
# Clean Docker
docker system prune -a

# Remove old logs
journalctl --vacuum-time=7d

# Remove old backups
rm -rf /root/backups/old-date/
```

**Upgrade storage:**
1. Resize droplet in DigitalOcean
2. Or add block storage volume

---

## Docker Issues

### Containers not running

**Check containers:**
```bash
docker ps -a
```

**Start containers:**
```bash
cd /pds
docker compose up -d
```

**Check logs:**
```bash
docker logs pds
docker logs caddy
```

### Docker daemon not responding

**Restart Docker:**
```bash
systemctl restart docker
sleep 5
systemctl restart pds
```

### Image pull fails

**Check internet:**
```bash
ping github.com
```

**Check Docker Hub:**
```bash
docker pull hello-world
```

**Try manual pull:**
```bash
docker pull ghcr.io/bluesky-social/pds:latest
```

---

## Firewall Issues

### Ports not accessible

**Check firewall:**
```bash
ufw status
```

**Should show:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

**Fix firewall:**
```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### Cloud provider firewall

**DigitalOcean:**
1. Go to Networking → Firewalls
2. Ensure inbound rules allow:
   - TCP 22 (SSH)
   - TCP 80 (HTTP)
   - TCP 443 (HTTPS)

---

## Advanced Debugging

### Enable debug logging

```bash
# Edit config
nano /pds/pds.env

# Add or change
LOG_LEVEL=debug

# Restart
systemctl restart pds
```

### Check detailed logs

```bash
# All logs
journalctl -u pds --no-pager

# Follow logs in real-time
journalctl -u pds -f

# Only errors
journalctl -u pds -p err

# Logs from last hour
journalctl -u pds --since "1 hour ago"
```

### Network diagnostics

```bash
# Check listening ports
netstat -tulpn

# Check connections
ss -tunap

# Test HTTPS
curl -v https://yourdomain.com/xrpc/_health

# Test from outside
curl -v https://yourdomain.com/xrpc/_health --resolve yourdomain.com:443:YOUR_IP
```

---

## Getting Help

If you can't resolve the issue:

1. **Gather information:**
   ```bash
   # System info
   uname -a
   
   # PDS version
   curl https://yourdomain.com/xrpc/_health
   
   # Logs
   journalctl -u pds -n 100 > pds-logs.txt
   
   # Docker status
   docker ps -a > docker-status.txt
   ```

2. **Check resources:**
   - [GitHub Issues](https://github.com/bluesky-social/pds/issues)
   - [AT Protocol Docs](https://atproto.com)
   - This troubleshooting guide

3. **Ask for help:**
   - [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)
   - Include error messages, logs, and what you've tried

---

## Common Error Messages

### "Failed to start pds.service"

Check logs: `journalctl -u pds -n 50`

Usually Docker or configuration issue.

### "Certificate verification failed"

DNS not properly configured or Caddy can't get certificate.

Check: DNS records, port 80 accessibility, domain ownership.

### "Database is locked"

Another process is using the database.

Solution: Restart PDS or check for zombie processes.

### "Connection refused"

Service not running or firewall blocking.

Check: `systemctl status pds`, `ufw status`

### "Out of memory"

Server ran out of RAM.

Solution: Restart PDS, upgrade server RAM.

---

**Back to:** [Maintenance →](maintenance.md) | [Main README →](../README.md)
