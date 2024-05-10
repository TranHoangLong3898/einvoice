import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/ui/component/service/hotelservice/otherhotelservicedialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class ListOtherHotelServiceDialog extends StatefulWidget {
  const ListOtherHotelServiceDialog({Key? key}) : super(key: key);

  @override
  State<ListOtherHotelServiceDialog> createState() =>
      _ListOtherHotelServiceState();
}

class _ListOtherHotelServiceState extends State<ListOtherHotelServiceDialog> {
  late ConfigurationManagement controller;

  @override
  void initState() {
    controller = ConfigurationManagement();
    controller.statusServiceFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider<ConfigurationManagement>.value(
        value: controller,
        child: Consumer<ConfigurationManagement>(builder: (_, controller, __) {
          if (controller.isInProgress) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }
          // UI desktop
          final children = !isMobile
              ? controller.others.map((otherService) {
                  if ((controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ACTIVE) &&
                          otherService.isActive!) ||
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_DEACTIVE) &&
                          !otherService.isActive!) ||
                      controller.statusServiceFilter ==
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    return Container(
                      height: SizeManagement.cardHeight,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.cardOutsideVerticalPadding,
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      decoration: BoxDecoration(
                          color: ColorManagement.lightMainBackground,
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8)),
                      child: Row(
                        children: [
                          //id
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: NeutronTextContent(
                              message: otherService.id!,
                            ),
                          )),
                          //name
                          Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: NeutronTextContent(
                                  tooltip: otherService.name,
                                  message: otherService.name!,
                                ),
                              )),

                          //active-status
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Switch(
                                value: otherService.isActive!,
                                activeColor: ColorManagement.greenColor,
                                inactiveTrackColor:
                                    ColorManagement.mainBackground,
                                onChanged: (value) async {
                                  if (otherService.id ==
                                      ServiceManager.BIKE_RENTAL_CAT) {
                                    MaterialUtil.showAlert(
                                        ctx,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .BIKE_RENTAL_CAN_NOT_DEACTIVE));
                                    return;
                                  }
                                  bool? confirm;
                                  String result;
                                  //false is deactivate, true is activate
                                  if (value == false) {
                                    confirm = await MaterialUtil.showConfirm(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CONFIRM_DEACTIVE,
                                            [otherService.name!]));
                                    if (confirm == null || confirm == false) {
                                      return;
                                    }
                                    result = await controller
                                        .toggleHotelServiceActivation(
                                            otherService)
                                        .then((value) => value);
                                  } else {
                                    confirm = await MaterialUtil.showConfirm(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CONFIRM_ACTIVE,
                                            [otherService.name!]));
                                    if (confirm == null || confirm == false) {
                                      return;
                                    }
                                    result = await controller
                                        .toggleHotelServiceActivation(
                                            otherService)
                                        .then((value) => value);
                                  }
                                  if (mounted) {
                                    MaterialUtil.showResult(ctx, result);
                                  }
                                }),
                          ),
                          //edit-button
                          SizedBox(
                            width: 60,
                            child: IconButton(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.POPUPMENU_EDIT),
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await showDialog(
                                    context: context,
                                    builder: (ctx) => OtherHotelServiceDialog(
                                          otherHotelService: otherService,
                                        ));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }).toList()
              // UI mobile
              : controller.others.map((otherService) {
                  if ((controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ACTIVE) &&
                          otherService.isActive!) ||
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_DEACTIVE) &&
                          !otherService.isActive!) ||
                      controller.statusServiceFilter ==
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8),
                          color: ColorManagement.lightMainBackground),
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.cardOutsideVerticalPadding,
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: NeutronTextContent(
                                    message: otherService.name!),
                              ),
                            ),
                            Switch(
                                value: otherService.isActive!,
                                activeColor: ColorManagement.greenColor,
                                inactiveTrackColor:
                                    ColorManagement.mainBackground,
                                onChanged: (value) async {
                                  if (otherService.id ==
                                      ServiceManager.BIKE_RENTAL_CAT) {
                                    MaterialUtil.showAlert(
                                        ctx,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .BIKE_RENTAL_CAN_NOT_DEACTIVE));
                                    return;
                                  }
                                  bool? confirm;
                                  String result;
                                  //false is deactivate, true is activate
                                  if (value == false) {
                                    confirm = await MaterialUtil.showConfirm(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CONFIRM_DEACTIVE,
                                            [otherService.name!]));
                                    if (confirm == null || confirm == false) {
                                      return;
                                    }
                                    result = await controller
                                        .toggleHotelServiceActivation(
                                            otherService)
                                        .then((value) => value);
                                  } else {
                                    confirm = await MaterialUtil.showConfirm(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CONFIRM_ACTIVE,
                                            [otherService.name!]));
                                    if (confirm == null || confirm == false) {
                                      return;
                                    }
                                    result = await controller
                                        .toggleHotelServiceActivation(
                                            otherService)
                                        .then((value) => value);
                                  }
                                  if (mounted) {
                                    MaterialUtil.showResult(ctx, result);
                                  }
                                }),
                          ],
                        ),
                        children: [
                          Column(
                            children: [
                              //id
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ID),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          message: otherService.id!),
                                    )
                                  ],
                                ),
                              ),
                              //name
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          tooltip: otherService.name,
                                          message: otherService.name!),
                                    )
                                  ],
                                ),
                              ),
                              //button
                              Row(
                                children: [
                                  //edit-button
                                  Expanded(
                                    child: IconButton(
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  OtherHotelServiceDialog(
                                                    otherHotelService:
                                                        otherService,
                                                  ));
                                        },
                                        icon: const Icon(Icons.edit)),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }
                  return Container();
                }).toList();
          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    //title in Mobile
                    isMobile
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                    fontSize: 14,
                                  ),
                                )),
                                SizedBox(
                                    width: 150,
                                    child: NeutronDropDown(
                                      textStyle: const TextStyle(
                                          color: ColorManagement.mainColorText,
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
                                      value: controller.statusServiceFilter!,
                                      onChanged: (value) {
                                        controller.setStatusFilter(value);
                                      },
                                    )),
                              ],
                            ),
                          )
                        //title in PC
                        : Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            height: SizeManagement.cardHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    isPadding: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ID),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    isPadding: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.center,
                                    width: 100,
                                    child: NeutronDropDown(
                                      textStyle: const TextStyle(
                                          color: ColorManagement.mainColorText,
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
                                      value: controller.statusServiceFilter!,
                                      onChanged: (value) {
                                        controller.setStatusFilter(value);
                                      },
                                    )),
                                const SizedBox(
                                  width: 60,
                                )
                              ],
                            ),
                          ),
                    //list
                    Expanded(
                        child: ListView(
                      children: children,
                    )),
                  ],
                )),
            //add-button
            Align(
              alignment: Alignment.bottomCenter,
              child: NeutronButton(
                icon1: Icons.add,
                onPressed1: () async {
                  await showDialog(
                      context: context,
                      builder: (ctx) => OtherHotelServiceDialog());
                },
              ),
            )
          ]);
        }));
  }
}
