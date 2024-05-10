import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/modal/warehouse/warehousetransfer/warehousenotetransfer.dart';
import 'package:ihotel/ui/component/warehouse/transfer/transferdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/swap_too_fast.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronbutton.dart';
import '../warehouseexceloption.dart';

class ListTransferWarehouseDialog extends StatefulWidget {
  const ListTransferWarehouseDialog({Key? key}) : super(key: key);

  @override
  State<ListTransferWarehouseDialog> createState() =>
      _ListTransfertWarehouseDialogState();
}

class _ListTransfertWarehouseDialogState
    extends State<ListTransferWarehouseDialog> {
  final WarehouseNotesManager warehouseNotesManager = WarehouseNotesManager();

  @override
  void initState() {
    warehouseNotesManager.initProperties(WarehouseNotesType.transfer);
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
                margin: const EdgeInsets.only(bottom: 60),
                padding: const EdgeInsets.all(
                    SizeManagement.cardInsideVerticalPadding),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    //search
                    buildSearch(controller),
                    //title
                    if (!isNotDesktop) buildTitle(),
                    //
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
                tooltip1: UITitleUtil.getTitleByCode(
                    UITitleCode.CREATE_TRANSFER_NOTE),
                onPressed1: () async {
                  showDialog(
                      context: context,
                      builder: (context) => TransferDialog(
                            warehouseNotesManager: warehouseNotesManager,
                            isImportExcelFile: false,
                          ));
                },
                icon2: Icons.note_add_outlined,
                tooltip2: UITitleUtil.getTitleByCode(
                    UITitleCode.CREATE_TRANSFER_NOTE_BY_EXCEL),
                onPressed2: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExcelOptionDialog(
                        controller: controller,
                        noteType: WarehouseNotesType.transfer),
                  );
                },
              ),
            ),
          ]);
        }));
  }

  Widget buildTitle() {
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
          const SizedBox(width: 40)
        ],
      ),
    );
  }

  Widget buildSearch(WarehouseNotesManager controller) => Align(
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
  ListView buildList(bool isMobile, BuildContext mainContext) {
    return ListView(
        children: warehouseNotesManager.filterData().map((transfer) {
      return isMobile
          ? TransferWarehouseItemInMobile(
              mainContext: mainContext,
              key: Key(transfer.id!),
              transfer: transfer as WarehouseNoteTransfer,
              warehouseNotesManager: warehouseNotesManager,
            )
          : TransferWarehouseItemInPC(
              mainContext: mainContext,
              key: Key(transfer.id!),
              transfer: transfer as WarehouseNoteTransfer,
              warehouseNotesManager: warehouseNotesManager,
            );
    }).toList());
  }
}

class TransferWarehouseItemInPC extends StatelessWidget {
  const TransferWarehouseItemInPC({
    Key? key,
    required this.transfer,
    required this.warehouseNotesManager,
    this.mainContext,
  }) : super(key: key);

  final WarehouseNoteTransfer transfer;

  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? mainContext;

  String? get creator => transfer.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : transfer.creator;

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
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TransferDialog(
              transfer: transfer,
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
                message: DateUtil.dateToDayMonthHourMinuteString(
                    transfer.createdTime!),
              ),
            ),
            const SizedBox(width: 8),
            //invoice number
            Expanded(
                child: NeutronTextContent(
                    textOverflow: TextOverflow.clip,
                    message: transfer.invoiceNumber ?? "")),
            const SizedBox(width: 8),
            //creator
            Expanded(
              flex: 2,
              child: NeutronTextContent(tooltip: creator, message: creator!),
            ),
            const SizedBox(width: 8),
            //excel
            IconButton(
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
              constraints: const BoxConstraints(maxWidth: 40),
              icon: const Icon(Icons.file_present_rounded),
              onPressed: () => ExcelUlti.exportTransferInvoice(transfer),
            ),
            //delete-button
            IconButton(
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
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
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor));
                  },
                );
                String result =
                    await warehouseNotesManager.deleteWarehouseNote(transfer);
                MaterialUtil.showResult(
                    mainContext!, MessageUtil.getMessageByCode(result));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TransferWarehouseItemInMobile extends StatelessWidget {
  const TransferWarehouseItemInMobile({
    Key? key,
    required this.transfer,
    required this.warehouseNotesManager,
    this.mainContext,
  }) : super(key: key);

  final WarehouseNoteTransfer transfer;

  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? mainContext;

  String? get creator => transfer.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : transfer.creator;

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
                DateUtil.dateToDayMonthHourMinuteString(transfer.createdTime!),
          ),
        ),
        title: NeutronTextContent(
          message:
              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${transfer.invoiceNumber ?? ""}',
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
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.download),
                onPressed: () => ExcelUlti.exportTransferInvoice(transfer),
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => TransferDialog(
                    transfer: transfer,
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
                onPressed: () async {
                  bool? confirmResult = await MaterialUtil.showConfirm(
                      context,
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_DELETE));
                  if (confirmResult == null || !confirmResult) {
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: ColorManagement.greenColor));
                    },
                  );
                  String result =
                      await warehouseNotesManager.deleteWarehouseNote(transfer);
                  MaterialUtil.showResult(
                      mainContext!, MessageUtil.getMessageByCode(result));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
