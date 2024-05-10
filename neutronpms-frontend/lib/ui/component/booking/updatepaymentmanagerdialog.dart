import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/updatepaymentmanagercontroller.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/service/deposit.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrontextformfield.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../validator/numbervalidator.dart';

class UpdatePaymentManagerDialog extends StatefulWidget {
  final Deposit deposit;

  const UpdatePaymentManagerDialog({Key? key, required this.deposit})
      : super(key: key);

  @override
  State<UpdatePaymentManagerDialog> createState() =>
      _UpdatePaymentManagerDialogState();
}

class _UpdatePaymentManagerDialogState
    extends State<UpdatePaymentManagerDialog> {
  UpdatePaymentManagerController? controller;
  late NeutronInputNumberController actualAmountController;
  late NeutronInputNumberController amountController;
  late bool isDisable;
  @override
  void initState() {
    controller ??= UpdatePaymentManagerController(deposit: widget.deposit);
    amountController = NeutronInputNumberController(controller!.teAmount);
    actualAmountController =
        NeutronInputNumberController(controller!.teActualAmount);
    isDisable = controller!.methodID != "de";
    super.initState();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.teAmount.dispose();
      controller!.teDesc.dispose();
      controller!.teActualAmount.dispose();
      controller!.teNote.dispose();
      controller!.teReferenceNumber.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<UpdatePaymentManagerController>.value(
            value: controller!,
            child: Consumer<UpdatePaymentManagerController>(
                builder: (_, controller, __) {
              if (controller.isLoading) {
                return Container(
                  width: kMobileWidth,
                  height: 480,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                );
              } else {
                return SizedBox(
                  width: kMobileWidth,
                  height: 480,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //amount
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: amountController.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    isNegative: true,
                                    validator: (String? value) =>
                                        NumberValidator.validateNumber(
                                                amountController.getRawString())
                                            ? null
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .INPUT_POSITIVE_AMOUNT),
                                    readOnly: true,
                                  ),
                                ),
                                //desc
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TABLEHEADER_DESCRIPTION_FULL),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teDesc,
                                    maxLine: 3,
                                    readOnly: isDisable,
                                  ),
                                ),
                                //method
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_METHOD),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: !isDisable
                                      ? NeutronDropDownCustom(
                                          childWidget: NeutronDropDown(
                                              isPadding: false,
                                              value: PaymentMethodManager()
                                                  .getPaymentMethodNameById(
                                                      controller.methodID),
                                              onChanged:
                                                  (String newMethodName) {
                                                controller
                                                    .setMethodID(newMethodName);
                                              },
                                              items: controller.methodNames),
                                        )
                                      : NeutronTextFormField(
                                          isDecor: true,
                                          hint: PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  widget.deposit.method!),
                                          readOnly: isDisable,
                                        ),
                                ),

                                //actualAmount
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ACTUAL_AMOUNT),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: actualAmountController.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    isNegative: true,
                                    validator: (String? value) =>
                                        NumberValidator.validateNumber(
                                                actualAmountController
                                                    .getRawString())
                                            ? null
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .INPUT_POSITIVE_AMOUNT),
                                  ),
                                ),
                                //note
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.HEADER_NOTES),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teNote,
                                    maxLine: 3,
                                  ),
                                ),
                                //teReferenceNumber
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TABLEHEADER_REFERENCE_NUMBER),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teReferenceNumber,
                                  ),
                                ),
                                //referencDate
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_REFERENCE_DATE),
                                  ),
                                ),
                                SizedBox(
                                  height: 70,
                                  child: NeutronDatePicker(
                                    border: Border.all(
                                        color: ColorManagement.borderCell,
                                        width: 1),
                                    colorBackground:
                                        ColorManagement.mainBackground,
                                    initialDate: controller.referencDate,
                                    firstDate: controller.now
                                        .subtract(const Duration(days: 365)),
                                    lastDate: controller.now
                                        .add(const Duration(days: 365)),
                                    onChange: (picked) {
                                      controller.setReferencDate(picked);
                                    },
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButton(
                            icon: Icons.save,
                            onPressed: () async {
                              final result = await controller.updateDeposit();
                              if (!mounted) {
                                return;
                              }
                              if (result == MessageCodeUtil.SUCCESS) {
                                Navigator.pop(context);
                              } else {
                                MaterialUtil.showResult(context,
                                    MessageUtil.getMessageByCode(result));
                              }
                            }),
                      ),
                    ],
                  ),
                );
              }
            })));
  }
}
