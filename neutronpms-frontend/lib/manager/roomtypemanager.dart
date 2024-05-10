import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';
import '../modal/roomtype.dart';
import 'beds.dart';

class RoomTypeManager extends ChangeNotifier {
  static final RoomTypeManager _instance = RoomTypeManager._internal();

  String? statusFilter;

  RoomTypeManager._internal();

  factory RoomTypeManager([RoomType? roomType]) {
    _instance.teId =
        TextEditingController(text: roomType != null ? roomType.id : '');
    _instance.teName =
        TextEditingController(text: roomType != null ? roomType.name : '');
    _instance.teNumGuest = TextEditingController(
        text: roomType != null ? roomType.guest.toString() : '');
    _instance.tePrice = TextEditingController(
        text: roomType != null ? roomType.price.toString() : '');
    if (roomType != null) {
      _instance.roomType = roomType;
      _instance.setBedChoose(roomType);
      _instance.bedChoose.addAll(roomType.beds!);
    }
    return _instance;
  }

  setBedChoose(RoomType roomType) {
    for (var item in roomType.beds!) {
      switch (item) {
        case Beds.king:
          _instance.isKing = true;
          break;
        case Beds.quad:
          _instance.isQuad = true;
          break;
        case Beds.queen:
          _instance.isQueen = true;
          break;
        case Beds.triple:
          _instance.isTriple = true;
          break;
        case Beds.single:
          _instance.isSingle = true;
          break;
        case Beds.twin:
          _instance.isTwin = true;
          break;
        case Beds.other:
          _instance.isOther = true;
          break;
        case Beds.double:
          _instance.isDouble = true;
          break;
      }
    }
  }

  RoomType? roomType;

  TextEditingController? teId, teName, teNumGuest, tePrice;

  String? errorLog;
  bool isTwin = false, isTriple = false, isQuad = false, isDouble = false;
  bool isKing = false, isSingle = false, isQueen = false, isOther = false;
  bool isLoading = false;
  List<dynamic> bedChoose = [];
  List<RoomType?> activedRoomTypes = [], fullRoomTypes = [];

  void update(Map<String, dynamic> data) {
    activedRoomTypes.clear();
    fullRoomTypes.clear();

    if (data.isEmpty) {
      return;
    }

    for (var item in data.entries) {
      final roomType = RoomType.fromSnapShot(item.value);
      roomType.id = item.key;
      fullRoomTypes.add(roomType);
    }

    fullRoomTypes.sort((a, b) => a!.id!.compareTo(b!.id!));

    activedRoomTypes =
        fullRoomTypes.where((element) => element!.isDelete == false).toList();
    notifyListeners();
  }

  List<String?> getRoomTypeNamesActived() {
    return activedRoomTypes.map((roomType) => roomType?.name).toList();
  }

  List<String?> getRoomTypeIDsActived() {
    return activedRoomTypes.map((roomType) => roomType?.id).toList();
  }

  List<String> getFullRoomTypeNames() {
    return fullRoomTypes.map((roomType) => roomType!.name!).toList();
  }

  List<String?> getFullRoomTypeIDs() {
    return fullRoomTypes.map((roomType) => roomType?.id).toList();
  }

  String getRoomTypeIDByName(String name) =>
      fullRoomTypes
          .where((element) => element?.isDelete == false)
          .firstWhere(
            (element) => element?.name == name,
            orElse: () => null,
          )
          ?.id ??
      "";

  String getRoomTypeNameByID(String? id) {
    return fullRoomTypes
            .firstWhere(
              (element) => element?.id == id,
              orElse: () => null,
            )
            ?.name ??
        "";
  }

  String getActiveRoomTypeNameByID(String? id) {
    return activedRoomTypes
            .firstWhere(
              (element) => element?.id == id,
              orElse: () => null,
            )
            ?.name ??
        "";
  }

  RoomType getRoomTypeByID(String id) =>
      activedRoomTypes.firstWhere((roomType) => roomType!.id == id)!;

  //get actived and deactived roomtype
  RoomType getAllRoomTypeByID(String id) =>
      fullRoomTypes.firstWhere((roomType) => roomType!.id == id)!;

  num getPriceOfRoomType(String roomTypeID) {
    try {
      return getRoomTypeByID(roomTypeID).price!;
    } catch (e) {
      return 0;
    }
  }

  num getAmountOfRoomType(String roomTypeID) {
    try {
      return getRoomTypeByID(roomTypeID).total!;
    } catch (e) {
      return 0;
    }
  }

  RoomType? getBedsOfRoomType(String roomTypeID) {
    try {
      return activedRoomTypes
          .firstWhere((element) => element!.id == roomTypeID);
    } catch (e) {
      return null;
    }
  }

  RoomType? getFirstRoomType() {
    try {
      return activedRoomTypes.first;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteRoomType(String idRoomType) async {
    isLoading = true;
    notifyListeners();
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('hotelmanager-deleteRoomType');
      final result = await callable(
          {'hotel_id': GeneralManager.hotelID, 'room_type_id': idRoomType});
      isLoading = false;
      notifyListeners();
      return result.data == MessageCodeUtil.SUCCESS ? true : false;
    } on FirebaseFunctionsException catch (e) {
      print(e.message);
      errorLog = MessageUtil.getMessageByCode(e.message);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // void cancelStream() {
  //   teNumGuest.dispose();
  //   tePrice.dispose();
  //   teId.dispose();
  //   teName.dispose();
  //   isTwin = false;
  //   isTriple = false;
  //   isQuad = false;
  //   isDouble = false;
  //   isKing = false;
  //   isSingle = false;
  //   isQueen = false;
  //   isOther = false;
  //   isLoading = false;
  // }

  void setStatusFilter(value) {
    statusFilter = value;
    notifyListeners();
  }
}
