locals {
  full_name       = "${var.env_name}-${var.vm_name}"
  common_labels   = merge(var.labels, { environment = var.env_name })
  create_sec_disk = var.secondary_disk_size > 0
}

resource "yandex_compute_disk" "boot" {
  name     = "${local.full_name}-boot"
  zone     = var.zone
  size     = var.boot_disk_size
  type     = var.boot_disk_type
  image_id = var.boot_disk_image_id
  labels   = local.common_labels
}

resource "yandex_compute_disk" "secondary" {
  count  = local.create_sec_disk ? 1 : 0
  name   = "${local.full_name}-data"
  zone   = var.zone
  size   = var.secondary_disk_size
  type   = var.secondary_disk_type
  labels = local.common_labels
}

resource "yandex_compute_instance" "this" {
  name        = local.full_name
  hostname    = local.full_name
  platform_id = var.platform_id
  zone        = var.zone
  labels      = local.common_labels

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot.id
  }

  dynamic "secondary_disk" {
    for_each = local.create_sec_disk ? [1] : []
    content {
      disk_id     = yandex_compute_disk.secondary[0].id
      auto_delete = false
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }
}
