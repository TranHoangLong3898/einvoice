import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/controller/warehouse/returntosuppliercontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/warehouse/warehousereturn/warehousenotereturn.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
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
import '../../../../modal/warehouse/warehouse.dart';
import '../../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../modal/warehouse/warehousereturn/itemreturn.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondatetimepicker.dart';

class ReturnToSupplierDialog extends StatefulWidget {
  final Warehouse? priorityWarehouse;
  final WarehouseNote? returnNote;
  final WarehouseNotesManager? warehouseNotesManager;

  // use when return to supplier
  final WarehouseNoteImport? importNote;

  const ReturnToSupplierDialog(
      {Key? key,
      this.returnNote,
      this.warehouseNotesManager,
      this.priorityWarehouse,
      this.importNote})
      : super(key: key);

  @override
  State<ReturnToSupplierDialog> createState() => _ReturnToSupplierDialogState();
}

class _ReturnToSupplierDialogState extends State<ReturnToSupplierDialog> {
  final DateTime now = Timestamp.now().toDate();
  ScrollController? scrollController;
  ScrollPhysics? scrollPhysics;
  ReturnToSupplierController? returnToSupplierController;

  WarehouseNote? get returnNote => widget.returnNote;

  WarehouseNotesManager? get warehouseNotesManager =>
      widget.warehouseNotesManager;

