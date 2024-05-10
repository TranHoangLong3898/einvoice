import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/bikerentalmanager.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/laundrymanager.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/manager/rateplanmanager.dart';
import 'package:ihotel/manager/roomextramanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/hotelservice/bikehotelservice.dart';
import 'package:ihotel/modal/hotelservice/hotelservice.dart';
import 'package:ihotel/modal/hotelservice/laundryhotelservice.dart';
import 'package:ihotel/modal/hotelservice/otherhotelservice.dart';
import 'package:ihotel/modal/hotelservice/roomextrahotelservice.dart';
import 'package:ihotel/modal/room.dart';
import 'package:ihotel/modal/tax.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/messageulti.dart';

class ConfigurationManagement extends ChangeNotifier {
  static final ConfigurationManagement _instance =
      ConfigurationManagement._singleton();
  ConfigurationManagement._singleton();
  factory ConfigurationManagement() {
    return _instance;
  }

  String? statusServiceFilter;

  bool isFirstLoadingDone = false;
  bool isInProgress = false;

  StreamSubscription? configurationSubscription;

  List<LaundryHotelService> laundries = [];
  List<BikeHotelService> bikes = [];
  Map<String, dynamic> bikeConfigs = {};
  List<OtherHotelService> others = [];
  RoomExtraHotelService? roomExtra;
  List<dynamic> suppliers = [];
  Map<String, NeutronInputNumberController> electricityWater = {};

  Tax tax = Tax.empty();

  //avoid 2 stream are executed at the same time
  bool isConfigurationStreamed = false;
  bool isItemStreamed = false;

  int compareRoom(Room roomOne, Room roomTwo) {
    return roomOne.roomType!.compareTo(roomTwo.roomType!);
  }

