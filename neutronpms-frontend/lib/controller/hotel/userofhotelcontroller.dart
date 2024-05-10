import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/hotel.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/util/messageulti.dart';

class UserOfHotelController extends ChangeNotifier {
  StreamSubscription? roleStream;
  late Hotel hotel;
  List<HotelUser> users = [];
  Map<String, dynamic> roles = {};
  bool isInprogress = false;

  UserOfHotelController() {
    hotel = GeneralManager.hotel!;
    getUsersOfHotel();
    getRolesOfAllUserInHotel();
  }

  void cancelStream() {
    roleStream?.cancel();
  }

  Future<void> getUsersOfHotel() async {
    isInprogress = true;
    notifyListeners();
    users.clear();
    await FirebaseFunctions.instance
        .httpsCallable('user-getUsersInHotel')
        .call({'hotel_id': GeneralManager.hotelID}).then((value) {
      for (var doc in (value.data as List<dynamic>)) {
        users.add(HotelUser.fromMap(doc));
      }
    }).onError((error, stackTrace) {
      users = [];
    });
    isInprogress = false;
    notifyListeners();
  }

  Future<void> getRolesOfAllUserInHotel() async {
    if (roleStream != null) roleStream!.cancel();
    roleStream = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        roles.clear();
        (snapshot.get('role') as Map).forEach((key, value) {
          roles[key] = value;
        });
      }
      notifyListeners();
    });
  }

  Future<String> removeMember(String uid) async {
    if (isInprogress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isInprogress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('user-removeUserFromHotel')
        .call({'hotel_id': GeneralManager.hotelID, 'uid': uid})
        .then((value) => value.data)
        .onError((error, stackTrace) => error.toString());
    if (result == MessageCodeUtil.SUCCESS) {
      users.removeWhere((user) => user.id == uid);
    }
    isInprogress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