  Warehouse? get priorityWarehouse => widget.priorityWarehouse;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(keepScrollOffset: true);
    scrollPhysics = const ClampingScrollPhysics();
    returnToSupplierController = ReturnToSupplierController(
        returnNote == null ? null : returnNote as WarehouseNoteReturn,
        warehouseNotesManager!,
        widget.importNote!,
        priorityWarehouse: priorityWarehouse);
  }

  @override
  Widget build(BuildContext context) {
    bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
          width: isNotDesktop ? kMobileWidth : kLargeWidth,
          height: kHeight,
          child: ChangeNotifierProvider<ReturnToSupplierController>.value(
            value: returnToSupplierController!,
            child: Consumer<ReturnToSupplierController>(
                builder: (_, controller, __) {
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
                            UITitleCode.HEADER_RETURN_WAREHOUSE)),
                  ),
                  //time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!isNotDesktop) ...[
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
                        NeutronTextContent(
                            message:
                                '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_IMPORT_INVOICE_NUMBER)}: ${widget.importNote!.invoiceNumber}')
                      ],
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
                  if (isNotDesktop) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
                        NeutronTextContent(
                            message:
                                '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_IMPORT_INVOICE_NUMBER)}:'),
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
                        NeutronTextContent(
                            message: widget.importNote!.invoiceNumber!),
                      ],
                    ),
                    const SizedBox(
                        height: SizeManagement.cardOutsideVerticalPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
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
                  ],
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
                      String result = await controller.updateReturnNote();
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

  ListView _buildListInMobile(ReturnToSupplierController controller) {
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
          ItemReturn itemReturn = controller.listItem[index];
          HotelItem? item = ItemManager().getItemById(itemReturn.id!);
          Warehouse? warehouse =
              WarehouseManager().getWarehouseByName(itemReturn.warehouse!);
          double? price = (item == null || warehouse == null)
              ? 0
              : controller.getPrice(item.id!, warehouse.id!);
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
                Expanded(child: buildSelectItemWidget(index)),
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
                                message: item?.unit ?? ' ',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //unit price
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: widthTitle,
                              child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_UNIT_PRICE),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.only(right: 16),
                              width: widthForm,
                              child: NeutronTextContent(
                                message: NumberUtil.numberFormat.format(price),
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
                                        items: controller
                                            .getAvailabelWarehouseNames(
                                                itemReturn.id!,
                                                itemReturn.warehouse!),
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemReturn.warehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setWarehouse(
                                              itemReturn, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneWarehouse(
                                          itemReturn.warehouse!);
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
                                    num stockAmount =
                                        controller.getItemAmountInImportNote(
                                            warehouse, itemReturn.id!);
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
                                  itemReturn.id == MessageCodeUtil.CHOOSE_ITEM,
                              textAlign: TextAlign.end,
                              hint: '0',
                              isDecor: true,
                              isDouble: true,
                              textColor: ColorManagement.positiveText,
                            ),
                          ),
                        ),
                      ]),
                      //total

                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TOTAL),
                          ),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.only(right: 16),
                            width: widthForm,
                            child: ChangeNotifierProvider<RebuildNumber>.value(
                              value: controller.rebuildStock[index],
                              child: Consumer<RebuildNumber>(
                                builder: (_, __, ___) => NeutronTextContent(
                                  textAlign: TextAlign.end,
                                  message: NumberUtil.numberFormat.format(
                                      (controller.inputAmounts[index]
                                                  .getNumber() ??
                                              0) *
                                          ((item == null || warehouse == null)
                                              ? 0
                                              : widget.importNote!.list!
                                                  .firstWhere((element) =>
                                                      element.id == item.id &&
                                                      element.warehouse ==
                                                          warehouse.id)
                                                  .price!)),
                                ),
                              ),
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

  Widget _buildListInPC(
      ReturnToSupplierController controller, BuildContext context) {
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
            //Unit price
            DataColumn(
                label: SizedBox(
              width: widthUnit,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_UNIT_PRICE),
                maxLines: 2,
                textAlign: TextAlign.center,
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
            //total

            DataColumn(
                label: SizedBox(
              width: widthAmount,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 14,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
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
          rows: controller.listItem.map((itemReturn) {
            int index = controller.listItem.indexOf(itemReturn);
            var item = ItemManager().getItemById(itemReturn.id!);
            var warehouse =
                WarehouseManager().getWarehouseByName(itemReturn.warehouse!);
            var price = (item == null || warehouse == null)
                ? 0
                : controller.getPrice(item.id!, warehouse.id!);

            return DataRow(
              cells: [
                //item
                DataCell(
                  SizedBox(
                    width: widthName,
                    child: buildSelectItemWidget(index),
                  ),
                ),
                //unit
                DataCell(
                  SizedBox(
                    width: widthUnit,
                    child: NeutronTextContent(
                      message: item?.unit ?? ' ',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                //cost price
                DataCell(
                  SizedBox(
                    width: widthUnit,
                    child: NeutronTextContent(
                      message: NumberUtil.numberFormat
                          .format(item != null ? price : 0),
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
                              items: controller.getAvailabelWarehouseNames(
                                  itemReturn.id!, itemReturn.warehouse!),
                              valueFirst:
                                  UITitleUtil.getTitleByCode(UITitleCode.NO),
                              value: itemReturn.warehouse!,
                              onChange: (value) {
                                GeneralManager().unfocus(context);
                                controller.setWarehouse(itemReturn, value);
                              }),
                        ),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller.cloneWarehouse(itemReturn.warehouse!);
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
                              controller.getItemAmountInImportNote(
                                  warehouse, itemReturn.id!);
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
                      readOnly: itemReturn.id == MessageCodeUtil.CHOOSE_ITEM,
                      textAlign: TextAlign.end,
                      hint: '0',
                      isDecor: true,
                      isDouble: true,
                      onChanged: (
                        String newAmount,
                      ) {
                        controller.onChangeAmount(index);
                      },
                      textColor: ColorManagement.positiveText,
                    ),
                  ),
                ),
                // total
                DataCell(
                  SizedBox(
                    width: widthAmount,
                    child: ChangeNotifierProvider<RebuildNumber>.value(
                      value: controller.rebuildStock[index],
                      child: Consumer<RebuildNumber>(
                        builder: (_, __, ___) => NeutronTextContent(
                          textAlign: TextAlign.end,
                          message: NumberUtil.numberFormat.format(
                              (controller.inputAmounts[index].getNumber() ??
                                      0) *
                                  ((item == null || warehouse == null)
                                      ? 0
                                      : widget.importNote!.list!
                                          .firstWhere((element) =>
                                              element.id == item.id &&
                                              element.warehouse == warehouse.id)
                                          .price)!),
                        ),
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

  Widget buildSelectItemWidget(int index) {
    ItemReturn itemReturn = returnToSupplierController!.listItem[index];
    return NeutronSearchDropDown(
        backgroundColor: ColorManagement.mainBackground,
        items: returnToSupplierController!.getListAvailabelItem(),
        valueFirst: MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_ITEM),
        value: itemReturn.id == MessageCodeUtil.CHOOSE_ITEM
            ? ''
            : ItemManager().getItemNameByID(itemReturn.id!)!,
        onChange: (value) {
          GeneralManager().unfocus(context);
          returnToSupplierController!.setItemId(index, value);
        });
  }
}
