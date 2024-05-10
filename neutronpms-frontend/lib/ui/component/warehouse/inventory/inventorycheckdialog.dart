import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/warehouse/inventorycontroller.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutronbuttontext.dart';
import 'package:ihotel/ui/controls/neutrondropdowsearch.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/suppliermanager.dart';
import '../../../../modal/warehouse/inventory/warehousechecknote.dart';
import '../../../../modal/warehouse/warehouse.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondropdown.dart';

class InventoryCheckDialog extends StatefulWidget {
  final Warehouse? priorityWarehouse;
  final WarehouseNote? inventory;
  final WarehouseNotesManager? warehouseNotesManager;

  const InventoryCheckDialog({
    Key? key,
    this.inventory,
    this.warehouseNotesManager,
    this.priorityWarehouse,
  }) : super(key: key);

  @override
  State<InventoryCheckDialog> createState() => _InventoryCheckDialogState();
}

class _InventoryCheckDialogState extends State<InventoryCheckDialog> {
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
  InventoryCheckController? inventoryCheckController;

  @override
  void initState() {
    super.initState();
    inventoryCheckController = InventoryCheckController(
        widget.inventory == null
            ? null
            : widget.inventory as WarehouseNoteCheck,
        widget.warehouseNotesManager!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            width: isNotDesktop ? kMobileWidth : 1000,
            height: kHeight,
            child: inventoryCheckController!.isInProgress!
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor),
                  )
                : Column(
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
                                UITitleCode.HEADER_INVENTORY_CHECKLIST)),
                      ),
                      //invoice and progress bar
                      Padding(
                        padding: const EdgeInsets.only(
                            top: SizeManagement.cardOutsideVerticalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                        controller: inventoryCheckController!
                                            .invoiceNumber,
                                        isDecor: true,
                                      )),
                                ],
                              ),
                              ProgressBar(
                                inventoryCheckController:
                                    inventoryCheckController!,
                              )
                            ]
                          ],
                        ),
                      ),
                      if (isNotDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeutronTextContent(
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}:'),
                            const SizedBox(
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            SizedBox(
                                width: 150,
                                height: 45,
                                child: NeutronTextFormField(
                                  controller:
                                      inventoryCheckController!.invoiceNumber,
                                  isDecor: true,
                                )),
                          ],
                        ),
                      const Divider(color: Colors.white),
                      // note info
                      Expanded(
                        child: NoteInformation(
                            inventoryCheckController: inventoryCheckController!,
                            isNotDesktop: isNotDesktop),
                      ),
                      BuildPagination(
                          inventoryCheckController: inventoryCheckController!),
                      const Divider(
                        color: Colors.white,
                      ),
                      BuildButton(
                          inventoryCheckController: inventoryCheckController!,
                          note: widget.inventory == null
                              ? null
                              : widget.inventory as WarehouseNoteCheck),
                    ],
                  )));
  }
}

class BuildPagination extends StatelessWidget {
  const BuildPagination({
    Key? key,
    required this.inventoryCheckController,
  }) : super(key: key);

  final InventoryCheckController inventoryCheckController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              inventoryCheckController.previousPage();
            },
            child: Icon(
              Icons.skip_previous,
              color: inventoryCheckController.pageIndex! >= 0
                  ? ColorManagement.iconMenuEnableColor
                  : ColorManagement.iconMenuDisableColor,
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () {
              inventoryCheckController.nextPage();
            },
            child: const Icon(Icons.skip_next,
                color: ColorManagement.iconMenuEnableColor),
          )
        ],
      ),
    );
  }
}

class BuildButton extends StatelessWidget {
  const BuildButton({
    Key? key,
    required this.inventoryCheckController,
    this.note,
  }) : super(key: key);

