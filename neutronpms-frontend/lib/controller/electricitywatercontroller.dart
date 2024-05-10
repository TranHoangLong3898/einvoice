import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/modal/electricitywater.dart';
import 'package:ihotel/modal/service/service.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../../modal/booking.dart';

class ElectricityWaterController extends ChangeNotifier {
  late DateTime now,
      createdDate,
      firstDate,
      lastDate,
      createdDateOld,
      firstDateOld,
      lastDateOld;
  TextEditingController teFirstElectricityORWater = TextEditingController();
  TextEditingController teLastElectricityORWater = TextEditingController();
  TextEditingController teElectricityWaterORPricer = TextEditingController();
  bool saving = false;
  final Booking booking;
  final Service? service;
  final bool isElectricity;
  late num firstEWold, lastEWold, priceEWold;
  num totalElectricityOrWater = 0;

  ElectricityWaterController(this.booking, this.isElectricity, this.service) {
    now = DateTime.now();
    Electricity? electricity;
    Water? water;
    if (isElectricity) {
      electricity = (service as Electricity?);
    } else {
      water = (service as Water?);
    }
    if (service == null) {
      DateTime? createEorW;
      if ((booking.waterDetails!.isNotEmpty && !isElectricity) ||
          (booking.electricityDetails!.isNotEmpty && isElectricity)) {
        Map<String, dynamic>? data =
            isElectricity ? booking.electricityDetails : booking.waterDetails;
        num sortTimeKey = 0;
        for (var key in data!.keys) {
          if (sortTimeKey < int.parse(key)) {
            sortTimeKey = int.parse(key);
          }
        }
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(
            data["$sortTimeKey"].toString().split(specificCharacter)[0]));
        createEorW = DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
        teFirstElectricityORWater.text = data["$sortTimeKey"]
            .toString()
            .split(specificCharacter)[1]
            .toString();
      } else {
        teFirstElectricityORWater.text = "0";
      }
      createdDate = DateUtil.to12h(createEorW ?? now);
      firstDate = DateUtil.to12h(createEorW ?? now);

      lastDate = DateUtil.to12h(DateTime(
          createEorW?.year ?? now.year,
          createEorW?.month ?? now.month,
          DateUtil.getLengthOfMonth(createEorW ?? now)));
    } else {
      createdDate =
          isElectricity ? electricity!.createdTime! : water!.createdTime!;
      firstDate =
          isElectricity ? electricity!.initialTime! : water!.initialTime!;
      lastDate = isElectricity ? electricity!.finalTime! : water!.finalTime!;
      teFirstElectricityORWater.text =
          (isElectricity ? electricity?.initialNumber : water?.initialNumber)
                  ?.toString() ??
              "0";
    }

    teLastElectricityORWater.text =
        (isElectricity ? electricity?.finalNumber : water?.finalNumber)
                ?.toString() ??
            "0";
    teElectricityWaterORPricer.text = isElectricity
        ? (electricity?.priceElectricity ?? 0) == 0
            ? (ConfigurationManagement()
                        .electricityWater["electricity"]
                        ?.getRawString() ??
                    0)
                .toString()
            : electricity?.priceElectricity?.toString() ?? "0"
        : (water?.priceWater ?? 0) == 0
            ? ConfigurationManagement()
                    .electricityWater["water"]
                    ?.getRawString() ??
                "0"
            : water?.priceWater?.toString() ?? "0";

    totalElectricityOrWater = num.parse(teLastElectricityORWater.text) == 0
        ? 0
        : (num.parse(teLastElectricityORWater.text) -
                num.parse(teFirstElectricityORWater.text)) *
            num.parse(teElectricityWaterORPricer.text);

