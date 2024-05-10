import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/ui/component/management/paymentmanagementdialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/management/receptioncashmanagementcontroller.dart';
import '../../../modal/service/deposit.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutroniconbutton.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutrondropdown.dart';

class ReceptionCashManagementDialog extends StatefulWidget {
  const ReceptionCashManagementDialog({Key? key}) : super(key: key);

  @override
  State<ReceptionCashManagementDialog> createState() =>
      _ReceptionCashManagementDialogState();
}

class _ReceptionCashManagementDialogState
    extends State<ReceptionCashManagementDialog> {
  late ReceptionCashManagementController controller;
  late DateTime now;

  @override
  void initState() {
    controller = ReceptionCashManagementController();
    now = Timestamp.now().toDate();
    super.initState();
  }

  @override
  void dispose() {
    controller.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : 1000;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<ReceptionCashManagementController>.value(
          value: controller,
          child: Consumer<ReceptionCashManagementController>(
            builder: (_, controller, child) {
              if (controller.isLoading!) {
                return child!;
              }
              return Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: buildAppBar(isMobile),
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 65),
                      child: Column(
                        children: [
                          //title
                          isMobile ? buildTitleInMobile() : buildTitleInPc(),
                          //content
                          Expanded(
                              child: ListView(
                                  children: isMobile
                                      ? buildListInMobile()
                                      : buildListInPc())),
                          //Pagination
                          SizedBox(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      controller.getDepositsFirstPage();
                                    },
                                    icon: const Icon(Icons.skip_previous)),
                                IconButton(
                                    onPressed: () {
                                      controller.getDepositsPreviousPage();
                                    },
                                    icon: const Icon(
                                        Icons.navigate_before_sharp)),
                                IconButton(
                                    onPressed: () {
                                      controller.getDepositsNextPage();
                                    },
                                    icon:
                                        const Icon(Icons.navigate_next_sharp)),
                                IconButton(
                                    onPressed: () {
                                      controller.getDepositsLastPage();
                                    },
                                    icon: const Icon(Icons.skip_next)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButtonText(
                            text:
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_CASH)} ${NumberUtil.numberFormat.format(controller.totalMoneyOfRecptionCash ?? 0)}'))
                  ],
                ),
              );
            },
            child: const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      title: NeutronTextContent(
          message: UITitleUtil.getTitleByCode(
              UITitleCode.SIDEBAR_RECEPTION_CASH_MANAGEMENT)),
      automaticallyImplyLeading: !isMobile,
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronIconButton(
          icon: Icons.horizontal_rule,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.HINT_WITHDRAW_CASH),
          onPressed: () async {
            final cashLog = await showDialog<Deposit>(
                context: context,
                builder: (context) => AddCashLogDialog(
                    false, controller.totalMoneyOfRecptionCash!));
            if (cashLog == null) return;
            controller.addCashLog(cashLog);
          },
        ),
        NeutronIconButton(
          icon: Icons.add,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.HINT_ADD_CASH),
          onPressed: () async {
            final cashLog = await showDialog<Deposit>(
                context: context,
                builder: (context) => AddCashLogDialog(
                    true, controller.totalMoneyOfRecptionCash!));
            if (cashLog == null) return;
            controller.addCashLog(cashLog);
          },
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: controller.startDate,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365)),
          onChange: (picked) {
            controller.setStartDate(picked);
          },
          margin: isMobile ? 3 : 10,
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: controller.endDate,
          firstDate: controller.startDate,
          lastDate: controller.startDate
              .add(Duration(days: controller.maxTimePeriod)),
          onChange: (picked) {
            controller.setEndDate(picked);
          },
          margin: isMobile ? 3 : 10,
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: () {
            controller.loadCashLogs();
          },
          margin: isMobile ? 3 : 10,
        ),
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            String? result = await controller.exportToExcel();
            if (mounted && result != null) {
              MaterialUtil.showAlert(context, result);
            }
          },
          margin: isMobile ? 3 : 10,
        )
      ],
    );
  }

  List<Widget> buildListInPc() {
    return controller.cashLogs
        .map((cashLog) => cashLog.created == null
            ?
            // ui for payment total
            InkWell(
                child: Container(
                  height: SizeManagement.cardHeight,
                  margin: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding,
                      vertical: SizeManagement.cardOutsideVerticalPadding),
                  decoration: BoxDecoration(
                      color: ColorManagement.lightMainBackground,
                      borderRadius:
                          BorderRadius.circular(SizeManagement.borderRadius8)),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: SizeManagement.cardInsideHorizontalPadding),
                          child: NeutronTextContent(message: ''),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: NeutronTextContent(
                          message: cashLog.desc!,
                        ),
                      ),
                      Expanded(
                          child: NeutronTextContent(
                        message: NumberUtil.numberFormat.format(cashLog.amount),
                        textAlign: TextAlign.end,
                        color: cashLog.amount! < 0
                            ? ColorManagement.negativeText
                            : ColorManagement.positiveText,
                      )),
                      const SizedBox(
                        width: 110,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => PaymentManagementDialog(
                          controller.startDate,
                          controller.endDate,
                          PaymentMethodManager.cashMethodID));
                },
              )
            : Container(
                height: SizeManagement.cardHeight,
                margin: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardOutsideHorizontalPadding,
                    vertical: SizeManagement.cardOutsideVerticalPadding),
                decoration: BoxDecoration(
                    color: ColorManagement.lightMainBackground,
                    borderRadius:
                        BorderRadius.circular(SizeManagement.borderRadius8)),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthHourMinuteString(
                                cashLog.created!.toDate())),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: NeutronTextContent(
                        message: cashLog.desc!,
                      ),
                    ),
                    Expanded(
                        child: NeutronTextContent(
                      message: NumberUtil.numberFormat.format(cashLog.amount),
                      textAlign: TextAlign.end,
                      color: cashLog.amount! < 0
                          ? ColorManagement.negativeText
                          : ColorManagement.positiveText,
                    )),
                    NeutronStatusDropdown(
                      margin: const EdgeInsets.only(
                          left: SizeManagement.rowSpacing),
                      width: 100,
                      currentStatus: cashLog.status!,
                      onChanged: (String newStatus) async {
                        String result = await controller.updateCashLogStatus(
                            cashLog, newStatus);
                        if (mounted && result != MessageCodeUtil.SUCCESS) {
                          MaterialUtil.showResult(
                              context, MessageUtil.getMessageByCode(result));
                        }
                      },
                      items: controller.statuses,
                      isDisable: !controller.statuses.contains(cashLog.status),
                    )
                  ],
                ),
              ))
        .toList();
  }

  List<Widget> buildListInMobile() {
    return controller.cashLogs
        .map((cashLog) => cashLog.created == null
            ? InkWell(
                child: Container(
                  height: SizeManagement.cardHeight,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding),
                  margin: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding,
                      vertical: SizeManagement.cardOutsideVerticalPadding),
                  decoration: BoxDecoration(
                      color: ColorManagement.lightMainBackground,
                      borderRadius:
                          BorderRadius.circular(SizeManagement.borderRadius8)),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeutronTextContent(
                          tooltip: cashLog.desc,
                          message: cashLog.desc!,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      NeutronTextContent(
                        message: NumberUtil.moneyFormat.format(cashLog.amount),
                        textAlign: TextAlign.end,
                        color: cashLog.amount! < 0
                            ? ColorManagement.negativeText
                            : ColorManagement.positiveText,
                      ),
                      const SizedBox(width: 40)
                    ],
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => PaymentManagementDialog(
                          controller.startDate,
                          controller.endDate,
                          PaymentMethodManager.cashMethodID));
                },
              )
            : Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeManagement.borderRadius8),
                    color: ColorManagement.lightMainBackground),
                margin: const EdgeInsets.only(
                    left: SizeManagement.cardOutsideHorizontalPadding,
                    right: SizeManagement.cardOutsideHorizontalPadding,
                    bottom: SizeManagement.bottomFormFieldSpacing),
                // Expansion Title
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding),
                  childrenPadding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeutronTextContent(
                          message: cashLog.created != null
                              ? DateUtil.dateToDayMonthHourMinuteString(
                                  cashLog.created!.toDate())
                              : ''),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: NeutronTextContent(
                          color: cashLog.amount! < 0
                              ? ColorManagement.negativeText
                              : ColorManagement.positiveText,
                          message:
                              (NumberUtil.moneyFormat.format(cashLog.amount)),
                        ),
                      )
                    ],
                  ),
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: NeutronTextContent(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                        )),
                        Expanded(
                            child: NeutronTextContent(
                          message: cashLog.desc!,
                          tooltip: cashLog.desc,
                          maxLines: 2,
                        ))
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: NeutronTextContent(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_STATUS),
                        )),
                        Expanded(
                            child: NeutronStatusDropdown(
                          margin: const EdgeInsets.only(
                              left: SizeManagement.rowSpacing),
                          width: 100,
                          currentStatus: cashLog.status!,
                          onChanged: (String newStatus) async {
                            String result = await controller
                                .updateCashLogStatus(cashLog, newStatus);
                            if (mounted && result != MessageCodeUtil.SUCCESS) {
                              MaterialUtil.showResult(context,
                                  MessageUtil.getMessageByCode(result));
                            }
                          },
                          items: controller.statuses,
                          isDisable:
                              !controller.statuses.contains(cashLog.status),
                        ))
                      ],
                    )
                  ],
                ),
              ))
        .toList();
  }

  Container buildTitleInPc() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE),
            ),
          )),
          Expanded(
              flex: 2,
              child: NeutronTextTitle(
                isPadding: false,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
              )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            isPadding: false,
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
          )),
          const SizedBox(
            width: 110,
          )
        ],
      ),
    );
  }

  Container buildTitleInMobile() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding,
          vertical: SizeManagement.cardOutsideVerticalPadding),
      child: Row(
        children: [
          Expanded(
            child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE),
            ),
          ),
          const SizedBox(width: 4),
          NeutronTextContent(
            message: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
          ),
          const SizedBox(width: 40)
        ],
      ),
    );
  }
}

