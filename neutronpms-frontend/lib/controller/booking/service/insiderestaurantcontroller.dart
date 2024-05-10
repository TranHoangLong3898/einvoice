import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../../modal/booking.dart';
import 'addservicecontroller.dart';

class InsideRestaurantController extends ChangeNotifier {
  List<InsideRestaurantService>? insideRestaurants = [];
  final Booking booking;
  InsideRestaurantController(this.booking) {
    update();
  }

  void update() async {
    insideRestaurants = await booking.getInsideRestaurantServices();
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}

class AddInsideRestaurantController extends AddServiceController {
  Map<String, TextEditingController> teControllers = {};
  final Booking? booking;
  bool adding = false;
  late TextEditingController teSaler;
  String emailSalerOld = '';

  AddInsideRestaurantController(this.booking) {
    getItems().forEach((item) {
      teControllers[item!] = TextEditingController(text: "");
    });
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    // ignore: avoid_function_literals_in_foreach_calls
    teControllers.values.forEach((controller) => controller.dispose());
  }

  List<String?> getItems() => RestaurantItemManager().getActiveItemsId();

  Future<String> addInsideRestaurant() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }

    Map<String, dynamic> mapItems = <String, dynamic>{};
    teControllers.forEach((item, teController) {
      if (teController.text.isEmpty) return;
      if (int.tryParse(teController.text.replaceAll(',', ''))! > 0) {
        Map mapItem = RestaurantItemManager().createItemMap(
          price: RestaurantItemManager().getPriceOfItem(item),
          amount: int.tryParse(teController.text.replaceAll(',', '')),
        );
        mapItems[item] = mapItem;
      }
    });
    if (mapItems.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.NO_ITEM_ADDED);
    }

    final insideRestaurant = InsideRestaurantService(
        items: mapItems,
        created: Timestamp.now(),
        name: booking!.name,
        room: booking!.room,
        saler: teSaler.text);

    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    adding = true;
    notifyListeners();
    String result = await booking!
        .addService(insideRestaurant)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class UpdateInsideRestaurantController extends UpdateServiceController {
  Map<String, NeutronInputNumberController> teControllers = {};
  Map<String, dynamic> oldItems = {};
  final Booking? booking;
  final InsideRestaurantService? service;
  late TextEditingController teSaler;
  String emailSalerOld = '';

  UpdateInsideRestaurantController({this.booking, this.service}) {
    saveOldItems();
    getServiceItems().forEach((item) {
      teControllers[item] = NeutronInputNumberController(
          TextEditingController(text: service!.getAmount(item).toString()));
    });
    teSaler = TextEditingController(text: service!.saler ?? "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    for (var controller in teControllers.values) {
      controller.disposeTextController();
    }
  }

  @override
  void saveOldItems() {
    service!.items!.forEach((key, value) {
      oldItems[key] = value;
    });
  }

  @override
  List<String> getServiceItems() => service!.getItems()!;

  @override
  void updateService() {
    teControllers.forEach((key, value) {
      if (value.getRawString().isEmpty || value.getRawString() == '0') {
        service!.items!.remove(key);
        return;
      }
      service!.items![key] = {
        'price': int.parse(service!.getPrice(key).toString()),
        'amount': int.parse(value.getRawString().replaceAll(',', ''))
      };
    });
  }

  @override
  bool isServiceItemsChanged() {
    if (oldItems.keys.length != service!.items!.keys.length ||
        emailSalerOld != teSaler.text) {
      return true;
    }
    for (var item in service!.items!.keys) {
      int oldAmount = int.parse(oldItems[item]['amount'].toString());
      int newAmount = int.parse(service!.items![item]['amount'].toString());
      if (oldAmount != newAmount || emailSalerOld != teSaler.text) {
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
