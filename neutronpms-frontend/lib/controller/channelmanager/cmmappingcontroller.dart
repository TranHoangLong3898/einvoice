import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/util/cmsutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/channelmanager.dart';
import '../../manager/generalmanager.dart';
import '../../modal/cmrateplan.dart';
import '../../util/dateutil.dart';

class CMMappingController extends ChangeNotifier {
  TextEditingController mappingHotelIDController = TextEditingController();
  TextEditingController mappingHotelKeyController = TextEditingController();
  TextEditingController propertyIdController = TextEditingController();
  Map<String, dynamic> mapCMPMSRoomTypes = {};
  Map<String, List<String>> ratePlanOfRoomType = {};
  DateTime startSync = Timestamp.now().toDate();
  DateTime endSync = Timestamp.now().toDate();
  String? syncAvaibilityErrorFromAPI;
  bool processing = false;
  String selectedRatePlan = 'Choose';
  String? cmsType;

  CMMappingController() {
    initialize();
  }

  void initialize() async {
    processing = true;
    notifyListeners();
    // final mappingInfo = await ChannelManager().getMappingHotelInfoFromCloud();
    mappingHotelIDController.text = GeneralManager.hotel!.hotelLinkMap!['id']!;
    mappingHotelKeyController.text =
        GeneralManager.hotel!.hotelLinkMap!['key']!;
    propertyIdController.text = GeneralManager.hotel!.propertyid!;
    cmsType = GeneralManager.hotel!.cms;
    mapCMPMSRoomTypes = ChannelManager().getPMSCMSRoomTypes();
    // get rate plan of each room type
    for (var item in mapCMPMSRoomTypes.entries) {
      if (item.value['roomTypeID'] == '') {
        ratePlanOfRoomType[item.key] = [''];
      } else {
        if (ChannelManager().ratePlanOfCmRoomType[item.key] == null ||
            ChannelManager().ratePlanOfCmRoomType[item.key]!.isEmpty) {
          List<CMRatePlan> ratePlans =
              await ChannelManager().getRatePlansFromCloud(item.key);
          ratePlanOfRoomType[item.key] = [
            '',
            ...ratePlans.map((e) => e.name!).toList()
          ];
        } else {
          ratePlanOfRoomType[item.key] = [
            '',
            ...ChannelManager()
                .ratePlanOfCmRoomType[item.key]!
                .map((e) => e.name!)
                .toList()
          ];
        }
      }
    }

    processing = false;
    notifyListeners();
  }

  Future<bool?> saveMappingHotelID() async {
    Map<String, String> data;
    if (cmsType == CmsType.hotelLink) {
      data = {
        'hotel_id': GeneralManager.hotelID!,
        'mapping_hotel_id': mappingHotelIDController.text,
        'mapping_hotel_key': mappingHotelKeyController.text,
        'cms_type': CmsType.hotelLink
      };
      if (mappingHotelIDController.text.isEmpty ||
          mappingHotelKeyController.text.isEmpty) {
        return false;
      }
    } else {
      data = {
        'property_id': propertyIdController.text,
        'cms_type': CmsType.oneCms,
        'hotel_id': GeneralManager.hotelID!,
      };
      if (propertyIdController.text.isEmpty) {
        return false;
      }
    }
    if (processing) return null;
    processing = true;
    notifyListeners();
    final result = await ChannelManager().saveMappingHotelInfoToCloud(data);
    GeneralManager.hotel!.isConnectChannel = true;
    processing = false;
    notifyListeners();
    return result;
  }

  Future<bool?> syncAvaibility() async {
    try {
      if (endSync.compareTo(startSync) < 0) return false;
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-syncavaibility');
      processing = true;
      notifyListeners();
      final data = (await callable({
        "hotel": GeneralManager.hotelID,
        "from": DateUtil.dateToShortString(startSync),
        "to": DateUtil.dateToShortString(endSync)
      }))
          .data;
      syncAvaibilityErrorFromAPI = MessageUtil.getMessageByCode(data['error']);
      processing = false;
      notifyListeners();
      return data['result'];
    } catch (e) {
      (e as FirebaseFunctionsException).message;
    }
    processing = false;
    notifyListeners();
    return true;
  }

  void setStartSync(DateTime date) {
    startSync = DateUtil.to12h(date);
    if (startSync.compareTo(endSync) > 0) {
      endSync = startSync;
    }
    notifyListeners();
  }

  void setEndSync(DateTime date) {
    endSync = DateUtil.to12h(date);
    notifyListeners();
  }

  Future<String?> syncRoomTypes() async {
    HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('channelmanager-syncchannelmanager');
    if (processing) return null;
    processing = true;
    notifyListeners();
    final data = (await callable({'hotel': GeneralManager.hotelID})).data;
    if (data == MessageCodeUtil.SUCCESS) {
      await ChannelManager().update();
      mapCMPMSRoomTypes = ChannelManager().getPMSCMSRoomTypes();
      for (var item in mapCMPMSRoomTypes.entries) {
        if (item.value['roomTypeID'] == '') {
          ratePlanOfRoomType[item.key] = [''];
        } else {
          if (ChannelManager().ratePlanOfCmRoomType[item.key] == null ||
              ChannelManager().ratePlanOfCmRoomType[item.key]!.isEmpty) {
            List<CMRatePlan> ratePlans =
                await ChannelManager().getRatePlansFromCloud(item.key);
            ratePlanOfRoomType[item.key] = [
              '',
              ...ratePlans.map((e) => e.name!).toList()
            ];
          } else {
            ratePlanOfRoomType[item.key] = [
              '',
              ...ChannelManager()
                  .ratePlanOfCmRoomType[item.key]!
                  .map((e) => e.name!)
                  .toList()
            ];
          }
        }
      }
      processing = false;
      notifyListeners();
      return MessageCodeUtil.SUCCESS;
    } else {
      processing = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(data);
    }
  }

