class Payment {
  String? name;
  String? id;
  bool? isDelete;
  List<dynamic>? status;
  Payment({this.id, this.name, this.status, this.isDelete});

  factory Payment.fromJson(String idPayment, dynamic payment) {
    return Payment(
        name: payment['name'],
        id: idPayment,
        status: payment['status'],
        isDelete: payment['is_delete']);
  }
}
