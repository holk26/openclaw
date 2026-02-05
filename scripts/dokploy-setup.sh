#!/bin/bash
set -euo pipefail

# OpenClaw Dokploy Setup Script
# This script helps you prepare OpenClaw for Dokploy deployment

echo "🦞 OpenClaw - Dokploy Setup"
echo "============================"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo "⚠️  Warning: .env file already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting. Please backup your existing .env file first."
        exit 1
    fi
fi

# Copy template
cp .env.dokploy .env
echo "✓ Created .env from template"

# Prompt for domain
read -p "Enter your domain (e.g., openclaw.yourdomain.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "❌ Domain is required"
    exit 1
fi

# Generate secure token
TOKEN=$(openssl rand -hex 32)
echo "✓ Generated secure gateway token"

# Update .env file
sed -i.bak "s/OPENCLAW_DOMAIN=.*/OPENCLAW_DOMAIN=$DOMAIN/" .env
sed -i.bak "s/OPENCLAW_GATEWAY_TOKEN=.*/OPENCLAW_GATEWAY_TOKEN=$TOKEN/" .env
rm .env.bak 2>/dev/null || true
echo "✓ Updated .env with your domain and token"

echo ""
echo "📋 Next steps:"
echo ""
echo "1. Edit .env and add your AI provider credentials:"
echo "   - CLAUDE_AI_SESSION_KEY (for Claude)"
echo "   - OPENAI_API_KEY (for OpenAI)"
echo "   - ANTHROPIC_API_KEY (for Anthropic API)"
echo ""
echo "2. In Dokploy dashboard:"
echo "   - Create new 'Compose' project"
echo "   - Upload docker-compose.dokploy.yml"
echo "   - Add environment variables from .env"
echo "   - Click 'Deploy'"
echo ""
echo "3. Access OpenClaw at: https://$DOMAIN"
echo ""
echo "Your gateway token: $TOKEN"
echo "(This token is saved in .env - keep it secure!)"
echo ""
echo "📚 Full documentation: docs/platforms/dokploy.md"
echo "🔗 OpenClaw docs: https://docs.openclaw.ai"
