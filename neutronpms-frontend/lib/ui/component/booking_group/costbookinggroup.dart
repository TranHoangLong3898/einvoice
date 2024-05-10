import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/ui/component/management/accounting/accountingdialog.dart';
import 'package:ihotel/ui/component/management/accounting/actualexpensesmanagementdialog.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:provider/provider.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controller/booking/costbookinggroupcontroller.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutronbuttontext.dart';
import '../../controls/neutrondropdowsearch.dart';
import '../../controls/neutronwaiting.dart';
import '../management/accounting/addactualpaymentdialog.dart';

class CostBookingGroupDialog extends StatefulWidget {
  final Booking booking;

  const CostBookingGroupDialog({Key? key, required this.booking})
      : super(key: key);

  @override
  State<CostBookingGroupDialog> createState() => _CostBookingGroupDialogState();
}

class _CostBookingGroupDialogState extends State<CostBookingGroupDialog> {
  late CosBookingGroupController controller;
  double totalAmout = 0;

  @override
  void initState() {
    super.initState();
    controller = CosBookingGroupController(widget.booking);
  }

  VerticalDivider get divider => const VerticalDivider(
      color: ColorManagement.mainColorText,
      thickness: 0.5,
      width: 4,
      endIndent: 10,
      indent: 10);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: kHeight,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<CosBookingGroupController>(
            child: const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
            builder: (_, controller, child) {
              return Scaffold(
                  backgroundColor: ColorManagement.mainBackground,
                  appBar: buildAppBar(isMobile),
                  body: Column(
                    children: [
                      const SizedBox(height: 10),
                      isMobile
                          ? buildFilterInMobile(isMobile)
                          : buildTitleInPC(),
                      const SizedBox(height: 10),
                      Expanded(
                          child: controller.isLoading
                              ? child!
                              : buildContent(isMobile)),
                      NeutronButtonText(
                        text:
                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNTING)}: ${NumberUtil.numberFormat.format(totalAmout)}",
                      )
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }

  List<Widget> get filters => [
        Container(
          margin: const EdgeInsets.all(8),
          width: 100,
          child: NeutronSearchDropDown(
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...SupplierManager().getSupplierNames()
              ],
              valueFirst: UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
              value: controller.supplierFilter,
              label:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER),
              onChange: (content) => controller.setSupplierFilter(content)),
        ),
        divider,
        Container(
          margin: const EdgeInsets.all(8),
          width: 100,
          child: NeutronSearchDropDown(
              label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
              value: controller.typeFilter,
              valueFirst: UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...AccountingTypeManager.listNames
              ],
              onChange: (content) => controller.setTypeFilter(content)),
        ),
        divider,
        Container(
          width: 90,
          margin: const EdgeInsets.all(8),
          child: NeutronDropDownCustom(
            backgroundColor: ColorManagement.lightMainBackground,
            label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
            childWidget: NeutronDropDown(
              isCenter: true,
              isPadding: false,
              onChanged: controller.setStatusFilter,
              value: controller.statusFilter,
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                'open',
                'partial',
                'done'
              ],
            ),
          ),
        ),
      ];

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
          message:
              UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNTING)),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        if (!isMobile) ...[...filters, divider],
        divider,
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            showDialog(
                context: context, builder: (context) => const NeutronWaiting());
            await controller
                .exportToExcel()
                .whenComplete(() => Navigator.pop(context));
          },
        ),
      ],
    );
  }

  Widget buildFilterInMobile(bool isMobile) => SizedBox(
        height: isMobile ? 60 : 55,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters,
        ),
      );

  Widget buildTitleInPC() {
    return Row(
      children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding * 2),
        SizedBox(
          width: 90,
          child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CREATED_TIME),
              maxLines: 2),
        ),
        SizedBox(
          width: 90,
          child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
              maxLines: 2),
        ),
        Expanded(
          flex: 2,
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
          ),
        ),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAID),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN),
            textAlign: TextAlign.end,
          ),
        ),
        Expanded(
          child: NeutronTextTitle(
            textAlign: TextAlign.center,
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
          ),
        ),
        const SizedBox(
            width: 120 + SizeManagement.cardInsideHorizontalPadding * 2),
      ],
    );
  }

  Widget buildContent(bool isMobile) {
    if (controller.accountings.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }
    return isMobile ? buildContentInMobile() : buildContentInPC();
  }

  ListView buildContentInPC() {
    double totalPaid = 0, totalRemain = 0;
    totalAmout = 0;
    return ListView(children: [
      ...controller.accountings.map((e) {
        totalAmout += e.amount!;
        totalPaid += e.actualPayment!;
        totalRemain += e.remain;
        return InkWell(
          onTap: () => showContentDetail(e.id!),
          child: Container(
            height: SizeManagement.cardHeight,
            decoration: BoxDecoration(
                color: ColorManagement.lightMainBackground,
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8)),
            margin: const EdgeInsets.all(
                SizeManagement.cardInsideHorizontalPadding),
            child: Row(children: [
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              SizedBox(
                  width: 90,
                  child: NeutronTextContent(
                    message:
                        DateUtil.dateToDayMonthHourMinuteString(e.created!),
                  )),
              SizedBox(
                  width: 90,
                  child: NeutronTextContent(
                    message: controller.mapDataBooking[e.id]!,
                  )),
              Expanded(
                  flex: 2,
                  child: NeutronTextContent(message: e.desc!, tooltip: e.desc)),
              const SizedBox(width: 4),
              Expanded(
                  child: NeutronTextContent(
                      message:
                          SupplierManager().getSupplierNameByID(e.supplier))),
              const SizedBox(width: 4),
              Expanded(
                  child: NeutronTextContent(
                      message: AccountingTypeManager.getNameById(e.type!)!)),
              const SizedBox(width: 4),
              Expanded(child: NeutronTextContent(message: e.author!)),
              Expanded(
                  child: NeutronTextContent(
                message: NumberUtil.numberFormat.format(e.amount),
                textAlign: TextAlign.end,
                color: ColorManagement.positiveText,
              )),
              const SizedBox(width: 4),
              Expanded(
                  child: NeutronTextContent(
                message: NumberUtil.numberFormat.format(e.actualPayment),
                textAlign: TextAlign.end,
                color: ColorManagement.negativeText,
              )),
              const SizedBox(width: 4),
              Expanded(
                  child: NeutronTextContent(
                message: NumberUtil.numberFormat.format(e.remain),
                textAlign: TextAlign.end,
                color: ColorManagement.positiveText,
              )),
              Expanded(
                  child: NeutronTextContent(
                message: e.status!,
                textAlign: TextAlign.center,
              )),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 40),
                onPressed: () => updateContent(e),
                icon: Tooltip(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_EDIT_ACOUNTING),
                    child: const Icon(Icons.edit)),
              ),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 40),
                onPressed: () => deleteContent(e),
                icon: Tooltip(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DELETE_ACOUNTING),
                    child: const Icon(Icons.delete)),
              ),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 40),
                onPressed: () => addActualPayment(e),
                icon: Tooltip(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ADD_ACTUAL_PAYMENT),
                    child: const Icon(Icons.add)),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            ]),
          ),
        );
      }).toList(),
      buildPageTotal(totalAmout, totalPaid, totalRemain)
    ]);
  }

  ListView buildContentInMobile() {
    return ListView(
      children: controller.accountings
          .map(
            (e) => Container(
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              margin: const EdgeInsets.all(
                  SizeManagement.cardOutsideHorizontalPadding),
              child: ExpansionTile(
                backgroundColor: ColorManagement.lightMainBackground,
                tilePadding: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardInsideHorizontalPadding),
                childrenPadding: const EdgeInsets.all(
                    SizeManagement.cardInsideHorizontalPadding),
                trailing: Tooltip(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_LIST_ACTUAL_PAYMENT),
                  child: IconButton(
                    constraints: const BoxConstraints(maxWidth: 30),
                    padding: const EdgeInsets.all(0),
                    hoverColor: Colors.transparent,
                    onPressed: () => showContentDetail(e.id!),
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ),
                leading: SizedBox(
                  width: 50,
                  child: NeutronTextContent(
                      message:
                          DateUtil.dateToDayMonthHourMinuteString(e.created!),
                      maxLines: 2),
                ),
                collapsedIconColor: ColorManagement.lightColorText,
                iconColor: ColorManagement.lightColorText,
                title: NeutronTextContent(
                  message: e.desc!,
                  tooltip: e.desc,
                  fontSize: 15,
                ),
                subtitle: NeutronTextContent(
                    message:
                        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS)}: ${e.status}',
                    fontSize: 11),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TYPE)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                              message:
                                  AccountingTypeManager.getNameById(e.type!)!))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATOR)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                              message: e.author!, tooltip: e.author))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SUPPLIER)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                              message: SupplierManager()
                                  .getSupplierNameByID(e.supplier)))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT_MONEY)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                            message: NumberUtil.numberFormat.format(e.amount),
                            color: ColorManagement.positiveText,
                          ))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PAID)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                            message:
                                NumberUtil.numberFormat.format(e.actualPayment),
                            color: ColorManagement.negativeText,
                          ))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_REMAIN)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                            message: NumberUtil.numberFormat.format(e.remain),
                            color: ColorManagement.positiveText,
                          ))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_STATUS)),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(message: e.status!))
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(maxWidth: 40),
                        onPressed: () => updateContent(e),
                        icon: Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_EDIT_ACOUNTING),
                            child: const Icon(Icons.edit)),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(maxWidth: 40),
                        onPressed: () => deleteContent(e),
                        icon: Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DELETE_ACOUNTING),
                            child: const Icon(Icons.delete)),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(maxWidth: 40),
                        onPressed: () => addActualPayment(e),
                        icon: Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ADD_ACTUAL_PAYMENT),
                            child: const Icon(Icons.add)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Container buildPageTotal(
          double totalAmout, double totalPaid, double totalRemain) =>
      Container(
        height: SizeManagement.cardHeight,
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        margin:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        child: Row(children: [
          const SizedBox(
              width: 90 + SizeManagement.cardInsideHorizontalPadding),
          const SizedBox(
              width: 90 + SizeManagement.cardInsideHorizontalPadding),
          const Spacer(flex: 5),
          const SizedBox(width: 4.0 * 3),
          Expanded(
              child: NeutronTextContent(
            message: NumberUtil.numberFormat.format(totalAmout),
            textAlign: TextAlign.end,
            color: ColorManagement.positiveText,
          )),
          const SizedBox(width: 4),
          Expanded(
              child: NeutronTextContent(
            message: NumberUtil.numberFormat.format(totalPaid),
            textAlign: TextAlign.end,
            color: ColorManagement.negativeText,
          )),
          const SizedBox(width: 4),
          Expanded(
              child: NeutronTextContent(
            message: NumberUtil.numberFormat.format(totalRemain),
            textAlign: TextAlign.end,
            color: ColorManagement.positiveText,
          )),
          const Spacer(),
          const SizedBox(
              width: 120 + SizeManagement.cardInsideHorizontalPadding),
        ]),
      );

  void updateContent(Accounting accounting) async {
    await showDialog(
        context: context,
        builder: (context) => AddAccountingDialog(accounting: accounting));
  }

  void deleteContent(Accounting accounting) async {
    final confirmResult = await MaterialUtil.showConfirm(
        context, MessageUtil.getMessageByCode(MessageCodeUtil.CONFIRM_DELETE));
    if (confirmResult == null || !confirmResult) {
      return;
    }
    String result = await controller.deleteAccounting(accounting);
    if (mounted) {
      MaterialUtil.showResult(context, MessageUtil.getMessageByCode(result));
    }
  }

  void addActualPayment(Accounting accounting) async {
    await showDialog(
        context: context,
        builder: (context) => AddActualPaymentDialog(
              costManagementID: accounting.id!,
            ));
  }

  void showContentDetail(String accountingId) {
    showDialog(
        context: context,
        builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child:
                ActualExpenseManagementDialog(costManagementId: accountingId)));
  }
}