  Future<bool?> clearAllCMRoomTypes() async {
    if (processing) return null;
    processing = true;
    notifyListeners();
    if (await ChannelManager().clearAllCMRoomTypesOnCloud()) {
      mapCMPMSRoomTypes = {};
      processing = false;
      notifyListeners();
      return true;
    } else {
      processing = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> saveMappingRoomTypeNew(
      String pmsRoomTypeName, String cmRoomTypeId) async {
    final String pmsRoomTypeId =
        RoomTypeManager().getRoomTypeIDByName(pmsRoomTypeName);
    if (mapCMPMSRoomTypes.values
        .where((element) => element['roomTypeID'] == pmsRoomTypeId)
        .isNotEmpty) {
      return MessageCodeUtil.ROOM_ID_DUPLICATED;
    }
    processing = true;
    notifyListeners();
    try {
      final success = await ChannelManager()
          .saveMappingRoomTypeToCloud(cmRoomTypeId, pmsRoomTypeId);
      if (success) {
        mapCMPMSRoomTypes[cmRoomTypeId]['roomTypeID'] = pmsRoomTypeId;

        await ChannelManager().update();
        // this.ratePlans.clear();
        List<CMRatePlan> ratePlans =
            await ChannelManager().getRatePlansFromCloud(cmRoomTypeId);
        ratePlanOfRoomType[cmRoomTypeId] = [
          '',
          ...ratePlans.map((e) => e.name!).toList()
        ];
      }
      processing = false;
      notifyListeners();
      return '';
    } on FirebaseFunctionsException catch (error) {
      print(error.message);
      processing = false;
      notifyListeners();
      return error.code;
    }
  }

  Future<String?> saveMappingRatePlan(
      String cmRatePlanName, String cmRoomTypeId) async {
    print('saveMappingRatePlanToCloud');
    final String cmRatePlanID = ChannelManager()
        .ratePlanOfCmRoomType[cmRoomTypeId]!
        .firstWhere((element) => element.name == cmRatePlanName)
        .id!;
    processing = true;
    notifyListeners();
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-saveMappingRatePlanToCloud');
      final result = await callable({
        'hotel_id': GeneralManager.hotelID,
        'rate_plan_id': cmRatePlanID,
        'cm_room_type_id': cmRoomTypeId
      });
      if (result.data) {
        mapCMPMSRoomTypes[cmRoomTypeId]['ratePlanID'] = cmRatePlanID;
        await ChannelManager().update();
        processing = false;
        notifyListeners();
        return '';
      }
    } on FirebaseFunctionsException catch (error) {
      processing = false;
      notifyListeners();
      return error.message;
    }
    return '';
  }

  void setCmsType(String type) {
    cmsType = type;
    notifyListeners();
  }

  // Future<bool> saveMappingRatePlan(String value, String cmRoomType) async {
  //   // final String pmsRoomTypeId = RoomTypeManager().getRoomTypeIDByName(value);

  //   // if (this.mapCMPMSRoomTypes.containsValue(pmsRoomTypeId)) return false;

  //   // ratePlans = await ChannelManager().getRatePlansFromCloud(
  //   //       ChannelManager().getCMRoomTypeIDByName(selectedRoomType));
  //   //   selectedRatePlan = ratePlans.length > 0 ? ratePlans[0].name : "";

  //   this.processing = true;
  //   notifyListeners();
  //   try {
  //     final cmRoomTypeID = ChannelManager().getCMRoomTypeIDByName(cmRoomType);
  //     if (cmRoomTypeID.isEmpty) return false;
  //     final success = await ChannelManager()
  //         .saveMappingRoomTypeToCloud(cmRoomTypeID, pmsRoomTypeId);
  //     if (success) {
  //       mapCMPMSRoomTypes[cmRoomType] = pmsRoomTypeId;
  //       await ChannelManager().update();
  //       this.ratePlans.clear();
  //       this.ratePlans = await ChannelManager().getRatePlansFromCloud(
  //           ChannelManager().getCMRoomTypeIDByName(pmsRoomTypeId));
  //     }
  //     this.processing = false;
  //     notifyListeners();
  //     return success;
  //   } on FirebaseFunctionsException catch (error) {
  //     print(error.message);
  //     this.processing = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }
  // Future<bool> saveMappingRoomType(
  //     String cmRoomType, String pmsRoomType) async {
  //   final cmRoomTypeID = ChannelManager().getCMRoomTypeIDByName(cmRoomType);
  //   if (cmRoomTypeID.isEmpty) {
  //     return false;
  //   }

  //   if (processing) return null;
  //   processing = true;
  //   final success = await ChannelManager()
  //       .saveMappingRoomTypeToCloud(cmRoomTypeID, pmsRoomType);
  //   if (success) {
  //     mapCMPMSRoomTypes[cmRoomType] = pmsRoomType;
  //     await ChannelManager().update();
  //     notifyListeners();
  //   }
  //   processing = false;
  //   return success;
  // }
}
