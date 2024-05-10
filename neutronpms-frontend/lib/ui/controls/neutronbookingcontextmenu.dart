import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/service/costform.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../manager/bookingmanager.dart';
import '../../manager/roommanager.dart';
import '../../manager/usermanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../ui/component/booking/bookingdialog.dart';
import '../../ui/component/booking/changeroomdialog.dart';
import '../../ui/component/booking/depositdialog.dart';
import '../../ui/component/booking/discountdialog.dart';
import '../../ui/component/booking/notedialog.dart';
import '../../ui/component/booking/setextrabeddialog.dart';
import '../../ui/component/extraservice/virtualbookingmanagementdialog.dart';
import '../../util/contextmenuutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../component/booking/checkoutdialog.dart';
import '../component/booking/logbookingdialog.dart';
import '../component/booking_group/groupdialog.dart';
import '../component/service/servicedialog.dart';

class NeutronBookingContextMenu extends StatelessWidget {
  final Widget? child;
  final String? tooltip;
  final Booking? booking;
  final Color? backgroundColor;
  final IconData? icon;
  final bool? isStatus;
  final bool? isGroup;

  const NeutronBookingContextMenu({
    Key? key,
    this.child,
    this.tooltip,
    this.booking,
    this.backgroundColor = ColorManagement.lightMainBackground,
    this.icon,
    this.isStatus = true,
    this.isGroup = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        icon ?? Icons.more_vert,
        color: ColorManagement.white,
      ),
      color: backgroundColor,
      tooltip: tooltip,
      onSelected: (String selection) async {
        if (booking!.isEmpty! &&
            (booking!.id == booking!.sID || booking!.group!)) {
          await BookingManager().getBookingGroupByID(booking!.sID!).then(
              (bookingData) async => handleSelection(
                  bookingData,
                  context,
                  selection,
                  await BookingManager().getBasicBookingByID(booking!.id!)));
        } else {
          await BookingManager()
              .getBookingByID(booking!.group! ? booking!.sID! : booking!.id!)
              .then((bookingData) async {
            booking!.isEmpty! ? bookingData : bookingData = booking;
            handleSelection(bookingData!, context, selection,
                await BookingManager().getBasicBookingByID(booking!.id!));
          });
        }
      },
      itemBuilder: (BuildContext context) {
        if (booking!.isVirtual!) {
          if (booking!.status == BookingStatus.booked) {
            return ContextMenuUtil().kBookedVirtualContextMenu();
          } else if (booking!.status == BookingStatus.checkout) {
            return ContextMenuUtil().kCheckOutVirtualContextMenu();
          } else {
            return [ContextMenuUtil().menuOpen];
          }
        } else {
          if (booking!.isEmpty!) {
            return ContextMenuUtil().kSimpleContextMenu(
                booking!.id == booking!.sID || booking!.group!);
          } else {
            if (UserManager.isPartnerAndApprover() &&
                !UserManager.canSeeStatusPageNotPartnerAndApprover()) {
              if (UserManager.isPartnerAddBookingShowBooking() &&
                  booking!.status == BookingStatus.unconfirmed) {
                return ContextMenuUtil()
                    .kBookedPartnerContextMenu(booking!.group!);
              }
              if (UserManager.isApprover() &&
                  booking!.status == BookingStatus.unconfirmed) {
                return ContextMenuUtil()
                    .kBookedApproverContextMenu(booking!.group!);
              }
              return ContextMenuUtil()
                  .kBookedPartnerContextMenu(booking!.group!);
            } else {
              if (booking!.status == BookingStatus.checkin) {
                if (booking!.id == booking!.sID) {
                  return ContextMenuUtil()
                      .kCheckinContextMenu(true, booking!.group!);
                }
                return ContextMenuUtil()
                    .kCheckinContextMenu(false, booking!.group!);
              } else if (booking!.status == BookingStatus.checkout) {
                if (booking!.id == booking!.sID || booking!.group!) {
                  return ContextMenuUtil().kCheckoutContextMenu(true, isGroup!);
                }
                return ContextMenuUtil().kCheckoutContextMenu(false, isGroup!);
              } else if (booking!.status == BookingStatus.cancel ||
                  booking!.status == BookingStatus.noshow) {
                return ContextMenuUtil().kCancelContextMenu(
                    booking!.sID == booking!.id, booking!.group!);
              }
              if (booking!.id == booking!.sID) {
                return ContextMenuUtil().kBookedContextMenu(
                    true,
                    booking!.group!,
                    booking!.status == BookingStatus.unconfirmed);
              }
              return ContextMenuUtil().kBookedContextMenu(
                  false,
                  booking!.group!,
                  booking!.status == BookingStatus.unconfirmed);
            }
          }
        }
      },
      child: child,
    );
  }

  void handleSelection(Booking bookingData, BuildContext context,
      String selection, Booking? basicBookings) async {
    if (selection == "Open") {
      await showDialog<String>(
              builder: (ctx) => bookingData.isVirtual!
                  ? VirtualBookingDialog(booking: bookingData)
                  : BookingDialog(booking: bookingData),
              context: context)
          .then((result) {
        if (result == null) return;

        MaterialUtil.showSnackBar(context, result);
      });
    } else if (selection == "Confirm booking") {
      await booking!.updateStatus(booking!).then((result) {
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
        } else {
          MaterialUtil.showSnackBar(
              context, MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS));
        }
      });
    } else if (selection == "Check in") {
      await bookingData.checkIn().then((result) {
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(
              context, MessageUtil.getMessageByCode(result, [booking!.name!]));
        } else {
          MaterialUtil.showSnackBar(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.BOOKING_CHECKIN_SUCCESS, [booking!.name!]));
        }
      }).onError((error, stackTrace) {
        error;
      });
    } else if (selection == "Check out") {
      if (bookingData.group!) {
        bool? isConfirmed = await MaterialUtil.showConfirm(
            context,
            MessageUtil.getMessageByCode(
                MessageCodeUtil.CONFIRM_BOOKING_CHECKOUT, [
              '${RoomManager().getNameRoomById(bookingData.room!)} - ${bookingData.name}'
            ]));
        if (isConfirmed != null && isConfirmed) {
          await bookingData.checkOut().then((result) {
            if (result == MessageCodeUtil.SUCCESS) {
              MaterialUtil.showSnackBar(
                  context,
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.BOOKING_CHECKOUT_SUCCESS,
                      [bookingData.name!]));
            } else {
              MaterialUtil.showAlert(context,
                  MessageUtil.getMessageByCode(result, [bookingData.name!]));
            }
          });
        }
      } else {
        await showDialog<String>(
                builder: (ctx) => CheckOutDialog(
                    booking: bookingData, basicBookings: basicBookings),
                context: context)
            .then((result) {
          if (result != null) {
            MaterialUtil.showSnackBar(context, result);
          }
        });
      }
    } else if (selection == "Cancel") {
      bool? isConfirmed = await MaterialUtil.showConfirm(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.CONFIRM_BOOKING_CANCEL_AT_ROOM, [
            bookingData.name!,
            RoomManager().getNameRoomById(bookingData.room!)
          ]));

      if (isConfirmed != null && isConfirmed) {
        bookingData.isVirtual!
            ? await bookingData.cancelVirtual().then((result) {
                if (result == MessageCodeUtil.SUCCESS) {
                  MaterialUtil.showSnackBar(
                      context,
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.BOOKING_CANCEL_SUCCESS,
                          [bookingData.name!]));
                } else {
                  MaterialUtil.showAlert(
                      context, MessageUtil.getMessageByCode(result));
                }
              }).onError((error, stackTrace) {
                error;
              })
            : await bookingData.cancel().then((result) {
                if (result == MessageCodeUtil.SUCCESS) {
                  MaterialUtil.showSnackBar(
                      context,
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.BOOKING_CANCEL_SUCCESS,
                          [bookingData.name!]));
                } else {
                  MaterialUtil.showAlert(
                      context, MessageUtil.getMessageByCode(result));
                }
              }).onError((error, stackTrace) {
                error;
              });
      }
    } else if (selection == "No show") {
      bool? isConfirmed = await MaterialUtil.showConfirm(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.CONFIRM_BOOKING_NO_SHOW_AT_ROOM,
              [booking!.name!, RoomManager().getNameRoomById(booking!.room!)]));
      if (isConfirmed != null && isConfirmed) {
        await bookingData.noShow().then((result) {
          if (result == MessageCodeUtil.SUCCESS) {
            MaterialUtil.showSnackBar(
                context,
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.BOOKING_CANCEL_SUCCESS,
                    [bookingData.name!]));
          } else {
            MaterialUtil.showAlert(
                context, MessageUtil.getMessageByCode(result));
          }
        }).onError((error, stackTrace) {
          error;
        });
      }
    } else if (selection == "Cost") {
      await showDialog<String>(
          builder: (ctx) => CostBookingDialog(
                booking: bookingData,
              ),
          context: context);
    } else if (selection == "Service") {
      await showDialog<String>(
          builder: (ctx) => ServiceDialog(
                booking: bookingData,
              ),
          context: context);
    } else if (selection == "Deposit") {
      await showDialog<String>(
          builder: (ctx) => DepositDialog(
                booking: bookingData,
              ),
          context: context);
    } else if (selection == "Group") {
      await showDialog<String>(
          builder: (ctx) =>
              GroupDialog(booking: bookingData, isStatus: isStatus!),
          context: context);
    } else if (selection == "Change room") {
      showDialog<String>(
          builder: (ctx) => ChangeRoomDialog(
                booking: bookingData,
              ),
          context: context);
    } else if (selection == "Extra bed") {
      await showDialog<String>(
          builder: (ctx) => SetExtraBedDialog(
                booking: bookingData,
              ),
          context: context);
    } else if (selection == "Undo check-in") {
      bool? isConfirmed = await MaterialUtil.showConfirm(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.CONFIRM_BOOKING_UNDO_CHECKIN_AT_ROOM, [
            bookingData.name!,
            RoomManager().getNameRoomById(bookingData.room!)
          ]));

      if (isConfirmed != null && isConfirmed) {
        await bookingData.undoCheckIn().then((result) {
          if (result != MessageCodeUtil.SUCCESS) {
            MaterialUtil.showAlert(
                context, MessageUtil.getMessageByCode(result));
          } else {
            MaterialUtil.showSnackBar(
                context,
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.BOOKING_UNDO_CHECKIN_SUCCESS,
                    [booking!.name!]));
          }
        }).onError((error, stackTrace) {
          error;
        });
      }
    } else if (selection == "Discount") {
      showDialog(
          context: context,
          builder: (context) => DiscountDialog(booking: bookingData));
    } else if (selection == "Notes") {
      showDialog(
          context: context,
          builder: (context) => NoteDialog(booking: bookingData));
    } else if (selection == "Set non room") {
      await booking!.setNonRoom().then((result) {
        MaterialUtil.showResult(context, MessageUtil.getMessageByCode(result));
      });
    } else if (selection == "Declare") {
      showDialog(
          context: context,
          builder: (context) => BookingDialog(
                booking: bookingData,
                initialTab: 2,
              ));
    } else if (selection == "Log activities") {
      showDialog(
          context: context,
          builder: (context) => LogBookingDialog(booking: booking!));
    }
  }
}
