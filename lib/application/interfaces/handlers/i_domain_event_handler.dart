abstract class IDomainEventHandler<IDomainEvent> {
  Future<void> handle(IDomainEvent domainEvent);
}