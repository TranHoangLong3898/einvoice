// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/changeroomcontroller.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/grid/bookingnonroomcell.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../manager/generalmanager.dart';
import '../../manager/usermanager.dart';
import '../../modal/booking.dart';
import '../../modal/coordinate.dart';
import '../../modal/room.dart';
import '../../modal/status.dart';
import '../../ui/component/booking/bookingdialog.dart';
import '../../ui/component/booking/repairdialog.dart';
import '../../util/contextmenuutil.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../component/booking/neutronbookingbottommenu.dart';
import '../component/costroomdialog.dart';
import '../component/summaryroomdialog.dart';

class BlankCell extends StatelessWidget {
  final Booking booking;

  const BlankCell({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: const EdgeInsets.all(0),
      color: ColorManagement.mainBackground,
      tooltip: '',
      onSelected: (String selection) async {
        if (selection == "Add booking") {
          String? result = await showDialog<String>(
              builder: (ctx) => BookingDialog(
                    booking: booking,
                  ),
              context: context);
          if (result != null) {
            MaterialUtil.showSnackBar(context, result);
          }
        } else if (selection == "Add repair") {
          String? result = await showDialog<String>(
              builder: (ctx) => RepairDialog(
                    booking: booking,
                  ),
              context: context);
          if (result == null) return;

          MaterialUtil.showSnackBar(context, result);
        }
      },
      itemBuilder: (BuildContext context) =>
          ContextMenuUtil().kEmptyContextMenu(),
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: GeneralManager.cellWidth,
            height: GeneralManager.cellHeight,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: ColorManagement.emptyCellBackground,
              border: Border.all(width: 0.2, color: ColorManagement.borderCell),
            ),
          );
        },
        onWillAccept: null,
        onAccept: (data) async {
          Booking? draggableBooking = (data as Booking);
          final now = DateTime.now();
          DateTime now12h = DateUtil.to12h(now);
          //list rooms which have bookings in date range
          Map<String, dynamic> bookedRoomsInRangeAndPrice = {};
          if (draggableBooking.status == BookingStatus.checkin) {
            bookedRoomsInRangeAndPrice = await DailyAllotmentStatic()
                .getPriceAndBookedRooms(
                    now12h, draggableBooking.outDate!, booking.roomTypeID!);
          } else {
            bookedRoomsInRangeAndPrice = await DailyAllotmentStatic()
                .getPriceAndBookedRooms(draggableBooking.inDate!,
                    draggableBooking.outDate!, booking.roomTypeID!);
          }
          if ((bookedRoomsInRangeAndPrice['booked'] as List<String>)
              .contains(booking.room)) {
            MaterialUtil.showAlert(
                context,
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.BOOKING_CONFLIX_ROOM,
                    [RoomManager().getNameRoomById(booking.room!)]));
            return;
          }
          bool confirmToChange = false;
          await MaterialUtil.showConfirm(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.CONFIRM_BOOKING_CHANGE_ROOM, [
                RoomManager().getNameRoomById(draggableBooking.room!),
                RoomManager().getNameRoomById(booking.room!)
              ])).then((value) => confirmToChange = value!);
          if (!confirmToChange) return;
          ChangeRoomController changeRoomController =
              ChangeRoomController(draggableBooking);
          changeRoomController.room = booking.room!;
          changeRoomController.roomTypeID = booking.roomTypeID!;
          changeRoomController.inDate = booking.inDate!;
          changeRoomController.changeRoom().then(
                (value) => {MaterialUtil.showResult(context, value)},
              );
        },
      ),
    );
  }
}

class BookingCell extends StatelessWidget {
  final BuildContext scaffoldContext;
  final Coordinate coordinate;
  final Booking booking;

