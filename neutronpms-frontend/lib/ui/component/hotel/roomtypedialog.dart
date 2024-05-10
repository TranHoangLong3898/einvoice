import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/ui/component/hotel/addroomdialog.dart';
import 'package:ihotel/ui/component/hotel/addroomtypedialog.dart';
import 'package:ihotel/ui/component/hotel/roomdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../modal/room.dart';
import '../../controls/neutrondropdown.dart';

class RoomTypeDialog extends StatelessWidget {
  final RoomTypeManager roomTypeManager = RoomTypeManager();
  final RoomManager roomManager = RoomManager();
  RoomTypeDialog({Key? key}) : super(key: key) {
    roomTypeManager.statusFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
    roomManager.statusFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kLargeWidth;
    }
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: width,
          height: height,
          child: Scaffold(
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              title: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.SIDEBAR_ROOMTYPE_ROOM)),
              backgroundColor: ColorManagement.mainBackground,
            ),
            body: ChangeNotifierProvider<RoomTypeManager>.value(
                value: RoomTypeManager(),
                child: Consumer<RoomTypeManager>(
                    builder: (_, roomTypeController, __) {
                  if (roomTypeController.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor));
                  }
                  final children =
                      roomTypeController.fullRoomTypes.map((roomtype) {
                    if ((roomTypeController.statusFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ACTIVE) &&
                            !roomtype!.isDelete!) ||
                        (roomTypeController.statusFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_DEACTIVE) &&
                            roomtype!.isDelete!) ||
                        roomTypeController.statusFilter ==
                            UITitleUtil.getTitleByCode(
                                UITitleCode.STATUS_ALL)) {
                      return isMobile
                          //UI on mobile
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground),
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardInsideHorizontalPadding),
                                title: Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                      child: NeutronTextContent(
                                          message: roomtype!.id!),
                                    ),
                                    Expanded(
                                      child: NeutronTextContent(
                                          tooltip: roomtype.name,
                                          message: roomtype.name!),
                                    ),
                                    IconButton(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_LIST_ROOM),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) => RoomDialog(
                                                    roomTypeId: roomtype.id,
                                                  ));
                                        },
                                        icon: const Icon(Icons.list))
                                  ],
                                ),
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 15, right: 15, top: 15),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextContent(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PRICE),
                                            )),
                                            Expanded(
                                                flex: 2,
                                                child: NeutronTextContent(
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(roomtype.price),
                                                  color: ColorManagement
                                                      .positiveText,
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 15, right: 15, top: 15),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextContent(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_GUEST),
                                            )),
                                            Expanded(
                                                flex: 2,
                                                child: NeutronTextContent(
                                                  message:
                                                      roomtype.guest.toString(),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(15),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextContent(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_BED),
                                            )),
                                            Expanded(
                                              flex: 2,
                                              child: NeutronTextContent(
                                                tooltip: roomtype.beds!
                                                    .map((bed) =>
                                                        SystemManagement()
                                                            .getBedNameById(
                                                                bed))
                                                    .toString(),
                                                message: roomtype.beds!
                                                    .map((bed) =>
                                                        SystemManagement()
                                                            .getBedNameById(
                                                                bed))
                                                    .toString(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      roomtype.isDelete!
                                          ? Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: SizeManagement
                                                          .rowSpacing),
                                              alignment: Alignment.center,
                                              child: NeutronTextContent(
                                                message: MessageUtil
                                                    .getMessageByCode(
                                                        MessageCodeUtil
                                                            .TEXTALERT_DELETED),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                    tooltip: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TOOLTIP_ADD_ROOM),
                                                    onPressed: () async {
                                                      await showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              AddRoomDialog(
                                                                roomType:
                                                                    roomtype.id,
                                                              ));
                                                    },
                                                    icon:
                                                        const Icon(Icons.add)),
                                                IconButton(
                                                    tooltip: UITitleUtil
                                                        .getTitleByCode(
                                                            UITitleCode
                                                                .TOOLTIP_EDIT),
                                                    onPressed: () async {
                                                      await showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              AddRoomTypeDialog(
                                                                roomType:
                                                                    roomtype,
                                                              ));
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit)),
                                                IconButton(
                                                    tooltip: UITitleUtil
                                                        .getTitleByCode(
                                                            UITitleCode
                                                                .TOOLTIP_DELETE),
                                                    onPressed: () async {
                                                      final result = await MaterialUtil
                                                          .showConfirm(
                                                              context,
                                                              MessageUtil.getMessageByCode(
                                                                  MessageCodeUtil
                                                                      .CONFIRM_DELETE_X,
                                                                  [
                                                                    RoomTypeManager()
                                                                        .getRoomTypeNameByID(
                                                                            roomtype.id!)
                                                                  ]));
                                                      if (result == null ||
                                                          result == false) {
                                                        return;
                                                      }
                                                      roomTypeController
                                                          .deleteRoomType(
                                                              roomtype.id!)
                                                          .then((value) {
                                                        if (!value) {
                                                          MaterialUtil.showAlert(
                                                              context,
                                                              roomTypeController
                                                                  .errorLog);
                                                        }
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.delete)),
                                              ],
                                            ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          //UI on web
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              decoration: BoxDecoration(
                                  color: ColorManagement.lightMainBackground,
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8)),
                              child: ExpansionTile(
                                iconColor: ColorManagement.mainColorText,
                                collapsedIconColor:
                                    ColorManagement.mainColorText,
                                tilePadding: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardInsideHorizontalPadding),
                                //info of roomtype
                                title: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: roomtype!.id!,
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                      tooltip: roomtype.name,
                                      message: roomtype.name!,
                                    )),
                                    Expanded(
                                        child: Center(
                                      child: NeutronTextContent(
                                        message: '${roomtype.guest}',
                                      ),
                                    )),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(right: 30),
                                      child: NeutronTextContent(
                                        message: NumberUtil.numberFormat
                                            .format(roomtype.price),
                                        color: ColorManagement.positiveText,
                                        textAlign: TextAlign.end,
                                      ),
                                    )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextContent(
                                          // textAlign: TextAlign.end,
                                          tooltip: roomtype.beds!
                                              .map((bed) => SystemManagement()
                                                  .getBedNameById(bed))
                                              .toString(),
                                          message: roomtype.beds!
                                              .map((bed) => SystemManagement()
                                                  .getBedNameById(bed))
                                              .toString(),
                                        )),
                                    if (roomtype.isDelete!)
                                      Container(
                                        width: 120,
                                        alignment: Alignment.center,
                                        child: NeutronTextContent(
                                            message:
                                                MessageUtil.getMessageByCode(
                                                    MessageCodeUtil
                                                        .TEXTALERT_DELETED)),
                                      ),
                                    //add room for this room type
                                    if (!roomtype.isDelete!)
                                      IconButton(
                                        constraints: const BoxConstraints(
                                            minWidth: 40, maxWidth: 40),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_ADD_ROOM),
                                        icon: const Icon(Icons.add),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) => AddRoomDialog(
                                                    roomType: roomtype.id,
                                                  ));
                                        },
                                      ),
                                    //edit button for edit info of this roomtype
                                    if (!roomtype.isDelete!)
                                      IconButton(
                                        constraints: const BoxConstraints(
                                            minWidth: 40, maxWidth: 40),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_EDIT),
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  AddRoomTypeDialog(
                                                    roomType: roomtype,
                                                  ));
                                        },
                                      ),
                                    //delete button for deactive this roomtype
                                    if (!roomtype.isDelete!)
                                      IconButton(
                                        constraints: const BoxConstraints(
                                            minWidth: 40, maxWidth: 40),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_DELETE),
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          final result =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_DELETE_X,
                                                      [
                                                        RoomTypeManager()
                                                            .getRoomTypeNameByID(
                                                                roomtype.id!)
                                                      ]));
                                          if (result == null ||
                                              result == false) {
                                            return;
                                          }
                                          roomTypeController
                                              .deleteRoomType(roomtype.id!)
                                              .then((value) {
                                            if (!value) {
                                              MaterialUtil.showAlert(context,
                                                  roomTypeController.errorLog);
                                            }
                                          });
                                        },
                                      )
                                  ],
                                ),
                                //list rooms of this roomtype
                                children: [
                                  ChangeNotifierProvider<RoomManager>.value(
                                    value: roomManager,
                                    child: Consumer<RoomManager>(
                                        builder: (_, roomController, __) {
                                      if (roomController.isLoading) {
                                        return const CircularProgressIndicator(
                                            color: ColorManagement.greenColor);
                                      }
                                      Iterable<Room> roomsOfRoomType =
                                          roomController.roomFull!
                                              .where((room) {
                                        if (room.roomType != roomtype.id) {
                                          return false;
                                        }
                                        return (roomController.statusFilter ==
                                                    UITitleUtil.getTitleByCode(
                                                        UITitleCode
                                                            .STATUS_ACTIVE) &&
                                                !room.isDelete!) ||
                                            (roomController.statusFilter ==
                                                    UITitleUtil.getTitleByCode(
                                                        UITitleCode
                                                            .STATUS_DEACTIVE) &&
                                                room.isDelete!) ||
                                            roomController.statusFilter ==
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode.STATUS_ALL);
                                      });
                                      return SizedBox(
                                        width: kWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            DataTable(
                                              columns: [
                                                DataColumn(
                                                  label: NeutronTextTitle(
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_ROOM_ID),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: NeutronTextTitle(
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_NAME),
                                                  ),
                                                ),
                                                DataColumn(
                                                  label: Container(
                                                    alignment: Alignment.center,
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 100,
                                                            minWidth: 100),
                                                    child: NeutronDropDown(
                                                      textStyle: const TextStyle(
                                                          color: ColorManagement
                                                              .mainColorText,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily:
                                                              FontManagement
                                                                  .fontFamily),
                                                      isCenter: true,
                                                      items: [
                                                        UITitleUtil.getTitleByCode(
                                                            UITitleCode
                                                                .STATUS_ACTIVE),
                                                        UITitleUtil.getTitleByCode(
                                                            UITitleCode
                                                                .STATUS_DEACTIVE),
                                                        UITitleUtil
                                                            .getTitleByCode(
                                                                UITitleCode
                                                                    .STATUS_ALL)
                                                      ],
                                                      value: roomController
                                                          .statusFilter,
                                                      onChanged: (value) {
                                                        roomController
                                                            .setStatusFilter(
                                                                value);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              rows: roomsOfRoomType
                                                  .map((room) => DataRow(
                                                        cells: [
                                                          DataCell(Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: SizeManagement
                                                                    .cardInsideHorizontalPadding),
                                                            child:
                                                                NeutronTextContent(
                                                              message: room.id!,
                                                            ),
                                                          )),
                                                          DataCell(
                                                              NeutronTextContent(
                                                            message: room.name!,
                                                          )),
                                                          DataCell(Container(
                                                            alignment: Alignment
                                                                .center,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        100,
                                                                    minWidth:
                                                                        100),
                                                            child: room
                                                                    .isDelete!
                                                                ? NeutronTextContent(
                                                                    message: MessageUtil.getMessageByCode(
                                                                        MessageCodeUtil
                                                                            .TEXTALERT_DELETED))
                                                                : Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      IconButton(
                                                                        constraints: const BoxConstraints(
                                                                            maxWidth:
                                                                                40,
                                                                            minWidth:
                                                                                40),
                                                                        icon: const Icon(
                                                                            Icons.edit),
                                                                        onPressed:
                                                                            () async {
                                                                          final result = await showDialog(
                                                                              context: context,
                                                                              builder: (ctx) => AddRoomDialog(
                                                                                    room: room,
                                                                                  ));
                                                                          if (result ==
                                                                              null) {
                                                                            return;
                                                                          }
                                                                        },
                                                                      ),
                                                                      IconButton(
                                                                        constraints: const BoxConstraints(
                                                                            maxWidth:
                                                                                40,
                                                                            minWidth:
                                                                                40),
                                                                        icon: const Icon(
                                                                            Icons.delete),
                                                                        onPressed:
                                                                            () async {
                                                                          final result = await MaterialUtil.showConfirm(
                                                                              context,
                                                                              MessageUtil.getMessageByCode(MessageCodeUtil.CONFIRM_DELETE_X, [
                                                                                RoomManager().getNameRoomById(room.id!)
                                                                              ]));
                                                                          if (result == null ||
                                                                              result == false) {
                                                                            return;
                                                                          }
                                                                          roomController
                                                                              .deleleRoom(room.id!)
                                                                              .then((value) {
                                                                            if (!value) {
                                                                              MaterialUtil.showAlert(context, roomController.errorLog);
                                                                            }
                                                                          });
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                          ))
                                                        ],
                                                      ))
                                                  .toList(),
                                            ),
                                            if (roomsOfRoomType.isEmpty)
                                              Container(
                                                alignment: Alignment.center,
                                                height: 30,
                                                child: NeutronTextContent(
                                                    message: MessageUtil
                                                        .getMessageByCode(
                                                            MessageCodeUtil
                                                                .NO_ROOM)),
                                              )
                                          ],
                                        ),
                                      );
                                    }),
                                  )
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
                                  horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding +
                                      SizeManagement
                                          .cardInsideHorizontalPadding),
                              height: SizeManagement.cardHeight,
                              child: !isMobile
                                  //title in web
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_R_TYPE_ID),
                                          ),
                                        ),
                                        Expanded(
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_NAME),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: NeutronTextTitle(
                                              isPadding: false,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_GUEST),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 30),
                                            child: NeutronTextTitle(
                                              textAlign: TextAlign.end,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PRICE),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_BED),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: 120,
                                          child: NeutronDropDown(
                                            textStyle: const TextStyle(
                                                color: ColorManagement
                                                    .mainColorText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                fontFamily:
                                                    FontManagement.fontFamily),
                                            isCenter: true,
                                            items: [
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_DEACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ALL)
                                            ],
                                            value: roomTypeController
                                                .statusFilter!,
                                            onChanged: (value) {
                                              roomTypeController
                                                  .setStatusFilter(value);
                                            },
                                          ),
                                        ),
                                        //size of trailing of expansionTile
                                        const SizedBox(width: 34),
                                      ],
                                    )
                                  //title in mobile
                                  : Row(
                                      children: [
                                        SizedBox(
                                          width: 55,
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_ID),
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
                                          width: 100,
                                          child: NeutronDropDown(
                                            textStyle: const TextStyle(
                                                color: ColorManagement
                                                    .mainColorText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                fontFamily:
                                                    FontManagement.fontFamily),
                                            isCenter: true,
                                            items: [
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_DEACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ALL)
                                            ],
                                            value: roomTypeController
                                                .statusFilter!,
                                            onChanged: (value) {
                                              roomTypeController
                                                  .setStatusFilter(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Expanded(
                                child: ListView(
                              children: children,
                            ))
                          ],
                        )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: NeutronButton(
                        icon1: Icons.add,
                        tooltip1: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_ADD_ROOMTYPE),
                        onPressed1: () async {
                          await showDialog(
                              context: context,
                              builder: (ctx) => const AddRoomTypeDialog());
                        },
                      ),
                    )
                  ]);
                })),
          )),
    );
  }
}
