# Homelab GitOps

A single-node **k3s** homelab.

[ArgoCD](https://argo-cd.readthedocs.io) reconciles the cluster from
`k3s-gitops/`, [Terraform](https://www.terraform.io) provisions the Cloudflare R2
buckets, and a host-level restic backup covers the node itself.

## Stack

| Area          | Components                                                                                         |
| ------------- | -------------------------------------------------------------------------------------------------- |
| Ingress       | **Envoy Gateway** (Gateway API), **cert-manager** (Let's Encrypt), **MetalLB** (L2 `LoadBalancer`) |
| DNS           | **external-dns** to Cloudflare                                                                     |
| Secrets       | **External Secrets Operator** from Google Secret Manager                                           |
| Data          | **CloudNativePG** + **Barman Cloud**: Postgres with WAL archiving and PITR to R2                   |
| Identity      | **Keycloak** (SSO / OIDC for Grafana and ArgoCD)                                                   |
| Observability | **kube-prometheus-stack**, **Grafana Operator**                                                    |
| Apps          | **Actual Budget**, **TaskChampion** sync server                                                    |

## Repository layout

| Path                  | Contents                                                               |
| --------------------- | ---------------------------------------------------------------------- |
| `k3s-gitops/`         | Kubernetes manifests and the ArgoCD app-of-apps                        |
| `terraform/`          | Cloudflare R2 buckets and remote state (see `terraform/README.md`)     |
| `k3s-backup/`         | Host-level restic backup for the k3s node (see `k3s-backup/readme.md`) |
| `flake.nix`, `.envrc` | Dev shell with the tooling                                             |

## How it works

ArgoCD applies a single root Application
(`k3s-gitops/bootstrap/manifest/root-app.yaml`) that recurses over
`k3s-gitops/apps/` — one Application per component, each combining a pinned Helm
chart with values and extra resources from this repo (via ArgoCD's `$values`
ref). Sync waves order the rollout (observability before Grafana, Keycloak after
its database) and automated sync with `prune` + `selfHeal` keeps the cluster
converged.

## Bootstrap

Once per cluster (see `justfile`):

```sh
just argocd-install     # install ArgoCD via Helm
just argocd-repo-add    # register this repo with ArgoCD
just argocd-bootstrap   # apply root-app; everything else syncs from Git
```

Terraform: `just tf-bootstrap` (state bucket, once), then
`just tf-init && just tf-apply`.

## Backups

- **Node** — restic (systemd timers) snapshots the k3s datastore, token, and
  local-path volumes to R2. See `k3s-backup/readme.md`.
- **Postgres** — CloudNativePG + Barman continuously archives WAL and takes
  daily base backups to R2, giving point-in-time recovery.

## Security

No secrets live in Git. Workloads read them from Google Secret Manager through
External Secrets. [gitleaks](https://github.com/gitleaks/gitleaks) scans for
leaked secrets in both git history and staged changes (rules in
`.gitleaks.toml`):

- `just gitleaks` — scan the full git history.
- [lefthook](https://github.com/evilmartians/lefthook) runs gitleaks on
  `pre-commit` (staged changes) and `pre-push` (full history); see `lefthook.yml`.
- CI runs the same scan on every push and pull request
  (`.github/workflows/gitleaks.yml`).

## Dependency updates

[Renovate](https://docs.renovatebot.com) runs daily (20:00 UTC) via
`.github/workflows/renovate.yml` and opens PRs for:

- Helm chart versions in the ArgoCD `Application` manifests under
  `k3s-gitops/apps/` (`argocd` manager, including the OCI charts)
- The ArgoCD chart version pinned in the `justfile` (regex manager)
- Terraform provider constraints under `terraform/`
- GitHub Actions used by the workflows
- The Keycloak operator image in
  `k3s-gitops/platform/keycloak-operator/operator/operator.yaml`

It needs a **`RENOVATE_TOKEN`** repository secret: a fine-grained PAT with
read/write access to **Contents**, **Issues**, **Pull requests** and
**Workflows** (Renovate bumps action versions in `.github/workflows/`).
Alternatively use `${{ secrets.GITHUB_TOKEN }}` and enable *Allow GitHub Actions
to create and approve pull requests*, at the cost of CI not running on Renovate's
PRs.

Deliberately not automated: the `Grafana` CR's `spec.version` and image in
`k3s-gitops/platform/grafana/grafana.yaml` (they must be bumped together), and
`flake.lock` (Renovate's `nix` manager needs Nix on the runner).

## Dev shell

The Nix flake (via direnv) provides `terraform`, `just`, `bws`, `gitleaks`, and
`lefthook`:

```sh
direnv reload   # or: nix develop
just setup      # install the git hooks
```
