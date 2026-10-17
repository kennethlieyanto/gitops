# Terraform

Cloud infrastructure for the homelab. Currently **Cloudflare only** (R2 for
restic offsite backups). Adding another cloud = add a `modules/<cloud>/...`
module and a `prod/<cloud>-<purpose>/` stack; nothing else changes.

## Layout

```
terraform/
├── modules/
│   └── cloudflare/
│       └── r2-bucket/          # reusable R2 bucket + lifecycle module
├── bootstrap/                  # creates the central remote-state R2 bucket
│                               # (local state, applied once)
└── prod/
    ├── cloudflare-backup/           # R2 bucket that restic writes to
    └── cloudflare-postgres-backup/  # R2 bucket for CloudNativePG/Barman backups
```

Each directory under `bootstrap/` and `prod/` is a root module with its own
state. State lives in a single central R2 bucket (S3-compatible), keyed by
`prod/<stack>/terraform.tfstate`.

## Prerequisites

Environment variables (see `terraform/.env.example`; `source` it or load with
direnv):

- `CLOUDFLARE_API_TOKEN` — Cloudflare API token with R2 permissions.
- `TF_VAR_cloudflare_account_id` — Cloudflare account ID.
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` — R2 **S3** credentials used by
  the `s3` state backend (separate from the API token).

> The provider manages the bucket, but R2 S3 access keys cannot be created by
> Terraform. Create them once in the Cloudflare dashboard and store them as
> secrets.

## First run

```sh
# 1. Create the remote-state bucket (local state)
just tf-bootstrap

# 2. Configure the prod stack backend (copy and fill in the account ID)
cp terraform/prod/cloudflare-backup/backend.hcl.example \
   terraform/prod/cloudflare-backup/backend.hcl

# 3. Init + apply the restic bucket
just tf-init
just tf-apply
```

After bootstrap, its local `terraform.tfstate` can be migrated into the state
bucket if desired.

## Commands

```sh
just tf-init   # init a stack (default: prod/cloudflare-backup)
just tf-plan
just tf-apply
just tf-fmt
```

Stack parameter:

```sh
just tf-plan prod/cloudflare-backup
```

## Notes

- `use_lockfile = true` requires Terraform/OpenTofu >= 1.10.
- If your backend errors on checksums, remove `skip_s3_checksum` from
  `backend.hcl` (or add it if your version requires it for R2).
- `terraform/` is intentionally outside `k3s-gitops/apps` so ArgoCD does not
  try to apply it.
