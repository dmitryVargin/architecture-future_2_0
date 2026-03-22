variable "yc_token" {
  description = "OAuth-токен или IAM-токен для Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Идентификатор облака Yandex Cloud"
  type        = string
}

variable "yc_folder_id" {
  description = "Идентификатор каталога Yandex Cloud"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_id" {
  description = "ID подсети для размещения ВМ"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
}

variable "boot_disk_image_id" {
  description = "ID образа для загрузочного диска (например, Ubuntu 22.04)"
  type        = string
}
