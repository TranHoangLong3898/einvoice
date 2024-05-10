import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/addrateplancontroller.dart';
import 'package:ihotel/modal/rateplan.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutronswitch.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../controls/neutrontexttilte.dart';

class AddRatePlanDialog extends StatefulWidget {
  final RatePlan? ratePlan;

  const AddRatePlanDialog({Key? key, this.ratePlan}) : super(key: key);

  @override
  State<AddRatePlanDialog> createState() => _AddRatePlanDialogState();
}

class _AddRatePlanDialogState extends State<AddRatePlanDialog> {
  final formKey = GlobalKey<FormState>();
  late AddRatePlanController addRatePlanController;
  late NeutronInputNumberController amountController;

  @override
  void initState() {
    addRatePlanController = AddRatePlanController(widget.ratePlan);
    amountController =
        NeutronInputNumberController(addRatePlanController.teAmount);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            width: kMobileWidth,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: ChangeNotifierProvider<AddRatePlanController>.value(
                  value: addRatePlanController,
                  child: Consumer<AddRatePlanController>(
                    builder: (_, controller, __) {
                      if (controller.isLoading) {
                        return Container(
                            alignment: Alignment.center,
                            height: kMobileWidth,
                            child: const CircularProgressIndicator(
                              color: ColorManagement.greenColor,
                            ));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title rate plan
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                vertical: SizeManagement.topHeaderTextSpacing),
                            child: NeutronTextHeader(
                              message: controller.isAddFeature
                                  ? UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_CREATE_RATE_PLAN)
                                  : UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_UPDATE_RATE_PLAN),
                            ),
                          ),
                          //id
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isRequired: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_RATE_PLAN),
                              isPadding: false,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground),
                            margin: const EdgeInsets.only(
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                right:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                bottom: SizeManagement.bottomFormFieldSpacing),
                            child: NeutronTextFormField(
                              isDecor: true,
                              readOnly: widget.ratePlan != null,
                              controller: controller.title,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_ID);
                                }
                                if (value.trim().isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.ID_CAN_NOT_BE_BLANK);
                                }
                                if (value.length > 64) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil
                                          .OVER_ID_RATE_LAN_MAX_LENGTH);
                                }
                                if (!RegExp(r'^[a-zA-Z0-9\_\s]*$')
                                    .hasMatch(value)) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil
                                          .ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
                                }
                                return null;
                              },
                            ),
                          ),
                          //amount + %
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          top: SizeManagement.rowSpacing,
                                          bottom: SizeManagement.rowSpacing,
                                        ),
                                        child: NeutronTextTitle(
                                          isRequired: true,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_AMOUNT),
                                          isPadding: false,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                SizeManagement.borderRadius8),
                                            color: ColorManagement
                                                .lightMainBackground),
                                        margin: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing),
                                        child: amountController.buildWidget(
                                          isNegative: true,
                                          isDouble: true,
                                          isDecor: true,
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return MessageUtil
                                                  .getMessageByCode(
                                                      MessageCodeUtil
                                                          .INPUT_AMOUNT);
                                            }
                                            if (!NumberValidator.validateNumber(
                                                amountController
                                                    .getRawString())) {
                                              MessageUtil.getMessageByCode(
                                                  MessageCodeUtil.INPUT_NUMBER);
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing,
                                      bottom: SizeManagement.rowSpacing,
                                    ),
                                    child: NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PERCENT),
                                      isPadding: false,
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
                                      child: NeutronSwitch(
                                        value: controller.isPercent,
                                        onChange: (bool isPercent) {
                                          controller.setPercent(isPercent);
                                        },
                                      )),
                                ],
                              ))
                            ],
                          ),
                          // Name roomType
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                vertical: SizeManagement.rowSpacing),
                            child: NeutronTextTitle(
                              isRequired: true,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                              isPadding: false,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground),
                            margin: const EdgeInsets.only(
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                right:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                bottom: SizeManagement.bottomFormFieldSpacing),
                            child: NeutronTextFormField(
                              isDecor: true,
                              controller: controller.teDecs,
                              maxLine: 3,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_DESCRIPTION);
                                }
                                return null;
                              },
                            ),
                          ),
                          NeutronButton(
                            icon: Icons.save,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final result = await controller.addRatePlan();
                                if (!mounted) {
                                  return;
                                }
                                if (result == '') {
                                  Navigator.pop(context, result);
                                } else {
                                  MaterialUtil.showAlert(context, result);
                                }
                              }
                            },
                          )
                          // Neutron Switch Percent
                        ],
                      );
                    },
                  ),
                ),
              ),
            )));
  }
}
