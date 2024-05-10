import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/controller/warehouse/liquidationcontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/warehouse/warehouseliquidation/warehousenoteliquidation.dart';
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
import '../../../../modal/warehouse/warehouseliquidation/itemliquidation.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondatetimepicker.dart';

class LiquidationDialog extends StatefulWidget {
  const LiquidationDialog({
    Key? key,
    this.liquidation,
    this.warehouseNotesManager,
    this.priorityWarehouse,
    this.isImportExcelFile,
  }) : super(key: key);

  final Warehouse? priorityWarehouse;

  final WarehouseNote? liquidation;

  final WarehouseNotesManager? warehouseNotesManager;

  final bool? isImportExcelFile;

  @override
  State<LiquidationDialog> createState() => _LiquidationDialogState();
}

class _LiquidationDialogState extends State<LiquidationDialog> {
  final DateTime now = Timestamp.now().toDate();

  final _formKey = GlobalKey<FormState>();

  final ScrollController scrollController =
      ScrollController(keepScrollOffset: true);

  final ScrollPhysics scrollPhysics = const ClampingScrollPhysics();

  LiquidationController? liquidationController;

  @override
  void initState() {
    super.initState();
    liquidationController = LiquidationController(
        widget.liquidation == null
            ? null
            : widget.liquidation as WarehouseNoteLiquidation,
        widget.warehouseNotesManager!,
        widget.isImportExcelFile!,
        priorityWarehouse: widget.priorityWarehouse);
  }

