docker-service-dir := "docker-services"

default:
    @just --choose

setup:
    cd infra && uv run ansible-galaxy install -r ansible/requirements.yaml -p ansible/roles/external

run:
    cd infra && uv run ansible-playbook -i ansible/inventory/production.yaml ansible/site.yaml 

lint:
    cd infra/ansible && uv run ansible-lint

start service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose up -d

stop service:
    cd {{ docker-service-dir }}/{{ service }} && docker compose down 

backup-nginx:
    docker exec nginx-backup-1 backup

backup-actual:
    docker exec actual-budget-backup-1 backup
