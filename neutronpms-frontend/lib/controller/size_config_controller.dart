import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SizeConfigController extends ChangeNotifier {
  late bool isLoading;
  late double value;

  SizeConfigController() {
    isLoading = false;
    value = GeneralManager.cellHeight;
  }

  void onChange(double newValue) {
    value = newValue;
    notifyListeners();
  }

  Future<bool> save() async {
    if (isLoading) {
      return false;
    }
    isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('cellHeight', value);
    isLoading = false;
    return true;
  }

  void rebuild() {
    if (value == GeneralManager.cellHeight) {
      return;
    }
    GeneralManager.cellHeight = value;
    GeneralManager.roomTypeCellHeight = value + 15;
    GeneralManager.bookingCellHeight = value - 6;
    GeneralManager().rebuild();
  }

  void reset() async {
    value = 40;
    notifyListeners();
  }
}
