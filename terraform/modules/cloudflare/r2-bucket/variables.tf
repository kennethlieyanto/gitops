variable "account_id" {
  description = "Cloudflare account ID that owns the R2 bucket."
  type        = string
}

variable "name" {
  description = "Name of the R2 bucket."
  type        = string
}

variable "location" {
  description = "Location hint for the bucket (e.g. APAC, ENAM, WEUR)."
  type        = string
  default     = "APAC"
}

variable "abort_multipart_uploads_after_seconds" {
  description = "Age in seconds after which incomplete multipart uploads are aborted."
  type        = number
  default     = 86400
}

variable "lifecycle_rules" {
  description = "Additional R2 lifecycle rules appended after the module defaults."
  type        = list(any)
  default     = []
}
