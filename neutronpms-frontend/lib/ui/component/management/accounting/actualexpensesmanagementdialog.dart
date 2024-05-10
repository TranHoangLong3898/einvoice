import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/actualexpensemanagementcontroller.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/accounting/actualpayment.dart';
import 'package:ihotel/ui/component/management/accounting/addactualpaymentdialog.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../manager/accountingtypemanager.dart';
import '../../../../manager/suppliermanager.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronblurbutton.dart';
import '../../../controls/neutronbutton.dart';
import '../../../controls/neutronbuttontext.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrondropdown.dart';
import '../../../controls/neutrondropdowsearch.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontexttilte.dart';
import '../../../controls/neutronwaiting.dart';
import 'accouting_from_actual_payment.dart';

class ActualExpenseManagementDialog extends StatefulWidget {
  const ActualExpenseManagementDialog(
      {Key? key, this.costManagementId = '', this.remainCost})
      : super(key: key);

  final String costManagementId;
  final double? remainCost;

  @override
  State<ActualExpenseManagementDialog> createState() =>
      _ActualExpenseManagementDialogState();
}

class _ActualExpenseManagementDialogState
    extends State<ActualExpenseManagementDialog> {
  late ActualExpenseManagementController controller;

  @override
  void initState() {
    super.initState();
    controller = ActualExpenseManagementController(widget.costManagementId);
  }

  String get costManagementId => widget.costManagementId;

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
          child: Consumer<ActualExpenseManagementController>(
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
                          ? costManagementId.isEmpty
                              ? buildFilterInMobile(isMobile)
                              : const SizedBox()
                          : buildTitleInPC(),
                      const SizedBox(height: 10),
                      Expanded(
                          child: controller.isLoading!
                              ? child!
                              : buildContent(isMobile)),
                      pagination,
                      costManagementId.isNotEmpty
                          ? NeutronButton(
                              icon: Icons.add,
                              onPressed: () async {
                                await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AddActualPaymentDialog(
                                          costManagementID: costManagementId,
                                          remainCost: widget.remainCost,
                                        ));
                              },
                            )
                          : NeutronButtonText(
                              text:
                                  "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACTUAL_EXPENSE)} ${NumberUtil.numberFormat.format(controller.actualPaymentTotal)}",
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
              value: controller.supplierFilter!,
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
              value: controller.typeFilter!,
              valueFirst: UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...AccountingTypeManager.listNames
              ],
              onChange: (content) => controller.setTypeFilter(content)),
        ),
        divider,
        //method
        Container(
          width: 90,
          margin: const EdgeInsets.all(8),
          child: NeutronDropDownCustom(
            backgroundColor: ColorManagement.lightMainBackground,
            label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD),
            childWidget: NeutronDropDown(
              isCenter: true,
              isPadding: false,
              onChanged: controller.setMethodFilter,
              value: controller.methodFilter!,
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...PaymentMethodManager().getPaymentMethodName()
              ],
            ),
          ),
        ),
        divider,
        //status
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
              value: controller.statusFilter!,
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...controller.listStatus
              ],
            ),
          ),
        ),
        // if (controller.costId == null) divider,
        //sort time
        // if (controller.costId == null)
        //   TextButton.icon(
        //       onPressed: controller.toggleSort,
        //       icon: Icon(
        //         controller.isSortDsc
        //             ? Icons.arrow_downward_rounded
        //             : Icons.arrow_upward_rounded,
        //         color: ColorManagement.lightColorText,
        //       ),
        //       label: NeutronTextContent(
        //         maxLines: 2,
        //         tooltip: UITitleUtil.getTitleByCode(controller.isSortDsc
        //             ? UITitleCode.TOOLTIP_DESCENDING
        //             : UITitleCode.TOOLTIP_ASCENDING),
        //         message: UITitleUtil.getTitleByCode(UITitleCode.SORT_BY_TIME),
        //       )),
      ];

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
        message: controller.costId?.isNotEmpty ?? false
            ? 'AccountingId: ${controller.costId}'
            : UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACTUAL_EXPENSE),
        maxLines: 2,
      ),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        if (!isMobile && costManagementId.isEmpty) ...[
          ...filters,
          divider,
        ],
        if (costManagementId.isEmpty) ...[
          NeutronDatePicker(
            isMobile: isMobile,
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
            initialDate: controller.startDate,
            firstDate: controller.now.subtract(const Duration(days: 365)),
            lastDate: controller.now.add(const Duration(days: 365)),
            onChange: controller.setStartDate,
          ),
          divider,
          NeutronDatePicker(
            isMobile: isMobile,
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
            initialDate: controller.endDate,
            firstDate: controller.startDate,
            lastDate: controller.startDate.add(const Duration(days: 30)),
            onChange: controller.setEndDate,
          ),
          divider,
          NeutronBlurButton(
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
            icon: Icons.refresh,
            onPressed: controller.loadActualPayments,
          ),
          divider,
        ],
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

  Widget buildFilterInMobile(bool isMobile) => Container(
        alignment: Alignment.center,
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
        const SizedBox(width: 4),
        Expanded(
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD),
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
        Expanded(
          child: NeutronTextTitle(
            textAlign: TextAlign.center,
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
          ),
        ),
        if (costManagementId.isEmpty) const SizedBox(width: 40),
        const SizedBox(
            width: 40 + SizeManagement.cardInsideHorizontalPadding * 2),
      ],
    );
  }

  Widget buildContent(bool isMobile) {
    if (controller.actualPayments.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }
    return isMobile ? buildContentInMobile() : buildContentInPC();
  }

  ListView buildContentInPC() {
    num pageTotal = 0;
    return ListView(children: [
      ...controller.actualPayments.map((e) {
        pageTotal += e.amount!;
        return InkWell(
          onTap: () => updateContent(e),
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
              const SizedBox(width: 4),
              Expanded(
                  child: NeutronTextContent(
                      message: PaymentMethodManager()
                          .getPaymentMethodNameById(e.method!))),
              Expanded(
                  child: NeutronTextContent(
                message: NumberUtil.numberFormat.format(e.amount),
                textAlign: TextAlign.end,
                color: ColorManagement.positiveText,
              )),
              Expanded(
                  child: NeutronStatusDropdown(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                currentStatus: e.status!,
                items: controller.listStatus,
                secondColorStatus: 'done',
                onChanged: (String value) => updateStatus(e, value),
              )),
              IconButton(
                constraints: const BoxConstraints(maxWidth: 40),
                onPressed: () => deleteContent(e),
                icon: const Icon(Icons.delete),
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DELETE_ACOUNTING),
              ),
              if (costManagementId.isEmpty)
                IconButton(
                  constraints: const BoxConstraints(maxWidth: 40),
                  onPressed: () => showAccountingContent(e),
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_COST),
                  icon: const Icon(Icons.account_balance_wallet_rounded),
                ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            ]),
          ),
        );
      }).toList(),
      buildPageTotal(pageTotal)
    ]);
  }

  Container buildPageTotal(num totalPage) {
    return Container(
      height: SizeManagement.cardHeight,
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      margin: const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
      child: Row(children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding + 90),
        const Spacer(
          flex: 6,
        ),
        const SizedBox(width: 16),
        Expanded(
            child: NeutronTextContent(
          message: NumberUtil.numberFormat.format(totalPage),
          textAlign: TextAlign.end,
          color: ColorManagement.positiveText,
        )),
        const Spacer(),
        SizedBox(
            width: SizeManagement.cardInsideHorizontalPadding +
                (costManagementId.isEmpty ? 80 : 40)),
      ]),
    );
  }

  ListView buildContentInMobile() {
    num totalPage = 0;
    return ListView(
        children: controller.actualPayments.map((e) {
      totalPage += e.amount!;
      return Container(
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        margin:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          backgroundColor: ColorManagement.lightMainBackground,
          tilePadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          childrenPadding:
              const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
          leading: SizedBox(
            width: 50,
            child: NeutronTextContent(
                message: DateUtil.dateToDayMonthHourMinuteString(e.created!),
                maxLines: 2),
          ),
          collapsedIconColor: ColorManagement.lightColorText,
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
                const SizedBox(width: 4),
                Expanded(
                    flex: 2,
                    child: NeutronTextContent(
                        message: AccountingTypeManager.getNameById(e.type!)!))
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
                const SizedBox(width: 4),
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
                const SizedBox(width: 4),
                Expanded(
                    flex: 2,
                    child: NeutronTextContent(
                        message:
                            SupplierManager().getSupplierNameByID(e.supplier)))
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_METHOD)),
                ),
                const SizedBox(width: 4),
                Expanded(
                    flex: 2,
                    child: NeutronTextContent(
                      message: PaymentMethodManager()
                          .getPaymentMethodNameById(e.method!),
                    ))
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
                const SizedBox(width: 4),
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
                          UITitleCode.TABLEHEADER_STATUS)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: NeutronStatusDropdown(
                    currentStatus: e.status!,
                    items: controller.listStatus,
                    secondColorStatus: 'done',
                    onChanged: (String value) => updateStatus(e, value),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  constraints: const BoxConstraints(maxWidth: 40),
                  onPressed: () => updateContent(e),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  constraints: const BoxConstraints(maxWidth: 40),
                  onPressed: () => deleteContent(e),
                  icon: const Icon(Icons.delete),
                ),
                if (costManagementId.isEmpty)
                  IconButton(
                    onPressed: () => showAccountingContent(e),
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    constraints: const BoxConstraints(maxWidth: 40),
                  ),
              ],
            )
          ],
        ),
      );
    }).toList()
          ..add(Container(
            height: SizeManagement.cardHeight,
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardInsideHorizontalPadding),
            decoration: BoxDecoration(
                color: ColorManagement.lightMainBackground,
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8)),
            child: Center(
              child: NeutronTextContent(
                message: NumberUtil.numberFormat.format(totalPage),
                color: ColorManagement.positiveText,
              ),
            ),
          )));
  }

  Row get pagination => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              splashRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getActualPaymentsPreviousPage,
              icon: const Icon(Icons.navigate_before_sharp)),
          IconButton(
              splashRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getActualPaymentsNextPage,
              icon: const Icon(Icons.navigate_next_sharp)),
        ],
      );

  void updateContent(ActualPayment actualPayment) async {
    await showDialog(
        context: context,
        builder: (context) => AddActualPaymentDialog(
              actualPayment: actualPayment,
              costManagementID: actualPayment.accountingId!,
            ));
  }

  void showAccountingContent(ActualPayment actualPayment) async {
    await showDialog(
        context: context,
        builder: (context) => AccountingFromActualPayment(
              actualPayment: actualPayment,
            ));
  }

  void deleteContent(ActualPayment actualPayment) async {
    final confirmResult = await MaterialUtil.showConfirm(
        context, MessageUtil.getMessageByCode(MessageCodeUtil.CONFIRM_DELETE));
    if (confirmResult == null || !confirmResult) {
      return;
    }
    String result = await controller.deleteAccounting(actualPayment);
    if (mounted) {
      MaterialUtil.showResult(context, MessageUtil.getMessageByCode(result));
    }
  }

  void updateStatus(ActualPayment actualPayment, String newStatus) async {
    if (newStatus == actualPayment.status) {
      return;
    }
    String result =
        await controller.updateActualPaymentStatus(actualPayment, newStatus);
    if (mounted) {
      MaterialUtil.showResult(context, MessageUtil.getMessageByCode(result));
    }
  }
}
