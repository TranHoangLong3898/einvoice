import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';

class AddAndUpdatePackageController extends ChangeNotifier {
  DateTime? now, startDate, endDate;
  TextEditingController? teID, teDesc;
  NeutronInputNumberController? tePrice;
  bool isLoading = false;
  Map<String, dynamic>? dataPackage;
  int? packageVersion;
  AddAndUpdatePackageController(this.dataPackage, String? id) {
    now = DateTime.now();
    startDate = DateUtil.to0h(dataPackage?["start_date"].toDate() ?? now!);
    endDate = DateUtil.to24h(dataPackage?["end_date"].toDate() ?? now!);
    teID = TextEditingController(text: id ?? "");
    teDesc = TextEditingController(text: dataPackage?["desc"] ?? "");
    tePrice = NeutronInputNumberController(
        TextEditingController(text: dataPackage?["price"]?.toString() ?? ""));
    packageVersion = dataPackage?["package"] ?? 0;
  }

  void setStart(DateTime date) {
    startDate = DateUtil.to0h(date);
    if (startDate!.compareTo(endDate!) > 0) {
      endDate = startDate;
    }
    notifyListeners();
  }

  void setEnd(DateTime date) {
    endDate = DateUtil.to24h(date);
    notifyListeners();
  }

  void setPackageVersion(int package) {
    if (packageVersion == package) return;
    packageVersion = package;
    notifyListeners();
  }

  Future<String> updatePackageVersion() async {
    if (teID!.text.isEmpty) {
      return MessageCodeUtil.INPUT_ID;
    }

    if (teDesc!.text.isEmpty) {
      return MessageCodeUtil.INPUT_DESCRIPTION;
    }

    if (tePrice!.getRawString().isEmpty) {
      return MessageCodeUtil.INPUT_POSITIVE_NUMBER;
    }
    isLoading = true;
    notifyListeners();
    String result;
    if (dataPackage == null) {
      result = await FirebaseFunctions.instance
          .httpsCallable('hotelmanager-addPackageVersion')
          .call({
        "hotel_id": GeneralManager.hotelID,
        "id_package": teID!.text,
        "desc": teDesc!.text,
        "price": double.parse(tePrice!.getRawString()),
        "start_date": startDate.toString(),
        "end_date": endDate.toString(),
        'package': packageVersion,
      }).then((value) {
        return value.data;
      }).onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    } else {
      result = await FirebaseFunctions.instance
          .httpsCallable('hotelmanager-updatePackageVersion')
          .call({
        "hotel_id": GeneralManager.hotelID,
        "desc": teDesc!.text,
        "id_package": teID!.text,
        "price": double.parse(tePrice!.getRawString()),
        "start_date": startDate.toString(),
        "end_date": endDate.toString(),
        'package': packageVersion,
      }).then((value) {
        return value.data;
      }).onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    }
    isLoading = false;
    notifyListeners();
    return result;
  }
}
