resource "proxmox_virtual_environment_vm" "k8s_node_1" {
  name      = "k8s-node-1"
  node_name = "kennethl-pve"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 1024 * 2
  }

  initialization {
    dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = "192.168.18.111/24"
        gateway = "192.168.18.1"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.k8s_node_1_cloud_config.id
  }

  started = false
}

resource "proxmox_virtual_environment_vm" "k8s_node_2" {
  name      = "k8s-node-2"
  node_name = "kennethl-pve"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 1024 * 2
  }

  initialization {
    dns {
      servers = ["1.1.1.1"]
    }
    ip_config {
      ipv4 {
        address = "192.168.18.112/24"
        gateway = "192.168.18.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.k8s_node_2_cloud_config.id
  }

  started = false
}
resource "proxmox_virtual_environment_file" "k8s_node_1_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "kennethl-pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: k8s-node-1
    timezone: Asia/Jakarta
    users:
      - default
      - name: kennethl
        groups: 
          - sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config-k8s-node-1.yaml"
  }
}

resource "proxmox_virtual_environment_file" "k8s_node_2_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "kennethl-pve"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: k8s-node-2
    timezone: Asia/Jakarta
    users:
      - default
      - name: kennethl
        groups: 
          - sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config-k8s-node-2.yaml"
  }
}
