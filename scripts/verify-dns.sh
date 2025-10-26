#!/bin/bash

# DNS Verification Script for Bluesky PDS
# This script checks if your DNS is properly configured for running a PDS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================="
echo "Bluesky PDS DNS Verification Script"
echo "=================================="
echo ""

# Check if domain argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <your-domain.com>"
    echo "Example: $0 example.com"
    exit 1
fi

DOMAIN=$1
echo "Checking DNS for: $DOMAIN"
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Check if dig is installed
if ! command -v dig &> /dev/null; then
    echo -e "${YELLOW}Warning: 'dig' command not found. Installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "On macOS, dig should be pre-installed. Please check your system."
        exit 1
    else
        sudo apt-get update && sudo apt-get install -y dnsutils
    fi
fi

# 1. Check root domain A record
echo "1. Checking root domain ($DOMAIN)..."
ROOT_IP=$(dig +short $DOMAIN A | head -n1)

if [ -z "$ROOT_IP" ]; then
    print_status 1 "Root domain does not resolve"
    ROOT_OK=0
else
    print_status 0 "Root domain resolves to: $ROOT_IP"
    ROOT_OK=1
fi
echo ""

# 2. Check wildcard subdomain
echo "2. Checking wildcard subdomain (*.${DOMAIN})..."
TEST_SUBDOMAIN="test-$(date +%s).${DOMAIN}"
WILDCARD_IP=$(dig +short $TEST_SUBDOMAIN A | head -n1)

if [ -z "$WILDCARD_IP" ]; then
    print_status 1 "Wildcard subdomain does not resolve"
    WILDCARD_OK=0
else
    print_status 0 "Wildcard resolves to: $WILDCARD_IP"
    WILDCARD_OK=1
fi
echo ""

# 3. Verify both point to same IP
if [ $ROOT_OK -eq 1 ] && [ $WILDCARD_OK -eq 1 ]; then
    echo "3. Verifying root and wildcard point to same IP..."
    if [ "$ROOT_IP" = "$WILDCARD_IP" ]; then
        print_status 0 "Root and wildcard point to same IP"
        IP_MATCH=1
    else
        print_status 1 "Root ($ROOT_IP) and wildcard ($WILDCARD_IP) point to different IPs"
        IP_MATCH=0
    fi
    echo ""
fi

# 4. Check if IP is reachable
if [ $ROOT_OK -eq 1 ]; then
    echo "4. Checking if server is reachable..."
    if ping -c 1 -W 2 $ROOT_IP &> /dev/null; then
        print_status 0 "Server is reachable at $ROOT_IP"
        PING_OK=1
    else
        print_status 1 "Server is not reachable (ping failed)"
        PING_OK=0
    fi
    echo ""
fi

# 5. Check HTTPS endpoint (if server is up)
if [ $ROOT_OK -eq 1 ]; then
    echo "5. Checking HTTPS endpoint..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 https://${DOMAIN}/xrpc/_health 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        print_status 0 "PDS health endpoint is accessible (HTTP $HTTP_CODE)"
        VERSION=$(curl -s https://${DOMAIN}/xrpc/_health 2>/dev/null | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        if [ ! -z "$VERSION" ]; then
            echo "  PDS Version: $VERSION"
        fi
        HTTPS_OK=1
    elif [ "$HTTP_CODE" = "000" ]; then
        print_status 1 "Cannot connect to HTTPS endpoint (connection failed)"
        HTTPS_OK=0
    else
        print_status 1 "HTTPS endpoint returned HTTP $HTTP_CODE"
        HTTPS_OK=0
    fi
    echo ""
fi

# 6. Check for common issues
echo "6. Checking for common issues..."

# Check for CNAME on root
CNAME_CHECK=$(dig +short $DOMAIN CNAME)
if [ ! -z "$CNAME_CHECK" ]; then
    print_status 1 "WARNING: Root domain has CNAME record (should be A record)"
else
    print_status 0 "No conflicting CNAME on root domain"
fi

# Check TTL
TTL=$(dig $DOMAIN A | grep -A1 "ANSWER SECTION" | tail -n1 | awk '{print $2}')
if [ ! -z "$TTL" ]; then
    if [ "$TTL" -le 600 ]; then
        print_status 0 "TTL is ${TTL}s (good for quick updates)"
    else
        echo -e "${YELLOW}!${NC} TTL is ${TTL}s (consider lowering to 600 for faster propagation)"
    fi
fi

echo ""

# Summary
echo "=================================="
echo "Summary"
echo "=================================="

PASSED=0
TOTAL=0

if [ $ROOT_OK -eq 1 ]; then
    ((PASSED++))
fi
((TOTAL++))

if [ $WILDCARD_OK -eq 1 ]; then
    ((PASSED++))
fi
((TOTAL++))

if [ $ROOT_OK -eq 1 ] && [ $WILDCARD_OK -eq 1 ] && [ $IP_MATCH -eq 1 ]; then
    ((PASSED++))
fi
((TOTAL++))

echo "Checks passed: $PASSED/$TOTAL"
echo ""

# Final verdict
if [ $PASSED -eq $TOTAL ]; then
    echo -e "${GREEN}✓ DNS is properly configured for Bluesky PDS!${NC}"
    
    if [ $HTTPS_OK -eq 1 ]; then
        echo -e "${GREEN}✓ PDS is already running and accessible!${NC}"
    else
        echo -e "${YELLOW}→ DNS is ready. You can now install the PDS.${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ DNS configuration needs attention.${NC}"
    echo ""
    echo "Required DNS records:"
    echo "  Type: A    Host: @    Value: <your-server-ip>"
    echo "  Type: A    Host: *    Value: <your-server-ip>"
    echo ""
    echo "See the documentation for your DNS provider:"
    echo "https://github.com/yourusername/bluesky-pds-guide/blob/main/docs/dns-configuration.md"
    exit 1
fi
