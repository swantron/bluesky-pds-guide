# Example DNS Records

This file shows example DNS configurations for different providers.

## For domain: `example.com` with server IP: `142.93.123.45`

---

## Standard Format

| Type | Host/Name | Value/Points To | TTL |
|------|-----------|-----------------|-----|
| A | @ | 142.93.123.45 | 600 |
| A | * | 142.93.123.45 | 600 |

---

## Squarespace / Google Domains

```
Type: A
Host: @
Points to: 142.93.123.45
TTL: 600

Type: A
Host: *
Points to: 142.93.123.45
TTL: 600
```

---

## Namecheap

```
Type: A Record
Host: @
Value: 142.93.123.45
TTL: 600

Type: A Record
Host: *
Value: 142.93.123.45
TTL: 600
```

---

## Cloudflare

**Important:** Disable proxy (gray cloud)

```
Type: A
Name: @
IPv4 address: 142.93.123.45
Proxy status: DNS only (gray cloud)
TTL: Auto

Type: A
Name: *
IPv4 address: 142.93.123.45
Proxy status: DNS only (gray cloud)
TTL: Auto
```

---

## GoDaddy

```
Type: A
Name: @
Value: 142.93.123.45
TTL: 600 seconds

Type: A
Name: *
Value: 142.93.123.45
TTL: 600 seconds
```

---

## DigitalOcean DNS

```
Type: A
Hostname: @
Will Direct To: Select your droplet
TTL: 600

Type: A
Hostname: *
Will Direct To: 142.93.123.45 (enter manually)
TTL: 600
```

---

## Route53 (AWS)

```json
{
  "Name": "example.com",
  "Type": "A",
  "TTL": 600,
  "ResourceRecords": [
    {
      "Value": "142.93.123.45"
    }
  ]
}
```

```json
{
  "Name": "*.example.com",
  "Type": "A",
  "TTL": 600,
  "ResourceRecords": [
    {
      "Value": "142.93.123.45"
    }
  ]
}
```

---

## What These Records Do

### Root Domain (`@` or `example.com`)
Points `example.com` to your server. This is where your PDS lives.

### Wildcard (`*` or `*.example.com`)
Points all subdomains to your server:
- `alice.example.com` → Your server
- `bob.example.com` → Your server
- `anything.example.com` → Your server

This allows user handles like `@alice.example.com`.

---

## Verification

After adding these records, verify with:

```bash
# Check root domain
dig example.com +short
# Should return: 142.93.123.45

# Check wildcard
dig test.example.com +short
# Should return: 142.93.123.45

# Check any subdomain
dig randomname.example.com +short
# Should return: 142.93.123.45
```

Or use online tools:
- https://whatsmydns.net
- https://dnschecker.org

---

## Troubleshooting

### Not resolving yet
- Wait 5-15 minutes for DNS propagation
- Check for typos in records
- Verify TTL is set to 600 (10 minutes)

### Wrong IP returned
- Double-check IP address in records
- Clear local DNS cache
- Check you're querying the right domain

### Wildcard not working
- Ensure wildcard record (`*`) exists
- Remove conflicting CNAME records
- Some providers use different wildcard syntax

---

## Optional: Email Records

If you're using a dedicated email service like Resend:

### SPF Record
```
Type: TXT
Host: @
Value: v=spf1 include:_spf.resend.com ~all
TTL: 600
```

### DKIM Record
```
Type: TXT
Host: resend._domainkey
Value: [Provided by your email service]
TTL: 600
```

### DMARC Record
```
Type: TXT
Host: _dmarc
Value: v=DMARC1; p=none; rua=mailto:admin@example.com
TTL: 600
```

---

**Back to:** [DNS Configuration Guide](../docs/dns-configuration.md)
