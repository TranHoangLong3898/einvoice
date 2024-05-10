class ItemTransfer {
  String? id;
  double? amount;
  String? fromWarehouse;
  String? toWarehouse;

  ItemTransfer({this.id, this.amount, this.fromWarehouse, this.toWarehouse});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTransfer &&
        other.id == id &&
        other.amount == amount &&
        other.fromWarehouse == fromWarehouse &&
        other.toWarehouse == toWarehouse;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        fromWarehouse.hashCode ^
        toWarehouse.hashCode;
  }

  @override
  String toString() {
    return 'ItemTransfer(id: $id, amount: $amount, fromWarehouse: $fromWarehouse, toWarehouse: $toWarehouse)';
  }
}
