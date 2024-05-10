// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/beds.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/modal/roomtype.dart';
import 'package:ihotel/util/messageulti.dart';

class AddRoomTypeController extends ChangeNotifier {
  RoomType? roomType;

  late TextEditingController teId;

  late TextEditingController teName;

  late TextEditingController teNumGuest;

  late TextEditingController tePrice;

  late TextEditingController teMinPrice;

  late String errorLog;

  bool isTwin = false;
  bool isTriple = false;
  bool isQuad = false;
  bool isDouble = false;
  bool isKing = false;
  bool isSingle = false;
  bool isQueen = false;
  bool isOther = false;
  bool isLoading = false;
  late bool isAddFeature;

  List<dynamic> bedChoose = [];

  Map<String, dynamic> beds = SystemManagement().beds;

  AddRoomTypeController(RoomType? roomType) {
    if (roomType == null) {
      isAddFeature = true;
      teId = TextEditingController(text: '');
      teName = TextEditingController(text: '');
      teNumGuest = TextEditingController(text: '');
      tePrice = TextEditingController(text: '');
      teMinPrice = TextEditingController(text: '');
    } else {
      isAddFeature = false;
      teId = TextEditingController(text: roomType.id);
      teName = TextEditingController(text: roomType.name);
      teNumGuest = TextEditingController(
          text: roomType != null ? roomType.guest.toString() : '');
      tePrice = TextEditingController(
          text: roomType != null ? roomType.price.toString() : '');
      teMinPrice = TextEditingController(
          text: roomType != null ? roomType.minPrice.toString() : '');
    }
    if (roomType != null) {
      this.roomType = roomType;
      setBedChoose(roomType);
      bedChoose.addAll(roomType.beds!);
    }
  }

  setBedChoose(RoomType roomType) {
    for (var item in roomType.beds!) {
      switch (item) {
        case Beds.king:
          isKing = true;
          break;
        case Beds.quad:
          isQuad = true;
          break;
        case Beds.queen:
          isQueen = true;
          break;
        case Beds.triple:
          isTriple = true;
          break;
        case Beds.single:
          isSingle = true;
          break;
        case Beds.twin:
          isTwin = true;
          break;
        case Beds.other:
          isOther = true;
          break;
        case Beds.double:
          isDouble = true;
          break;
      }
    }
  }

  setBedTwinForRoomType(bool value) {
    if (value) {
      isTwin = true;
      bedChoose.add(Beds.twin);
      notifyListeners();
    } else {
      isTwin = false;
      bedChoose.remove(Beds.twin);
      notifyListeners();
    }
  }

  setBedTripleForRoomType(bool checkbox) {
    if (checkbox) {
      isTriple = true;
      bedChoose.add(Beds.triple);
      notifyListeners();
    } else {
      isTriple = false;
      bedChoose.remove(Beds.triple);
      notifyListeners();
    }
  }

  setBedQuadForRoomType(bool checkbox) {
    if (checkbox) {
      isQuad = true;
      bedChoose.add(Beds.quad);
      notifyListeners();
    } else {
      isQuad = false;
      bedChoose.remove(Beds.quad);
      notifyListeners();
    }
  }

  setBedDoubleForRoomType(bool checkbox) {
    if (checkbox) {
      isDouble = true;
      bedChoose.add(Beds.double);
      notifyListeners();
    } else {
      isDouble = false;
      bedChoose.remove(Beds.double);
      notifyListeners();
    }
  }

  setBedKingForRoomType(bool checkbox) {
    if (checkbox) {
      isKing = true;
      bedChoose.add(Beds.king);
      notifyListeners();
    } else {
      isKing = false;
      bedChoose.remove(Beds.king);
      notifyListeners();
    }
  }

  setBedSingleForRoomType(bool checkbox) {
    if (checkbox) {
      isSingle = true;
      bedChoose.add(Beds.single);
      notifyListeners();
    } else {
      isSingle = false;
      bedChoose.remove(Beds.single);

      notifyListeners();
    }
  }

  setBedOtherForRoomType(bool checkbox) {
    if (checkbox) {
      isOther = true;
      bedChoose.add(Beds.other);
      notifyListeners();
    } else {
      isOther = false;
      bedChoose.remove(Beds.other);
      notifyListeners();
    }
  }

  setBedQueenForRoomType(bool checkbox) {
    if (checkbox) {
      isQueen = true;
      bedChoose.add(Beds.queen);
      notifyListeners();
    } else {
      isQueen = false;
      bedChoose.remove(Beds.queen);
      notifyListeners();
    }
  }

  Future<String> addRoomType() async {
    // if (this.teName == null) {
    //   return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
    // }
    if (bedChoose.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_TYPE_OF_BED);
    }

    if (this.roomType != null) {
      if (bedChoose.length == 1 && bedChoose.contains(Beds.none)) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_TYPE_OF_BED);
      }
    }

    isLoading = true;
    notifyListeners();

    final roomType = {
      'hotel_id': GeneralManager.hotelID,
      'room_type_id': this.roomType != null ? this.roomType!.id : teId.text,
      'room_type_name': teName.text,
      'room_type_guest': num.parse(teNumGuest.text.replaceAll(',', '')),
      'room_type_price': num.parse(tePrice.text.replaceAll(',', '')),
      'room_type_beds': bedChoose,
      'room_type_min_price': num.parse(teMinPrice.text.replaceAll(',', '')),
    };
    HttpsCallable callable;
    try {
      if (this.roomType != null) {
        callable = FirebaseFunctions.instance
            .httpsCallable('hotelmanager-editRoomType');
      } else {
        callable = FirebaseFunctions.instance
            .httpsCallable('hotelmanager-createRoomType');
      }
      await callable(roomType);
      isLoading = false;
      notifyListeners();
      return '';
    } on FirebaseFunctionsException catch (e) {
      errorLog = MessageUtil.getMessageByCode(e.message);
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }

  void cancel() {
    teNumGuest.dispose();
    tePrice.dispose();
    teId.dispose();
    teName.dispose();
  }
}
