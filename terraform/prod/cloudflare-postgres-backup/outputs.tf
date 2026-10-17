output "bucket_name" {
  description = "Name of the CloudNativePG backup R2 bucket."
  value       = module.postgres_backup_bucket.bucket_name
}

output "s3_endpoint" {
  description = "S3-compatible endpoint for the account."
  value       = module.postgres_backup_bucket.s3_endpoint
}
