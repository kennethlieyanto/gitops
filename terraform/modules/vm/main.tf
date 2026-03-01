terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.vm_name
  node_name = var.node_name

  stop_on_destroy = true

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      username = var.username
      keys     = [trimspace(var.ssh_public_key_content)]
    }
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = var.cloud_image_id
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
