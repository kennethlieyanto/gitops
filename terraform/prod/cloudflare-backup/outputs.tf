output "bucket_name" {
  description = "Name of the restic R2 bucket."
  value       = module.restic_bucket.bucket_name
}

output "s3_endpoint" {
  description = "S3-compatible endpoint for the account."
  value       = module.restic_bucket.s3_endpoint
}

output "restic_repository" {
  description = "restic repository URL for the backup bucket."
  value       = module.restic_bucket.restic_repository
}
