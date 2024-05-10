import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/changeroomcontroller.dart';
import '../../../manager/roomtypemanager.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class ChangeRoomDialog extends StatelessWidget {
  final Booking? booking;

  const ChangeRoomDialog({Key? key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        margin: const EdgeInsets.all(10),
        width: kMobileWidth,
        height: 40,
        child: ChangeNotifierProvider.value(
          value: ChangeRoomController(booking!),
          child: Consumer<ChangeRoomController>(builder: (_, controller, __) {
            if (controller.changing) {
              return const Center(
                  child: CircularProgressIndicator(
                color: ColorManagement.greenColor,
              ));
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 3,
                  child: NeutronDropDown(
                      value: RoomTypeManager()
                          .getRoomTypeNameByID(controller.roomTypeID),
                      onChanged: (String newRoomTypeName) async {
                        controller.setRoomTypeID(RoomTypeManager()
                            .getRoomTypeIDByName(newRoomTypeName));
                      },
                      items: RoomTypeManager().getRoomTypeNamesActived()),
                ),
                Expanded(
                  flex: 2,
                  child: NeutronDropDown(
                      value: RoomManager().getNameRoomById(controller.room),
                      onChanged: (String newNameRoom) {
                        controller.setRoom(
                            RoomManager().getIdRoomByName(newNameRoom));
                      },
                      items: controller.rooms),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 50,
                  child: ElevatedButton(
                      child: const Icon(Icons.save, color: Colors.white),
                      onPressed: () async {
                        final result = await controller.changeRoom();
                        if (result ==
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.SUCCESS)) {
                          // ignore: use_build_context_synchronously
                          MaterialUtil.showSnackBar(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.BOOKING_CHANGE_TO_ROOM, [
                                controller.booking.name!,
                                RoomManager().getNameRoomById(controller.room)
                              ]));
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          // ignore: use_build_context_synchronously
                          MaterialUtil.showAlert(context, result);
                        }
                      }),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
