import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';

import '../../modal/booking.dart';
import '../../modal/service/transfer.dart';

class TransferController extends ChangeNotifier {
  List<Transfer>? transfers = [];
  final Booking? booking;
  bool _loading = false;

  TransferController(this.booking) {
    loadTransfers();
  }
  void loadTransfers() async {
    if (booking == null) return;

    _loading = true;

    transfers = (await booking?.getTransfers())!;

    _loading = false;
    notifyListeners();
  }

  num getTotal() => transfers!
      .fold(0, (previousValue, transfer) => previousValue + transfer.amount!);

  bool isLoading() => _loading;

  String getInfo() {
    if (booking == null) return "";

    return "${booking!.name} - ${RoomManager().getNameRoomById(booking!.room!)}";
  }
}
