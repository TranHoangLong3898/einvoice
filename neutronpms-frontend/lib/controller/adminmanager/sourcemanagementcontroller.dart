import 'package:flutter/material.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/util/messageulti.dart';

class SourceManagementController extends ChangeNotifier {
  bool isInProgress = false;
  bool isAddFeature = false;

  late bool isOta;
  late bool isActive;
  TextEditingController? teIdController;
  TextEditingController? teNameController;
  late TextEditingController teMappingSourceController;

  final dynamic source;
  late String oldId;
  late String oldName;
  late String oldMappingSource;
  late bool oldOTA;
  late bool oldActive;

  SourceManagementController(this.source) {
    if (source == null) {
      isAddFeature = true;
      oldId = '';
      oldName = '';
      oldMappingSource = '';
      oldOTA = false;
      oldActive = true;
    } else {
      isAddFeature = false;
      oldId = source['id'] ?? '';
      oldName = source['name'] ?? '';
      oldMappingSource = source['mapping_source'] ?? '';
      oldOTA = source['ota'] ?? false;
      oldActive = source['active'] ?? true;
    }
    teIdController = TextEditingController(text: oldId);
    teNameController = TextEditingController(text: oldName);
    teMappingSourceController = TextEditingController(text: oldMappingSource);
    isOta = oldOTA;
    isActive = oldActive;
  }

  void setOTA(bool value) {
    if (isOta == value) return;
    isOta = value;
    notifyListeners();
  }

  void setActive(bool value) {
    if (isActive == value) return;
    isActive = value;
    notifyListeners();
  }

  bool isValueChanged() {
    String newId = teIdController!.text;
    String newName = teNameController!.text;
    String newMappingSource = teMappingSourceController.text;
    return !(newId == oldId &&
        newName == oldName &&
        newMappingSource == oldMappingSource &&
        isOta == oldOTA &&
        isActive == oldActive);
  }

  Future<String> updateSource() async {
    String? newId = teIdController?.text;
    String? newName =
        teNameController?.text.replaceAll(RegExp(r"\s\s+"), ' ').trim();
    String newMappingSource =
        teMappingSourceController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim();
    if (newId == null || newId.isEmpty) return MessageCodeUtil.INPUT_ID;
    if (newName == null || newName.isEmpty) return MessageCodeUtil.INPUT_NAME;
    if (isAddFeature) {
      isInProgress = true;
      notifyListeners();
      String result = await SourceManager()
          .addSourceToCloud(
              id: newId,
              name: newName,
              mappingSource: newMappingSource,
              isOta: isOta,
              isActive: isActive)
          .then((value) => value);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    } else {
      if (!isValueChanged()) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
      }
      isInProgress = true;
      notifyListeners();
      String result = await SourceManager()
          .updateSourceToCloud(
              newId: newId,
              newName: newName,
              newMappingSource: newMappingSource,
              isOta: isOta,
              isActive: isActive)
          .then((value) => value);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    }
  }
}
