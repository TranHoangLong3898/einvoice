import 'package:ihotel/util/warehouseutil.dart';
import 'package:ihotel/util/messageulti.dart';

class ItemLost {
  ItemLost({
    this.id,
    this.warehouse,
    this.amount,
    this.status,
  });

  String? id;

  String? warehouse;

  double? amount;

  /// Lost status: [LostStatus.lost], [LostStatus.broken] or [LostStatus.expired]
  String? status;

  String get statusName {
    switch (status) {
      case LostStatus.lost:
        return MessageUtil.getMessageByCode(MessageCodeUtil.LOST);
      case LostStatus.expired:
        return MessageUtil.getMessageByCode(MessageCodeUtil.EXPIRED);
      default:
        return MessageUtil.getMessageByCode(MessageCodeUtil.BROKEN);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemLost &&
        other.id == id &&
        other.warehouse == warehouse &&
        other.status == status &&
        other.amount == amount;
  }

  @override
  int get hashCode =>
      id.hashCode ^ warehouse.hashCode ^ amount.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'ItemLost(id: $id, warehouseId: $warehouse, amount: $amount, status = $status)';
}
