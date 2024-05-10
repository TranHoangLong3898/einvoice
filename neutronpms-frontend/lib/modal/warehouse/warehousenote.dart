class WarehouseNote {
  String? id;
  String? creator;
  String? invoiceNumber;
  DateTime? createdTime;
  DateTime? actualCreated;
  String? type;

  WarehouseNote(
      {this.id,
      this.creator,
      this.invoiceNumber,
      this.createdTime,
      this.type,
      this.actualCreated});
}
