import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import '../handler/firebasehandler.dart';
import '../modal/cmrateplan.dart';
import 'generalmanager.dart';

class ChannelManager extends ChangeNotifier {
  List<Map<String, dynamic>> cmRoomTypes = [];

  Map<String, List<CMRatePlan>> ratePlanOfCmRoomType = {};

  static final ChannelManager _instance = ChannelManager._internal();

  factory ChannelManager() {
    return _instance;
  }
  ChannelManager._internal();

  Future<void> update() async {
    cmRoomTypes = await getCMRoomTypesFromCloud();
  }

  List<String> getMappedRoomTypeNames() => cmRoomTypes
      .where((cmRoomType) => cmRoomType['mapping_room_type'].isNotEmpty)
      .map((cmRoomTypes) => RoomTypeManager()
          .getRoomTypeNameByID(cmRoomTypes['mapping_room_type']))
      .toList();

  String? getRatePlaneNameById(String idRatePlan, String cmRoomTypeId) {
    return ratePlanOfCmRoomType[cmRoomTypeId]
        ?.firstWhere((element) => element.id == idRatePlan)
        .name;
  }

  String getCMRoomTypeNameByID(String id) {
    try {
      return cmRoomTypes
          .firstWhere((cmRoomType) => cmRoomType['id'] == id)['name']
          .toString();
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> getPMSCMSRoomTypes() {
    Map<String, dynamic> map = {};
    for (var roomType in cmRoomTypes) {
      map[roomType['id']] = {};
      map[roomType['id']]['roomTypeID'] = roomType['mapping_room_type'];
      map[roomType['id']]['ratePlanID'] = roomType['mapping_rate_plan'];
    }
    return map;
  }

  String getCMRoomTypeIDByPMSRoomTypeID(String roomTypeID) {
    try {
      return cmRoomTypes
          .firstWhere((cmRoomType) =>
              cmRoomType['mapping_room_type'] == roomTypeID)['id']
          .toString();
    } on Exception catch (e) {
      print(e.toString());
      return '';
    }
  }

  String? getPMSRoomTypeIDByCMRoomTypeName(String cmRoomTypeID) {
    try {
      return cmRoomTypes
          .firstWhere((cmRoomType) => cmRoomType['name'] == cmRoomTypeID)[
              'mapping_room_type']
          .toString();
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<CMRatePlan>> getCmRatePlanFromCloudByCmRoomTypeId(
      String cmRoomTypeId) async {
    final snapshots = await FirebaseHandler.hotelRef
        .collection('cm_room_types')
        .doc(cmRoomTypeId)
        .collection('cm_rate_plans')
        .get();
    if (snapshots.docs.isEmpty) {
      return [];
    }
    List<CMRatePlan> ratePlans = [];
    for (var doc in snapshots.docs) {
      ratePlans.add(CMRatePlan(id: doc.id, name: doc.get('name')));
    }
    ratePlanOfCmRoomType[cmRoomTypeId] = ratePlans;
    return ratePlans = [];
  }

  Future<Map<String, String>> getMappingHotelInfoFromCloud() async {
    final snapshot = await FirebaseHandler.hotelRef.get();
    try {
      return {
        'id': (snapshot.data() as Map<String, dynamic>)
                .containsKey('mapping_hotel_id')
            ? snapshot.get('mapping_hotel_id')
            : '',
        'key': (snapshot.data() as Map<String, dynamic>)
                .containsKey('mapping_hotel_key')
            ? snapshot.get('mapping_hotel_key')
            : ''
      };
    } catch (e) {
      print(e.toString());
      return {'id': '', 'key': ''};
    }
  }

  Future<bool> saveMappingHotelInfoToCloud(Map<String, String> info) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-saveMappingHotelID');
      await callable(info);
      GeneralManager.hotel!.isConnectChannel = true;
      notifyListeners();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCMRoomTypesFromCloud() async {
    try {
      final snapshots =
          await FirebaseHandler.hotelRef.collection('cm_room_types').get();
      List<Map<String, dynamic>> cmRoomTypes = [];
      for (var doc in snapshots.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (!data.containsKey('mapping_room_type')) {
          data['mapping_room_type'] = '';
        }
        if (!data.containsKey('mapping_rate_plan')) {
          data['mapping_rate_plan'] = '';
        }
        cmRoomTypes.add(data);
      }
      return cmRoomTypes;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<bool> saveMappingRoomTypeToCloud(
      String cmRoomType, String pmsRoomType) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-saveMappingRoomTypeToCloud');
      final result = await callable({
        'cm_room_type_id': cmRoomType,
        'hotel_id': GeneralManager.hotelID,
        'mapping_room_type': pmsRoomType
      });

      return result.data;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<List<CMRatePlan>> getRatePlansFromCloud(String roomType) async {
    final snapshots = await FirebaseHandler.hotelRef
        .collection('cm_room_types')
        .doc(roomType)
        .collection('cm_rate_plans')
        .get();
    List<CMRatePlan> ratePlans = [];
    for (var doc in snapshots.docs) {
      ratePlans.add(CMRatePlan(id: doc.id, name: doc.get('name')));
    }
    ratePlanOfCmRoomType[roomType] = ratePlans;
    return ratePlans;
  }

  Future<bool> clearAllCMRoomTypesOnCloud() async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-clearAllCmRoomType');
      await callable({'hotel_id': GeneralManager.hotelID});
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
