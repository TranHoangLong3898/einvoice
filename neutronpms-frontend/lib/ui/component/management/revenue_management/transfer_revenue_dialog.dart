import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/management/revenue_management/revenue_management_dialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../manager/generalmanager.dart';
import '../../../../manager/paymentmethodmanager.dart';

class TransferRevenueDialog extends StatelessWidget {
  const TransferRevenueDialog({Key? key, required this.controllerRevenue})
      : super(key: key);
  final RevenueManagementController controllerRevenue;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        padding:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        width: kMobileWidth,
        child: ChangeNotifierProvider<TransferRevenueController>(
          create: (context) => TransferRevenueController(),
          child: Consumer<TransferRevenueController>(
            child: const SizedBox(
                height: kMobileWidth,
                child: Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                )),
            builder: (_, controller, child) {
              return controller.isLoading
                  ? child!
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TRANSFER_REVENUE),
                          ),
                        ),
                        NeutronTextFormField(
                          isDecor: true,
                          controller: controller.teDesc,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_METHOD_FROM),
                          childWidget: NeutronDropDown(
                            isPadding: false,
                            items: controller.listMethods,
                            value: controller.methodFrom,
                            onChanged: controller.setMethodFrom,
                          ),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_METHOD_TO),
                          childWidget: NeutronDropDown(
                            isPadding: false,
                            items: controller.listMethods,
                            value: controller.methodTo,
                            onChanged: controller.setMethodTo,
                          ),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        controller.teAmount.buildWidget(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                          isDouble: true,
                          isDecor: true,
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronButton(
                          margin: const EdgeInsets.all(0),
                          icon: Icons.save,
                          onPressed: () async {
                            String validateResult =
                                controller.validateDataBeforeUpdateClound(
                                    controllerRevenue.revenueDocData);
                            bool? confirm;
                            if (validateResult != MessageCodeUtil.SUCCESS &&
                                validateResult ==
                                    MessageCodeUtil
                                        .AMOUNT_TRANSFER_BIGGER_THAN_CURRENT_AMOUNT) {
                              confirm = await MaterialUtil.showConfirm(context,
                                  MessageUtil.getMessageByCode(validateResult));
                            } else if (validateResult ==
                                MessageCodeUtil.SUCCESS) {
                              confirm = true;
                            } else {
                              MaterialUtil.showResult(context,
                                  MessageUtil.getMessageByCode(validateResult));
                              return;
                            }
                            if (confirm!) {
                              String result = await controller.updateToCloud();
                              if (result == MessageCodeUtil.SUCCESS) {
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop(true);
                              } else {
                                // ignore: use_build_context_synchronously
                                MaterialUtil.showResult(context,
                                    MessageUtil.getMessageByCode(result));
                              }
                            }
                          },
                        )
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class TransferRevenueController extends ChangeNotifier {
  late bool isLoading;
  late TextEditingController teDesc;
  late String _methodIdFrom;
  late String _methodIdTo;

  late NeutronInputNumberController teAmount;
  TransferRevenueController() {
    isLoading = false;
    teDesc = TextEditingController(text: '');
    _methodIdFrom = '';
    _methodIdTo = '';
    teAmount = NeutronInputNumberController(TextEditingController(text: ''));
  }

  String get methodFrom => _methodIdFrom.isEmpty
      ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)
      : PaymentMethodManager().getPaymentMethodNameById(_methodIdFrom);
  String get methodTo => _methodIdTo.isEmpty
      ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)
      : PaymentMethodManager().getPaymentMethodNameById(_methodIdTo);

  List<String> get listMethods => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE),
        ...PaymentMethodManager().getPaymentMethodName()
      ];

  void setMethodFrom(String newType) {
    if (newType == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      return;
    }

    if (_methodIdFrom.isEmpty) {
      if (_methodIdTo.isNotEmpty && methodTo == newType) {
        return;
      }
      _methodIdFrom = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    } else {
      if (methodFrom == newType || newType == methodTo) {
        return;
      }
      _methodIdFrom = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    }
    notifyListeners();
  }

  void setMethodTo(String newType) {
    if (newType == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      return;
    }
    if (_methodIdTo.isEmpty) {
      if (_methodIdFrom.isNotEmpty && methodFrom == newType) {
        return;
      }
      _methodIdTo = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    } else {
      if (methodTo == newType || newType == methodFrom) {
        return;
      }
      _methodIdTo = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    }
    notifyListeners();
  }

  String validateDataBeforeUpdateClound(Map<String, num> revenueDoc) {
    if (_methodIdFrom.isEmpty || _methodIdTo.isEmpty) {
      return MessageCodeUtil.TEXTALERT_METHOD_CAN_NOT_BE_EMPTY;
    }
    if (num.tryParse(teAmount.getRawString()) == null) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }
    if (num.tryParse(teAmount.getRawString())! > revenueDoc[_methodIdFrom]! &&
        revenueDoc.isEmpty) {
      return MessageCodeUtil.AMOUNT_TRANSFER_BIGGER_THAN_CURRENT_AMOUNT;
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> updateToCloud() async {
    if (_methodIdFrom.isEmpty || _methodIdTo.isEmpty) {
      return MessageCodeUtil.TEXTALERT_METHOD_CAN_NOT_BE_EMPTY;
    }
    if (num.tryParse(teAmount.getRawString()) == null) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }

    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('revenue-createTransferRevenue')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'method_id_from': _methodIdFrom,
          'method_id_to': _methodIdTo,
          'desc': teDesc.text.trim(),
          'amount': num.parse(teAmount.getRawString())
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }
}
