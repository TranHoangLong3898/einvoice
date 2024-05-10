import 'package:flutter/material.dart';

class RebuildNumber extends ChangeNotifier {
  num value;
  RebuildNumber(this.value);

  void rebuild(num newValue) {
    value = newValue;
    notifyListeners();
  }
}
