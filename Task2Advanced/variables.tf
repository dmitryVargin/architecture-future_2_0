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

variable "environment" {
  description = "Имя окружения (dev, stage, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Допустимые значения: dev, stage, prod."
  }
}
