variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the R2 bucket."
  type        = string
}

variable "bucket_name" {
  description = "Name of the R2 bucket used for CloudNativePG (Barman Cloud) backups."
  type        = string
  default     = "keycloak-db-backups"
}

variable "bucket_location" {
  description = "Location hint for the bucket (e.g. APAC, ENAM, WEUR)."
  type        = string
  default     = "APAC"
}
