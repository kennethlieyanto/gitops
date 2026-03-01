variable "vm_name" {
  description = "VM Name displayed in Proxmox"
  type        = string
}

variable "node_name" {
  description = "Node name"
  type        = string
}

variable "ip_address" {
  description = "VM IP address"
  type        = string
}

variable "gateway" {
  description = "VM gateway"
  type        = string
}

variable "username" {
  description = "Linux user account username"
  type        = string
}

variable "ssh_public_key_content" {
  description = "SSH public key content"
  type        = string
}

variable "cloud_image_id" {
  description = "ID of the imported cloud image"
  type        = string
}
