import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../manager/generalmanager.dart';

class SizeForFrontDeskBoardController extends ChangeNotifier {
  late int value;

  SizeForFrontDeskBoardController() {
    value = GeneralManager.sizeDatesForBoard;
  }

  void onChange(int newValue) {
    if (value == newValue) return;
    value = newValue;
    notifyListeners();
  }

  Future<bool> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("sizeboard", value);
    return true;
  }

  void rebuild() {
    if (value == GeneralManager.sizeDatesForBoard) {
      return;
    }
    GeneralManager.sizeDatesForBoard = value;
    GeneralManager().rebuild();
  }
}
