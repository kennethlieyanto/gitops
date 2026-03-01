variable "proxmox_endpoint" {
  description = "Proxmox API Endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Use secure connection or not"
  type        = string
}

variable "proxmox_ssh_username" {
  description = "SSH Username"
  type        = string
}

variable "proxmox_ubuntu_cloudimg_url" {
  description = "Ubuntu Cloud Image Url"
  type        = string
}

variable "proxmox_node_name" {
  description = "Node name" # currently only one
  type        = string
}

variable "ubuntu_01_vm_ip_address" {
  description = "ubuntu-01 ip address"
  type        = string
}

variable "ubuntu_01_vm_gateway" {
  description = "ubuntu-01 gateway"
  type        = string
}

variable "ubuntu_01_vm_username" {
  description = "Linux user account username"
  type        = string
}

variable "ubuntu_01_vm_name" {
  description = "VM Name displayed in Proxmox"
  type        = string
}

variable "ssh_public_key" {
  description = "Path to SSH public key"
  type        = string
}

variable "ubuntu_02_vm_ip_address" {
  description = "ubuntu-01 ip address"
  type        = string
}

variable "ubuntu_02_vm_gateway" {
  description = "ubuntu-01 gateway"
  type        = string
}

variable "ubuntu_02_vm_username" {
  description = "Linux user account username"
  type        = string
}

variable "ubuntu_02_vm_name" {
  description = "VM Name displayed in Proxmox"
  type        = string
}


variable "ingress_vm_ip_address" {
  description = "ubuntu-01 ip address"
  type        = string
}

variable "ingress_vm_gateway" {
  description = "ubuntu-01 gateway"
  type        = string
}

variable "ingress_vm_username" {
  description = "Linux user account username"
  type        = string
}

variable "ingress_vm_name" {
  description = "VM Name displayed in Proxmox"
  type        = string
}


variable "ingress_stage_vm_ip_address" {
  description = "ubuntu-01 ip address"
  type        = string
}

variable "ingress_stage_vm_gateway" {
  description = "ubuntu-01 gateway"
  type        = string
}

variable "ingress_stage_vm_username" {
  description = "Linux user account username"
  type        = string
}

variable "ingress_stage_vm_name" {
  description = "VM Name displayed in Proxmox"
  type        = string
}


