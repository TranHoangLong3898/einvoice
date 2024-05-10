import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/generalmanager.dart';
import '../../modal/accounting/accounting.dart';

class AccountingTypeController extends ChangeNotifier {
  final AccountingType? accountingTypes;

  bool isLoading = false;
  late TextEditingController teIdController, teNameController;

  AccountingTypeController(this.accountingTypes) {
    teIdController = TextEditingController(text: accountingTypes?.id ?? '');
    teNameController = TextEditingController(text: accountingTypes?.name ?? '');
  }

  bool get isAdd => accountingTypes == null;

  Future<String> createAndUpdate() async {
    if (teIdController.text.isEmpty) {
      return MessageCodeUtil.INPUT_ID;
    }
    if (teIdController.text.length > 16) {
      return MessageCodeUtil.ID_OVER_MAXIMUM_CHARACTERS;
    }
    if (teNameController.text.isEmpty) {
      return MessageCodeUtil.INPUT_NAME;
    }

    if (accountingTypes == null) {
      return await createNewAccountingType();
    } else {
      if (teNameController.text == accountingTypes!.name) {
        isLoading = false;
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      return await updateAccountingType();
    }
  }

  Future<String> createNewAccountingType() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-createAccountingType')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'id': teIdController.text.replaceAll(RegExp(r'\s\s+'), '').trim(),
          'name':
              teNameController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim(),
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  Future<String> updateAccountingType() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-updateAccountingType')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'id': teIdController.text,
          'name':
              teNameController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim(),
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }
}
