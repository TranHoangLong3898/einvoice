import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/activity.dart';
import 'package:ihotel/util/messageulti.dart';

import '../constants.dart';
import '../handler/firebasehandler.dart';

class ActivityController extends ChangeNotifier {
  static final ActivityController _instance = ActivityController._singleton();
  ActivityController._singleton();

  StreamSubscription? activityStream;
  bool isStreamed = false;

  Map<String, Activity>? activities = {};
  DocumentSnapshot? lastActivityQueried;
  int pageSize = 10;
  late int pageIndex = 0;
  late int startIndex;
  late int endIndex;
  bool isLoading = false;
  bool isHaveNotification = false;

  factory ActivityController() {
    return _instance;
  }

  void cancel() {
    isStreamed = false;
    activities!.clear();
    lastActivityQueried = null;
    pageSize = 10;
    pageIndex = 0;
    isLoading = false;
    isHaveNotification = false;
    if (activityStream != null) {
      activityStream?.cancel();
      print('asyncActivities: cancelled');
    }
  }

  void getActivitiesFromCloud(bool isLimited) {
    if (FirebaseAuth.instance.currentUser == null ||
        !GeneralManager().canReadActivity) return;
    if (isStreamed) return;
    print('Starting async activities from cloud: ${DateTime.now()}');
    isStreamed = true;
    activityStream = FirebaseHandler.hotelRef
        .collection('activities')
        .orderBy('id', descending: true)
        .limit(2)
        .snapshots()
        .listen((event) {
      if (event.docs.isNotEmpty) {
        activities!.clear();
        // ignore: avoid_function_literals_in_foreach_calls
        event.docs.forEach((element) {
          lastActivityQueried = element;
          for (int i = lastActivityQueried!.get('activities').length - 1;
              i >= 0;
              i--) {
            Activity item =
                Activity.fromJson(lastActivityQueried!.get('activities')[i]);

            //housekeeping and maintainer will be limited on seeing notification
            if (isLimited) {
              if (item.type == 'deposit') continue;
              //can see only notification about CRUD minibar/laundry
              if (item.type == 'service') {
                List<String> descArray =
                    item.desc.toString().split(specificCharacter);
                if (descArray[3] != MessageCodeUtil.ACTIVITY_MINIBAR_SERVICE &&
                    descArray[3] != MessageCodeUtil.ACTIVITY_LAUNDRY_SERVICE) {
                  continue;
                }
              }
              //can see only notification about checkout booking
              if (item.type == 'booking') {
                List<String> descArray =
                    item.desc.toString().split(specificCharacter);
                if (descArray[2] != 'checkout') {
                  continue;
                }
              }
            }
            activities![
                    '${lastActivityQueried!.id}${item.createdTime.seconds * Random().nextInt(100)}'] =
                item;
          }
        });
        isHaveNotification = true;
        updateIndex();
        notifyListeners();
      }
    });
  }

  void updateIndex() {
    startIndex = pageIndex * pageSize;
    endIndex = pageIndex * pageSize + pageSize > activities!.length
        ? activities!.length
        : pageIndex * pageSize + pageSize;
  }

  Future<void> nextPage() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (FirebaseAuth.instance.currentUser == null ||
        !GeneralManager().canReadActivity) return;
    if (activities!.length > (pageIndex * pageSize + pageSize)) {
      pageIndex++;
      updateIndex();
      isLoading = false;
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    await FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID)
        .collection('activities')
        .orderBy('id', descending: true)
        .startAfterDocument(lastActivityQueried!)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        lastActivityQueried = value.docs.last;
        for (int i = lastActivityQueried!.get('activities').length - 1;
            i >= 0;
            i--) {
          //element in array ~~ an activity object
          Activity item =
              Activity.fromJson(lastActivityQueried!.get('activities')[i]);
          activities!['${lastActivityQueried!.id}${item.createdTime.seconds}'] =
              item;
        }

        updateIndex();
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void previousPage() {
    if (pageIndex == 0) return;
    isLoading = true;
    notifyListeners();
    --pageIndex;
    if (pageIndex < 0) pageIndex = 0;
    updateIndex();
    isLoading = false;
    notifyListeners();
  }

  void firstPage() {
    if (pageIndex == 0) return;
    pageIndex = 0;
    updateIndex();
    notifyListeners();
  }

  void lastPage() {
    int lastIndex = (activities!.length / pageSize).ceilToDouble().toInt() - 1;
    if (activities!.length <= pageSize || pageIndex == lastIndex) {
      return;
    }
    pageIndex = (activities!.length / pageSize).ceilToDouble().toInt() - 1;
    updateIndex();
    notifyListeners();
  }

  void turnOffNotification() {
    isHaveNotification = false;
    notifyListeners();
  }
}
