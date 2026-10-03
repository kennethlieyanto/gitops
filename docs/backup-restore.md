# Backup & Restore

Single-node k3s, Local-path volumes on local disk. Backup target is a RAID1
mounted at `/mnt/backup` on a separate backup host, then offsite to Backblaze
B2. Tool: borgmatic/borg.

## What must be backed up

| Path | What | Why |
|------|------|-----|
| `/var/lib/rancher/k3s/storage/` | All PersistentVolumes (actual-budget 10Gi, taskwarrior 1Gi, twreport 1Gi) | The actual app data. Lives only on this node. |
| `/var/lib/rancher/k3s/server/db/` | k3s SQLite datastore (`state.db`) | Cluster state: all Kubernetes objects. |
| `/var/lib/rancher/k3s/server/token` | Cluster join token | Encrypts confidential data in the datastore; the datastore backup is unusable without it. |

Not backed up: cluster/platform manifests — these live in `k3s-gitops` on GitHub
and are rebuilt by ArgoCD.

## Key understanding

- **Local-path volumes are node-bound.** Data exists on one node's disk only;
  there is no replication and no failover.
- **SQLite data must be copied consistently.** Both apps and the k3s datastore
  are SQLite; raw file copies during writes can be corrupt. Use `sqlite3 .backup`.
- **One copy is not a backup.** The RAID1 protects against disk failure only —
  not fire/theft/ransomware. An offsite (cloud) copy is required for real safety.
- **A backup is only trusted after a test restore.**

## Strategy (3-2-1)

1. Node → RAID1 on the backup host over SSH (daily, borgmatic).
2. RAID1 → Backblaze B2 (offsite, ~$0.07/mo for ~12GiB).
3. Git config → GitHub (already in place).
