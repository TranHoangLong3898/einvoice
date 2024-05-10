// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';

import '../../manager/generalmanager.dart';
import '../../manager/itemmanager.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/messageulti.dart';
import '../../validator/stringvalidator.dart';

class ItemController extends ChangeNotifier {
  HotelItem? oldItemService;
  bool? isInProgress = false, isAddFeature;
  Uint8List? base64;
  late TextEditingController teIdController, teNameController;
  late NeutronInputNumberController teCostPrice;
  late String unit;
  late List<String> units;

  ItemController(HotelItem? newItem) {
    if (newItem == null) {
      isAddFeature = true;
      teIdController = TextEditingController();
      teNameController = TextEditingController();
      teCostPrice =
          NeutronInputNumberController(TextEditingController(text: ''));
      unit = MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_UNIT);
    } else {
      oldItemService = newItem;
      isAddFeature = false;
      teIdController = TextEditingController(text: newItem.id);
      teNameController = TextEditingController(text: newItem.name);
      teCostPrice = NeutronInputNumberController(
          TextEditingController(text: newItem.costPrice?.toString() ?? ''));
      unit = newItem.unit ??
          MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_UNIT);
      base64 = newItem.image;
    }
  }

  void setUnit(String newUnit) {
    if (unit == newUnit) return;
    unit = MessageUtil.messageMap.entries
        .firstWhere((element) =>
            element.value![GeneralManager.locale!.languageCode] == newUnit)
        .key;
    notifyListeners();
  }

  String setImageToItem(PlatformFile pickedFile) {
    if (pickedFile.size > 1024 * 100) {
      base64 = null;
      return MessageUtil.getMessageByCode(MessageCodeUtil.IMAGE_OVER_MAX_SIZE);
    }
    base64 = pickedFile.bytes;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> updateItem() async {
    if (isInProgress!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    String? validateId =
        StringValidator.validateRequiredId(teIdController.text);
    if (validateId != null) {
      return validateId;
    }
    String? validateName =
        StringValidator.validateRequiredName(teNameController.text);
    if (validateName != null) {
      return validateName;
    }
    if (unit == MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_UNIT)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.TEXTALERT_PLEASE_CHOOSE_UNIT);
    }

    double? costPriceItem =
        double.tryParse(teCostPrice.controller.text.replaceAll(',', ''))!;
    if (costPriceItem == null || costPriceItem <= 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.COST_PRICE_MUST_BE_A_POSITIVE_NUMBER);
    }

    HotelItem newItem = HotelItem(
        id: teIdController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        unit: unit,
        name: teNameController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
        costPrice: costPriceItem,
        defaultWarehouseId: oldItemService?.defaultWarehouseId,
        image: base64,
        sellPrice: oldItemService?.sellPrice,
        type: oldItemService?.type ?? ItemType.other,
        isActive: oldItemService?.isActive ?? true);
    String result;
    if (isAddFeature!) {
      isInProgress = true;
      notifyListeners();
      result = await ItemManager().createItem(newItem).then((value) => value);
      if (result == MessageCodeUtil.SUCCESS && base64 != null) {
        FirebaseStorage.instance
            .ref('img_item/${GeneralManager.hotelID}/${newItem.id}')
            .putData(base64!)
            .then((p0) => print('Add image successfully!'))
            .onError((error, stackTrace) => print(error));
      }
    } else {
      if (oldItemService!.equalTo(newItem)) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
      }
      isInProgress = true;
      notifyListeners();
      result = await ItemManager().updateItem(newItem).then((value) => value);
      if (result == MessageCodeUtil.SUCCESS &&
          oldItemService!.image != newItem.image &&
          base64 != null) {
        FirebaseStorage.instance
            .ref('img_item/${GeneralManager.hotelID}/${newItem.id}')
            .putData(base64!)
            .then((p0) => print('Update image successfully!'))
            .onError((error, stackTrace) => print(error));
      }
    }
    // ItemManager()
    //   ..filter()
    //   ..rebuild();
    isInProgress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
