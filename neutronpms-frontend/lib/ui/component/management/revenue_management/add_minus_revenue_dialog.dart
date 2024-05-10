import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
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

class AddRevenueDialog extends StatelessWidget {
  const AddRevenueDialog(
      {Key? key, required this.methodID, required this.isAdd})
      : super(key: key);
  final bool isAdd;
  final String methodID;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        padding:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        width: kMobileWidth,
        child: ChangeNotifierProvider(
          create: (context) =>
              AddRevenueController(methodID: methodID, isAdd: isAdd),
          child: Consumer<AddRevenueController>(
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
                            message: UITitleUtil.getTitleByCode(isAdd
                                ? UITitleCode.TABLEHEADER_ADD_REVENUE
                                : UITitleCode.TABLEHEADER_MINUS_REVENUE),
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

class AddRevenueController extends ChangeNotifier {
  late bool isLoading;
  late TextEditingController teDesc;
  late String _methodId;
  late bool _isAdd;
  late NeutronInputNumberController teAmount;
  AddRevenueController({required methodID, required isAdd}) {
    isLoading = false;
    teDesc = TextEditingController(text: '');
    _methodId = methodID;
    _isAdd = isAdd;
    teAmount = NeutronInputNumberController(TextEditingController(text: ''));
  }

  String get method =>
      PaymentMethodManager().getPaymentMethodNameById(_methodId);
  List<String> get listMethods =>
      [...PaymentMethodManager().getPaymentMethodName()];

  void setMethod(String newType) {
    if (method == newType) {
      return;
    }
    _methodId = PaymentMethodManager().getPaymentMethodIdByName(newType)!;
    notifyListeners();
  }

  Future<String> updateToCloud() async {
    if (_methodId.isEmpty) {
      return MessageCodeUtil.TEXTALERT_METHOD_CAN_NOT_BE_EMPTY;
    }
    if (num.tryParse(teAmount.getRawString()) == null) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }

    isLoading = true;
    notifyListeners();

    return await FirebaseFunctions.instance
        .httpsCallable('revenue-createRevenue')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'method_id': _methodId,
          'is_add': _isAdd,
          'desc': teDesc.text.trim(),
          'amount': num.parse(teAmount.getRawString())
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
}