  const BookingCell(
      {Key? key,
      required this.booking,
      required this.coordinate,
      required this.scaffoldContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!GeneralManager.showAllotment) {
      return const SizedBox();
    }
    if (booking.status == BookingStatus.repair) {
      return Positioned(
        left: coordinate.left,
        top: coordinate.top,
        child: PopupMenuButton<String>(
          tooltip: '',
          color: ColorManagement.mainBackground,
          onSelected: (String selection) async {
            if (selection == "Open") {
              String? result = await showDialog<String>(
                  builder: (ctx) => RepairDialog(
                        booking: booking,
                      ),
                  context: context);
              if (result == null) return;

              MaterialUtil.showSnackBar(context, result);
            } else if (selection == "Delete repair") {
              String result = await booking
                  .deleteRepair()
                  .then((value) => value)
                  .onError((error, stackTrace) => error.toString());
              if (result == MessageCodeUtil.SUCCESS) {
                MaterialUtil.showSnackBar(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_DELETE_REPAIR_SUCCESS,
                        [booking.room!]));
              } else {
                MaterialUtil.showAlert(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.BOOKING_DELETE_REPAIR_FAIL));
              }
            }
          },
          itemBuilder: (BuildContext context) =>
              ContextMenuUtil().kRepairContextMenu(),
          child: _buildBookingObject(),
        ),
      );
    }
    if (booking.status == BookingStatus.moved) {
      return Positioned(
        left: coordinate.left,
        top: coordinate.top,
        child: Tooltip(
          waitDuration: const Duration(milliseconds: 500),
          message: booking.decodeName(),
          child: _buildBookingObject(),
        ),
      );
    }
    return Positioned(
      left: coordinate.left,
      top: coordinate.top,
      child: Tooltip(
        waitDuration: const Duration(milliseconds: 500),
        message: booking.decodeName()! +
            (booking.notes == null
                ? ''
                : booking.notes!.isEmpty
                    ? ""
                    : ' (${booking.notes})'),
        child: InkWell(
          onTap: () async {
            await BookingManager()
                .getBookingByID(booking.group! ? booking.sID! : booking.id!)
                .then((value) {
              if ((UserManager.user!.email == value!.creator ||
                      UserManager.user!.email == value.saler) &&
                  UserManager.isPartnerAddBookingShowBooking()) {
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return NeutronBookingBottomMenu(
                        scaffoldContext: scaffoldContext,
                        booking: booking,
                      );
                    });
              } else if (!UserManager.isPartnerAddBookingShowBooking()) {
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return NeutronBookingBottomMenu(
                        scaffoldContext: scaffoldContext,
                        booking: booking,
                      );
                    });
              }
            });
          },

          //draw drag&drop for booking
          child: booking.status == BookingStatus.booked ||
                  booking.status == BookingStatus.checkin ||
                  booking.status == BookingStatus.unconfirmed
              ? LongPressDraggable(
                  axis: booking.status == BookingStatus.checkin
                      ? Axis.vertical
                      : null,
                  data: booking,
                  //widget display at mouse point when dragging
                  feedback: _buildBookingObject(),
                  //widget display at primary position
                  childWhenDragging: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    child: Opacity(
                      opacity: 0.3,
                      child:
                          //Type of bed + Booking name
                          Row(
                        children: [
                          //Type of bed
                          Container(
                            alignment: Alignment.center,
                            width: GeneralManager.bedCellWidth,
                            height: GeneralManager.bookingCellHeight,
                            color: BookingStatus()
                                .getColorByStatus(booking.status!),
                          ),
                          //Booking name
                          Container(
                            alignment: Alignment.centerLeft,
                            width: GeneralManager.cellWidth -
                                GeneralManager.bedCellWidth -
                                6,
                            height: GeneralManager.bookingCellHeight,
                            padding: const EdgeInsets.only(left: 4),
                            color: BookingStatus()
                                .getColorByStatus(booking.status!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onDraggableCanceled: (velocity, offset) =>
                      MaterialUtil.showSnackBar(
                        scaffoldContext,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.INPUT_VALID_ROOM),
                      ),
                  child: _buildBookingObject())
              //can not drag
              : _buildBookingObject(),
        ),
      ),
    );
  }

  Widget _buildBookingObject() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Row(
        children: [
          //sign of bookings has tax_declare = true
          if (booking.isTaxDeclare!)
            Container(
              width: GeneralManager.taxDeclareSignWidth,
              height: GeneralManager.bookingCellHeight,
              color: ColorManagement.taxDeclareSignal,
            ),
          //Type of bed
          if (booking.status == BookingStatus.booked ||
              booking.status == BookingStatus.checkin ||
              booking.status == BookingStatus.unconfirmed)
            Container(
              alignment: Alignment.center,
              width: GeneralManager.bedCellWidth,
              height: GeneralManager.bookingCellHeight,
              color:
                  BookingStatus.getBedNameColorByStatus(booking.statusPayment),
              child: Text(
                booking.bed!.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: ColorManagement.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          //Booking name
          Container(
            alignment: Alignment.centerLeft,
            width: coordinate.length! -
                GeneralManager.bedCellWidth -
                4 -
                (booking.isTaxDeclare!
                    ? GeneralManager.taxDeclareSignWidth
                    : 0),
            height: GeneralManager.bookingCellHeight,
            padding: const EdgeInsets.only(left: 4),
            color: BookingStatus().getColorByStatus(booking.status!),
            child: Text(
              booking.decodeName()!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: BookingStatus.getBookingNameColorByStatus(
                      booking.status!),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
          ),
        ],
      ),
    );
  }
}

class DateCell extends StatelessWidget {
  final DateTime date;

