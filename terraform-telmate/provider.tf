terraform {
  required_version = "~> 1.11"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://kennethl-pve:8006/api2/json"
  pm_tls_insecure = true
}

