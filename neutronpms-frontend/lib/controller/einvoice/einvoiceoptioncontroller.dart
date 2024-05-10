import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/einvoiceutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class ElectronicInvoiceOptionController extends ChangeNotifier {
  bool isConnect = false;
  String software = UITitleCode.NO;
  String generateOption = ElectronicInvoiceGenerateOption.bySelection;
  String serviceOption = ElectronicInvoiceServiceOption.bySelection;
  TextEditingController usernameTeController = TextEditingController(text: ''),
      passwordTeController = TextEditingController(text: '');
  bool isLoading = false;
  ElectronicInvoiceOptionController() {
    isConnect = GeneralManager.hotel!.isConnectToEInvoiceSoftware();
    if (isConnect) {
      software = GeneralManager.hotel!.eInvoiceOptions!['software']['name'];
      generateOption =
          GeneralManager.hotel!.eInvoiceOptions!['generate_option'];
      serviceOption = GeneralManager.hotel!.eInvoiceOptions!['service_option'];
      if (software == ElectronicInvoiceSoftWare.easyInvoice) {
        Map<String, dynamic> eInvoiceSoftwareData =
            GeneralManager.hotel!.eInvoiceOptions!['software'];
        usernameTeController.text = eInvoiceSoftwareData['username'];
        passwordTeController.text = eInvoiceSoftwareData['password'];
      }
    }
  }

  void setConnect(bool value) {
    isConnect = value;
    notifyListeners();
  }

  setSoftware(String value) {
    if (value == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
      software = UITitleCode.NO;
    } else {
      software = value;
    }
    notifyListeners();
  }

  setSoftGenerateOption(String value) {
    generateOption = ElectronicInvoiceGenerateOption.options().firstWhere(
      (element) => UITitleUtil.getTitleByCode(element) == value,
      orElse: () => '',
    );
    notifyListeners();
  }

  setServiceOption(String value) {
    if (value == UITitleUtil.getTitleByCode(UITitleCode.NO)) {
      serviceOption = UITitleCode.NO;
    } else {
      serviceOption = ElectronicInvoiceServiceOption.options().firstWhere(
        (element) => UITitleUtil.getTitleByCode(element) == value,
        orElse: () => '',
      );
    }
    notifyListeners();
  }

  Future<String> save() async {
    final Map<String, dynamic> dataToUpdate = {
      'hotel_id': GeneralManager.hotelID
    };
    if (isConnect) {
      if (software == UITitleCode.NO) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.SOFTWARE_CAN_NOT_BE_EMPTY);
      }
      if (usernameTeController.text.trim() == '') {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.USERNAME_CAN_NOT_BE_EMPTY);
      }
      if (passwordTeController.text.trim() == '') {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.PASSWORD_CAN_NOT_BE_EMPTY);
      }

      dataToUpdate['software'] = {
        'name': software,
        'username': usernameTeController.text.trim(),
        'password': passwordTeController.text.trim()
      };
      dataToUpdate['generate_option'] = generateOption;
      dataToUpdate['service_option'] = serviceOption;
    }
    try {
      isLoading = true;
      notifyListeners();
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('einvoice-updateEInvoiceData');
      final result = await callable(dataToUpdate);
      if (result.data == MessageCodeUtil.SUCCESS) {
        if (isConnect) {
          GeneralManager.hotel!.eInvoiceOptions = {
            'software': dataToUpdate['software'],
            'generate_option': dataToUpdate['generate_option'],
            'service_option': dataToUpdate['service_option']
          };
        } else {
          GeneralManager.hotel!.eInvoiceOptions = {};
        }
        isLoading = false;
        notifyListeners();
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (error) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(error.message);
    }
    isLoading = false;
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }
}