  final InventoryCheckController inventoryCheckController;
  final WarehouseNoteCheck? note;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InventoryCheckController>.value(
      value: inventoryCheckController,
      child: Consumer<InventoryCheckController>(
        builder: (_, controller, __) =>
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          controller.status == InventorySatus.CREATELIST
              ? NeutronTextButton(
                  message: UITitleUtil.getTitleByCode(UITitleCode.CONFIRM_LIST),
                  onPressed: () async {
                    String result;
                    if (controller.listItem.isNotEmpty &&
                        controller.invoiceNumber!.text.trim() != '') {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => const Center(
                            child: CircularProgressIndicator(
                                color: ColorManagement.greenColor)),
                      );
                      result = await controller.updateNote(false);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      if (result == MessageCodeUtil.SUCCESS ||
                          result == MessageCodeUtil.STILL_NOT_CHANGE_VALUE) {
                        controller.changeStatus(InventorySatus.CHECKING);
                      } else {
                        // ignore: use_build_context_synchronously
                        MaterialUtil.showResult(
                            context, MessageUtil.getMessageByCode(result));
                      }
                    }
                  },
                  width: 100,
                )
              : controller.status == InventorySatus.CHECKING
                  ? Row(
                      children: [
                        NeutronSingleButton(
                            margin: const EdgeInsets.only(
                                bottom:
                                    SizeManagement.cardInsideVerticalPadding,
                                right:
                                    SizeManagement.cardInsideHorizontalPadding),
                            size: 42,
                            onPressed: () {
                              ExcelUlti.exportInventoryChecklist(note ??
                                  WarehouseNoteCheck(
                                      list: controller.listItem,
                                      warehouse: controller.warehouse,
                                      invoiceNumber:
                                          controller.invoiceNumber!.text));
                            },
                            icon: Icons.download),
                        NeutronTextButton(
                          message: UITitleUtil.getTitleByCode(UITitleCode.BACK),
                          onPressed: () async {
                            controller.changeStatus(InventorySatus.CREATELIST);
                          },
                          width: 100,
                        ),
                        NeutronTextButton(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.FINISH_INENTORY_CHECK),
                          onPressed: controller.inputActualInventory
                                      .where((element) =>
                                          element.controller.text == '')
                                      .length ==
                                  controller.inputActualInventory.length
                              ? () {}
                              : () async {
                                  String checkingResult =
                                      controller.completeChecking();
                                  bool? result = true;
                                  if (checkingResult ==
                                      MessageCodeUtil.SUCCESS) {
                                    controller.setChecker();
                                    controller
                                        .changeStatus(InventorySatus.CHECKED);
                                  } else {
                                    result = await MaterialUtil.showConfirm(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            checkingResult),
                                        UITitleUtil.getTitleByCode(UITitleCode
                                            .BUTTON_TEXT_ENTER_ACTUAL_INVENTORY),
                                        UITitleUtil.getTitleByCode(UITitleCode
                                            .BUTTON_TEXT_REMOVE_FROM_CHECKLIST),
                                        false);
                                  }
                                  if (!result!) {
                                    controller.removeFromCheckList();
                                    controller.setChecker();
                                    controller
                                        .changeStatus(InventorySatus.CHECKED);
                                  }
                                },
                          width: 100,
                        )
                      ],
                    )
                  : controller.status == InventorySatus.CHECKED
                      ? controller.checkDifference()
                          ? Row(
                              children: [
                                NeutronTextButton(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.BACK),
                                  onPressed: () async {
                                    controller
                                        .changeStatus(InventorySatus.CHECKING);
                                  },
                                  width: 100,
                                ),
                                NeutronTextButton(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.CONFIRM_INVENTORY_BALANCE),
                                  onPressed: () async {
                                    bool? optionResult = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ChooseBalanceMethod(),
                                    );
                                    String? result;
                                    if (optionResult != null) {
                                      if (optionResult) {
                                        bool? confirmBalance =
                                            // ignore: use_build_context_synchronously
                                            await MaterialUtil.showConfirm(
                                                context,
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode
                                                        .INVENTORY_QUANTITY_CHANGE_ALERT));
                                        if (confirmBalance!) {
                                          if (controller.warehouseActions[
                                                      controller.warehouse] ==
                                                  WarehouseActionType.IMPORT ||
                                              controller.warehouseActions[
                                                      controller.warehouse] ==
                                                  WarehouseActionType.BOTH) {
                                            controller.initImportDialog();
                                            // ignore: use_build_context_synchronously
                                            result = await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  InputImportNoteDialog(
                                                      inventoryCheckController:
                                                          controller),
                                            );
                                          } else {
                                            result = await controller
                                                .updateNote(true);
                                          }
                                        }
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) => const Center(
                                              child: CircularProgressIndicator(
                                                  color: ColorManagement
                                                      .greenColor)),
                                        );
                                        result =
                                            await controller.updateNote(false);
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      }
                                      if (result != null) {
                                        // ignore: use_build_context_synchronously
                                        MaterialUtil.showResult(
                                            context,
                                            MessageUtil.getMessageByCode(
                                                result));
                                      }
                                      if (result == '') {
                                        controller.changeStatus(
                                            InventorySatus.BALANCED);
                                      }
                                    }
                                  },
                                  width: 100,
                                ),
                              ],
                            )
                          : NeutronTextButton(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DONE),
                              onPressed: () async {
                                controller
                                    .changeStatus(InventorySatus.BALANCED);
                              },
                              width: 100,
                            )
                      : NeutronTextButton(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.INVENTORY_FINISH),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          width: 100,
                        ),
        ]),
      ),
    );
  }
}

