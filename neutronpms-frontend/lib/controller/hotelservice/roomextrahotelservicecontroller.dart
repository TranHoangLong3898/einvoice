import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class RoomExtraHotelServiceController extends ChangeNotifier {
  final ConfigurationManagement? management;
  //check whether just display or allow to edit
  bool isUpdatablePrice = false;
  bool isAddEarlyCheckIn = false;
  bool isShowEditButtonEarlyCheckin = false;
  bool isShowEditButtonLateCheckout = false;

  bool isInProgress = false;

  late String oldAdultPrice, oldChildPrice;

  late TextEditingController teAdultPriceController, teChildPriceController;
  SplayTreeMap<String, num> earlyCheckIn = SplayTreeMap();
  SplayTreeMap<String, num> lateCheckOut = SplayTreeMap();

  //for add extra_hour screen
  late TextEditingController teHourController, teRatioController;

  RoomExtraHotelServiceController(this.management) {
    teAdultPriceController = TextEditingController(
        text: management!.roomExtra?.adultPrice?.toString() ?? '0');
    teChildPriceController = TextEditingController(
        text: management!.roomExtra?.childPrice?.toString() ?? '0');
    oldAdultPrice = management!.roomExtra?.adultPrice?.toString() ?? '0';
    oldChildPrice = management!.roomExtra?.childPrice?.toString() ?? '0';

    teRatioController = TextEditingController();
    teHourController = TextEditingController();
  }

  void changeEditButtonEarlyCheckinStatus(bool value) {
    isShowEditButtonEarlyCheckin = value;
    notifyListeners();
  }

  void changeEditButtonLateCheckoutStatus(bool value) {
    isShowEditButtonLateCheckout = value;
    notifyListeners();
  }

  Future<String> addExtraHour() async {
    num ratio = num.parse(teRatioController.text.replaceAll(',', ''));
    if (ratio > 100 || ratio < 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.RATIO_MUST_BE_FROM_0_TO_100);
    }
    earlyCheckIn
        .addAll(management?.roomExtra?.earlyCheckIn as Map<String, num>);
    lateCheckOut
        .addAll(management?.roomExtra?.lateCheckOut as Map<String, num>);
    if (isAddEarlyCheckIn) {
      if (management!.roomExtra!.earlyCheckIn!.keys
          .contains(teHourController.text.replaceAll(',', ''))) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.DUPLICATED_HOUR);
      }
      earlyCheckIn[teHourController.text.replaceAll(',', '')] = ratio / 100;
    } else {
      if (management!.roomExtra!.lateCheckOut!.keys
          .contains(teHourController.text.replaceAll(',', ''))) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.DUPLICATED_HOUR);
      }
      lateCheckOut[teHourController.text.replaceAll(',', '')] = ratio / 100;
    }
    isInProgress = true;
    notifyListeners();
    String result = await management!
        .updateRoomExtraHotelService(
            earlyCheckIn: earlyCheckIn, lateCheckOut: lateCheckOut)
        .then((value) {
      return value;
    }).catchError((e) {
      return e.toString();
    });
    earlyCheckIn.clear();
    lateCheckOut.clear();
    isShowEditButtonEarlyCheckin = false;
    isShowEditButtonLateCheckout = false;
    isInProgress = false;
    notifyListeners();
    return result;
  }

  Future<String> removeExtraHour(String key, bool isRemoveEarlyCheckIn) async {
    earlyCheckIn
        .addAll(management!.roomExtra?.earlyCheckIn as Map<String, num>);
    lateCheckOut
        .addAll(management!.roomExtra?.lateCheckOut as Map<String, num>);
    dynamic keyRemove;
    if (isRemoveEarlyCheckIn) {
      keyRemove = earlyCheckIn.remove(key);
    } else {
      keyRemove = lateCheckOut.remove(key);
    }
    if (keyRemove == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);
    }
    isInProgress = true;
    notifyListeners();
    String result = await management!
        .updateRoomExtraHotelService(
            earlyCheckIn: earlyCheckIn, lateCheckOut: lateCheckOut)
        .then((value) {
      return value;
    }).catchError((e) {
      return e.toString();
    });
    earlyCheckIn.clear();
    lateCheckOut.clear();
    isShowEditButtonLateCheckout = false;
    isShowEditButtonEarlyCheckin = false;
    isInProgress = false;
    notifyListeners();
    return result;
  }

  Future<String> updatePrice() async {
    if (oldAdultPrice == teAdultPriceController.text.replaceAll(',', '') &&
        oldChildPrice == teChildPriceController.text.replaceAll(',', '')) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (teAdultPriceController.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_ADULT_PRICE);
    }
    if (teChildPriceController.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_CHILD_PRICE);
    }
    num adultPrice = num.parse(teAdultPriceController.text.replaceAll(',', ''));
    num childPrice = num.parse(teChildPriceController.text.replaceAll(',', ''));
    isInProgress = true;
    notifyListeners();
    String result = await management!
        .updateRoomExtraHotelService(
            adultPrice: adultPrice, childPrice: childPrice)
        .then((value) => value)
        .catchError((e) => MessageUtil.getMessageByCode(e.message));
    if (result == MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
      isUpdatablePrice = false;
    }

    isShowEditButtonLateCheckout = false;
    isShowEditButtonEarlyCheckin = false;
    isInProgress = false;
    notifyListeners();
    return result;
  }

  void setUpdateStatus(bool status) {
    if (isUpdatablePrice == status) return;
    isUpdatablePrice = status;
    notifyListeners();
  }

  String getDesc(String? hour, bool isEarlyCheckin) {
    SplayTreeMap? map = (isEarlyCheckin
        ? management?.roomExtra?.earlyCheckIn
        : management?.roomExtra?.lateCheckOut);

    if (hour == null) {
      if (map == null || map.keys.isEmpty) {
        return '0 < ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOUR)}';
      }
      return '${map.keys.last} < ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOUR)}';
    }
    int index = map!.keys.toList().indexOf(hour);
    if (index == 0) {
      return '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOUR)} ≤ $hour';
    } else {
      return '${map.keys.elementAt(index - 1)} < ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HOUR)} ≤ $hour';
    }
  }
}
