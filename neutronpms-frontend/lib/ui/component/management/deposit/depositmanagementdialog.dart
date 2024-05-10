// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/depositmanagement/depositmanagementcontroller.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/component/management/deposit/depositdialog.dart';
import 'package:ihotel/ui/component/management/deposit/deposithistorydetail.dart';
import 'package:ihotel/ui/component/management/deposit/depositrefund.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class DepositManagementDialog extends StatelessWidget {
  const DepositManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth + 100;
    }
    final now = Timestamp.now().toDate();
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        height: height,
        width: width,
        child: ChangeNotifierProvider<DepositManagementController>(
          create: (context) => DepositManagementController(),
          builder: (context, child) => Consumer<DepositManagementController>(
            builder: (context, controller, child) => DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                    actions: [
                      NeutronDatePicker(
                        isMobile: isMobile,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_START_DATE),
                        initialDate: controller.startDate,
                        firstDate: now.subtract(const Duration(days: 365)),
                        lastDate: now.add(const Duration(days: 365)),
                        onChange: (picked) {
                          controller.setStartDate(picked);
                        },
                      ),
                      NeutronDatePicker(
                        isMobile: isMobile,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_END_DATE),
                        initialDate: controller.endDate,
                        firstDate: controller.startDate,
                        lastDate: controller.startDate
                            .add(Duration(days: controller.maxTimePeriod)),
                        onChange: (picked) {
                          controller.setEndDate(picked);
                        },
                      ),
                      NeutronBlurButton(
                        color: ColorManagement.greenColor,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_REFRESH),
                        icon: Icons.refresh,
                        onPressed: () {
                          controller.loadDeposits();
                        },
                      ),
                    ],
                    bottom: TabBar(
                      onTap: (value) {
                        controller.setQueryStatus(value);
                        controller.loadDeposits();
                      },
                      tabs: [
                        Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_DEPOSIT),
                            child: const Tab(icon: Icon(Icons.money))),
                        Tooltip(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_REFUND),
                            child: const Tab(
                                icon: Icon(Icons.keyboard_return_outlined))),
                      ],
                    )),
                floatingActionButton: floatingActionButton(context),
                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      controller.isLoading!
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorManagement.greenColor,
                              ),
                            )
                          : isMobile
                              ? buildDepositOnMobile(controller, context)
                              : buildDepositOnPc(controller, context),
                      controller.isLoading!
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorManagement.greenColor,
                              ),
                            )
                          : isMobile
                              ? buildRefundOnMobile(controller, context)
                              : buildRefundOnPc(controller, context)
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDepositOnMobile(
      DepositManagementController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              child: NeutronTextFormField(
            textAlign: TextAlign.center,
            hint: UITitleUtil.getTitleByCode(
                UITitleCode.HINT_INPUT_SID_TO_SEARCH),
            controller: controller.searchTeController,
            isDecor: true,
            borderColor: ColorManagement.white,
            onChanged: (p0) => controller.search(),
          )),
        ),
        Expanded(
          child: controller.filter().isEmpty
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.NO_DATA)))
              : ListView(
                  children: controller
                      .filter()
                      .map((e) => Card(
                            elevation: 10,
                            color: ColorManagement.lightMainBackground,
                            child: ExpansionTile(
                              iconColor: ColorManagement.white,
                              collapsedIconColor: ColorManagement.white,
                              title: NeutronTextContent(
                                maxLines: 2,
                                message:
                                    DateUtil.dateToDayMonthYearHourMinuteString(
                                        e.createTime),
                              ),
                              leading:
                                  NeutronTextContent(message: 'SID : ${e.sid}'),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} : ${e.name}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY)} : ${NumberUtil.numberFormat.format(e.amount)}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT_METHOD)} : ${PaymentMethodManager().getPaymentMethodNameById(e.paymentMethod)}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)} : ${e.note}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TOOLTIP_TRANSFER_DEPOSIT),
                                    icon: const Icon(Icons.transform_outlined),
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              DepositRefundDialog(
                                                  deposit: e,
                                                  transferBooking: true));
                                    },
                                  ),
                                ),
                                NeutronButton(
                                  icon: Icons.edit,
                                  icon1: Icons.delete,
                                  icon2: Icons.assignment_return_outlined,
                                  tooltip2: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_REFUND),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            DepositDialog(deposit: e));
                                  },
                                  onPressed1: () async {
                                    String result = await controller
                                        .deteleDepositPayment(e);
                                    if (result != MessageCodeUtil.SUCCESS) {
                                      MaterialUtil.showResult(context,
                                          MessageUtil.getMessageByCode(result));
                                    }
                                  },
                                  onPressed2: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            DepositRefundDialog(deposit: e));
                                  },
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
        ),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    controller.getDepositFirstPage();
                  },
                  icon: const Icon(Icons.skip_previous)),
              IconButton(
                  onPressed: () {
                    controller.getDepositPreviousPage();
                  },
                  icon: const Icon(
                    Icons.navigate_before_sharp,
                  )),
              IconButton(
                  onPressed: () {
                    controller.getDepositNextPage();
                  },
                  icon: const Icon(
                    Icons.navigate_next_sharp,
                  )),
              IconButton(
                  onPressed: () {
                    controller.getDepositLastPage();
                  },
                  icon: const Icon(Icons.skip_next)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRefundOnMobile(
      DepositManagementController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              child: NeutronTextFormField(
            textAlign: TextAlign.center,
            hint: UITitleUtil.getTitleByCode(
                UITitleCode.HINT_INPUT_SID_TO_SEARCH),
            controller: controller.searchTeController,
            isDecor: true,
            borderColor: ColorManagement.white,
            onChanged: (p0) => controller.search(),
          )),
        ),
        Expanded(
          child: controller.filter().isEmpty
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.NO_DATA)))
              : ListView(
                  children: controller
                      .filter()
                      .map((e) => Card(
                            elevation: 10,
                            color: e.paymentMethod == "transferdeposit"
                                ? ColorManagement.greenColor
                                : ColorManagement.lightMainBackground,
                            child: ExpansionTile(
                              iconColor: ColorManagement.white,
                              collapsedIconColor: ColorManagement.white,
                              title: NeutronTextContent(
                                maxLines: 2,
                                message:
                                    DateUtil.dateToDayMonthYearHourMinuteString(
                                        e.createTime),
                              ),
                              leading:
                                  NeutronTextContent(message: 'SID : ${e.sid}'),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} : ${e.name}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY)} : ${NumberUtil.numberFormat.format(e.amount)}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT_METHOD)} : ${PaymentMethodManager().getPaymentMethodNameById(e.paymentMethod)}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.start,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)} : ${e.note}'),
                                ),
                                e.status == DepositStatus.DEPOSIT
                                    ? NeutronButton(
                                        icon: Icons.edit,
                                        icon1: Icons.delete,
                                        icon2: Icons.assignment_return_outlined,
                                        tooltip2: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_REFUND),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositDialog(deposit: e));
                                        },
                                        onPressed1: () async {
                                          String result = await controller
                                              .deteleDepositPayment(e);
                                          if (result !=
                                              MessageCodeUtil.SUCCESS) {
                                            MaterialUtil.showResult(
                                                context,
                                                MessageUtil.getMessageByCode(
                                                    result));
                                          }
                                        },
                                        onPressed2: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositRefundDialog(
                                                      deposit: e));
                                        },
                                      )
                                    : NeutronButton(
                                        icon: Icons.edit,
                                        icon1: Icons.delete,
                                        icon2: Icons.history,
                                        tooltip2: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_HISTORY),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositRefundDialog(
                                                    deposit: e,
                                                    isAddRefund: false,
                                                  ));
                                        },
                                        onPressed1: () async {
                                          String result = await controller
                                              .deteleRefundDepositPayment(e);
                                          if (result !=
                                              MessageCodeUtil.SUCCESS) {
                                            MaterialUtil.showResult(
                                                context,
                                                MessageUtil.getMessageByCode(
                                                    result));
                                          }
                                        },
                                        onPressed2: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositHistoryDetail(
                                                      deposit: e));
                                        },
                                      )
                              ],
                            ),
                          ))
                      .toList(),
                ),
        ),
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    controller.getDepositFirstPage();
                  },
                  icon: const Icon(Icons.skip_previous)),
              IconButton(
                  onPressed: () {
                    controller.getDepositPreviousPage();
                  },
                  icon: const Icon(
                    Icons.navigate_before_sharp,
                  )),
              IconButton(
                  onPressed: () {
                    controller.getDepositNextPage();
                  },
                  icon: const Icon(
                    Icons.navigate_next_sharp,
                  )),
              IconButton(
                  onPressed: () {
                    controller.getDepositLastPage();
                  },
                  icon: const Icon(Icons.skip_next)),
            ],
          ),
        ),
      ],
    );
  }

  Column buildRefundOnPc(
      DepositManagementController controller, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            child: NeutronTextFormField(
          textAlign: TextAlign.center,
          hint:
              UITitleUtil.getTitleByCode(UITitleCode.HINT_INPUT_SID_TO_SEARCH),
          controller: controller.searchTeController,
          isDecor: true,
          borderColor: ColorManagement.white,
          onChanged: (p0) => controller.search(),
        )),
      ),
      Padding(
        padding: const EdgeInsets.all(SizeManagement.cardInsideVerticalPadding),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => controller.sortByTime(),
                child: Row(
                  children: [
                    NeutronTextTitle(
                      isPadding: false,
                      textAlign: TextAlign.center,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_TIME),
                    ),
                    Icon(
                      controller.isDescending
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 13,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_AMOUNT_MONEY),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_PAYMENT_METHOD),
            )),
            const SizedBox(width: 100)
          ],
        ),
      ),
      Expanded(
          child: controller.filter().isEmpty
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.NO_DATA)))
              : ListView(
                  children: controller
                      .filter()
                      .map((e) => Card(
                            margin: const EdgeInsets.all(
                                SizeManagement.cardInsideVerticalPadding),
                            elevation: 10,
                            color: e.paymentMethod == "transferdeposit"
                                ? ColorManagement.greenColor
                                : ColorManagement.lightMainBackground,
                            child: InkWell(
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      e.status == DepositStatus.DEPOSIT
                                          ? DepositDialog(deposit: e)
                                          : DepositRefundDialog(
                                              deposit: e,
                                              isAddRefund: false,
                                              transferBooking:
                                                  e.paymentMethod ==
                                                      "transferdeposit",
                                            )),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: NeutronTextContent(
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          message: DateUtil
                                              .dateToDayMonthYearHourMinuteString(
                                                  e.createTime)),
                                    ),
                                    Expanded(
                                        child: NeutronTextContent(
                                      textAlign: TextAlign.center,
                                      message: e.sid,
                                      tooltip: e.sid,
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.center,
                                          tooltip: NumberUtil.numberFormat
                                              .format(e.amount),
                                          message: NumberUtil.moneyFormat
                                              .format(e.amount)),
                                    ),
                                    Expanded(
                                        child: NeutronTextContent(
                                            textAlign: TextAlign.center,
                                            tooltip: e.name,
                                            message: e.name)),
                                    Expanded(
                                        child: NeutronTextContent(
                                            textAlign: TextAlign.center,
                                            tooltip: e.note ?? '',
                                            message: e.note ?? '')),
                                    Expanded(
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.center,
                                          tooltip: PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  e.paymentMethod),
                                          message: PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  e.paymentMethod)),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          String result = e.status ==
                                                  DepositStatus.DEPOSIT
                                              ? await controller
                                                  .deteleDepositPayment(e)
                                              : await controller
                                                  .deteleRefundDepositPayment(
                                                      e);
                                          if (result !=
                                              MessageCodeUtil.SUCCESS) {
                                            MaterialUtil.showResult(
                                                context,
                                                MessageUtil.getMessageByCode(
                                                    result));
                                          }
                                        },
                                      ),
                                    ),
                                    e.status == DepositStatus.DEPOSIT
                                        ? SizedBox(
                                            width: 50,
                                            child: IconButton(
                                              tooltip:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TOOLTIP_REFUND),
                                              icon: const Icon(Icons
                                                  .assignment_return_outlined),
                                              onPressed: () async {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        DepositRefundDialog(
                                                            deposit: e));
                                              },
                                            ),
                                          )
                                        : SizedBox(
                                            width: 50,
                                            child: IconButton(
                                                tooltip:
                                                    UITitleUtil.getTitleByCode(
                                                        UITitleCode
                                                            .TOOLTIP_HISTORY),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        DepositHistoryDetail(
                                                            deposit: e),
                                                  );
                                                },
                                                icon:
                                                    const Icon(Icons.history)),
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                )),
      const Divider(color: ColorManagement.white),
      SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  controller.getDepositFirstPage();
                },
                icon: const Icon(Icons.skip_previous)),
            IconButton(
                onPressed: () {
                  controller.getDepositPreviousPage();
                },
                icon: const Icon(
                  Icons.navigate_before_sharp,
                )),
            IconButton(
                onPressed: () {
                  controller.getDepositNextPage();
                },
                icon: const Icon(
                  Icons.navigate_next_sharp,
                )),
            IconButton(
                onPressed: () {
                  controller.getDepositLastPage();
                },
                icon: const Icon(Icons.skip_next)),
          ],
        ),
      ),
    ]);
  }

  Column buildDepositOnPc(
      DepositManagementController controller, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            child: NeutronTextFormField(
          textAlign: TextAlign.center,
          hint:
              UITitleUtil.getTitleByCode(UITitleCode.HINT_INPUT_SID_TO_SEARCH),
          controller: controller.searchTeController,
          isDecor: true,
          borderColor: ColorManagement.white,
          onChanged: (p0) => controller.search(),
        )),
      ),
      Padding(
        padding: const EdgeInsets.all(SizeManagement.cardInsideVerticalPadding),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => controller.sortByTime(),
                child: Row(
                  children: [
                    NeutronTextTitle(
                      isPadding: false,
                      textAlign: TextAlign.center,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_TIME),
                    ),
                    Icon(
                      controller.isDescending
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 13,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_AMOUNT_MONEY),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
            )),
            Expanded(
                child: NeutronTextTitle(
              isPadding: false,
              textAlign: TextAlign.center,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_PAYMENT_METHOD),
            )),
            const SizedBox(width: 150)
          ],
        ),
      ),
      Expanded(
          child: controller.filter().isEmpty
              ? Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.NO_DATA)))
              : ListView(
                  children: controller
                      .filter()
                      .map((e) => Card(
                            margin: const EdgeInsets.all(
                                SizeManagement.cardInsideVerticalPadding),
                            elevation: 10,
                            color: ColorManagement.lightMainBackground,
                            child: InkWell(
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => DepositDialog(deposit: e),
                              ),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: NeutronTextContent(
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          message: DateUtil
                                              .dateToDayMonthYearHourMinuteString(
                                                  e.createTime)),
                                    ),
                                    Expanded(
                                        child: NeutronTextContent(
                                      textAlign: TextAlign.center,
                                      message: e.sid,
                                      tooltip: e.sid,
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.center,
                                          tooltip: NumberUtil.numberFormat
                                              .format(e.remain),
                                          message: NumberUtil.moneyFormat
                                              .format(e.remain)),
                                    ),
                                    Expanded(
                                        child: NeutronTextContent(
                                            textAlign: TextAlign.center,
                                            tooltip: e.name,
                                            message: e.name)),
                                    Expanded(
                                        child: NeutronTextContent(
                                            textAlign: TextAlign.center,
                                            tooltip: e.note ?? '',
                                            message: e.note ?? '')),
                                    Expanded(
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.center,
                                          tooltip: PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  e.paymentMethod),
                                          message: PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  e.paymentMethod)),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          String result = await controller
                                              .deteleDepositPayment(e);
                                          if (result !=
                                              MessageCodeUtil.SUCCESS) {
                                            MaterialUtil.showResult(
                                                context,
                                                MessageUtil.getMessageByCode(
                                                    result));
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_REFUND),
                                        icon: const Icon(
                                            Icons.assignment_return_outlined),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositRefundDialog(
                                                      deposit: e));
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TOOLTIP_TRANSFER_DEPOSIT),
                                        icon: const Icon(
                                            Icons.transform_outlined),
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DepositRefundDialog(
                                                      deposit: e,
                                                      transferBooking: true));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                )),
      const Divider(color: ColorManagement.white),
      SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  controller.getDepositFirstPage();
                },
                icon: const Icon(Icons.skip_previous)),
            IconButton(
                onPressed: () {
                  controller.getDepositPreviousPage();
                },
                icon: const Icon(
                  Icons.navigate_before_sharp,
                )),
            IconButton(
                onPressed: () {
                  controller.getDepositNextPage();
                },
                icon: const Icon(
                  Icons.navigate_next_sharp,
                )),
            IconButton(
                onPressed: () {
                  controller.getDepositLastPage();
                },
                icon: const Icon(Icons.skip_next)),
          ],
        ),
      ),
    ]);
  }

  FloatingActionButton floatingActionButton(BuildContext context) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.greenColor,
        mini: true,
        tooltip: UITitleUtil.getTitleByCode(
            UITitleCode.TOOLTIP_PAYMENT_METHOD_REPORT_DETAIL),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const DepositDialog(),
          );
        },
        child: const Icon(Icons.add),
      );
}
