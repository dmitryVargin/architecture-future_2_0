module "vm" {
  source = "../../modules/vm"

  env_name            = "dev"
  vm_name             = "future2-app"
  cores               = 2
  memory              = 2
  core_fraction       = 20
  boot_disk_size      = 15
  boot_disk_type      = "network-hdd"
  boot_disk_image_id  = var.boot_disk_image_id
  secondary_disk_size = 20
  secondary_disk_type = "network-hdd"
  subnet_id           = var.subnet_id
  zone                = var.zone
  nat                 = true
  ssh_public_key      = var.ssh_public_key
  preemptible         = true

  labels = {
    project = "future2"
    team    = "platform"
  }
}