class AddCashLogDialog extends StatefulWidget {
  final bool isAdd;
  final num totalCash;
  const AddCashLogDialog(this.isAdd, this.totalCash, {Key? key})
      : super(key: key);

  @override
  State<AddCashLogDialog> createState() => _AddCashLogDialogState();
}

class _AddCashLogDialogState extends State<AddCashLogDialog> {
  AddCashLogController? addCashLogController;

  late NeutronInputNumberController inputMoneyController;

  @override
  void initState() {
    addCashLogController ??= AddCashLogController(widget.totalCash);
    inputMoneyController =
        NeutronInputNumberController(addCashLogController!.amountController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        width: kMobileWidth,
        height: 340,
        color: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider.value(
          value: addCashLogController,
          child: Consumer<AddCashLogController>(
            builder: (_, controller, __) {
              if (controller.isAdding) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                );
              }
              return Stack(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      child: NeutronTextHeader(
                        message: widget.isAdd
                            ? UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_ADD_CASH)
                            : UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_WITHDRAW_CASH),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding,
                          vertical: SizeManagement.rowSpacing),
                      child: NeutronTextTitle(
                          isRequired: true,
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: SizeManagement.bottomFormFieldSpacing,
                          left: SizeManagement.cardOutsideHorizontalPadding,
                          right: SizeManagement.cardOutsideHorizontalPadding),
                      child: NeutronTextFormField(
                        isDecor: true,
                        controller: controller.descController,
                        maxLine: 3,
                        validator: (value) => value!.isEmpty
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.INPUT_DESCRIPTION)
                            : null,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding,
                          vertical: SizeManagement.rowSpacing),
                      child: NeutronTextTitle(
                          isRequired: true,
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: SizeManagement.bottomFormFieldSpacing,
                          left: SizeManagement.cardOutsideHorizontalPadding,
                          right: SizeManagement.cardOutsideHorizontalPadding),
                      child: inputMoneyController.buildWidget(),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: NeutronButton(
                    icon1: widget.isAdd ? Icons.add : Icons.horizontal_rule,
                    onPressed1: () async {
                      final result =
                          await controller.withdrawCashLog(widget.isAdd);
                      if (!mounted) {
                        return;
                      }
                      if (result['result'] == MessageCodeUtil.SUCCESS) {
                        Navigator.pop(context, result['data']);
                      } else {
                        MaterialUtil.showAlert(context,
                            MessageUtil.getMessageByCode(result['result']));
                      }
                    },
                  ),
                )
              ]);
            },
          ),
        ),
      ),
    );
  }
}
