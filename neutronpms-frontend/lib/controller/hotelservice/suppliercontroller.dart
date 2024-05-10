import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/util/messageulti.dart';

class SupplierController extends ChangeNotifier {
  bool isInProgress = false;
  late bool isAddFeature;

  late TextEditingController teIdController;
  late TextEditingController teNameController;
  Map<String, bool> services = {};

  late GlobalKey<FormState> formKey;

  SupplierController({dynamic supplier}) {
    formKey = GlobalKey<FormState>();
    if (supplier == null) {
      isAddFeature = true;
      teIdController = TextEditingController(text: '');
      teNameController = TextEditingController(text: '');
    } else {
      isAddFeature = false;
      teIdController = TextEditingController(text: supplier['id']);
      teNameController = TextEditingController(text: supplier['name']);
    }
    for (var element in OtherManager().dataOthers) {
      // if (element.isActive) {
      if (supplier != null) {
        if ((supplier['services'] as List).contains(element.id)) {
          services[element.id!] = true;
        } else {
          services[element.id!] = false;
        }
      } else {
        services[element.id!] = false;
      }
    }
  }

  Future<String> updateSupplier() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    List<String> checkedServices =
        services.keys.where((element) => services[element]!).toList();
    if (checkedServices.isEmpty) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NEED_TO_CHOOSE_ATLEAST_ONE_SERVICE);
    }
    isInProgress = true;
    notifyListeners();
    dynamic newSupplier = {
      'id': teIdController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
      'name': teNameController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
      'services': checkedServices
    };
    String result =
        await ConfigurationManagement.updateSupplier(newSupplier, isAddFeature)
            .then((value) => value);
    isInProgress = false;
    notifyListeners();
    return result;
  }

  void updateServices(String serviceItem, bool checked) {
    services[serviceItem] = checked;
    notifyListeners();
  }
}
