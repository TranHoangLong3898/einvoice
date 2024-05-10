import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/depositmanagement/depositrefundcontroller.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class DepositRefundDialog extends StatelessWidget {
  const DepositRefundDialog(
      {super.key,
      required this.deposit,
      this.isAddRefund = true,
      this.transferBooking = false});
  final BookingDeposit deposit;
  final bool isAddRefund;
  final bool transferBooking;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardInsideVerticalPadding,
            horizontal: SizeManagement.cardInsideHorizontalPadding),
        width: kMobileWidth,
        height: transferBooking ? 300 : 400,
        child: ChangeNotifierProvider<DepositRefundController>(
          create: (context) =>
              DepositRefundController(deposit, isAddRefund, transferBooking),
          builder: (context, child) => Consumer<DepositRefundController>(
            builder: (context, controller, child) => controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: SizeManagement.topHeaderTextSpacing),
                        child: Center(
                          child: NeutronTextTitle(
                              fontSize: 18,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DEPOSIT)),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            if (transferBooking)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SID),
                                  controller: controller.sidTeController,
                                  backgroundColor:
                                      ColorManagement.lightMainBackground,
                                  isDecor: true,
                                  borderColor: ColorManagement.greenColor,
                                ),
                              ),
                            if (!transferBooking)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  suffixIcon: InkWell(
                                    child: const Icon(
                                      Icons.calendar_month,
                                      color: ColorManagement.white,
                                    ),
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                          builder: (context, child) =>
                                              DateTimePickerDarkTheme
                                                  .buildDarkTheme(
                                                      context, child!),
                                          context: context,
                                          initialDate: controller.createTime ??
                                              DateTime.now(),
                                          firstDate:
                                              UserManager.isManagementRole()
                                                  ? DateTime.now().subtract(
                                                      const Duration(days: 60))
                                                  : DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)));
                                      if (picked != null) {
                                        controller.setEndDate(picked);
                                      }
                                    },
                                  ),
                                  readOnly: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TIME),
                                  controller: TextEditingController(
                                      text: DateUtil.dateToDayMonthYearString(
                                          controller.createTime)),
                                  backgroundColor:
                                      ColorManagement.lightMainBackground,
                                  isDecor: true,
                                  borderColor: ColorManagement.greenColor,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom:
                                      SizeManagement.bottomFormFieldSpacing),
                              child: NeutronTextFormField(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_NOTES),
                                controller: controller.noteTeController,
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                isDecor: true,
                                borderColor: ColorManagement.greenColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom:
                                      SizeManagement.bottomFormFieldSpacing),
                              child: controller.amountInput!.buildWidget(
                                  isDecor: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                                  isDouble: true,
                                  borderColor: ColorManagement.greenColor),
                            ),
                            if (!transferBooking)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronDropDownCustom(
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_PAYMENT_METHOD),
                                  borderColors: ColorManagement.greenColor,
                                  childWidget: NeutronDropDown(
                                    value: controller.paymentMethod! ==
                                            UITitleCode.NO
                                        ? UITitleUtil.getTitleByCode(
                                            UITitleCode.NO)
                                        : PaymentMethodManager()
                                            .getPaymentMethodNameById(
                                                controller.paymentMethod!),
                                    items: [
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.NO),
                                      ...PaymentMethodManager()
                                          .paymentMethodsActive
                                          .where((element) =>
                                              element.id != 'transfer')
                                          .map((paymentMethod) =>
                                              paymentMethod.name)
                                          .toList()
                                    ],
                                    onChanged: (String value) {
                                      controller.setPaymentMethod(value);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          await controller.updateRefundDeposit().then((result) {
                            if (result == MessageCodeUtil.SUCCESS) {
                              Navigator.pop(context);
                            } else {
                              MaterialUtil.showResult(context,
                                  MessageUtil.getMessageByCode(result));
                            }
                          });
                        },
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
