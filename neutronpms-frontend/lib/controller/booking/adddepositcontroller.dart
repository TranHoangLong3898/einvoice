import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../modal/booking.dart';
import '../../modal/service/deposit.dart';

class AddDepositController extends ChangeNotifier {
  final Booking? booking;
  final Deposit? deposit;
  late String idBooking;
  late String methodID;
  Booking? transferredBooking;
  late TextEditingController teDesc;
  late TextEditingController teAmount;
  late TextEditingController teNote;
  late TextEditingController teActualAmount;
  late TextEditingController teReferenceNumber;
  DateTime? referencDate, oldreferencDate;
  late num oldDeposit;
  late String oldMethod;
  late String oldDesc;
  num? oldActualAmount;
  String? oldNote, oldReferenceNumber;
  List<String> methodNames = [];
  bool isLoading = false;
  final DateTime now = Timestamp.now().toDate();
  num? totalPricePayment;

  AddDepositController({this.booking, this.deposit, this.totalPricePayment}) {
    isLoading = true;
    notifyListeners();
    methodNames = PaymentMethodManager().getPaymentActiveMethodName();
    if (booking != null) {
      idBooking = (booking!.group! ? booking!.sID! : booking!.id!);
    }
    if (deposit != null) {
      oldDeposit = deposit!.amount!;
      oldMethod = deposit!.method!;
      oldDesc = deposit!.desc!;
      methodID = deposit!.method!;
      oldActualAmount = deposit!.actualAmount;
      oldNote = deposit!.note;
      oldReferenceNumber = deposit!.referenceNumber;
      oldreferencDate = deposit!.referencDate;
      teDesc = TextEditingController(text: deposit!.desc!);
      teAmount = TextEditingController(text: deposit!.amount.toString());
      teActualAmount =
          TextEditingController(text: deposit!.actualAmount.toString());
      teNote = TextEditingController(text: deposit!.note);
      teReferenceNumber = TextEditingController(text: deposit!.referenceNumber);
      referencDate = deposit!.referencDate;
      if (methodID == PaymentMethodManager.transferMethodID) {
        getTransferredBookingFromCloud(deposit!.transferredBID!);
      } else {
        isLoading = false;
        notifyListeners();
      }
    } else {
      methodID = PaymentMethodManager().getPaymentActiveMethodId().first!;
      teDesc = TextEditingController();
      teAmount =
          TextEditingController(text: totalPricePayment?.toString() ?? "0");
      teNote = TextEditingController(text: "");
      teActualAmount = TextEditingController(text: "0");
      teReferenceNumber = TextEditingController(text: "");
      referencDate = null;
      isLoading = false;
      notifyListeners();
    }
  }

  void setReferencDate(DateTime newDate) {
    if (referencDate != null && DateUtil.equal(newDate, referencDate!)) return;
    referencDate = newDate;
    notifyListeners();
  }

  void setMethodID(String methodName) {
    if (PaymentMethodManager().getPaymentMethodIdByName(methodName) !=
        methodID) {
      methodID = PaymentMethodManager().getPaymentMethodIdByName(methodName)!;
      if (methodID != PaymentMethodManager.transferMethodID) {
        transferredBooking = null;
      }
      notifyListeners();
    }
  }

  void setTransferredBooking(Booking booking) {
    transferredBooking = booking;
    notifyListeners();
  }

  void getTransferredBookingFromCloud(String idBooking) async {
    transferredBooking = await BookingManager().getBookingByID(idBooking);
    isLoading = false;
    notifyListeners();
  }

  String getTransferredBookingInfo() => transferredBooking == null
      ? 'Choose Booking'
      : '${transferredBooking!.name} (${transferredBooking!.group! ? 'Group' : RoomManager().getNameRoomById(transferredBooking!.room!)})';

  Future<String> addDeposit() async {
    final newDeposit = num.tryParse(teAmount.text.replaceAll(',', ''));
    final newactualAmount =
        num.tryParse(teActualAmount.text.replaceAll(',', ''));
    if (newDeposit == null) {
      return MessageCodeUtil.INPUT_PAYMENT;
    }
    if (methodID == PaymentMethodManager.transferMethodID &&
        transferredBooking == null) {
      return MessageCodeUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED;
    }

    if (deposit != null) {
      if (newDeposit == oldDeposit &&
          teDesc.text == oldDesc &&
          methodID == oldMethod &&
          newactualAmount == oldActualAmount &&
          teNote.text == oldNote &&
          teReferenceNumber.text == oldReferenceNumber &&
          oldreferencDate == referencDate) {
        return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
      }
      isLoading = true;
      notifyListeners();
      deposit!.setAmount(newDeposit);
      deposit!.setDesc(teDesc.text);
      deposit!.setMethod(methodID);
      deposit!.setActualAmount(newactualAmount ?? 0);
      deposit!.setNote(teNote.text);
      deposit!.setReferenceNumber(teReferenceNumber.text);
      deposit!.setReferencDate(referencDate);
      if (transferredBooking != null) {
        deposit!.setTransferredBID(transferredBooking!.id!);
      }
      String nameRoomTransfer = '';
      if (transferredBooking != null) {
        nameRoomTransfer = transferredBooking!.group!
            ? ''
            : RoomManager().getNameRoomById(transferredBooking!.room!);
      }
      final result = await booking!.updateDeposit(deposit!, nameRoomTransfer,
          RoomManager().getNameRoomById(booking!.room!));
      if (result != MessageCodeUtil.SUCCESS) {
        deposit!.setAmount(oldDeposit);
        deposit!.setDesc(oldDesc);
        deposit!.setMethod(oldMethod);
      }
      isLoading = false;
      notifyListeners();
      return result;
    } else {
      isLoading = true;
      notifyListeners();
      String nameRoomTransferTo = '';
      if (transferredBooking != null) {
        nameRoomTransferTo = transferredBooking!.group!
            ? ''
            : RoomManager().getNameRoomById(transferredBooking!.room!);
      }
      final result = await booking!.addDeposit(
          Deposit(
            desc: teDesc.text,
            amount: newDeposit,
            method: methodID,
            transferredBID: transferredBooking?.id,
            created: Timestamp.now(),
            status: PaymentMethodManager.statusOpen,
            actualAmount: newactualAmount,
            note: teNote.text,
            referenceNumber: teReferenceNumber.text,
            referencDate: referencDate,
          ),
          nameRoomTransferTo,
          RoomManager().getNameRoomById(booking!.room!));
      isLoading = false;
      notifyListeners();
      return result;
    }
  }
}
