import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/ui/component/service/hotelservice/laundryhotelservicedialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class ListLaundriesHotelService extends StatefulWidget {
  const ListLaundriesHotelService({Key? key}) : super(key: key);

  @override
  State<ListLaundriesHotelService> createState() =>
      _ListLaundriesHotelServiceState();
}

class _ListLaundriesHotelServiceState extends State<ListLaundriesHotelService> {
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
          final Widget children = controller.laundries.isEmpty
              //have not config yet
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)),
                )
              : ListView(
                  children: controller.laundries.map((laundry) {
                  if ((controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ACTIVE) &&
                          laundry.isActive!) ||
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_DEACTIVE) &&
                          !laundry.isActive!) ||
                      controller.statusServiceFilter ==
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
                    return isMobile
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
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: NeutronTextContent(
                                          message: laundry.name!),
                                    ),
                                  ),
                                  Switch(
                                      value: laundry.isActive!,
                                      activeColor: ColorManagement.greenColor,
                                      inactiveTrackColor:
                                          ColorManagement.mainBackground,
                                      onChanged: (value) async {
                                        bool? confirm;
                                        String result = '';
                                        //false is deactivate, true is activate
                                        if (value == false) {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_DEACTIVE,
                                                      [laundry.name!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  laundry)
                                              .then((value) => value);
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [laundry.name!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  laundry)
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
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_ID),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                                message: laundry.id!),
                                          )
                                        ],
                                      ),
                                    ),
                                    //name
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_NAME),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                                tooltip: laundry.name,
                                                message: laundry.name!),
                                          )
                                        ],
                                      ),
                                    ),
                                    //piron
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_IRON_AMOUNT),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                              color:
                                                  ColorManagement.positiveText,
                                              message: NumberUtil.numberFormat
                                                  .format(laundry.piron),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    //plaundry
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_LAUNDRY_AMOUNT),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                              color:
                                                  ColorManagement.positiveText,
                                              message: NumberUtil.numberFormat
                                                  .format(laundry.plaundry),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    //button
                                    IconButton(
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  LaundryHotelServiceDialog(
                                                    laundryHotelService:
                                                        laundry,
                                                  ));
                                        },
                                        icon: const Icon(Icons.edit))
                                  ],
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: SizeManagement.cardHeight,
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
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
                                    message: laundry.id!,
                                  ),
                                )),
                                //name
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: NeutronTextContent(
                                        tooltip: laundry.name,
                                        message: laundry.name!,
                                      ),
                                    )),
                                //piron
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.end,
                                      color: ColorManagement.positiveText,
                                      message: NumberUtil.numberFormat
                                          .format(laundry.piron)),
                                )),
                                //plaundry
                                Expanded(
                                    child: NeutronTextContent(
                                  textAlign: TextAlign.end,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(laundry.plaundry),
                                )),
                                const SizedBox(width: 30),
                                //active-status
                                Container(
                                  width: 100,
                                  alignment: Alignment.center,
                                  child: Switch(
                                      value: laundry.isActive!,
                                      activeColor: ColorManagement.greenColor,
                                      inactiveTrackColor:
                                          ColorManagement.mainBackground,
                                      onChanged: (value) async {
                                        bool? confirm;
                                        String result;
                                        //false is deactivate, true is activate
                                        if (value == false) {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_DEACTIVE,
                                                      [laundry.name!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  laundry)
                                              .then((value) => value);
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [laundry.name!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  laundry)
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
                                        UITitleCode.TOOLTIP_EDIT),
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (ctx) =>
                                              LaundryHotelServiceDialog(
                                                laundryHotelService: laundry,
                                              ));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                  }
                  return Container();
                }).toList());

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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: NeutronTextTitle(
                                      fontSize: 14,
                                      textAlign: TextAlign.end,
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_IRON_AMOUNT),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    textAlign: TextAlign.end,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT),
                                  ),
                                ),
                                const SizedBox(width: 30),
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
                                const SizedBox(width: 60)
                              ],
                            ),
                          ),
                    //list
                    Expanded(child: children),
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
                      builder: (ctx) => LaundryHotelServiceDialog());
                },
              ),
            )
          ]);
        }));
  }
}
