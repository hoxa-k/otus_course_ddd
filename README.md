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