class InputImportNoteDialog extends StatelessWidget {
  final InventoryCheckController? inventoryCheckController;
  const InputImportNoteDialog({
    Key? key,
    this.inventoryCheckController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: isNotDesktop ? kMobileWidth : kWidth,
        height: kHeight,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: kWidth,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: NeutronTextTitle(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.IMPORT_NOTE),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              child: ChangeNotifierProvider<InventoryCheckController>.value(
                value: inventoryCheckController!,
                child: Consumer<InventoryCheckController>(
                  builder: (context, controller, child) => DataTable(
                    columns: [
                      DataColumn(
                          label: SizedBox(
                        width: 150,
                        child: NeutronTextTitle(
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM),
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 150,
                        child: NeutronTextTitle(
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_SUPPLIER),
                        ),
                      )),
                      DataColumn(
                          label: SizedBox(
                        width: 100,
                        child: NeutronTextTitle(
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ),
                      )),
                    ],
                    rows: controller
                        .getListImport()
                        .map(
                          (e) => DataRow(cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: NeutronTextContent(
                                  message:
                                      ItemManager().getItemNameByID(e.id!)!,
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: SizedBox(
                                  width: 150,
                                  child: NeutronDropDown(
                                    items: [
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.NO),
                                      ...SupplierManager()
                                          .getActiveSupplierNames()
                                    ],
                                    value: e.supplierId != null
                                        ? SupplierManager()
                                            .getSupplierNameByID(e.supplierId)
                                        : UITitleUtil.getTitleByCode(
                                            UITitleCode.NO),
                                    onChanged: (value) {
                                      controller.chooseSupplierForImport(
                                          value, e);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: SizedBox(
                                  width: 100,
                                  child: controller.inputPrice[
                                          controller.getListImport().indexOf(e)]
                                      .buildWidget(
                                          color: ColorManagement
                                              .lightMainBackground,
                                          onChanged: (String value) {
                                            controller.setPrice(value, e);
                                          },
                                          textAlign: TextAlign.center,
                                          isDecor: true),
                                ),
                              ),
                            )
                          ]),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: kWidth,
                child: NeutronButton(
                  onPressed: () async {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) => const Dialog(
                          backgroundColor: ColorManagement.mainBackground,
                          child: SizedBox(
                            width: kWidth,
                            height: kHeight,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: ColorManagement.greenColor),
                            ),
                          )),
                    );
                    String result =
                        await inventoryCheckController!.updateNote(true);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    if (result == '') {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, result);
                    } else {
                      // ignore: use_build_context_synchronously
                      MaterialUtil.showResult(
                          context, MessageUtil.getMessageByCode(result));
                    }
                  },
                  icon: Icons.save,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChooseBalanceMethod extends StatelessWidget {
  const ChooseBalanceMethod({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 180,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: NeutronTextTitle(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_BALANCE_METHOD),
              ),
            ),
            const SizedBox(
              height: SizeManagement.rowSpacing,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: ColorManagement.greenColor),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(FontAwesomeIcons.scaleBalanced, size: 18),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.INVENTORY_ONLY_BALANCE),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: ColorManagement.greenColor),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(FontAwesomeIcons.fileInvoice, size: 18),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.INVENTORY_BALANCE_AND_CREATE_NOTE),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NoteInformation extends StatelessWidget {
  const NoteInformation({
    Key? key,
    required this.inventoryCheckController,
    required this.isNotDesktop,
  }) : super(key: key);

  final InventoryCheckController inventoryCheckController;
  final bool isNotDesktop;

  final ScrollPhysics scrollPhysics = const ClampingScrollPhysics();
  final double widthOrdinalNumbers = 30;
  final double widthName = 200;
  final double widthUnit = 100;
  final double widthInventory = 100;
  final double widthActualInventory = 100;
  final double widthNote = 150;
  final double widthDelete = 70;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: inventoryCheckController,
      child: Consumer<InventoryCheckController>(
        builder: (_, controller, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isNotDesktop)
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1200),
                    reverseDuration: const Duration(milliseconds: 1200),
                    switchInCurve: Curves.easeInOutExpo,
                    switchOutCurve: Curves.easeInOutExpo,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(animation);
                      return SlideTransition(
                        position: offset,
                        child: child,
                      );
                    },
                    child: controller.status == InventorySatus.CREATELIST
                        ? SearchForPC(controller: controller)
                        : NoteInfoInPC(controller: controller)),
              if (isNotDesktop &&
                  controller.status == InventorySatus.CREATELIST) ...[
                SearchForMobile(controller: controller),
                const Divider(
                  color: Colors.white,
                ),
              ],
              isNotDesktop ? listForMobile(controller) : listForPc(controller),
            ],
          );
        },
      ),
    );
  }

  Expanded listForMobile(InventoryCheckController controller) {
    return Expanded(
        child: SingleChildScrollView(
      child: Column(
          children: controller
              .getSubList()
              .map((item) => Card(
                    margin: const EdgeInsets.all(4),
                    color: ColorManagement.lightMainBackground,
                    child: ExpansionTile(
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      leading: NeutronTextContent(
                        message:
                            (controller.listItem.indexOf(item) + 1).toString(),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 3,
                            child: NeutronTextContent(
                              message: ItemManager().getItemNameByID(item.id!)!,
                              tooltip: ItemManager().getItemNameByID(item.id!),
                            ),
                          ),
                          if (controller.status == InventorySatus.CREATELIST)
                            Expanded(
                              child: IconButton(
                                  color: ColorManagement.redColor,
                                  onPressed: () {
                                    controller.removeItem(
                                        item, controller.listItem);
                                  },
                                  icon: const Icon(Icons.delete)),
                            )
                        ],
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: NeutronTextContent(
                                fontSize: 14,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT)} :',
                              ),
                            ),
                            Expanded(
                              child: NeutronTextContent(
                                fontSize: 14,
                                message: MessageUtil.getMessageByCode(
                                    ItemManager().getItemById(item.id!)?.unit ??
                                        MessageCodeUtil.NO),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.columnSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: NeutronTextContent(
                                fontSize: 14,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVENTORY)} :',
                              ),
                            ),
                            Expanded(
                              child: NeutronTextContent(
                                fontSize: 14,
                                message: Decimal.tryParse(item.amount != null
                                        ? item.amount.toString()
                                        : WarehouseManager()
                                            .getWarehouseById(
                                                controller.warehouse)!
                                            .items![item.id]
                                            .toString())
                                    .toString(),
                                tooltip: Decimal.tryParse(item.amount != null
                                        ? item.amount.toString()
                                        : WarehouseManager()
                                            .getWarehouseById(
                                                controller.warehouse)!
                                            .items![item.id]
                                            .toString())
                                    .toString(),
                              ),
                            )
                          ],
                        ),
                        if (controller.status != InventorySatus.CREATELIST) ...[
                          const SizedBox(
                            height: SizeManagement.columnSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: NeutronTextContent(
                                  fontSize: 14,
                                  message:
                                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACTUAL_INVENTORY)} :',
                                ),
                              ),
                              Expanded(
                                child: controller.status ==
                                        InventorySatus.BALANCED
                                    ? NeutronTextContent(
                                        message: Decimal.tryParse(
                                                item.actualAmount.toString())
                                            .toString(),
                                        tooltip: Decimal.tryParse(
                                                item.actualAmount.toString())
                                            .toString(),
                                      )
                                    : controller.inputActualInventory[
                                            controller.listItem.indexOf(item)]
                                        .buildWidget(
                                            isDouble: true,
                                            readOnly: controller.status !=
                                                InventorySatus.CHECKING,
                                            onChanged: (String value) {
                                              controller.enterActualInventory(
                                                  value,
                                                  controller.listItem
                                                      .indexOf(item));
                                            },
                                            textAlign: TextAlign.start,
                                            isDecor: true),
                              ),
                            ],
                          ),
                          if (controller.status == InventorySatus.CHECKED ||
                              controller.status == InventorySatus.BALANCED) ...[
                            const SizedBox(
                              height: SizeManagement.columnSpacing,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: NeutronTextContent(
                                    fontSize: 14,
                                    message:
                                        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DIFFERENCE)} :',
                                  ),
                                ),
                                Expanded(
                                    child: NeutronTextContent(
                                  message: Decimal.tryParse(
                                          (item.actualAmount! - item.amount!)
                                              .toString())
                                      .toString(),
                                  tooltip: Decimal.tryParse(
                                          (item.actualAmount! - item.amount!)
                                              .toString())
                                      .toString(),
                                )),
                              ],
                            ),
                          ],
                          const SizedBox(
                            height: SizeManagement.columnSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: NeutronTextContent(
                                  fontSize: 14,
                                  message:
                                      '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)} :',
                                ),
                              ),
                              Expanded(
                                child: controller.status ==
                                        InventorySatus.BALANCED
                                    ? NeutronTextContent(
                                        message: item.note ?? '',
                                      )
                                    : NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: controller.status !=
                                            InventorySatus.CHECKING,
                                        textAlign: TextAlign.start,
                                        controller: controller.inputNotes[
                                            controller.listItem.indexOf(item)],
                                        onChanged: (String value) {
                                          controller.enterItemNote(
                                              value,
                                              controller.listItem
                                                  .indexOf(item));
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ))
              .toList()),
    ));
  }

  Expanded listForPc(InventoryCheckController controller) {
    return Expanded(
      child: AnimatedSwitcher(
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                currentChild!,
              ],
            );
          },
          duration: const Duration(milliseconds: 1200),
          reverseDuration: const Duration(milliseconds: 1200),
          switchInCurve: Curves.easeInOutExpo,
          switchOutCurve: Curves.easeInOutExpo,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.0, 10.0),
              end: const Offset(0.0, 0.0),
            ).animate(animation);
            return SlideTransition(
              position: offset,
              child: child,
            );
          },
          child: controller.status == InventorySatus.CREATELIST
              ? buildListCreate(controller)
              : controller.status == InventorySatus.CHECKING
                  ? buildListChecking(controller)
                  : controller.status == InventorySatus.CHECKED
                      ? buildListBalance(controller)
                      : buildListFinish(controller)),
    );
  }

  SingleChildScrollView buildListCreate(InventoryCheckController controller) {
    final ScrollController scrollController =
        ScrollController(keepScrollOffset: true);

    return SingleChildScrollView(
      key: const Key('create list'),
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
            columns: [
              DataColumn(
                  label: SizedBox(
                width: widthOrdinalNumbers,
                child: const NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: '',
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthName,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
                ),
              )),
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
              DataColumn(
                  label: SizedBox(
                width: widthInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthDelete,
                child: const NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: '',
                ),
              )),
            ],
            rows: controller.listItem
                .sublist(controller.startIndex!, controller.endIndex)
                .map((item) => DataRow(cells: [
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthOrdinalNumbers,
                          child: NeutronTextContent(
                            message: (controller.listItem.indexOf(item) + 1)
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthName,
                          child: NeutronTextContent(
                            message: ItemManager().getItemNameByID(item.id!)!,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthUnit,
                          child: NeutronTextContent(
                            message: MessageUtil.getMessageByCode(
                                ItemManager().getItemById(item.id!)!.unit ??
                                    ' '),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthInventory,
                          child: NeutronTextContent(
                            message: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                            tooltip: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthDelete,
                          child: NeutronButton(
                              icon: Icons.delete,
                              onPressed: () {
                                controller.removeItem(
                                    item, controller.listItem);
                              }),
                        ),
                      ),
                    ]))
                .toList()),
      ),
    );
  }

  SingleChildScrollView buildListChecking(InventoryCheckController controller) {
    final ScrollController scrollController =
        ScrollController(keepScrollOffset: true);

    return SingleChildScrollView(
      key: const Key('checking list'),
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
            columns: [
              DataColumn(
                  label: SizedBox(
                width: widthOrdinalNumbers,
                child: const NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: '',
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthName,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
                ),
              )),
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
              DataColumn(
                  label: SizedBox(
                width: widthInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ACTUAL_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthDelete,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
                ),
              )),
            ],
            rows: controller.listItem
                .sublist(controller.startIndex!, controller.endIndex)
                .map((item) => DataRow(cells: [
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthOrdinalNumbers,
                          child: NeutronTextContent(
                            message: (controller.listItem.indexOf(item) + 1)
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthName,
                          child: NeutronTextContent(
                            message: ItemManager().getItemNameByID(item.id!)!,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthUnit,
                          child: NeutronTextContent(
                            message: MessageUtil.getMessageByCode(
                                ItemManager().getItemById(item.id!)?.unit ??
                                    MessageCodeUtil.NO),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthInventory,
                          child: NeutronTextContent(
                            message: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                            tooltip: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthActualInventory,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: controller.inputActualInventory[
                                    controller.listItem.indexOf(item)]
                                .buildWidget(
                                    isDouble: true,
                                    onChanged: (String value) {
                                      controller.enterActualInventory(value,
                                          controller.listItem.indexOf(item));
                                    },
                                    textAlign: TextAlign.center,
                                    isDecor: true),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthNote,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextFormField(
                              isDecor: true,
                              textAlign: TextAlign.start,
                              controller: controller.inputNotes[
                                  controller.listItem.indexOf(item)],
                              onChanged: (String value) {
                                controller.enterItemNote(
                                    value, controller.listItem.indexOf(item));
                              },
                            ),
                          ),
                        ),
                      ),
                    ]))
                .toList()),
      ),
    );
  }

  SingleChildScrollView buildListBalance(InventoryCheckController controller) {
    final ScrollController scrollController =
        ScrollController(keepScrollOffset: true);

    return SingleChildScrollView(
      key: const Key('balance list'),
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
            columns: [
              DataColumn(
                  label: SizedBox(
                width: widthOrdinalNumbers,
                child: const NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: '',
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthName,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
                ),
              )),
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
              DataColumn(
                  label: SizedBox(
                width: widthInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ACTUAL_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: widthActualInventory,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DIFFERENCE),
                ),
              )),
            ],
            rows: controller.listItem
                .sublist(controller.startIndex!, controller.endIndex)
                .map((item) => DataRow(cells: [
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthOrdinalNumbers,
                          child: NeutronTextContent(
                            message: (controller.listItem.indexOf(item) + 1)
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthName,
                          child: NeutronTextContent(
                            message: ItemManager().getItemNameByID(item.id!)!,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthUnit,
                          child: NeutronTextContent(
                            message: MessageUtil.getMessageByCode(
                                ItemManager().getItemById(item.id!)?.unit ??
                                    MessageCodeUtil.NO),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthInventory,
                          child: NeutronTextContent(
                            message: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                            tooltip: Decimal.tryParse(WarehouseManager()
                                    .getWarehouseById(controller.warehouse)!
                                    .items![item.id]
                                    .toString())
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthActualInventory,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextContent(
                              message: controller
                                  .inputActualInventory[
                                      controller.listItem.indexOf(item)]
                                  .controller
                                  .text,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthActualInventory,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextContent(
                              message:
                                  '${Decimal.tryParse((WarehouseManager().getWarehouseById(controller.warehouse)!.items![item.id] - controller.inputActualInventory[controller.listItem.indexOf(item)].getNumber()).toString())}',
                              tooltip:
                                  '${Decimal.tryParse((WarehouseManager().getWarehouseById(controller.warehouse)!.items![item.id] - controller.inputActualInventory[controller.listItem.indexOf(item)].getNumber()).toString())}',
                            ),
                          ),
                        ),
                      ),
                    ]))
                .toList()),
      ),
    );
  }

  SingleChildScrollView buildListFinish(InventoryCheckController controller) {
    final ScrollController scrollController =
        ScrollController(keepScrollOffset: true);

    return SingleChildScrollView(
      key: const Key('finish list'),
      controller: scrollController,
      physics: scrollPhysics,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
            columns: [
              DataColumn(
                  label: SizedBox(
                width: widthOrdinalNumbers,
                child: const NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: '',
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 170,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 50,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 70,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 70,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ACTUAL_INVENTORY),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 70,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DIFFERENCE),
                ),
              )),
              DataColumn(
                  label: SizedBox(
                width: 150,
                child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  message: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
                ),
              ))
            ],
            rows: controller.listItem
                .sublist(controller.startIndex!, controller.endIndex)
                .map((item) => DataRow(cells: [
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: widthOrdinalNumbers,
                          child: NeutronTextContent(
                            message: (controller.listItem.indexOf(item) + 1)
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 170,
                          child: NeutronTextContent(
                            message: ItemManager().getItemNameByID(item.id!)!,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 50,
                          child: NeutronTextContent(
                            message: MessageUtil.getMessageByCode(
                                ItemManager().getItemById(item.id!)?.unit ??
                                    ' '),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: NeutronTextContent(
                            message: Decimal.tryParse((item.amount ??
                                        (WarehouseManager()
                                            .getWarehouseById(
                                                controller.warehouse)!
                                            .items![item.id] as double))
                                    .toString())
                                .toString(),
                            tooltip: Decimal.tryParse((item.amount ??
                                        (WarehouseManager()
                                            .getWarehouseById(
                                                controller.warehouse)!
                                            .items![item.id] as double))
                                    .toString())
                                .toString(),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextContent(
                              message: Decimal.tryParse(item.actualAmount
                                          ?.toString() ??
                                      controller
                                          .inputActualInventory[
                                              controller.listItem.indexOf(item)]
                                          .controller
                                          .text)
                                  .toString(),
                              tooltip: Decimal.tryParse(item.actualAmount
                                          ?.toString() ??
                                      controller
                                          .inputActualInventory[
                                              controller.listItem.indexOf(item)]
                                          .controller
                                          .text)
                                  .toString(),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextContent(
                              message: Decimal.tryParse(
                                      (item.amount! - item.actualAmount!)
                                          .toString())
                                  .toString(),
                              tooltip: Decimal.tryParse(
                                      (item.amount! - item.actualAmount!)
                                          .toString())
                                  .toString(),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          alignment: Alignment.center,
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: NeutronTextContent(message: item.note ?? ''),
                          ),
                        ),
                      ),
                    ]))
                .toList()),
      ),
    );
  }
}

