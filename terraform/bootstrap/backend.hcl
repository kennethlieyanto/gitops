# Copy to backend.hcl and fill in the account ID.
# Used by: terraform init -backend-config=backend.hcl -migrate-state

bucket = "kennethl-tfstate"
key    = "bootstrap/terraform.tfstate"
region = "auto"

endpoints = {
  s3 = "https://e5b1e4474fb9e39e954f646bd697e162.r2.cloudflarestorage.com"
}

skip_credentials_validation = true
skip_region_validation      = true
skip_requesting_account_id  = true
skip_s3_checksum            = true
use_lockfile                = true
