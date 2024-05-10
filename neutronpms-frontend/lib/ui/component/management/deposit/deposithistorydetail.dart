import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class DepositHistoryDetail extends StatelessWidget {
  const DepositHistoryDetail({super.key, required this.deposit});
  final BookingDeposit deposit;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        width: kMobileWidth,
        height: deposit.history.length > 4
            ? kHeight
            : (80 * deposit.history.length + 75).toDouble(),
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding,
            vertical: SizeManagement.cardInsideVerticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: SizeManagement.topHeaderTextSpacing),
              child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_HISTORY)),
            ),
            Expanded(
                child: ListView(
              children: deposit.history
                  .map(
                    (e) => Container(
                      decoration: BoxDecoration(
                          color: ColorManagement.lightMainBackground,
                          border: Border.all(color: ColorManagement.greenColor),
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.cardInsideVerticalPadding,
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      height: 90,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            NeutronTextContent(
                                textAlign: TextAlign.start,
                                message:
                                    '${DateUtil.dateToDayMonthYearHourMinuteString(e.time)} ${e.status == DepositStatus.DEPOSIT ? "Cọc cho Booking có Sid" : "Trả Cọc cho Booking có Sid"}: ${e.sid}'),
                            NeutronTextContent(
                                textAlign: TextAlign.start,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} : ${e.name}'),
                            NeutronTextContent(
                                textAlign: TextAlign.start,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY)} : ${NumberUtil.numberFormat.format(e.amount)}'),
                            NeutronTextContent(
                                textAlign: TextAlign.start,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT_METHOD)} : ${PaymentMethodManager().getPaymentMethodNameById(e.paymentMethod)}'),
                          ]),
                    ),
                  )
                  .toList(),
            ))
          ],
        ),
      ),
    );
  }
}
