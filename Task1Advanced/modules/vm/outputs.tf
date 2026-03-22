output "vm_id" {
  description = "Идентификатор созданной виртуальной машины"
  value       = yandex_compute_instance.this.id
}

output "vm_name" {
  description = "Имя виртуальной машины"
  value       = yandex_compute_instance.this.name
}

output "vm_fqdn" {
  description = "Полное доменное имя (FQDN) виртуальной машины"
  value       = yandex_compute_instance.this.fqdn
}

output "internal_ip" {
  description = "Внутренний IP-адрес виртуальной машины"
  value       = yandex_compute_instance.this.network_interface[0].ip_address
}

output "external_ip" {
  description = "Внешний (публичный) IP-адрес виртуальной машины (null, если NAT отключён)"
  value       = var.nat ? yandex_compute_instance.this.network_interface[0].nat_ip_address : null
}

output "boot_disk_id" {
  description = "Идентификатор загрузочного диска"
  value       = yandex_compute_disk.boot.id
}

output "secondary_disk_id" {
  description = "Идентификатор дополнительного диска (null, если не создан)"
  value       = local.create_sec_disk ? yandex_compute_disk.secondary[0].id : null
}

output "zone" {
  description = "Зона доступности, в которой размещена ВМ"
  value       = yandex_compute_instance.this.zone
}
