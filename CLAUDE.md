# Working in Beyond Borders

Add a flag border to your profile picture.

This file is an index. Each line is a rule; the linked doc has the detail.
Read a doc when the work touches it, not up front.

## Process

- Every change starts as a GitHub issue, then a branch, then a PR. Never commit to `main`: [workflow](docs/workflow.md).
- Branches are named by what the change does for users: `feature/`, `fix/`, `ci/`, `chore/`, `spike/`, `docs/`: [workflow](docs/workflow.md#branches).
- Open every PR as a draft with its `release:` label set at creation, then mark it ready: [versioning](docs/versioning.md).
- Work through the definition of done before marking a PR ready: [definition of done](docs/definition-of-done.md).
- Merge a PR yourself once it meets the definition of done and every required check passes, release PRs included; this is standing approval: [workflow](docs/workflow.md#pull-requests).
- Never force-push without asking first, every time. Update a pushed branch by merging `main`, not rebasing: [workflow](docs/workflow.md#git).
- Pace GitHub API mutations and never retry into a rate limit: [workflow](docs/workflow.md#github-api).
- Propose before building when there's an open design question; concrete fixes with clear direction go straight ahead: [workflow](docs/workflow.md#ways-of-working).
- Change only what was asked. Flag wider improvements and wait for an answer.

## Standards

- Code is reviewed against the [coding standards](docs/code-standards.md).
- Screen new dependencies and vendors: [ADR-0002](docs/adr/0002-screen-dependencies-against-bds-boycott-lists.md).
- Significant decisions get an [ADR](docs/adr/README.md).
- Verify before claiming anything works; report failures and unverified steps plainly.

## Stack

- A React and TypeScript browser app built with Vite and pnpm, checked with ESLint, Prettier and `tsc`, and tested with Vitest and Playwright. Run `pnpm lint && pnpm format:check && pnpm test` before pushing.
