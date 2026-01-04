docker-service-dir := "docker-services"
backup-ssh-host-name := "kennethl-ws"
backup-ssh-username := "kennethl"

list:
    ls {{ docker-service-dir }}

start service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose up -d

stop service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose down 

backup service:
    #!/usr/bin/env bash
    set -e

    echo "Stopping {{ service }}..."
    just stop {{ service }}

    echo "Creating backup archive..."
    cd {{ docker-service-dir }}/{{ service }}
    timestamp=$(date +%Y%m%d_%H%M%S)
    archive_name="{{ service }}-${timestamp}.tar.gz"
    tar -czf "../${archive_name}" .

    ssh {{ backup-ssh-username }}@{{ backup-ssh-host-name }} "mkdir -p ~/backups"

    echo "Copying backup to remote host..."
    scp "../${archive_name}" {{ backup-ssh-username }}@{{ backup-ssh-host-name }}:~/backups/

    echo "Cleaning up local archive..."
    rm "../${archive_name}"

    echo "Starting {{ service }} back again..."
    just start {{ service }}

    echo "Backup completed successfully!"
