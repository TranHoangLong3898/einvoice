import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/requestmanager.dart';
import '../../modal/item.dart';

class ItemManagementController extends ChangeNotifier {
  late String type;
  List<String> types = [];
  bool addMode = false;
  TextEditingController teItem = TextEditingController();
  TextEditingController teUnit = TextEditingController();
  TextEditingController teNewType = TextEditingController();
  List<Item> items = [];
  bool inProgress = false;

  ItemManagementController() {
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

  Future<void> updateItems() async {
    items = await RequestManager().getItems(type);
  }

  void disposeAllTextEditingControllers() {
    teItem.dispose();
    teUnit.dispose();
    teNewType.dispose();
  }

  void setType(String newType) async {
    if (newType == type) return;
    type = newType;
    await updateItems();
    notifyListeners();
  }

  void toogleMode() {
    addMode = !addMode;
    notifyListeners();
  }

  Future<String> addItem() async {
    if (inProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    inProgress = true;
    final item = Item(name: teItem.text, unit: teUnit.text);
    final result = await RequestManager()
        .addItem(item, type)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    inProgress = false;
    if (result == MessageCodeUtil.SUCCESS) {
      items.removeWhere((element) => element.name == item.name);
      items.add(item);
      teItem.text = '';
      teUnit.text = '';
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }

  Future<String> deleteItem(String name) async {
    if (inProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    inProgress = true;
    final result = await RequestManager()
        .removeItem(name, type)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    inProgress = false;
    if (result == MessageCodeUtil.SUCCESS) {
      items.removeWhere((item) => item.name == name);
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }

  Future<String> addItemType() async {
    if (inProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    inProgress = true;
    final newType = teNewType.text;
    final result = await RequestManager().addItemType(newType);
    inProgress = false;
    if (result == MessageCodeUtil.SUCCESS) {
      if (!types.contains(newType)) {
        types.add(newType);
      }
      teNewType.text = '';
      addMode = false;
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }

  Future<String> deleteItemType() async {
    if (inProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    inProgress = true;
    final result = await RequestManager().deleteItemType(type);
    inProgress = false;
    if (result == MessageCodeUtil.SUCCESS) {
      types.remove(type);
      type = (types.isNotEmpty ? types.first : null)!;
      await updateItems();
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }
}
