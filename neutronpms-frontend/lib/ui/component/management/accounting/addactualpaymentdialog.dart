import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/accounting/actualpayment.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../manager/usermanager.dart';
import '../../../controls/neutrondatetimepicker.dart';

class AddActualPaymentDialog extends StatelessWidget {
  final ActualPayment? actualPayment;
  final String costManagementID;
  final double? remainCost;
  const AddActualPaymentDialog(
      {Key? key,
      this.actualPayment,
      required this.costManagementID,
      this.remainCost})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        padding:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        width: kMobileWidth,
        child: ChangeNotifierProvider(
          create: (context) => AddActualPaymentController(
              actualPayment, costManagementID, remainCost),
          child: Consumer<AddActualPaymentController>(
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
                                UITitleCode.SIDEBAR_ACTUAL_EXPENSE),
                          ),
                        ),
                        // date picked for manager
                        if (UserManager.canSeeAccounting() &&
                            actualPayment == null) ...[
                          NeutronDateTimePickerBorder(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATE),
                            onPressed: (DateTime? picked) {
                              if (picked != null) {
                                controller.setCreatedDate(picked);
                              }
                            },
                            initialDate: controller.created ?? controller.now,
                            firstDate: controller.now!
                                .subtract(const Duration(days: 31)),
                            lastDate: controller.now,
                            isEditDateTime: true,
                          ),
                          const SizedBox(height: SizeManagement.rowSpacing)
                        ],

                        NeutronTextFormField(
                          isDecor: true,
                          controller: controller.teDesc,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_METHOD),
                          childWidget: NeutronDropDown(
                            isPadding: false,
                            items: controller.listMethods,
                            value: controller.method,
                            onChanged: controller.setMethod,
                          ),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        controller.teAmount.buildWidget(
                          isNegative: true,
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
                            String result = await controller.updateToCloud();
                            if (result == MessageCodeUtil.SUCCESS) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                            }
                            // ignore: use_build_context_synchronously
                            MaterialUtil.showResult(
                                context, MessageUtil.getMessageByCode(result));
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

class AddActualPaymentController extends ChangeNotifier {
  ActualPayment? oldActualPayment;
  late bool isLoading;
  late final String accountingID;
  late TextEditingController teDesc;
  late String _methodId;
  double? remainCost;
  late NeutronInputNumberController teAmount;
  DateTime? created;
  DateTime? now;

  AddActualPaymentController(
      this.oldActualPayment, this.accountingID, this.remainCost) {
    isLoading = false;
    now = DateTime.now();
    teDesc = TextEditingController(text: oldActualPayment?.desc ?? '');
    _methodId = oldActualPayment?.method ?? '';
    teAmount = NeutronInputNumberController(TextEditingController(
        text: remainCost?.toString() ??
            oldActualPayment?.amount?.toString() ??
            ''));
  }

  String get method => _methodId.isEmpty
      ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)
      : PaymentMethodManager().getPaymentMethodNameById(_methodId);

  List<String> get listMethods => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE),
        ...PaymentMethodManager().getPaymentMethodName()
      ];

  void setMethod(String newType) {
    if (method == newType) {
      return;
    }
    if (newType == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      _methodId = '';
    } else {
      _methodId = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    }
    notifyListeners();
  }

  void setCreatedDate(DateTime datePicked) {
    created = datePicked;
    notifyListeners();
  }

  Future<String> updateToCloud() async {
    if (teDesc.text.isEmpty) {
      return MessageCodeUtil.INPUT_DESCRIPTION;
    }
    if (_methodId.isEmpty) {
      return MessageCodeUtil.TEXTALERT_METHOD_CAN_NOT_BE_EMPTY;
    }
    if (num.tryParse(teAmount.getRawString()) == null) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }
    String result;
    if (oldActualPayment == null) {
      result = await createNewActualPayment();
    } else {
      result = await updateActualPayment();
    }
    return result;
  }

  Future<String> createNewActualPayment() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-createActual')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cost_management_id': accountingID,
          'method_actual_payment_id': _methodId,
          'desc_actual_payment': teDesc.text.trim(),
          'amount_actual_payment': num.parse(teAmount.getRawString()),
          'created': created != null ? created.toString() : ''
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  Future<String> updateActualPayment() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-updateActual')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cost_management_id': oldActualPayment!.accountingId,
          'actual_payment_id': oldActualPayment!.id,
          'method_actual_payment_id': _methodId,
          'desc_actual_payment': teDesc.text.trim(),
          'amount_actual_payment': num.parse(teAmount.getRawString())
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }
}