class NoteInfoInPC extends StatelessWidget {
  final InventoryCheckController? controller;
  const NoteInfoInPC({
    Key? key,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeutronTextContent(
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE)} : ${WarehouseManager().getWarehouseNameById(controller!.warehouse)}',
                ),
                NeutronTextContent(
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS)} : ${UITitleUtil.getTitleByCode(controller!.status!)}',
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeutronTextContent(
                  tooltip: controller!.creator,
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR)} : ${controller!.creator}',
                ),
                NeutronTextContent(
                  tooltip: controller!.checker,
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECKER)} : ${controller!.checker}',
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeutronTextContent(
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_TIME)} : ${controller!.createTime == null ? '' : DateUtil.dateToString(controller!.createTime!)}',
                ),
                NeutronTextContent(
                  message:
                      '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECK_TIME)} : ${controller!.checkTime == null ? '' : DateUtil.dateToString(controller!.checkTime!)}',
                ),
              ],
            ),
          ),
          Expanded(
            child: NeutronTextContent(
              message:
                  '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)} : ${controller!.note!.text.trim()}',
            ),
          ),
        ]),
      ),
    );
  }
}

class SearchForMobile extends StatelessWidget {
  const SearchForMobile({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final InventoryCheckController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeutronSearchDropDown(
              width: 130,
              onChange: controller.setWarehouse,
              backgroundColor: ColorManagement.mainBackground,
              hint: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE),
              value: controller.warehouse ==
                      UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE
                  ? UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE)
                  : WarehouseManager()
                      .getWarehouseNameById(controller.warehouse)!,
              items: controller.getAvailabelWarehouseNames(),
              valueFirst: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE),
              label:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE),
            ),
            SizedBox(
                width: 110,
                height: 50,
                child: NeutronTextFormField(
                  maxLine: 4,
                  label: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
                  controller: controller.note,
                  isDecor: true,
                )),
          ],
        ),
        const SizedBox(
          height: SizeManagement.columnSpacing,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeutronSearchDropDown(
              width: 250,
              onChange: controller.chooseItemToList,
              backgroundColor: ColorManagement.mainBackground,
              hint: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_CHOOSE_ITEM),
              value: controller.item,
              items: controller.getListItemNameOfWarehouse(),
              valueFirst: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_CHOOSE_ITEM),
              label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
            ),
          ],
        ),
      ],
    );
  }
}

