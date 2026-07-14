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
    quantity INTEGER NOT NULL,
);

CREATE TABLE users (
    id BINARY(16) DEFAULT (UUID_TO_BIN(UUID(), 1)) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    balance DOUBLE DEFAULT 0.00,
    status ENUM('beginner', 'advanced', 'master') NOT NULL,
);
```
В таблице users id - это ключ БД, создается автоматически при добавлении новой записи, user_id - это id доменной модели, сквозное для различных доменов, что бы была возможность связать жизненный цикл сущности в разных доменах. Возможно, это здесь излишне.

ValueObject Points в данном случае сохрянен как одно поле в таблице (Users --> balance), так как у этого VO только одно свойство со значением. Если бы было еще одно свойство, например название валюты, можно в соответствующей таблице сделать два поля: balance_count, balance_currency.

### Оптимистичные блокировки

Добавим поле version в таблицу Orders
```
ALTER TABLE orders
ADD version INTEGER DEFAULT 0;
```

```
UPDATE orders
SET customer_id = (UUID_TO_BIN('1233', 1)), status = created, version = version + 1
WHERE id = (UUID_TO_BIN('1233', 1)) AND version = expected_version;
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

## ДЗ 6 "Асинхронная интеграция и защита от внешнего мира"

### Интеграционное событие
```
{
  "eventId": "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d9e0f",
  "eventType": "OrderConfirmedEvent",
  "meta": {
    "schemaId": "1.0",
    "producer": "Orders",
    "correlationId": "12134",
  },
  "data": {
    "orderId": "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d9ert",
    "confirmedAt": "2026-06-26T10:15:55Z",
    "customerId":  "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d96jk",
    "items": [
      {
        "productId": "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d9psk",
        "title": "Доспехи рыцаря",
        "quantity": 1,
        "price": 100
      }
    ]
  }
}
```
**eventId** - для идемпотентности операции

**eventType** - для определения кому предназначено сообщения (для маршрутизации)

**schemaId** - для идентификации формата сообщения в случае изменения формата.

**producer** - для отладки, отслеживания процесса в логах

**correlationId** - Сквозное ID бизнес-операции. Упрощает трассировку логов.

**Метаданные**

**items** - данные по составу заказа для тела уведомления

**customerId** - id пользователя, по которому определять контактные данные для уведомлений. Для безопасной передачи даннх во внешнюю систему лучше не передавать в сообщении ФИО и контактные данные. Можно либо синхронизировать данные во внешнем микросервисе с микросервисом пользователей, либо запрашивать контактные данные пользователя у микросервиса пользователей непосредственно при обработке данных сообщения.

### Надежная публикация

```
Future handle(ConfirmOrderCommand command) async {
    final order = _orderRepository.findById(command.orderId);
    if (order == null) throw OrderCreateException('Order not found');
    order.confirm();
    try {
    
    await _repository.transactional((_) async {
      await _orderRepository.save(order);
      
      for (final event in order.domainEvents) {
        final outboxMessage = OutboxMessage(
            id: Uuid().v4(),
            type: event.runtimeType.toString(),
            payload: event.toJson();
            occuredAt: DateTime.now();
        );
        await _outboxRepository.add(outboxMessage);
      }
    });
    
    order.clearDomainEvents();
    
  } catch (e) {
    throw Exception("Transaction failed and rolled back automatically. Error: $e");
  }

}
```

Фоновый процесс (Message Relay/Publisher) опросит таблицу outbox_messages и опубликует сообщение в брокер (RabbitMQ, Kafka), пометит событие как опубликованное.

### Защитный слой (ACL)

Warehouse DTO:
```
{
  "sklad_id": 105,
  "sklad_name": "Центральный Склад",
  "sklad_adr": "г. Москва, ул. Ленина, 1",
  "item_art": "ART-9982",
  "item_title": "Световой меч джедая",
  "item_descr": "Супер меч, о котором мечтают все",
  "item_qty": 150,
  "item_price_val": 45.50,
  "item_cur": "RUB",
  "cat_name": "Оборонительное приспособление игрока",
  "manager_fio": "Иванов И.И."
}
```

