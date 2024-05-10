import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/order.dart';
import 'package:ihotel/util/messageulti.dart';

import '../handler/firebasehandler.dart';
import '../modal/item.dart';
import '../modal/request.dart';

class RequestManager {
  static const statusNotYet = -1;
  static const statusNo = 0;
  static const statusYes = 1;

  Future<List<Request>?> getRequestsByOrderID(String orderID) async {
    try {
      List<Request> requests = [];

      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colRequests)
          .where('order_id', isEqualTo: orderID)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          requests.add(Request.fromSnapshot(doc));
        }
      });

      return requests;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<dynamic>> getItemTypes() async => await FirebaseHandler.hotelRef
          .collection('configs')
          .doc('item_types')
          .get()
          .then((doc) => doc.get('types'))
          .catchError((e) {
        print(e.toString());
        return [];
      });

  Future<String> addItemType(String type) async {
    if (type.trim().isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('item-addItemType')
        .call({'hotel_id': GeneralManager.hotelID, 'item_type': type}).then(
            (value) => value.data);
  }

  Future<String> deleteItemType(String type) async {
    if (type.trim().isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('item-deleteItemType')
        .call({'hotel_id': GeneralManager.hotelID, 'item_type': type}).then(
            (value) => value.data);
  }

  Future<String> addItem(Item item, String type) async {
    if (item.name!.trim().isEmpty ||
        item.unit!.trim().isEmpty ||
        type.trim().isEmpty) {
      return MessageCodeUtil.INVALID_DATA;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('item-addItemToCloud')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'item_type': type,
      'item_name': item.name,
      'unit': item.unit
    }).then((value) => value.data);
  }

  Future<String> removeItem(String item, String type) async {
    if (item.trim().isEmpty || type.trim().isEmpty) {
      return MessageCodeUtil.INVALID_DATA;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('item-addItemToCloud')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'item_type': type,
      'item_name': item,
    }).then((value) => value.data);
  }

  Future<List<Item>> getItems(String type) async =>
      await FirebaseHandler.hotelRef
          .collection('items')
          .doc(type)
          .get()
          .then((doc) {
        List<Item> items = [];
        if (!doc.exists) return <Item>[];
        if (!doc.data()!.containsKey('items')) return <Item>[];
        final dataOfItems = doc.get('items');
        for (var item in dataOfItems.keys) {
          items.add(Item(name: item, unit: dataOfItems[item]['unit']));
        }
        return items;
      }).catchError((e) {
        print(e.toString());
        return <Item>[];
      });

  Future<String> updateApproval(List<String> ids, num value) async {
    if (ids.isEmpty) return MessageCodeUtil.NO_REQUEST;
    if (value < statusNotYet || value > statusYes) {
      return MessageCodeUtil.WRONG_APPROVAL_REQUEST;
    }
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var id in ids) {
        batch.update(
            FirebaseHandler.hotelRef
                .collection(FirebaseHandler.colRequests)
                .doc(id),
            {'approved': value});
      }

      await batch.commit();
      return MessageCodeUtil.SUCCESS;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }

  Future<String> deleteRequests(List<String> ids) async {
    if (ids.isEmpty) return MessageCodeUtil.NO_REQUEST;

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var id in ids) {
        batch.delete(FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colRequests)
            .doc(id));
      }

      await batch.commit();
      return MessageCodeUtil.SUCCESS;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }

  Future<String> updateOrderToCloud(
      OrderSupplier order, List<Request?> requests) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var request in requests) {
        batch.update(
            FirebaseHandler.hotelRef
                .collection(FirebaseHandler.colRequests)
                .doc(request!.id),
            {'price': request.price, 'order_id': request.orderID});
      }
      batch.set(
          FirebaseHandler.hotelRef
              .collection(FirebaseHandler.colOrders)
              .doc(order.id),
          {'desc': order.desc, 'supplier': order.supplier});
      await batch.commit();
      return MessageCodeUtil.SUCCESS;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }
}
