class ItemInventory {
  String? id;
  double? actualAmount;
  double? amount;
  String? note;

  /// just use when balance and create import note
  double? price;

  /// just use when balance and create import note
  String? supplierId;

  ItemInventory(
      {this.id,
      this.actualAmount,
      this.amount,
      this.note,
      this.price,
      this.supplierId});
  ItemInventory.byId(this.id);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemInventory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ItemExport(id: $id, actualAmount: $actualAmount, amount: $amount, note: $note)';
}
