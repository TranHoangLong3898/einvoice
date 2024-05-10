import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowAllotmentController extends ChangeNotifier {
  late bool value;

  ShowAllotmentController() {
    value = GeneralManager.showAllotment;
  }

  void onChange(bool newValue) {
    value = !newValue;
    notifyListeners();
  }

  Future<bool> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("showAllotment", value);
    return true;
  }

  void rebuild() {
    if (value == GeneralManager.showAllotment) {
      return;
    }
    GeneralManager.showAllotment = value;
    GeneralManager().rebuild();
  }
}