class SearchForPC extends StatelessWidget {
  const SearchForPC({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final InventoryCheckController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 250,
          child: NeutronSearchDropDown(
            width: 250,
            onChange: controller.setWarehouse,
            backgroundColor: ColorManagement.mainBackground,
            hint: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE),
            value:
                controller.warehouse == UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE
                    ? UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE)
                    : WarehouseManager()
                        .getWarehouseNameById(controller.warehouse)!,
            items: controller.getAvailabelWarehouseNames(),
            valueFirst: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE),
            label:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE),
          ),
        ),
        Container(
            width: 250,
            height: 50,
            margin: const EdgeInsets.all(8),
            child: NeutronTextFormField(
              label: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
              controller: controller.note,
              isDecor: true,
            )),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: NeutronSearchDropDown(
                restInput: true,
                width: 250,
                onChange: controller.chooseItemToList,
                backgroundColor: ColorManagement.mainBackground,
                hint: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_CHOOSE_ITEM),
                value: controller.item,
                items: controller.getListItemNameOfWarehouse(),
                valueFirst: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_CHOOSE_ITEM),
                label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
              ),
            ),
            NeutronTextButton(
              isUpperCase: false,
              margin: const EdgeInsets.all(2),
              onPressed: () {
                if (controller.warehouse !=
                    UITitleCode.TABLEHEADER_CHOOSE_WAREHOUSE) {
                  showDialog(
                    context: context,
                    builder: (context) => AddMultipleItem(
                      controller: controller,
                    ),
                  );
                }
              },
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.HEADER_INVENTORY_ADD_MULTIPLE),
              width: 120,
            )
          ],
        ),
      ],
    );
  }
}

