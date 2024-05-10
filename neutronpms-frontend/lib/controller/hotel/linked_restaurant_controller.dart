import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/modal/restaurant.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../handler/firebasehandler.dart';
import '../../manager/generalmanager.dart';

class LinkedRestaurantController extends ChangeNotifier {
  bool isLoading = false, isStreaming = false;
  StreamSubscription? streamSubscription;
  List<Restaurant> restaurantDisplay = [];

  LinkedRestaurantController();

  void listenColRestaurant() {
    if (isStreaming) {
      return;
    }

    streamSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc('restaurants')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        restaurantDisplay.clear();
        final Map<String, dynamic> mapData = doc.get('data');
        for (var entry in mapData.entries) {
          restaurantDisplay
              .add(Restaurant.fromSnapshot(entry.key, entry.value));
        }
        notifyListeners();
      }
    });
  }

  Future<String> activeOrDeactiveLinkedRestaurant(Restaurant restaurant) async {
    isLoading = true;
    notifyListeners();
    HttpsCallable callable;
    final dataCallable = {
      'hotel_id': GeneralManager.hotelID,
      'res_id': restaurant.id
    };
    if (restaurant.isLinked!) {
      callable = FirebaseFunctions.instance
          .httpsCallable('restaurant-disableConnectRestaurant');
    } else {
      callable = FirebaseFunctions.instance
          .httpsCallable('restaurant-acceptConnectRestaurant');
    }
    try {
      await callable(dataCallable);
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
    isLoading = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  void dispol() {
    restaurantDisplay.clear();
    streamSubscription?.cancel();
  }
}
