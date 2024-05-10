import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSupplier {
  final String? id;
  String? desc;
  String? supplier;
  final Timestamp? createdTime;
  final String? createdBy;
  bool? ordered;

  OrderSupplier(
      {this.id,
      this.desc,
      this.supplier,
      this.createdTime,
      this.createdBy,
      this.ordered = false});

  factory OrderSupplier.fromSnapshot(DocumentSnapshot doc) => OrderSupplier(
        id: doc.id,
        desc: doc.get('desc'),
        supplier: doc.get('supplier'),
        createdBy: doc.get('created_by'),
        createdTime: doc.get('created_time'),
        ordered: doc.get('ordered'),
      );
}
