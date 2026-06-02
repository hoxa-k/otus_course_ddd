# Домашние задания по курсу "Domain Driven Design и асинхронная архитектура"

## ДЗ 2 "Качество кода и богатая модель"
VO Email [email.dart](lib/models/email.dart), Points [points.dart](lib/models/points.dart) + тесты  [email_test.dart](test/email_test.dart)  [points_test.dart](test/points_test.dart)

[user_model.dart](lib/models/user_model.dart) - пример плохого кода Доменной модели UserModel. 
Нарушен принцип единой ответственности SOLID

[user_model_corrected.dart](lib/models/user_model_corrected.dart) - предложенный рефакторинг. 
Выделить методы подсчета баллов в доменную сущность другого домена. Заменить примитивы на VO.


