import 'package:ddd/models/user_model_corrected.dart';

class DiscountConfig {
  final int minPositionsInOrder;
  final Map<GameParticipantStatus, int> discountForStatuses;

  const DiscountConfig({
    required this.minPositionsInOrder,
    required this.discountForStatuses,
  });
}