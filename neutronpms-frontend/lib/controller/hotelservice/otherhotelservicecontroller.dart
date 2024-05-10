import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/otherhotelservice.dart';
import 'package:ihotel/util/messageulti.dart';

class OtherHotelServiceController extends ChangeNotifier {
  final OtherHotelService? service;
  bool isInProgress = false;
  late bool isAddFeature;
  late TextEditingController teIdController;
  late TextEditingController teNameController;

  OtherHotelServiceController(this.service) {
    if (service == null) {
      isAddFeature = true;
      teIdController = TextEditingController();
      teNameController = TextEditingController();
    } else {
      isAddFeature = false;
      teIdController = TextEditingController(text: service!.id);
      teNameController = TextEditingController(text: service!.name);
    }
  }

  Future<String> updateOther() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isInProgress = true;
    notifyListeners();
    String result;
    OtherHotelService otherHotelService = OtherHotelService(
        id: teIdController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        name: teNameController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim());
    if (isAddFeature) {
      result = await ConfigurationManagement.createOtherHotelService(
              otherHotelService)
          .then((value) => value);
    } else {
      result = await ConfigurationManagement.updateOtherHotelService(
              otherHotelService)
          .then((value) => value);
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
