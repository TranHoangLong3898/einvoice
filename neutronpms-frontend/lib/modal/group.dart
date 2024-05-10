import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/booking.dart';

class Group {
  String? id;
  String? name;
  String? email;
  num? adult;
  num? child;
  String? room;
  num? roomCharge;
  num? remaining;
  String? phone;
  DateTime? inDate;
  DateTime? outDate;
  DateTime? created;
  dynamic data;
  String? ratePlanID;
  String? sID;
  String? sourceID;
  List<num>? price;
  bool? payAtHotel = false;
  bool? breakfast = false;
  num? deposit;
  num? service;
  num? discount;
  List<Booking>? subBookings;

  Group(
      {this.id,
      this.email,
      this.name,
      this.adult,
      this.child,
      this.remaining,
      this.roomCharge,
      this.room,
      this.deposit,
      this.phone,
      this.inDate,
      this.outDate,
      this.created,
      this.data,
      this.ratePlanID,
      this.sID,
      this.sourceID,
      this.price,
      this.payAtHotel,
      this.breakfast,
      this.subBookings,
      this.service,
      this.discount});

  factory Group.fromSnapshot(DocumentSnapshot documentSnapshot) {
    // final data = documentSnapshot.data() as Map<String, dynamic>;
    return Group(
      id: documentSnapshot.id,
      email: documentSnapshot.get('email'),
      name: documentSnapshot.get('name'),
      phone: documentSnapshot.get('phone'),
      inDate: documentSnapshot.get('in_date').toDate(),
      outDate: documentSnapshot.get('out_date').toDate(),
      created: documentSnapshot.get('created').toDate(),
      data: documentSnapshot.get('data'),
      ratePlanID: documentSnapshot.get('rate_plan'),
      sID: documentSnapshot.get('sid'),
      sourceID: documentSnapshot.get('source'),
      price: documentSnapshot.get('price'),
      payAtHotel: documentSnapshot.get('pay_at_hotel'),
      breakfast: documentSnapshot.get('breakfast'),
      subBookings: [],
    );
  }

  Map<String, String> getRoomChargeDetail() {
    Map<String, String> mapData = {};
    for (Booking subBooking in subBookings!) {
      for (int i = 0; i < subBooking.price!.length; i++) {
        String key =
            "${subBooking.inDate!.add(Duration(days: i))}, ${subBooking.price![i]}";

        mapData.containsKey(key)
            ? mapData[key] =
                "${mapData[key]}, ${RoomManager().getNameRoomById(subBooking.room!)}"
            : mapData[key] = RoomManager().getNameRoomById(subBooking.room!);
      }
    }
    return mapData;
  }
}
