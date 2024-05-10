import 'package:flutter/material.dart';
import '../../ui/controls/neutrontextformfield.dart';

class PriceController extends ChangeNotifier {
  List<NeutronInputNumberController> moneyController = [];

  PriceController(
      List<DateTime>? staysDay, List<String>? staysDaByMonth, List<num> price) {
    if (staysDay != null && staysDaByMonth == null) {
      for (var i = 0; i < staysDay.length; i++) {
        moneyController.add(NeutronInputNumberController(
            TextEditingController(text: price[i].toString())));
      }
    }
    if (staysDaByMonth != null) {
      for (var i = 0;
          i < (staysDaByMonth.length + (staysDay?.length ?? 0));
          i++) {
        moneyController.add(NeutronInputNumberController(
            TextEditingController(text: price[i].toString())));
      }
    }
  }

  void disposeNeutronInput() {
    for (var element in moneyController) {
      element.controller.dispose();
    }
  }

  List<num> getPriceArr() {
    final List<num> result = [];

    for (var item in moneyController) {
      if (item.controller.text == '') {
        return [];
      } else {
        result.add(num.parse(item.controller.text.replaceAll(',', '')));
      }
    }

    return result;
  }

  void setPriceAllByMonth(int end, String price) {
    for (var i = 0; i < end; i++) {
      moneyController[i].controller.text = price;
    }
    notifyListeners();
  }

  void setPriceAll(int start, int end, String price) {
    for (var i = start; i < end; i++) {
      moneyController[i].controller.text = price;
    }
    notifyListeners();
  }

  void setPriceMediumAllByDay(
      int start, int end, String price, DateTime startDate, DateTime endDate) {
    DateTime outDate = endDate;
    if (startDate.year != endDate.year) {
      outDate = startDate.month != endDate.month
          ? DateTime(endDate.year, endDate.month, startDate.day, 12)
          : DateTime(endDate.year, startDate.month + 1, startDate.day, 12);
    } else {
      outDate = startDate.month != endDate.month
          ? DateTime(startDate.year, endDate.month, startDate.day, 12)
          : DateTime(startDate.year, startDate.month + 1, startDate.day, 12);
    }
    print(outDate.difference(startDate).inDays);
    num priceMedium = (num.parse(price.isEmpty ? "0" : price) /
            outDate.difference(startDate).inDays)
        .round();
    for (var i = start; i < end; i++) {
      moneyController[i].controller.text = priceMedium.toString();
    }
    notifyListeners();
  }
}
