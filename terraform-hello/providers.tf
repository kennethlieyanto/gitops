terraform {
  required_version = "~> 1.11"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.18.101:8006/"

  api_token = "root@pam!terraform-user=c46a1791-4a52-4512-ac79-5805b7951793"

  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    agent    = true
    username = "root"
  }
}

