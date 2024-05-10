import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/rebuildnumber.dart';
import 'package:ihotel/controller/warehouse/transfercontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/warehouse/warehousetransfer/warehousenotetransfer.dart';
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
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../modal/warehouse/warehousetransfer/itemtransfer.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondatetimepicker.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog(
      {Key? key,
      this.transfer,
      this.warehouseNotesManager,
      this.priorityWarehouse,
      this.isImportExcelFile})
      : super(key: key);

  final Warehouse? priorityWarehouse;
  final WarehouseNote? transfer;
  final WarehouseNotesManager? warehouseNotesManager;
  final bool? isImportExcelFile;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  DateTime? now;
  GlobalKey<FormState>? _formKey;
  ScrollController? scrollController;
  ScrollPhysics? scrollPhysics;
  TransferController? transferController;

  @override
  void initState() {
    super.initState();
    now = Timestamp.now().toDate();
    _formKey = GlobalKey<FormState>();
    scrollController = ScrollController(keepScrollOffset: true);
    scrollPhysics = const ClampingScrollPhysics();
    transferController = TransferController(
      widget.transfer == null ? null : widget.transfer as WarehouseNoteTransfer,
      widget.warehouseNotesManager!,
      widget.isImportExcelFile!,
      priorityWarehouse: widget.priorityWarehouse,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
          width: isNotDesktop ? kMobileWidth : 750,
          height: kHeight,
          child: Form(
            key: _formKey,
            child: ChangeNotifierProvider<TransferController>.value(
              value: transferController!,
              child: Consumer<TransferController>(builder: (_, controller, __) {
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
                              UITitleCode.HEADER_TRANSFER_WAREHOUSE)),
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
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            IconButton(
                                padding: const EdgeInsets.all(0),
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CHOOSE_DATE),
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    firstDate: now!
                                        .subtract(const Duration(days: 365)),
                                    lastDate:
                                        now!.add(const Duration(days: 365)),
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
                                      now!.hour,
                                      now!.minute,
                                      now!.second,
                                      now!.millisecond,
                                      now!.microsecond));
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
                        ),
                      ],
                    ), //add item button
                    if (isNotDesktop)
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
                            ),
                          ),
                        ],
                      ),
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
                    //list
                    Expanded(
                        child: isNotDesktop
                            ? _buildMobile(controller)
                            : _buildPC(controller, context)),
                    //save
                    NeutronButton(
                      icon: Icons.save,
                      onPressed: () async {
                        if (controller.quantityWarning!) {
                          bool? confirmResult = await MaterialUtil.showConfirm(
                              context,
                              MessageUtil.getMessageByCode(MessageCodeUtil
                                  .CONFIRM_TRANSFER_MUCH_THAN_IN_STOCK));
                          if (confirmResult != null && !confirmResult) {
                            return;
                          }
                        }
                        String result = await controller.updateTransfer();
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

  ListView _buildMobile(TransferController controller) {
    const double widthTitle = 70;
    const double widthForm = kMobileWidth -
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
          ItemTransfer itemTransfer = controller.listItem[index];
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
                  child: buildSelectItem(index),
                ),
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
                                    ItemManager()
                                            .getItemById(itemTransfer.id!)
                                            ?.unit ??
                                        MessageCodeUtil.NO),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //from
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_FROM_WAREHOUSE),
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
                                                itemTransfer.id!,
                                                itemTransfer.fromWarehouse!,
                                                true),
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemTransfer.fromWarehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setFromWarehouse(
                                              index, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneFromWarehouse(
                                          itemTransfer.fromWarehouse!);
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
                        DataCell(Container(
                            padding: const EdgeInsets.only(
                                right:
                                    SizeManagement.cardInsideHorizontalPadding +
                                        30),
                            width: widthForm,
                            child: ChangeNotifierProvider.value(
                              value: controller.rebuildStock[index],
                              child: Consumer<RebuildNumber>(
                                builder: (_, rebuild, __) {
                                  num stockAmount = WarehouseManager()
                                          .getWarehouseByName(
                                              itemTransfer.fromWarehouse!)
                                          ?.getAmountOfItem(itemTransfer.id!) ??
                                      0;
                                  return NeutronTextContent(
                                    color: controller
                                            .isTransferMuchThanInStock(index)
                                        ? ColorManagement.negativeText
                                        : ColorManagement.positiveText,
                                    textAlign: TextAlign.end,
                                    message: NumberUtil.numberFormat
                                        .format(stockAmount),
                                  );
                                },
                              ),
                            ))),
                      ]),
                      //to
                      DataRow(cells: [
                        DataCell(SizedBox(
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TO_WAREHOUSE),
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
                                                itemTransfer.id!,
                                                itemTransfer.toWarehouse!,
                                                true),
                                        valueFirst: UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                        value: itemTransfer.toWarehouse!,
                                        onChange: (value) {
                                          GeneralManager().unfocus(context);
                                          controller.setToWarehouse(
                                              index, value);
                                        })),
                                SizedBox(
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      controller.cloneToWarehouse(
                                          itemTransfer.toWarehouse!);
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
                          width: widthTitle,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT),
                          ),
                        )),
                        DataCell(
                          Container(
                            width: widthForm,
                            padding: const EdgeInsets.only(right: 30),
                            alignment: Alignment.centerRight,
                            child: controller.inputAmounts[index].buildWidget(
                                padding: 0,
                                readOnly: itemTransfer.id ==
                                    MessageCodeUtil.CHOOSE_ITEM,
                                textAlign: TextAlign.end,
                                onChanged: (String value) {
                                  controller.onChangeAmount(index);
                                },
                                hint: '0',
                                isDecor: true,
                                isDouble: true),
                          ),
                        ),
                      ]),
                    ]),
              )
            ],
          );
        }));
  }

  Widget _buildPC(TransferController controller, BuildContext context) {
    const double widthUnit = 70;
    const double widthAmount = 80;
    const double widthDropdown = 125;
    const double widthTrailingIcon = 40;
    const double widthColumnSpace = 8;
    const double widthStock = 80;
    const double widthName = 750 -
        widthUnit -
        widthAmount -
        widthStock -
        widthDropdown * 2 -
        widthColumnSpace * 5 -
        widthTrailingIcon * 2 -
        SizeManagement.cardOutsideHorizontalPadding * 2;

    return SingleChildScrollView(
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columnSpacing: widthColumnSpace,
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
            //from
            DataColumn(
                label: SizedBox(
              width: widthDropdown,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_FROM_WAREHOUSE),
              ),
            )),
            //stock
            DataColumn(
                label: SizedBox(
              width: widthStock,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_INVENTORY),
              ),
            )),
            //to
            DataColumn(
                label: SizedBox(
              width: widthDropdown,
              child: NeutronTextTitle(
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_TO_WAREHOUSE),
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
            //remove button
            DataColumn(
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REMOVE_ALL),
              label: SizedBox(
                  width: widthTrailingIcon,
                  child: InkWell(
                    child: const Icon(Icons.playlist_remove_sharp),
                    onTap: () {
                      controller.removeAllItem();
                    },
                  )),
            ),
          ],
          rows: controller.listItem.map((itemTransfer) {
            int index = controller.listItem.indexOf(itemTransfer);
            return DataRow(
              cells: [
                //item
                DataCell(
                  SizedBox(width: widthName, child: buildSelectItem(index)),
                ),
                //unit
                DataCell(
                  Container(
                    alignment: Alignment.center,
                    width: widthUnit,
                    child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          ItemManager().getItemById(itemTransfer.id!)?.unit ??
                              MessageCodeUtil.NO),
                    ),
                  ),
                ),
                //from
                DataCell(
                  SizedBox(
                    width: widthDropdown,
                    child: Row(
                      children: [
                        Expanded(
                            child: NeutronSearchDropDown(
                                backgroundColor: ColorManagement.mainBackground,
                                items: controller.getAvailabelWarehouseNames(
                                    itemTransfer.id!,
                                    itemTransfer.fromWarehouse!,
                                    true),
                                valueFirst:
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
                                value: itemTransfer.fromWarehouse!,
                                onChange: (value) {
                                  GeneralManager().unfocus(context);
                                  controller.setFromWarehouse(index, value);
                                })),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller.cloneFromWarehouse(
                                  itemTransfer.fromWarehouse!);
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
                      child: ChangeNotifierProvider.value(
                        value: controller.rebuildStock[index],
                        child: Consumer<RebuildNumber>(
                          builder: (_, rebuild, __) {
                            num stockAmount = WarehouseManager()
                                    .getWarehouseByName(
                                        itemTransfer.fromWarehouse!)
                                    ?.getAmountOfItem(itemTransfer.id!) ??
                                0;
                            return NeutronTextContent(
                              color: controller.isTransferMuchThanInStock(index)
                                  ? ColorManagement.negativeText
                                  : ColorManagement.positiveText,
                              textAlign: TextAlign.end,
                              message:
                                  NumberUtil.numberFormat.format(stockAmount),
                            );
                          },
                        ),
                      )),
                ),
                //to
                DataCell(
                  SizedBox(
                    width: widthDropdown,
                    child: Row(
                      children: [
                        Expanded(
                            child: NeutronSearchDropDown(
                                backgroundColor: ColorManagement.mainBackground,
                                items: controller.getAvailabelWarehouseNames(
                                    itemTransfer.id!,
                                    itemTransfer.toWarehouse!,
                                    true),
                                valueFirst:
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
                                value: itemTransfer.toWarehouse!,
                                onChange: (value) {
                                  GeneralManager().unfocus(context);
                                  controller.setToWarehouse(index, value);
                                })),
                        SizedBox(
                          width: 30,
                          child: InkWell(
                            onTap: () {
                              controller
                                  .cloneToWarehouse(itemTransfer.toWarehouse!);
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
                        readOnly:
                            itemTransfer.id == MessageCodeUtil.CHOOSE_ITEM,
                        textAlign: TextAlign.end,
                        onChanged: (String value) {
                          controller.onChangeAmount(index);
                        },
                        hint: '0',
                        isDecor: true,
                        isDouble: true),
                  ),
                ),
                //remove
                DataCell(
                    SizedBox(
                      width: widthTrailingIcon,
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

  Widget buildSelectItem(int index) {
    ItemTransfer itemTransfer = transferController!.listItem[index];

    return NeutronSearchDropDown(
        backgroundColor: ColorManagement.mainBackground,
        items: transferController!.getListAvailabelItem(),
        valueFirst: MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_ITEM),
        value: itemTransfer.id == MessageCodeUtil.CHOOSE_ITEM
            ? ''
            : ItemManager().getItemNameByID(itemTransfer.id!)!,
        onChange: (value) {
          GeneralManager().unfocus(context);
          transferController!.setItemId(index, value);
        });
  }
}
