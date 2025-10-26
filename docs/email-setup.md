# Email/SMTP Setup

Configure email functionality for your PDS to send verification emails, password resets, and notifications.

## Why Set Up Email?

Email is **optional** but highly recommended for:
- ✉️ Email verification for new accounts
- 🔐 Password reset functionality
- 📧 Account notifications
- 👥 Invite code delivery

**You can skip this initially** and add it later.

---

## Option 1: Email Service (Recommended)

Use a dedicated email service provider. Most have generous free tiers.

### Recommended Services

| Service | Free Tier | Best For |
|---------|-----------|----------|
| [Resend](https://resend.com) | 3,000/month | Easy setup, modern |
| [SendGrid](https://sendgrid.com) | 100/day | Established, reliable |
| [Mailgun](https://mailgun.com) | 5,000/month | Flexible, good docs |
| [Postmark](https://postmarkapp.com) | 100/month | High deliverability |
| [Amazon SES](https://aws.amazon.com/ses/) | 3,000/month* | AWS users |

*Free tier requires AWS account

---

## Setup: Resend (Recommended)

### Step 1: Create Resend Account

1. Go to [resend.com](https://resend.com)
2. Sign up for free account
3. Verify your email

### Step 2: Add Domain (Optional)

For better deliverability:

1. Go to **Domains** → **Add Domain**
2. Enter your domain (e.g., `yourdomain.com`)
3. Add the DNS records they provide:
   ```
   TXT  resend._domainkey  [provided value]
   ```
4. Verify domain

**OR** skip domain verification and use Resend's domain (faster, less deliverability).

### Step 3: Create API Key

1. Go to **API Keys** → **Create API Key**
2. Name it: `PDS Server`
3. Permission: **Sending access**
4. Click **Create**
5. **Copy the API key** (starts with `re_`)

Example: `re_123abc456def789`

### Step 4: Configure PDS

SSH to your server:

```bash
ssh root@yourdomain.com
```

Edit the PDS configuration:

```bash
sudo nano /pds/pds.env
```

Add these lines (or update if they exist):

```bash
PDS_EMAIL_SMTP_URL=smtps://resend:re_YOUR_API_KEY_HERE@smtp.resend.com:465/
PDS_EMAIL_FROM_ADDRESS=noreply@yourdomain.com
```

**Replace:**
- `re_YOUR_API_KEY_HERE` with your actual API key
- `yourdomain.com` with your domain

**Note:** Keep `resend:` as the username. The format is `resend:API_KEY`.

### Step 5: Restart PDS

```bash
sudo systemctl restart pds
```

### Step 6: Test Email

Create a test account or use password reset to verify emails are sending.

---

## Setup: SendGrid

### Step 1: Create SendGrid Account

1. Go to [sendgrid.com](https://sendgrid.com)
2. Sign up for free account
3. Complete sender verification

### Step 2: Create API Key

1. Go to **Settings** → **API Keys**
2. Click **Create API Key**
3. Name: `PDS Server`
4. Permission: **Restricted Access** → **Mail Send** (Full Access)
5. Click **Create & View**
6. **Copy the API key** (starts with `SG.`)

### Step 3: Configure PDS

```bash
sudo nano /pds/pds.env
```

Add:
```bash
PDS_EMAIL_SMTP_URL=smtps://apikey:SG.YOUR_API_KEY_HERE@smtp.sendgrid.net:465/
PDS_EMAIL_FROM_ADDRESS=noreply@yourdomain.com
```

**Important:** Username is literally `apikey` (not your SendGrid username).

### Step 4: Restart

```bash
sudo systemctl restart pds
```

---

## Setup: Mailgun

### Step 1: Create Mailgun Account

1. Go to [mailgun.com](https://mailgun.com)
2. Sign up for free account
3. Verify your email

### Step 2: Get SMTP Credentials

1. Go to **Sending** → **Domain Settings**
2. Click on your domain
3. Find **SMTP Credentials** section
4. Note the username and password

### Step 3: Configure PDS

```bash
sudo nano /pds/pds.env
```

Add:
```bash
PDS_EMAIL_SMTP_URL=smtps://USERNAME:PASSWORD@smtp.mailgun.org:465/
PDS_EMAIL_FROM_ADDRESS=noreply@yourdomain.com
```

Replace `USERNAME` and `PASSWORD` with your Mailgun SMTP credentials.

### Step 4: Restart

```bash
sudo systemctl restart pds
```

---

## Option 2: Gmail (Simple but Limited)

Use your Gmail account. **Not recommended for production** (daily limits, security concerns).

### Enable App Passwords

1. Go to [myaccount.google.com](https://myaccount.google.com)
2. **Security** → **2-Step Verification** (enable if not already)
3. **Security** → **App passwords**
4. Create app password for "Mail"
5. Copy the 16-character password

### Configure PDS

```bash
sudo nano /pds/pds.env
```

Add:
```bash
PDS_EMAIL_SMTP_URL=smtps://your.email@gmail.com:APP_PASSWORD@smtp.gmail.com:465/
PDS_EMAIL_FROM_ADDRESS=your.email@gmail.com
```

**Replace:**
- `your.email@gmail.com` with your Gmail address
- `APP_PASSWORD` with the 16-character app password (no spaces)

### Restart

```bash
sudo systemctl restart pds
```

**Limitations:**
- 500 emails/day limit
- May be flagged as spam
- Less professional

---

## Option 3: Local SMTP Server

If you have Postfix or Exim running locally:

```bash
sudo nano /pds/pds.env
```

Add:
```bash
PDS_EMAIL_SMTP_URL=smtp:///?sendmail=true
PDS_EMAIL_FROM_ADDRESS=noreply@yourdomain.com
```

This uses the local sendmail interface.

**Prerequisites:**
- Postfix/Exim must be installed and configured
- SPF/DKIM records configured
- Server not on any blacklists

---

## Configuration Reference

### SMTP URL Format

```
scheme://[username:password@]host[:port][/path][?query]
```

**Schemes:**
- `smtp://` - Plain SMTP (port 25 or 587)
- `smtps://` - SMTP over TLS (port 465)
- `smtp+starttls://` - SMTP with STARTTLS (port 587)

### Common Ports

| Port | Type | Usage |
|------|------|-------|
| 25 | SMTP | Traditional, often blocked |
| 465 | SMTPS | SMTP over TLS (recommended) |
| 587 | Submission | SMTP with STARTTLS |

### Examples

**Resend:**
```bash
PDS_EMAIL_SMTP_URL=smtps://resend:re_abc123@smtp.resend.com:465/
```

**SendGrid:**
```bash
PDS_EMAIL_SMTP_URL=smtps://apikey:SG.abc123@smtp.sendgrid.net:465/
```

**Mailgun:**
```bash
PDS_EMAIL_SMTP_URL=smtps://user@domain.com:password@smtp.mailgun.org:465/
```

**Office 365:**
```bash
PDS_EMAIL_SMTP_URL=smtp+starttls://user@domain.com:password@smtp.office365.com:587/
```

**Custom SMTP with port 587:**
```bash
PDS_EMAIL_SMTP_URL=smtp+starttls://username:password@mail.example.com:587/
```

---

## URL Encoding Special Characters

If your password contains special characters, they must be **percent-encoded**:

| Character | Encoded |
|-----------|---------|
| `@` | `%40` |
| `:` | `%3A` |
| `/` | `%2F` |
| `?` | `%3F` |
| `#` | `%23` |
| `&` | `%26` |
| `=` | `%3D` |
| `+` | `%2B` |
| ` ` (space) | `%20` |

### Example

Password: `my:p@ss/word`  
Encoded: `my%3Ap%40ss%2Fword`

Full URL:
```bash
PDS_EMAIL_SMTP_URL=smtps://user%40example.com:my%3Ap%40ss%2Fword@smtp.example.com:465/
```

---

## Testing Email

### Method 1: Create Test Account

```bash
sudo pdsadmin account create
```

Use a real email address you can access. You should receive a verification email.

### Method 2: Password Reset

1. Go to Bluesky app
2. Click "Forgot password"
3. Enter email
4. Check for reset email

### Method 3: Check Logs

```bash
# Check for SMTP errors
journalctl -u pds -n 50 | grep -i email
journalctl -u pds -n 50 | grep -i smtp
```

---

## Troubleshooting

### No emails being sent

**Check configuration:**
```bash
cat /pds/pds.env | grep EMAIL
```

**Check PDS logs:**
```bash
journalctl -u pds -f
```

Try sending test email and watch for errors.

### Authentication failed

**Common issues:**
1. Wrong username/password
2. Special characters not URL-encoded
3. Wrong SMTP host/port
4. API key instead of password (or vice versa)

**Fix:** Double-check credentials and URL encoding.

### Emails going to spam

**Solutions:**
1. Verify domain with email provider
2. Set up SPF record
3. Set up DKIM record
4. Use dedicated email service (not Gmail)

### SSL/TLS errors

**Try different scheme:**
```bash
# Instead of smtps://
PDS_EMAIL_SMTP_URL=smtp+starttls://...
```

Or different port:
```bash
# Try port 587 instead of 465
```

---

## Email Records for Better Deliverability

Add these DNS records to improve email deliverability:

### SPF Record

```
TXT  @  v=spf1 include:_spf.resend.com ~all
```

(Replace with your email provider's SPF record)

### DKIM Record

Your email provider will give you a DKIM record to add:

```
TXT  resend._domainkey  [provided value]
```

### DMARC Record (Optional)

```
TXT  _dmarc  v=DMARC1; p=none; rua=mailto:admin@yourdomain.com
```

---

## Disabling Email

To run PDS without email:

```bash
sudo nano /pds/pds.env
```

Comment out or remove:
```bash
# PDS_EMAIL_SMTP_URL=...
# PDS_EMAIL_FROM_ADDRESS=...
```

Restart:
```bash
sudo systemctl restart pds
```

**Note:** Users won't be able to verify emails or reset passwords.

---

## Next Steps

✅ Email configured  
✅ Test email sent successfully  

**Continue to:**
- [Maintenance & Updates →](maintenance.md)
- [Troubleshooting Guide →](troubleshooting.md)

---

**Need help?** Join [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)
