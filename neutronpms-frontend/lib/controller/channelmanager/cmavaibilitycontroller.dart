import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/generalmanager.dart';
import '../../util/dateutil.dart';

class CMAvaibilityController extends ChangeNotifier {
  List<String?> roomTypeNames = [];
  TextEditingController valueController = TextEditingController();
  DateTime startAdjust = DateUtil.to12h(Timestamp.now().toDate());
  DateTime endAdjust = DateUtil.to12h(Timestamp.now().toDate());
  late String selectedRoomType;
  String selectedType = 'Avaibility';
  final List<num> chooseDay = [1, 2, 3, 4, 5, 6, 0];
  bool isMonday = true;
  bool isTuesday = true;
  bool isWednesday = true;
  bool isFriday = true;
  bool isThursday = true;
  bool isSaturday = true;
  bool isSunday = true;
  bool updating = false;

  TextEditingController priceController = TextEditingController();

  CMAvaibilityController() {
    initialize();
  }

  void initialize() async {
    roomTypeNames = RoomTypeManager().getRoomTypeNamesActived();
    selectedRoomType = (roomTypeNames.isNotEmpty ? roomTypeNames.first : "")!;
    notifyListeners();
  }

  void setMonDay(value) {
    if (value != isMonday) {
      isMonday = value;
      if (isMonday) {
        chooseDay.add(1);
      } else {
        chooseDay.remove(1);
      }
      notifyListeners();
    }
  }

  void setTuesday(value) {
    if (value != isTuesday) {
      isTuesday = value;
      if (isTuesday) {
        chooseDay.add(2);
      } else {
        chooseDay.remove(2);
      }
      notifyListeners();
    }
  }

  void setWednesday(value) {
    if (value != isWednesday) {
      isWednesday = value;
      if (isWednesday) {
        chooseDay.add(3);
      } else {
        chooseDay.remove(3);
      }
      notifyListeners();
    }
  }

  void setThursday(value) {
    if (value != isThursday) {
      isThursday = value;
      if (isThursday) {
        chooseDay.add(4);
      } else {
        chooseDay.remove(4);
      }
      notifyListeners();
    }
  }

  void setFriday(value) {
    if (value != isFriday) {
      isFriday = value;
      if (isFriday) {
        chooseDay.add(5);
      } else {
        chooseDay.remove(5);
      }
      notifyListeners();
    }
  }

  void setSaturday(value) {
    if (value != isSaturday) {
      isSaturday = value;
      if (isSaturday) {
        chooseDay.add(6);
      } else {
        chooseDay.remove(6);
      }
      notifyListeners();
    }
  }

  void setSunday(value) {
    if (value != isSunday) {
      isSunday = value;
      if (isSunday) {
        chooseDay.add(0);
      } else {
        chooseDay.remove(0);
      }
      notifyListeners();
    }
  }

  void setStartAdjust(DateTime date) {
    startAdjust = DateUtil.to12h(date);
    if (startAdjust.compareTo(endAdjust) > 0) {
      endAdjust = startAdjust;
    }
    notifyListeners();
  }

  void setEndAdjust(DateTime date) {
    endAdjust = DateUtil.to12h(date);
    notifyListeners();
  }

  void changeSelectedRoomType(String roomType) {
    if (roomType == selectedRoomType) return;
    selectedRoomType = roomType;
    notifyListeners();
  }

  void changeSelectedType(String type) {
    if (type == selectedType) return;
    selectedType = type;
    notifyListeners();
  }

  Future<String> updateAvaibility() async {
    try {
      if (valueController.text == '' && priceController.text == '') {
        return MessageCodeUtil.INVALID_DATA;
      }
      num? value;
      if (valueController.text != '') {
        value = num.tryParse(valueController.text)!;
        final maxRoomtype = RoomTypeManager()
            .getRoomTypeByID(
                RoomTypeManager().getRoomTypeIDByName(selectedRoomType))
            .total;
        if (value > maxRoomtype!) {
          return MessageCodeUtil.QUANTITY_ROOMTYPE_SMALLER_THAN_MAX_ROOMTYPE;
        }
      }
      num? price;
      if (priceController.text != '') {
        price = num.tryParse(priceController.text.replaceAll(',', ''))!;
        final minPrice = RoomTypeManager()
            .getRoomTypeByID(
                RoomTypeManager().getRoomTypeIDByName(selectedRoomType))
            .minPrice;
        if (price < minPrice!) {
          return MessageCodeUtil.PRICE_MUST_BIGGER_THAN_MIN_PRICE;
        }
      }
      if (endAdjust.compareTo(startAdjust) < 0) {
        return MessageCodeUtil.INVALID_DAY;
      }
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-updateavaibility');
      updating = true;
      notifyListeners();
      final result = await callable({
        "hotel": GeneralManager.hotelID,
        "roomType": RoomTypeManager().getRoomTypeIDByName(selectedRoomType),
        "from": startAdjust.toString(),
        "to": endAdjust.toString(),
        'value': value,
        'rate': price,
        'chooseDay': chooseDay
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        updating = false;
        notifyListeners();
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (e) {
      updating = false;
      notifyListeners();
      return e.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }
}
