import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/requestmanager.dart';
import '../../modal/item.dart';
import '../../modal/request.dart';

class AddRequestController extends ChangeNotifier {
  late String type;
  late Item item;

  TextEditingController teAmount = TextEditingController();
  TextEditingController teDesc = TextEditingController();
  List<String> types = [];
  List<Item> items = [];

  late Request addedRequest;

  bool adding = false;

  AddRequestController() {
    initialize();
  }

  void initialize() async {
    types = (await RequestManager().getItemTypes())
        .map((e) => e.toString())
        .toList();

    if (types.isNotEmpty) {
      type = types.first;
      await updateItems();
    }
    notifyListeners();
  }

  void disposeAllTextEditingControllers() {
    teDesc.dispose();
    teAmount.dispose();
  }

  void setType(String newType) async {
    if (newType == type) return;
    type = newType;

    await updateItems();
    notifyListeners();
  }

  void setItem(String newItem) async {
    if (newItem == item.name) return;
    item = items.firstWhere((element) => element.name == newItem);
    notifyListeners();
  }

  Future<void> updateItems() async {
    items = await RequestManager().getItems(type);
    if (items.isNotEmpty) item = items.first;
  }

  Future<String> addRequest() async {
    final amount = num.tryParse(teAmount.text);
    final request = Request(
        desc: teDesc.text,
        amount: amount,
        createdTime: Timestamp.now(),
        createdBy: FirebaseAuth.instance.currentUser!.email,
        item: item.name,
        unit: item.unit,
        type: type);
    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    adding = true;
    final result = await request.addToCloud();
    if (result == MessageUtil.getMessageByCode(null)) {
      addedRequest = request;
    }
    adding = false;
    return MessageUtil.getMessageByCode(result);
  }

  List<String> getItems() => items.map((e) => e.name!).toList();
}
