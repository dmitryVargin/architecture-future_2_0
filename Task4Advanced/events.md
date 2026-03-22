# Каталог доменных событий «Будущее 2.0»

## Соглашения

- **Формат имени:** `<Домен>.<Сущность>.<Действие>` (PascalCase)
- **Транспорт:** Apache Kafka
- **Формат данных:** JSON + Avro-схема в Schema Registry
- **Версионирование:** семантическое (v1, v2, ...), обратная совместимость обязательна

## Управление пациентами

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Patient.Registered` | Управление пациентами | Клинические операции, Финансовые операции, Аналитика | Зарегистрирован новый пациент в системе | `{ "eventId": "uuid", "timestamp": "ISO8601", "patientId": "uuid", "fullName": "string", "birthDate": "date", "insurancePolicyId": "string", "registrationSource": "enum(clinic|online|partner)" }` |
| `Patient.ProfileUpdated` | Управление пациентами | Клинические операции, Финансовые операции | Обновлены персональные данные пациента | `{ "eventId": "uuid", "timestamp": "ISO8601", "patientId": "uuid", "changedFields": ["string"], "updatedBy": "uuid" }` |
| `Patient.ConsentGranted` | Управление пациентами | Аналитика, Платформа данных | Пациент дал согласие на обработку данных | `{ "eventId": "uuid", "timestamp": "ISO8601", "patientId": "uuid", "consentType": "enum(pd_processing|marketing|research)", "validUntil": "date" }` |
| `Patient.Archived` | Управление пациентами | Все домены | Пациент переведён в архив | `{ "eventId": "uuid", "timestamp": "ISO8601", "patientId": "uuid", "reason": "string" }` |
| `MedicalRecord.EntryAdded` | Управление пациентами | Исследования и ИИ, Аналитика | В мед. карту добавлена новая запись | `{ "eventId": "uuid", "timestamp": "ISO8601", "recordId": "uuid", "patientId": "uuid", "entryType": "enum(diagnosis|prescription|note)", "doctorId": "uuid" }` |

## Клинические операции

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Schedule.Published` | Клинические операции | Управление пациентами (для записи) | Расписание врача опубликовано | `{ "eventId": "uuid", "timestamp": "ISO8601", "scheduleId": "uuid", "doctorId": "uuid", "date": "date", "slots": [{"start": "time", "end": "time"}] }` |
| `Appointment.Created` | Клинические операции | Управление пациентами, Финансовые операции | Создана запись на приём | `{ "eventId": "uuid", "timestamp": "ISO8601", "appointmentId": "uuid", "patientId": "uuid", "doctorId": "uuid", "scheduledAt": "ISO8601", "serviceType": "string" }` |
| `Appointment.Completed` | Клинические операции | Исследования и ИИ, Финансовые операции, Аналитика | Приём врача завершён | `{ "eventId": "uuid", "timestamp": "ISO8601", "appointmentId": "uuid", "patientId": "uuid", "doctorId": "uuid", "diagnosisCodes": ["string"], "prescriptions": [{"type": "string", "details": "string"}] }` |
| `Appointment.Cancelled` | Клинические операции | Финансовые операции, Аналитика | Приём отменён | `{ "eventId": "uuid", "timestamp": "ISO8601", "appointmentId": "uuid", "patientId": "uuid", "reason": "string", "cancelledBy": "enum(patient|doctor|system)" }` |
| `Appointment.NoShow` | Клинические операции | Финансовые операции, Аналитика | Пациент не явился на приём | `{ "eventId": "uuid", "timestamp": "ISO8601", "appointmentId": "uuid", "patientId": "uuid" }` |

## Медицинские исследования и ИИ

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Research.Ordered` | Исследования и ИИ | Клинические операции, Финансовые операции | Назначено исследование | `{ "eventId": "uuid", "timestamp": "ISO8601", "researchId": "uuid", "patientId": "uuid", "appointmentId": "uuid", "researchType": "string", "priority": "enum(normal|urgent)" }` |
| `Research.SampleCollected` | Исследования и ИИ | Инвентаризация | Биоматериал собран | `{ "eventId": "uuid", "timestamp": "ISO8601", "researchId": "uuid", "sampleId": "uuid", "collectedBy": "uuid" }` |
| `Research.ResultReady` | Исследования и ИИ | Клинические операции, Управление пациентами, Аналитика | Результат исследования готов | `{ "eventId": "uuid", "timestamp": "ISO8601", "researchId": "uuid", "patientId": "uuid", "resultSummary": "string", "attachments": ["url"] }` |
| `AITask.Completed` | Исследования и ИИ | Клинические операции, Аналитика | ИИ-анализ завершён | `{ "eventId": "uuid", "timestamp": "ISO8601", "taskId": "uuid", "researchId": "uuid", "modelVersion": "string", "prediction": "string", "confidence": "float", "processingTimeMs": "int" }` |
| `AITask.Failed` | Исследования и ИИ | Клинические операции (для ручной обработки) | ИИ-анализ завершился с ошибкой | `{ "eventId": "uuid", "timestamp": "ISO8601", "taskId": "uuid", "researchId": "uuid", "errorCode": "string", "errorMessage": "string" }` |

## Финансовые операции

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Invoice.Issued` | Финансовые операции | Управление пациентами, Кредитование, Аналитика | Счёт выставлен пациенту/организации | `{ "eventId": "uuid", "timestamp": "ISO8601", "invoiceId": "uuid", "patientId": "uuid", "totalAmount": "decimal", "currency": "RUB", "items": [{"description": "string", "amount": "decimal"}], "dueDate": "date" }` |
| `Payment.Confirmed` | Финансовые операции | Клинические операции, Аналитика | Оплата подтверждена | `{ "eventId": "uuid", "timestamp": "ISO8601", "paymentId": "uuid", "invoiceId": "uuid", "amount": "decimal", "method": "enum(cash|card|insurance|credit)", "transactionRef": "string" }` |
| `Payment.Rejected` | Финансовые операции | Клинические операции | Оплата отклонена | `{ "eventId": "uuid", "timestamp": "ISO8601", "paymentId": "uuid", "invoiceId": "uuid", "reason": "string" }` |
| `Invoice.Overdue` | Финансовые операции | Кредитование, Аналитика | Счёт просрочен | `{ "eventId": "uuid", "timestamp": "ISO8601", "invoiceId": "uuid", "patientId": "uuid", "overdueAmount": "decimal", "daysPastDue": "int" }` |
| `Payment.Refunded` | Финансовые операции | Управление пациентами, Аналитика | Возврат средств выполнен | `{ "eventId": "uuid", "timestamp": "ISO8601", "paymentId": "uuid", "refundAmount": "decimal", "reason": "string" }` |

