argoocd_repo_url := "https://argoproj.github.io/argo-helm"
argocd_helm_chart_version := "9.7.0"

default:
    @just --list

argocd-install: 
    helm repo add argo {{ argoocd_repo_url }}
    helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace \
      --version {{ argocd_helm_chart_version }} \
      -f k3s-gitops/bootstrap/argocd-values.yaml

argocd-bootstrap: 
    kubectl apply -f k3s-gitops/bootstrap/manifest/

argocd-repo-add:
    argocd repo add git@github.com:kennethlieyanto/gitops.git \
      --ssh-private-key-path /home/kennethl/.ssh/id_ed25519 \
      --insecure-skip-server-verification
