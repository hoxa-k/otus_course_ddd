import 'package:ddd/domain/events/domain_event.dart';

abstract class IDomainEventDispatcher {
  Future dispatch(List<IDomainEvent> events);
}