class ItemExport {
  String? id;
  String? warehouse;
  double? amount;

  ItemExport({this.id, this.warehouse, this.amount});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemExport &&
        other.id == id &&
        other.warehouse == warehouse &&
        other.amount == amount;
  }

  @override
  int get hashCode => id.hashCode ^ warehouse.hashCode ^ amount.hashCode;

  @override
  String toString() =>
      'ItemExport(id: $id, warehouseId: $warehouse, amount: $amount)';
}
