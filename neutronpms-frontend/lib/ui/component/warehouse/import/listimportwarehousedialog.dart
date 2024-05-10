import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/warehouse/warehousenote.dart';
import 'package:ihotel/modal/warehouse/warehousereturn/warehousenotereturn.dart';
import 'package:ihotel/ui/component/management/accounting/listcostsofimportnotedialog.dart';
import 'package:ihotel/ui/component/warehouse/import/importdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/swap_too_fast.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/roles.dart';
import '../../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronbutton.dart';
import '../../../controls/neutrondropdown.dart';
import '../../management/accounting/accountingdialog.dart';
import '../return_to_supplier/returntosupplier.dart';
import '../warehouseexceloption.dart';

class ListImportWarehouseDialog extends StatefulWidget {
  const ListImportWarehouseDialog({Key? key}) : super(key: key);

  @override
  State<ListImportWarehouseDialog> createState() =>
      _ListImportWarehouseDialogState();
}

class _ListImportWarehouseDialogState extends State<ListImportWarehouseDialog> {
  final WarehouseNotesManager warehouseNotesManager = WarehouseNotesManager();

  @override
  void initState() {
    warehouseNotesManager.initProperties(WarehouseNotesType.import);
    // warehouseNotesManager.getWarehouseNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return ChangeNotifierProvider<WarehouseNotesManager>.value(
        value: warehouseNotesManager,
        child: Consumer<WarehouseNotesManager>(builder: (_, controller, __) {
          if (controller.isInProgress == null) {
            return SwapTooFast(action: warehouseNotesManager.getWarehouseNotes);
          }

          if (controller.isInProgress!) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }
          return Scaffold(
            backgroundColor: ColorManagement.mainBackground,
            body: Stack(children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  padding: const EdgeInsets.all(
                      SizeManagement.cardInsideVerticalPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      buildSearch(controller, isNotDesktop),
                      if (isNotDesktop)
                        const SizedBox(
                          width: SizeManagement.columnSpacing,
                        ),
                      if (isNotDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: NeutronDropDown(
                                items: [
                                  UITitleUtil.getTitleByCode(UITitleCode.ALL),
                                  UITitleUtil.getTitleByCode(
                                      NoteTypesUlti.IMPORT),
                                  UITitleUtil.getTitleByCode(
                                      NoteTypesUlti.COMPENSATION),
                                  UITitleUtil.getTitleByCode(
                                      NoteTypesUlti.BALANCE)
                                ],
                                value: UITitleUtil.getTitleByCode(
                                    controller.importType),
                                onChanged: controller.setImportType,
                              ),
                            ),
                            const SizedBox(
                              width: SizeManagement.columnSpacing,
                            ),
                            Expanded(
                              child: NeutronDropDown(
                                items: [
                                  UITitleUtil.getTitleByCode(UITitleCode.ALL),
                                  UITitleUtil.getTitleByCode(
                                      NoteCostTypesUlti.COST),
                                  UITitleUtil.getTitleByCode(
                                      NoteCostTypesUlti.NOCOST)
                                ],
                                value: UITitleUtil.getTitleByCode(
                                    controller.hasCostFilter),
                                onChanged: controller.sethasCostFilter,
                              ),
                            ),
                            const SizedBox(
                              width: SizeManagement.columnSpacing,
                            ),
                            Expanded(
                              child: NeutronDropDown(
                                items: [
                                  UITitleUtil.getTitleByCode(UITitleCode.ALL),
                                  UITitleUtil.getTitleByCode(
                                      NoteCostTypesUlti.COST),
                                  UITitleUtil.getTitleByCode(
                                      NoteCostTypesUlti.NOCOST)
                                ],
                                value: UITitleUtil.getTitleByCode(
                                    controller.hasCostFilter),
                                onChanged: controller.sethasCostFilter,
                              ),
                            ),
                          ],
                        ),
                      if (!isNotDesktop) buildTitle(controller),
                      controller.data.isEmpty
                          ? Center(
                              child: NeutronTextContent(
                                  message: MessageUtil.getMessageByCode(
                                      MessageCodeUtil.NO_DATA)))
                          : Expanded(child: buildList(isNotDesktop, context)),
                      controller.data.isEmpty
                          ? Container()
                          : buildPagination(controller),
                    ],
                  )),
              //add-button
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                  icon1: Icons.add,
                  tooltip1: UITitleUtil.getTitleByCode(
                      UITitleCode.CREATE_IMPORT_NOTE),
                  onPressed1: () async {
                    if (!WarehouseManager().isHaveRoleInWareHouseImport()) {
                      MaterialUtil.showAlert(
                          context,
                          MessageUtil.getMessageByCode(MessageCodeUtil
                              .NOT_HAVE_PERMISSION_IMPORT_WAREHOUSE));
                      return;
                    }

                    final Map<String, dynamic>? result = await showDialog(
                        context: context,
                        builder: (context) => ImportDialog(
                              warehouseNotesManager: warehouseNotesManager,
                              isImportExcelFile: false,
                            ));

                    if (!mounted || result == null) {
                      return;
                    }

                    if (UserManager.role!.contains(Roles.accountant) ||
                        UserManager.canCRUDWarehouseNote()) {
                      // ignore: use_build_context_synchronously
                      final bool? confirmResult = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(MessageCodeUtil
                              .CONFIRM_CREATE_COST_MANAGEMENT_AFTER_IMPORT));

                      if (confirmResult == null || !confirmResult) {
                        return;
                      }
                      // ignore: use_build_context_synchronously
                      showDialog(
                          context: context,
                          builder: (context) => AddAccountingDialog(
                                inputData: result,
                              ));
                    }
                  },
                  icon2: Icons.note_add_outlined,
                  tooltip2: UITitleUtil.getTitleByCode(
                      UITitleCode.CREATE_IMPORT_NOTE_BY_EXCEL),
                  onPressed2: () {
                    showDialog(
                      context: context,
                      builder: (context) => ExcelOptionDialog(
                          controller: controller,
                          noteType: WarehouseNotesType.import),
                    );
                  },
                ),
              ),
            ]),
          );
        }));
  }

  Widget buildSearch(WarehouseNotesManager controller, bool isNotDesktop) =>
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 280,
          height: SizeManagement.cardHeight,
          child: TextFormField(
            controller: controller.queryString,
            style: const TextStyle(
              color: ColorManagement.lightColorText,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            onChanged: (String value) {
              controller.setQueryString(value);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(
                  SizeManagement.cardInsideHorizontalPadding),
              suffixIcon: InkWell(
                onTap: () => controller.getWarehouseNotes(),
                child: const Icon(
                  Icons.search,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              hintStyle: const TextStyle(
                color: ColorManagement.lightColorText,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: ColorManagement.mainBackground, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                borderSide: const BorderSide(
                    color: ColorManagement.mainBackground, width: 1),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {
                    controller.checkSearch();
                  },
                  style: ButtonStyle(
                      alignment: Alignment.center,
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ColorManagement.greenColor),
                      fixedSize:
                          MaterialStateProperty.all<Size>(const Size(80, 50))),
                  child: Text(
                    controller.isSearchByInvoice
                        ? UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_INVOICE_NUMBER)
                        : UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATOR),
                    style: const TextStyle(
                      color: ColorManagement.lightColorText,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              hintText: controller.isSearchByInvoice
                  ? UITitleUtil.getTitleByCode(
                      UITitleCode.HINT_INPUT_INVOICE_NUMBER_TO_SEARCH)
                  : UITitleUtil.getTitleByCode(
                      UITitleCode.HINT_INPUT_CREATOR_TO_SEARCH),
              fillColor: ColorManagement.lightMainBackground,
              filled: true,
            ),
            cursorColor: ColorManagement.greenColor,
            cursorHeight: 20,
          ),
        ),
      );

  Widget buildTitle(WarehouseNotesManager controller) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.rowSpacing,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: NeutronTextTitle(
              fontSize: 14,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_INVOICE_NUMBER),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
            ),
          ),
          Expanded(
            child: NeutronDropDown(
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.ALL),
                UITitleUtil.getTitleByCode(NoteTypesUlti.IMPORT),
                UITitleUtil.getTitleByCode(NoteTypesUlti.COMPENSATION),
                UITitleUtil.getTitleByCode(NoteTypesUlti.BALANCE)
              ],
              value: UITitleUtil.getTitleByCode(controller.importType),
              onChanged: controller.setImportType,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NeutronTextTitle(
                overflow: TextOverflow.visible,
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_TOTAL_FULL)),
          ),
          Expanded(
            child: NeutronDropDown(
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.ALL),
                UITitleUtil.getTitleByCode(NoteCostTypesUlti.COST),
                UITitleUtil.getTitleByCode(NoteCostTypesUlti.NOCOST)
              ],
              value: UITitleUtil.getTitleByCode(controller.hasCostFilter),
              onChanged: controller.sethasCostFilter,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  ListView buildList(bool isMobile, BuildContext mainContext) {
    void showCostDialog(WarehouseNoteImport importNote) async {
      await WarehouseNotesManager()
          .getCostByInvoiceNum(importNote.invoiceNumber!);

      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) => ImportNoteCostsDialog(
                importNote: importNote,
              ));
    }

    return ListView(
        children: warehouseNotesManager.importFilter().map((import) {
      return isMobile
          ? ImportWarehouseItemInMobile(
              mainContext: mainContext,
              showCostDialogMobile: showCostDialog,
              key: Key(import.id!),
              import: import as WarehouseNoteImport,
              warehouseNotesManager: warehouseNotesManager,
            )
          : ImportWarehouseItemInPC(
              maincontext: mainContext,
              showCostDialogPC: showCostDialog,
              key: Key(import.id!),
              import: import as WarehouseNoteImport,
              warehouseNotesManager: warehouseNotesManager,
            );
    }).toList());
  }

  Widget buildPagination(WarehouseNotesManager controller) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              controller.previousPage();
            },
            child: Icon(
              Icons.skip_previous,
              color: controller.pageIndex >= 0
                  ? ColorManagement.iconMenuEnableColor
                  : ColorManagement.iconMenuDisableColor,
            ),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () {
              controller.nextPage();
            },
            child: const Icon(Icons.skip_next,
                color: ColorManagement.iconMenuEnableColor),
          )
        ],
      ),
    );
  }
}

