# ADR-0003: Host on Cloudflare Workers

## Status

Accepted, 2026-11-12.

## Context

The site was served by GitHub Pages from a `gh-pages` branch, with PR builds published under `/beta/<semver>/` on the same site. GitHub Pages has no single-page app fallback, so deep links failed, and the repository is moving to the oneloneraven organisation, which doesn't allow GitHub Pages. The zone was already on Cloudflare.

## Decision

Serve the app from a Cloudflare Worker with static assets, following the claude-project-bootstrap `cloudflare-opentofu` module:

- each release tag deploys to production, behind an approval on the `production` environment;
- every PR gets a Workers Preview;
- the zone's DNS, TLS, HSTS, DNSSEC, CAA, security headers and `www` redirect are in OpenTofu, with state in R2.

The module's cache rules aren't used, because flag images keep their names when they're updated. Hashed assets are cached through `public/_headers` instead.

## Consequences

- Deep links work, and every response carries the security headers.
- Cloudflare is a single point of failure for DNS, hosting and state. The Workers Free plan's daily request limit applies only to requests that run the Worker (`/api/*`): static assets are served without it, and the `www` redirect is a zone rule.
- Releases need the maintainer's approval to reach production.
- The repository can move to the organisation.
