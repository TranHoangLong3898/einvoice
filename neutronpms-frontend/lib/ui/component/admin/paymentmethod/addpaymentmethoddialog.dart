import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/payment.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

class AddPaymentMethodDialog extends StatefulWidget {
  final Payment? payment;
  const AddPaymentMethodDialog({Key? key, this.payment}) : super(key: key);

  @override
  State<AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<AddPaymentMethodDialog> {
  final formKey = GlobalKey<FormState>();
  PaymentMethodManager? paymentMethodManager;

  @override
  void initState() {
    paymentMethodManager ??= PaymentMethodManager.addPayment(widget.payment);
    super.initState();
  }

  @override
  void dispose() {
    PaymentMethodManager().payment = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            width: kMobileWidth,
            height: 500,
            child: Form(
              key: formKey,
              child: ChangeNotifierProvider<PaymentMethodManager>.value(
                value: paymentMethodManager!,
                child: Consumer<PaymentMethodManager?>(
                  builder: (_, controller, __) {
                    if (controller!.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ));
                    }
                    return Stack(children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 65),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //header
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.symmetric(
                                    vertical:
                                        SizeManagement.topHeaderTextSpacing),
                                child: NeutronTextHeader(
                                  message: controller.payment == null
                                      ? UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_CREATE_PAYMENT)
                                      : UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_UPDATE_PAYMENT),
                                ),
                              ),
                              // Id Roomtype
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ID),
                                  isPadding: false,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                margin: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  readOnly: widget.payment != null,
                                  isDecor: true,
                                  controller: controller.teId,
                                  validator: (String? value) {
                                    // return StringValidator.validateRequiredId(
                                    //     value);
                                    if (value == null || value.isEmpty) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil.INPUT_ID);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              // Name payment
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NAME),
                                  isPadding: false,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                margin: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  isDecor: true,
                                  controller: controller.teName,
                                  validator: (value) {
                                    return StringValidator.validateRequiredName(
                                        value);
                                  },
                                ),
                              ),
                              // Status 6 field
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_STATUS_ONE_VALUE_ONE_FIELD),
                                  isPadding: false,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[0],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .CAN_NOT_BE_EMPTY);
                                          }

                                          return StringValidator
                                              .validateRequiredStatus(value);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[1],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .CAN_NOT_BE_EMPTY);
                                          }
                                          return StringValidator
                                              .validateRequiredStatus(value);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[2],
                                        validator: (value) {
                                          return StringValidator
                                              .validateRequiredStatus(value!);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[3],
                                        validator: (value) {
                                          return StringValidator
                                              .validateRequiredStatus(value!);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[4],
                                        validator: (value) {
                                          return StringValidator
                                              .validateRequiredStatus(value!);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        readOnly: true,
                                        controller: controller.teStatus[5],
                                        validator: (value) {
                                          return StringValidator
                                              .validateRequiredStatus(value!);
                                        },
                                        hint: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_STATUS),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final result = await controller.addPayment();
                              if (!mounted) {
                                return;
                              }
                              if (result == MessageCodeUtil.SUCCESS) {
                                Navigator.pop(context);
                              } else {
                                MaterialUtil.showAlert(context, result);
                              }
                            }
                          },
                        ),
                      )
                    ]);
                  },
                ),
              ),
            )));
  }
}
