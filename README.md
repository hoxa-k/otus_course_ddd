# Домашние задания по курсу "Domain Driven Design и асинхронная архитектура"

## ДЗ 2 "Качество кода и богатая модель"
VO Email [email.dart](lib/domain/models/email.dart), Points [points.dart](lib/domain/models/points.dart) + тесты  [email_test.dart](test/email_test.dart)  [points_test.dart](test/points_test.dart)

[user_model.dart](lib/domain/models/user_model.dart) - пример плохого кода Доменной модели UserModel. 
Нарушен принцип единой ответственности SOLID

[user_model_corrected.dart](lib/domain/models/user_model_corrected.dart) - предложенный рефакторинг. 
Выделить методы подсчета баллов в доменную сущность другого домена. Заменить примитивы на VO.

## ДЗ 3 "Проектирование Агрегатов и их жизненный цикл"

Агрегат Order [order.dart](lib/domain/models/order.dart)

Интерфейс репозитория [i_order_repository.dart](lib/interfaces/repositories/i_order_repository.dart)

Реализация in memory репозитория [in_memory_order_repository.dart](lib/infrastructure/repositories/in_memory_order_repository.dart)

Ревлизована фабрика для создания агрегата Order через статический метод [order.dart](lib/domain/models/order.dart#L32-L43)

Тесты для проверки создания агрегата Order и сохранения в репозиторий [order_test.dart](test/order_test.dart)

## ДЗ 4 "Сервисы и события в домене"

Необходимо реализовать операцию расчета стоимости игровых продуктов для пользователя в зависимости от статуса этого пользователя и количества продуктов в заказе. Если количество продуктов в заказе меньше заданного, то скидка не применяется совсем, если больше или равна, то применяется скидка в зависимости от статуса пользователя.

Данная операция зависит от агрегата Order и агрегата User. Доменный сервис для расчета скидки: [discount_service.dart](lib/domain/services/discount_service.dart)

Доменное событие [OrderConfirmedEvent](lib/domain/events/order_confirmed_event.dart) вызывает отправку email через инфраструктурный сервис. Реализовано в [SendOrderConfirmationHandler](lib/application/send_order_confirmation_handler.dart)

## ДЗ 5 "Хранение данных и согласованность"

### Маппинг в БД
```
CREATE TABLE orders (
    id BINARY(16) PRIMARY KEY,
    customer_id BINARY(16) NOT NULL,
    status ENUM('draft', 'created', 'confirmed', 'paid', 'pending', 'canceled') NOT NULL,
);

CREATE TABLE order_lines (
    id BINARY(16) DEFAULT (UUID_TO_BIN(UUID(), 1)) PRIMARY KEY,
    order_id BINARY(16) NOT NULL,
    product_id BINARY(16) NOT NULL,
    quantity INT NOT NULL,
);

CREATE TABLE users (
    id BINARY(16) DEFAULT (UUID_TO_BIN(UUID(), 1)) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    balance INTt DEFAULT 0,
    status ENUM('beginner', 'advanced', 'master') NOT NULL,
);
```
ValueObject Points в данном случае сохрянен как одно поле в таблице (Users --> balance), так как у этого VO только одно свойство со значением. Если бы было еще одно свойство, например название валюты, можно в соответствующей таблице сделать два поля: balance_count, balance_currency.

### Оптимистичные блокировки

Добавим поле version в таблицу Orders
```
ALTER TABLE orders
ADD version INT DEFAULT 0;
```

```
UPDATE orders
SET customer_id = (UUID_TO_BIN('1233', 1)), status = created, version = version + 1
WHERE id = (UUID_TO_BIN('1233', 1));
```

### Проектирование Саги (Saga)

#### Бизнес-процесс "Оформление и оплата заказа"
**Orders (Заказы)**: Управляет состоянием заказа ('draft', 'created', 'confirmed', 'pending', 'paid', 'canceled'). Отвечает за логику создания и фиксации.

**Payments (Платежи):** Обрабатывает списание средств, хранит транзакции.

**Notifications (Уведомления):** Отправляет уведомления (email/SMS/PUSH) о статусе операции.

#### Позитивный сценарий (Happy path)
**Orders:** Получает команду 'Оплатить заказ'. Если заказ в статусе 'confirmed', сохраняет заказ со статусом 'pending'. Отправляет команду 'Списать средства'

**Payments:** Получает команду на списание, успешно проводит операцию, возвращает 'success'.

**Orders:** Меняет статус заказа на 'paid'.

**Notifications:** Получает команду, отправляет клиенту чек и уведомление об успешной оплате.

#### Негативный сценарий
**Orders:** Получает команду 'Оплатить заказ'. Если заказ в статусе 'confirmed', сохраняет заказ со статусом 'pending'. Отправляет команду 'Списать средства'

**Payments:** Получает команду на списание, операция по списанию заканчивается ошибкой (например, недостаточно средств), возвращает 'error'.

**Orders:** Меняет статус заказа на 'canceled'.

**Notifications:** Получает команду, отправляет клиенту уведомление об ошибке при оплате.

### Идемпотентный обработчик

```

Future<bool> handle(OrderPaidEvent event) async {
  if( await _eventsRepository.eventExists(event.id) {
    return true;
  }
  
  try {
    _emailService.sendEmail(to: userEmail, message: 'Success message');
    _eventsRepository.saveEvent(event.id);
   } catch (e) {
      throw Exception('Failed to process event ${event.id}');
   }
}
```