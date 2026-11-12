# Deployment Architecture

Production is served by GitHub Pages from the `gh-pages` branch.

## Overview

- **Production** – deploys to the root of `gh-pages` branch
- **PR previews** – each pull request gets a Workers preview URL from `.github/workflows/preview.yml`

## GitHub Pages Configuration

**CRITICAL:** GitHub Pages must be configured to deploy from `gh-pages`:

1. Go to: **Settings → Pages**
2. Under "Build and deployment" → "Source"
3. Select: **"Deploy from a branch"**
4. Branch: **`gh-pages`**
5. Folder: **`/ (root)`**

## Deployment Types

- [Production Deployment](docs/deployment-production.md)
- [Custom Domain Setup](docs/deployment-custom-domain.md)

## Quick Links

- [Troubleshooting](docs/deployment-troubleshooting.md)
- [Architecture Decision](docs/deployment-architecture-decision.md)