class AddMultipleItem extends StatelessWidget {
  final InventoryCheckController controller;

  const AddMultipleItem({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.initChooseMultiple();
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);
    TextEditingController textEditingController =
        TextEditingController(text: '');

    return ChangeNotifierProvider<InventoryCheckController>.value(
      value: controller,
      child: Dialog(
        child: Container(
          width: isNotDesktop ? kMobileWidth : kLargeWidth,
          height: kHeight,
          decoration: const BoxDecoration(
            color: ColorManagement.lightMainBackground,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(
                    SizeManagement.cardInsideVerticalPadding),
                child: NeutronTextHeader(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.HEADER_INVENTORY_ADD_MULTIPLE_ITEM),
                ),
              ),
              const Divider(
                color: Colors.white12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 300,
                        child: Consumer<InventoryCheckController>(
                            builder: (_, value, __) => NeutronTextFormField(
                                  isDecor: true,
                                  backgroundColor:
                                      ColorManagement.mainBackground,
                                  controller: textEditingController,
                                  onChanged: value.search,
                                  textAlign: TextAlign.center,
                                  // suffixWidget: const Icon(Icons.search),
                                  // hint: UITitleUtil.getTitleByCode(
                                  //     UITitleCode.HINT_SEARCH_ITEM),
                                )),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.white12,
              ),
              Expanded(
                child: SizedBox(
                    height: 250,
                    width: kLargeWidth,
                    child: Consumer<InventoryCheckController>(
                        builder: (_, value, __) => Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(SizeManagement
                                        .cardInsideHorizontalPadding),
                                    child: GridView.builder(
                                      shrinkWrap: false,
                                      itemCount: value.tempList.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 3,
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                      ),
                                      itemBuilder: (context, index) {
                                        return TextButton(
                                            style: ButtonStyle(
                                                iconColor: MaterialStateProperty
                                                    .all<Color>(Colors.white),
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        ColorManagement
                                                            .greenColor)),
                                            onPressed: () {
                                              value.removeItem(
                                                  value.tempList[index],
                                                  value.tempList);
                                            },
                                            child: Text(
                                              ItemManager()
                                                  .getItemById(value
                                                      .tempList[index].id!)!
                                                  .name!,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ));
                                      },
                                    ),
                                  ),
                                ),
                                const VerticalDivider(
                                  color: Colors.white12,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(SizeManagement
                                        .cardInsideHorizontalPadding),
                                    child: Consumer<InventoryCheckController>(
                                      builder: (_, value, __) =>
                                          GridView.builder(
                                              shrinkWrap: false,
                                              itemCount: value.filter().length,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: 3,
                                                mainAxisSpacing: 8.0,
                                                crossAxisSpacing: 8.0,
                                              ),
                                              itemBuilder: (context, index) {
                                                return TextButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty.all<
                                                                    Color>(
                                                                ColorManagement
                                                                    .redColor)),
                                                    onPressed: () => value
                                                        .chooseItemToTempList(
                                                            value.filter()[
                                                                index]),
                                                    child: Text(
                                                      value.filter()[index],
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ));
                                              }),
                                    ),
                                  ),
                                ),
                              ],
                            ))),
              ),
              const Divider(
                color: Colors.white12,
              ),
              NeutronButton(
                icon: Icons.add_outlined,
                onPressed: () {
                  controller.addTempListToList();
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key? key,
    required this.inventoryCheckController,
  }) : super(key: key);
  final InventoryCheckController inventoryCheckController;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InventoryCheckController>.value(
      value: inventoryCheckController,
      child: Consumer<InventoryCheckController>(
        builder: (_, value, __) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: 450,
                  height: 5,
                  color: const Color.fromARGB(66, 191, 189, 189),
                ),
                ChangeNotifierProvider<InventoryCheckController>.value(
                  value: inventoryCheckController,
                  child: Consumer<InventoryCheckController>(
                      builder: (_, controller, __) => AnimatedContainer(
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.bounceOut,
                            width: controller.progressWidth,
                            height: 5,
                            color: ColorManagement.orangeColor,
                          )),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 8,
                ),
                const Positioned(
                  right: 150,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 8,
                  ),
                ),
                const Positioned(
                  right: 300,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 8,
                  ),
                ),
                const Positioned(
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: SizeManagement.rowSpacing,
            ),
            SizedBox(
              width: 500,
              height: 30,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.INVENTORY_CREATE_LIST),
                    ),
                  ),
                  Positioned(
                      left: 150,
                      child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.INVENTORY_CHECK),
                      )),
                  Positioned(
                      left: 300,
                      child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.INVENTORY_BALANCE),
                      )),
                  Positioned(
                      right: 5,
                      child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.INVENTORY_FINISH),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
