import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

import '../../../manager/bikerentalmanager.dart';
import '../../../manager/servicemanager.dart';
import '../../../manager/suppliermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/bikerental.dart';
import '../../../modal/status.dart';
import 'addservicecontroller.dart';

class BikeRentalController extends ChangeNotifier {
  List<BikeRental> bikeRentals = [];
  final Booking booking;

  BikeRentalController(this.booking) {
    update();
  }

  void update() async {
    bikeRentals = await booking.getBikeRentals();
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}

class AddBikeRentalController extends AddServiceController {
  final Booking booking;
  late String type;
  late String supplierID;
  late String bike;
  late TextEditingController tePrice, teSaler;
  String emailSalerOld = '';
  late DateTime startDate;
  List<String> bikes = [];
  bool adding = false;

  AddBikeRentalController(this.booking) {
    supplierID =
        SupplierManager().getFirstSupplierID(ServiceManager.BIKE_RENTAL_CAT);
    List<String> types = BikeRentalManager().getTypes();
    type = types.isEmpty ? '' : 'manual';
    bike = '';
    tePrice = TextEditingController();
    startDate = Timestamp.now().toDate();
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
    getAvailableBikes();
  }

  void disposeTextEditingControllers() {
    tePrice.dispose();
  }

  void setSupplier(String newSupplierName) {
    final newSupplierID =
        SupplierManager().getSupplierIDByName(newSupplierName);
    if (newSupplierID!.isEmpty) return;

    if (newSupplierID == supplierID) return;

    supplierID = newSupplierID;
    getAvailableBikes();
  }

  void setType(String value) {
    String newType =
        value == MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_MANUAL)
            ? 'manual'
            : 'auto';
    if (newType == type) return;
    type = newType;
    getAvailableBikes();
  }

  void setBike(String newBike) {
    bike = newBike;
    tePrice.text =
        NumberUtil.numberFormat.format(BikeRentalManager().getPrice(bike));
    notifyListeners();
  }

  void getAvailableBikes() async {
    if (supplierID.isEmpty) {
      bikes = [];
    } else {
      bikes = BikeRentalManager()
          .getAvailableBikesByTypeAndSupplierId(type, supplierID);
    }
    // if (bikes.isEmpty) {
    //   bike = '';
    //   tePrice.text = NumberUtil.numberFormat
    //       .format(BikeRentalManager().getDefaultPrice(type));
    // } else {
    //   bike = bikes[0];
    //   tePrice.text =
    //       NumberUtil.numberFormat.format(BikeRentalManager().getPrice(bike));
    // }
    bike = '';
    tePrice.text = NumberUtil.numberFormat
        .format(BikeRentalManager().getDefaultPrice(type));
    notifyListeners();
  }

  Future<String> addBikeRental() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }

    final price = num.tryParse(tePrice.text.replaceAll(',', ''));
    if (price == null || price < 0) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_PRICE);
    }

    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    adding = true;
    notifyListeners();
    String result = await booking
        .addService(BikeRental(
            start: Timestamp.fromDate(startDate),
            bike: bike,
            price: price,
            progress: BikeRentalProgress.booked,
            supplierID: supplierID,
            total: 0,
            time: Timestamp.now(),
            type: type,
            saler: teSaler.text))
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
