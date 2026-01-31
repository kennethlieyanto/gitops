variable "proxmox_endpoint" {
  description = "Proxmox API Endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "proxmox_ssh_username" {
  description = "SSH Username"
  type        = string
}