  Future<void> asyncData() async {
    if (isConfigurationStreamed) {
      return;
    }
    isConfigurationStreamed = true;

    print('asyncConfigurationsFromCloud: Init');
    configurationSubscription?.cancel();
    configurationSubscription = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colManagement)
        .doc(FirebaseHandler.colConfigurations)
        .snapshots()
        .listen((snapshots) {
      laundries.clear();
      bikes.clear();
      others.clear();
      suppliers.clear();
      electricityWater.clear();
      if (snapshots.exists) {
        Map<String, dynamic> snapshotData = snapshots.get('data');
        RoomTypeManager().update(snapshotData['room_types']);
        RoomManager().update(snapshotData['rooms']);
        RatePlanManager().update(snapshotData['rate_plan']);
        ServiceManager().update(snapshotData['service_statuses']);
        SourceManager().update(snapshotData['sources']);
        AccountingTypeManager.update(snapshotData['accounting_type'] ?? {});

        if (snapshotData['laundries'] != null) {
          (snapshotData['laundries'] as Map).forEach((key, value) {
            HotelService hotelService;
            hotelService = LaundryHotelService.fromMap(value);
            hotelService.type = 'laundries';
            hotelService.id = key;
            laundries.add(hotelService as LaundryHotelService);
          });
        }
        if (snapshotData['bikes'] != null) {
          (snapshotData['bikes'] as Map).forEach((key, value) {
            HotelService hotelService;
            hotelService = BikeHotelService.fromMap(value);
            hotelService.type = 'bikes';
            hotelService.id = key;
            bikes.add(hotelService as BikeHotelService);
          });
        }
        if (snapshotData['bike_rental'] != null) {
          bikeConfigs = snapshotData['bike_rental'];
        }
        if (snapshotData['other_services'] != null) {
          (snapshotData['other_services'] as Map).forEach((key, value) {
            HotelService hotelService;
            hotelService = OtherHotelService.fromMap(value);
            hotelService.type = 'other_services';
            hotelService.id = key;
            others.add(hotelService as OtherHotelService);
          });
        }
        if (snapshotData['room_extra'] != null) {
          roomExtra = RoomExtraHotelService.fromMap(snapshotData['room_extra']);
        } else {
          roomExtra = RoomExtraHotelService.empty();
        }
        if (snapshotData['suppliers'] != null) {
          (snapshotData['suppliers'] as Map).forEach((key, value) {
            final dataSupplier = value;
            dataSupplier['id'] = key;
            suppliers.add(dataSupplier);
          });
        }
        if (snapshotData['tax'] != null) {
          tax.getFromJsonDocument(snapshotData['tax']);
        }

        laundries.sort((a, b) => a.id!.compareTo(b.id!));
        bikes.sort((a, b) => a.id!.compareTo(b.id!));
        others.sort((a, b) => a.id!.compareTo(b.id!));
        BikeRentalManager().update();
        LaundryManager().update();
        OtherManager().update();
        RoomExtraManager().update();
        SupplierManager().update();
        isFirstLoadingDone = true;
        electricityWater["water"] = NeutronInputNumberController(
            TextEditingController(
                text: snapshotData['electricity_water']?["water"]?.toString() ??
                    "0"));
        electricityWater["electricity"] = NeutronInputNumberController(
            TextEditingController(
                text: snapshotData['electricity_water']?["electricity"]
                        ?.toString() ??
                    "0"));
        notifyListeners();
      }
    });
  }

  void cancelStream() {
    configurationSubscription?.cancel();
    isConfigurationStreamed = false;
    laundries.clear();
    bikes.clear();
    bikeConfigs.clear();
    others.clear();
    roomExtra = null;
    suppliers.clear();
    electricityWater.clear();
    tax = Tax.empty();
    isFirstLoadingDone = false;
    print('asyncConfigurationAndItem: Cancelled');
  }

  void setStatusFilter(String value) {
    statusServiceFilter = value;
    notifyListeners();
  }

  Future<String> toggleHotelServiceActivation(HotelService service) async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isInProgress = true;
    notifyListeners();
    try {
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-toggleHotelServiceActivation')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'service_id': service.id,
        'service_type': service.type,
        'service_is_active': !service.isActive!
      }).then((value) => value.data);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      print(e);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> createLaundryHotelService(
      LaundryHotelService laundry) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'laundries',
        'service_id': laundry.id,
        'service_name': laundry.name,
        'service_plaundry': laundry.plaundry,
        'service_piron': laundry.piron
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-createHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> createBikeHotelService(BikeHotelService bike) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'bikes',
        'service_id': bike.id,
        'service_price': bike.price,
        'service_bike_type': bike.bikeType,
        'bike_supplier_id': bike.supplierId
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-createHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> createOtherHotelService(
      OtherHotelService service) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'other_services',
        'service_id': service.id,
        'service_name': service.name,
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-createHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  Future<String> createElectricityWaterHotelService() async {
    try {
      isInProgress = true;
      notifyListeners();
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'electricitywater_services',
        'service_water': int.parse(electricityWater["water"]!.getRawString()),
        'service_electricity':
            int.parse(electricityWater["electricity"]!.getRawString()),
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateHotelService')
          .call(dataService)
          .then((value) => value.data);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> updateLaundryHotelService(
      LaundryHotelService service) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'laundries',
        'service_id': service.id,
        'service_name': service.name,
        'service_plaundry': service.plaundry,
        'service_piron': service.piron
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> updateBikeHotelService(BikeHotelService service) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'bikes',
        'service_id': service.id,
        'service_price': service.price,
        'service_bike_type': service.bikeType,
        'bike_supplier_id': service.supplierId
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> updateOtherHotelService(
      OtherHotelService service) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'other_services',
        'service_id': service.id,
        'service_name': service.name,
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  Future<String> updateRoomExtraHotelService(
      {num? adultPrice,
      num? childPrice,
      Map<String, num>? earlyCheckIn,
      Map<String, num>? lateCheckOut}) async {
    if (adultPrice == null &&
        childPrice == null &&
        earlyCheckIn == null &&
        lateCheckOut == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.FAILED);
    }
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'service_type': 'room_extra',
        if (adultPrice != null) 'service_adult': adultPrice,
        if (childPrice != null) 'service_child': childPrice,
        if (earlyCheckIn != null) 'service_early_check_in': earlyCheckIn,
        if (lateCheckOut != null) 'service_late_check_out': lateCheckOut,
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('service-updateHotelService')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  Future<String> toggleSupplierActivation(dynamic supplier) async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isInProgress = true;
    notifyListeners();
    try {
      String result = await FirebaseFunctions.instance
          .httpsCallable('supplier-toggleSupplierActivation')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'supplier_id': supplier['id'],
        'supplier_active': !(supplier['active'] as bool)
      }).then((value) => value.data);
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      print(e.toString());
      isInProgress = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  static Future<String> updateSupplier(
      dynamic supplier, bool isAddFeature) async {
    try {
      dynamic dataService = {
        'hotel_id': GeneralManager.hotelID,
        'supplier_services': supplier['services'],
        'supplier_id': supplier['id'],
        'supplier_name': supplier['name'],
        'is_add_feature': isAddFeature
      };
      String result = await FirebaseFunctions.instance
          .httpsCallable('supplier-updateSupplier')
          .call(dataService)
          .then((value) => value.data);
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    }
  }

  Future<String> deleteAccountingType(String id) async {
    isInProgress = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-toggleAccountingTypeActivation')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'id': id,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isInProgress = false;
          notifyListeners();
        });
  }
}