## Кредитование

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `CreditApplication.Submitted` | Кредитование | Финансовые операции, Аналитика | Подана заявка на кредит | `{ "eventId": "uuid", "timestamp": "ISO8601", "applicationId": "uuid", "applicantId": "uuid", "requestedAmount": "decimal", "productType": "string" }` |
| `CreditApplication.Approved` | Кредитование | Финансовые операции, Аналитика | Кредитная заявка одобрена | `{ "eventId": "uuid", "timestamp": "ISO8601", "applicationId": "uuid", "approvedAmount": "decimal", "interestRate": "float", "termMonths": "int", "scoringResult": "int" }` |
| `CreditApplication.Rejected` | Кредитование | Финансовые операции, Аналитика | Кредитная заявка отклонена | `{ "eventId": "uuid", "timestamp": "ISO8601", "applicationId": "uuid", "reason": "string", "scoringResult": "int" }` |
| `CreditContract.Created` | Кредитование | Финансовые операции, Аналитика | Кредитный договор создан | `{ "eventId": "uuid", "timestamp": "ISO8601", "contractId": "uuid", "applicationId": "uuid", "principalAmount": "decimal", "interestRate": "float", "startDate": "date", "endDate": "date" }` |
| `CreditContract.PaymentReceived` | Кредитование | Финансовые операции, Аналитика | Получен платёж по кредиту | `{ "eventId": "uuid", "timestamp": "ISO8601", "contractId": "uuid", "paymentAmount": "decimal", "principalPart": "decimal", "interestPart": "decimal", "remainingBalance": "decimal" }` |
| `CreditContract.Overdue` | Кредитование | Финансовые операции, Аналитика | Просрочка по кредиту | `{ "eventId": "uuid", "timestamp": "ISO8601", "contractId": "uuid", "overdueAmount": "decimal", "daysPastDue": "int" }` |

## Управление персоналом

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Employee.Hired` | Управление персоналом | Клинические операции, Аналитика | Принят новый сотрудник | `{ "eventId": "uuid", "timestamp": "ISO8601", "employeeId": "uuid", "role": "string", "department": "string", "startDate": "date" }` |
| `Employee.CertificateExpiring` | Управление персоналом | Клинические операции | Сертификат врача истекает через 30 дней | `{ "eventId": "uuid", "timestamp": "ISO8601", "employeeId": "uuid", "certificateType": "string", "expirationDate": "date" }` |
| `Employee.Terminated` | Управление персоналом | Клинические операции, Финансовые операции | Сотрудник уволен | `{ "eventId": "uuid", "timestamp": "ISO8601", "employeeId": "uuid", "terminationDate": "date", "reason": "string" }` |

## Инвентаризация

| Событие | Контекст-источник | Подписчики | Семантика | Минимальный контракт |
|---------|-------------------|------------|-----------|---------------------|
| `Inventory.Received` | Инвентаризация | Финансовые операции, Аналитика | Товар/оборудование получено на склад | `{ "eventId": "uuid", "timestamp": "ISO8601", "itemId": "uuid", "name": "string", "category": "enum(medicine|equipment|supplies)", "quantity": "int", "unitCost": "decimal" }` |
| `Inventory.LowStock` | Инвентаризация | Клинические операции | Остаток ниже минимального порога | `{ "eventId": "uuid", "timestamp": "ISO8601", "itemId": "uuid", "currentQuantity": "int", "minimumThreshold": "int" }` |
| `Inventory.Expired` | Инвентаризация | Клинические операции, Финансовые операции | Срок годности истёк (лекарства) | `{ "eventId": "uuid", "timestamp": "ISO8601", "itemId": "uuid", "name": "string", "quantity": "int", "expirationDate": "date" }` |
| `Inventory.MaintenanceDue` | Инвентаризация | Клинические операции | Оборудование требует поверки/обслуживания | `{ "eventId": "uuid", "timestamp": "ISO8601", "itemId": "uuid", "equipmentName": "string", "maintenanceType": "string", "dueDate": "date" }` |
