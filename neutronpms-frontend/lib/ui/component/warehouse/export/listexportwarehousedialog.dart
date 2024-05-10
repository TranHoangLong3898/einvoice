import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/warehouse/warehouseexport/warehousenoteexport.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/swap_too_fast.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/warehousemanager.dart';
import '../../../../manager/warehousenotesmanager.dart';
import '../../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../../modal/warehouse/warehousenote.dart';
import '../../../../modal/warehouse/warehousereturn/warehousenotereturn.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../../util/warehouseutil.dart';
import '../../../controls/neutronbutton.dart';
import '../../../controls/neutrondialogs.dart';
import '../../../controls/neutrondropdown.dart';
import '../../../controls/neutrontexttilte.dart';
import '../import/importdialog.dart';
import '../return_to_supplier/returntosupplier.dart';
import '../warehouseexceloption.dart';
import 'exportdialog.dart';

class ListExportWarehouseDialog extends StatefulWidget {
  const ListExportWarehouseDialog({Key? key}) : super(key: key);

  @override
  State<ListExportWarehouseDialog> createState() =>
      _ListExportWarehouseDialogState();
}

class _ListExportWarehouseDialogState extends State<ListExportWarehouseDialog> {
  final WarehouseNotesManager warehouseNotesManager = WarehouseNotesManager();

  @override
  void initState() {
    warehouseNotesManager.initProperties(WarehouseNotesType.export);
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

          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                padding: const EdgeInsets.all(
                    SizeManagement.cardInsideVerticalPadding),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    buildSearch(controller, isNotDesktop),
                    if (!isNotDesktop) buildTitle(controller),
                    if (isNotDesktop)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: SizeManagement.cardInsideVerticalPadding,
                            bottom: SizeManagement.cardInsideVerticalPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  controller.checkSearch();
                                },
                                style: ButtonStyle(
                                    alignment: Alignment.center,
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            ColorManagement.greenColor),
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(80, 45))),
                                child: Text(
                                  controller.isSearchByInvoice
                                      ? UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_NUMBER)
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
                            const SizedBox(
                              width: SizeManagement.columnSpacing,
                            ),
                            Expanded(
                              child: NeutronDropDown(
                                  items: [
                                    UITitleUtil.getTitleByCode(UITitleCode.ALL),
                                    UITitleUtil.getTitleByCode(
                                        NoteTypesUlti.EXPORT),
                                    UITitleUtil.getTitleByCode(
                                        NoteTypesUlti.RETURN)
                                  ],
                                  value: UITitleUtil.getTitleByCode(
                                      controller.exportType),
                                  onChanged: controller.setExportType),
                            ),
                          ],
                        ),
                      ),
                    //list
                    controller.data.isEmpty
                        ? Center(
                            child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.NO_DATA)))
                        : Expanded(child: buildList(isNotDesktop, context)),
                    //pagination
                    controller.data.isEmpty
                        ? Container()
                        : Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: controller.previousPage,
                                  child: Icon(
                                    Icons.skip_previous,
                                    color: controller.pageIndex >= 0
                                        ? ColorManagement.iconMenuEnableColor
                                        : ColorManagement.iconMenuDisableColor,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                InkWell(
                                  onTap: controller.nextPage,
                                  child: const Icon(Icons.skip_next,
                                      color:
                                          ColorManagement.iconMenuEnableColor),
                                )
                              ],
                            ),
                          )
                  ],
                )),
            //add-button
            Align(
              alignment: Alignment.bottomCenter,
              child: NeutronButton(
                icon1: Icons.add,
                tooltip1:
                    UITitleUtil.getTitleByCode(UITitleCode.CREATE_EXPORT_NOTE),
                onPressed1: () async {
                  if (!WarehouseManager().isHaveRoleInWareHouseExport()) {
                    await MaterialUtil.showAlert(
                        context,
                        MessageUtil.getMessageByCode(MessageCodeUtil
                            .NOT_HAVE_PERMISSION_EXPORT_WAREHOUSE));
                    return;
                  }

                  showDialog(
                      context: context,
                      builder: (context) => ExportDialog(
                            warehouseNotesManager: warehouseNotesManager,
                            isImportExcelFile: false,
                          ));
                },
                icon2: Icons.note_add_outlined,
                tooltip2: UITitleUtil.getTitleByCode(
                    UITitleCode.CREATE_EXPORT_NOTE_BY_EXCEL),
                onPressed2: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExcelOptionDialog(
                        controller: controller,
                        noteType: WarehouseNotesType.export),
                  );
                },
              ),
            ),
          ]);
        }));
  }

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
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
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
          const SizedBox(width: 8),
          Expanded(
            child: NeutronDropDown(
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.ALL),
                UITitleUtil.getTitleByCode(NoteTypesUlti.EXPORT),
                UITitleUtil.getTitleByCode(NoteTypesUlti.RETURN),
                UITitleUtil.getTitleByCode(NoteTypesUlti.BALANCE),
              ],
              value: UITitleUtil.getTitleByCode(controller.exportType),
              onChanged: controller.setExportType,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: SizedBox(),
          )
        ],
      ),
    );
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
              prefixIcon: isNotDesktop
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: () {
                          controller.checkSearch();
                        },
                        style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ColorManagement.greenColor),
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(80, 50))),
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

  ListView buildList(bool isMobile, BuildContext mainContex) {
    return ListView(
        children: warehouseNotesManager.exportFilter().map((note) {
      return isMobile
          ? ExportWarehouseItemInMobile(
              mainContex: mainContex,
              key: Key(note.id!),
              note: note,
              warehouseNotesManager: warehouseNotesManager,
            )
          : ExportWarehouseItemInPC(
              mainContex: mainContex,
              key: Key(note.id!),
              note: note,
              warehouseNotesManager: warehouseNotesManager,
            );
    }).toList());
  }
}

