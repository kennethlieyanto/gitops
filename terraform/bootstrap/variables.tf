variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the R2 bucket."
  type        = string
}

variable "state_bucket_name" {
  description = "Name of the R2 bucket used for Terraform remote state."
  type        = string
  default     = "kennethl-tfstate"
}

variable "state_bucket_location" {
  description = "Location hint for the state bucket (e.g. APAC, ENAM, WEUR)."
  type        = string
  default     = "APAC"
}
