import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/contextmenuutil.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/pdfutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/depositcontroller.dart';
import '../../../manager/paymentmethodmanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/deposit.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../booking/adddepositdialog.dart';

class DepositDialog extends StatefulWidget {
  final Booking? booking;
  const DepositDialog({Key? key, this.booking}) : super(key: key);

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  DepositController? controller;

  @override
  void initState() {
    controller ??= DepositController(widget.booking);
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
      width = kWidth;
    }
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        height: height,
        width: width,
        child: Scaffold(
          backgroundColor: ColorManagement.mainBackground,
          appBar: AppBar(
              backgroundColor: ColorManagement.mainBackground,
              title: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.DEPOSITDIALOG_TITLE)),
              actions: const []),
          body: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<DepositController>(
              builder: (_, controller, __) {
                if (controller.isLoading()) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  );
                }
                if (controller.deposits == null) {
                  return Column(children: [
                    Center(
                      child: Text(MessageUtil.getMessageByCode(
                          MessageCodeUtil.UNDEFINED_ERROR)),
                    ),
                  ]);
                }
                Widget child;
                if (controller.deposits!.isEmpty) {
                  child = Center(
                    child: Text(
                      widget.booking!.canUpdateDeposit()
                          ? MessageUtil.getMessageByCode(
                              MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.NO_DATA),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  final children = controller.deposits!
                      .map((deposit) => Container(
                            height: SizeManagement.cardHeight,
                            margin: const EdgeInsets.only(
                                bottom: SizeManagement.rowSpacing),
                            padding: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardInsideHorizontalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            decoration: BoxDecoration(
                                color: ColorManagement.lightMainBackground,
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8)),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 85,
                                  child: NeutronTextContent(
                                      message: DateUtil
                                          .dateToDayMonthHourMinuteString(
                                              deposit.created!.toDate())),
                                ),
                                if (!isMobile)
                                  Expanded(
                                    child: NeutronTextContent(
                                        tooltip: deposit.desc,
                                        message: deposit.desc!),
                                  ),
                                SizedBox(
                                  width: 75,
                                  child: NeutronTextContent(
                                    message: PaymentMethodManager()
                                        .getPaymentMethodNameById(
                                            deposit.method!),
                                  ),
                                ),
                                SizedBox(
                                  width: 75,
                                  child: NeutronTextContent(
                                    textAlign: TextAlign.right,
                                    message: NumberUtil.numberFormat
                                        .format(deposit.amount),
                                    color: deposit.amount! > 0
                                        ? ColorManagement.positiveText
                                        : ColorManagement.negativeText,
                                  ),
                                ),
                                //menu in mobile
                                if (isMobile &&
                                    widget.booking!.canUpdateDeposit())
                                  SizedBox(
                                    width: 20,
                                    child: PopupMenuButton(
                                        color: ColorManagement.mainBackground,
                                        child: const Icon(Icons.more_vert),
                                        itemBuilder: (context) => [
                                              if (!(controller
                                                      .booking!.group! &&
                                                  controller.booking!.id !=
                                                      controller.booking!.sID))
                                                ContextMenuUtil().menuPrint,
                                              if (deposit.method !=
                                                  "transferdeposit")
                                                ContextMenuUtil().editDeposit,
                                              if (deposit.method !=
                                                  "transferdeposit")
                                                ContextMenuUtil().deleteDeposit,
                                            ],
                                        onSelected: (String value) async {
                                          switch (value) {
                                            case 'Edit':
                                              await showDialog<String>(
                                                context: context,
                                                builder: (ctx) =>
                                                    AddDepositDialog(
                                                  deposit: deposit,
                                                  booking: widget.booking!,
                                                ),
                                              ).then((result) =>
                                                  {controller.loadDeposits()});
                                              return;
                                            case 'Delete':
                                              // ignore: use_build_context_synchronously
                                              await MaterialUtil.showConfirm(
                                                      context,
                                                      MessageUtil.getMessageByCode(
                                                          MessageCodeUtil
                                                              .CONFIRM_DELETE_PAYMENT_WITH_AMOUNT,
                                                          [
                                                            NumberUtil
                                                                .numberFormat
                                                                .format(deposit
                                                                    .amount)
                                                          ]))
                                                  .then((confirmed) => confirmed!
                                                      ? controller
                                                          .deleteDeposit(
                                                              deposit)
                                                          .then((result) =>
                                                              MaterialUtil.showResult(
                                                                  context, result))
                                                      : null);
                                              return;
                                            case 'Print':
                                              Printing.layoutPdf(
                                                  onLayout: (PdfPageFormat
                                                          format) async =>
                                                      (await PDFUtil
                                                              .buildDepositPDFDoc(
                                                                  controller
                                                                      .booking!,
                                                                  deposit))
                                                          .save());
                                              return;
                                            default:
                                              return;
                                          }
                                        }),
                                  ),
                                // Button edit deposits
                                (!isMobile &&
                                        widget.booking!.canUpdateDeposit() &&
                                        deposit.method != "transferdeposit")
                                    ? IconButton(
                                        padding: const EdgeInsets.all(0),
                                        onPressed: () async {
                                          String? result =
                                              await showDialog<String>(
                                            context: context,
                                            builder: (ctx) => AddDepositDialog(
                                              deposit: deposit,
                                              booking: widget.booking!,
                                            ),
                                          );
                                          if (result == null) return;
                                          if (result == '') {
                                            controller.loadDeposits();
                                          }
                                        },
                                        icon: const Icon(Icons.edit),
                                      )
                                    : const SizedBox(width: 40),
                                // Button delete deposits
                                (!isMobile &&
                                        widget.booking!.canUpdateDeposit() &&
                                        deposit.method != "transferdeposit")
                                    ? IconButton(
                                        padding: const EdgeInsets.all(0),
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          bool? isConfirmed =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_DELETE_PAYMENT_WITH_AMOUNT,
                                                      [
                                                        NumberUtil.numberFormat
                                                            .format(
                                                                deposit.amount)
                                                      ]));
                                          if (isConfirmed == null ||
                                              !isConfirmed) {
                                            return;
                                          }
                                          String result = await controller
                                              .deleteDeposit(deposit);
                                          if (mounted) {
                                            MaterialUtil.showResult(
                                                context, result);
                                          }
                                        })
                                    : const SizedBox(width: 40),
                                // Button print
                                if (!isMobile &&
                                    !(controller.booking!.group! &&
                                        controller.booking!.id !=
                                            controller.booking!.sID)) ...[
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: const Icon(Icons.print),
                                      onPressed: () async {
                                        Printing.layoutPdf(
                                            onLayout:
                                                (PdfPageFormat format) async =>
                                                    (await PDFUtil
                                                            .buildDepositPDFDoc(
                                                                controller
                                                                    .booking!,
                                                                deposit))
                                                        .save());
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      icon: const Icon(
                                          Icons.file_present_rounded),
                                      onPressed: () async {
                                        ExcelUlti.exportDepositForm(
                                            controller.booking!, deposit);
                                      })
                                ],
                              ],
                            ),
                          ))
                      .toList();

                  child = Column(
                    children: [
                      Expanded(child: ListView(children: children)),
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                icon: const Icon(Icons.navigate_before)),
                            IconButton(
                                onPressed: () {
                                  controller.getDepositNextPage();
                                },
                                icon: const Icon(Icons.navigate_next)),
                            IconButton(
                                onPressed: () {
                                  controller.getDepositLastPage();
                                },
                                icon: const Icon(Icons.skip_next)),
                          ],
                        ),
                      ),
                      Text(
                        "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT)}: ${NumberUtil.numberFormat.format(controller.totalDepositsMoney)}. ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRANSFERRED)}:  ${NumberUtil.numberFormat.format(controller.totalTransferredMoney)}.  ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRANSFERRING)}:  ${NumberUtil.numberFormat.format(controller.totalTransferingMoney)}",
                      )
                    ],
                  );
                }
                return Stack(fit: StackFit.expand, children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: widget.booking!.canUpdateDeposit()
                            ? 65
                            : SizeManagement.rowSpacing),
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            SizeManagement.cardOutsideHorizontalPadding),
                    child: Column(
                      children: [
                        const SizedBox(height: SizeManagement.rowSpacing),
                        //booking name
                        NeutronTextContent(
                          tooltip: controller.getInfo(),
                          message: controller.getInfo(),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        //title
                        Row(
                          children: [
                            const SizedBox(
                                width:
                                    SizeManagement.cardInsideHorizontalPadding),
                            SizedBox(
                                width: 85,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    fontSize: 13,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATE))),
                            if (!isMobile)
                              Expanded(
                                child: NeutronTextTitle(
                                  isPadding: false,
                                  fontSize: 13,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                                ),
                              ),
                            SizedBox(
                                width: 75,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    fontSize: 13,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TABLEHEADER_METHOD_COMPACT))),
                            SizedBox(
                                width: 75,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    textAlign: TextAlign.end,
                                    fontSize: 13,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_AMOUNT))),
                            if (isMobile && widget.booking!.canUpdateDeposit())
                              const SizedBox(width: 20),
                            if (!isMobile && widget.booking!.canUpdateDeposit())
                              const SizedBox(width: 80),
                            if (!isMobile &&
                                !(controller.booking!.group! &&
                                    controller.booking!.id !=
                                        controller.booking!.sID))
                              const SizedBox(width: 80),
                            const SizedBox(
                                width:
                                    SizeManagement.cardInsideHorizontalPadding),
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Expanded(child: child)
                      ],
                    ),
                  ),
                  if (widget.booking!.canUpdateDeposit())
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: NeutronButton(
                          icon: Icons.add,
                          onPressed: () async {
                            await showDialog<String>(
                              context: context,
                              builder: (ctx) => AddDepositDialog(
                                booking: widget.booking!,
                                totalPricePayment:
                                    controller.getTotalPricePaymet(
                                        (widget.booking?.getTotalCharge() ??
                                                0) +
                                            (widget.booking?.transferred ?? 0)),
                              ),
                            );
                          }),
                    ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getIcon(Deposit deposit) {
    if (deposit.method == PaymentMethodManager.cardMethodID) {
      return const Icon(Icons.monetization_on);
    } else if (deposit.method == PaymentMethodManager.bankMethodID) {
      return const Icon(Icons.account_balance_outlined);
    } else if (deposit.method == PaymentMethodManager.cardMethodID) {
      return const Icon(Icons.credit_card);
    } else {
      return Text(
        deposit.method!.substring(0, 1).toUpperCase(),
      );
    }
  }
}
