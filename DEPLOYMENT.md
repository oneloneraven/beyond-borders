# Deployment

`wearebeyondborders.com` is served by a Cloudflare Worker with static assets. Why: [ADR-0003](docs/adr/0003-host-on-cloudflare-workers.md).

## Production

1. A PR merges with a `release:` label other than `none` ([versioning](docs/versioning.md)).
2. `release.yml` tags the merge commit `vX.Y.Z` and creates a GitHub Release.
3. `deploy.yml` runs on the tag. The `production` environment waits for the maintainer to approve it.
4. Once approved, it builds the app with that version and deploys `dist/` to the `beyond-borders` Worker's `production` environment with `wrangler deploy`.

The Worker serves the build's static assets, falls back to `index.html` for the app's routes, and answers `/api/health` with the release it's running:

```bash
curl -s https://wearebeyondborders.com/api/health
```

`www.wearebeyondborders.com` redirects to the apex with a Cloudflare redirect rule, keeping the path and query.

## PR previews

`preview.yml` uploads every PR's build as a Workers Preview named `pr-<n>`, and comments its URL on the PR. The Preview is deleted when the PR closes. Dependabot PRs and PRs that only touch docs, tests or `infra/` don't get one.

## Infrastructure

DNS, TLS, HSTS, DNSSEC, CAA, the security headers and the `www` redirect are in OpenTofu: [infra](infra/README.md). Merging a change under `infra/` applies it to the live zone.

## Caching

- `/assets/*`: Vite's hashed bundles are cached for a year as `immutable` (`public/_headers`).
- Everything else, including flag images, revalidates on each load with an ETag, so a new release or a flag update shows at once.

## Rolling back

Under Workers & Pages → `beyond-borders-production` → Deployments, roll back to the previous version, then fix forward with a new PR. There's no other origin: the apex's A record is a placeholder that only lets the Worker's route answer.

## Troubleshooting

- **The deploy didn't run:** check that `release.yml` cut a tag for the merge (`release: none` cuts none), then whether the Deploy run is waiting for approval.
- **A PR has no preview comment:** check the Preview run. PRs from forks don't get the Cloudflare token.
- **`/api/health` shows an old version:** check that the Deploy run for the newest tag finished.
