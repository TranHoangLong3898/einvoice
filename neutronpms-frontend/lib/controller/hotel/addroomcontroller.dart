import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/room.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/roomtypemanager.dart';
import '../../util/uimultilanguageutil.dart';

class AddRoomController extends ChangeNotifier {
  bool isLoading = false;
  late bool isAddFeature;
  late TextEditingController teId;
  String roomTypeID = "";

  late TextEditingController teName;

  Room? room;

  late String teRoomType;

  late String errorLog;

  AddRoomController(this.room, String? roomType) {
    if (room == null) {
      roomTypeID = roomType!;
      isAddFeature = true;
      teId = TextEditingController(text: '');
      teName = TextEditingController(text: '');
      teRoomType = roomType;
    } else {
      isAddFeature = false;
      teId = TextEditingController(text: room!.id);
      teName = TextEditingController(text: room!.name);
      teRoomType = room!.roomType!;
    }
  }

  void setRoomTypeId(String idRoomType) {
    if (idRoomType ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) return;
    teRoomType = RoomTypeManager().getRoomTypeIDByName(idRoomType);
    notifyListeners();
  }

  Future<String> addRoom() async {
    if (roomTypeID == teId.text) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INPUT_ROOM_ID_DUPLICATED_ROOM_TYPE);
    }
    if (teRoomType.isEmpty ||
        teRoomType ==
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_ROOMTYPE);
    }

    isLoading = true;
    notifyListeners();

    final roomType = {
      'hotel_id': GeneralManager.hotelID,
      'room_id': room != null ? room!.id : teId.text,
      'room_name': teName.text,
      'room_type_id': teRoomType,
    };
    HttpsCallable callable;
    try {
      if (room != null) {
        callable =
            FirebaseFunctions.instance.httpsCallable('hotelmanager-editRoom');
      } else {
        callable =
            FirebaseFunctions.instance.httpsCallable('hotelmanager-createRoom');
      }
      await callable(roomType);
      isLoading = false;
      notifyListeners();
      return '';
    } on FirebaseFunctionsException catch (e) {
      isLoading = false;
      notifyListeners();
      return MessageUtil.getMessageByCode(e.message);
    }
  }
}
