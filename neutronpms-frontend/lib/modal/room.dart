import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/manager/generalmanager.dart';

class Room {
  String? id;
  String? name;
  String? roomType;
  bool? isClean = false;
  bool? isType = false;
  String? bed;
  String? bookingID;
  String? bookingInfo;
  String? note;
  bool? isDelete;
  DateTime? lastClean;
  bool? vacantOvernight;

  Room.type({this.id}) {
    isType = true;
  }

  factory Room.fromSnaphot(dynamic snapshot) {
    return Room(
      name: snapshot['name'],
      isClean: snapshot['clean'],
      bookingID: snapshot['bid'],
      bookingInfo: snapshot['binfo'],
      bed: snapshot['bed'],
      roomType: snapshot['room_type'],
      isDelete: snapshot['is_delete'],
      note: snapshot.containsKey('note') ? snapshot['note'] : "",
      lastClean: snapshot.containsKey('last_clean')
          ? (snapshot['last_clean'] as Timestamp).toDate()
          : null,
      vacantOvernight: snapshot.containsKey('vacant_overnight')
          ? snapshot['vacant_overnight']
          : false,
    );
  }

  Room(
      {this.id,
      this.name,
      this.roomType,
      this.isClean,
      this.bed,
      this.bookingID,
      this.bookingInfo,
      this.isDelete,
      this.lastClean,
      this.vacantOvernight,
      this.note});

  Future<String> updateClean(bool isClean, bool vacantOvernight) async {
    return await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateCleanRoom')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'room_id': id,
          'room_clean': isClean,
          'vacantvernight': vacantOvernight
        })
        .timeout(const Duration(seconds: 60))
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> updateBed(String bed) async {
    return await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateBedOfRoom')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'room_id': id,
          'room_bed': bed
        })
        .timeout(const Duration(seconds: 60))
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> updateVacantOvernight(bool vacantOvernight) async {
    return await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateVacantOvernightRoom')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'room_id': id,
          'vacantvernight': vacantOvernight
        })
        .timeout(const Duration(seconds: 60))
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }
}
