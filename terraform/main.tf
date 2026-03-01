data "local_file" "ssh_public_key" {
  filename = "./id_ed25519.pub"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  url          = var.proxmox_ubuntu_cloudimg_url
  file_name    = "ubuntu-24.04-server-cloudimg-amd64.qcow2"
}

module "ubuntu_01" {
  source = "./modules/vm"
  providers = {
    proxmox = proxmox
  }

  vm_name                = var.ubuntu_01_vm_name
  node_name              = var.proxmox_node_name
  ip_address             = var.ubuntu_01_vm_ip_address
  gateway                = var.ubuntu_01_vm_gateway
  username               = var.ubuntu_01_vm_username
  ssh_public_key_content = data.local_file.ssh_public_key.content
  cloud_image_id         = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

module "ubuntu_02" {
  source = "./modules/vm"
  providers = {
    proxmox = proxmox
  }

  vm_name                = var.ubuntu_02_vm_name
  node_name              = var.proxmox_node_name
  ip_address             = var.ubuntu_02_vm_ip_address
  gateway                = var.ubuntu_02_vm_gateway
  username               = var.ubuntu_02_vm_username
  ssh_public_key_content = data.local_file.ssh_public_key.content
  cloud_image_id         = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

module "ingress" {
  source = "./modules/vm"
  providers = {
    proxmox = proxmox
  }

  vm_name                = var.ingress_vm_name
  node_name              = var.proxmox_node_name
  ip_address             = var.ingress_vm_ip_address
  gateway                = var.ingress_vm_gateway
  username               = var.ingress_vm_username
  ssh_public_key_content = data.local_file.ssh_public_key.content
  cloud_image_id         = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}

module "ingress_stage" {
  source = "./modules/vm"
  providers = {
    proxmox = proxmox
  }

  vm_name                = var.ingress_stage_vm_name
  node_name              = var.proxmox_node_name
  ip_address             = var.ingress_stage_vm_ip_address
  gateway                = var.ingress_stage_vm_gateway
  username               = var.ingress_stage_vm_username
  ssh_public_key_content = data.local_file.ssh_public_key.content
  cloud_image_id         = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
}
