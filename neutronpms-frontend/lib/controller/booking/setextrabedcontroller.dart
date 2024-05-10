import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../modal/booking.dart';

class SetExtraBedController extends ChangeNotifier {
  late Booking booking;
  late TextEditingController teBed = TextEditingController();
  bool updating = false;
  late int oldExtrabed;

  SetExtraBedController(this.booking) {
    teBed.text = booking.extraBed?.toString() ?? '';
    oldExtrabed = booking.extraBed ?? 0;
  }

  void disposeTextEditingControllers() {
    teBed.dispose();
  }

  Future<String> updateExtraBed() async {
    int? newExtraBed = int.tryParse(teBed.text);
    if (newExtraBed == oldExtrabed) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (updating) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    updating = true;
    notifyListeners();
    String result = await booking
        .updateExtraBed(newExtraBed!)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    updating = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
