class ItemImport {
  String? id;
  double? price;
  double? amount;
  String? supplier;
  String? warehouse;

  ItemImport({this.id, this.price, this.amount, this.supplier, this.warehouse});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemImport &&
        other.id == id &&
        other.price == price &&
        other.amount == amount &&
        other.supplier == supplier &&
        other.warehouse == warehouse;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        price.hashCode ^
        amount.hashCode ^
        supplier.hashCode ^
        warehouse.hashCode;
  }

  @override
  String toString() {
    return 'ItemImport(id: $id, price: $price, amount: $amount, supplier: $supplier, warehouse: $warehouse)';
  }
}
