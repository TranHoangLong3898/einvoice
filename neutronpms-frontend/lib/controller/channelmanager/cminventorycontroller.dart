import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/util/cmsutil.dart';
// import 'package:ihotel/util/cmsutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/channelmanager.dart';
import '../../manager/generalmanager.dart';
import '../../modal/cmrateplan.dart';
import '../../util/dateutil.dart';

class CMInventoryController extends ChangeNotifier {
  List<String> roomTypeNames = [];
  List<CMRatePlan> ratePlans = [];
  TextEditingController valueAvailabilityController = TextEditingController();
  TextEditingController valueRatesController = TextEditingController();
  TextEditingController valueExtraAdultController = TextEditingController();
  TextEditingController valueExtraChildController = TextEditingController();
  TextEditingController valueMinNightsController = TextEditingController();
  TextEditingController valueMaxNightsController = TextEditingController();
  TextEditingController valueMinStayArrivalController = TextEditingController();
  TextEditingController valueMinStayThroughController = TextEditingController();
  TextEditingController valueMaxAvailabilityController =
      TextEditingController();
  bool isCloseToArrival = false;
  bool isCloseToDeparture = false;
  bool isStopSell = false;

  final DateTime now = Timestamp.now().toDate();
  DateTime start = Timestamp.now().toDate();
  DateTime end = Timestamp.now().toDate();
  late String selectedRoomType;
  late String selectedRoomTypePeriod;
  late String selectedRatePlan;
  late String updateReleasePeriodErrorFromAPI;
  late List<num> chooseDayHTL = [1, 2, 3, 4, 5, 6, 0];
  late List<String> chooseDay = ["mo", "tu", "we", "th", "fr", "sa", "su"];
  bool isMonday = true;
  bool isTuesday = true;
  bool isWednesday = true;
  bool isFriday = true;
  bool isThursday = true;
  bool isSaturday = true;
  bool isSunday = true;
  List<Map<String, dynamic>> listOption = [];
  bool updating = false;
  String? updateInventoryErrorFromAPI;
  List<String> selectedType = [];
  final types = [
    'Availability',
    'Rate',
    if (GeneralManager.hotel!.isConnectChannel!) ...[
      if (GeneralManager.hotel!.cms == CmsType.hotelLink) ...[
        'ExtraAdultRate',
        'ExtraChildRate',
      ],
      'MinNights',
      'MaxNights',
      'CloseToArrival',
      'CloseToDeparture',
      if (GeneralManager.hotel!.cms == CmsType.oneCms) ...[
        'MinStayArrival',
        'MinStayThrough',
        'MaxAvailability',
      ],
      'StopSell',
      'Days'
    ]
  ];

  CMInventoryController() {
    initialize();
  }

  void initialize() async {
    updating = true;
    notifyListeners();
    roomTypeNames = ChannelManager().getMappedRoomTypeNames();
    selectedRoomType = roomTypeNames.isNotEmpty
        ? RoomTypeManager().getRoomTypeIDByName(roomTypeNames.first)
        : '';
    selectedRoomTypePeriod = roomTypeNames.isNotEmpty
        ? RoomTypeManager().getRoomTypeIDByName(roomTypeNames.first)
        : '';
    if (selectedRoomType.isNotEmpty) {
      ratePlans = await ChannelManager().getRatePlansFromCloud(
          ChannelManager().getCMRoomTypeIDByPMSRoomTypeID(selectedRoomType));
      selectedRatePlan = (ratePlans.isNotEmpty ? ratePlans.first.id : "")!;
    } else {
      selectedRatePlan = "";
    }
    updating = false;
    notifyListeners();
  }

  String getCmRatePlanNameByID(String ratePlanID) {
    return ratePlans
        .firstWhere((element) => element.id == ratePlanID)
        .name
        .toString();
  }

  String getCmRatePlanIDByName(String ratePlanName) {
    return ratePlans
        .firstWhere((element) => element.name == ratePlanName)
        .id
        .toString();
  }

  void changeSelectedRoomType(String selectedRoomTypeNameParam) async {
    if (selectedRoomTypeNameParam == '') return;
    if (RoomTypeManager().getRoomTypeIDByName(selectedRoomTypeNameParam) ==
        selectedRoomType) return;
    selectedRoomType =
        RoomTypeManager().getRoomTypeIDByName(selectedRoomTypeNameParam);
    ratePlans = await ChannelManager().getRatePlansFromCloud(
        ChannelManager().getCMRoomTypeIDByPMSRoomTypeID(selectedRoomType));
    selectedRatePlan = (ratePlans.isNotEmpty ? ratePlans.first.id : "")!;
    notifyListeners();
  }

  void changeSelectedRatePlan(String ratePlanNameParam) {
    if (selectedRatePlan == getCmRatePlanIDByName(ratePlanNameParam)) return;
    selectedRatePlan = getCmRatePlanIDByName(ratePlanNameParam);
    notifyListeners();
  }

