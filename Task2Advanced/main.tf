module "vm" {
  source = "../Task1Advanced/modules/vm"

  env_name            = var.environment
  vm_name             = "future2-app"
  cores               = var.environment == "prod" ? 8 : var.environment == "stage" ? 4 : 2
  memory              = var.environment == "prod" ? 16 : var.environment == "stage" ? 8 : 2
  core_fraction       = var.environment == "prod" ? 100 : var.environment == "stage" ? 50 : 20
  boot_disk_size      = var.environment == "prod" ? 50 : var.environment == "stage" ? 30 : 15
  boot_disk_type      = var.environment == "dev" ? "network-hdd" : "network-ssd"
  boot_disk_image_id  = "fd8v3n0p7hqtg1ubuntu"
  secondary_disk_size = var.environment == "prod" ? 100 : var.environment == "stage" ? 50 : 20
  secondary_disk_type = var.environment == "dev" ? "network-hdd" : "network-ssd"
  subnet_id           = "e9bkf3mn01subnet5az"
  zone                = var.zone
  nat                 = true
  ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7Rk3vZpFmKdT9nQ2xHj ci@future2"
  preemptible         = var.environment == "dev"

  labels = {
    project     = "future2"
    managed_by  = "terraform"
    environment = var.environment
  }
}