class ImportWarehouseItemInPC extends StatelessWidget {
  const ImportWarehouseItemInPC({
    Key? key,
    required this.import,
    required this.warehouseNotesManager,
    this.showCostDialogPC,
    this.maincontext,
  }) : super(key: key);

  final WarehouseNoteImport import;
  final Function? showCostDialogPC;
  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? maincontext;
  String? get creator => import.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : import.creator;

  String get totalString => import.type == WarehouseNotesType.import
      ? NumberUtil.numberFormat.format(import.getTotal())
      : '0';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeManagement.cardHeight,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardInsideHorizontalPadding),
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: InkWell(
        onTap: () async {
          WarehouseNoteReturn? returnNote = import.returnInvoiceNum != ''
              ? (await warehouseNotesManager.getWarehouseNoteByInvoiceNum(
                  import.returnInvoiceNum!,
                  WarehouseNotesType.returnToSupplier)) as WarehouseNoteReturn
              : null;
          WarehouseNote? importNote = import.returnInvoiceNum != ''
              ? (await warehouseNotesManager.getWarehouseNoteByInvoiceNum(
                  returnNote!.importInvoiceNumber!, WarehouseNotesType.import))
              : null;
          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              builder: (context) => import.type == WarehouseNotesType.import
                  ? ImportDialog(
                      import: import,
                      warehouseNotesManager: warehouseNotesManager,
                      importNoteForCompensation: importNote,
                      isImportExcelFile: false,
                      returnNote: returnNote,
                    )
                  : CheckDialog(
                      checkNote: import,
                    ));
        },
        child: Row(
          children: [
            //id
            SizedBox(
              width: 70,
              child: NeutronTextContent(
                color: (import.type == WarehouseNotesType.import &&
                        (import.totalCost != null &&
                            import.totalCost! > import.getTotal()))
                    ? ColorManagement.negativeText
                    : ColorManagement.lightColorText,
                textOverflow: TextOverflow.clip,
                message: DateUtil.dateToDayMonthHourMinuteString(
                    import.createdTime!),
              ),
            ),
            const SizedBox(width: 8),
            //invoice number
            Expanded(
                flex: 2,
                child: NeutronTextContent(
                    color: (import.type == WarehouseNotesType.import &&
                            (import.totalCost != null &&
                                import.totalCost! > import.getTotal()))
                        ? ColorManagement.negativeText
                        : ColorManagement.lightColorText,
                    textOverflow: TextOverflow.clip,
                    message: import.invoiceNumber ?? "")),
            const SizedBox(width: 8),
            //creator
            Expanded(
              flex: 2,
              child: NeutronTextContent(
                tooltip: creator,
                message: creator!,
                color: (import.type == WarehouseNotesType.import &&
                        (import.totalCost != null &&
                            import.totalCost! > import.getTotal()))
                    ? ColorManagement.redColor
                    : ColorManagement.lightColorText,
              ),
            ),
            const SizedBox(width: 8),
            //type
            Expanded(
                child: NeutronTextContent(
                    color: (import.type == WarehouseNotesType.import &&
                            (import.totalCost != null &&
                                import.totalCost! > import.getTotal()))
                        ? ColorManagement.negativeText
                        : ColorManagement.positiveText,
                    message: UITitleUtil.getTitleByCode(
                        import.type == WarehouseNotesType.importBalance
                            ? UITitleCode.BALANCE
                            : (import.returnInvoiceNum != '')
                                ? UITitleCode.COMPENSATION
                                : UITitleCode.IMPORT))),
            const SizedBox(width: 8),
            //total
            Expanded(
                child: NeutronTextContent(
                    color: (import.type == WarehouseNotesType.import &&
                            (import.totalCost != null &&
                                import.totalCost! > import.getTotal()))
                        ? ColorManagement.negativeText
                        : ColorManagement.positiveText,
                    message: totalString)),

            const SizedBox(width: 8),
            import.type == WarehouseNotesType.import
                ? Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //Return to supplier
                        import.invoiceNumber == null
                            ? const Spacer()
                            : Expanded(
                                child: IconButton(
                                  tooltip: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_RETURN_TO_SUPPLIER),
                                  constraints:
                                      const BoxConstraints(maxWidth: 40),
                                  icon:
                                      const Icon(Icons.settings_backup_restore),
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ReturnToSupplierDialog(
                                                returnNote:
                                                    warehouseNotesManager
                                                        .getReturnNote(import
                                                            .invoiceNumber!),
                                                importNote: import,
                                                warehouseNotesManager:
                                                    warehouseNotesManager));
                                  },
                                ),
                              ),
                        //Cost
                        import.invoiceNumber == null
                            ? const Spacer()
                            : (import.totalCost == 0 ||
                                    import.totalCost == null)
                                ? Expanded(
                                    child: IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        final Map<String, dynamic> result = {
                                          'invoice_num': import.invoiceNumber,
                                          'amount': NumberUtil.numberFormat
                                              .format(import.getTotal()),
                                        };
                                        await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AddAccountingDialog(
                                                  inputData: result,
                                                ));
                                      },
                                    ),
                                  )
                                : Expanded(
                                    child: IconButton(
                                      tooltip: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ACCOUNTING),
                                      constraints:
                                          const BoxConstraints(maxWidth: 40),
                                      icon: const Icon(
                                          Icons.account_balance_wallet_rounded),
                                      onPressed: () =>
                                          showCostDialogPC!(import),
                                    ),
                                  ),
                        //excel
                        Expanded(
                          child: IconButton(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.file_present_rounded),
                            onPressed: () =>
                                ExcelUlti.exportImportInvoice(import),
                          ),
                        ),
                        //delete-button
                        Expanded(
                          child: IconButton(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_DELETE),
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              bool? confirmResult =
                                  await MaterialUtil.showConfirm(
                                      context,
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.CONFIRM_DELETE));
                              if (confirmResult == null || !confirmResult) {
                                return;
                              }

                              bool? confirmDelete = true;
                              bool isHasCost = false;
                              if (import.totalCost == null) {
                                if (UserManager.canSeeAccounting()) {
                                  List<Accounting> accountings =
                                      await warehouseNotesManager
                                          .getCostByImportInvoiceNumber(
                                              import.invoiceNumber!);
                                  isHasCost = accountings.isNotEmpty;
                                }
                              } else {
                                if (import.totalCost != 0) {
                                  isHasCost = true;
                                }
                              }
                              if (isHasCost) {
                                // ignore: use_build_context_synchronously
                                confirmDelete = await MaterialUtil.showConfirm(
                                    context,
                                    MessageUtil.getMessageByCode(MessageCodeUtil
                                        .CONFIRM_DELETE_iMPORT_NOTE));
                              }

                              if (confirmDelete!) {
                                String result = await warehouseNotesManager
                                    .deleteWarehouseNote(import);
                                MaterialUtil.showResult(maincontext!,
                                    MessageUtil.getMessageByCode(result));
                              }
                            },
                          ),
                        ),
                      ],
                    ))
                : const Spacer(
                    flex: 3,
                  )
          ],
        ),
      ),
    );
  }
}

