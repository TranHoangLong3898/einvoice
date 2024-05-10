import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/servicemanager.dart';
import '../../modal/status.dart';
import '../booking.dart';
import 'service.dart';

class BikeRental extends Service {
  final String? type;
  final String? supplierID;

  final num? price;

  Timestamp? start;
  Timestamp? end;

  String? bike;
  int? progress;

  BikeRental({
    this.price,
    this.bike,
    this.type,
    String? id,
    num? total,
    Timestamp? time,
    String? status,
    this.start,
    this.end,
    this.supplierID,
    this.progress,
    String? bookingID,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? room,
    bool? delete,
    String? sID,
    bool? isGroup,
    String? saler,
  }) : super(
            id: id ?? "",
            created: time ?? Timestamp.now(),
            total: total ?? 0,
            cat: ServiceManager.BIKE_RENTAL_CAT,
            bookingID: bookingID ?? "",
            status: status ?? "",
            inDate: inDate ?? DateTime.now(),
            outDate: outDate ?? DateTime.now(),
            name: name ?? "",
            room: room ?? "",
            deletable: delete ?? true,
            sID: sID ?? "",
            isGroup: isGroup ?? false,
            saler: saler ?? "");

  factory BikeRental.fromSnapshot(DocumentSnapshot doc) => BikeRental(
        id: doc.id,
        start: doc.get('start'),
        end: (doc.data() as Map<String, dynamic>).containsKey('end')
            ? doc.get('end')
            : null,
        supplierID: doc.get('supplier'),
        total: doc.get('total'),
        bike: doc.get('bike'),
        price: doc.get('price'),
        progress: doc.get('progress'),
        time: doc.get('created'),
        bookingID: doc.get('bid'),
        status: doc.get('status'),
        inDate: (doc.get('in') as Timestamp).toDate(),
        outDate: (doc.get('out') as Timestamp).toDate(),
        name: doc.get('name'),
        room: doc.get('room'),
        sID: doc.get('sid'),
        delete: (doc.data() as Map<String, dynamic>).containsKey('delete')
            ? doc.get('delete')
            : true,
        type: doc.get('type'),
        isGroup: doc.get('group'),
        saler: (doc.data() as Map<String, dynamic>).containsKey('email_saler')
            ? doc.get('email_saler')
            : "",
      );

  @override
  num? getTotal() {
    if (progress == BikeRentalProgress.booked) {
      return 0;
    } else if (progress == BikeRentalProgress.checkin) {
      int lr = Timestamp.now().toDate().difference(start!.toDate()).inDays + 1;
      return lr * (price ?? 0);
    } else {
      return total;
    }
  }

  Future<String> updateBikeRentalProgress(int progress) async {
    try {
      final now = Timestamp.now();
      num total = 0;
      Map<String, dynamic> map = {'progress': progress};
      if (progress == BikeRentalProgress.checkin) {
        map['start'] = now.toDate().toString();
        map['delete'] = false;
      } else if (progress == BikeRentalProgress.checkout) {
        map['end'] = now.toDate().toString();
        map['used'] = now.toDate().toString();
        total = getTotal()!;
        map['total'] = total;
        map['delete'] = false;
      }
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateBikeRentalProgress')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'booking_id': bookingID,
            'bike_rental_id': id,
            'data_update': map,
            if (isGroup ?? false) 'booking_sid': sID
          })
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
      if (result == MessageCodeUtil.SUCCESS) {
        this.progress = progress;
        if (progress == BikeRentalProgress.checkin) {
          start = now;
          deletable = false;
        } else if (progress == BikeRentalProgress.checkout) {
          end = now;
          this.total = total;
          deletable = false;
        }
      }
      return result;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }

  Future<bool> changeBike(String newBike) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('service-changeBike')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'booking_id': bookingID,
            if (isGroup ?? false) 'booking_sid': sID,
            'bike_rental_id': id,
            'new_bike': newBike
          })
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  bool isMovable() {
    if (progress == BikeRentalProgress.checkin) return true;
    return false;
  }

  Future<String> moveToBooking(Booking booking) async {
    if (booking.id == bookingID) {
      return MessageCodeUtil.CAN_NOT_TRANSFER_FOR_YOURSELF;
    }

    //transfer in the same group-booking
    if (booking.sID == sID) {
      return await FirebaseFunctions.instance
          .httpsCallable('service-moveBikeInTheSameGroupBooking')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'this_booking_id': bookingID,
            'destination_booking_id': booking.id,
            'sid': booking.sID,
            'service_id': id,
          })
          .then((value) => value.data)
          .onError((error, stackTrace) {
            print(error);
            return (error as FirebaseFunctionsException).message;
          });
    }

    return await FirebaseFunctions.instance
        .httpsCallable('service-moveBikeToOtherBooking')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'this_booking_id': bookingID,
          if (isGroup ?? false) 'this_booking_sid': sID,
          'destination_booking_id': booking.id,
          if (booking.group ?? false) 'destination_booking_sid': booking.sID,
          'service_id': id,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        });
  }
}
