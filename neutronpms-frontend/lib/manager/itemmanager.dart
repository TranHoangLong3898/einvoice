import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/status.dart';

import '../handler/firebasehandler.dart';
import '../util/messageulti.dart';
import '../util/uimultilanguageutil.dart';
import 'generalmanager.dart';
import 'minibarmanager.dart';

class ItemManager extends ChangeNotifier {
  static final ItemManager _instance = ItemManager._singleton();
  ItemManager._singleton();

  factory ItemManager() => _instance;

  bool isStreaming = false, isLoading = false, isLoadingImprot = false;
  String statusServiceFilter =
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  String queryString = '';

  StreamSubscription? itemSubscription;
  List<HotelItem> items = [];
  Map<String, Uint8List?> itemImages = {};

  List<HotelItem> get itemsTypeOther => items
      .where((item) => item.isActive!)
      .where((element) => element.type == ItemType.other)
      .toList();

  void asyncItemsFromCloud() {
    if (isStreaming) {
      return;
    }
    isStreaming = true;

    print('asyncItemsFromCloud: Init');
    itemSubscription?.cancel();
    itemSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc(FirebaseHandler.colItems)
        .snapshots()
        .listen((snapshots) {
      items.clear();
      if (!snapshots.exists) {
        filter();
        MinibarManager().update();
        RestaurantItemManager().update();
        notifyListeners();
        return;
      }
      (snapshots.data()!['data'] as Map).forEach((key, value) async {
        HotelItem item = HotelItem.fromMap(key, value as Map<String, dynamic>);
        if (!itemImages.containsKey(item.id)) {
          Uint8List? img = await FirebaseStorage.instance
              .ref('img_item/${GeneralManager.hotelID}')
              .child(item.id!)
              .getData()
              .onError((error, stackTrace) => null);
          itemImages[item.id!] = img;
        }
        item.image = itemImages[item.id];
        items.add(item);
        if (items.length == snapshots.data()!['data'].length) {
          items.sort((a, b) => a.id!.compareTo(b.id!));
          filter();
          MinibarManager().update();
          RestaurantItemManager().update();
          notifyListeners();
        }
      });
    });
  }

  void cancelStream() {
    itemSubscription?.cancel();
    isStreaming = false;
    items.clear();
    itemImages.clear();
    print('asyncItemsFromCloud: Cancelled');
  }

  Future<String> createItem(HotelItem item) async {
    itemImages[item.id!] = item.image;
    return await FirebaseFunctions.instance
        .httpsCallable('item-createItem')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'item_id': item.id,
          'item_name': item.name,
          'item_cost_price': item.costPrice,
          'item_unit': item.unit,
          if (item.defaultWarehouseId?.isNotEmpty ?? false)
            'item_default_warehouse': item.defaultWarehouseId,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> createsMultipleItem(Map<String, dynamic> data) async {
    isLoadingImprot = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('item-createsMultipleItem')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'data_items': data,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoadingImprot = false;
          notifyListeners();
        });
  }

  Future<String> updateItem(HotelItem item) async {
    itemImages[item.id!] = item.image;
    items.firstWhere((element) => element.id == item.id).image = item.image;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('item-updateItem')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'item_id': item.id,
          'item_name': item.name,
          'item_cost_price': item.costPrice,
          'item_sell_price': item.sellPrice,
          'item_type': item.type,
          'item_unit': item.unit,
          'item_default_warehouse': item.defaultWarehouseId,
          'item_auto_export': item.isAutoExport
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> toggleActivation(String id) async {
    if (isLoading) {
      return MessageCodeUtil.IN_PROGRESS;
    }
    isLoading = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('item-toggleItemActivation')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'item_id': id,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isLoading = false;
    notifyListeners();
    return result;
  }

  List<String?> getIdsOfActiveItems() {
    return items
        .where((item) => item.isActive!)
        .map((item) => item.id)
        .toList();
  }

  String? getIdByName(String name) {
    try {
      return items.firstWhere((item) => item.name == name).id;
    } catch (e) {
      return null;
    }
  }

  String? getIdByNameAndUnit(String name, String unit) {
    try {
      return items
          .firstWhere((item) => item.name == name && item.unit == unit)
          .id;
    } catch (e) {
      return '';
    }
  }

  String? getItemNameByID(String id) {
    try {
      return items.firstWhere((item) => item.id == id).name;
    } catch (e) {
      return '';
    }
  }

  String? getItemUnitByID(String id) {
    try {
      return items.firstWhere((item) => item.id == id).unit;
    } catch (e) {
      return '';
    }
  }

  String? getNameAndUnitByID(String id) {
    try {
      HotelItem item = items.firstWhere((item) => item.id == id);
      return '${item.name} - ${item.unit}';
    } catch (e) {
      return null;
    }
  }

  HotelItem? getItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  HotelItem? getItemByName(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (e) {
      return null;
    }
  }

  bool isContainId(String id) => items.map((e) => e.id).toList().contains(id);

  void setStatusFilter(String value) {
    if (statusServiceFilter == value) {
      return;
    }
    statusServiceFilter = value;
    filter();
    notifyListeners();
  }

  void setQueryString(String newQuery) {
    if (queryString == newQuery) {
      return;
    }
    queryString = newQuery;
    filter();
    notifyListeners();
  }

  Iterable<HotelItem> filter() {
    return items.where((item) =>
        checkWithStatusFilter(item) &&
        _isPartialMatch(item.name!, queryString));
  }

  bool _isPartialMatch(String option, String searchText) {
    List<String> searchWords = searchText.split(' ');
    return searchWords.every((word) => option.toLowerCase().contains(word));
  }

  void rebuild() {
    notifyListeners();
  }

  bool checkWithStatusFilter(HotelItem item) {
    return (statusServiceFilter ==
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE) &&
            item.isActive!) ||
        (statusServiceFilter ==
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE) &&
            !item.isActive!) ||
        statusServiceFilter ==
            UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL);
  }

  List<HotelItem> getActiveItems() {
    return items.where((element) => element.isActive!).toList();
  }

  void removeItemDuplicated(String id, Map<String, dynamic> data) {
    data.remove(id);
    notifyListeners();
  }
}
