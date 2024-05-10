class ItemReturn {
  String? id;
  String? warehouse;
  double? amount;
  double? price;

  ItemReturn({this.id, this.warehouse, this.amount, this.price});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemReturn &&
        other.id == id &&
        other.warehouse == warehouse &&
        other.price == price &&
        other.amount == amount;
  }

  @override
  int get hashCode =>
      id.hashCode ^ warehouse.hashCode ^ amount.hashCode ^ price.hashCode;

  @override
  String toString() =>
      'ItemExport(id: $id, warehouseId: $warehouse, amount: $amount, price: $price)';
}
