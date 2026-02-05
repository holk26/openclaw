# OpenClaw - Dokploy Deployment

Deploy OpenClaw on your VPS using Dokploy with automatic SSL via Traefik.

## Quick Start

### Prerequisites

- VPS with Dokploy installed ([installation guide](https://docs.dokploy.com/get-started/introduction))
- Domain name pointing to your VPS
- AI provider credentials (Claude, OpenAI, or Anthropic)

### Deployment Steps

1. **Clone or download this repository**

2. **Run the setup script** (optional - helps configure environment):
   ```bash
   ./scripts/dokploy-setup.sh
   ```
   
   Or manually copy the environment template:
   ```bash
   cp .env.dokploy .env
   ```

3. **Configure environment variables**:
   ```bash
   # Edit .env file
   OPENCLAW_DOMAIN=openclaw.yourdomain.com
   OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)
   
   # Add your AI provider keys
   CLAUDE_AI_SESSION_KEY=your-key
   # OR
   OPENAI_API_KEY=your-key
   ```

4. **Deploy in Dokploy**:
   - Go to Dokploy dashboard
   - Create new "Compose" project
   - Upload `docker-compose.dokploy.yml`
   - Add environment variables from `.env`
   - Click "Deploy"

5. **Access OpenClaw**:
   ```
   https://openclaw.yourdomain.com
   ```

## Files Included

- `docker-compose.dokploy.yml` - Docker Compose configuration with Traefik labels
- `dokploy.json` - Dokploy template for one-click deployment
- `.env.dokploy` - Environment variable template
- `docs/platforms/dokploy.md` - Comprehensive deployment guide

## Required Environment Variables

| Variable | Description |
|----------|-------------|
| `OPENCLAW_DOMAIN` | Your domain (e.g., openclaw.example.com) |
| `OPENCLAW_GATEWAY_TOKEN` | Secure random token for authentication |
| `CLAUDE_AI_SESSION_KEY` or `OPENAI_API_KEY` | AI provider credentials |

## Features

✅ Automatic HTTPS with Let's Encrypt  
✅ HTTP to HTTPS redirect  
✅ Traefik reverse proxy integration  
✅ Persistent volumes for config and workspace  
✅ Production-ready configuration  
✅ Easy environment management  

## Documentation

- [Full Dokploy Deployment Guide](docs/platforms/dokploy.md)
- [OpenClaw Documentation](https://docs.openclaw.ai)
- [VPS Hosting Options](https://docs.openclaw.ai/vps)

## Support

- [Discord Community](https://discord.gg/clawd)
- [GitHub Issues](https://github.com/openclaw/openclaw/issues)
- [Documentation](https://docs.openclaw.ai)

## Security Notes

- Always use strong, randomly generated tokens
- Never commit `.env` files with secrets
- Keep your AI provider keys secure
- Regular backups recommended

## License

MIT License - see [LICENSE](LICENSE) file for details.
