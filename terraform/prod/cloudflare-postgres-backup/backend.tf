# Remote state, stored in the central R2 bucket created by ../../bootstrap.
# All settings come from backend.hcl, passed at init:
#   terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {}
}
