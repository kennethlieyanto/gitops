output "state_bucket_name" {
  description = "Name of the R2 bucket used for Terraform remote state."
  value       = cloudflare_r2_bucket.tfstate.name
}
