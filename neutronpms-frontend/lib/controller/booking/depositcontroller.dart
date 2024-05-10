import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/handler/firebasehandler.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../modal/booking.dart';
import '../../modal/service/deposit.dart';

class DepositController extends ChangeNotifier {
  List<Deposit>? deposits = [];
  late String idBooking;
  StreamSubscription? subscription;
  StreamSubscription? subscriptionDepositsAndTransfer;
  Booking? booking;
  QuerySnapshot? snapshotTepm;
  Query? nextQuery;
  Query? preQuery;
  bool? forward;
  bool _loading = false;
  num totalDepositsMoney = 0;
  num totalTransferingMoney = 0;
  num totalTransferredMoney = 0;

  final pageSize = 10;

  Query getInitQuery() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(idBooking)
        .collection(FirebaseHandler.colDeposits)
        .orderBy('created');
  }

  DepositController(this.booking) {
    idBooking = booking!.group! ? booking!.sID! : booking!.id!;
    loadDeposits();
    getDepositsAndTransferTotalMoney();
  }

  void updateDepositsAndQueries(QuerySnapshot snapshot) {
    if (snapshot.size == 0) {
      if (forward == null) {
        nextQuery = null;
        preQuery = null;
      } else if (forward!) {
        nextQuery = null;
        preQuery = getInitQuery()
            .endAtDocument(snapshotTepm!.docs.last)
            .limitToLast(pageSize);
      } else {
        preQuery = null;
        nextQuery = getInitQuery()
            .startAtDocument(snapshotTepm!.docs.first)
            .limit(pageSize);
      }
    } else {
      snapshotTepm = snapshot;
      for (var item in snapshot.docs) {
        deposits!.add(Deposit.fromSnapshot(item));
      }
      if (snapshot.size < pageSize) {
        if (forward == null) {
          nextQuery = null;
          preQuery = null;
        } else if (forward!) {
          nextQuery = null;
          preQuery = getInitQuery()
              .endBeforeDocument(snapshot.docs.first)
              .limitToLast(pageSize);
        } else {
          preQuery = null;
          nextQuery = getInitQuery()
              .startAfterDocument(snapshot.docs.last)
              .limit(pageSize);
        }
      } else {
        nextQuery = getInitQuery()
            .startAfterDocument(snapshot.docs.last)
            .limit(pageSize);
        preQuery = getInitQuery()
            .endBeforeDocument(snapshot.docs.first)
            .limitToLast(pageSize);
      }
    }
    _loading = false;
    notifyListeners();
  }

  void loadDeposits() async {
    if (booking == null) return;
    _loading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshot) {
      deposits!.clear();
      updateDepositsAndQueries(snapshot);
    });
  }

  void getDepositNextPage() async {
    if (nextQuery == null) return;
    _loading = true;
    notifyListeners();
    forward = true;
    subscription?.cancel();
    subscription = nextQuery!.snapshots().listen((snapshot) {
      deposits!.clear();
      updateDepositsAndQueries(snapshot);
    });
  }

  void getDepositPreviousPage() {
    if (preQuery == null) return;
    _loading = true;
    notifyListeners();
    forward = false;
    subscription?.cancel();
    subscription = preQuery!.snapshots().listen((snapshot) {
      deposits!.clear();
      updateDepositsAndQueries(snapshot);
    });
  }

  void getDepositLastPage() async {
    if (booking == null) return;
    _loading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        getInitQuery().limitToLast(pageSize).snapshots().listen((snapshot) {
      deposits!.clear();
      updateDepositsAndQueries(snapshot);
    });
  }

  void getDepositFirstPage() {
    if (booking == null) return;
    _loading = true;
    notifyListeners();
    subscription?.cancel();
    subscription =
        getInitQuery().limit(pageSize).snapshots().listen((snapshot) {
      deposits!.clear();
      updateDepositsAndQueries(snapshot);
    });
  }

// cancel stream if dialog dispose
  void cancelStream() {
    subscription?.cancel();
    subscriptionDepositsAndTransfer?.cancel();
  }

// listen deposits and transferring
  void getDepositsAndTransferTotalMoney() {
    if (booking == null) return;
    subscriptionDepositsAndTransfer = FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .doc(idBooking)
        .snapshots()
        .listen((event) {
      if (event.data()!.containsKey('deposit')) {
        totalDepositsMoney = event.get('deposit');
      }
      if (event.data()!.containsKey('transferring')) {
        totalTransferingMoney = event.get('transferring');
      }
      if (event.data()!.containsKey('transferred')) {
        totalTransferredMoney = event.get('transferred');
      }
      notifyListeners();
    });
  }

// Delete deposits
  Future<String> deleteDeposit(Deposit deposit) async {
    if (booking == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.BOOKING_NOT_FOUND);
    }
    _loading = true;
    notifyListeners();
    final result = await booking!.deleteDeposit(deposit);
    _loading = false;
    notifyListeners();
    return result;
  }

// Get room and name people book
  String getInfo() {
    if (booking == null || booking!.isEmpty!) return "";
    if (booking!.group == false) {
      return "${booking!.name} (${RoomManager().getNameRoomById(booking!.room!)})";
    } else {
      return "Group: ${booking!.name}";
    }
  }

  num getTotalPricePaymet(num remain) {
    return (remain -
        deposits!.fold(0.0,
            (previousValue, element) => previousValue + (element.amount ?? 0)));
  }

  bool isLoading() => _loading;
}
