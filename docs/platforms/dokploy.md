---
summary: "Deploy OpenClaw on a VPS using Dokploy with Traefik reverse proxy"
read_when:
  - You want to deploy OpenClaw on a VPS using Dokploy
  - You want automated SSL/TLS with Let's Encrypt
  - You want a simple deployment platform with web UI
title: "Dokploy Deployment"
---

# Dokploy Deployment

[Dokploy](https://dokploy.com/) is a self-hosted Platform-as-a-Service (PaaS) that uses Docker and Traefik for easy application deployment. This guide shows you how to deploy OpenClaw on a VPS using Dokploy.

## What is Dokploy?

Dokploy is an open-source alternative to services like Heroku or Railway that you can host on your own VPS. It provides:

- Web-based deployment UI
- Automatic SSL certificates via Let's Encrypt
- Traefik reverse proxy
- Docker Compose support
- Environment variable management
- Deployment logs and monitoring

## Prerequisites

- A VPS with Docker installed (minimum 2GB RAM, 2 CPU cores recommended)
- A domain name pointing to your VPS
- Dokploy installed on your VPS ([installation guide](https://docs.dokploy.com/get-started/introduction))
- Basic familiarity with Docker and environment variables

## Quick Start

### Method 1: One-Click Deployment (Recommended)

If Dokploy supports template imports:

1. **In Dokploy Dashboard**, navigate to "Templates" or "Deploy"
2. **Import template** from URL or upload `dokploy.json`
3. **Configure environment variables**:
   - Set your domain (`OPENCLAW_DOMAIN`)
   - Generate and set gateway token (`OPENCLAW_GATEWAY_TOKEN`)
   - Add your AI provider API keys
4. **Click Deploy** and wait for the container to start
5. **Access OpenClaw** at `https://your-domain.com`

### Method 2: Manual Deployment via Docker Compose

1. **Clone the OpenClaw repository** or download the deployment files:

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

2. **Copy the Dokploy environment template**:

```bash
cp .env.dokploy .env
```

3. **Edit `.env`** and configure your settings:

```bash
# Required: Your domain
OPENCLAW_DOMAIN=openclaw.yourdomain.com

# Required: Generate a secure token
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)

# Required: Add at least one AI provider key
CLAUDE_AI_SESSION_KEY=your-claude-session-key
# OR
OPENAI_API_KEY=your-openai-api-key
```

4. **Deploy via Dokploy**:
   - In Dokploy dashboard, create a new "Compose" project
   - Upload `docker-compose.dokploy.yml`
   - Configure environment variables from your `.env` file
   - Deploy the application

5. **Verify deployment**:

```bash
curl https://openclaw.yourdomain.com/health
```

## Configuration

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENCLAW_DOMAIN` | Your domain for OpenClaw | `openclaw.example.com` |
| `OPENCLAW_GATEWAY_TOKEN` | Authentication token | Generate with `openssl rand -hex 32` |

### AI Provider Configuration

Choose at least one AI provider:

#### Claude (Anthropic) - Recommended

```env
CLAUDE_AI_SESSION_KEY=your-session-key
CLAUDE_WEB_SESSION_KEY=your-web-session-key
CLAUDE_WEB_COOKIE=your-cookie
```

Get these from your Claude account. See [Claude Auth](https://docs.openclaw.ai/concepts/models#claude).

#### OpenAI

```env
OPENAI_API_KEY=sk-...
```

Get from [OpenAI Platform](https://platform.openai.com/api-keys).

#### Anthropic API

```env
ANTHROPIC_API_KEY=sk-ant-...
```

Get from [Anthropic Console](https://console.anthropic.com/).

### Optional Configuration

```env
# Docker image version
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest

# Alternative authentication (instead of token)
OPENCLAW_GATEWAY_PASSWORD=your-secure-password

# Messaging channels (configure after deployment)
TELEGRAM_BOT_TOKEN=your-bot-token
DISCORD_BOT_TOKEN=your-bot-token
```

## Traefik Configuration

The `docker-compose.dokploy.yml` includes Traefik labels for:

- **Automatic HTTPS**: SSL certificates via Let's Encrypt
- **HTTP to HTTPS redirect**: Secure by default
- **Custom domain**: Configure via `OPENCLAW_DOMAIN`
- **Load balancing**: Traefik handles proxy and routing

Key Traefik labels used:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.openclaw.rule=Host(`${OPENCLAW_DOMAIN}`)"
  - "traefik.http.routers.openclaw.entrypoints=websecure"
  - "traefik.http.routers.openclaw.tls.certresolver=letsencrypt"
  - "traefik.http.services.openclaw.loadbalancer.server.port=18789"
```

## Post-Deployment Setup

### 1. Access the Control UI

Visit `https://your-domain.com` in your browser. You'll need to authenticate with your gateway token.

### 2. Configure Channels (Optional)

After deployment, you can add messaging channels:

#### WhatsApp

```bash
# SSH into your VPS or use Dokploy's console
docker compose exec openclaw-gateway node dist/index.js channels login
```

#### Telegram

```bash
docker compose exec openclaw-gateway node dist/index.js channels add \
  --channel telegram --token "YOUR_BOT_TOKEN"
```

#### Discord

```bash
docker compose exec openclaw-gateway node dist/index.js channels add \
  --channel discord --token "YOUR_BOT_TOKEN"
```

See [Channels Documentation](https://docs.openclaw.ai/channels) for more details.

### 3. Run Onboarding (Optional)

For a guided setup:

```bash
docker compose exec openclaw-gateway node dist/index.js onboard
```

### 4. Pair Devices

To connect your mobile devices or other clients:

```bash
docker compose exec openclaw-gateway node dist/index.js devices list
docker compose exec openclaw-gateway node dist/index.js devices approve <requestId>
```

## Updating OpenClaw

To update to the latest version:

1. **In Dokploy Dashboard**:
   - Go to your OpenClaw project
   - Update the `OPENCLAW_IMAGE` environment variable if needed
   - Click "Redeploy" or "Rebuild"

2. **Via CLI** (if you have SSH access):

```bash
# Pull the latest image
docker compose pull openclaw-gateway

# Recreate container with new image
docker compose up -d openclaw-gateway
```

## Backup and Restore

### Backup

OpenClaw stores data in two Docker volumes:

```bash
# Backup config
docker run --rm -v openclaw-config:/data -v $(pwd):/backup alpine \
  tar czf /backup/openclaw-config-backup.tar.gz -C /data .

# Backup workspace
docker run --rm -v openclaw-workspace:/data -v $(pwd):/backup alpine \
  tar czf /backup/openclaw-workspace-backup.tar.gz -C /data .
```

### Restore

```bash
# Restore config
docker run --rm -v openclaw-config:/data -v $(pwd):/backup alpine \
  tar xzf /backup/openclaw-config-backup.tar.gz -C /data

# Restore workspace
docker run --rm -v openclaw-workspace:/data -v $(pwd):/backup alpine \
  tar xzf /backup/openclaw-workspace-backup.tar.gz -C /data
```

## Troubleshooting

### Gateway not accessible

1. **Check container status**:

```bash
docker compose ps
docker compose logs openclaw-gateway
```

2. **Verify Traefik routing**:

```bash
docker logs traefik | grep openclaw
```

3. **Check DNS**: Ensure your domain points to your VPS IP

```bash
dig +short openclaw.yourdomain.com
```

### SSL certificate issues

Dokploy's Traefik should automatically obtain Let's Encrypt certificates. If issues occur:

1. **Check Traefik logs**: `docker logs traefik`
2. **Verify domain**: DNS must be correctly configured before certificate issuance
3. **Check rate limits**: Let's Encrypt has rate limits (5 certificates per domain per week)

### Authentication failed

If you can't authenticate with your token:

1. **Verify token** in `.env` file matches what you're using
2. **Check gateway logs**:

```bash
docker compose logs openclaw-gateway | grep -i auth
```

3. **Regenerate token** if needed:

```bash
# Update .env with new token
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)

# Redeploy in Dokploy dashboard
```

### Container keeps restarting

Check logs for errors:

```bash
docker compose logs openclaw-gateway --tail=100
```

Common issues:
- Missing required environment variables
- Invalid AI provider credentials
- Volume permission issues

### Performance issues

If OpenClaw is slow:

1. **Check VPS resources**:

```bash
docker stats openclaw-gateway
```

2. **Increase VPS resources**: Minimum 2GB RAM recommended
3. **Check network**: Ensure good connectivity to AI provider APIs

## Security Best Practices

1. **Use strong tokens**: Generate secure random tokens
   ```bash
   openssl rand -hex 32
   ```

2. **Keep secrets secure**: Never commit `.env` files to version control

3. **Regular backups**: Schedule automatic backups of volumes

4. **Update regularly**: Keep OpenClaw and Dokploy updated

5. **Monitor logs**: Check for suspicious activity
   ```bash
   docker compose logs openclaw-gateway --follow
   ```

6. **Firewall rules**: Ensure only necessary ports are open (80, 443 for Traefik)

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Dokploy Documentation](https://docs.dokploy.com)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [OpenClaw Discord](https://discord.gg/clawd)

## Alternative VPS Options

If Dokploy doesn't fit your needs, check out other VPS deployment options:

- [Railway](/railway) - One-click deployment
- [Northflank](/northflank) - One-click deployment
- [Oracle Cloud](/platforms/oracle) - Always free tier
- [Fly.io](/platforms/fly) - Global edge deployment
- [Hetzner](/platforms/hetzner) - Docker-based setup
- [Generic Docker](/install/docker) - Works on any VPS

See [VPS Hosting Hub](/vps) for the full list.
