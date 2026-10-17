# GitOps

Personal homelab GitOps.

## Setup

The dev shell (direnv + Nix flake) provides the tooling (`terraform`, `just`,
`bws`, `gitleaks`, `lefthook`). After the flake changes are picked up:

```sh
direnv reload   # or: nix develop
just setup      # installs the git hooks via lefthook
```

## Secret scanning

[gitleaks](https://github.com/gitleaks/gitleaks) scans for leaked secrets in
both git history and staged changes. Rules live in `.gitleaks.toml`.

- `just gitleaks` — scan the full git history.
- [lefthook](https://github.com/evilmartians/lefthook) runs gitleaks on
  `pre-commit` (staged changes) and `pre-push` (full history); see `lefthook.yml`.
- CI runs the same scan on every push and pull request
  (`.github/workflows/gitleaks.yml`).