  void setMonDay(value) {
    if (value != isMonday) {
      isMonday = value;
      isMonday ? chooseDay.add("mo") : chooseDay.remove("mo");
      isMonday ? chooseDayHTL.add(1) : chooseDayHTL.remove(1);
      notifyListeners();
    }
  }

  void setTuesday(value) {
    if (value != isTuesday) {
      isTuesday = value;
      isTuesday ? chooseDay.add("tu") : chooseDay.remove("tu");
      isTuesday ? chooseDayHTL.add(2) : chooseDayHTL.remove(2);
      notifyListeners();
    }
  }

  void setWednesday(value) {
    if (value != isWednesday) {
      isWednesday = value;
      isWednesday ? chooseDay.add("we") : chooseDay.remove("we");
      isWednesday ? chooseDayHTL.add(3) : chooseDayHTL.remove(3);
      notifyListeners();
    }
  }

  void setThursday(value) {
    if (value != isThursday) {
      isThursday = value;
      isThursday ? chooseDay.add("th") : chooseDay.remove("th");
      isThursday ? chooseDayHTL.add(4) : chooseDayHTL.remove(4);
      notifyListeners();
    }
  }

  void setFriday(value) {
    if (value != isFriday) {
      isFriday = value;
      isFriday ? chooseDay.add("fr") : chooseDay.remove("fr");
      isFriday ? chooseDayHTL.add(5) : chooseDayHTL.remove(5);
      notifyListeners();
    }
  }

  void setSaturday(value) {
    if (value != isSaturday) {
      isSaturday = value;
      isSaturday ? chooseDay.add("sa") : chooseDay.remove("sa");
      isSaturday ? chooseDayHTL.add(6) : chooseDayHTL.remove(6);
      notifyListeners();
    }
  }

  void setSunday(value) {
    if (value != isSunday) {
      isSunday = value;
      isSunday ? chooseDay.add("su") : chooseDay.remove("su");
      isSunday ? chooseDayHTL.add(0) : chooseDayHTL.remove(0);
      notifyListeners();
    }
  }

  void setCloseToArrival(value) {
    if (isCloseToArrival == value) return;
    isCloseToArrival = value;
    notifyListeners();
  }

  void setCloseToDeparture(value) {
    if (isCloseToDeparture == value) return;
    isCloseToDeparture = value;
    notifyListeners();
  }

  void setStopSell(value) {
    if (isStopSell == value) return;
    isStopSell = value;
    notifyListeners();
  }

  void setType(String statusName, bool check) {
    check ? selectedType.add(statusName) : selectedType.remove(statusName);
    notifyListeners();
  }

  List<String> getRatePlanNames() => ratePlans.isNotEmpty
      ? ratePlans.map((ratePlan) => ratePlan.name!).toList()
      : [''];

  void setStart(DateTime date) {
    start = DateUtil.to12h(date);
    if (start.compareTo(end) > 0) {
      end = start;
    }
    notifyListeners();
  }

  void setEnd(DateTime date) {
    end = DateUtil.to12h(date);
    notifyListeners();
  }