  @override
  Widget build(BuildContext context) {
    bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
          width: isNotDesktop ? kMobileWidth : 820,
          height: kHeight,
          child: Form(
            key: _formKey,
            child: ChangeNotifierProvider<LiquidationController>.value(
              value: liquidationController!,
              child:
                  Consumer<LiquidationController>(builder: (_, controller, __) {
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
                              UITitleCode.HEADER_LIQUIDATION)),
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
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            IconButton(
                                padding: const EdgeInsets.all(0),
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CHOOSE_DATE),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    firstDate:
                                        now.subtract(const Duration(days: 365)),
                                    lastDate:
                                        now.add(const Duration(days: 365)),
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
                                message:
                                    DateUtil.dateToString(controller.now!)),
                            const SizedBox(
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
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
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                          ],
                        )
                      ],
                    ),
                    if (isNotDesktop &&
                        controller.invoiceNumber!.text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeutronTextContent(
                              message:
                                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}:'),
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          SizedBox(
                              width: 150,
                              height: 45,
                              child: NeutronTextFormField(
                                controller: controller.invoiceNumber,
                                isDecor: true,
                              )),
                        ],
                      ), //add item button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          IconButton(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_ADD_ITEM),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              onPressed: () {
                                bool result = controller.addItemToList();
                                if (result && scrollController.hasClients) {
                                  scrollController.jumpTo(scrollController
                                          .position.maxScrollExtent +
                                      45);
                                }
                              },
                              icon: const Icon(Icons.add)),
                          if (isNotDesktop)
                            IconButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                onPressed: () {
                                  controller.removeAllItem();
                                },
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_REMOVE_ALL),
                                icon: const Icon(Icons.playlist_remove_sharp)),
                        ],
                      ),
                    ),
                    //list
                    Expanded(
                        child: isNotDesktop
                            ? _buildMobile(controller)
                            : _buildPC(controller, context)),
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
                        if (controller.quantityWarning!) {
                          bool? confirmResult = await MaterialUtil.showConfirm(
                              context,
                              MessageUtil.getMessageByCode(MessageCodeUtil
                                  .CONFIRM_LIQUIDATION_MUCH_THAN_IN_STOCK));
                          if (confirmResult != null && !confirmResult) {
                            return;
                          }
                        }
                        String result = await controller.updateLiquidation();
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
          ),
        ));
  }

  ListView _buildMobile(LiquidationController controller) {
    double titleMobile = 75;
    double widthForm = kMobileWidth -
        titleMobile -
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
          ItemLiquidation itemLiquidation = controller.listItem[index];
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
                        value: itemLiquidation.id == MessageCodeUtil.CHOOSE_ITEM
                            ? ''
                            : ItemManager()
                                .getItemNameByID(itemLiquidation.id!)!,
                        onChange: (value) {
                          GeneralManager().unfocus(context);
                          controller.setItemId(index, value);
                        })),
                const SizedBox(width: 4),
                Expanded(
                    child: Center(
                  child: NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                        ItemManager().getItemById(itemLiquidation.id!)?.unit ??
                            MessageCodeUtil.NO),
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
                    columnSpacing: 0,
                    horizontalMargin:
                        SizeManagement.cardOutsideHorizontalPadding,
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      //warehouse
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: titleMobile,
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
                                                itemLiquidation.id!,
                                                itemLiquidation.warehouse!),
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemLiquidation.warehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setWarehouse(
                                              itemLiquidation, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneWarehouse(
                                          itemLiquidation.warehouse!);
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
                          width: titleMobile,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_INVENTORY),
                          ),
                        )),
                        DataCell(Container(
                            width: widthForm,
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardInsideHorizontalPadding),
                            child: ChangeNotifierProvider<RebuildNumber>.value(
                                value: controller.rebuildStock[index],
                                child: Consumer<RebuildNumber>(
                                    builder: (_, rebuildController, __) {
                                  num stockAmount = WarehouseManager()
                                          .getWarehouseByName(
                                              itemLiquidation.warehouse!)
                                          ?.getAmountOfItem(
                                              itemLiquidation.id!) ??
                                      0;

                                  return NeutronTextContent(
                                    color: controller
                                            .isLiquidationMuchThanInStock(index)
                                        ? ColorManagement.negativeText
                                        : ColorManagement.positiveText,
                                    textAlign: TextAlign.end,
                                    message: NumberUtil.numberFormat
                                        .format(stockAmount),
                                  );
                                })))),
                      ]),
                      //price
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: titleMobile,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE),
                          ),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardInsideHorizontalPadding),
                            width: widthForm,
                            child: controller.inputPrices[index].buildWidget(
                                padding: 0,
                                readOnly: itemLiquidation.id ==
                                    MessageCodeUtil.CHOOSE_ITEM,
                                textAlign: TextAlign.end,
                                onChanged: (String value) {
                                  controller.rebuildTotal(index);
                                },
                                textColor: ColorManagement.positiveText,
                                hint: '0',
                                isDecor: false,
                                isDouble: true),
                          ),
                        ),
                      ]),
                      //amount
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: titleMobile,
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_AMOUNT)),
                        )),
                        DataCell(
                          Container(
                            width: widthForm,
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardInsideHorizontalPadding),
                            child: controller.inputAmounts[index].buildWidget(
                              onChanged: (String value) {
                                controller.rebuildTotal(index);
                              },
                              readOnly: itemLiquidation.id ==
                                  MessageCodeUtil.CHOOSE_ITEM,
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

  Widget _buildPC(LiquidationController controller, BuildContext context) {
    double widthUnit = 70;
    double widthAmount = 80;
    double widthDropdown = 150;
    double widthStock = 80;
    double widthName = 150;
    double widthPrice = 100;
    double widthTotal = 120;

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
                label: Container(
              width: widthAmount,
              alignment: Alignment.centerRight,
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
          rows: controller.listItem.map((itemLiquidation) {
            int index = controller.listItem.indexOf(itemLiquidation);
            return DataRow(
              cells: [
                //item
                DataCell(SizedBox(
                    width: widthName,
                    child: NeutronSearchDropDown(
                        backgroundColor: ColorManagement.mainBackground,
                        items: controller.getListAvailabelItem(),
                        valueFirst: MessageUtil.getMessageByCode(
                            MessageCodeUtil.CHOOSE_ITEM),
                        value: itemLiquidation.id == MessageCodeUtil.CHOOSE_ITEM
                            ? ''
                            : ItemManager()
                                .getItemNameByID(itemLiquidation.id!)!,
                        onChange: (value) {
                          GeneralManager().unfocus(context);
                          controller.setItemId(index, value);
                        }))),
                //unit
                DataCell(
                  Container(
                    width: widthUnit,
                    alignment: Alignment.center,
                    child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(ItemManager()
                              .getItemById(itemLiquidation.id!)
                              ?.unit ??
                          MessageCodeUtil.NO),
                    ),
                  ),
                ),
                //price
                DataCell(
                  SizedBox(
                    width: widthPrice,
                    child: controller.inputPrices[index].buildWidget(
                        readOnly:
                            itemLiquidation.id == MessageCodeUtil.CHOOSE_ITEM,
                        textAlign: TextAlign.end,
                        onChanged: (String value) {
                          controller.rebuildTotal(index);
                        },
                        textColor: ColorManagement.positiveText,
                        hint: '0',
                        isDecor: false,
                        isDouble: true),
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
                                    itemLiquidation.id!,
                                    itemLiquidation.warehouse!),
                                valueFirst:
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
                                value: itemLiquidation.warehouse!,
                                onChange: (value) {
                                  GeneralManager().unfocus(context);
                                  controller.setWarehouse(
                                      itemLiquidation, value);
                                })),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller
                                  .cloneWarehouse(itemLiquidation.warehouse!);
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
                          num stockAmount = WarehouseManager()
                                  .getWarehouseByName(
                                      itemLiquidation.warehouse!)
                                  ?.getAmountOfItem(itemLiquidation.id!) ??
                              0;

                          return NeutronTextContent(
                            color:
                                controller.isLiquidationMuchThanInStock(index)
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
                      onChanged: (String value) {
                        controller.rebuildTotal(index);
                      },
                      readOnly:
                          itemLiquidation.id == MessageCodeUtil.CHOOSE_ITEM,
                      textAlign: TextAlign.end,
                      hint: '0',
                      isDecor: true,
                      isDouble: true,
                      textColor: ColorManagement.positiveText,
                    ),
                  ),
                ),
                //total
                DataCell(Container(
                  width: widthTotal,
                  alignment: Alignment.centerRight,
                  child: ChangeNotifierProvider<RebuildNumber>.value(
                      value: controller.listTotal[index],
                      child: Consumer<RebuildNumber>(
                        builder: ((_, rebuildController, __) =>
                            NeutronTextContent(
                                message: NumberUtil.numberFormat
                                    .format(rebuildController.value))),
                      )),
                )), //remove
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
