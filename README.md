# Bluesky PDS Self-Hosting Guide

A comprehensive guide to self-hosting your own Bluesky Personal Data Server (PDS) on the AT Protocol network.

![AT Protocol](https://img.shields.io/badge/AT%20Protocol-Federated-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## What is this?

This guide walks you through setting up your own **Bluesky PDS** (Personal Data Server), allowing you to:

- 🔐 **Own your data** - Your posts, follows, and content live on your server
- 🌐 **Custom domain handle** - Use `@yourname.yourdomain.com` as your Bluesky handle
- 🤝 **Federate** - Participate in the wider Bluesky/AT Protocol network
- 🎨 **Control your identity** - Full control over your social media presence

## Quick Start

**Requirements:**
- A domain name ($10-15/year)
- A VPS server ($7/month minimum)
- 30 minutes of your time

**Steps:**
1. [Create a DigitalOcean Droplet](docs/digitalocean-setup.md)
2. [Configure DNS Records](docs/dns-configuration.md)
3. [Install PDS](docs/installation.md)
4. [Create Your Account](docs/installation.md#create-account)
5. [Connect Bluesky App](docs/installation.md#connect-app)

## Documentation

### Setup Guides
- [Prerequisites & Requirements](docs/prerequisites.md)
- [DigitalOcean Server Setup](docs/digitalocean-setup.md)
- [DNS Configuration](docs/dns-configuration.md) (Squarespace, Cloudflare, Namecheap)
- [PDS Installation](docs/installation.md)
- [Email/SMTP Setup](docs/email-setup.md)

### Maintenance
- [Updating Your PDS](docs/maintenance.md#updates)
- [Backups](docs/maintenance.md#backups)
- [Troubleshooting](docs/troubleshooting.md)

## What You'll Host

Your PDS includes:
- **Personal Data Server** - Stores your posts, follows, media
- **Domain-based Identity** - Your handle is tied to your domain
- **Automatic TLS** - Caddy handles SSL certificates

You'll use Bluesky's shared infrastructure for:
- **AppView** - Indexes the network
- **Relay** - Aggregates events
- **Feed Generators** - Custom algorithms

## Server Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 1 GB | 2 GB |
| CPU | 1 core | 2 cores |
| Storage | 20 GB SSD | 40 GB SSD |
| OS | Ubuntu 20.04+ | Ubuntu 24.04 |
| Users | 1-20 | 1-50 |

## Cost Estimate

- **Domain**: $10-15/year
- **VPS**: $7-12/month (DigitalOcean, Vultr, Linode)
- **Email (optional)**: Free tier available (Resend, SendGrid)

**Total**: ~$100-110/year

## Architecture

```
┌─────────────────────────────────────────┐
│         Bluesky Network                 │
│  ┌──────────┐  ┌─────────┐  ┌────────┐ │
│  │ AppView  │  │  Relay  │  │ Feeds  │ │
│  └──────────┘  └─────────┘  └────────┘ │
└─────────────────┬───────────────────────┘
                  │ AT Protocol
┌─────────────────▼───────────────────────┐
│          Your PDS Server                │
│  ┌──────────────────────────────────┐   │
│  │  yourdomain.com                  │   │
│  │  ├── Caddy (TLS/HTTPS)          │   │
│  │  ├── PDS Container               │   │
│  │  └── SQLite Database             │   │
│  └──────────────────────────────────┘   │
│                                          │
│  Your Data:                              │
│  - Posts & Media                         │
│  - Follows & Followers                   │
│  - Profile & Settings                    │
└──────────────────────────────────────────┘
```

## Example Handles

Once set up, you and others can create accounts like:
- `@alice.yourdomain.com`
- `@bob.yourdomain.com`
- `@yourname.yourdomain.com`

## Community & Support

- [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)
- [Official PDS Repo](https://github.com/bluesky-social/pds)
- [AT Protocol Docs](https://atproto.com/)
- [Bluesky](https://bsky.app/)

## Contributing

Found an issue or want to improve the guide? PRs welcome!

## License

MIT License - feel free to use and modify this guide.

## Acknowledgments

- Bluesky team for creating the AT Protocol
- The federated social web community

---

**Ready to get started?** → [Prerequisites](docs/prerequisites.md)