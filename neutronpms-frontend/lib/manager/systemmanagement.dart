import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/versionmanager.dart';

class SystemManagement {
  static final SystemManagement _instance = SystemManagement._singleton();
  SystemManagement._singleton();

  factory SystemManagement() {
    return _instance;
  }

  Map<String, dynamic> beds = {};
  bool isStreaming = false;
  StreamSubscription? streamSubscription;

  Future<void> update() async {
    await getConfigurationFromCloud();
  }

  getConfigurationFromCloud() {
    try {
      if (isStreaming) {
        return;
      }
      isStreaming = true;
      print('asyncSystemConfiguration: Init');
      streamSubscription = FirebaseFirestore.instance
          .collection('system')
          .doc('configuration')
          .snapshots()
          .listen((snapshots) {
        if (snapshots.exists) {
          beds = snapshots.get('beds');
          VersionManager().update(snapshots.get('version'));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void cancelStream() {
    streamSubscription?.cancel();
    isStreaming = false;
    print('asyncSystemConfiguration: Cancelled');
  }

  String getBedNameById(String idBed) {
    return beds[idBed];
  }

  String getBedIdByName(String nameBed) {
    for (var item in beds.keys) {
      if (beds[item] == nameBed) {
        return item;
      }
    }
    return '?';
  }

  List<String> getBedsName() => beds.values.map((e) => e.toString()).toList();
  List<String> getBedsId() => beds.keys.toList();
}
