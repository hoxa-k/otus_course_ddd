import 'package:ddd/models/order.dart';
import 'package:ddd/models/user_model_corrected.dart';

class DiscountConfig {
  final int minPositionsInOrder;
  final Map<GameParticipantStatus, int> discountForStatuses;

  const DiscountConfig({
    required this.minPositionsInOrder,
    required this.discountForStatuses,
  });
}

class DiscountService {
  num calculate(
    Order order,
    GameParticipantModel participant,
    DiscountConfig config,
  ) {
    final orderPositionsCount = order.items.length;
    final participantStatus = participant.status;
    if (orderPositionsCount < config.minPositionsInOrder) return 0;
    return config.discountForStatuses[participantStatus] ?? 0;
  }
}
