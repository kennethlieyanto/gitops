#!/usr/bin/env bash
set -Eeuo pipefail

readonly K3S_ROOT=/var/lib/rancher/k3s
readonly STAGE=/var/backups/k3s-restic/stage

if [[ ${EUID} -ne 0 ]]; then
  echo "This script must run as root" >&2
  exit 1
fi

exec 9>/run/k3s-restic-backup.lock
flock -n 9 || exit 0

cleanup() {
  rm -rf -- "${STAGE}"
}
trap cleanup EXIT

install -d -m 0700 "${STAGE}/server/db" "${STAGE}/storage"

# K3s requires the datastore and server token to be restored together.
sqlite3 "${K3S_ROOT}/server/db/state.db" \
  ".backup '${STAGE}/server/db/state.db'"
install -m 0600 "${K3S_ROOT}/server/token" "${STAGE}/server/token"

# Keep all PV files, but use SQLite's online backup API for database files.
while IFS= read -r -d '' source_file; do
  relative_path=${source_file#"${K3S_ROOT}/storage/"}
  destination="${STAGE}/storage/${relative_path}"
  install -d -m 0700 "$(dirname "${destination}")"

  case "${source_file}" in
    *.sqlite|*.sqlite3|*.db)
      sqlite3 "${source_file}" ".backup '${destination}'"
      ;;
    *)
      cp -a -- "${source_file}" "${destination}"
      ;;
  esac
done < <(find "${K3S_ROOT}/storage" -type f -print0)

cd "${STAGE}"
restic backup . --tag k3s
restic forget --tag k3s \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --prune
