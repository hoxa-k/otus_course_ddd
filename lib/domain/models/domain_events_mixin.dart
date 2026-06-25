import 'dart:collection';

import 'package:ddd/domain/events/domain_event.dart';

mixin DomainEventsMixin {

  final List<IDomainEvent> _domainEvents = [];

  List<IDomainEvent> get domainEvents => UnmodifiableListView(_domainEvents);

  void addDomainEvent(IDomainEvent event) {
    _domainEvents.add(event);
  }

  void clearDomainEvents() {
    _domainEvents.clear();
  }
}