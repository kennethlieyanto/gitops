resource "proxmox_virtual_environment_container" "ubuntu_ct_01" {
  description = "Managed by Terraform"

  node_name = var.proxmox_node_name
  vm_id     = 111

  # newer linux distributions require unprivileged user namespaces
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "ubuntu-ct-01"

    ip_config {
      ipv4 {
        address = var.ubuntu_ct_01_ip_address
        gateway = var.ubuntu_ct_01_gateway
      }
    }

    user_account {
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
      password = var.ubuntu_ct_01_password
    }
  }

  network_interface {
    name = "veth0"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 6
  }

  operating_system {
    # template_file_id = proxmox_virtual_environment_download_file.ubuntu_2404_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

variable "ubuntu_ct_01_ip_address" {
  description = "ubuntu-01 ip address"
  type        = string
}

variable "ubuntu_ct_01_gateway" {
  description = "ubuntu-01 gateway"
  type        = string
}

variable "ubuntu_ct_01_password" {
  description = "Linux user account username"
  type        = string
}
