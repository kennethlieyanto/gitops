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

argocd-bootstrap: 
    kubectl apply -f k3s-gitops/bootstrap/manifest/

argoocd_repo_url := "https://argoproj.github.io/argo-helm"
argocd_helm_chart_version := "9.7.0"
argocd-install: 
    helm repo add argo {{ argoocd_repo_url }}
    helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace \
      --version {{ argocd_helm_chart_version }} \
      -f k3s-gitops/bootstrap/argocd-values.yaml

argocd-repo-add:
    argocd repo add git@github.com:kennethlieyanto/homeserver.git \
      --ssh-private-key-path /home/kennethl/.ssh/id_ed25519 \
      --insecure-skip-server-verification
