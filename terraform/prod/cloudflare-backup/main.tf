module "restic_bucket" {
  source = "../../modules/cloudflare/r2-bucket"

  account_id = var.cloudflare_account_id
  name       = var.bucket_name
  location   = var.bucket_location
}
