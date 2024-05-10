import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/ui/component/service/hotelservice/bikehotelservicedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/bikepriceconfiguation.dart';
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

import '../../../../manager/servicemanager.dart';
import '../../../../manager/suppliermanager.dart';

class ListBikeHotelService extends StatefulWidget {
  const ListBikeHotelService({Key? key}) : super(key: key);

  @override
  State<ListBikeHotelService> createState() => _ListBikeHotelServiceState();
}

class _ListBikeHotelServiceState extends State<ListBikeHotelService> {
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
          if (controller.bikeConfigs['auto'] == null ||
              controller.bikeConfigs['manual'] == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeutronTextContent(
                    textAlign: TextAlign.center,
                    message: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_NEED_TO_CONFIG_X_FIRST, [
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL)
                    ])),
                const SizedBox(height: SizeManagement.rowSpacing),
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => BikePriceConfigurationDialog());
                  },
                  child: NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_CLICK_HERE,
                    ),
                    color: ColorManagement.redColor,
                  ),
                )
              ],
            );
          }
          if (controller.isInProgress) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }
          // UI desktop
          final Widget children = controller.bikes.isEmpty
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)),
                )
              : ListView(
                  children: controller.bikes.map((bike) {
                  if ((controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ACTIVE) &&
                          bike.isActive!) ||
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_DEACTIVE) &&
                          !bike.isActive!) ||
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
                                      child:
                                          NeutronTextContent(message: bike.id!),
                                    ),
                                  ),
                                  Switch(
                                      value: bike.isActive!,
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
                                                      [bike.id!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  bike)
                                              .then((value) => value);
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [bike.id!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  bike)
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
                                                message: bike.id!),
                                          )
                                        ],
                                      ),
                                    ),
                                    //type
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_TYPE),
                                          )),
                                          Expanded(
                                              child: NeutronTextContent(
                                                  message: MessageUtil
                                                      .getMessageByCode(
                                                          bike.bikeType)))
                                        ],
                                      ),
                                    ),
                                    //supplier
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_SUPPLIER),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                                tooltip: SupplierManager()
                                                    .getSupplierNameByID(
                                                        bike.supplierId!),
                                                message: SupplierManager()
                                                    .getSupplierNameByID(
                                                        bike.supplierId!)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //price
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_PRICE),
                                          )),
                                          Expanded(
                                            child: NeutronTextContent(
                                              color:
                                                  ColorManagement.positiveText,
                                              message: NumberUtil.numberFormat
                                                  .format(bike.price),
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
                                                  BikeHotelServiceDialog(
                                                    bikeHotelService: bike,
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
                                    message: bike.id!,
                                  ),
                                )),
                                //type
                                Expanded(
                                    child: NeutronTextContent(
                                  message: MessageUtil.getMessageByCode(
                                      bike.bikeType),
                                )),
                                //type
                                Expanded(
                                    child: NeutronTextContent(
                                  message: SupplierManager()
                                      .getSupplierNameByID(bike.supplierId!),
                                )),
                                //price
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.end,
                                      color: ColorManagement.positiveText,
                                      message: NumberUtil.numberFormat
                                          .format(bike.price)),
                                )),
                                const SizedBox(width: 10),
                                //active-status
                                Container(
                                  width: 100,
                                  alignment: Alignment.center,
                                  child: Switch(
                                      value: bike.isActive!,
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
                                                      [bike.id!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  bike)
                                              .then((value) => value);
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [bike.id!]));
                                          if (confirm == null ||
                                              confirm == false) return;
                                          result = await controller
                                              .toggleHotelServiceActivation(
                                                  bike)
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
                                              BikeHotelServiceDialog(
                                                bikeHotelService: bike,
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
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TYPE),
                                  ),
                                ),
                                Expanded(
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_SUPPLIER),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: NeutronTextTitle(
                                      textAlign: TextAlign.end,
                                      fontSize: 14,
                                      isPadding: true,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                                Container(
                                  width: 60,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    alignment: Alignment.center,
                                    icon:
                                        const Icon(Icons.settings_applications),
                                    tooltip: UITitleUtil.getTitleByCode(UITitleCode
                                        .TOOLTIP_CONFIGURATION_BIKE_DEFAULT_PRICE),
                                    onPressed: () async {
                                      bool? result = await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              BikePriceConfigurationDialog());
                                      if (mounted && result != null && result) {
                                        MaterialUtil.showSnackBar(
                                            context,
                                            MessageUtil.getMessageByCode(
                                                MessageCodeUtil.SUCCESS));
                                      }
                                    },
                                  ),
                                ),
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
                  if (SupplierManager()
                      .getActiveSupplierNamesByService(
                          ServiceManager.BIKE_RENTAL_CAT)
                      .isEmpty) {
                    MaterialUtil.showAlert(
                        context,
                        MessageUtil.getMessageByCode(MessageCodeUtil
                            .NEED_TO_ADD_BIKE_RENTAL_TO_SUPPLIER_FIRST));
                    return;
                  }
                  await showDialog(
                      context: context,
                      builder: (ctx) => BikeHotelServiceDialog());
                },
              ),
            )
          ]);
        }));
  }
}
