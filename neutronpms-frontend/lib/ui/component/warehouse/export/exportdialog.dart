import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/controller/warehouse/exportcontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/warehouse/warehouseexport/warehousenoteexport.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/generalmanager.dart';
import '../../../../modal/warehouse/warehouse.dart';
import '../../../../modal/warehouse/warehouseexport/itemexport.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondropdowsearch.dart';

class ExportDialog extends StatefulWidget {
  final Warehouse? priorityWarehouse;
  final WarehouseNote? export;
  final WarehouseNotesManager? warehouseNotesManager;
  final bool? isImportExcelFile;

  const ExportDialog({
    Key? key,
    this.export,
    this.warehouseNotesManager,
    this.priorityWarehouse,
    this.isImportExcelFile,
  }) : super(key: key);

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final DateTime now = Timestamp.now().toDate();
  ScrollController? scrollController;
  ScrollPhysics? scrollPhysics;
  ExportController? exportController;

  WarehouseNotesManager get warehouseNotesManager =>
      widget.warehouseNotesManager!;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(keepScrollOffset: true);
    scrollPhysics = const ClampingScrollPhysics();
    exportController = ExportController(
        widget.export == null ? null : widget.export as WarehouseNoteExport,
        warehouseNotesManager,
        widget.isImportExcelFile!,
        priorityWarehouse: widget.priorityWarehouse);
  }

  @override
  Widget build(BuildContext context) {
    bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
          width: isNotDesktop ? kMobileWidth : kLargeWidth,
          height: kHeight,
          child: ChangeNotifierProvider<ExportController>.value(
            value: exportController!,
            child: Consumer<ExportController>(builder: (_, controller, __) {
              if (controller.isInProgress!) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                );
              }

              return Column(
                children: [
                  //header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: SizeManagement.topHeaderTextSpacing,
                      bottom: SizeManagement.rowSpacing,
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding,
                    ),
                    child: NeutronTextHeader(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.HEADER_EXPORT_WAREHOUSE)),
                  ),
                  //time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!isNotDesktop)
                        Row(
                          children: [
                            NeutronTextContent(
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}:'),
                            const SizedBox(
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            SizedBox(
                                width: 200,
                                height: 45,
                                child: NeutronTextFormField(
                                  controller: controller.invoiceNumber,
                                  isDecor: true,
                                )),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          IconButton(
                              padding: const EdgeInsets.all(0),
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CHOOSE_DATE),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  firstDate:
                                      now.subtract(const Duration(days: 365)),
                                  lastDate: now.add(const Duration(days: 365)),
                                  initialDate: controller.now!,
                                  context: context,
                                  builder: (context, child) =>
                                      DateTimePickerDarkTheme.buildDarkTheme(
                                          context, child!),
                                );
                                if (picked == null) {
                                  return;
                                }
                                controller.setDate(DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    now.hour,
                                    now.minute,
                                    now.second,
                                    now.millisecond,
                                    now.microsecond));
                              },
                              icon: const Icon(
                                Icons.date_range_outlined,
                                size: 20,
                                color: ColorManagement.lightColorText,
                              )),
                          NeutronTextContent(
                              message: DateUtil.dateToString(controller.now!)),
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          IconButton(
                            onPressed: () async {
                              TimeOfDay? timePicked = await NeutronHourPicker(
                                      context: context,
                                      initTime: TimeOfDay.fromDateTime(
                                          controller.now!))
                                  .pickTime();
                              controller.setTime(timePicked!);
                            },
                            icon: const Icon(Icons.watch_later_outlined),
                            iconSize: 16,
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CHOOSE_TIME),
                          ),
                          NeutronTextContent(
                              message: DateUtil.dateToHourMinuteString(
                                  controller.now!)),
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                        ],
                      ),
                    ],
                  ),
                  if (isNotDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NeutronTextContent(
                            message:
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}:'),
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: NeutronTextFormField(
                            controller: controller.invoiceNumber,
                            isDecor: true,
                          ),
                        ),
                      ],
                    ),
                  //add item button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(
                          width: SizeManagement.cardOutsideHorizontalPadding),
                      IconButton(
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_ADD_ITEM),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () {
                            bool result = controller.addItemToList();
                            if (result && scrollController!.hasClients) {
                              scrollController!.jumpTo(
                                  scrollController!.position.maxScrollExtent +
                                      45);
                            }
                          },
                          icon: const Icon(Icons.add)),
                      if (isNotDesktop)
                        IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            onPressed: () {
                              controller.removeAllItem();
                            },
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_REMOVE_ALL),
                            icon: const Icon(Icons.playlist_remove_sharp)),
                    ],
                  ),
                  //list
                  Expanded(
                      child: isNotDesktop
                          ? _buildListInMobile(controller)
                          : _buildListInPC(controller, context)),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  //save
                  if (widget.export == null ||
                      widget.export!.type != WarehouseNotesType.exportBalance)
                    NeutronButton(
                      icon: Icons.save,
                      onPressed: () async {
                        if (controller.quantityWarning!) {
                          bool? confirmResult = await MaterialUtil.showConfirm(
                              context,
                              MessageUtil.getMessageByCode(MessageCodeUtil
                                  .CONFIRM_EXPORT_MUCH_THAN_IN_STOCK));
                          if (confirmResult != null && !confirmResult) {
                            return;
                          }
                        }
                        String result = await controller.updateExport();
                        if (result == MessageCodeUtil.SUCCESS) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                        // ignore: use_build_context_synchronously
                        MaterialUtil.showResult(
                            context, MessageUtil.getMessageByCode(result));
                      },
                    )
                ],
              );
            }),
          ),
        ));
  }

  ListView _buildListInMobile(ExportController controller) {
    double widthTitle = 75;
    double widthForm = kMobileWidth -
        widthTitle -
        SizeManagement.cardOutsideHorizontalPadding * 2 -
        SizeManagement.cardInsideHorizontalPadding * 2;

    return ListView.builder(
        controller: scrollController,
        physics: scrollPhysics,
        itemCount: controller.listItem.length,
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        itemBuilder: ((context, index) {
          ItemExport itemExport = controller.listItem[index];
          var item = ItemManager().getItemById(itemExport.id!);
          var warehouse =
              WarehouseManager().getWarehouseByName(itemExport.warehouse!);
          Color color = index % 2 == 0
              ? ColorManagement.evenColor
              : ColorManagement.oddColor;

          return ExpansionTile(
            collapsedBackgroundColor: color,
            backgroundColor: color,
            tilePadding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardInsideHorizontalPadding),
            childrenPadding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardInsideHorizontalPadding),
            iconColor: ColorManagement.lightColorText,
            collapsedIconColor: ColorManagement.lightColorText,
            title: Row(
              children: [
                Expanded(child: buildSelectItemWidget(index, controller)),
                const SizedBox(width: 4),
                IconButton(
                  color: Colors.white,
                  constraints: const BoxConstraints(maxWidth: 40),
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
                  onPressed: () => controller.removeItem(index),
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
            children: [
              SizedBox(
                width: double.infinity,
                child: DataTable(
                    headingRowHeight: 0,
                    columnSpacing: 0,
                    horizontalMargin:
                        SizeManagement.cardOutsideHorizontalPadding,
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      //unit
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: widthTitle,
                              child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_UNIT),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.only(right: 16),
                              width: widthForm,
                              child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    item?.unit ?? MessageCodeUtil.NO),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //warehouse
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_WAREHOUSE),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: widthForm,
                            child: Row(
                              children: [
                                Expanded(
                                    child: NeutronSearchDropDown(
                                        backgroundColor:
                                            ColorManagement.mainBackground,
                                        items: [
                                          UITitleUtil.getTitleByCode(
                                              UITitleCode.NO),
                                          ...controller
                                              .getAvailabelWarehouseNames(
                                                  itemExport.id!,
                                                  itemExport.warehouse!)
                                        ],
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemExport.warehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setWarehouse(
                                              itemExport, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneWarehouse(
                                          itemExport.warehouse!);
                                    },
                                    child: const Icon(
                                      Icons.copy,
                                      color: ColorManagement.lightColorText,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                      //stock
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_INVENTORY),
                          ),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.only(right: 16),
                            width: widthForm,
                            child: ChangeNotifierProvider<RebuildNumber>.value(
                                value: controller.rebuildStock[index],
                                child: Consumer<RebuildNumber>(
                                  builder: (_, rebuild, __) {
                                    num stockAmount = warehouse
                                            ?.getAmountOfItem(itemExport.id!) ??
                                        0;
                                    return NeutronTextContent(
                                      color: controller
                                              .isExportMuchThanInStock(index)
                                          ? ColorManagement.negativeText
                                          : ColorManagement.positiveText,
                                      textAlign: TextAlign.end,
                                      message: NumberUtil.numberFormat
                                          .format(stockAmount),
                                    );
                                  },
                                )),
                          ),
                        ),
                      ]),
                      //amount
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT),
                          ),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.only(right: 16),
                            width: widthForm,
                            child: controller.inputAmounts[index].buildWidget(
                              padding: 0,
                              onChanged: (String value) {
                                controller.onChangeAmount(index);
                              },
                              readOnly:
                                  itemExport.id == MessageCodeUtil.CHOOSE_ITEM,
                              textAlign: TextAlign.end,
                              hint: '0',
                              isDecor: true,
                              isDouble: true,
                              textColor: ColorManagement.positiveText,
                            ),
                          ),
                        ),
                      ]),
                    ]),
              )
            ],
          );
        }));
  }

  Widget _buildListInPC(ExportController controller, BuildContext context) {
    double widthUnit = 70;
    double widthAmount = 80;
    double widthDropdown = 150;
    double widthStock = 80;
    double widthName = 150;

    return SingleChildScrollView(
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: 3,
          showCheckboxColumn: true,
          horizontalMargin: SizeManagement.cardOutsideHorizontalPadding,
          columns: [
            //item name
            DataColumn(
                label: SizedBox(
              width: widthName,
              child: NeutronTextTitle(
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
              ),
            )),
            //unit
            DataColumn(
                label: SizedBox(
              width: widthUnit,
              child: NeutronTextTitle(
                textAlign: TextAlign.center,
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT),
              ),
            )),
            //warehouse
            DataColumn(
                label: Container(
              width: widthDropdown,
              alignment: Alignment.center,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LINK_TO_WAREHOUSE),
              ),
            )),
            //stock
            DataColumn(
                label: Container(
              width: widthStock,
              alignment: Alignment.center,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_INVENTORY),
              ),
            )),
            //amount
            DataColumn(
                label: SizedBox(
              width: widthAmount,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
              ),
            )),
            //remove button
            DataColumn(
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REMOVE_ALL),
              label: Expanded(
                child: InkWell(
                  onTap: controller.removeAllItem,
                  child: const Icon(Icons.playlist_remove_sharp),
                ),
              ),
            ),
          ],
          rows: controller.listItem.map((itemExport) {
            int index = controller.listItem.indexOf(itemExport);
            var item = ItemManager().getItemById(itemExport.id!);
            var warehouse =
                WarehouseManager().getWarehouseByName(itemExport.warehouse!);

            return DataRow(
              cells: [
                //item
                DataCell(
                  SizedBox(
                    width: widthName,
                    child: buildSelectItemWidget(index, controller),
                  ),
                ),
                //unit
                DataCell(
                  SizedBox(
                    width: widthUnit,
                    child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          (item?.unit ?? MessageCodeUtil.NO)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                //warehouse
                DataCell(
                  SizedBox(
                    width: widthDropdown,
                    child: Row(
                      children: [
                        Expanded(
                            child: NeutronSearchDropDown(
                                backgroundColor: ColorManagement.mainBackground,
                                items: [
                                  ...controller.getAvailabelWarehouseNames(
                                      itemExport.id!, itemExport.warehouse!)
                                ],
                                valueFirst:
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
                                value: itemExport.warehouse!,
                                onChange: (value) {
                                  GeneralManager().unfocus(context);
                                  controller.setWarehouse(itemExport, value);
                                })),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller.cloneWarehouse(itemExport.warehouse!);
                            },
                            child: const Icon(
                              Icons.copy,
                              color: ColorManagement.lightColorText,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                //stock
                DataCell(
                  SizedBox(
                    width: widthStock,
                    child: ChangeNotifierProvider<RebuildNumber>.value(
                        value: controller.rebuildStock[index],
                        child: Consumer<RebuildNumber>(
                            builder: (_, rebuildController, __) {
                          num stockAmount =
                              warehouse?.getAmountOfItem(itemExport.id!) ?? 0;
                          return NeutronTextContent(
                            color: controller.isExportMuchThanInStock(index)
                                ? ColorManagement.negativeText
                                : ColorManagement.positiveText,
                            textAlign: TextAlign.center,
                            message:
                                NumberUtil.numberFormat.format(stockAmount),
                          );
                        })),
                  ),
                ),
                //amount
                DataCell(
                  SizedBox(
                    width: widthAmount,
                    child: controller.inputAmounts[index].buildWidget(
                      readOnly: itemExport.id == MessageCodeUtil.CHOOSE_ITEM,
                      textAlign: TextAlign.end,
                      hint: '0',
                      isDecor: true,
                      isDouble: true,
                      onChanged: (String newAmount) {
                        controller.onChangeAmount(index);
                      },
                      textColor: ColorManagement.positiveText,
                    ),
                  ),
                ),
                //remove
                DataCell(
                  Center(
                    child: Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_DELETE),
                      child: const Icon(Icons.remove),
                    ),
                  ),
                  onTap: () {
                    controller.removeItem(index);
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  NeutronSearchDropDown buildSelectItemWidget(
      int index, ExportController controller) {
    ItemExport itemExport = exportController!.listItem[index];
    return NeutronSearchDropDown(
        backgroundColor: ColorManagement.mainBackground,
        items: controller.getListAvailabelItem(),
        valueFirst: MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_ITEM),
        value: itemExport.id == MessageCodeUtil.CHOOSE_ITEM
            ? ''
            : ItemManager().getItemNameByID(itemExport.id!)!,
        onChange: (value) {
          GeneralManager().unfocus(context);
          controller.setItemId(index, value);
        });
  }
}
