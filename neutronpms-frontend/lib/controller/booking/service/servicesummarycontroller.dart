import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/electricitywater.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../handler/firebasehandler.dart';
import '../../../manager/generalmanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/bikerental.dart';
import '../../../modal/service/extraguest.dart';
import '../../../modal/service/insiderestaurantservice.dart';
import '../../../modal/service/laundry.dart';
import '../../../modal/service/minibar.dart';

import '../../../modal/service/other.dart';
import '../../../modal/service/outsiderestaurantservice.dart';
import '../../../util/pdfutil.dart';

class ServiceSummaryController extends ChangeNotifier {
  Booking? booking;
  StreamSubscription? subscription;
  bool isBookingParent = false;
  ServiceSummaryController(Booking booking) {
    if (booking.id == booking.sID) {
      isBookingParent = true;
    }
    Stream collectionStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection(FirebaseHandler.colBookings)
        .doc(booking.group! ? booking.sID : booking.id)
        .snapshots();
    subscription = collectionStream.listen((doc) {
      if (booking.group!) {
        print("asyncBooking: ${booking.id} of parentBooking: ${booking.sID}");
        Booking bookingParent = Booking.groupFromSnapshot(doc);
        if (isBookingParent) {
          this.booking = bookingParent;
        } else {
          this.booking = Booking.fromBookingParent(booking.id!, bookingParent);
        }
      } else {
        print("asyncBooking: ${booking.id}");
        this.booking = Booking.fromSnapshot(doc);
      }
      notifyListeners();
    }, onDone: () => print('asyncBooking: Done'), cancelOnError: true);
  }

  void cancelStream() {
    subscription?.cancel();
  }

  Future exportDetailService() async {
    List<Minibar> minibarData = await booking!.getMinibars();

    List<InsideRestaurantService> insiderRestautant =
        await booking!.getInsideRestaurantServices();

    List<ExtraGuest> extraGuestData = await booking!.getExtraGuests();

    List<Laundry> laundryData = await booking!.getLaundries();

    List<BikeRental> bikeRentalData = await booking!.getBikeRentals();

    List<Other> otherData = await booking!.getOthers();

    List<Electricity> electricityData = await booking!.getElectricity();

    List<Water> waterData = await booking!.getWater();

    List<OutsideRestaurantService> outsideRestaurantServiceData =
        await booking!.getRestaurantServices();
    Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            (await PDFUtil.buildAllServiceOfBookingPDFDoc(
                    booking!,
                    minibarData,
                    insiderRestautant,
                    extraGuestData,
                    laundryData,
                    bikeRentalData,
                    otherData,
                    outsideRestaurantServiceData,
                    electricityData,
                    waterData))
                .save());
  }
}