  const DateCell({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DailyAllotmentStatic(),
      child: Consumer<DailyAllotmentStatic>(
        builder: (_, controllerDaily, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          alignment: Alignment.center,
          width: GeneralManager.cellWidth,
          height: GeneralManager.dateCellHeight,
          decoration: BoxDecoration(
            color: DateUtil.dateToString(date) ==
                    DateUtil.dateToString(Timestamp.now().toDate())
                ? ColorManagement.nowDateColor
                : ColorManagement.dateCellBackground,
            border: Border.all(width: 0.2, color: ColorManagement.borderCell),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 3.5, top: 3.5),
                    decoration: BoxDecoration(
                      color: ColorManagement.greenColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: NeutronTextContent(
                      color: Colors.white,
                      message: controllerDaily.getTotalRoomWithDate(date),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 3.5, top: 3.5),
                    decoration: BoxDecoration(
                      color: ColorManagement.orangeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (controllerDaily
                                .getTotalCurrentBookingNonRoomWithDate(date) ==
                            0) return;
                        showDialog(
                          context: context,
                          builder: (context) =>
                              BookingNonRoomCell(dateTime: date),
                        );
                      },
                      child: NeutronTextContent(
                        tooltip:
                            "${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_NON_ROOM_BOOKINGS)} - ${controllerDaily.getTotalCurrentBookingNonRoomWithDate(date)}",
                        color: Colors.white,
                        message: controllerDaily
                            .getTotalCurrentBookingNonRoomWithDate(date)
                            .toString(),
                      ),
                    ),
                  )
                ],
              ),
              NeutronTextContent(
                message: DateUtil.dateToString(date),
                color: DateUtil.dateToString(date) ==
                        DateUtil.dateToString(Timestamp.now().toDate())
                    ? ColorManagement.white
                    : ColorManagement.textBlack,
              ),
              NeutronTextContent(
                message: controllerDaily.getRankByDate(date),
                color: DateUtil.dateToString(date) ==
                        DateUtil.dateToString(Timestamp.now().toDate())
                    ? ColorManagement.white
                    : ColorManagement.textBlack,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.only(top: 3.5, bottom: 3.5),
                decoration: BoxDecoration(
                  color: ColorManagement.redColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: NeutronTextContent(
                  message: controllerDaily.getPeformanceWithDate(date),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomNameCell extends StatelessWidget {
  final Room room;

  const RoomNameCell({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      width: GeneralManager.cellWidth,
      height: room.isType!
          ? GeneralManager.roomTypeCellHeight
          : GeneralManager.cellHeight,
      decoration: BoxDecoration(
        color: ColorManagement.white,
        border: Border.all(width: 0.2, color: ColorManagement.borderCell),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //Type of bed
          if (room.bed?.isNotEmpty ?? false)
            Container(
              alignment: Alignment.center,
              width: GeneralManager.cellHeight * 0.65,
              height: GeneralManager.cellHeight * 0.65,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: room.vacantOvernight!
                    ? ColorManagement.vacantOvernightRoomCellBackground
                    : room.isClean!
                        ? ColorManagement.cleanRoomCellBackground
                        : ColorManagement.redColor,
              ),
              child: Text(
                room.bed!.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 10 + GeneralManager.cellHeight / 10),
              ),
            ),
          //Room name
          Expanded(
            child: PopupMenuButton<String>(
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REPORT),
              onSelected: (value) {
                if (value == "cost") {
                  showDialog(
                      context: context,
                      builder: (context) => CostRoomDialog(idRom: room.id!));
                } else if (value == "summary") {
                  showDialog(
                      context: context,
                      builder: (context) => SummaryRoomDialog(idRom: room.id!));
                }
              },
              offset: const Offset(50, 0),
              color: ColorManagement.mainBackground,
              splashRadius: SizeManagement.borderRadius8,
              itemBuilder: (BuildContext context) => room.isType!
                  ? <PopupMenuEntry<String>>[]
                  : !UserManager.canSeeAccounting()
                      ? <PopupMenuEntry<String>>[]
                      : <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                              value: "cost",
                              child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_COST_OF_ROOM),
                              )),
                          PopupMenuItem<String>(
                              value: "summary",
                              child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SUMMARY),
                              )),
                        ],
              child: NeutronTextContent(
                tooltip: room.isType!
                    ? RoomTypeManager()
                        .getRoomTypeNameByID(room.id!)
                        .toUpperCase()
                    : null,
                message: room.isType!
                    ? RoomTypeManager()
                        .getRoomTypeNameByID(room.id!)
                        .toUpperCase()
                    : room.name!.toUpperCase(),
                color: ColorManagement.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomTypeCell extends StatelessWidget {
  final DateTime date;
  final String roomTypeID;

  const RoomTypeCell({Key? key, required this.date, required this.roomTypeID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DailyAllotmentStatic(),
      child: Consumer<DailyAllotmentStatic>(
        builder: (_, controller, __) => Container(
          alignment: Alignment.center,
          width: GeneralManager.cellWidth,
          height: GeneralManager.roomTypeCellHeight,
          decoration: BoxDecoration(
            color: ColorManagement.emptyCellBackground,
            border: Border.all(width: 0.2, color: ColorManagement.borderCell),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: controller.getTotalRoomWithDateAndRoomType(
                          date, roomTypeID) >=
                      0
                  ? ColorManagement.roomLeftCellBackground
                  : ColorManagement.redColor,
            ),
            margin: const EdgeInsets.only(bottom: 2),
            width: GeneralManager.roomleftCellWidth,
            height: GeneralManager.roomleftCellHeight,
            alignment: Alignment.center,
            child: NeutronTextContent(
              color: Colors.white,
              message: controller
                  .getTotalRoomWithDateAndRoomType(date, roomTypeID)
                  .toString(),
            ),
          ),
        ),
      ),
    );
  }
}
