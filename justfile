default:
    @just --list

tfplan:
    cd terraform && terraform plan -out tfplan

tfapply:
    cd terraform && terraform apply tfplan

list-inventory-all:
    cd ansible && ansible-inventory -i inventory/staging.yaml -i inventory/production.yaml --graph

list-inventory environment:
    cd ansible && ansible-inventory -i inventory/{{ environment }}.yaml --graph

secret group_name:
    cd ansible && ansible-vault edit group_vars/{{ group_name }}/vault.yaml

setup-ansible:
    cd ansible && ansible-galaxy install -r requirements.yaml

play environment playbook='site':
    cd ansible && ansible-playbook -i inventory/{{ environment }}.yaml {{ playbook }}.yaml

lint:
    ansible-lint

restore-nginx:
    ansible-playbook -i ansible/inventory.yaml ansible/restore-volume.yaml \
        --limit staging \
        -e "service_name=nginx" \
        -e "backup_base_filename=nginx-proxy-manager-backup" \
        -e '{"volumes_to_restore": [{"name": "npm_data", "backup_path": "npm-data-backup"}, {"name": "npm_letsencrypt", "backup_path": "npm-letsencrypt-backup"}]}'

restore-actual-budget:
    ansible-playbook -i ansible/inventory.yaml ansible/restore-volume.yaml \
        --limit staging \
        -e "service_name=actual-budget" \
        -e "backup_base_filename=actual-budget-backup" \
        -e '{"volumes_to_restore": [{"name": "actual_data", "backup_path": "actual-budget-backup"}]}'
