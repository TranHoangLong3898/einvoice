// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/depositmanagement/depositcontroller.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/bookingdeposit.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class DepositDialog extends StatelessWidget {
  const DepositDialog({super.key, this.deposit});
  final BookingDeposit? deposit;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardInsideVerticalPadding,
            horizontal: SizeManagement.cardInsideHorizontalPadding),
        width: kMobileWidth,
        height: deposit == null ? kHeight - 200 : kHeight,
        child: ChangeNotifierProvider<DepositController>(
          create: (context) => DepositController(deposit),
          builder: (context, child) => Consumer<DepositController>(
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom:
                                      SizeManagement.bottomFormFieldSpacing),
                              child: NeutronTextFormField(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_NAME),
                                controller: controller.teName,
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
                              child: NeutronTextFormField(
                                suffixIcon: InkWell(
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: ColorManagement.white,
                                  ),
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                            builder: (context, child) =>
                                                DateTimePickerDarkTheme
                                                    .buildDarkTheme(
                                                        context, child!),
                                            context: context,
                                            initialDate:
                                                controller.createTime ??
                                                    DateTime.now(),
                                            firstDate: UserManager
                                                    .isManagementRole()
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
                              child: controller.amountInput!.buildWidget(
                                  isDecor: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                                  isDouble: true,
                                  borderColor: ColorManagement.greenColor),
                            ),
                            if (deposit != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  readOnly: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_REMAIN),
                                  controller: controller.teRemain,
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
                                    UITitleUtil.getTitleByCode(UITitleCode.NO),
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
                            if (deposit != null)
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: ColorManagement.greenColor)),
                                child: ExpansionTile(
                                  iconColor: ColorManagement.white,
                                  collapsedIconColor: ColorManagement.white,
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  title: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_HISTORY)),
                                  children: controller.history!
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Tooltip(
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TOOLTIP_CLICK_TO_COPY_SID),
                                              child: InkWell(
                                                onTap: () async {
                                                  await Clipboard.setData(
                                                      ClipboardData(
                                                          text: e.sid));
                                                },
                                                child: NeutronTextContent(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 3,
                                                    message:
                                                        '${DateUtil.dateToString(e.time)} ${e.status == DepositStatus.DEPOSIT ? "Cọc cho Booking có Sid" : "Trả Cọc cho Booking có Sid"} ${e.sid} : ${NumberUtil.numberFormat.format(e.amount)} HK:${e.name}'),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )
                          ],
                        ),
                      ),
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          await controller.updateDeposit().then((result) {
                            if (result == MessageCodeUtil.SUCCESS) {
                              Navigator.pop(context);
                            }
                            MaterialUtil.showResult(
                                context, MessageUtil.getMessageByCode(result));
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
