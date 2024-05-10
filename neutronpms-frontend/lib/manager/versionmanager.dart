import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import 'generalmanager.dart';

class VersionManager extends ChangeNotifier {
  static final VersionManager _instance = VersionManager._singleton();
  VersionManager._singleton();

  factory VersionManager() {
    return _instance;
  }

  static String? versionInCloud;
  bool isLoadding = true;

  void update(String version) {
    versionInCloud = version;
    isLoadding = false;
    notifyListeners();
  }

  bool isNeedToUpdate() {
    List<String> currentVersionArray = GeneralManager.version.split('.');
    List<String> cloudVersionArray = versionInCloud!.split('.');
    if (num.tryParse(currentVersionArray[0])! <
        num.tryParse(cloudVersionArray[0])!) {
      return true;
    }
    if (currentVersionArray[0] == cloudVersionArray[0] &&
        num.tryParse(currentVersionArray[1])! <
            num.tryParse(cloudVersionArray[1])!) {
      return true;
    }
    if (currentVersionArray[0] == cloudVersionArray[0] &&
        currentVersionArray[1] == cloudVersionArray[1] &&
        num.tryParse(currentVersionArray[2])! <
            num.tryParse(cloudVersionArray[2])!) {
      return true;
    }
    return false;
  }

  Future<String> updateVersionToCloud(String newVersion) async {
    return await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateVersion')
        .call({'version': newVersion})
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }
}