  String addOption() {
    if (GeneralManager.hotel!.cms == CmsType.hotelLink &&
        listOption.length == 1) return "Hotelink Chỉnh Được tạo một lần";
    final valueAvailability =
        num.tryParse(valueAvailabilityController.text.replaceAll(',', ''));
    final valueRates =
        num.tryParse(valueRatesController.text.replaceAll(',', ''));
    final valueExtraAdult =
        num.tryParse(valueExtraAdultController.text.replaceAll(',', ''));
    final valueExtraChild =
        num.tryParse(valueExtraChildController.text.replaceAll(',', ''));
    final valueMinNights =
        num.tryParse(valueMinNightsController.text.replaceAll(',', ''));
    final valueMaxNights =
        num.tryParse(valueMaxNightsController.text.replaceAll(',', ''));
    final valueMinStayArrival =
        num.tryParse(valueMinStayArrivalController.text.replaceAll(',', ''));
    final valueMinStayThrough =
        num.tryParse(valueMinStayThroughController.text.replaceAll(',', ''));
    final valueMaxAvailability =
        num.tryParse(valueMaxAvailabilityController.text.replaceAll(',', ''));

    bool check = (valueAvailability == null || valueAvailability < 0) &&
        (valueRates == null || valueRates < 0) &&
        (valueExtraAdult == null || valueExtraAdult < 0) &&
        (valueExtraChild == null || valueExtraChild < 0) &&
        (valueMinNights == null || valueMinNights < 0) &&
        (valueMaxNights == null || valueMaxNights < 0) &&
        (valueMinStayArrival == null || valueMinStayArrival < 0) &&
        (valueMinStayThrough == null || valueMinStayThrough < 0) &&
        (valueMaxAvailability == null || valueMaxAvailability < 0) &&
        !selectedType.contains("CloseToArrival") &&
        !selectedType.contains("CloseToDeparture") &&
        !selectedType.contains("StopSell");

    if (check && !selectedType.contains("Days")) {
      return updateInventoryErrorFromAPI =
          MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_NUMBER);
    }
    if (check && selectedType.contains("Days")) {
      return updateInventoryErrorFromAPI =
          MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_NUMBER);
    }

    if (end.compareTo(start) < 0) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_DAY);
    }

    Map<String, dynamic> data = {};
    data["roomID"] =
        ChannelManager().getCMRoomTypeIDByPMSRoomTypeID(selectedRoomType);
    data["roomTypeID"] = selectedRoomType;
    data["ratePlanID"] = selectedRatePlan;
    data["RomType"] = RoomTypeManager().getRoomTypeNameByID(selectedRoomType);
    data["RatePlan"] = getCmRatePlanNameByID(selectedRatePlan);
    data["from"] = DateUtil.dateToHLSString(start);
    data["to"] = DateUtil.dateToHLSString(end);
    if (valueAvailability != null && valueAvailability >= 0) {
      data["Availability"] = valueAvailability;
      valueAvailabilityController.clear();
    }
    if (valueRates != null && valueRates >= 0) {
      data["Rate"] = GeneralManager.hotel!.cms == CmsType.hotelLink
          ? valueRates
          : valueRatesController.text;
      valueRatesController.clear();
    }
    if (valueExtraAdult != null && valueExtraAdult >= 0) {
      data["ExtraAdultRate"] = valueExtraAdult;
      valueExtraAdultController.clear();
    }
    if (valueExtraChild != null && valueExtraChild >= 0) {
      data["ExtraChildRate"] = valueExtraChild;
      valueExtraChildController.clear();
    }
    if (valueMinNights != null && valueMinNights >= 0) {
      data["MinNights"] = valueMinNights;
      valueMinNightsController.clear();
    }
    if (valueMaxNights != null && valueMaxNights >= 0) {
      data["MaxNights"] = valueMaxNights;
      valueMaxNightsController.clear();
    }
    if (valueMinStayArrival != null && valueMinStayArrival >= 0) {
      data["MinStayArrival"] = valueMinStayArrival;
      valueMinStayArrivalController.clear();
    }
    if (valueMinStayThrough != null && valueMinStayThrough >= 0) {
      data["MinStayThrough"] = valueMinStayThrough;
      valueMinStayThroughController.clear();
    }
    if (valueMaxAvailability != null && valueMaxAvailability >= 0) {
      data["MaxAvailability"] = valueMaxAvailability;
      valueMaxAvailabilityController.clear();
    }
    if (selectedType.contains("CloseToArrival")) {
      data["CloseToArrival"] = isCloseToArrival ? 1 : 0;
      isCloseToArrival = false;
    }
    if (selectedType.contains("CloseToDeparture")) {
      data["CloseToDeparture"] = isCloseToDeparture ? 1 : 0;
      isCloseToDeparture = false;
    }
    if (selectedType.contains("StopSell")) {
      data["StopSell"] = isStopSell ? 1 : 0;
      isStopSell = false;
    }
    if (selectedType.contains("Days")) {
      data["Days"] = chooseDay.toList();
      data["chooseDayHTL"] = chooseDayHTL.toList();
      chooseDay.clear();
    }
    selectedType.clear();
    listOption.add(data);
    chooseDay.clear();
    chooseDayHTL.clear();
    isMonday = true;
    isTuesday = true;
    isWednesday = true;
    isFriday = true;
    isThursday = true;
    isSaturday = true;
    isSunday = true;
    chooseDayHTL.addAll([1, 2, 3, 4, 5, 6, 0]);
    chooseDay.addAll(["mo", "tu", "we", "th", "fr", "sa", "su"]);
    print(listOption);
    notifyListeners();
    return MessageCodeUtil.SUCCESS;
  }

  Future<bool?> updateInventory() async {
    try {
      updating = true;
      notifyListeners();
      if (listOption.isEmpty) {
        updateInventoryErrorFromAPI =
            MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA);
        updating = false;
        notifyListeners();
        return false;
      }

      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('channelmanager-updateinventory');
      final data = (await callable({
        "hotel": GeneralManager.hotelID,
        "dataoption": listOption,
      }))
          .data;
      updateInventoryErrorFromAPI = MessageUtil.getMessageByCode(data['error']);
      listOption.clear();
      updating = false;
      notifyListeners();
      return data['result'];
    } catch (e) {
      updating = false;
      notifyListeners();
      return false;
    }
  }

  void removeOption(Map<String, dynamic> map) {
    listOption.remove(map);
    notifyListeners();
  }
}
