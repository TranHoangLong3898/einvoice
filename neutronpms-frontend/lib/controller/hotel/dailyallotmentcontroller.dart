import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/util/cmsutil.dart';
import 'package:ihotel/util/dateutil.dart';
import '../../handler/firebasehandler.dart';
import '../../util/messageulti.dart';

class DailyAllotmentController extends ChangeNotifier {
  late String roomTypeId;
  DateTime selectDay = DateTime.now();
  DateTime now = DateTime.now();
  String? onMonthId;
  late num priceOfRoomType;
  late num amountOfRoomType;
  // List<String> roomTypes = [];
  Map<String, dynamic> dailyAllotments = {};
  Map<String, dynamic> textEditingControllers = {};
  List<Map<String, dynamic>> dailyRender = [];
  StreamSubscription? subscription;
  bool isLoading = false;

  DailyAllotmentController() {
    isLoading = true;
    roomTypeId = RoomTypeManager().getFirstRoomType()?.id ?? 'None';
    loadDailyAllotment();
  }

  DocumentReference getInitQuery(String monthId) {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colDailyAllotment)
        .doc(monthId);
  }

  void loadDailyAllotment() async {
    if (onMonthId != null &&
        onMonthId == DateUtil.dateToShortStringYearMonth(selectDay)) return;
    await subscription?.cancel();
    subscription = getInitQuery(DateUtil.dateToShortStringYearMonth(selectDay))
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        clear();
        dailyAllotments.addAll(snapshot.get('data'));
        updateDailyAllotmentWithRoomType(roomTypeId);
      }
    });
  }

  void setRoomType(String nameRoomType) {
    if (nameRoomType == RoomTypeManager().getRoomTypeNameByID(roomTypeId)) {
      return;
    }
    roomTypeId = RoomTypeManager().getRoomTypeIDByName(nameRoomType);
    dailyRender.clear();
    updateDailyAllotmentWithRoomType(roomTypeId);
  }

  void updateDailyAllotmentWithRoomType(String idRoomType) {
    if (roomTypeId == 'None') {
      isLoading = false;
      notifyListeners();
      return;
    }
    priceOfRoomType = RoomTypeManager().getPriceOfRoomType(idRoomType);
    amountOfRoomType = RoomTypeManager().getAmountOfRoomType(idRoomType);
    textEditingControllers[idRoomType] = {};
    for (var item in dailyAllotments.entries) {
      Map<String, dynamic> data = {};
      if (item.key == 'default') continue;
      data['num'] = item.value?[idRoomType]?['num'] ?? amountOfRoomType;
      data['price'] = item.value?[idRoomType]?['price'] ?? priceOfRoomType;
      data['roomType'] = idRoomType;
      data['day'] = item.key;
      textEditingControllers[idRoomType][item.key] = {};
      textEditingControllers[idRoomType][item.key]['num'] =
          TextEditingController(text: data['num'].toString());
      textEditingControllers[idRoomType][item.key]['price'] =
          TextEditingController(text: data['price'].toString());
      dailyRender.add(data);
    }
    dailyRender
        .sort((a, b) => int.parse(a['day']).compareTo(int.parse(b['day'])));
    isLoading = false;
    notifyListeners();
  }

  void setMonthId(DateTime datePicked) {
    if ((datePicked.month.compareTo(now.month) == -1) &&
        datePicked.year.compareTo(now.year) == -1) return;
    selectDay = datePicked;
    loadDailyAllotment();
    notifyListeners();
  }

  void cancelStream() {
    subscription?.cancel();
  }

  Future<String> updateDailyAllotmentToCloud() async {
    try {
      isLoading = true;
      notifyListeners();
      final Map<String, dynamic> dataUpdate = {};
      for (var element in dailyAllotments.entries) {
        // continue if dailyallotment.defalut
        if (element.key == 'default') continue;
        //validate rate and quantity of room must input
        if (textEditingControllers[roomTypeId][element.key]['num'].text == '' ||
            textEditingControllers[roomTypeId][element.key]['price']
                    .text
                    .replaceAll(',', '') ==
                '') {
          isLoading = false;
          notifyListeners();
          return MessageUtil.getMessageByCode(
              MessageCodeUtil.INPUT_RATE_ROOM_CHANNEL);
        }
        // validate rate must smaller than min price of room tpye
        if (num.parse(textEditingControllers[roomTypeId][element.key]['price']
                .text
                .replaceAll(',', '')) <
            RoomTypeManager().getRoomTypeByID(roomTypeId).minPrice!) {
          isLoading = false;
          notifyListeners();
          return MessageUtil.getMessageByCode(
              MessageCodeUtil.PRICE_MUST_BIGGER_THAN_MIN_PRICE);
        }
        // validate quantity must smaller than min price of room tpye
        if (num.parse(
                textEditingControllers[roomTypeId][element.key]['num'].text) >
            RoomTypeManager().getRoomTypeByID(roomTypeId).total!) {
          isLoading = false;
          notifyListeners();
          return MessageUtil.getMessageByCode(
              MessageCodeUtil.OVER_MAXIMUM_ROOM_OF_ROOMTYPE);
        }
        if (textEditingControllers[roomTypeId][element.key]['num'].text !=
            element.value[roomTypeId]['num'].toString()) {
          dataUpdate[element.key] = {};
          dataUpdate[element.key]['num'] = num.parse(
              textEditingControllers[roomTypeId][element.key]['num'].text);
        }
        if (element.value[roomTypeId]['price'] == null &&
            textEditingControllers[roomTypeId][element.key]['price']
                    .text
                    .replaceAll(',', '') !=
                priceOfRoomType.toString()) {
          if (dataUpdate[element.key] == null) {
            dataUpdate[element.key] = {};
          }
          dataUpdate[element.key]['price'] =
              GeneralManager.hotel!.cms == CmsType.hotelLink
                  ? num.parse(textEditingControllers[roomTypeId][element.key]
                          ['price']
                      .text
                      .replaceAll(',', ''))
                  : textEditingControllers[roomTypeId][element.key]['price']
                      .text
                      .replaceAll(',', '');
        } else if (element.value[roomTypeId]['price'] != null &&
            textEditingControllers[roomTypeId][element.key]['price']
                    .text
                    .replaceAll(',', '') !=
                element.value[roomTypeId]['price'].toString()) {
          if (dataUpdate[element.key] == null) {
            dataUpdate[element.key] = {};
          }
          dataUpdate[element.key]['price'] =
              GeneralManager.hotel!.cms == CmsType.hotelLink
                  ? num.parse(textEditingControllers[roomTypeId][element.key]
                          ['price']
                      .text
                      .replaceAll(',', ''))
                  : textEditingControllers[roomTypeId][element.key]['price']
                      .text
                      .replaceAll(',', '');
        }
      }
      if (dataUpdate.isEmpty) {
        isLoading = false;
        notifyListeners();
        return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_DATA);
      }
      print(dataUpdate);
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('dailytask-editDailyAllotment');
      final result = await callable({
        'list': dataUpdate,
        'hotel_id': GeneralManager.hotelID,
        'daily_allotment_id': DateUtil.dateToShortStringYearMonth(selectDay),
        'room_type_id': roomTypeId,
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
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

  void clear() {
    dailyRender.clear();
    dailyAllotments.clear();
  }
}
