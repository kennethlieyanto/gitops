terraform {
  required_version = "~> 1.11"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
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

