import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../../manager/laundrymanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/laundry.dart';
import 'addservicecontroller.dart';

class LaundryController extends ChangeNotifier {
  List<Laundry>? laundries = [];
  final Booking booking;
  LaundryController(this.booking) {
    update();
  }

  void update() async {
    laundries = await booking.getLaundries();
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}

class AddLaundryController extends AddServiceController {
  Map<String, TextEditingController> teLaundryControllers = {};
  Map<String, TextEditingController> teIronControllers = {};
  late TextEditingController teDesc, teSaler;
  String emailSalerOld = '';
  final Booking? booking;
  bool adding = false;

  AddLaundryController(this.booking) {
    teDesc = TextEditingController(text: "");
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
    LaundryManager().getActiveItems().forEach((item) {
      teLaundryControllers[item] = TextEditingController(text: "");
      teIronControllers[item] = TextEditingController(text: "");
    });
  }

  void disposeTextEditingControllers() {
    // ignore: avoid_function_literals_in_foreach_calls
    teLaundryControllers.values.forEach((controller) => controller.dispose());
    // ignore: avoid_function_literals_in_foreach_calls
    teIronControllers.values.forEach((controller) => controller.dispose());
  }

  Future<String> addLaundry() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    Map<String, dynamic> mapItems = <String, dynamic>{};
    teLaundryControllers.forEach((item, teController) {
      final lamount = num.tryParse(teController.text.isEmpty
          ? '0'
          : teController.text.replaceAll(',', ''));
      final iamount = num.tryParse(teIronControllers[item]!.text.isEmpty
          ? '0'
          : teIronControllers[item]!.text.replaceAll(',', ''));
      if (lamount == null || iamount == null) return;
      if (lamount <= 0 && iamount <= 0) return;
      Map mapItem = LaundryManager().createItemMap(
          lprice: LaundryManager().getLaundryPrice(item),
          lamount: lamount,
          iprice: LaundryManager().getIronPrice(item),
          iamount: iamount);
      if (mapItem.keys.isNotEmpty) mapItems[item] = mapItem;
    });

    if (mapItems.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_ITEM_ADDED);
    }
    final laundry = Laundry(
        time: Timestamp.now(),
        items: mapItems,
        name: booking!.name,
        room: booking!.room,
        desc: teDesc.text,
        saler: teSaler.text);
    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    adding = true;
    notifyListeners();
    String result = await booking!
        .addService(laundry)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class UpdateLaundryController extends UpdateServiceController {
  Map<String, TextEditingController> teLaundryControllers = {};
  Map<String, TextEditingController> teIronControllers = {};
  //key = name; value = {iron: {amount:..., price:...}, laundry: {amount:..., price:...}}
  Map<String, dynamic> oldItems = {};
  final Booking? booking;
  final Laundry? service;
  late TextEditingController teDesc, teSaler;
  String emailSalerOld = '';

  UpdateLaundryController({this.booking, this.service}) {
    teDesc = TextEditingController(text: service!.desc ?? "");
    teSaler = TextEditingController(text: service!.saler ?? "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
    saveOldItems();
    getServiceItems().forEach((item) {
      teLaundryControllers[item] = TextEditingController(
          text: service!.getAmount(item, 'laundry').toString());
      teIronControllers[item] = TextEditingController(
          text: service!.getAmount(item, 'iron').toString());
    });
  }

  void disposeTextEditingControllers() {
    // ignore: avoid_function_literals_in_foreach_calls
    teLaundryControllers.values.forEach((controller) => controller.dispose());
    // ignore: avoid_function_literals_in_foreach_calls
    teIronControllers.values.forEach((controller) => controller.dispose());
  }

  //set keys and values of oldItem = laundryItems
  @override
  void saveOldItems() {
    service!.items!.forEach((key, value) {
      oldItems[key] = value;
    });
  }

  //get list types of laundry-service
  @override
  List<String> getServiceItems() => service!.getItems()!;

  // return true if user changed amount of items in laundry
  // return false if user changed nothing
  @override
  bool isServiceItemsChanged() {
    bool differencesDesc = service!.desc != teDesc.text;
    if (oldItems.keys.length != service!.items!.keys.length ||
        differencesDesc ||
        emailSalerOld != teSaler.text) {
      return true;
    }
    try {
      for (String key in oldItems.keys) {
        if (oldItems[key].length != service!.items![key].length ||
            differencesDesc) return true;
        if (oldItems[key]['laundry'] != null) {
          num oldLaundryAmount =
              num.parse(oldItems[key]['laundry']['amount'].toString());
          num newLaundryAmount =
              num.parse(service!.items![key]['laundry']['amount'].toString());
          if (oldLaundryAmount != newLaundryAmount ||
              differencesDesc ||
              emailSalerOld != teSaler.text) {
            return true;
          }
        }
        if (oldItems[key]['iron'] != null) {
          num oldIronAmount =
              num.parse(oldItems[key]['iron']['amount'].toString());
          num newIronAmount =
              num.parse(service!.items![key]['iron']['amount'].toString());
          if (oldIronAmount != newIronAmount ||
              differencesDesc ||
              emailSalerOld != teSaler.text) return true;
        }
      }
      return false;
    } catch (e) {
      print(e);
      return true;
    }
  }

  @override
  void updateService() {
    teLaundryControllers.forEach((key, value) {
      if ((value.text.isEmpty || value.text == '0') &&
          (teIronControllers[key]!.value.text == '0' ||
              teIronControllers[key]!.value.text.isEmpty)) {
        service!.items!.remove(key);
        return;
      }
      service!.items![key] = {
        if (value.text != '0')
          'laundry': {
            'price': LaundryManager().getLaundryPrice(key),
            'amount': num.parse(value.text.replaceAll(',', ''))
          },
        if (teIronControllers[key]!.value.text != '0')
          'iron': {
            'price': LaundryManager().getIronPrice(key),
            'amount': num.parse(
                teIronControllers[key]!.value.text.replaceAll(',', ''))
          }
      };
    });
  }

  //update money-total to screen
  void updateTotal() {
    service!.total = service!.getTotal();
    notifyListeners();
  }

  @override
  Future<String> updateServiceToDatabase() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    if (!isServiceItemsChanged()) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (service!.items!.isEmpty) {
      service!.items!.addAll(oldItems);
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.DIRECT_TO_DELETE_BUTTON);
    }
    if (updating!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    service!.desc = teDesc.text;
    service!.saler = teSaler.text;
    setProgressUpdating();
    String result = await booking!
        .updateService(service!)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    // result == null means updating successfully. Then update oldItems = current laundryItems
    if (result == MessageCodeUtil.SUCCESS) {
      saveOldItems();
      updateTotal();
    } else {
      service!.items!.clear();
      service!.items!.addEntries(oldItems.entries);
    }
    setProgressDone();
    return MessageUtil.getMessageByCode(result);
  }
}
