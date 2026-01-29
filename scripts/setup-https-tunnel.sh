#!/bin/bash

# Quick HTTPS Tunnel for Kong using Cloudflare Tunnel
# This creates a public HTTPS URL for your Kong API

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Setting up HTTPS tunnel for Kong...${NC}"
echo ""

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo -e "${YELLOW}Installing cloudflared...${NC}"
    brew install cloudflared
fi

echo -e "${YELLOW}Starting tunnel to Kong...${NC}"
echo ""
echo "This will create a public HTTPS URL for your Kong API Gateway"
echo "Press Ctrl+C to stop the tunnel"
echo ""

# Get Kong service dynamically
echo -e "${YELLOW}Getting Kong LoadBalancer URL...${NC}"
KONG_HOST=$(kubectl get svc -n gateway kong -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$KONG_HOST" ]; then
    echo -e "${YELLOW}Error: Could not get Kong LoadBalancer URL${NC}"
    echo "Make sure Kong is deployed in the 'gateway' namespace"
    exit 1
fi

KONG_URL="${KONG_HOST}:8000"
echo -e "${GREEN}Kong URL: http://$KONG_URL${NC}"
echo ""

# Start tunnel
cloudflared tunnel --url http://$KONG_URL

# The tunnel URL will be displayed in the output
# Use that URL in your Vercel environment variables
