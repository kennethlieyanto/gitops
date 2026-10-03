# Remote state, stored in the central R2 bucket that this stack creates.
# Because the bucket does not exist yet, the first apply uses temporary local
# state; afterwards migrate it here (see README.md).
#
# All settings come from backend.hcl, passed at init:
#   terraform init -backend-config=backend.hcl -migrate-state
terraform {
  backend "s3" {}
}
