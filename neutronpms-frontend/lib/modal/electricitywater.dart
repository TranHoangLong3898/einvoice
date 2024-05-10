import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/modal/service/service.dart';

class Electricity extends Service {
  DateTime? initialTime;
  DateTime? finalTime;
  num? initialNumber;
  num? finalNumber;
  num? priceElectricity;
  DateTime? createdTime;

  Electricity({
    num? total,
    String? desc,
    this.createdTime,
    this.initialTime,
    this.initialNumber = 0,
    this.finalNumber = 0,
    this.priceElectricity = 0,
    this.finalTime,
    String? status,
    String? bookingID,
    String? id,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? room,
    String? sID,
    bool? isGroup,
  }) : super(
          id: id ?? "",
          created: Timestamp.fromDate(createdTime!),
          status: status ?? "",
          total: total ?? 0,
          cat: ServiceManager.ELECTRICITY_CAT,
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          desc: desc ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
        );

  factory Electricity.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    return Electricity(
      id: doc.id,
      initialTime: data.containsKey('initial_time')
          ? (doc.get('initial_time') as Timestamp).toDate()
          : DateTime.now(),
      initialNumber:
          data.containsKey('initial_number') ? doc.get('initial_number') : 0,
      finalNumber:
          data.containsKey('final_number') ? doc.get('final_number') : 0,
      finalTime: data.containsKey('final_time')
          ? (doc.get('final_time') as Timestamp).toDate()
          : DateTime.now(),
      priceElectricity: data.containsKey('price_electricity')
          ? doc.get('price_electricity')
          : 0,
      desc: doc.get('desc'),
      total: doc.get('total'),
      createdTime: (doc.get('created') as Timestamp).toDate(),
      bookingID: doc.get('bid'),
      inDate: (doc.get('in') as Timestamp).toDate(),
      outDate: (doc.get('out') as Timestamp).toDate(),
      name: doc.get('name'),
      room: doc.get('room'),
      sID: doc.get('sid'),
      isGroup: doc.get('group'),
    );
  }

  @override
  num? getTotal() => total;
}

class Water extends Service {
  DateTime? initialTime;
  DateTime? finalTime;
  num? initialNumber;
  num? finalNumber;
  num? priceWater;
  DateTime? createdTime;
  Water({
    num? total,
    String? desc,
    this.createdTime,
    this.initialTime,
    this.initialNumber = 0,
    this.finalNumber = 0,
    this.priceWater = 0,
    this.finalTime,
    String? status,
    String? bookingID,
    String? id,
    DateTime? inDate,
    DateTime? outDate,
    String? name,
    String? room,
    String? sID,
    bool? isGroup,
  }) : super(
          id: id ?? "",
          created: Timestamp.fromDate(createdTime!),
          status: status ?? "",
          total: total ?? 0,
          cat: ServiceManager.WATER_CAT,
          bookingID: bookingID ?? "",
          inDate: inDate ?? DateTime.now(),
          outDate: outDate ?? DateTime.now(),
          name: name ?? "",
          room: room ?? "",
          desc: desc ?? "",
          sID: sID ?? "",
          isGroup: isGroup ?? false,
        );

  factory Water.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    return Water(
      id: doc.id,
      initialTime: data.containsKey('initial_time')
          ? (doc.get('initial_time') as Timestamp).toDate()
          : DateTime.now(),
      initialNumber:
          data.containsKey('initial_number') ? doc.get('initial_number') : 0,
      finalNumber:
          data.containsKey('final_number') ? doc.get('final_number') : 0,
      finalTime: data.containsKey('final_time')
          ? (doc.get('final_time') as Timestamp).toDate()
          : DateTime.now(),
      priceWater: data.containsKey('price_water') ? doc.get('price_water') : 0,
      desc: doc.get('desc'),
      total: doc.get('total'),
      createdTime: (doc.get('created') as Timestamp).toDate(),
      // status: doc.get('status'),
      bookingID: doc.get('bid'),
      inDate: (doc.get('in') as Timestamp).toDate(),
      outDate: (doc.get('out') as Timestamp).toDate(),
      name: doc.get('name'),
      room: doc.get('room'),
      sID: doc.get('sid'),
      isGroup: doc.get('group'),
    );
  }

  @override
  num? getTotal() => total;
}
