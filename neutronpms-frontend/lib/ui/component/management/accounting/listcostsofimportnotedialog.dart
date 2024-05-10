import 'package:flutter/material.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/ui/component/management/accounting/accountingdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/accountingtypemanager.dart';
import '../../../../manager/suppliermanager.dart';
import '../../../../manager/warehousenotesmanager.dart';
import '../../../../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/uimultilanguageutil.dart';

class ImportNoteCostsDialog extends StatefulWidget {
  const ImportNoteCostsDialog({Key? key, required this.importNote})
      : super(key: key);
  final WarehouseNoteImport importNote;
  @override
  State<ImportNoteCostsDialog> createState() => _ImportNoteCostsDialogState();
}

class _ImportNoteCostsDialogState extends State<ImportNoteCostsDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotDesktop = !ResponsiveUtil.isDesktop(context);

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Scaffold(
          backgroundColor: ColorManagement.mainBackground,
          appBar: buildAppBar(isNotDesktop),
          body: ChangeNotifierProvider.value(
            value: WarehouseNotesManager(),
            child:
                Consumer<WarehouseNotesManager>(builder: (_, controller, __) {
              return Stack(children: [
                Container(
                  margin: const EdgeInsets.only(
                      bottom: SizeManagement.marginBottomForStack),
                  child: Column(
                    children: [
                      if (!isNotDesktop) buildTitleInPC(),
                      Expanded(
                          child: controller.listAccounting.isEmpty
                              ? Center(
                                  child: NeutronTextTitle(
                                    message: MessageUtil.getMessageByCode(
                                        MessageCodeUtil.NO_DATA),
                                  ),
                                )
                              : isNotDesktop
                                  ? ListView(
                                      children: controller.listAccounting
                                          .map((e) =>
                                              buildContentInMobile(context, e))
                                          .toList())
                                  : ListView(
                                      children: controller.listAccounting
                                          .map((e) =>
                                              buildContentInPC(context, e))
                                          .toList())),
                    ],
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    bottom: SizeManagement.marginBottomForStack,
                    child: SizedBox(
                      height: SizeManagement.neutronComponentHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeutronTextContent(
                            message:
                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(widget.importNote.getTotal())}",
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          NeutronTextContent(
                            message:
                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNTING)}: ${NumberUtil.numberFormat.format(widget.importNote.totalCost ?? 0)}",
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: NeutronButton(
                      icon: Icons.add,
                      onPressed: () async {
                        final Map<String, dynamic> result = {
                          'invoice_num': widget.importNote.invoiceNumber,
                          'amount': controller.getRemainCostOfImportNote(
                              widget.importNote.getTotal().toDouble())
                        };
                        Accounting? cost = await showDialog(
                            context: context,
                            builder: (context) => AddAccountingDialog(
                                  inputData: result,
                                ));
                        if (cost != null) {
                          controller.addCostForImportNote(
                              cost, widget.importNote);
                        }
                      },
                    ))
              ]);
            }),
          )),
    );
  }

  Widget buildContentInPC(BuildContext context, Accounting e) {
    double remainingAmount = 0;

    remainingAmount = e.amount! - e.actualPayment!;

    return Container(
      height: SizeManagement.cardHeight,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          //created time
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: DateUtil.dateToDayMonthHourMinuteString(e.created!),
                message: DateUtil.dateToDayMonthHourMinuteString(e.created!),
              )),
          const SizedBox(width: 10),
          //description
          Expanded(
              flex: 2,
              child: NeutronTextContent(
                tooltip: e.desc,
                message: e.desc!,
              )),

          const SizedBox(width: 10),
          //supplier
          Expanded(
              flex: 2,
              child: NeutronTextContent(
                tooltip: SupplierManager().getSupplierNameByID(e.supplier),
                message: SupplierManager().getSupplierNameByID(e.supplier),
              )),
          const SizedBox(width: 10),
          //type
          Expanded(
              flex: 2,
              child: NeutronTextContent(
                tooltip: AccountingTypeManager.getNameById(e.type!),
                message: AccountingTypeManager.getNameById(e.type!)!,
              )),
          const SizedBox(width: 10),
          //creator
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: e.author.toString(),
                message: e.author.toString(),
              )),
          const SizedBox(width: 10),
          //amount
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(e.amount),
                message: NumberUtil.numberFormat.format(e.amount),
              )),
          const SizedBox(width: 10),
          const SizedBox(width: 10),
          //paid
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(e.actualPayment),
                message: NumberUtil.numberFormat.format(e.actualPayment),
              )),
          const SizedBox(width: 10),
          //remaining
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(remainingAmount),
                message: NumberUtil.numberFormat.format(remainingAmount),
              )),
          const SizedBox(width: 10),
          //status
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                color: AccountingStatus.DONE == e.status
                    ? ColorManagement.greenColor
                    : AccountingStatus.NOTYET == e.status
                        ? ColorManagement.redColor
                        : ColorManagement.yellowColor,
                tooltip: UITitleUtil.getTitleByCode(e.status!),
                message: UITitleUtil.getTitleByCode(e.status!),
              )),
        ],
      ),
    );
  }

  Widget buildContentInMobile(BuildContext context, Accounting e) {
    double remainingAmount = 0;

    remainingAmount = e.amount! - e.actualPayment!;

    return Container(
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      margin: const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
      child: ExpansionTile(
        backgroundColor: ColorManagement.lightMainBackground,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding),
        childrenPadding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),

        collapsedIconColor: ColorManagement.lightColorText,
        //created time
        title: Row(
          children: [
            Expanded(
                child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CREATED_TIME),
            )),
            Expanded(
                child: NeutronTextContent(
              tooltip: DateUtil.dateToDayMonthHourMinuteString(e.created!),
              message: DateUtil.dateToDayMonthHourMinuteString(e.created!),
            )),
          ],
        ),
        children: [
          //description
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: e.desc,
                message: e.desc!,
              )),
            ],
          ),
          const SizedBox(height: 8),
          //supplier
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_SUPPLIER),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: SupplierManager().getSupplierNameByID(e.supplier),
                message: SupplierManager().getSupplierNameByID(e.supplier),
              )),
            ],
          ),
          const SizedBox(height: 8),
          //type
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
                tooltip: AccountingTypeManager.getNameById(e.type!),
                message: AccountingTypeManager.getNameById(e.type!)!,
              )),
            ],
          ),
          const SizedBox(height: 8),
          //creator
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATOR),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: e.author.toString(),
                message: e.author.toString(),
              )),
            ],
          ),
          const SizedBox(height: 8),
          //amount
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(e.amount),
                message: NumberUtil.numberFormat.format(e.amount),
              )),
            ],
          ),
          const SizedBox(height: 8),
          //paid
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAID),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(e.actualPayment),
                message: NumberUtil.numberFormat.format(e.actualPayment),
              )),
            ],
          ),
          const SizedBox(height: 8),
          //remaining
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_REMAIN),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                tooltip: NumberUtil.numberFormat.format(remainingAmount),
                message: NumberUtil.numberFormat.format(remainingAmount),
              )),
            ],
          ),
          const SizedBox(height: 8),
          //status
          Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_STATUS),
                ),
              ),
              Expanded(
                  child: NeutronTextContent(
                color: AccountingStatus.DONE == e.status
                    ? ColorManagement.greenColor
                    : AccountingStatus.NOTYET == e.status
                        ? ColorManagement.redColor
                        : ColorManagement.yellowColor,
                tooltip: UITitleUtil.getTitleByCode(e.status!),
                message: UITitleUtil.getTitleByCode(e.status!),
              )),
            ],
          ),
        ],
      ),
    );
  }

  buildTitleInPC() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          const SizedBox(width: 10),
          //created time
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CREATED_TIME),
            ),
          ),
          const SizedBox(width: 10),
          //description
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 15,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
            ),
          ),
          const SizedBox(width: 10),
          //supplier
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 15,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER),
            ),
          ),
          const SizedBox(width: 10),
          //type
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 15,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
            ),
          ),
          const SizedBox(width: 10),
          //creator
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
            ),
          ),
          const SizedBox(width: 10),
          //amount
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_AMOUNT_MONEY),
            ),
          ),
          const SizedBox(width: 10),
          //paid
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAID),
            ),
          ),
          const SizedBox(width: 10),
          //remaining
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN),
            ),
          ),
          const SizedBox(width: 10),
          //status
          Expanded(
            flex: 3,
            child: NeutronTextTitle(
              fontSize: 15,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
            ),
          ),
        ],
      ),
    );
  }

  buildAppBar(bool isNotDesktop) {
    return AppBar(
      automaticallyImplyLeading: isNotDesktop ? false : true,
      centerTitle: true,
      title: NeutronTextHeader(
          message:
              UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNTING)),
    );
  }
}
