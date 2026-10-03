terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.26.0"
    }
  }
}

resource "cloudflare_r2_bucket" "this" {
  account_id = var.account_id
  name       = var.name
  location   = var.location
}

locals {
  default_lifecycle_rules = [
    {
      id      = "abort-incomplete-multipart-uploads"
      enabled = true
      conditions = {
        prefix = ""
      }
      abort_multipart_uploads_transition = {
        condition = {
          type    = "Age"
          max_age = var.abort_multipart_uploads_after_seconds
        }
      }
    },
  ]
}

resource "cloudflare_r2_bucket_lifecycle" "this" {
  account_id  = var.account_id
  bucket_name = cloudflare_r2_bucket.this.name
  rules       = concat(local.default_lifecycle_rules, var.lifecycle_rules)
}
