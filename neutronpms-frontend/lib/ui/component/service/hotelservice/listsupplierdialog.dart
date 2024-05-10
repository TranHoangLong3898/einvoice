import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/ui/component/service/hotelservice/supplierdialog.dart';
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

class ListSupplierDialog extends StatefulWidget {
  const ListSupplierDialog({Key? key}) : super(key: key);

  @override
  State<ListSupplierDialog> createState() => _ListSupplierDialogState();
}

class _ListSupplierDialogState extends State<ListSupplierDialog> {
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
    final double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: Scaffold(
          appBar: AppBar(
              title: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.SIDEBAR_SUPPLIER_SERVICE_MANAGEMENT))),
          backgroundColor: ColorManagement.mainBackground,
          body: ChangeNotifierProvider<ConfigurationManagement>.value(
              value: controller,
              child: Consumer<ConfigurationManagement>(
                  builder: (_, controller, __) {
                if (controller.isInProgress) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor));
                }
                // UI desktop
                final children = !isMobile
                    ? controller.suppliers.map((supplier) {
                        if ((controller.statusServiceFilter ==
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.STATUS_ACTIVE) &&
                                supplier['active']) ||
                            (controller.statusServiceFilter ==
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.STATUS_DEACTIVE) &&
                                !(supplier['active'] as bool)) ||
                            controller.statusServiceFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ALL)) {
                          return Container(
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
                                    message: supplier['id'],
                                  ),
                                )),
                                //name
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: NeutronTextContent(
                                        tooltip: supplier['name'],
                                        message: supplier['name'],
                                      ),
                                    )),
                                //services
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: NeutronTextContent(
                                        tooltip: (supplier['services'] as List)
                                            .fold(
                                                '',
                                                (previousValue, element) =>
                                                    '$previousValue${OtherManager().getServiceNameByID(element)}, '),
                                        message: (supplier['services'] as List)
                                            .fold(
                                                '',
                                                (previousValue, element) =>
                                                    '$previousValue${OtherManager().getServiceNameByID(element)}, '),
                                      ),
                                    )),
                                //active-status
                                Container(
                                  width: 100,
                                  alignment: Alignment.center,
                                  child: Switch(
                                      value: supplier['active'],
                                      activeColor: ColorManagement.greenColor,
                                      inactiveTrackColor:
                                          ColorManagement.mainBackground,
                                      onChanged: (value) async {
                                        if (supplier['id'] ==
                                            SupplierManager.inhouseSupplier) {
                                          MaterialUtil.showAlert(
                                              context,
                                              MessageUtil.getMessageByCode(
                                                  MessageCodeUtil
                                                      .CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER));
                                          return;
                                        }
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
                                                      [supplier['name']]));
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [supplier['name']]));
                                        }
                                        if (confirm == null ||
                                            confirm == false) {
                                          return;
                                        }
                                        result = await controller
                                            .toggleSupplierActivation(supplier)
                                            .then((value) => value);
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
                                          builder: (ctx) => SupplierDialog(
                                                supplier: supplier,
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
                    : controller.suppliers.map((supplier) {
                        if ((controller.statusServiceFilter ==
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.STATUS_ACTIVE) &&
                                supplier['active']) ||
                            (controller.statusServiceFilter ==
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.STATUS_DEACTIVE) &&
                                !(supplier['active'] as bool)) ||
                            controller.statusServiceFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ALL)) {
                          return Container(
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
                                          message: supplier['name']),
                                    ),
                                  ),
                                  Switch(
                                      value: supplier['active'],
                                      activeColor: ColorManagement.greenColor,
                                      inactiveTrackColor:
                                          ColorManagement.mainBackground,
                                      onChanged: (value) async {
                                        if (supplier['id'] ==
                                            SupplierManager.inhouseSupplier) {
                                          MaterialUtil.showAlert(
                                              context,
                                              MessageUtil.getMessageByCode(
                                                  MessageCodeUtil
                                                      .CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER));
                                          return;
                                        }
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
                                                      [supplier['name']]));
                                        } else {
                                          confirm =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_ACTIVE,
                                                      [supplier['name']]));
                                        }
                                        if (confirm == null ||
                                            confirm == false) {
                                          return;
                                        }
                                        result = await controller
                                            .toggleSupplierActivation(supplier)
                                            .then((value) => value);
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
                                                message: supplier['id']),
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
                                                tooltip: supplier['name'],
                                                message: supplier['name']),
                                          )
                                        ],
                                      ),
                                    ),
                                    //services
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_SERVICE),
                                          )),
                                          Expanded(
                                              child: NeutronTextContent(
                                            tooltip: (supplier['services']
                                                    as List)
                                                .fold(
                                                    '',
                                                    (previousValue, element) =>
                                                        '$previousValue${OtherManager().getServiceNameByID(element)}, '),
                                            message: (supplier['services']
                                                    as List)
                                                .fold(
                                                    '',
                                                    (previousValue, element) =>
                                                        '$previousValue${OtherManager().getServiceNameByID(element)}, '),
                                          ))
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
                                                        SupplierDialog(
                                                          supplier: supplier,
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
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: NeutronTextTitle(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.HINT_NAME),
                                          fontSize: 14,
                                        ),
                                      )),
                                      SizedBox(
                                          width: 150,
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
                                            value:
                                                controller.statusServiceFilter!,
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
                                      //id
                                      Expanded(
                                        child: NeutronTextTitle(
                                          fontSize: 14,
                                          isPadding: true,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_ID),
                                        ),
                                      ),
                                      //name
                                      Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          fontSize: 14,
                                          isPadding: true,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_NAME),
                                        ),
                                      ),
                                      //services-array
                                      Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          fontSize: 14,
                                          isPadding: true,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_SERVICE),
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
                                            value:
                                                controller.statusServiceFilter!,
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
                            builder: (ctx) => const SupplierDialog());
                      },
                    ),
                  )
                ]);
              })),
        ),
      ),
    );
  }
}
