# Infrastructure

The DNS records, TLS and HSTS, DNSSEC, CAA and security headers for `wearebeyondborders.com` are managed here with [OpenTofu](https://opentofu.org), the open-source fork of Terraform (same HCL, providers and state format). The only things outside OpenTofu are the state bucket (it must exist before OpenTofu can use it) and the CI credentials below.

State lives in the R2 bucket `beyond-borders-tfstate`, never in git.

The records predate OpenTofu, so `imports.tf` adopts them by id. Once they're in state, an import block is a no-op.

## Workflows

| Workflow              | Trigger                                             | What it does                                                            |
| --------------------- | --------------------------------------------------- | ----------------------------------------------------------------------- |
| `infra.yml`           | PR touching `infra/` (plan); push to `main` (apply) | Format check, validate, plan; refuses any plan that deletes or replaces |
| `bootstrap-state.yml` | Manual                                              | Creates the state bucket if it's missing; safe to re-run                |

## Setup

1. The zone `wearebeyondborders.com` is active on Cloudflare.
2. Create the CI tokens below, the R2 state credentials, and the GitHub secrets and variables: `node <plugin>/skills/bootstrap/scripts/secrets.mjs cloudflare-tokens <project dir>` does the CI tokens and `secrets.mjs cloudflare-r2 <project dir>` the state credentials, or follow this page by hand.
3. Run "Bootstrap OpenTofu state bucket".
4. Run "Infra" (dispatch it, or merge a change under `infra/`).
5. Add the DS record from `tofu output app_dnssec_ds_record` (or the Infra run's log) at the registrar.

### Cloudflare API tokens

Create each as an account-owned token with a one-year expiry, scoped to this account and, for zone permissions, to `wearebeyondborders.com` only.

| Token       | GitHub secret                                        | Permissions                                                                                                                    |
| ----------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Preview     | `CLOUDFLARE_PREVIEW_TOKEN` (repository)              | Account: Workers Scripts Edit, Account Settings Read                                                                           |
| Deploy      | `CLOUDFLARE_DEPLOY_TOKEN` (environment `production`) | Account: Workers Scripts Edit, Account Settings Read. Zone: Workers Routes Edit                                                |
| Infra plan  | `CLOUDFLARE_INFRA_PLAN_TOKEN` (repository)           | Account: Workers R2 Storage Read, Transform Rules Read. Zone: DNS Read, Zone Settings Read, Zone WAF Read, Cache Settings Read |
| Infra apply | `CLOUDFLARE_INFRA_APPLY_TOKEN` (environment `infra`) | Account: Workers R2 Storage Edit, Transform Rules Edit. Zone: DNS Edit, Zone Settings Edit, Zone WAF Edit, Cache Settings Edit |

Transform Rules is account-scoped, so the infra tokens' Transform Rules permission covers every zone in the account, not just `wearebeyondborders.com`.

If a plan or apply fails with an authorisation error, the error names the missing permission: add exactly that one.

Never add a per-Worker granular policy to an existing token by editing it in place: such writes have failed or silently left a token with no policies. Create a new token instead. Check a token's real contents with `GET /accounts/<account id>/tokens/<token id>`, not the dashboard labels.

### R2 state credentials

Two R2 API tokens (R2 → Manage R2 API Tokens), both limited to the `beyond-borders-tfstate` bucket:

| Token            | Permission          | GitHub secrets                                                                              |
| ---------------- | ------------------- | ------------------------------------------------------------------------------------------- |
| State read-write | Object Read & Write | `TF_STATE_ACCESS_KEY_ID`, `TF_STATE_SECRET_ACCESS_KEY` (environment `infra`)                |
| State read-only  | Object Read only    | `TF_STATE_READ_ACCESS_KEY_ID`, `TF_STATE_READ_SECRET_ACCESS_KEY` (repository, for PR plans) |

PR plans run with the read-only pair, so code in a pull request can't rewrite state.

### OpenTofu version

`infra.yml` pins OpenTofu exactly in `tofu_version`. Dependabot doesn't bump it. To upgrade, take the newest `opentofu/opentofu` release that is more than 72 hours old (not a pre-release), change `tofu_version`, and run the same version locally.

### Variables

`CLOUDFLARE_ACCOUNT_ID` as a repository variable. It isn't confidential.

## Disaster recovery

1. Run "Bootstrap OpenTofu state bucket".
2. Run "Infra" to recreate everything managed here.

## Teardown

Deliberately deleting the project's infrastructure:

1. Remove `prevent_destroy` from every resource in a PR (the infra workflow refuses plans that delete, so run the destroy locally).
2. Locally, with the infra apply token and state credentials in your environment: `tofu init -backend-config="endpoints={s3=\"https://<account id>.r2.cloudflarestorage.com\"}"` then `tofu destroy`.
3. Empty and delete the `beyond-borders-tfstate` bucket in the dashboard.
4. Revoke the four Cloudflare tokens and the R2 credentials.
5. Remove the DS record at the registrar.
