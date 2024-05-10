import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/revenue_logs/revenue_log.dart';
import 'package:ihotel/ui/component/management/revenue_management/check_revenue_logs_controller.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondropdown.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontexttilte.dart';
import '../../../controls/neutronwaiting.dart';

class RevenueLogsDialog extends StatefulWidget {
  const RevenueLogsDialog({Key? key}) : super(key: key);

  @override
  State<RevenueLogsDialog> createState() => _RevenueLogsDialogState();
}

class _RevenueLogsDialogState extends State<RevenueLogsDialog> {
  late RevenueLogsController controller;

  @override
  void initState() {
    super.initState();
    controller = RevenueLogsController();
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
          child: Consumer<RevenueLogsController>(
            child: const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
            builder: (_, controller, child) {
              return Scaffold(
                  floatingActionButton: isMobile ? floatingActionButton : null,
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
                          child: controller.isLoading!
                              ? child!
                              : buildContent(isMobile)),
                      pagination(isMobile),
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }

  FloatingActionButton get floatingActionButton => FloatingActionButton(
        backgroundColor: ColorManagement.lightMainBackground,
        mini: true,
        tooltip:
            UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
        onPressed: () async {
          await controller.getAllCheckCashFlowStatement().then((revenueLogs) {
            if (revenueLogs.isEmpty) return;
            showDialog(
                context: context,
                builder: (context) => WillPopScope(
                    onWillPop: () => Future.value(false),
                    child: const NeutronWaiting()));
            ExcelUlti.exportCheckCashFlowStatement(revenueLogs, controller);
            Navigator.pop(context);
          });
        },
        child: const Icon(Icons.file_present_rounded,
            color: ColorManagement.redColor),
      );

  List<Widget> get filters => [
        // type
        Container(
          width: 120,
          margin: const EdgeInsets.all(8),
          child: NeutronDropDownCustom(
            backgroundColor: ColorManagement.lightMainBackground,
            label: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
            childWidget: NeutronDropDown(
              isCenter: true,
              isPadding: false,
              onChanged: controller.setypeFilter,
              value: controller.typeLogFilter,
              items: controller.getTypeNames,
            ),
          ),
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
              value: controller.methodFilter,
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                ...PaymentMethodManager().getPaymentMethodName()
              ],
            ),
          ),
        ),
      ];

  Widget buildFilterInMobile(bool isMobile) => Container(
        alignment: Alignment.center,
        height: isMobile ? 60 : 55,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters,
        ),
      );

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
        message: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_HISTORY),
        maxLines: 2,
      ),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        if (!isMobile) ...[...filters, divider],
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
          onPressed: controller.loadRevenueLogs,
        ),
        if (!isMobile) ...[
          divider,
          NeutronBlurButton(
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
              onPressed: () async {
                await controller
                    .getAllCheckCashFlowStatement()
                    .then((revenueLogs) {
                  if (revenueLogs.isEmpty) return;
                  showDialog(
                      context: context,
                      builder: (context) => WillPopScope(
                          onWillPop: () => Future.value(false),
                          child: const NeutronWaiting()));
                  ExcelUlti.exportCheckCashFlowStatement(
                      revenueLogs, controller);
                  Navigator.pop(context);
                });
              },
              icon: Icons.file_present_rounded)
        ]
      ],
    );
  }

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
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: NeutronTextTitle(
            isPadding: false,
            textAlign: TextAlign.center,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: NeutronTextTitle(
            isPadding: false,
            textAlign: TextAlign.center,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: NeutronTextTitle(
            isPadding: false,
            textAlign: TextAlign.center,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_PAYMENT_METHOD),
          ),
        ),
        SizedBox(
          width: 100,
          child: NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          width: 100,
          child: NeutronTextTitle(
            isPadding: false,
            message: "BAT",
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding * 2),
      ],
    );
  }

  Widget buildContent(bool isMobile) {
    if (controller.revenueLogs.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }
    return isMobile ? buildContentInMobile() : buildContentInPC();
  }

  ListView buildContentInPC() {
    return ListView(
      children: controller.revenueLogs
          .map(
            (e) => Container(
              height: SizeManagement.cardHeight,
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              margin: const EdgeInsets.all(
                  SizeManagement.cardInsideHorizontalPadding),
              child: Row(children: [
                const SizedBox(
                    width: SizeManagement.cardInsideHorizontalPadding),
                SizedBox(
                    width: 90,
                    child: NeutronTextContent(
                      message:
                          DateUtil.dateToDayMonthHourMinuteString(e.created!),
                    )),
                Expanded(
                    child:
                        NeutronTextContent(message: e.desc!, tooltip: e.desc)),
                const SizedBox(width: 4),
                SizedBox(
                    width: 100,
                    child: NeutronTextContent(
                      message: e.getTypeName(),
                      textAlign: TextAlign.center,
                    )),
                const SizedBox(width: 4),
                SizedBox(
                  width: 100,
                  child: NeutronTextContent(
                      message: e.author!, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 4),
                SizedBox(
                    width: 100,
                    child: NeutronTextContent(
                        textAlign: TextAlign.center,
                        message: e.type == TypeRevenueLog.typeTransfer
                            ? '${PaymentMethodManager().getPaymentMethodNameById(e.method)} -> ${PaymentMethodManager().getPaymentMethodNameById(e.methodTo!)}'
                            : PaymentMethodManager()
                                .getPaymentMethodNameById(e.method))),
                SizedBox(
                    width: 100,
                    child: NeutronTextContent(
                      message: NumberUtil.numberFormat.format(e.amount),
                      textAlign: TextAlign.end,
                      color: ColorManagement.positiveText,
                    )),
                SizedBox(
                    width: 100,
                    child: NeutronTextContent(
                        message: NumberUtil.numberFormat.format(
                            controller.getAmountBalanceAfterTransaction(e)),
                        textAlign: TextAlign.end,
                        color:
                            controller.getAmountBalanceAfterTransaction(e) > 0
                                ? ColorManagement.positiveText
                                : ColorManagement.negativeText)),
                const SizedBox(
                    width: SizeManagement.cardInsideHorizontalPadding),
              ]),
            ),
          )
          .toList(),
    );
  }

  ListView buildContentInMobile() {
    return ListView(
      children: controller.revenueLogs
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
                leading: SizedBox(
                  width: 50,
                  child: NeutronTextContent(
                      message:
                          DateUtil.dateToDayMonthHourMinuteString(e.created!),
                      maxLines: 2),
                ),
                collapsedIconColor: ColorManagement.lightColorText,
                title: NeutronTextContent(
                  message: e.desc!,
                  tooltip: e.desc,
                  fontSize: 15,
                ),
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
                          child: NeutronTextContent(message: e.getTypeName()))
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
                  if (e.type == TypeRevenueLog.typeTransfer) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_METHOD_FROM)),
                        ),
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              message: PaymentMethodManager()
                                  .getPaymentMethodNameById(e.method),
                            ))
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_METHOD_TO)),
                        ),
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              message: PaymentMethodManager()
                                  .getPaymentMethodNameById(e.methodTo!),
                            ))
                      ],
                    ),
                  ],
                  if (e.type != TypeRevenueLog.typeTransfer)
                    const SizedBox(height: 8),
                  if (e.type != TypeRevenueLog.typeTransfer)
                    Row(
                      children: [
                        Expanded(
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_METHOD)),
                        ),
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              message: PaymentMethodManager()
                                  .getPaymentMethodNameById(e.method),
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
                          message: UITitleUtil.getTitleByCode(UITitleCode
                              .TABLEHEADER_BALANCE_AFTER_TRANSACTION),
                          tooltip: UITitleUtil.getTitleByCode(UITitleCode
                              .TABLEHEADER_BALANCE_AFTER_TRANSACTION),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: NeutronTextContent(
                              message: NumberUtil.numberFormat.format(controller
                                  .getAmountBalanceAfterTransaction(e)),
                              textAlign: TextAlign.end,
                              color: controller
                                          .getAmountBalanceAfterTransaction(e) >
                                      0
                                  ? ColorManagement.positiveText
                                  : ColorManagement.negativeText)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Row pagination(bool isMobile) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isMobile)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardOutsideHorizontalPadding),
                child: NeutronTextContent(
                  message:
                      "*BAT: ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BALANCE_AFTER_TRANSACTION)}",
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getRevenueLogsFirstPage,
              icon: const Icon(Icons.skip_previous)),
          IconButton(
              splashRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getRevenueLogsPreviousPage,
              icon: const Icon(Icons.navigate_before_sharp)),
          IconButton(
              splashRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getRevenueLogsNextPage,
              icon: const Icon(Icons.navigate_next_sharp)),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getRevenueLogsLastPage,
              icon: const Icon(Icons.skip_next)),
          if (!isMobile) const Expanded(child: SizedBox()),
        ],
      );
}
