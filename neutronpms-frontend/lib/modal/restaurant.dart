// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  String? id;
  String? nameRes;
  String? email;
  DateTime? created;
  bool? isLinked;
  Restaurant({
    this.id,
    this.nameRes,
    this.email,
    this.created,
    this.isLinked,
  });

  factory Restaurant.fromSnapshot(String idRes, dynamic mapData) {
    return Restaurant(
      id: idRes,
      nameRes: mapData['res_name'],
      email: mapData['email'],
      created: (mapData['created'] as Timestamp).toDate(),
      isLinked: mapData['is_linked'],
    );
  }
}
