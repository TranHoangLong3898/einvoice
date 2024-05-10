import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/warehousenotesmanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/swap_too_fast.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../modal/warehouse/warehouseliquidation/warehousenoteliquidation.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronbutton.dart';
import '../warehouseexceloption.dart';
import 'liquidationdialog.dart';

class ListLiquidationWarehouseDialog extends StatefulWidget {
  const ListLiquidationWarehouseDialog({Key? key}) : super(key: key);

  @override
  State<ListLiquidationWarehouseDialog> createState() =>
      _ListLiquidationWarehouseDialogState();
}

class _ListLiquidationWarehouseDialogState
    extends State<ListLiquidationWarehouseDialog> {
  final WarehouseNotesManager warehouseNotesManager = WarehouseNotesManager();

  @override
  void initState() {
    warehouseNotesManager.initProperties(WarehouseNotesType.liquidation);
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

          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                padding: const EdgeInsets.all(
                    SizeManagement.cardInsideVerticalPadding),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    //search
                    buildSearch(controller),
                    //title
                    if (!isNotDesktop) buildTitle(),
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
                    UITitleCode.CREATE_LIQUIDATION_NOTE),
                onPressed1: () async {
                  showDialog(
                      context: context,
                      builder: (context) => LiquidationDialog(
                            warehouseNotesManager: warehouseNotesManager,
                            isImportExcelFile: false,
                          ));
                },
                icon2: Icons.note_add_outlined,
                tooltip2: UITitleUtil.getTitleByCode(
                    UITitleCode.CREATE_LIQUIDATION_NOTE_BY_EXCEL),
                onPressed2: () {
                  showDialog(
                    context: context,
                    builder: (context) => ExcelOptionDialog(
                        controller: controller,
                        noteType: WarehouseNotesType.liquidation),
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
          const SizedBox(width: 80)
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
        children: warehouseNotesManager.filterData().map((liquidation) {
      return isMobile
          ? LiquidationWarehouseItemInMobile(
              mainContext: mainContext,
              key: Key(liquidation.id!),
              liquidation: liquidation as WarehouseNoteLiquidation,
              warehouseNotesManager: warehouseNotesManager,
            )
          : LiquidationWarehouseItemInPC(
              mainContext: mainContext,
              key: Key(liquidation.id!),
              liquidation: liquidation as WarehouseNoteLiquidation,
              warehouseNotesManager: warehouseNotesManager,
            );
    }).toList());
  }
}

class LiquidationWarehouseItemInPC extends StatelessWidget {
  const LiquidationWarehouseItemInPC({
    Key? key,
    required this.liquidation,
    required this.warehouseNotesManager,
    this.mainContext,
  }) : super(key: key);

  final WarehouseNoteLiquidation liquidation;

  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? mainContext;

  String get creator => liquidation.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : liquidation.creator!;

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
            builder: (context) => LiquidationDialog(
              liquidation: liquidation,
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
                    liquidation.createdTime!),
              ),
            ),
            const SizedBox(width: 8),
            //invoice number
            Expanded(
                child: NeutronTextContent(
                    textOverflow: TextOverflow.clip,
                    message: liquidation.invoiceNumber ?? "")),
            const SizedBox(width: 8),
            //creator
            Expanded(
              flex: 2,
              child: NeutronTextContent(tooltip: creator, message: creator),
            ),
            const SizedBox(width: 8),
            //excel
            IconButton(
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
              constraints: const BoxConstraints(maxWidth: 40),
              icon: const Icon(Icons.download),
              onPressed: () => ExcelUlti.exportLiquidationInvoice(liquidation),
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
                String result = await warehouseNotesManager
                    .deleteWarehouseNote(liquidation);
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

class LiquidationWarehouseItemInMobile extends StatelessWidget {
  const LiquidationWarehouseItemInMobile({
    Key? key,
    required this.liquidation,
    required this.warehouseNotesManager,
    this.mainContext,
  }) : super(key: key);

  final WarehouseNoteLiquidation liquidation;

  final WarehouseNotesManager warehouseNotesManager;
  final BuildContext? mainContext;

  String get creator => liquidation.creator == emailAdmin
      ? UITitleUtil.getTitleByCode(UITitleCode.ADMIN)
      : liquidation.creator!;

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
            message: DateUtil.dateToDayMonthHourMinuteString(
                liquidation.createdTime!),
          ),
        ),
        title: NeutronTextContent(
          message:
              '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${liquidation.invoiceNumber ?? ""}',
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
                child: NeutronTextContent(message: creator),
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
                icon: const Icon(Icons.file_present_rounded),
                onPressed: () =>
                    ExcelUlti.exportLiquidationInvoice(liquidation),
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
                constraints: const BoxConstraints(maxWidth: 40),
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => LiquidationDialog(
                    liquidation: liquidation,
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
                  String result = await warehouseNotesManager
                      .deleteWarehouseNote(liquidation);
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
