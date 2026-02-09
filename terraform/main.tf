terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.97.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  tmp_dir   = "/var/tmp"

  ssh {
    agent    = true
    username = var.proxmox_ssh_username
  }
}

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

data "local_file" "ssh_public_key" {
  filename = "./id_ed25519.pub"
}

resource "proxmox_virtual_environment_vm" "ubuntu_01_vm" {
  name      = var.ubuntu_01_vm_name
  node_name = var.proxmox_node_name

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = true

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = var.ubuntu_01_vm_ip_address
        gateway = var.ubuntu_01_vm_gateway
      }
    }

    user_account {
      username = var.ubuntu_01_vm_username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  memory {
    dedicated = 2048
    floating  = 0
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_02_vm" {
  name      = var.ubuntu_02_vm_name
  node_name = var.proxmox_node_name

  # should be true if qemu agent is not installed / enabled on the VM
  stop_on_destroy = true

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = var.ubuntu_02_vm_ip_address
        gateway = var.ubuntu_02_vm_gateway
      }
    }

    user_account {
      username = var.ubuntu_02_vm_username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  memory {
    dedicated = 2048
    floating  = 0
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = var.proxmox_ubuntu_cloudimg_url
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
}

