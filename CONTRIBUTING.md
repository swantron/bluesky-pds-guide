# Contributing to Bluesky PDS Guide

Thanks for your interest in improving this guide! This document is designed to help people self-host their own Bluesky PDS servers.

## How to Contribute

### Found an Issue?

If you notice:
- Outdated information
- Broken links
- Typos or unclear instructions
- Missing steps

Please [open an issue](https://github.com/yourusername/bluesky-pds-guide/issues/new) describing the problem.

### Want to Improve the Guide?

1. **Fork the repository**
2. **Create a branch** for your changes
   ```bash
   git checkout -b improve-dns-docs
   ```
3. **Make your changes**
4. **Test if applicable** (especially for scripts)
5. **Commit with a clear message**
   ```bash
   git commit -m "Add Cloudflare DNS configuration examples"
   ```
6. **Push and create a Pull Request**

## What We're Looking For

### Documentation Improvements
- Clarifying confusing sections
- Adding more examples
- Better explanations for beginners
- Screenshots or diagrams
- Additional troubleshooting tips

### New Sections
- Alternative VPS providers
- Different DNS providers
- Advanced configurations
- Migration guides
- Performance optimization

### Scripts and Tools
- Helpful automation scripts
- DNS verification tools
- Backup helpers
- Monitoring solutions

## Style Guidelines

### Writing Style
- **Clear and concise** - Assume readers are technical but new to PDS
- **Step-by-step** - Number steps, use code blocks
- **Test your instructions** - Make sure they actually work
- **Include examples** - Real-world examples help

### Code Blocks
Always specify the language:

````markdown
```bash
sudo systemctl restart pds
```
````

### Command Prompts
Don't include `$` or `#` in commands (easier to copy-paste):

**Good:**
```bash
systemctl status pds
```

**Avoid:**
```bash
$ systemctl status pds
```

### File Paths
Use absolute paths and make them clear:

```bash
# Edit PDS configuration
sudo nano /pds/pds.env
```

## Testing Changes

### Documentation Changes
- Read through your changes
- Check all links work
- Verify code blocks format correctly
- Ensure markdown renders properly

### Script Changes
Test scripts before submitting:
```bash
# Test the DNS verification script
./scripts/verify-dns.sh example.com
```

## Commit Messages

Use clear, descriptive commit messages:

**Good:**
- `Add DigitalOcean firewall setup instructions`
- `Fix broken link to AT Protocol docs`
- `Update email setup for Resend changes`

**Avoid:**
- `fix stuff`
- `update`
- `changes`

## Pull Request Process

1. **Describe your changes** - What and why
2. **Reference issues** - If fixing an issue, mention it
3. **Keep it focused** - One PR per topic
4. **Be responsive** - Address review feedback

## What to Avoid

- Don't add promotional content
- Don't make breaking changes without discussion
- Don't copy copyrighted content
- Don't include credentials or secrets

## Questions?

Not sure about something? Feel free to:
- Open an issue to discuss
- Ask in the [AT Protocol Discord](https://discord.gg/e7hpHxRfBP)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make this guide better! 🎉
