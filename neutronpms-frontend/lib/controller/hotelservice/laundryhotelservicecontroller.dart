import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/hotelservice/laundryhotelservice.dart';
import 'package:ihotel/util/messageulti.dart';

class LaundryHotelServiceController extends ChangeNotifier {
  final LaundryHotelService? service;
  bool isInProgress = false;
  late bool isAddFeature;
  late TextEditingController teIdController;
  late TextEditingController teNameController;
  late TextEditingController tePlaundryController;
  late TextEditingController tePironController;

  LaundryHotelServiceController(this.service) {
    if (service == null) {
      isAddFeature = true;
      teIdController = TextEditingController();
      teNameController = TextEditingController();
      tePlaundryController = TextEditingController();
      tePironController = TextEditingController();
    } else {
      isAddFeature = false;
      teIdController = TextEditingController(text: service!.id);
      teNameController = TextEditingController(text: service!.name);
      tePlaundryController =
          TextEditingController(text: service!.plaundry.toString());
      tePironController =
          TextEditingController(text: service!.piron.toString());
    }
  }

  Future<String> updateLaundry() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    num plaundry = num.parse(tePlaundryController.text.replaceAll(',', ''));
    num piron = num.parse(tePironController.text.replaceAll(',', ''));
    if (plaundry == 0 && piron == 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.TEXTALERT_BOTH_OF_PRICE_CAN_NOT_BE_ZERO);
    }
    isInProgress = true;
    notifyListeners();
    String result;
    LaundryHotelService laundryHotelService = LaundryHotelService(
        id: teIdController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        name: teNameController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        plaundry: plaundry,
        piron: piron);
    if (isAddFeature) {
      result = await ConfigurationManagement.createLaundryHotelService(
              laundryHotelService)
          .then((value) => value);
    } else {
      result = await ConfigurationManagement.updateLaundryHotelService(
              laundryHotelService)
          .then((value) => value);
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
