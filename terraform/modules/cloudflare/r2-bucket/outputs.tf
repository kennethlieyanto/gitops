output "bucket_name" {
  description = "Name of the R2 bucket."
  value       = cloudflare_r2_bucket.this.name
}

output "s3_endpoint" {
  description = "S3-compatible endpoint for the account."
  value       = "https://${var.account_id}.r2.cloudflarestorage.com"
}

output "restic_repository" {
  description = "restic repository URL for this bucket."
  value       = "s3:https://${var.account_id}.r2.cloudflarestorage.com/${cloudflare_r2_bucket.this.name}"
}
