default:
    @just --choose

list-inventory limit:
    # ansible-inventory -i ansible/inventory.yaml --list
    ansible-playbook ansible/site.yaml -i ansible/inventory.yaml -l {{ limit }} --list-hosts

edit-secret:
    ansible-vault edit ansible/group_vars/docker_hosts/vault.yml

setup-ansible:
    ansible-galaxy install -r ansible/requirements.yaml

play environment:
    ansible-playbook -i ansible/inventory.yaml ansible/site.yaml --limit {{ environment }}

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
