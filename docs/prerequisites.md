# Prerequisites

Before setting up your Bluesky PDS, ensure you have the following:

## Required Items

### 1. Domain Name

You **must** have a domain name that you control.

**Why?**
- Bluesky uses domain-based handles (e.g., `@yourname.yourdomain.com`)
- DNS configuration is required for federation
- TLS certificates are automatically provisioned for your domain

**Where to buy:**
- [Namecheap](https://www.namecheap.com/) - $10-15/year
- [Porkbun](https://porkbun.com/) - $8-12/year
- [Cloudflare](https://www.cloudflare.com/products/registrar/) - At-cost pricing
- [Google Domains](https://domains.google/) (now Squarespace)

**Domain types that work:**
- `.com`, `.net`, `.org` - Most common
- `.dev`, `.app`, `.io` - Developer-friendly
- `.xyz`, `.tech` - Budget options
- Any other TLD works fine

### 2. VPS (Virtual Private Server)

A cloud server to run your PDS.

**Minimum Requirements:**
- **RAM**: 1 GB
- **CPU**: 1 core
- **Storage**: 20 GB SSD
- **OS**: Ubuntu 20.04/22.04/24.04 or Debian 11/12
- **Network**: Public IPv4 address

**Recommended Providers:**

| Provider | Plan | RAM | Price | Notes |
|----------|------|-----|-------|-------|
| [DigitalOcean](https://digitalocean.com) | Basic Droplet | 1 GB | $6/mo | Easy setup, good docs |
| [Vultr](https://vultr.com) | Regular | 1 GB | $6/mo | Similar to DO |
| [Linode](https://linode.com) | Nanode | 1 GB | $5/mo | Reliable, cheaper |
| [Hetzner](https://hetzner.com) | CX11 | 2 GB | €4/mo | EU-based, great value |
| [AWS Lightsail](https://aws.amazon.com/lightsail/) | $3.50 | 512 MB | $3.50/mo | Might be tight on RAM |

**For 1-20 users:** 1 GB RAM is sufficient  
**For 20-50 users:** 2 GB RAM recommended

### 3. Email Service (Optional but Recommended)

For email verification and notifications.

**Free Tiers Available:**
- [Resend](https://resend.com/) - 3,000 emails/month free
- [SendGrid](https://sendgrid.com/) - 100 emails/day free
- [Mailgun](https://mailgun.com/) - 5,000 emails/month free
- [Postmark](https://postmarkapp.com/) - 100 emails/month free

You can also use your own SMTP server or skip email initially.

## Technical Knowledge Required

### Basic (Required)
- [ ] Using SSH to connect to a server
- [ ] Basic command line navigation (`cd`, `ls`)
- [ ] Copying and pasting commands

### Intermediate (Helpful)
- [ ] Understanding DNS (A records, wildcards)
- [ ] Basic Linux administration
- [ ] Docker concepts (optional - installer handles this)

**Don't worry!** This guide walks you through each step.

## Checklist

Before proceeding, verify you have:

- [ ] Domain name purchased and DNS accessible
- [ ] VPS account created (DigitalOcean, Vultr, etc.)
- [ ] SSH client installed on your computer
  - macOS/Linux: Built-in Terminal
  - Windows: [PuTTY](https://putty.org/) or [Windows Terminal](https://aka.ms/terminal)
- [ ] Credit card for VPS ($6-12/month)
- [ ] 30-60 minutes of time

## Optional Items

- [ ] Email service account (Resend, SendGrid)
- [ ] Credit card for domain ($10-15/year)
- [ ] Text editor for local config files

## Firewall Requirements

Your VPS firewall must allow:

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH access |
| 80 | TCP | HTTP (TLS verification) |
| 443 | TCP | HTTPS (main application) |

**Note:** The installer will configure this automatically if using Ubuntu's `ufw`.

## Network Requirements

- Public IPv4 address (provided by VPS)
- Ability to configure DNS A records
- No port blocking by ISP (not applicable to VPS)

## Account Setup Time

| Task | Time Required |
|------|---------------|
| Domain purchase | 5 minutes |
| VPS creation | 2 minutes |
| DNS configuration | 5 minutes |
| DNS propagation | 5-15 minutes |
| PDS installation | 10 minutes |
| Account creation | 2 minutes |
| **Total** | **30-45 minutes** |

---

**Next Step:** [DigitalOcean Server Setup →](digitalocean-setup.md)
