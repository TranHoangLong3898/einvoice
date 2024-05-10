import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../modal/booking.dart';

class NoteController extends ChangeNotifier {
  late String oldNote;
  TextEditingController notesController = TextEditingController();
  Booking? booking;
  bool saving = false;

  NoteController({this.booking}) {
    initialize();
  }

  void initialize() async {
    final note = booking!.group!
        ? await booking?.getNotesBySid() ?? ""
        : await booking?.getNotes() ?? "";
    oldNote = note;
    notesController.text = note;
    notifyListeners();
  }

  Future<String> saveNotes() async {
    if (oldNote == notesController.text) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (saving) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    saving = true;
    notifyListeners();
    final result = await booking!
        .saveNotes(notesController.text)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    saving = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
