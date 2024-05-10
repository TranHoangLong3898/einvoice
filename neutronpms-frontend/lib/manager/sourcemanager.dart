import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class SourceManager extends ChangeNotifier {
  static final SourceManager _instance = SourceManager._singleton();
  SourceManager._singleton();

  factory SourceManager() {
    return _instance;
  }

  static String noneSourceId = 'none';
  static String noneSourceName = '';
  static String virtualSource = 'virtual';
  static String directSource = 'di';

  List<dynamic> dataSources = [];
  String statusServiceFilter =
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  bool isInprogress = false;

  Future<void> update(Map<String, dynamic>? data) async {
    if (data == null) {
      return;
    }
    dataSources.clear();
    data.forEach((key, value) {
      final dataSource = value;
      dataSource['id'] = key;
      dataSources.add(dataSource);
    });
    dataSources.add({
      'id': noneSourceId,
      'name': noneSourceName,
      'active': true,
      'ota': false,
      'mapping_source': ''
    });
    dataSources
        .sort((a, b) => a['id'].toString().compareTo(b['id'].toString()));
    notifyListeners();
  }

  Future<String> addSourceToCloud(
      {String? id,
      String? name,
      String? mappingSource,
      bool? isOta,
      bool? isActive}) async {
    return await FirebaseFunctions.instance
        .httpsCallable('source-addSource')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'source_id': id,
          'source_name': name,
          'source_mapping_source': mappingSource,
          'source_ota': isOta,
          'source_active': isActive
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> updateSourceToCloud(
      {String? newId,
      String? newName,
      String? newMappingSource,
      bool? isOta,
      bool? isActive}) async {
    return await FirebaseFunctions.instance
        .httpsCallable('source-updateSource')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'source_id': newId,
          'source_name': newName,
          'source_mapping_source': newMappingSource,
          'source_ota': isOta,
          'source_active': isActive
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> toggleActiveSourceFromCloud(String? id) async {
    if (id == null || id.isEmpty) return MessageCodeUtil.INPUT_ID;
    if (isInprogress) return MessageCodeUtil.IN_PROGRESS;
    isInprogress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('source-toggleActiveSource')
        .call({
          'source_id': id,
          'hotel_id': GeneralManager.hotelID,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isInprogress = false;
    notifyListeners();
    return result;
  }

  void setStatusFilter(String value) {
    statusServiceFilter = value;
    notifyListeners();
  }

  List<String> getSourceNames() =>
      dataSources.map((e) => e['name'].toString()).toList();

  List<String> getActiveSourceNames() => dataSources
      .where((e) => e['active'] ?? true)
      .map((e) => e['name'].toString())
      .toList();

  String getIdOfFirstActiveSource() {
    try {
      dynamic source = dataSources.firstWhere((element) => element['active'],
          orElse: () => null);
      return source['id'] ?? noneSourceId;
    } catch (e) {
      return noneSourceId;
    }
  }

  String getSourceIDByName(String name) {
    try {
      return dataSources
          .firstWhere((source) => source['name'] == name)['id']
          .toString();
    } catch (e) {
      return noneSourceId;
    }
  }

  String getSourceNameByID(String id) {
    try {
      return dataSources
          .firstWhere((source) => source['id'] == id)['name']
          .toString();
    } catch (e) {
      return noneSourceName;
    }
  }

  bool isSourceOTA(String sourceID) {
    try {
      return dataSources
          .firstWhere((source) => source['id'] == sourceID)['ota'];
    } catch (e) {
      return false;
    }
  }

  List<dynamic> getSourceIDs() {
    return dataSources.map((element) => element['id']).toList();
  }
}
