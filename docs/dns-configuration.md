# DNS Configuration

Configure your domain's DNS records to point to your DigitalOcean server.

## Overview

You need to create two A records:
1. **Root domain** (`yourdomain.com`) → Your server IP
2. **Wildcard** (`*.yourdomain.com`) → Your server IP

The wildcard allows user subdomains like `@alice.yourdomain.com`.

## Requirements

- Your domain name
- Your server's IPv4 address from DigitalOcean
- Access to your domain's DNS settings

---

## Squarespace DNS

If your domain is registered with Squarespace (formerly Google Domains):

### Step 1: Access DNS Settings

1. Log in to [Squarespace Domains](https://domains.squarespace.com/)
2. Click on your domain (e.g., `yourdomain.com`)
3. Click **DNS Settings** or **Advanced DNS**

### Step 2: Add A Records

Click **Add Record** and create these two records:

#### Record 1: Root Domain
| Field | Value |
|-------|-------|
| Type | `A` |
| Host | `@` |
| Points to | `142.93.123.45` (your server IP) |
| TTL | `600` (10 minutes) |

#### Record 2: Wildcard
| Field | Value |
|-------|-------|
| Type | `A` |
| Host | `*` |
| Points to | `142.93.123.45` (your server IP) |
| TTL | `600` |

### Step 3: Remove Conflicting Records

**Important:** Delete any existing A records for `@` or `*` that point elsewhere.

Common conflicts:
- A record for `@` pointing to old server
- CNAME record for `www`
- Forwarding rules

### Step 4: Save Changes

Click **Save** or **Apply Changes**

---

## Namecheap DNS

### Step 1: Access DNS Settings

1. Log in to [Namecheap](https://namecheap.com)
2. Go to **Domain List**
3. Click **Manage** next to your domain
4. Go to **Advanced DNS** tab

### Step 2: Add A Records

Click **Add New Record**:

#### Record 1: Root Domain
| Type | Host | Value | TTL |
|------|------|-------|-----|
| `A Record` | `@` | `142.93.123.45` | `600` |

#### Record 2: Wildcard
| Type | Host | Value | TTL |
|------|------|-------|-----|
| `A Record` | `*` | `142.93.123.45` | `600` |

### Step 3: Save Changes

Click the green checkmark to save each record.

---

## Cloudflare DNS

### Step 1: Access DNS Settings

1. Log in to [Cloudflare](https://cloudflare.com)
2. Select your domain
3. Go to **DNS** → **Records**

### Step 2: Add A Records

Click **Add record**:

#### Record 1: Root Domain
| Type | Name | IPv4 address | Proxy status | TTL |
|------|------|--------------|--------------|-----|
| `A` | `@` | `142.93.123.45` | DNS only (gray cloud) | Auto |

#### Record 2: Wildcard
| Type | Name | IPv4 address | Proxy status | TTL |
|------|------|--------------|--------------|-----|
| `A` | `*` | `142.93.123.45` | DNS only (gray cloud) | Auto |

**Important:** Click the orange cloud to turn it gray (DNS only). Proxying through Cloudflare will break the PDS.

### Step 3: Save

Click **Save** for each record.

---

## GoDaddy DNS

### Step 1: Access DNS Settings

1. Log in to [GoDaddy](https://godaddy.com)
2. Go to **My Products**
3. Click **DNS** next to your domain

### Step 2: Add A Records

Click **Add** under DNS Records:

#### Record 1: Root Domain
| Type | Name | Value | TTL |
|------|------|-------|-----|
| `A` | `@` | `142.93.123.45` | `600 seconds` |

#### Record 2: Wildcard
| Type | Name | Value | TTL |
|------|------|-------|-----|
| `A` | `*` | `142.93.123.45` | `600 seconds` |

### Step 3: Save

Click **Save** at the bottom.

---

## Google Domains (Now Squarespace)

Google Domains was acquired by Squarespace. Follow the [Squarespace DNS](#squarespace-dns) instructions above.

---

## DigitalOcean DNS (Alternative)

You can also use DigitalOcean's nameservers:

### Step 1: Add Domain to DigitalOcean

1. In DigitalOcean, go to **Networking** → **Domains**
2. Enter your domain name
3. Click **Add Domain**

### Step 2: Create DNS Records

DigitalOcean will ask you to create records:

1. **A record:** `@` → Select your droplet
2. **A record:** `*` → Enter your droplet IP manually

### Step 3: Update Nameservers

At your domain registrar, change nameservers to:
```
ns1.digitalocean.com
ns2.digitalocean.com
ns3.digitalocean.com
```

**Note:** Nameserver changes can take 24-48 hours to propagate.

---

## Verify DNS Configuration

### Using Command Line

Wait 5-10 minutes after making DNS changes, then test:

```bash
# Test root domain
dig yourdomain.com +short
# Should return: 142.93.123.45

# Test wildcard
dig test.yourdomain.com +short
# Should return: 142.93.123.45

# Test any subdomain
dig random.yourdomain.com +short
# Should return: 142.93.123.45
```

### Using Online Tools

Visit these websites and enter your domain:

- [whatsmydns.net](https://whatsmydns.net) - Check global DNS propagation
- [dnschecker.org](https://dnschecker.org) - Check DNS from multiple locations
- [mxtoolbox.com](https://mxtoolbox.com/DNSLookup.aspx) - DNS lookup tool

### Using nslookup (Windows/Mac)

```bash
nslookup yourdomain.com
nslookup test.yourdomain.com
```

Both should return your server IP.

---

## DNS Propagation Time

| Provider | Typical Time |
|----------|--------------|
| Cloudflare | 1-5 minutes |
| DigitalOcean | 5-10 minutes |
| Namecheap | 10-30 minutes |
| Squarespace | 10-30 minutes |
| GoDaddy | 10-60 minutes |

**Note:** Setting TTL to 600 (10 minutes) speeds up propagation.

---

## Common Issues

### DNS not resolving

**Check:**
1. Records were saved correctly
2. Correct IP address was entered
3. No typos in domain name
4. Enough time has passed (wait 15-30 minutes)

### Wildcard not working

**Check:**
1. Wildcard record exists (`*`)
2. No conflicting CNAME records
3. Using DNS only (not proxied on Cloudflare)

### Still using old IP

**Solution:**
```bash
# Clear local DNS cache

# macOS
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Windows
ipconfig /flushdns

# Linux
sudo systemd-resolve --flush-caches
```

---

## Example Configuration Summary

For domain `example.com` with server IP `142.93.123.45`:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | `@` | `142.93.123.45` | 600 |
| A | `*` | `142.93.123.45` | 600 |

This allows:
- `example.com` → PDS server
- `alice.example.com` → Alice's handle
- `bob.example.com` → Bob's handle
- `anything.example.com` → All resolve to server

---

## Next Steps

Once DNS is configured and verified:

✅ Root domain resolves to your server  
✅ Wildcard subdomains resolve to your server  
✅ Changes have propagated globally  

**Next:** [Install PDS →](installation.md)

---

**Need help?** Join the [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)
