# k3s Backup

This directory contains the host-level restic backup for the single-node k3s
cluster. The backup is stored in Cloudflare R2 and is encrypted by restic.

Terraform manages the R2 buckets. The backup itself runs on the k3s node with
restic and systemd.

## What is backed up

| Data | Purpose |
| --- | --- |
| `/var/lib/rancher/k3s/server/db/state.db` | k3s SQLite datastore and cluster state |
| `/var/lib/rancher/k3s/server/token` | Required with `state.db` to restore the datastore |
| `/var/lib/rancher/k3s/storage/` | LocalPath PersistentVolume data |

The backup script uses `sqlite3 .backup` for SQLite files and copies other PV
files normally. This includes Actual Budget attachments such as `.blob` files.
Git-managed Kubernetes manifests are already backed up in the Git repository
and are not duplicated here.

## Cloudflare and Terraform

Terraform lives in `../terraform/`:

```text
terraform/bootstrap/              central R2 state bucket
terraform/prod/cloudflare-backup/ R2 bucket used by restic
```

The Cloudflare Terraform API token needs:

```text
Account -> Workers R2 Storage -> Edit
```

The Terraform state backend uses separate R2 S3 credentials with Object Read &
Write access scoped to the state bucket. R2 S3 credentials cannot currently be
created by the Terraform Cloudflare provider.

### Bootstrap order

The state bucket has a chicken-and-egg dependency: Terraform needs state to
manage the bucket, but the bucket is needed for remote state.

1. Use temporary local state to create the state bucket.
2. Create R2 S3 credentials scoped to that bucket.
3. Copy and fill `terraform/bootstrap/backend.hcl.example`.
4. Migrate local state to the R2 backend using the `bootstrap/terraform.tfstate`
   key:

   ```sh
   terraform -chdir=terraform/bootstrap init \
     -backend-config=backend.hcl -migrate-state
   ```

5. Run `terraform plan` and confirm there are no changes.

For a fresh setup, the first local-state apply is:

```sh
terraform -chdir=terraform/bootstrap init -backend=false
terraform -chdir=terraform/bootstrap apply
```

Do not repeat this after state migration; use the remote backend instead.

The production stack uses a separate state key:

```text
prod/cloudflare-backup/terraform.tfstate
```

After the state bucket exists, apply the production stack:

```sh
cp terraform/prod/cloudflare-backup/backend.hcl.example \
   terraform/prod/cloudflare-backup/backend.hcl
# Fill in the Cloudflare account ID in backend.hcl.

just tf-init
just tf-plan
just tf-apply
```

## R2 credentials for restic

Create a separate R2 S3 API token scoped only to the restic bucket:

```text
Permission: Object Read & Write
Scope:      the restic backup bucket only
```

Do not reuse the Terraform API token or the Terraform state credentials.

## k3s node setup

Install the required packages:

```sh
sudo apt-get update
sudo apt-get install -y restic sqlite3
```

The node needs this root-only environment file:

```text
/etc/restic/k3s.env
```

Example:

```text
RESTIC_REPOSITORY=s3:https://<ACCOUNT_ID>.r2.cloudflarestorage.com/k3s-restic
AWS_DEFAULT_REGION=auto
AWS_ACCESS_KEY_ID=<R2 access key for the restic bucket>
AWS_SECRET_ACCESS_KEY=<R2 secret key for the restic bucket>
RESTIC_PASSWORD_FILE=/etc/restic/k3s-restic-password
```

Create a separate restic repository password at:

```text
/etc/restic/k3s-restic-password
```

Store that password in a password manager. Losing it makes the encrypted
restic repository unrecoverable.

Protect both files:

```sh
sudo chown root:root /etc/restic/k3s.env /etc/restic/k3s-restic-password
sudo chmod 600 /etc/restic/k3s.env /etc/restic/k3s-restic-password
```

## Installed files

The supplied files are installed on the node as follows:

```text
k3s-restic-backup.sh       /usr/local/sbin/k3s-restic-backup.sh
k3s-restic-backup.service  /etc/systemd/system/k3s-restic-backup.service
k3s-restic-backup.timer    /etc/systemd/system/k3s-restic-backup.timer
k3s-restic-check.service   /etc/systemd/system/k3s-restic-check.service
k3s-restic-check.timer     /etc/systemd/system/k3s-restic-check.timer
```

The backup service:

1. Creates a temporary staging directory under `/var/backups/k3s-restic/`.
2. Creates consistent SQLite copies.
3. Copies non-database PV files.
4. Creates a restic snapshot tagged `k3s`.
5. Applies this retention policy:

   ```text
   7 daily, 4 weekly, 12 monthly
   ```

6. Removes the temporary staging directory.

The backup timer runs daily. The check timer runs weekly and reads a subset of
repository data to detect corruption.

## Initialize and validate

Initialize the repository once. Do not run `restic init` again if snapshots
already exist:

```sh
sudo bash -c 'set -a; . /etc/restic/k3s.env; set +a; restic init'
```

Run a manual backup:

```sh
sudo systemctl start k3s-restic-backup.service
sudo journalctl -u k3s-restic-backup.service -n 100 --no-pager
```

List snapshots:

```sh
sudo bash -c 'set -a; . /etc/restic/k3s.env; set +a; restic snapshots --tag k3s'
```

Check the repository:

```sh
sudo systemctl start k3s-restic-check.service
sudo journalctl -u k3s-restic-check.service -n 100 --no-pager
```

Enable the timers only after the manual backup succeeds:

```sh
sudo systemctl enable --now \
  k3s-restic-backup.timer \
  k3s-restic-check.timer

systemctl list-timers 'k3s-restic-*'
```

## Restore test

Restore the latest snapshot into a temporary directory first:

```sh
restore_dir=$(mktemp -d)
sudo bash -c 'set -a; . /etc/restic/k3s.env; set +a; restic restore latest --target "$1"' \
  _ "$restore_dir"
```

Check every restored SQLite database:

```sh
sudo find "$restore_dir" -type f \
  \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) \
  -exec sqlite3 '{}' 'PRAGMA integrity_check;' \;
```

Every database should report `ok`.

## Full disaster recovery

1. Install k3s on the replacement node.
2. Stop k3s:

   ```sh
   sudo systemctl stop k3s
   ```

3. Restore the staged `server/db/state.db` and `server/token`.
4. Remove stale `state.db-wal` and `state.db-shm` files.
5. Restore the staged `storage/` contents to
   `/var/lib/rancher/k3s/storage/`.
6. Start k3s.
7. Verify the cluster and let ArgoCD reconcile the workloads.

Restoring `state.db` and `server/token` together preserves the original PV
object names, so the LocalPath directories match. If the token is unavailable,
the old k3s datastore cannot be restored; rebuild from Git and restore the app
data into newly-created PVCs instead.

## Security

- Never commit `k3s.env`, the restic password, R2 credentials, or Terraform
  state.
- Use different credentials for Terraform management, Terraform state, and
  restic data.
- The restic repository password is required for every restore.