```
abstract class WarehouseStockItem {
  final int sklad_id;
  final String sklad_name;
  final String sklad_adr;
  final String item_art;
  final String item_title;
  final String item_descr;
  final num item_qty;
  final num item_price_val;
  final String item_cur;
  final String cat_name;
  final String manager_fio;
}

class WarehouseAclAdapter {

  static WarehouseStockItem toDomain({LegacyWarehouseResponse legacyData}) {
    _validateLegacyData(legacyData);

    const price = Points.fromCurrency(
      legacyData.item_price_val, legacyData.item_cur,);


    const product = Product(
      id: legacyData.item_art,
      name: legacyData.item_title.trim(),
      price: price,
      description: legacyData.item_descr.trim(),
    );

    return product;
  }

  static void _validateLegacyData(LegacyWarehouseResponse data) {
    const quantity = Math.max(0, legacyData.item_qty);
    if (quantity == 0) {
      throw Exception(
          '[ACL] Ошибка валидации легаси данных: товар отсутствует на складе');
    }
    if (!data.item_art) {
      throw Exception(
          '[ACL] Ошибка валидации легаси данных: отсутствуют обязательные идентификаторы.');
    }
    if (data.item_price_val.runtimeType is! num || isNaN(data.item_price_val)) {
      throw Exception(
          '[ACL] Ошибка валидации легаси данных: неверный формат цены.');
    }
  }
}
```

## ДЗ 7 "CQRS и Наблюдаемость"

### 1. Разделение моделей (CQRS)

#### Command-модель: PlaceOrderCommand (DTO с данными для создания заказа)

```
class PlaceOrderCommand {
    final String orderId;
    final String customerId;
    final List<OrderItemDto> items;
    final ShippingDetailesDto shippingDetailes;
    final PaymentDetailesDto paymentDetailes;
    final DateTime createdAt;
}

class OrderItemDto {
    final String productId;
    final int quantity;
    final num price;
}
```

#### Query-модель (Read Model): OrderHistoryItemDTO

```
class OrderHistoryItemDTO {
    final String productId;
    final String name;
    final String description;
    final List<Uri> images;
    final int quantity;
    final num price;
}
```
Для чтения выгоднее использовать отдельную Read-модель, так как она содержит все данные для отображения, не нужно делать несколько запросов для обогащения данных, это обеспечит целостность данных при отображении, уменьшит количество точек отказа, уменьшит время загрузки данных.

### 2. Проектор (Projector)

```
class OrderProjector {
  final OrderRepository _repository;

  OrderProjector(this._repository);

  Future<void> project(OrderEvent event) async {
    switch (event) {
      case OrderConfirmedEvent e:
        await _handleConfirmed(e);
      case OrderShippedEvent e:
        await _handleShipped(e);
      default:
        break;
    }
  }
      
  Future<void> _handleConfirmed(OrderConfirmedEvent event) async {
    final readModel = OrderReadModel(
      id: event.orderId,
      customerId: event.customerId,
      status: OrderStatus.confirmed,
      updatedAt: event.confirmedAt,
    );
    
    await _repository.save(readModel);
  }

  Future<void> _handleShipped(OrderShippedEvent event) async {
    final existingModel = await _repository.getById(event.orderId);
    
    if (existingModel == null) {
      throw OrderException('Order ${event.orderId} not exists in repository');
    }

    final updatedModel = existingModel.copyWith(
      status: OrderStatus.shipped,
      trackingNumber: event.trackingNumber,
      updatedAt: event.shippedAt,
    );

    await _repository.save(updatedModel);
  }
}
```

### 3. Структурированное логирование

Пример JSON-лога PlaceOrderUseCase при успешном выполнении
```
{
    "level": "Information", 
    "timestamp": "2026-07-14T11:44:53Z, 
    "message": "Order placed successfully", 
    "correlationId": "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d9cor",
    "aggregateId": "Order",
    "orderId": "7b9e6d41-3a2b-4c1d-9e8f-5a6b7c8d9ert",
}
```

### 4. Метрики и Алертинг

Бизнес-метрика: 
<br>**Cart Abandonment Rate** (Доля брошенных корзин) - Доля пользователей, добавивших товары в корзину, но закрывших приложение на этапе ввода данных или оплаты.
<br>Можно сделать оповещение менеджера при резком скачке метрики в течении дня. Например превышение метрики на 10-15% от среднего исторического показателя. Это может говорить о том, что не работает платежная система или ошибка в UI (кнопка заказа не работает или перекрывается другими элементами).
<br>**Пример алерта**: Автоматический алерт в корпоративный мессенджер дежурному менеджеру и команде разработки для срочного аудита логов.

Техническая метрика:
<br>**Frequency of Errors** (Частота ошибок): Доля сбоев при обработке запроса (например, таймауты платежных систем или баз данных).