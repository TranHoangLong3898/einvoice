import 'package:cloud_firestore/cloud_firestore.dart';

class Transfer {
  final String? desc;
  final num? amount;
  final Timestamp? time;
  final String? hotel;

  Transfer({this.desc, this.amount, this.time, this.hotel});
}
