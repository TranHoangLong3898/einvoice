class ItemLiquidation {
  String? id;
  double? price;
  double? amount;
  String? warehouse;

  ItemLiquidation({this.id, this.price, this.amount, this.warehouse});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemLiquidation &&
        other.id == id &&
        other.price == price &&
        other.amount == amount &&
        other.warehouse == warehouse;
  }

  @override
  int get hashCode {
    return id.hashCode ^ price.hashCode ^ amount.hashCode ^ warehouse.hashCode;
  }

  @override
  String toString() {
    return 'ItemLiquidation(id: $id, price: $price, amount: $amount, warehouse: $warehouse)';
  }
}
