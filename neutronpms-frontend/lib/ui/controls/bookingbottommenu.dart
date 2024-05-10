import 'package:flutter/material.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/component/booking/changeroomdialog.dart';
import 'package:ihotel/ui/component/booking/checkoutdialog.dart';
import 'package:ihotel/ui/component/booking/depositdialog.dart';
import 'package:ihotel/ui/component/booking/discountdialog.dart';
import 'package:ihotel/ui/component/booking/notedialog.dart';
import 'package:ihotel/ui/component/booking/setextrabeddialog.dart';
import 'package:ihotel/ui/component/booking/updatetaxdeclaredialog.dart';
import 'package:ihotel/ui/component/extraservice/virtualbookingmanagementdialog.dart';
import 'package:ihotel/ui/component/service/servicedialog.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';

import '../../manager/usermanager.dart';
import '../component/booking/logbookingdialog.dart';
import '../component/booking_group/groupdialog.dart';
import '../component/service/costform.dart';

class BookingBottomMenu {
  final BuildContext? context;
  Booking? booking;
  final numberIconsBookedOnWeb = 15;
  final numberIconsBookedGroupOnWeb = 14;
  final numberIconsCheckInOnWeb = 12;
  final numberIconsOnMobile = 8;

  BookingBottomMenu({this.context, this.booking}) {
    getBooking();
  }

  getBooking() async {
    if (booking!.isEmpty!) return;
    if (booking!.group!) {
      final source = booking!.sourceID;
      final bed = booking!.bed;
      final breakfast = booking!.breakfast;
      final lunch = booking!.lunch;
      final dinner = booking!.dinner;
      final payAtHotel = booking!.payAtHotel;
      Booking parent =
          await BookingManager().getBookingGroupByID(booking!.sID!);
      booking = Booking.fromBookingParent(booking!.id!, parent);
      booking!.sourceID = source;
      booking!.lunch = lunch;
      booking!.breakfast = breakfast;
      booking!.dinner = dinner;
      booking!.payAtHotel = payAtHotel;
      booking!.bed = bed;
    } else {
      booking = await BookingManager().getBookingByID(booking!.id!);
    }
  }

  int getCrossAxisCountGridView() {
    if (ResponsiveUtil.isMobile(context!) &&
        booking!.status == BookingStatus.checkin) {
      return 6;
    } else if (ResponsiveUtil.isMobile(context!) &&
        booking!.status == BookingStatus.booked) {
      return booking!.group! ? 7 : 8;
    } else {
      if (booking!.status == BookingStatus.booked) {
        return booking!.group!
            ? numberIconsBookedGroupOnWeb
            : numberIconsBookedOnWeb;
      }
      if (booking!.status == BookingStatus.checkin) {
        return booking!.group! ? 11 : numberIconsCheckInOnWeb;
      }
      return 8;
    }
  }

  double getChildAspectRatio() {
    int heightMenuOnWeb = 50;
    int heightMenuOnMobile = 50;

    // widthCell = screenWidth / countOfIcons
    // ratio = widthCell / height;
    if (ResponsiveUtil.isMobile(context!)) {
      return MediaQuery.of(context!).size.width /
          getCrossAxisCountGridView() /
          heightMenuOnMobile;
    } else {
      return MediaQuery.of(context!).size.width /
          getCrossAxisCountGridView() /
          heightMenuOnWeb;
    }
  }

  open() async {
    await showDialog<String>(
            builder: (ctx) => booking!.isVirtual!
                ? VirtualBookingDialog(booking: booking!)
                : BookingDialog(booking: booking!),
            context: context!)
        .then((result) => {
              if (result != null) MaterialUtil.showSnackBar(context, result),
            });
  }