    createdDateOld = createdDate;
    firstDateOld = firstDate;
    lastDateOld = lastDate;
    firstEWold = num.parse(teFirstElectricityORWater.text);
    lastEWold = num.parse(teLastElectricityORWater.text);
    priceEWold = num.parse(teElectricityWaterORPricer.text);
    notifyListeners();
  }

  void changeElectricityOrWater() {
    final teLastEorW = teLastElectricityORWater.text.isEmpty
        ? 0
        : num.parse(teLastElectricityORWater.text.replaceAll(',', ''));
    final teEorWPrice = teElectricityWaterORPricer.text.isEmpty
        ? 0
        : num.parse(teElectricityWaterORPricer.text.replaceAll(',', ''));
    final teFirstEorW = teFirstElectricityORWater.text.isEmpty
        ? 0
        : num.parse(teFirstElectricityORWater.text.replaceAll(',', ''));
    totalElectricityOrWater =
        teLastEorW == 0 ? 0 : (teLastEorW - teFirstEorW) * teEorWPrice;
    notifyListeners();
  }

  Future<String> saveElectricityWater() async {
    num firstEorWater =
        num.tryParse(teFirstElectricityORWater.text.replaceAll(',', '')) ?? 0;
    num lastEorWater =
        num.tryParse(teLastElectricityORWater.text.replaceAll(',', '')) ?? 0;
    final waterEorPricer =
        num.tryParse(teElectricityWaterORPricer.text.replaceAll(',', ''));

    if (waterEorPricer == null ||
        firstEorWater < 0 ||
        lastEorWater < 0 ||
        waterEorPricer < 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.HOUR_AND_PRICE_MUST_BE_POSITIVE);
    }
    if (firstEorWater == firstEWold &&
        lastEorWater == lastEWold &&
        waterEorPricer == priceEWold &&
        createdDateOld.isAtSameMomentAs(createdDateOld) &&
        firstDateOld.isAtSameMomentAs(firstDate) &&
        lastDateOld.isAtSameMomentAs(lastDate)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }

    if (firstEorWater >= lastEorWater && lastEorWater != 0) {
      return MessageUtil.getMessageByCode(MessageCodeUtil
          .THE_BIGINGING_OF_THE_PERIOD_CANNOT_BE_GTEATER_THAN_THE_END_OF_THE_THE_PERIOD);
    }

    Electricity electricityWaters = Electricity(
        id: service?.id ?? "",
        initialNumber: firstEorWater,
        initialTime: firstDate,
        finalTime: lastDate,
        finalNumber: lastEorWater,
        createdTime: createdDate,
        total: totalElectricityOrWater,
        priceElectricity: waterEorPricer,
        desc: "");

    Water waters = Water(
        id: service?.id ?? "",
        initialNumber: firstEorWater,
        initialTime: firstDate,
        finalTime: lastDate,
        finalNumber: lastEorWater,
        createdTime: createdDate,
        total: totalElectricityOrWater,
        priceWater: waterEorPricer,
        desc: "");
    if (saving) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    saving = true;
    notifyListeners();
    String result = "";
    if (service == null) {
      result = await booking
          .addService(isElectricity ? electricityWaters : waters)
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    } else {
      result = await booking
          .updateService(isElectricity ? electricityWaters : waters)
          .then((value) => value)
          .onError((error, stackTrace) => error.toString());
    }

    saving = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }

  void setCreateDate(DateTime date) {
    if (createdDate.isAtSameMomentAs(DateUtil.to12h(date))) return;
    createdDate = DateUtil.to12h(date);
    notifyListeners();
  }

  void setFirstDate(DateTime date) {
    if (firstDate.isAtSameMomentAs(DateUtil.to12h(date))) return;
    firstDate = DateUtil.to12h(date);
    notifyListeners();
  }

  void setLastDate(DateTime date) {
    if (lastDate.isAtSameMomentAs(DateUtil.to12h(date))) return;
    lastDate = DateUtil.to12h(date);
    notifyListeners();
  }
}

class ElectricityWaterListController extends ChangeNotifier {
  List<Electricity>? electricity = [];
  List<Water>? water = [];
  final Booking booking;
  bool isLoading = true;
  bool isElectricity;
  ElectricityWaterListController(this.booking, this.isElectricity) {
    update();
  }

  void update() async {
    if (isElectricity) {
      electricity!.clear();
      electricity = await booking.getElectricity();
    } else {
      water!.clear();
      water = await booking.getWater();
    }
    isLoading = false;
    notifyListeners();
  }

  void rebuild() {
    notifyListeners();
  }
}
