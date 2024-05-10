import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/tax.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:provider/provider.dart';

class TaxDialog extends StatefulWidget {
  const TaxDialog({Key? key}) : super(key: key);

  @override
  State<TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends State<TaxDialog> {
  final formKey = GlobalKey<FormState>();

  final TaxControler controller = TaxControler();
  late NeutronInputNumberController vatController;
  late NeutronInputNumberController serviceFeeController;

  @override
  void initState() {
    vatController = NeutronInputNumberController(controller.teVat);
    serviceFeeController =
        NeutronInputNumberController(controller.teServiceFee);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: ChangeNotifierProvider<TaxControler>.value(
          value: controller,
          child: Consumer<TaxControler>(
            builder: (_, controller, __) => controller.isInProgress
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    ))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.topHeaderTextSpacing),
                        child: NeutronTextHeader(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.SIDEBAR_TAX),
                        ),
                      ),
                      //input
                      Flexible(
                        fit: FlexFit.loose,
                        child: Form(
                          key: formKey,
                          child: Row(
                            children: [
                              //service fee
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                          .cardOutsideHorizontalPadding /
                                      2,
                                ),
                                child: serviceFeeController.buildWidget(
                                  suffixText: '%',
                                  isDecor: true,
                                  isDouble: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SERVICE_FEE),
                                  validator: (String? serviceFee) {
                                    if (serviceFee == null ||
                                        serviceFee.trim().isEmpty) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil.INPUT_SERVICE_FEE);
                                    }
                                    num? serviceFeeNumber = num.tryParse(
                                        serviceFeeController.getRawString());
                                    if (serviceFeeNumber == null ||
                                        serviceFeeNumber < 0) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .INPUT_POSITIVE_NUMBER);
                                    }
                                    return null;
                                  },
                                ),
                              )),
                              //vat
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  left: SizeManagement
                                          .cardOutsideHorizontalPadding /
                                      2,
                                ),
                                child: vatController.buildWidget(
                                  suffixText: '%',
                                  isDecor: true,
                                  isDouble: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TAX),
                                  validator: (String? vat) {
                                    if (vat == null || vat.trim().isEmpty) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil.INPUT_VAT);
                                    }
                                    num? vatNumber = num.tryParse(
                                        vatController.getRawString());
                                    if (vatNumber == null || vatNumber < 0) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .INPUT_POSITIVE_NUMBER);
                                    }
                                    return null;
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: SizeManagement.bottomFormFieldSpacing),
                      //button
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            String result = await controller.updateTax();
                            if (mounted) {
                              MaterialUtil.showResult(context, result);
                            }
                          }
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class TaxControler extends ChangeNotifier {
  bool isInProgress = false;
  late TextEditingController teServiceFee;
  late TextEditingController teVat;
  late Tax tax;
  TaxControler() {
    tax = ConfigurationManagement().tax;
    teServiceFee =
        TextEditingController(text: (tax.serviceFee! * 100).toString());
    teVat = TextEditingController(text: (tax.vat! * 100).toString());
  }

  Future<String> updateTax() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    if (teServiceFee.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_SERVICE_FEE);
    }
    if (teVat.text.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_VAT);
    }
    if (!NumberValidator.validatePercentageNumber(
        teServiceFee.text.replaceAll(',', ''))) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_RANGE_SERVICE_FEE_PERCENTAGE);
    }
    if (!NumberValidator.validatePercentageNumber(
        teVat.text.replaceAll(',', ''))) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_RANGE_VAT_PERCENTAGE);
    }
    num? vat = num.tryParse(teVat.text.replaceAll(',', ''));
    num? serviceFee = num.tryParse(teServiceFee.text.replaceAll(',', ''));
    if (vat == null || serviceFee == null) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INPUT_NON_NEGATIVE_NUMBER);
    }
    if (vat == tax.vat && serviceFee == tax.serviceFee) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    isInProgress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateTax')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'service_fee': serviceFee / 100,
          'vat': vat / 100
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);

    isInProgress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