class CheckDialog extends StatelessWidget {
  final WarehouseNoteImport? checkNote;
  const CheckDialog({
    Key? key,
    this.checkNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveUtil.isDesktop(context);

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: 500,
        child: Scaffold(
            appBar: AppBar(),
            backgroundColor: ColorManagement.mainBackground,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.columnSpacing,
                      vertical: SizeManagement.rowSpacing),
                  child: NeutronTextTitle(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.INVENTORY_CHECK),
                  ),
                ),
                const SizedBox(
                  height: SizeManagement.rowSpacing,
                ),
                DataTable(
                    columns: [
                      DataColumn(
                          label: NeutronTextTitle(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ITEM),
                      )),
                      DataColumn(
                          label: NeutronTextTitle(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_WAREHOUSE),
                      )),
                      DataColumn(
                          label: NeutronTextTitle(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_AMOUNT),
                      )),
                    ],
                    rows: checkNote!.list!
                        .map((e) => DataRow(cells: [
                              DataCell(SizedBox(
                                width: isDesktop ? 130 : 80,
                                child: NeutronTextContent(
                                  tooltip:
                                      ItemManager().getNameAndUnitByID(e.id!),
                                  message:
                                      ItemManager().getNameAndUnitByID(e.id!)!,
                                ),
                              )),
                              DataCell(NeutronTextContent(
                                  tooltip: WarehouseManager()
                                      .getWarehouseNameById(e.warehouse!),
                                  message: WarehouseManager()
                                      .getWarehouseNameById(e.warehouse!)!)),
                              DataCell(NeutronTextContent(
                                  tooltip: e.amount.toString(),
                                  message: e.amount.toString())),
                            ]))
                        .toList()),
              ],
            )),
      ),
    );
  }
}

