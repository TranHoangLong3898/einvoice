import 'package:flutter/material.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/ui/component/warehouse/warehousedetaildialog.dart';
import 'package:ihotel/ui/component/warehouse/warehousedialog.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:provider/provider.dart';

import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutrontextcontent.dart';

class ListWarehouseDialog extends StatefulWidget {
  const ListWarehouseDialog({Key? key}) : super(key: key);

  @override
  State<ListWarehouseDialog> createState() => _ListWarehouseDialogState();
}

class _ListWarehouseDialogState extends State<ListWarehouseDialog> {
  @override
  Widget build(BuildContext context) {
    final isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return ChangeNotifierProvider<WarehouseManager>.value(
        value: WarehouseManager(),
        child: Consumer<WarehouseManager>(builder: (_, controller, __) {
          if (controller.isInProgress) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }
          final Widget children = ListView(
              children: controller.warehouses
                  .where((warehouse) =>
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ACTIVE) &&
                          warehouse.isActive!) ||
                      (controller.statusServiceFilter ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_DEACTIVE) &&
                          !warehouse.isActive!) ||
                      controller.statusServiceFilter ==
                          UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL))
                  .map((warehouse) {
            return isNotDesktop
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(SizeManagement.borderRadius8),
                        color: ColorManagement.lightMainBackground),
                    margin: const EdgeInsets.symmetric(
                        vertical: SizeManagement.cardOutsideVerticalPadding,
                        horizontal:
                            SizeManagement.cardOutsideHorizontalPadding),
                    child: ExpansionTile(
                      iconColor: ColorManagement.mainColorText,
                      collapsedIconColor: ColorManagement.mainColorText,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      title: Row(
                        children: [
                          Expanded(
                              child:
                                  NeutronTextContent(message: warehouse.name!)),
                          Switch(
                              value: warehouse.isActive!,
                              activeColor: ColorManagement.greenColor,
                              inactiveTrackColor:
                                  ColorManagement.mainBackground,
                              onChanged: (bool value) async {
                                //false is deactivate, true is activate
                                bool? confirm = await MaterialUtil.showConfirm(
                                    context,
                                    MessageUtil.getMessageByCode(
                                        value
                                            ? MessageCodeUtil.CONFIRM_ACTIVE
                                            : warehouse.items!.isEmpty
                                                ? MessageCodeUtil
                                                    .CONFIRM_DEACTIVE
                                                : MessageCodeUtil
                                                    .CONFIRM_DEACTIVE_STILL_HAVE_ITEMS,
                                        [warehouse.name!]));
                                if (confirm == null || confirm == false) {
                                  return;
                                }
                                String result = await controller
                                    .toggleActivation(warehouse)
                                    .then((value) => value);
                                // ignore: use_build_context_synchronously
                                MaterialUtil.showResult(context,
                                    MessageUtil.getMessageByCode(result));
                              }),
                        ],
                      ),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DataTable(
                              horizontalMargin:
                                  SizeManagement.cardOutsideHorizontalPadding,
                              headingRowHeight: 0,
                              columnSpacing: 4,
                              columns: const [
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('')),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ID))),
                                  DataCell(NeutronTextContent(
                                      message: warehouse.id!)),
                                ]),
                                DataRow(cells: [
                                  DataCell(NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME))),
                                  DataCell(NeutronTextContent(
                                    message: warehouse.name!,
                                    tooltip: warehouse.name,
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Center(
                                    child: IconButton(
                                      tooltip: UITitleUtil.getTitleByCode(
                                          UITitleCode.TOOLTIP_SEE_DETAIL),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                WarehouseDetailDialog(
                                                    warehouse: warehouse));
                                      },
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        color:
                                            ColorManagement.iconMenuEnableColor,
                                      ),
                                    ),
                                  )),
                                  DataCell(Center(
                                    child: IconButton(
                                      tooltip: UITitleUtil.getTitleByCode(
                                          UITitleCode.TOOLTIP_EDIT),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                WarehouseDialog(
                                                    warehouse: warehouse));
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color:
                                            ColorManagement.iconMenuEnableColor,
                                      ),
                                    ),
                                  )),
                                ])
                              ]),
                        ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              WarehouseDetailDialog(warehouse: warehouse));
                    },
                    child: Container(
                      height: SizeManagement.cardHeight,
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
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
                              child:
                                  NeutronTextContent(message: warehouse.id!)),
                          //name
                          Expanded(
                              flex: 2,
                              child: NeutronTextContent(
                                tooltip: warehouse.name,
                                message: warehouse.name!,
                              )),
                          const SizedBox(width: 8),
                          //active-status
                          Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Switch(
                                value: warehouse.isActive!,
                                activeColor: ColorManagement.greenColor,
                                inactiveTrackColor:
                                    ColorManagement.mainBackground,
                                onChanged: (value) async {
                                  //false is deactivate, true is activate
                                  bool? confirm =
                                      await MaterialUtil.showConfirm(
                                          context,
                                          MessageUtil.getMessageByCode(
                                              value
                                                  ? MessageCodeUtil
                                                      .CONFIRM_ACTIVE
                                                  : warehouse.items!.isEmpty
                                                      ? MessageCodeUtil
                                                          .CONFIRM_DEACTIVE
                                                      : MessageCodeUtil
                                                          .CONFIRM_DEACTIVE_STILL_HAVE_ITEMS,
                                              [warehouse.name!]));
                                  if (confirm == null || confirm == false) {
                                    return;
                                  }
                                  String result = await controller
                                      .toggleActivation(warehouse)
                                      .then((value) => value);
                                  // ignore: use_build_context_synchronously
                                  MaterialUtil.showResult(context,
                                      MessageUtil.getMessageByCode(result));
                                }),
                          ),
                          //edit-button
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_EDIT),
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        WarehouseDialog(warehouse: warehouse));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          }).toList());

          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                child: controller.warehouses.isEmpty
                    ? Center(
                        child: NeutronTextContent(
                            message: MessageUtil.getMessageByCode(
                                MessageCodeUtil.NO_DATA)))
                    : Column(
                        children: [
                          //title
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            padding: const EdgeInsets.symmetric(
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            height: SizeManagement.cardHeight,
                            child: Row(
                              children: [
                                if (!isNotDesktop)
                                  Expanded(
                                    child: NeutronTextTitle(
                                      fontSize: 14,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ID),
                                    ),
                                  ),
                                Expanded(
                                  flex: 2,
                                  child: NeutronTextTitle(
                                    fontSize: 14,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                    alignment: Alignment.center,
                                    width: 100,
                                    child: NeutronDropDown(
                                      textStyle: StyleManagement.title,
                                      isCenter: true,
                                      items: [
                                        UITitleUtil.getTitleByCode(
                                            UITitleCode.STATUS_ACTIVE),
                                        UITitleUtil.getTitleByCode(
                                            UITitleCode.STATUS_DEACTIVE),
                                        UITitleUtil.getTitleByCode(
                                            UITitleCode.STATUS_ALL)
                                      ],
                                      value: controller.statusServiceFilter,
                                      onChanged: (value) {
                                        controller.setStatusFilter(value);
                                      },
                                    )),
                                const SizedBox(width: 40)
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
                  showDialog(
                      context: context,
                      builder: (context) => WarehouseDialog());
                },
              ),
            ),
          ]);
        }));
  }
}
