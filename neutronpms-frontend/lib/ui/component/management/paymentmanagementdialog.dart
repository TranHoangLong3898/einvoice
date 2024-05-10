import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/booking/updatepaymentmanagerdialog.dart';
import 'package:ihotel/ui/component/management/paymentmanagerdetaildialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutronprintpdf.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/pdfutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/management/paymentmanagementcontroller.dart';
import '../../../manager/paymentmethodmanager.dart';
import '../../../manager/sourcemanager.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';

class PaymentManagementDialog extends StatefulWidget {
  final String? paymentMethodID;
  final DateTime? inDate;
  final DateTime? outDate;
  const PaymentManagementDialog(
      [this.inDate, this.outDate, this.paymentMethodID, Key? key])
      : super(key: key);

  @override
  State<PaymentManagementDialog> createState() =>
      _PaymentManagementDialogState();
}

class _PaymentManagementDialogState extends State<PaymentManagementDialog> {
  PaymentManagementController? controller;

  @override
  void initState() {
    if (widget.inDate != null &&
        widget.outDate != null &&
        widget.paymentMethodID != null) {
      controller ??= PaymentManagementController(
          widget.inDate,
          widget.outDate,
          PaymentMethodManager()
              .getPaymentMethodNameById(widget.paymentMethodID!));
    } else {
      controller ??= PaymentManagementController();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kLargeWidth + 200;
    }
    final now = Timestamp.now().toDate();

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<PaymentManagementController>(
            builder: (_, controller, __) {
              final children = !isMobile
                  ? controller.deposits!.map((deposit) {
                      final statuses = PaymentMethodManager()
                          .getStatusByPaymentID(deposit.method!);
                      return InkWell(
                        onTap: () {
                          if (deposit.method == "transferdeposit") return;
                          showDialog(
                            context: context,
                            builder: (context) =>
                                UpdatePaymentManagerDialog(deposit: deposit),
                          );
                        },
                        child: Container(
                          height: SizeManagement.cardHeight,
                          margin: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding,
                              vertical:
                                  SizeManagement.cardOutsideVerticalPadding),
                          decoration: BoxDecoration(
                              color: ColorManagement.lightMainBackground,
                              borderRadius: BorderRadius.circular(
                                  SizeManagement.borderRadius8)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardInsideHorizontalPadding),
                                  child: NeutronTextContent(
                                      message: DateUtil
                                          .dateToDayMonthHourMinuteString(
                                              deposit.created!.toDate())),
                                ),
                              ),
                              Expanded(
                                child: NeutronTextContent(
                                  tooltip: deposit.sID,
                                  message: deposit.sID!,
                                ),
                              ),
                              Expanded(
                                  child: NeutronTextContent(
                                      tooltip: deposit.name,
                                      message: deposit.name!)),
                              Expanded(
                                  child: NeutronTextContent(
                                      tooltip: deposit.desc,
                                      message: deposit.desc!)),
                              Expanded(
                                  child: NeutronTextContent(
                                      textAlign: TextAlign.center,
                                      message: RoomManager()
                                          .getNameRoomById(deposit.room!))),
                              Expanded(
                                  child: NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          deposit.inDate!))),
                              Expanded(
                                  child: NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          deposit.outDate!))),
                              Expanded(
                                  child: Text(
                                NumberUtil.numberFormat.format(deposit.amount),
                                textAlign: TextAlign.end,
                                style: NeutronTextStyle.totalNumber,
                              )),
                              Expanded(
                                  child: Center(
                                child: NeutronTextContent(
                                    tooltip: PaymentMethodManager()
                                        .getPaymentMethodNameById(
                                            deposit.method!),
                                    message: PaymentMethodManager()
                                        .getPaymentMethodNameById(
                                            deposit.method!)),
                              )),
                              Expanded(
                                  child: Center(
                                child: NeutronTextContent(
                                    message: SourceManager()
                                        .getSourceNameByID(deposit.sourceID!)),
                              )),
                              Expanded(
                                  child: NeutronStatusDropdown(
                                currentStatus: deposit.status!,
                                onChanged: (String newStatus) async {
                                  String? result = await controller
                                      .updateDepositStatus(deposit, newStatus);
                                  if (mounted && result != null) {
                                    MaterialUtil.showResult(context, result);
                                  }
                                },
                                items: statuses!,
                                isDisable: !statuses.contains(deposit.status),
                              )),
                              SizedBox(
                                width: 120,
                                child: controller.isLoadingConfirmMoney &&
                                        controller.idDeposit == deposit.id
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: ColorManagement.greenColor))
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: NeutronTextContent(
                                                message: deposit.confirmDate ==
                                                        null
                                                    ? ""
                                                    : DateUtil
                                                        .dateToDayMonthYearString(
                                                            deposit
                                                                .confirmDate!)),
                                          ),
                                          IconButton(
                                              iconSize: 20,
                                              icon: const Icon(
                                                  Icons.calendar_today),
                                              tooltip:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode.TOOLTIP_DATE),
                                              onPressed: () async {
                                                final DateTime now =
                                                    Timestamp.now().toDate();
                                                final DateTime? picked = await showDatePicker(
                                                    builder: (context, child) =>
                                                        DateTimePickerDarkTheme
                                                            .buildDarkTheme(
                                                                context,
                                                                child!),
                                                    context: context,
                                                    initialDate: Timestamp.now()
                                                        .toDate(),
                                                    firstDate: now.subtract(
                                                        const Duration(
                                                            days: 365)),
                                                    lastDate: now.add(
                                                        const Duration(days: 365)));
                                                if (picked != null) {
                                                  bool? isConfirmed =
                                                      // ignore: use_build_context_synchronously
                                                      await MaterialUtil
                                                          .showConfirm(
                                                    context,
                                                    MessageUtil.getMessageByCode(
                                                        MessageCodeUtil
                                                            .CONFIRM_YOU_ARE_SURE,
                                                        [
                                                          DateUtil
                                                              .dateToDayMonthYearString(
                                                                  picked)
                                                        ]),
                                                  );
                                                  if (isConfirmed != null &&
                                                      isConfirmed) {
                                                    controller
                                                        .setConfirmDate(picked);
                                                    String result =
                                                        await controller
                                                            .updateConfirmMoney(
                                                                deposit);
                                                    if (mounted &&
                                                        result !=
                                                            MessageCodeUtil
                                                                .SUCCESS) {
                                                      MaterialUtil.showResult(
                                                          context, result);
                                                    }
                                                  }
                                                }
                                              }),
                                        ],
                                      ),
                              ),
                              if (deposit.sID!.isNotEmpty)
                                SizedBox(
                                    width: 40,
                                    child: NeutronBookingContextMenu(
                                      booking: Booking.empty(
                                          id: deposit.bookingID,
                                          sID: deposit.sID),
                                      tooltip: UITitleUtil.getTitleByCode(
                                          UITitleCode.TOOLTIP_MENU),
                                    )),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  : controller.deposits!.map((deposit) {
                      final statuses = PaymentMethodManager()
                          .getStatusByPaymentID(deposit.method!);
                      return InkWell(
                        onTap: () {
                          if (deposit.method == "transferdeposit") return;
                          showDialog(
                            context: context,
                            builder: (context) =>
                                UpdatePaymentManagerDialog(deposit: deposit),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeManagement.borderRadius8),
                              color: ColorManagement.lightMainBackground),
                          margin: const EdgeInsets.only(
                              left: SizeManagement.cardOutsideHorizontalPadding,
                              right:
                                  SizeManagement.cardOutsideHorizontalPadding,
                              bottom: SizeManagement.bottomFormFieldSpacing),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: NeutronTextContent(
                                      textOverflow: TextOverflow.clip,
                                      maxLines: 2,
                                      tooltip: DateUtil
                                          .dateToDayMonthHourMinuteString(
                                              deposit.created!.toDate()),
                                      message: DateUtil
                                          .dateToDayMonthHourMinuteString(
                                              deposit.created!.toDate())),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: NeutronTextContent(
                                        color: ColorManagement.positiveText,
                                        message: NumberUtil.moneyFormat
                                            .format(deposit.amount)),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: NeutronTextContent(
                                      message: PaymentMethodManager()
                                          .getPaymentMethodNameById(
                                              deposit.method!)),
                                ))
                              ],
                            ),
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SOURCE_ID),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                        message: deposit.sID!,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            message: deposit.name!))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DESCRIPTION_FULL),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            tooltip: deposit.desc,
                                            message: deposit.desc!))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ROOM),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            message: RoomManager()
                                                .getNameRoomById(
                                                    deposit.room!)))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_IN),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            message:
                                                DateUtil.dateToDayMonthString(
                                                    deposit.inDate!)))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_OUT),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            message:
                                                DateUtil.dateToDayMonthString(
                                                    deposit.outDate!)))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SOURCE_FROM),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            message: SourceManager()
                                                .getSourceNameByID(
                                                    deposit.sourceID!)))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PAYMENT_DATE),
                                    )),
                                    Expanded(
                                        child: controller
                                                    .isLoadingConfirmMoney &&
                                                controller.idDeposit ==
                                                    deposit.id
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: ColorManagement
                                                            .greenColor))
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child: NeutronTextContent(
                                                        message: deposit
                                                                    .confirmDate ==
                                                                null
                                                            ? ""
                                                            : DateUtil
                                                                .dateToDayMonthYearString(
                                                                    deposit
                                                                        .confirmDate!)),
                                                  ),
                                                  IconButton(
                                                      iconSize: 20,
                                                      icon: const Icon(
                                                          Icons.calendar_today),
                                                      tooltip: UITitleUtil
                                                          .getTitleByCode(
                                                              UITitleCode
                                                                  .TOOLTIP_DATE),
                                                      onPressed: () async {
                                                        final DateTime now =
                                                            Timestamp.now()
                                                                .toDate();
                                                        final DateTime? picked = await showDatePicker(
                                                            builder: (context,
                                                                    child) =>
                                                                DateTimePickerDarkTheme
                                                                    .buildDarkTheme(
                                                                        context,
                                                                        child!),
                                                            context: context,
                                                            initialDate:
                                                                Timestamp.now()
                                                                    .toDate(),
                                                            firstDate: now.subtract(
                                                                const Duration(
                                                                    days: 365)),
                                                            lastDate: now.add(
                                                                const Duration(days: 365)));
                                                        if (picked != null) {
                                                          bool? isConfirmed =
                                                              // ignore: use_build_context_synchronously
                                                              await MaterialUtil
                                                                  .showConfirm(
                                                            context,
                                                            MessageUtil.getMessageByCode(
                                                                MessageCodeUtil
                                                                    .CONFIRM_YOU_ARE_SURE,
                                                                [
                                                                  DateUtil
                                                                      .dateToDayMonthYearString(
                                                                          picked)
                                                                ]),
                                                          );
                                                          if (isConfirmed !=
                                                                  null &&
                                                              isConfirmed) {
                                                            controller
                                                                .setConfirmDate(
                                                                    picked);
                                                            String result =
                                                                await controller
                                                                    .updateConfirmMoney(
                                                                        deposit);
                                                            if (mounted &&
                                                                result !=
                                                                    MessageCodeUtil
                                                                        .SUCCESS) {
                                                              MaterialUtil
                                                                  .showResult(
                                                                      context,
                                                                      result);
                                                            }
                                                          }
                                                        }
                                                      }),
                                                ],
                                              ))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10, bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_STATUS),
                                    )),
                                    Expanded(
                                        child: NeutronStatusDropdown(
                                      currentStatus: deposit.status!,
                                      onChanged: (String newStatus) async {
                                        String? result = await controller
                                            .updateDepositStatus(
                                                deposit, newStatus);
                                        if (mounted && result != null) {
                                          MaterialUtil.showResult(
                                              context, result);
                                        }
                                      },
                                      items: statuses!,
                                      isDisable:
                                          !statuses.contains(deposit.status),
                                    ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList();

              if (controller.deposits == null) {
                return Container(
                  color: ColorManagement.mainBackground,
                  alignment: Alignment.center,
                  child: Text(MessageUtil.getMessageByCode(
                      MessageCodeUtil.UNDEFINED_ERROR)),
                );
              }

              return Scaffold(
                  floatingActionButton: floatingActionButton(controller),
                  backgroundColor: ColorManagement.mainBackground,
                  appBar: AppBar(
                    leadingWidth: isMobile ? 0 : 56,
                    leading: isMobile ? Container() : null,
                    title: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT)),
                    backgroundColor: ColorManagement.mainBackground,
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
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_REFRESH),
                        icon: Icons.refresh,
                        onPressed: () {
                          controller.loadDeposits();
                        },
                      ),
                      NeutronBlurButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_PRINT),
                        icon: Icons.print,
                        onPressed: () async {
                          await controller
                              .getAllPaymentForExporting()
                              .then((exportData) {
                            if (exportData.isEmpty) {
                              return MaterialUtil.showAlert(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.NO_DATA));
                            }
                            showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                        child: SizedBox(
                                      width: kMobileWidth,
                                      height: 70,
                                      child: NeutronButton(
                                        margin: const EdgeInsets.all(
                                            SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        icon: Icons.picture_as_pdf,
                                        icon1: Icons.file_present_rounded,
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_EXPORT_TO_PDF),
                                        tooltip1: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TOOLTIP_EXPORT_TO_EXCEL),
                                        onPressed: () async {
                                          await PrintPDFToDevice
                                              .printPdfAccordingToDevice(
                                                  context,
                                                  PDFUtil
                                                      .buildPaymentManagementPDFDoc(
                                                          exportData,
                                                          controller
                                                              .dataPayment),
                                                  "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT)}_${DateUtil.dateToShortString(controller.startDate)}_${DateUtil.dateToShortString(controller.endDate)}");
                                        },
                                        onPressed1: () async {
                                          ExcelUlti.exportPaymentManagement(
                                              exportData,
                                              controller.dataPayment,
                                              controller.startDate,
                                              controller.endDate);
                                        },
                                      ),
                                    )));
                          });
                        },
                      ),
                    ],
                  ),
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 65),
                        child: Column(
                          children: [
                            !isMobile
                                ? Container(
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardInsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_CREATE),
                                          ),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_SOURCE_ID),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_NAME),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_DESCRIPTION_FULL),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          textAlign: TextAlign.center,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_ROOM),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_IN),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_OUT),
                                        )),
                                        Expanded(
                                            child: NeutronTextTitle(
                                          textAlign: TextAlign.end,
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_PAYMENT),
                                        )),
                                        Expanded(
                                          child: NeutronDropDown(
                                            value: controller.methodName,
                                            onChanged:
                                                (String newMethod) async {
                                              controller.setMethod(newMethod);
                                            },
                                            items: controller.getMethodNames(),
                                          ),
                                        ),
                                        Expanded(
                                          child: NeutronDropDown(
                                            value: controller.sourceName,
                                            onChanged:
                                                (String newSource) async {
                                              controller.setSource(newSource);
                                            },
                                            items: controller.getSourceNames(),
                                          ),
                                        ),
                                        Expanded(
                                          child: NeutronDropDown(
                                            value: controller.status,
                                            onChanged:
                                                (String newStatus) async {
                                              controller.setStatus(newStatus);
                                            },
                                            items: controller.getStatuses(),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 120,
                                            child: Tooltip(
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_PAYMENT_DATE),
                                              child: NeutronTextTitle(
                                                isPadding: false,
                                                messageUppercase: false,
                                                message: UITitleUtil
                                                    .getTitleByCode(UITitleCode
                                                        .TABLEHEADER_PAYMENT_DATE),
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 40,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_CREATE),
                                          ),
                                        ),
                                        Expanded(
                                          child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_PAYMENT),
                                          ),
                                        ),
                                        Expanded(
                                          child: NeutronDropDown(
                                            value: controller.methodName,
                                            onChanged:
                                                (String newMethod) async {
                                              controller.setMethod(newMethod);
                                            },
                                            items: controller.getMethodNames(),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 40,
                                        )
                                      ],
                                    ),
                                  ),
                            Expanded(
                              child: controller.isLoading!
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: ColorManagement.greenColor,
                                      ),
                                    )
                                  : ListView(
                                      children: children,
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
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButtonText(
                            text:
                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT)}: ${NumberUtil.numberFormat.format(controller.depositTotal)}",
                          )),
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton(
          PaymentManagementController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.lightMainBackground,
        mini: true,
        tooltip: UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_PAYMENT_METHOD_REPORT_DETAIL),
        onPressed: () async =>
            await controller.getAllPaymentForExporting().then((booking) {
          controller.totalAll = 0;
          showDialog(
            context: context,
            builder: (context) =>
                DetailPaymentManagerDialog(controller: controller),
          );
        }),
        child: const Icon(Icons.description_sharp),
      );
}
