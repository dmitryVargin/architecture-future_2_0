variable "env_name" {
  description = "Название окружения (dev, stage, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env_name)
    error_message = "Допустимые значения: dev, stage, prod."
  }
}

variable "vm_name" {
  description = "Базовое имя виртуальной машины"
  type        = string
  default     = "vm"
}

variable "platform_id" {
  description = "Идентификатор платформы Yandex Cloud (standard-v1, standard-v2, standard-v3)"
  type        = string
  default     = "standard-v3"
}

variable "cores" {
  description = "Количество ядер vCPU"
  type        = number

  validation {
    condition     = var.cores >= 2 && var.cores <= 96
    error_message = "Количество ядер должно быть от 2 до 96."
  }
}

variable "memory" {
  description = "Объём оперативной памяти в ГБ"
  type        = number

  validation {
    condition     = var.memory >= 1 && var.memory <= 640
    error_message = "Объём памяти должен быть от 1 до 640 ГБ."
  }
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU в процентах (5, 20, 50, 100)"
  type        = number
  default     = 100

  validation {
    condition     = contains([5, 20, 50, 100], var.core_fraction)
    error_message = "Допустимые значения: 5, 20, 50, 100."
  }
}

variable "boot_disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20

  validation {
    condition     = var.boot_disk_size >= 10 && var.boot_disk_size <= 4096
    error_message = "Размер загрузочного диска должен быть от 10 до 4096 ГБ."
  }
}

variable "boot_disk_type" {
  description = "Тип загрузочного диска (network-hdd, network-ssd, network-ssd-nonreplicated)"
  type        = string
  default     = "network-hdd"

  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.boot_disk_type)
    error_message = "Допустимые типы: network-hdd, network-ssd, network-ssd-nonreplicated."
  }
}

variable "boot_disk_image_id" {
  description = "ID образа для загрузочного диска"
  type        = string
}

variable "secondary_disk_size" {
  description = "Размер дополнительного подключаемого диска в ГБ (0 — диск не создаётся)"
  type        = number
  default     = 0

  validation {
    condition     = var.secondary_disk_size >= 0 && var.secondary_disk_size <= 8192
    error_message = "Размер дополнительного диска должен быть от 0 до 8192 ГБ."
  }
}

variable "secondary_disk_type" {
  description = "Тип дополнительного подключаемого диска"
  type        = string
  default     = "network-hdd"

  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.secondary_disk_type)
    error_message = "Допустимые типы: network-hdd, network-ssd, network-ssd-nonreplicated."
  }
}

variable "subnet_id" {
  description = "ID подсети для размещения ВМ"
  type        = string
}

variable "zone" {
  description = "Зона доступности Yandex Cloud"
  type        = string
  default     = "ru-central1-a"

  validation {
    condition     = can(regex("^ru-central1-[a-d]$", var.zone))
    error_message = "Зона должна соответствовать формату ru-central1-[a-d]."
  }
}

variable "nat" {
  description = "Выдать публичный IP-адрес (NAT)"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
}

variable "ssh_user" {
  description = "Имя пользователя для SSH-доступа"
  type        = string
  default     = "ubuntu"
}

variable "preemptible" {
  description = "Создать прерываемую (preemptible) ВМ для экономии"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Метки ресурсов для управления и учёта затрат"
  type        = map(string)
  default     = {}
}
