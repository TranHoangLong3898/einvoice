import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/ui/component/hotel/roomtypedialog.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controller/currentbookingcontroller.dart';
import '../../manager/generalmanager.dart';
import '../../manager/roommanager.dart';
import '../../modal/booking.dart';
import 'cell.dart';

class StatusGrid extends StatelessWidget {
  final CurrentBookingsController controllerBooking;
  final RoomManager roomManager = RoomManager();

  StatusGrid({Key? key, required this.controllerBooking}) : super(key: key) {
    roomManager.currentBookingsController = controllerBooking;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: roomManager,
      child: Consumer<RoomManager>(builder: (_, controller, __) {
        if (controller.rooms!.isEmpty &&
            ConfigurationManagement().isFirstLoadingDone) {
          return createAlert(context);
        }
        return Row(
          children: [
            //Left column: Display roomtypes and rooms of each type
            RoomNameColumn(roomManager: controller),
            //Right column: Display status of bookings which are corresponding with each room
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (controller.getRoomsPlus().map((room) {
                  if (room.isType!) {
                    // return ChangeNotifierProvider.value(
                    //   value: DailyAllotmentStatic(),
                    //   child: Consumer<DailyAllotmentStatic>(
                    //     builder: (_, __, ___) {
                    return Row(
                      children: List.generate(
                        GeneralManager.numDates,
                        (index) => RoomTypeCell(
                            roomTypeID: room.id!,
                            date: controllerBooking.currentDate!
                                .add(Duration(days: index))),
                      ).toList(),
                      // );
                      // },
                      // ),
                    );
                  } else {
                    //Blank cell in Status board
                    return GeneralManager.showAllotment
                        ? Row(
                            children: List.generate(
                                GeneralManager.numDates,
                                (index) => BlankCell(
                                    booking: Booking.empty(
                                        room: room.id,
                                        sourceID: SourceManager.directSource,
                                        roomTypeID: room.roomType,
                                        inDate: controllerBooking.currentDate!
                                            .add(Duration(
                                                days: index))))).toList(),
                          )
                        : const SizedBox();
                  }
                })).toList()),
          ],
        );
      }),
    );
  }

  Widget createAlert(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 20),
              children: [
                TextSpan(
                    text: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_PLEASE)),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await showDialog(
                          context: context,
                          builder: (context) => RoomTypeDialog());
                    },
                  text: MessageUtil.getMessageByCode(
                          MessageCodeUtil.TEXTALERT_TO_CREATE_ROOMTYPE_AND_ROOM)
                      .toLowerCase(),
                  style: const TextStyle(
                      color: ColorManagement.redColor, fontSize: 20),
                ),
                TextSpan(
                    text: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_FOR_HOTEL_TO_USE)),
                TextSpan(
                    text: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_YOU_CAN)),
                TextSpan(
                  text:
                      ' ${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLICK_HERE)} ',
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: ColorManagement.redColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      launchUrlString(
                          'https://www.youtube.com/watch?v=3diC6Qy1cBI',
                          mode: LaunchMode.externalApplication);
                    },
                ),
                TextSpan(
                    text: MessageUtil.getMessageByCode(MessageCodeUtil
                        .TEXTALERT_FOR_INSTRUCTION_VIDEO_DETAIL)),
              ]),
        ),
      );
}

class RoomNameColumn extends StatelessWidget {
  const RoomNameColumn({Key? key, required this.roomManager}) : super(key: key);

  final RoomManager roomManager;

  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider.value(
    //   value: RoomManager(),
    //   child: Consumer<RoomManager>(builder: (_, roomManager, __) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: GeneralManager.showAllotment
            ? (roomManager.getRoomsPlus().map((room) {
                return RoomNameCell(room: room);
              }).toList())
            : (roomManager
                .getRoomsPlus()
                .where((element) => element.isType!)
                .map((room) {
                return RoomNameCell(room: room);
              }).toList()));
    // }),
    // );
  }
}
