module "vm" {
  source = "../../modules/vm"

  env_name            = "stage"
  vm_name             = "future2-app"
  cores               = 4
  memory              = 8
  core_fraction       = 50
  boot_disk_size      = 30
  boot_disk_type      = "network-ssd"
  boot_disk_image_id  = var.boot_disk_image_id
  secondary_disk_size = 50
  secondary_disk_type = "network-ssd"
  subnet_id           = var.subnet_id
  zone                = var.zone
  nat                 = true
  ssh_public_key      = var.ssh_public_key
  preemptible         = false

  labels = {
    project = "future2"
    team    = "platform"
  }
}
