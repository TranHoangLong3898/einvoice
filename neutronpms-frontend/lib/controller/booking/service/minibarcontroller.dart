import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../../manager/minibarmanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/minibar.dart';
import 'addservicecontroller.dart';

class MinibarController extends ChangeNotifier {
  List<Minibar>? minibars = [];
  final Booking booking;
  MinibarController(this.booking) {
    update();
  }

  void update() async {
    //get all minibar services which are ordered by Booking object
    minibars = await booking.getMinibars();
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}

class AddMinibarController extends AddServiceController {
  late TextEditingController teDesc, teSaler;
  String emailSalerOld = '';
  Map<String, TextEditingController> teMinibarControllers = {};
  final Booking? booking;
  bool adding = false;

  AddMinibarController(this.booking) {
    getMinibarItems().forEach((item) {
      teMinibarControllers[item] = TextEditingController(text: "");
    });
    teDesc = TextEditingController(text: "");
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    // ignore: avoid_function_literals_in_foreach_calls
    teMinibarControllers.values.forEach((controller) => controller.dispose());
  }

  //get list name of minibars
  List<String> getMinibarItems() => MinibarManager().getActiveItemsId();

  Future<String> addMinibar() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    Map<String, dynamic> mapItems = <String, dynamic>{};
    teMinibarControllers.forEach((item, teController) {
      if (teController.text.isEmpty) return;
      if (int.tryParse(teController.text.replaceAll(',', ''))! > 0) {
        Map mapItem = MinibarManager().createItemMap(
          price: MinibarManager().getPriceOfItem(item),
          amount: int.tryParse(teController.text.replaceAll(',', '')),
        );

        mapItems[item] = mapItem;
      }
    });
    if (mapItems.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_ITEM_ADDED);
    }

    final minibar = Minibar(
        items: mapItems,
        created: Timestamp.now(),
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
        .addService(minibar)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class UpdateMinibarController extends UpdateServiceController {
  Map<String, TextEditingController> teMinibarControllers = {};
  //key = id of minibarservice; value = {price: ..., amount:....}
  Map<String, dynamic> oldItems = {};
  final Booking? booking;
  final Minibar? service;
  late TextEditingController teDesc, teSaler;
  String emailSalerOld = '';

  UpdateMinibarController({this.booking, this.service}) {
    saveOldItems();
    getServiceItems().forEach((item) {
      teMinibarControllers[item] =
          TextEditingController(text: service!.getAmount(item).toString());
    });
    teDesc = TextEditingController(text: service!.desc ?? "");
    teSaler = TextEditingController(text: service!.saler ?? "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    // ignore: avoid_function_literals_in_foreach_calls
    teMinibarControllers.values.forEach((controller) => controller.dispose());
  }

  //set keys and values of oldItem = minibarItems
  @override
  void saveOldItems() {
    service!.items!.forEach((key, value) {
      oldItems[key] = value;
    });
  }

  //get list types of minibar-service
  @override
  List<String> getServiceItems() => service!.getItems()!;

  @override
  void updateService() {
    teMinibarControllers.forEach((key, value) {
      if (value.text.isEmpty || value.text == '0') {
        service!.items!.remove(key);
        return;
      }
      service!.items![key] = {
        'price': int.parse(service!.getPrice(key).toString()),
        'amount': int.parse(value.text.replaceAll(',', ''))
      };
    });
  }

  // return true if user changed amount of items in minibar
  // return false if user changed nothing
  @override
  bool isServiceItemsChanged() {
    if (oldItems.keys.length != service!.items!.keys.length ||
        service!.desc != teDesc.text ||
        emailSalerOld != teSaler.text) {
      return true;
    }
    for (var item in service!.items!.keys) {
      int oldAmount = int.parse(oldItems[item]['amount'].toString());
      int newAmount = int.parse(service!.items![item]['amount'].toString());
      if (oldAmount != newAmount ||
          service!.desc != teDesc.text ||
          emailSalerOld != teSaler.text) {
        return true;
      }
    }
    return false;
  }

  //update newTotal to screen
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
    setProgressUpdating();
    service!.desc = teDesc.text;
    service!.saler = teSaler.text;
    String result = await booking!
        .updateService(service!)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
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
