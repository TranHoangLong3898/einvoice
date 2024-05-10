import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/hotel/addroomdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../util/materialutil.dart';
import '../../controls/neutrondropdown.dart';

class RoomDialog extends StatelessWidget {
  final String? roomTypeId;
  const RoomDialog({Key? key, this.roomTypeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider.value(
          value: RoomManager(),
          child: Consumer<RoomManager>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor));
              }

              final children = controller.roomFull!
                  .where((room) =>
                      roomTypeId == null || room.roomType == roomTypeId)
                  .map((room) {
                if ((controller.statusFilter ==
                            UITitleUtil.getTitleByCode(
                                UITitleCode.STATUS_ACTIVE) &&
                        !room.isDelete!) ||
                    (controller.statusFilter ==
                            UITitleUtil.getTitleByCode(
                                UITitleCode.STATUS_DEACTIVE) &&
                        room.isDelete!) ||
                    controller.statusFilter ==
                        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeManagement.borderRadius8),
                        color: ColorManagement.lightMainBackground),
                    margin: const EdgeInsets.symmetric(
                        vertical: SizeManagement.cardOutsideVerticalPadding,
                        horizontal:
                            SizeManagement.cardOutsideHorizontalPadding),
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManagement.cardInsideHorizontalPadding),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 55,
                          child: NeutronTextContent(message: room.id!),
                        ),
                        Expanded(
                            child: NeutronTextContent(
                          message: room.name!,
                        )),
                        IconButton(
                            constraints: const BoxConstraints(
                                minWidth: 40, maxWidth: 40),
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (ctx) => AddRoomDialog(
                                        room: room,
                                      ));
                            },
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            constraints: const BoxConstraints(
                                minWidth: 40, maxWidth: 40),
                            onPressed: () async {
                              final result = await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CONFIRM_DELETE_X, [
                                    RoomManager().getNameRoomById(room.id!)
                                  ]));
                              if (result == null || result == false) return;
                              controller.deleleRoom(room.id!).then((value) {
                                if (!value) {
                                  MaterialUtil.showAlert(
                                      context, controller.errorLog);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete))
                      ],
                    ),
                  );
                }
                return Container();
              }).toList();

              return Stack(children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 65),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        height: SizeManagement.cardHeight,
                        child: Row(children: [
                          SizedBox(
                            width: 55,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardInsideHorizontalPadding),
                              child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ID),
                              ),
                            ),
                          ),
                          Expanded(
                            child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_NAME),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 80,
                            child: NeutronDropDown(
                              textStyle: const TextStyle(
                                  color: ColorManagement.mainColorText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: FontManagement.fontFamily),
                              isCenter: true,
                              items: [
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ACTIVE),
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_DEACTIVE),
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ALL)
                              ],
                              value: controller.statusFilter,
                              onChanged: (value) {
                                controller.setStatusFilter(value);
                              },
                            ),
                          ),
                        ]),
                      ),
                      Expanded(
                          child: ListView(
                              children: children.isEmpty
                                  ? [
                                      Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: NeutronTextContent(
                                            message:
                                                MessageUtil.getMessageByCode(
                                                    MessageCodeUtil.NO_DATA)),
                                      )
                                    ]
                                  : children)),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NeutronButton(
                    icon1: Icons.add,
                    onPressed1: () async {
                      final result = await showDialog(
                          context: context,
                          builder: (ctx) => AddRoomDialog(
                                roomType: roomTypeId,
                              ));
                      if (result == null) return;
                    },
                  ),
                )
              ]);
            },
          ),
        ),
      ),
    );
  }
}
