import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/controller/warehouse/importcontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdowsearch.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/generalmanager.dart';
import '../../../../manager/usermanager.dart';
import '../../../../modal/warehouse/warehouse.dart';
import '../../../../modal/warehouse/warehouseimport/itemimport.dart';
import '../../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../modal/warehouse/warehousereturn/warehousenotereturn.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';

class ImportDialog extends StatefulWidget {
  final Warehouse? priorityWarehouse;
  final WarehouseNote? import;
  final WarehouseNotesManager? warehouseNotesManager;
  final bool? isImportExcelFile;

  // use for compensation
  final WarehouseNoteReturn? returnNote;
  final WarehouseNote? importNoteForCompensation;

  const ImportDialog({
    Key? key,
    this.import,
    this.warehouseNotesManager,
    this.priorityWarehouse,
    this.isImportExcelFile,
    this.importNoteForCompensation,
    this.returnNote,
  }) : super(key: key);

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final DateTime now = Timestamp.now().toDate();
  final double widthTitleMobile = 75;
  final double widthUnit = 70;
  final double widthAmount = 80;
  final double widthPrice = 100;
  final double widthTotal = 120;
  final double widthName = 130;
  final double widthDropdown = 150;
  final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);

  final ScrollPhysics scrollPhysics = const ClampingScrollPhysics();
  ImportController? importController;

  @override
  void initState() {
    super.initState();
    importController = ImportController(
        widget.import == null ? null : widget.import as WarehouseNoteImport,
        widget.warehouseNotesManager,
        widget.isImportExcelFile!,
        priorityWarehouse: widget.priorityWarehouse,
        importNoteForCompensation: widget.importNoteForCompensation == null
            ? null
            : widget.importNoteForCompensation as WarehouseNoteImport,
        returnNote: widget.returnNote);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
          width: isNotDesktop ? kMobileWidth : 1000,
          height: kHeight,
          child: ChangeNotifierProvider<ImportController>.value(
            value: importController!,
            child: Consumer<ImportController>(builder: (_, controller, __) {
              if (controller.isInProgress) {
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
                            UITitleCode.HEADER_IMPORT_WAREHOUSE)),
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
                      )
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
                            )),
                      ],
                    ),
                  //add item button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_ADD_ITEM),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: () {
                            bool result = controller.addItemToList();
                            if (result && scrollController.hasClients) {
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent +
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
                  //total
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        vertical: SizeManagement.rowSpacing),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeutronTextTitle(
                          message:
                              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL)}: ',
                        ),
                        const SizedBox(width: 8),
                        LimitedBox(
                          maxWidth: isNotDesktop ? 180 : 700,
                          child: ChangeNotifierProvider<RebuildNumber>.value(
                            value: controller.finalTotal,
                            child: Consumer<RebuildNumber>(
                                builder: ((_, finalTotal, __) =>
                                    NeutronTextTitle(
                                      overflow: TextOverflow.ellipsis,
                                      color: ColorManagement.positiveText,
                                      message: isNotDesktop
                                          ? NumberUtil.moneyFormat
                                              .format(finalTotal.value)
                                          : NumberUtil.numberFormat
                                              .format(finalTotal.value),
                                    ))),
                          ),
                        )
                      ],
                    ),
                  ),
                  //save
                  NeutronButton(
                    icon: Icons.save,
                    onPressed: () async {
                      WarehouseNoteImport? oldImport = controller.oldImport;
                      bool? isCanUpdate = true;
                      if (oldImport != null) {
                        if (controller.oldImport!.totalCost == null) {
                          if (UserManager.canSeeAccounting()) {
                            bool checkCostResult = await widget
                                .warehouseNotesManager!
                                .checkCostByImportInvoiceNumber(
                                    oldImport.invoiceNumber!,
                                    controller.finalTotal.value.toDouble());
                            if (!checkCostResult) {
                              // ignore: use_build_context_synchronously
                              isCanUpdate = await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CONFIRM_EDIT_iMPORT_NOTE));
                            }
                          }
                        } else if (controller.finalTotal.value <
                            oldImport.totalCost!) {
                          isCanUpdate = await MaterialUtil.showConfirm(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.CONFIRM_EDIT_iMPORT_NOTE));
                        }
                      }
                      if (isCanUpdate!) {
                        await controller.updateImport().then((result) {
                          if (result == MessageCodeUtil.SUCCESS) {
                            Map<String, dynamic>? returnData;
                            if (controller.isAddFeature!) {
                              returnData = {
                                'desc':
                                    'Import - ${DateUtil.dateToDayMonthHourMinuteString(controller.now!)}',
                                'amount': controller.finalTotal.value,
                                'invoice_num': controller.invoiceNumber!.text
                              };
                            }
                            Navigator.pop(context, returnData);
                          }
                          MaterialUtil.showResult(
                              context, MessageUtil.getMessageByCode(result));
                        });
                      }
                    },
                  )
                ],
              );
            }),
          ),
        ));
  }

  ListView _buildListInMobile(ImportController controller) {
    double widthFormFieldMobile = kMobileWidth -
        widthTitleMobile -
        SizeManagement.cardOutsideHorizontalPadding * 2 -
        SizeManagement.cardInsideHorizontalPadding * 2 -
        4;
    return ListView.builder(
        controller: scrollController,
        physics: scrollPhysics,
        itemCount: controller.listItem.length,
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        itemBuilder: ((context, index) {
          ItemImport itemImport = controller.listItem[index];
          String? nameTemp = ItemManager().getItemNameByID(itemImport.id!);
          String? itemName = nameTemp!.isEmpty
              ? MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_ITEM)
              : nameTemp;
          var item = ItemManager().getItemById(itemImport.id!);

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
            title: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: NeutronSearchDropDown(
                        backgroundColor: ColorManagement.mainBackground,
                        items: controller.getListAvailabelItem(),
                        valueFirst: MessageUtil.getMessageByCode(
                            MessageCodeUtil.CHOOSE_ITEM),
                        value: itemName,
                        onChange: (value) {
                          GeneralManager().unfocus(context);
                          controller.setItemId(index, value);
                        })),
                const SizedBox(width: 4),
                Expanded(
                    child: Center(
                  child: NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                        item?.unit ?? MessageCodeUtil.NO),
                  ),
                )),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
                    onPressed: () {
                      controller.removeItem(index);
                    },
                    icon: const Icon(Icons.remove),
                  ),
                ),
              ],
            ),
            children: [
              SizedBox(
                width: double.infinity,
                child: DataTable(
                    headingRowHeight: 0,
                    horizontalMargin: 0,
                    columnSpacing: 4,
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      //supplier
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitleMobile,
                          child: NeutronTextContent(
                            textOverflow: TextOverflow.clip,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SUPPLIER),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: widthFormFieldMobile,
                            child: Row(
                              children: [
                                Expanded(
                                    child: NeutronSearchDropDown(
                                        backgroundColor:
                                            ColorManagement.mainBackground,
                                        items: [
                                          if (controller.isCompensation)
                                            ...controller.getSuppliersByItemId(
                                                itemImport.id!),
                                          if (!controller.isCompensation)
                                            ...controller
                                                .getAvailabelSupplierNames(
                                                    itemImport.id!,
                                                    itemImport.supplier!)
                                        ],
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemImport.supplier!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setSupplier(index, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller
                                          .cloneSupplier(itemImport.supplier!);
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
                      //price
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitleMobile,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: widthFormFieldMobile,
                            child: controller.inputPrices[index].buildWidget(
                              readOnly:
                                  itemImport.id == MessageCodeUtil.CHOOSE_ITEM,
                              textAlign: TextAlign.end,
                              onChanged: (String value) {
                                controller.rebuildTotal(index);
                              },
                              textColor: ColorManagement.positiveText,
                              hint: '0',
                              isDecor: false,
                              isDouble: true,
                            ),
                          ),
                        ),
                      ]),
                      //warehouse
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitleMobile,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_WAREHOUSE),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: widthFormFieldMobile,
                            child: Row(
                              children: [
                                Expanded(
                                    child: NeutronSearchDropDown(
                                        items: [
                                      if (!controller.isCompensation)
                                        ...controller
                                            .getAvailabelWarehouseNames(
                                                itemImport.id!),
                                      if (controller.isCompensation)
                                        ...controller.getWarehousesByItemId(
                                            itemImport.id!),
                                    ],
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemImport.warehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setWarehouse(
                                              itemImport, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneWarehouse(
                                          itemImport.warehouse!);
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
                      //amount
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitleMobile,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT),
                          ),
                        )),
                        DataCell(
                          Container(
                            width: widthFormFieldMobile,
                            alignment: Alignment.centerRight,
                            child: controller.inputAmounts[index].buildWidget(
                              readOnly:
                                  itemImport.id == MessageCodeUtil.CHOOSE_ITEM,
                              textAlign: TextAlign.end,
                              onChanged: (String value) {
                                controller.rebuildTotal(index);
                              },
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

  Widget _buildListInPC(ImportController controller, BuildContext context) {
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
                label: Container(
              width: widthUnit,
              alignment: Alignment.center,
              child: NeutronTextTitle(
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT),
              ),
            )),
            //price
            DataColumn(
                label: Container(
              width: widthPrice,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                  right: SizeManagement.cardInsideHorizontalPadding),
              child: NeutronTextTitle(
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
              ),
            )),
            //supplier
            DataColumn(
                label: SizedBox(
              width: widthDropdown,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_SUPPLIER),
              ),
            )),
            //warehouse
            DataColumn(
                label: SizedBox(
              width: widthDropdown,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LINK_TO_WAREHOUSE),
              ),
            )),
            //amount
            DataColumn(
                label: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(
                  right: SizeManagement.cardInsideHorizontalPadding),
              width: widthAmount,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
              ),
            )),
            //total
            DataColumn(
                label: Container(
              width: widthTotal,
              alignment: Alignment.centerRight,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_TOTAL_COMPACT),
              ),
            )),
            //remove button
            DataColumn(
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REMOVE_ALL),
              label: Expanded(
                  child: InkWell(
                child: const Icon(Icons.playlist_remove_sharp),
                onTap: () {
                  controller.removeAllItem();
                },
              )),
            ),
          ],
          rows: controller.listItem.map((itemImport) {
            int index = controller.listItem.indexOf(itemImport);
            String? nameTemp = ItemManager().getItemNameByID(itemImport.id!);
            var item = ItemManager().getItemById(itemImport.id!);
            String? itemName = nameTemp!.isEmpty
                ? MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_ITEM)
                : nameTemp;
            return DataRow(
              cells: [
                //item
                DataCell(SizedBox(
                  width: 200,
                  child: NeutronSearchDropDown(
                      backgroundColor: ColorManagement.mainBackground,
                      items: controller.getListAvailabelItem(),
                      valueFirst: MessageUtil.getMessageByCode(
                          MessageCodeUtil.CHOOSE_ITEM),
                      value: itemName,
                      onChange: (value) {
                        GeneralManager().unfocus(context);
                        controller.setItemId(index, value);
                      }),
                )),
                //unit
                DataCell(
                  Container(
                    alignment: Alignment.center,
                    width: widthUnit,
                    child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          item?.unit ?? MessageCodeUtil.NO),
                    ),
                  ),
                ),
                //price
                DataCell(
                  SizedBox(
                    width: widthPrice,
                    child: controller.inputPrices[index].buildWidget(
                      readOnly: itemImport.id == MessageCodeUtil.CHOOSE_ITEM,
                      textAlign: TextAlign.end,
                      onChanged: (String value) {
                        controller.rebuildTotal(index);
                      },
                      textColor: ColorManagement.positiveText,
                      hint: '0',
                      isDecor: false,
                      isDouble: true,
                    ),
                  ),
                ),
                //supplier
                DataCell(
                  SizedBox(
                    width: widthDropdown,
                    child: Row(
                      children: [
                        Expanded(
                          child: NeutronSearchDropDown(
                              backgroundColor: ColorManagement.mainBackground,
                              items: [
                                if (controller.isCompensation)
                                  ...controller
                                      .getSuppliersByItemId(itemImport.id!),
                                if (!controller.isCompensation)
                                  ...controller.getAvailabelSupplierNames(
                                      itemImport.id!, itemImport.supplier!)
                              ],
                              valueFirst:
                                  UITitleUtil.getTitleByCode(UITitleCode.NO),
                              value: itemImport.supplier!,
                              onChange: (value) {
                                GeneralManager().unfocus(context);
                                controller.setSupplier(index, value);
                              }),
                        ),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller.cloneSupplier(itemImport.supplier!);
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
                                  if (!controller.isCompensation)
                                    ...controller.getAvailabelWarehouseNames(
                                        itemImport.id!),
                                  if (controller.isCompensation)
                                    ...controller
                                        .getWarehousesByItemId(itemImport.id!),
                                ],
                                valueFirst:
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
                                value: itemImport.warehouse!,
                                onChange: (value) {
                                  GeneralManager().unfocus(context);
                                  controller.setWarehouse(itemImport, value);
                                })),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller.cloneWarehouse(itemImport.warehouse!);
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
                //amount
                DataCell(
                  Container(
                    width: widthAmount,
                    alignment: Alignment.centerRight,
                    child: controller.inputAmounts[index].buildWidget(
                      color: ColorManagement.mainBackground,
                      readOnly: itemImport.id == MessageCodeUtil.CHOOSE_ITEM,
                      textAlign: TextAlign.end,
                      onChanged: (String value) {
                        controller.rebuildTotal(index);
                      },
                      hint: '0',
                      isDecor: true,
                      isDouble: true,
                      textColor: ColorManagement.positiveText,
                    ),
                  ),
                ),
                //total
                DataCell(
                  Container(
                    width: widthTotal,
                    alignment: Alignment.centerRight,
                    child: ChangeNotifierProvider<RebuildNumber>.value(
                      value: controller.listTotal[index],
                      child: Consumer<RebuildNumber>(
                        builder: ((_, rebuildController, __) =>
                            NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(rebuildController.value),
                            )),
                      ),
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
                    ), onTap: () {
                  controller.removeItem(index);
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