class ImportWarehouseItemInMobile extends StatelessWidget {
  const ImportWarehouseItemInMobile({
    Key? key,
    required this.import,
    required this.warehouseNotesManager,
    this.showCostDialogMobile,
    this.mainContext,
  }) : super(key: key);
  final WarehouseNoteImport import;
  final Function? showCostDialogMobile;
  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? mainContext;

  String? get creator => import.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : import.creator;

  String get totalString => import.type == WarehouseNotesType.import
      ? NumberUtil.numberFormat.format(import.getTotal())
      : '0';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      color: ColorManagement.lightMainBackground,
      child: ExpansionTile(
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: SizedBox(
          width: 60,
          child: NeutronTextContent(
            color: (import.type == WarehouseNotesType.import &&
                    (import.totalCost != null &&
                        import.totalCost! > import.getTotal()))
                ? ColorManagement.negativeText
                : ColorManagement.lightColorText,
            message:
                DateUtil.dateToDayMonthHourMinuteString(import.createdTime!),
          ),
        ),
        title: NeutronTextContent(
          color: (import.type == WarehouseNotesType.import &&
                  (import.totalCost != null &&
                      import.totalCost! > import.getTotal()))
              ? ColorManagement.negativeText
              : ColorManagement.lightColorText,
          message:
              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${import.invoiceNumber ?? ""}',
        ),
        subtitle: NeutronTextContent(
          message: totalString,
          fontSize: 12,
          color: (import.type == WarehouseNotesType.import &&
                  (import.totalCost != null &&
                      import.totalCost! > import.getTotal()))
              ? ColorManagement.negativeText
              : ColorManagement.positiveText,
        ),
        iconColor: ColorManagement.lightColorText,
        children: [
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATOR),
                ),
              ),
              Expanded(
                child: NeutronTextContent(message: creator!),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
                ),
              ),
              Expanded(
                child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        import.type == WarehouseNotesType.importBalance
                            ? UITitleCode.BALANCE
                            : (import.returnInvoiceNum != '')
                                ? UITitleCode.COMPENSATION
                                : UITitleCode.IMPORT)),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Return to supplier
              if (import.invoiceNumber != null &&
                  import.type == WarehouseNotesType.import)
                IconButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_RETURN_TO_SUPPLIER),
                  constraints: const BoxConstraints(maxWidth: 40),
                  icon: const Icon(Icons.settings_backup_restore),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => ReturnToSupplierDialog(
                            returnNote: warehouseNotesManager.getReturnNote(
                                import.invoiceNumber!) as WarehouseNote,
                            importNote: import,
                            warehouseNotesManager: warehouseNotesManager));
                  },
                ),

              //Cost
              if (import.invoiceNumber != null &&
                  import.type == WarehouseNotesType.import)
                (import.totalCost == 0 || import.totalCost == null)
                    ? IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final Map<String, dynamic> result = {
                            'invoice_num': import.invoiceNumber,
                            'amount': NumberUtil.numberFormat
                                .format(import.getTotal()),
                          };
                          await showDialog(
                              context: context,
                              builder: (context) => AddAccountingDialog(
                                    inputData: result,
                                  ));
                        },
                      )
                    : IconButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ACCOUNTING),
                        constraints: const BoxConstraints(maxWidth: 40),
                        icon: const Icon(Icons.account_balance_wallet_rounded),
                        onPressed: () => showCostDialogMobile!(import),
                      ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.download),
                onPressed: () => ExcelUlti.exportImportInvoice(import),
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => import.type == WarehouseNotesType.import
                      ? ImportDialog(
                          import: import,
                          warehouseNotesManager: warehouseNotesManager,
                          isImportExcelFile: false,
                        )
                      : CheckDialog(checkNote: import),
                ),
              ),
              //delete-button
              if (import.type == WarehouseNotesType.import)
                IconButton(
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
                  constraints: const BoxConstraints(maxWidth: 40),
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool? confirmResult = await MaterialUtil.showConfirm(
                        context,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.CONFIRM_DELETE));
                    if (confirmResult == null || !confirmResult) {
                      return;
                    }
                    bool? confirmDelete = true;
                    bool isHasCost = false;
                    if (import.totalCost == null) {
                      if (UserManager.canSeeAccounting()) {
                        List<Accounting> accountings =
                            await warehouseNotesManager
                                .getCostByImportInvoiceNumber(
                                    import.invoiceNumber!);
                        isHasCost = accountings.isNotEmpty;
                      }
                    } else {
                      if (import.totalCost != 0) {
                        isHasCost = true;
                      }
                    }
                    if (isHasCost) {
                      // ignore: use_build_context_synchronously
                      confirmDelete = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.CONFIRM_DELETE_iMPORT_NOTE));
                    }

                    if (confirmDelete!) {
                      String result = await warehouseNotesManager
                          .deleteWarehouseNote(import);

                      MaterialUtil.showResult(
                          mainContext!, MessageUtil.getMessageByCode(result));
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
