import 'package:ddd/models/discount_config.dart';
import 'package:ddd/models/order.dart';
import 'package:ddd/models/user_model_corrected.dart';

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
