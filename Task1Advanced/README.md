# Task 1 — Модульная инфраструктура для нескольких сред

## Описание

Переиспользуемый Terraform-модуль для создания виртуальных машин в Yandex Cloud. Модуль поддерживает развёртывание в трёх окружениях (dev, stage, prod) с различными конфигурациями ресурсов.

## Структура проекта

```
Task1Advanced/
├── modules/
│   └── vm/
│       ├── main.tf          # Ресурсы: ВМ, загрузочный диск, дополнительный диск
│       ├── variables.tf     # Входные параметры модуля
│       └── outputs.tf       # Выходные значения модуля
├── envs/
│   ├── dev/                 # Окружение разработки
│   │   ├── provider.tf      # Конфигурация провайдера
│   │   ├── main.tf          # Вызов модуля с параметрами dev
│   │   ├── variables.tf     # Переменные окружения
│   │   ├── outputs.tf       # Выходы окружения
│   │   └── terraform.tfvars # Значения переменных для dev
│   ├── stage/               # Окружение тестирования
│   │   └── ...              # Аналогичная структура
│   └── prod/                # Продуктивное окружение
│       └── ...              # Аналогичная структура
└── README.md
```

## Параметры модуля (inputs)

| Параметр | Тип | Обязательный | По умолчанию | Описание |
|----------|-----|:---:|--------------|----------|
| `env_name` | `string` | Да | — | Название окружения (`dev`, `stage`, `prod`) |
| `vm_name` | `string` | Нет | `"vm"` | Базовое имя виртуальной машины |
| `platform_id` | `string` | Нет | `"standard-v3"` | Платформа Yandex Cloud |
| `cores` | `number` | Да | — | Количество ядер vCPU (2–96) |
| `memory` | `number` | Да | — | Объём RAM в ГБ (1–640) |
| `core_fraction` | `number` | Нет | `100` | Гарантированная доля vCPU (5, 20, 50, 100) |
| `boot_disk_size` | `number` | Нет | `20` | Размер загрузочного диска в ГБ |
| `boot_disk_type` | `string` | Нет | `"network-hdd"` | Тип загрузочного диска |
| `boot_disk_image_id` | `string` | Да | — | ID образа ОС |
| `secondary_disk_size` | `number` | Нет | `0` | Размер доп. диска в ГБ (0 — не создаётся) |
| `secondary_disk_type` | `string` | Нет | `"network-hdd"` | Тип дополнительного диска |
| `subnet_id` | `string` | Да | — | ID подсети |
| `zone` | `string` | Нет | `"ru-central1-a"` | Зона доступности |
| `nat` | `bool` | Нет | `false` | Назначить публичный IP |
| `ssh_public_key` | `string` | Да | — | Публичный SSH-ключ |
| `ssh_user` | `string` | Нет | `"ubuntu"` | Имя пользователя SSH |
| `preemptible` | `bool` | Нет | `false` | Прерываемая ВМ |
| `labels` | `map(string)` | Нет | `{}` | Метки ресурсов |

## Выходные значения (outputs)

| Выход | Описание |
|-------|----------|
| `vm_id` | Идентификатор виртуальной машины |
| `vm_name` | Имя виртуальной машины |
| `vm_fqdn` | FQDN виртуальной машины |
| `internal_ip` | Внутренний IP-адрес |
| `external_ip` | Внешний IP-адрес (null, если NAT отключён) |
| `boot_disk_id` | ID загрузочного диска |
| `secondary_disk_id` | ID дополнительного диска (null, если не создан) |
| `zone` | Зона доступности |

## Конфигурации окружений

| Параметр | Dev | Stage | Prod |
|----------|-----|-------|------|
| vCPU | 2 | 4 | 8 |
| RAM | 2 ГБ | 8 ГБ | 16 ГБ |
| Доля vCPU | 20% | 50% | 100% |
| Загр. диск | 15 ГБ HDD | 30 ГБ SSD | 50 ГБ SSD |
| Доп. диск | 20 ГБ HDD | 50 ГБ SSD | 100 ГБ SSD |
| Прерываемая | Да | Нет | Нет |
| Зона | ru-central1-a | ru-central1-b | ru-central1-a |

## Запуск

### Предварительные требования

1. Установлен Terraform >= 1.4.0
2. Настроен доступ к Yandex Cloud (OAuth-токен или IAM-токен)
3. Созданы облако, каталог и подсеть в Yandex Cloud

### Развёртывание окружения

```bash
# Перейти в директорию нужного окружения
cd envs/dev

# Отредактировать terraform.tfvars — подставить реальные значения

# Инициализация
terraform init

# Просмотр плана
terraform plan -var-file=terraform.tfvars -var="yc_token=<YOUR_TOKEN>"

# Применение
terraform apply -var-file=terraform.tfvars -var="yc_token=<YOUR_TOKEN>"
```

Для stage и prod — аналогично, подставив соответствующую директорию:

```bash
cd envs/stage
terraform init
terraform plan -var-file=terraform.tfvars -var="yc_token=<YOUR_TOKEN>"
terraform apply -var-file=terraform.tfvars -var="yc_token=<YOUR_TOKEN>"
```

### Удаление инфраструктуры

```bash
terraform destroy -var-file=terraform.tfvars -var="yc_token=<YOUR_TOKEN>"
```

## Принципы проектирования

- **Переиспользуемость**: единый модуль для всех окружений, различия — только в параметрах `.tfvars`
- **Валидация**: все переменные содержат проверки допустимых значений
- **Безопасность**: токен передаётся как sensitive-переменная, не сохраняется в `.tfvars`
- **Экономия**: dev-окружение использует прерываемые ВМ и сниженную долю vCPU
- **Маркировка**: все ресурсы получают метки окружения для управления и учёта затрат