  confirmBooking() async {
    await booking!.updateStatus(booking!).then((result) {
      if (result != MessageCodeUtil.SUCCESS) {
        MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
      } else {
        MaterialUtil.showSnackBar(
            context, MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS));
      }
    });
  }

  checkIn() async {
    var checkInConfirm = await MaterialUtil.showConfirm(
        context!,
        MessageUtil.getMessageByCode(
            MessageCodeUtil.CONFIRM_BOOKING_CHECKIN_AT_ROOM,
            [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));
    if (checkInConfirm == null || !checkInConfirm) return;
    await booking!.checkIn().then((result) {
      if (result == MessageCodeUtil.SUCCESS) {
        MaterialUtil.showSnackBar(
            context,
            MessageUtil.getMessageByCode(
                MessageCodeUtil.BOOKING_CHECKIN_SUCCESS, [booking!.name!]));
      } else {
        String infoDisplay = result.contains('room')
            ? RoomManager().getNameRoomById(booking!.room!)
            : booking!.name!;
        MaterialUtil.showAlert(
            context, MessageUtil.getMessageByCode(result, [infoDisplay]));
      }
    }).onError((error, stackTrace) {
      error;
    });
  }

  checkOut(Booking basicBookings) async {
    if (booking!.group!) {
      await BookingManager()
          .getBookingGroupByID(booking!.sID!)
          .then((bookingGroup) async {
        bool? isConfirmed;
        if (bookingGroup.getRemaining()! > 0) {
          isConfirmed = (await MaterialUtil.showConfirm(
              context!,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.BOOKING_GROUP_HAVE_REMAINING_BEFORE_CHECKOUT,
                  [
                    bookingGroup.getRemaining().toString(),
                    '${RoomManager().getNameRoomById(booking!.room!)} - ${booking!.name!}'
                  ])));
        } else {
          isConfirmed = (await MaterialUtil.showConfirm(
              context!,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.CONFIRM_BOOKING_CHECKOUT, [
                '${RoomManager().getNameRoomById(booking!.room!)} - ${booking?.name}'
              ])));
        }
        if (isConfirmed != null && isConfirmed) {
          await booking!.checkOut().then((result) {
            if (result == MessageCodeUtil.SUCCESS) {
              MaterialUtil.showSnackBar(
                  context,
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.BOOKING_CHECKOUT_SUCCESS,
                      [booking!.name!]));
            } else {
              MaterialUtil.showAlert(context,
                  MessageUtil.getMessageByCode(result, [booking!.name!]));
            }
          });
        }
      });
    } else {
      await showDialog<String>(
              builder: (ctx) => CheckOutDialog(
                    booking: booking!,
                    basicBookings: basicBookings,
                  ),
              context: context!)
          .then((result) {
        if (result != null) {
          MaterialUtil.showSnackBar(context, result);
        }
      });
    }
  }

  noShow() async {
    bool? isConfirmed = await MaterialUtil.showConfirm(
        context!,
        MessageUtil.getMessageByCode(
            MessageCodeUtil.CONFIRM_BOOKING_NO_SHOW_AT_ROOM,
            [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));
    if (isConfirmed != null && isConfirmed) {
      await booking!.noShow().then((result) {
        if (result == MessageCodeUtil.SUCCESS) {
          MaterialUtil.showSnackBar(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.BOOKING_CANCEL_SUCCESS, [booking!.name!]));
        } else {
          MaterialUtil.showAlert(
              context, MessageUtil.getMessageByCode(result, [booking!.name!]));
        }
      });
    }
  }

  cancel() async {
    bool? isConfirmed = await MaterialUtil.showConfirm(
        context!,
        MessageUtil.getMessageByCode(
            MessageCodeUtil.CONFIRM_BOOKING_CANCEL_AT_ROOM,
            [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));
    if (isConfirmed != null && isConfirmed) {
      booking!.isVirtual!
          ? await booking!.cancelVirtual().then((result) {
              if (result == MessageCodeUtil.SUCCESS) {
                MaterialUtil.showSnackBar(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_CANCEL_SUCCESS,
                        [booking!.name!]));
              } else {
                MaterialUtil.showAlert(context,
                    MessageUtil.getMessageByCode(result, [booking!.name!]));
              }
            }).onError((error, stackTrace) {
              error;
            })
          : await booking!.cancel().then((result) {
              if (result == MessageCodeUtil.SUCCESS) {
                MaterialUtil.showSnackBar(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_CANCEL_SUCCESS,
                        [booking!.name!]));
              } else {
                MaterialUtil.showAlert(context,
                    MessageUtil.getMessageByCode(result, [booking!.name!]));
              }
            });
    }
  }

  service() async {
    await showDialog<String>(
        builder: (ctx) => ServiceDialog(
              booking: booking!,
            ),
        context: context!);
  }

  cost() async {
    await showDialog<String>(
        builder: (ctx) => CostBookingDialog(booking: booking!),
        context: context!);
  }

  summary(Booking basicBookings) async {
    showDialog(
      context: context!,
      builder: (ctx) => CheckOutDialog(
        booking: booking!,
        basicBookings: basicBookings,
        isShowCheckoutButton: false,
      ),
    );
  }

  payment() async {
    await showDialog<String>(
        builder: (ctx) => DepositDialog(
              booking: booking!,
            ),
        context: context!);
  }

  group() async {
    if (booking!.sID == null || booking!.sID!.isEmpty) return;
    await showDialog<String>(
        builder: (ctx) => GroupDialog(
              booking: booking!,
            ),
        context: context!);
  }

  changeRoom() async {
    await showDialog<String>(
        builder: (ctx) => ChangeRoomDialog(
              booking: booking!,
            ),
        context: context!);
  }

  extraBed() async {
    await showDialog<String>(
        builder: (ctx) => SetExtraBedDialog(
              booking: booking!,
            ),
        context: context!);
  }

  undoCheckIn() async {
    bool? isConfirmed = await MaterialUtil.showConfirm(
        context!,
        MessageUtil.getMessageByCode(
            MessageCodeUtil.CONFIRM_BOOKING_UNDO_CHECKIN_AT_ROOM,
            [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));

    if (isConfirmed != null && isConfirmed) {
      await booking!.undoCheckIn().then((result) {
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
        } else {
          MaterialUtil.showSnackBar(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.BOOKING_UNDO_CHECKIN_SUCCESS,
                  [booking!.name!]));
        }
      });
    }
  }

  undoCheckOut() async {
    bool? isConfirmed = await MaterialUtil.showConfirm(
        context!,
        MessageUtil.getMessageByCode(
            MessageCodeUtil.CONFIRM_BOOKING_UNDO_CHECKOUT_AT_ROOM,
            [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));

    if (isConfirmed != null && isConfirmed) {
      await booking!.undoCheckout().then((result) {
        MaterialUtil.showResult(context!, MessageUtil.getMessageByCode(result));
      });
    }
  }

  discount() {
    showDialog(
        context: context!,
        builder: (context) => DiscountDialog(booking: booking!));
  }

  note() {
    showDialog(
        context: context!, builder: (context) => NoteDialog(booking: booking!));
  }

  updateTaxDeclare() {
    showDialog(
        context: context!,
        builder: (context) => UpdateTaxDeclareDialog(booking: booking!));
  }

  getLogBooking() {
    showDialog(
        context: context!,
        builder: (context) => LogBookingDialog(booking: booking!));
  }

  setNonRoom() async {
    await booking!.setNonRoom().then((result) {
      MaterialUtil.showResult(context!, MessageUtil.getMessageByCode(result));
    });
  }

  bool isAvailableOpen() {
    return booking!.status != BookingStatus.moved;
  }

  bool isAvailabApprover() {
    return booking!.status == BookingStatus.unconfirmed &&
        !UserManager.isPartnerAddBookingShowBooking();
  }

  bool isBookingGroup() {
    return booking!.group == true;
  }

  bool isAvailableCheckin() {
    if (!booking!.isVirtual! && !booking!.isEmpty!) {
      return booking!.status! == BookingStatus.booked;
    }
    return false;
  }

  bool isAvailableCheckout() {
    if (booking!.isVirtual!) {
      return booking!.status! == BookingStatus.booked;
    } else {
      if (!booking!.isEmpty!) return booking!.status! == BookingStatus.checkin;
    }
    return false;
  }

  bool isAvailablePayment() {
    if (booking!.isEmpty! &&
        booking!.status! != BookingStatus.repair &&
        booking!.status! != BookingStatus.moved) {
      return false;
    }
    return true;
  }

  bool isAvailableCostBooking() {
    if ((booking!.isEmpty! &&
            booking!.status! != BookingStatus.repair &&
            booking!.status! != BookingStatus.moved) ||
        !UserManager.canSeeAccounting()) {
      return false;
    }
    return true;
  }

  bool isAvailableService() {
    if (booking!.isEmpty! &&
        booking!.status! != BookingStatus.repair &&
        booking!.status! != BookingStatus.moved) {
      return false;
    }
    return true;
  }

  bool isAvailableSummary() {
    if ((booking!.isEmpty! || booking!.group!) &&
        booking!.status! != BookingStatus.repair &&
        booking!.status! != BookingStatus.moved) {
      return false;
    }
    return true;
  }

  bool isAvailableGroup() {
    return booking!.group! && booking!.status != BookingStatus.unconfirmed;
  }

  bool isAvailableCancel() {
    if (booking!.isVirtual!) {
      return booking!.status == BookingStatus.booked;
    } else {
      return (booking!.status == BookingStatus.unconfirmed ||
              (booking!.status == BookingStatus.booked &&
                  !UserManager.isPartnerAddBookingShowBooking() &&
                  !UserManager.isApprover())) &&
          !booking!.isEmpty!;
    }
  }

  bool isAvailableNoShow() =>
      booking!.status == BookingStatus.booked &&
      !booking!.isEmpty! &&
      !booking!.isVirtual!;

  bool isAvailableChangeRoom() {
    if (!booking!.isVirtual! && !booking!.isEmpty!) {
      return booking!.status == BookingStatus.checkin ||
          booking!.status == BookingStatus.booked;
    }
    return false;
  }

  bool isAvailableExtraBed() {
    if (!booking!.isVirtual! &&
        !booking!.isEmpty! &&
        booking!.status == BookingStatus.booked) {
      return true;
    }
    return false;
  }

  bool isAvailableUndoCheckin() {
    if (!booking!.isVirtual! && !booking!.isEmpty!) {
      return booking!.status == BookingStatus.checkin;
    }
    return false;
  }

  bool isAvailableUndoCheckout() {
    if (!booking!.isVirtual! &&
        !booking!.isEmpty! &&
        booking!.status == BookingStatus.checkout) {
      return true;
    }
    return false;
  }

  bool isAvailableDiscount() {
    if (booking!.isVirtual!) {
      return booking!.status == BookingStatus.booked;
    } else {
      if (!booking!.isEmpty! && !booking!.group!) {
        return booking!.status == BookingStatus.checkin ||
            booking!.status == BookingStatus.booked;
      }
    }
    return false;
  }

  bool isAvailableSetNonroom() {
    if (!booking!.isVirtual! && !booking!.isEmpty!) {
      return booking!.status == BookingStatus.booked;
    }
    return false;
  }

  bool isAvailableNote() {
    return (booking!.status == BookingStatus.unconfirmed ||
        (!booking!.isEmpty! && !UserManager.isPartnerAddBookingShowBooking()));
  }

  bool isAvailableDeclareTax() {
    if (!booking!.isVirtual! && !booking!.isEmpty!) {
      return booking!.status == BookingStatus.checkin ||
          booking!.status == BookingStatus.booked;
    }
    return false;
  }

  bool isAvailableLogBooking() => booking!.status != BookingStatus.moved;
}
