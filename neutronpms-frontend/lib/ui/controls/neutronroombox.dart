// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/modal/roomtype.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../controller/housekeeping/housekeepingcontroller.dart';
import '../../manager/bookingmanager.dart';
import '../../manager/roomtypemanager.dart';
import '../../modal/booking.dart';
import '../../modal/room.dart';
import '../../ui/component/service/laundryform.dart';
import '../../ui/component/service/minibarform.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';

class NeutronRoomBox extends StatefulWidget {
  final Room room;
  final HouseKeepingPageController controller;

  const NeutronRoomBox({
    Key? key,
    required this.room,
    required this.controller,
  }) : super(key: key);

  @override
  State<NeutronRoomBox> createState() => _NeutronRoomBoxState();
}

class _NeutronRoomBoxState extends State<NeutronRoomBox> {
  String? bookingID, bookingInfo, inBed, bed, roomType, lastCleanTime;
  late int extraBed;
  late bool checkOut, checkIn, isClean, isRepair, isLoading, isVacantOvernight;
  late RoomType roomtype;
  late List<PopupMenuEntry<String>> kRoomBoxContextMenu;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  void getData() {
    bookingID = widget.room.bookingID;
    bookingInfo = widget.room.bookingInfo;
    inBed = widget.controller.getBed(widget.room.id!);
    extraBed = widget.controller.getExtraBed(widget.room.id!);
    bed = widget.room.bed!;
    checkOut = widget.controller.isOutToday(widget.room.id!) &&
        bookingID != null &&
        bookingInfo != null;
    checkIn = widget.controller.isInToday(widget.room.id!) ? true : false;
    roomType = widget.room.roomType;
    isClean = widget.room.isClean!;
    isRepair = widget.controller.isRepair(widget.room.id!);
    isVacantOvernight = widget.room.vacantOvernight!;
    roomtype = RoomTypeManager().getBedsOfRoomType(roomType!)!;
    kRoomBoxContextMenu = <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        height: 35,
        textStyle: const TextStyle(color: Colors.white),
        value: 'set clean',
        child: Text(isClean
            ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_DIRTY)
            : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLEAN)),
      ),
      const PopupMenuItem<String>(
        height: 35,
        textStyle: TextStyle(color: Colors.white),
        value: 'note',
        child: Text("Note"),
      ),
      if (isVacantOvernight)
        PopupMenuItem<String>(
          height: 35,
          textStyle: const TextStyle(color: Colors.white),
          value: 'vacant overnight',
          child: Text(
              MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLEAN)),
        ),
      if (roomtype.beds!.length > 1)
        ...RoomTypeManager()
            .getBedsOfRoomType(roomType!)!
            .beds!
            .map((bed) => PopupMenuItem<String>(
                  height: 35,
                  textStyle: const TextStyle(color: Colors.white),
                  value: bed,
                  child: Text(SystemManagement().getBedNameById(bed)),
                ))
            .toList(),
      if (bookingID != null) ...[
        PopupMenuItem<String>(
          height: 35,
          textStyle: const TextStyle(color: Colors.white),
          value: 'minibar',
          child: Text(
              MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_MINIBAR)),
        ),
        PopupMenuItem<String>(
          height: 35,
          textStyle: const TextStyle(color: Colors.white),
          value: 'laundry',
          child: Text(
              MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_LAUNDRY)),
        )
      ],
    ];
    lastCleanTime = widget.room.lastClean == null
        ? 'N/A'
        : DateUtil.dateToDayMonthHourMinuteString(widget.room.lastClean!);
  }

  @override
  Widget build(BuildContext context) {
    getData();

    return PopupMenuButton(
      color: ColorManagement.mainBackground,
      tooltip: widget.room.note,
      itemBuilder: (BuildContext context) => kRoomBoxContextMenu,
      onSelected: onSelectOption,
      child: Container(
        alignment: Alignment.center,
        height: 100,
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isLoading
              ? ColorManagement.transparentBackground
              : isVacantOvernight
                  ? ColorManagement.vacantOvernightRoomCellBackground
                  : isClean
                      ? ColorManagement.cleanRoomCellBackground
                      : ColorManagement.redColor,
        ),
        child: isLoading
            ? loadingWidget
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  icons,
                  typeBedAndRoomName,
                  inDateAndOutDateInfo,
                  extraBedInfo,
                  lastCleanInfo,
                ],
              ),
      ),
    );
  }

  Widget get loadingWidget =>
      const CircularProgressIndicator(color: ColorManagement.greenColor);

  Row get icons => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (checkOut)
            const Icon(Icons.flight_takeoff,
                size: 20, color: Color(0xFFF5C441)),
          if (bookingID != null && bookingID!.isNotEmpty)
            const Icon(Icons.hotel, size: 20),
          if (checkIn) const Icon(Icons.flight_land, size: 20),
          if (isRepair) const Icon(Icons.build, size: 20, color: Colors.black)
        ],
      );

  Row get typeBedAndRoomName => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //bed
          Container(
            alignment: Alignment.center,
            width: SizeManagement.smallCircle,
            height: SizeManagement.smallCircle,
            decoration: const BoxDecoration(
              color: ColorManagement.bedSmallCircleBackGround,
            ),
            child: Text(
              bed!.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 2),
            ),
          ),
          //room name
          Container(
            constraints: const BoxConstraints(minWidth: 90, maxWidth: 90),
            child: Row(
              children: [
                NeutronTextContent(
                  message: RoomManager().getNameRoomById(widget.room.id!),
                  tooltip: RoomManager().getNameRoomById(widget.room.id!),
                  color: Colors.white,
                ),
                if (widget.room.note!.isNotEmpty)
                  const Icon(Icons.document_scanner_sharp,
                      size: 10, color: Color(0xFFF5C441)),
              ],
            ),
          ),
        ],
      );

  Text get inDateAndOutDateInfo {
    return Text(
        (inBed == null || bookingInfo != null
                ? ''
                : '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_BED)} (${inBed?.substring(0, 1).toUpperCase()})') +
            (bookingInfo ?? ''),
        style: const TextStyle(fontSize: 12));
  }

  Text get extraBedInfo => Text(
      extraBed == 0
          ? ''
          : '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_EXTRA_BED)}: $extraBed',
      style: const TextStyle(fontSize: 12));

  Text get lastCleanInfo => Text(
      '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_LAST_CLEAN)}: $lastCleanTime',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12));

  void updateLoadingStatus(bool newStatus) {
    if (newStatus == isLoading) {
      return;
    }
    setState(() {
      isLoading = newStatus;
    });
  }

  void onSelectOption(value) async {
    switch (value) {
      case 'note':
        await showDialog<String>(
            context: context,
            builder: (context) =>
                NoteDialog(controller: widget.controller, room: widget.room));
        break;
      case 'set clean':
        updateLoadingStatus(true);
        String result = await widget.room
            .updateClean(!isClean, isVacantOvernight)
            .then((value) {
          updateLoadingStatus(false);
          return value;
        });
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
        }
        break;
      case 'vacant overnight':
        updateLoadingStatus(true);
        String result = await widget.room
            .updateVacantOvernight(!isVacantOvernight)
            .then((value) {
          updateLoadingStatus(false);
          return value;
        });
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
        }
        break;
      case 'minibar':
        if (bookingID != null) {
          Booking? booking =
              await BookingManager().getBasicBookingByID(bookingID!);

          await showDialog<String>(
              context: context,
              builder: (context) => Dialog(
                  backgroundColor: ColorManagement.mainBackground,
                  child: SizedBox(
                      width: ResponsiveUtil.isMobile(context)
                          ? kMobileWidth
                          : kWidth,
                      child: MinibarForm(booking: booking!))));
        } else {
          MaterialUtil.showAlert(context,
              MessageUtil.getMessageByCode(MessageCodeUtil.NO_GUEST_IN_ROOM));
        }
        break;
      case "laundry":
        if (bookingID != null) {
          Booking? booking =
              await BookingManager().getBasicBookingByID(bookingID!);

          await showDialog<String>(
              context: context,
              builder: (context) => Dialog(
                  backgroundColor: ColorManagement.mainBackground,
                  child: SizedBox(
                      width: ResponsiveUtil.isMobile(context)
                          ? kMobileWidth
                          : kWidth,
                      child: LaundryForm(booking: booking!))));
        } else {
          MaterialUtil.showAlert(context,
              MessageUtil.getMessageByCode(MessageCodeUtil.NO_GUEST_IN_ROOM));
        }
        break;
      default:
        updateLoadingStatus(true);
        String result = await widget.room.updateBed(value).then((value) {
          updateLoadingStatus(false);
          return value;
        });
        if (result != MessageCodeUtil.SUCCESS) {
          MaterialUtil.showAlert(context, MessageUtil.getMessageByCode(result));
        }
    }
  }
}

class NoteDialog extends StatefulWidget {
  final Room room;
  final HouseKeepingPageController controller;
  const NoteDialog({Key? key, required this.room, required this.controller})
      : super(key: key);

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late TextEditingController teNote;

  @override
  void initState() {
    teNote = TextEditingController(text: widget.room.note ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                    vertical: SizeManagement.topHeaderTextSpacing),
                child: NeutronTextHeader(
                  message: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
                )),
            Padding(
              padding: const EdgeInsets.only(
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding,
                  top: SizeManagement.rowSpacing),
              child: NeutronTextFormField(
                paddingVertical: 16,
                label: UITitleUtil.getTitleByCode(UITitleCode.HINT_NOTES),
                isDecor: true,
                maxLine: 3,
                controller: teNote,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
              child: NeutronButton(
                icon: Icons.save,
                onPressed: () async {
                  final result = await widget.controller
                      .saveNotes(widget.room, teNote.text);
                  if (result ==
                      MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
                    MaterialUtil.showSnackBar(context, result);
                    Navigator.pop(context);
                  } else {
                    MaterialUtil.showAlert(context, result);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
