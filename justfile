default:
    @just --list

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

repo-add:
    argocd repo add git@github.com:kennethlieyanto/homeserver.git \
      --ssh-private-key-path /home/kennethl/.ssh/id_ed25519 \
      --insecure-skip-server-verification

install-argocd:
    helm repo add argo https://argoproj.github.io/argo-helm
    helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace \
      --version 9.7.0 \
      -f bootstrap/argocd-values.yaml

bootstrap: repo-add
    kubectl apply -f bootstrap/root-app.yaml