class ExportWarehouseItemInPC extends StatelessWidget {
  const ExportWarehouseItemInPC({
    Key? key,
    @required this.note,
    @required this.warehouseNotesManager,
    this.mainContex,
  }) : super(key: key);

  final WarehouseNote? note;

  final WarehouseNotesManager? warehouseNotesManager;
  final BuildContext? mainContex;

  String? get creator => note!.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : note!.creator;

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
          WarehouseNoteImport? importNote =
              note!.type == WarehouseNotesType.returnToSupplier
                  ? await warehouseNotesManager!.getWarehouseNoteByInvoiceNum(
                      (note as WarehouseNoteReturn).importInvoiceNumber!,
                      WarehouseNotesType.import) as WarehouseNoteImport
                  : null;
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) =>
                note?.type == WarehouseNotesType.returnToSupplier
                    ? importNote == null
                        ? NeutronAlertDialog(messages: [
                            MessageUtil.getMessageByCode(MessageCodeUtil
                                .WAREHOUSE_NOTE_HAS_BEEN_DELETED_UNABLE_TO_DISPLAY)
                          ])
                        : ReturnToSupplierDialog(
                            warehouseNotesManager: warehouseNotesManager,
                            returnNote: note!,
                            importNote: importNote,
                          )
                    : ExportDialog(
                        export: note,
                        warehouseNotesManager: warehouseNotesManager,
                        isImportExcelFile: false,
                      ),
          );
        },
        child: Row(
          children: [
            //id
            SizedBox(
              width: 70,
              child: NeutronTextContent(
                textOverflow: TextOverflow.clip,
                message:
                    DateUtil.dateToDayMonthHourMinuteString(note!.createdTime!),
              ),
            ),
            const SizedBox(width: 8),
            //invoice number
            Expanded(
                child: NeutronTextContent(
                    textOverflow: TextOverflow.clip,
                    message: note!.invoiceNumber ?? "")),
            const SizedBox(width: 8),
            //creator
            Expanded(
              flex: 2,
              child: NeutronTextContent(tooltip: creator, message: creator!),
            ),
            Expanded(
              child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      note!.type == WarehouseNotesType.exportBalance
                          ? UITitleCode.BALANCE
                          : note!.type!),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //compensation
                    if (note!.type == WarehouseNotesType.returnToSupplier)
                      IconButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.COMPENSATION),
                        constraints: const BoxConstraints(maxWidth: 40),
                        icon: const Icon(Icons.login),
                        onPressed: () async {
                          WarehouseNoteImport importNote =
                              (await warehouseNotesManager!
                                      .getWarehouseNoteByInvoiceNum(
                                          (note as WarehouseNoteReturn)
                                              .importInvoiceNumber!,
                                          WarehouseNotesType.import)
                                  as WarehouseNoteImport);
                          WarehouseNote? import = await warehouseNotesManager!
                              .getWareImportNoteByReturnInvoiceNum(
                                  (note as WarehouseNoteReturn).invoiceNumber!);
                          // ignore: use_build_context_synchronously
                          await showDialog(
                              context: context,
                              builder: (context) => ImportDialog(
                                    warehouseNotesManager:
                                        warehouseNotesManager,
                                    isImportExcelFile: false,
                                    importNoteForCompensation: importNote,
                                    returnNote: note as WarehouseNoteReturn,
                                    import: import == null
                                        ? null
                                        : import as WarehouseNoteImport,
                                  ));
                        },
                      ),
                    //excel
                    IconButton(
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                      constraints: const BoxConstraints(maxWidth: 40),
                      icon: const Icon(Icons.file_present_rounded),
                      onPressed: () => ExcelUlti.exportExportInvoice(
                          note as WarehouseNoteExport),
                    ),
                    //delete-button
                    IconButton(
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_DELETE),
                      constraints: const BoxConstraints(maxWidth: 40),
                      icon: const Icon(Icons.delete),
                      onPressed: note!.type == WarehouseNotesType.exportBalance
                          ? null
                          : () async {
                              bool? confirmResult =
                                  await MaterialUtil.showConfirm(
                                      context,
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.CONFIRM_DELETE));
                              if (confirmResult == null || !confirmResult) {
                                return;
                              }
                              String result = await warehouseNotesManager!
                                  .deleteWarehouseNote(note!);
                              MaterialUtil.showResult(mainContex!,
                                  MessageUtil.getMessageByCode(result));
                            },
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class ExportWarehouseItemInMobile extends StatelessWidget {
  const ExportWarehouseItemInMobile({
    Key? key,
    @required this.note,
    @required this.warehouseNotesManager,
    this.mainContex,
  }) : super(key: key);

  final WarehouseNote? note;

  final WarehouseNotesManager? warehouseNotesManager;
  final BuildContext? mainContex;

  String? get creator => note!.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : note!.creator;

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
            message:
                DateUtil.dateToDayMonthHourMinuteString(note!.createdTime!),
          ),
        ),
        title: NeutronTextContent(
          message:
              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${note!.invoiceNumber ?? ""}',
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //compensation
              if (note!.type == WarehouseNotesType.returnToSupplier)
                IconButton(
                  tooltip: UITitleUtil.getTitleByCode(UITitleCode.COMPENSATION),
                  constraints: const BoxConstraints(maxWidth: 40),
                  icon: const Icon(Icons.login),
                  onPressed: () async {
                    WarehouseNoteImport importNote =
                        (await warehouseNotesManager!
                                .getWarehouseNoteByInvoiceNum(
                                    (note as WarehouseNoteReturn)
                                        .importInvoiceNumber!,
                                    WarehouseNotesType.import)
                            as WarehouseNoteImport);
                    WarehouseNote? import = (await warehouseNotesManager!
                        .getWareImportNoteByReturnInvoiceNum(
                            (note as WarehouseNoteReturn)
                                .importInvoiceNumber!));
                    // ignore: use_build_context_synchronously
                    await showDialog(
                        context: context,
                        builder: (context) => ImportDialog(
                              warehouseNotesManager: warehouseNotesManager,
                              isImportExcelFile: false,
                              importNoteForCompensation: importNote,
                              import: import == null
                                  ? null
                                  : import as WarehouseNoteImport,
                              returnNote: note as WarehouseNoteReturn,
                            ));
                  },
                ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.download),
                onPressed: () =>
                    ExcelUlti.exportExportInvoice(note as WarehouseNoteExport),
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ExportDialog(
                    export: note,
                    warehouseNotesManager: warehouseNotesManager,
                    isImportExcelFile: false,
                  ),
                ),
              ),
              //delete-button
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.delete),
                onPressed: note!.type == WarehouseNotesType.exportBalance
                    ? null
                    : () async {
                        bool? confirmResult = await MaterialUtil.showConfirm(
                            context,
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.CONFIRM_DELETE));
                        if (confirmResult == null || !confirmResult) {
                          return;
                        }
                        String result = await warehouseNotesManager!
                            .deleteWarehouseNote(note!);
                        MaterialUtil.showResult(
                            mainContex!, MessageUtil.getMessageByCode(result));
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
