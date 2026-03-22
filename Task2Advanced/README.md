# Task 2 — Интеграция с CI/CD и удалённым хранением состояния

## Описание

Автоматизация развёртывания инфраструктуры «Будущее 2.0» через GitHub Actions с хранением Terraform state в Yandex Object Storage (S3-совместимое хранилище) и блокировкой состояния через YDB (DynamoDB-совместимый API).

## Структура проекта

```
Task2Advanced/
├── backend.tf                          # Конфигурация backend (S3 + DynamoDB lock)
├── main.tf                             # Основная конфигурация с модулем VM
├── variables.tf                        # Переменные
├── outputs.tf                          # Выходные значения
├── .github/
│   └── workflows/
│       └── terraform.yml               # CI/CD pipeline
└── README.md
```

## Удалённое хранение состояния

### Backend — Yandex Object Storage (S3)

Terraform state хранится в S3-совместимом бакете Yandex Object Storage. Каждое окружение использует отдельный бакет, что обеспечивает полную изоляцию состояний.

| Параметр | Значение |
|----------|----------|
| Endpoint | `https://storage.yandexcloud.net` |
| Бакет | `future2-tf-state-{env}` |
| Ключ | `{env}/terraform.tfstate` |
| Регион | `ru-central1` |

### Блокировка состояния — YDB (DynamoDB API)

Для предотвращения одновременных изменений используется таблица блокировок в YDB через DynamoDB-совместимый API.

| Параметр | Значение |
|----------|----------|
| Endpoint | `https://docapi.serverless.yandexcloud.net/...` |
| Таблица | `tf-lock-table` |

### Подготовка инфраструктуры для backend

1. **Создать бакет в Object Storage** для каждого окружения:

```bash
yc storage bucket create --name future2-tf-state-dev
yc storage bucket create --name future2-tf-state-stage
yc storage bucket create --name future2-tf-state-prod
```

2. **Включить версионирование** бакетов (для возможности восстановления state):

```bash
yc storage bucket update --name future2-tf-state-dev --versioning versioning-enabled
```

3. **Включить шифрование на стороне сервера** (SSE):

```bash
yc storage bucket update --name future2-tf-state-dev \
  --encryption '{"rules": [{"kmskeyid": "<KMS_KEY_ID>", "sseAlgorithm": "aws:kms"}]}'
```

4. **Создать YDB Serverless базу** и таблицу для блокировок:

```bash
yc ydb database create --name tf-locks --serverless
```

Таблица `tf-lock-table` создаётся со следующей схемой:
- `LockID` (String) — первичный ключ
- `Info` (String) — информация о блокировке

5. **Создать сервисный аккаунт** с ролями:
   - `storage.editor` — для работы с Object Storage
   - `ydb.editor` — для работы с YDB
   - `editor` — для управления ресурсами Compute

```bash
yc iam service-account create --name tf-ci-sa
yc iam access-key create --service-account-name tf-ci-sa
```

Полученные `access_key` и `secret` используются как `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY`.

## CI/CD Pipeline

### Схема работы

```
┌─────────────┐     ┌──────────┐     ┌───────────────┐
│  Validate   │────▶│   Plan   │────▶│    Apply      │
│  fmt+init   │     │  + save  │     │  (manual      │
│  +validate  │     │ artifact │     │   approval)   │
└─────────────┘     └──────────┘     └───────────────┘
```

### Триггеры запуска

| Триггер | Описание |
|---------|----------|
| `push` на `main` | Автоматический запуск при изменениях в `Task2Advanced/` |
| `pull_request` на `main` | Запуск при создании PR с изменениями в `Task2Advanced/` |
| `workflow_dispatch` | Ручной запуск с выбором окружения и действия |

### Jobs

#### 1. Validate
- Проверка форматирования (`terraform fmt -check`)
- Инициализация без backend (`terraform init -backend=false`)
- Валидация конфигурации (`terraform validate`)

#### 2. Plan
- Инициализация с backend для выбранного окружения
- Создание плана изменений (`terraform plan -out=tfplan`)
- Сохранение плана как артефакта GitHub Actions (хранение 5 дней)

#### 3. Apply
- Запускается **только** при ручном выборе действия `apply`
- Требует **manual approval** через GitHub Environment Protection Rules
- Скачивает артефакт плана из предыдущего шага
- Применяет **именно тот план**, который был проверен на этапе Plan

### Настройка GitHub Secrets

В настройках репозитория (Settings → Secrets and variables → Actions) необходимо создать:

| Secret | Описание |
|--------|----------|
| `YC_TOKEN` | OAuth-токен или IAM-токен Yandex Cloud |
| `YC_CLOUD_ID` | Идентификатор облака |
| `YC_FOLDER_ID` | Идентификатор каталога |
| `AWS_ACCESS_KEY_ID` | Access Key от сервисного аккаунта YC |
| `AWS_SECRET_ACCESS_KEY` | Secret Key от сервисного аккаунта YC |

### Настройка Environment Protection Rules

Для контроля применения изменений настройте окружения в GitHub:

1. Перейдите в Settings → Environments
2. Создайте окружения: `dev-apply`, `stage-apply`, `prod-apply`
3. Для `stage-apply` и `prod-apply` добавьте:
   - **Required reviewers** — список пользователей, которые должны одобрить apply
   - **Wait timer** (опционально) — задержка перед применением (например, 5 минут для prod)

## Безопасность

### Принцип наименьших привилегий

- Сервисный аккаунт CI/CD имеет только необходимые роли
- Токены передаются исключительно через GitHub Secrets (зашифрованы AES-256)
- Секреты не логируются в выводе pipeline (маскируются автоматически)

### Изоляция окружений

- Каждое окружение использует **отдельный бакет** для хранения state
- Отдельные **ключи** state внутри бакета
- **Environment Protection Rules** предотвращают несанкционированный apply в prod

### Защита state-файла

- State хранится **только удалённо** — локальные копии не создаются
- Версионирование бакета позволяет восстановить предыдущее состояние
- Шифрование на стороне сервера (SSE) через Yandex KMS
- Блокировка через YDB предотвращает одновременные изменения (race condition)

### Аудит

- Все запуски pipeline отображаются в GitHub Actions с полным логом
- Object Storage ведёт журнал доступа к бакетам
- YDB записывает операции блокировки/разблокировки

## Запуск вручную

### Через GitHub Actions UI

1. Перейдите в Actions → Terraform CI/CD → Run workflow
2. Выберите окружение (`dev`, `stage`, `prod`)
3. Выберите действие (`plan` или `apply`)
4. Нажмите **Run workflow**

### Локальный запуск

```bash
cd Task2Advanced

export AWS_ACCESS_KEY_ID="<YOUR_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<YOUR_SECRET_KEY>"

terraform init \
  -backend-config="bucket=future2-tf-state-dev" \
  -backend-config="key=dev/terraform.tfstate"

terraform plan -var="yc_token=<TOKEN>" -var="yc_cloud_id=<CLOUD_ID>" -var="yc_folder_id=<FOLDER_ID>"

terraform apply -var="yc_token=<TOKEN>" -var="yc_cloud_id=<CLOUD_ID>" -var="yc_folder_id=<FOLDER_ID>"
```
