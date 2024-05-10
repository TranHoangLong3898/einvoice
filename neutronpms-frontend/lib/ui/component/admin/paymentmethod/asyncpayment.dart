import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../manager/generalmanager.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/materialutil.dart';
import '../../../controls/neutronblurbutton.dart';
import '../../../controls/neutrondatepicker.dart';

class AsyncPaymentController extends ChangeNotifier {
  bool isLoading = false;
  DateTime startDate = DateUtil.to12h(DateTime.now());
  DateTime endDate = DateUtil.to12h(DateTime.now());
  void setStartDate(DateTime newDate) {
    if (DateUtil.equal(newDate, startDate)) return;
    newDate = DateUtil.to12h(newDate);
    startDate = newDate;
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    if (DateUtil.equal(newDate, endDate)) return;
    newDate = DateUtil.to12h(newDate);
    endDate = newDate;
    notifyListeners();
  }

  Future<String> asyncPayment() async {
    isLoading = true;
    notifyListeners();
    final callable =
        FirebaseFunctions.instance.httpsCallable('deposit-asyncPayment');
    try {
      final result = await callable({
        'hotel_id': GeneralManager.hotelID,
        'start_date': startDate.toString(),
        'end_date': endDate.toString(),
      });
      print(result.data);
      isLoading = false;
      notifyListeners();
      return '';
    } on FirebaseFunctionsException {
      isLoading = false;
      notifyListeners();
      return 'Fail Async';
    }
  }
}

class AsyncPaymentDialog extends StatelessWidget {
  const AsyncPaymentDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now().toDate();
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: ChangeNotifierProvider<AsyncPaymentController>.value(
            value: AsyncPaymentController(),
            child:
                Consumer<AsyncPaymentController>(builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: ColorManagement.greenColor,
                ));
              }
              return Column(
                children: [
                  const Text('Async Payment Flow In Date'),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Start Date'),
                      ),
                      Expanded(
                        child: NeutronDatePicker(
                          initialDate: controller.startDate,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 365)),
                          onChange: (picked) {
                            controller.setStartDate(picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('End Date'),
                      ),
                      Expanded(
                        child: NeutronDatePicker(
                          initialDate: controller.endDate,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 365)),
                          onChange: (picked) {
                            controller.setEndDate(picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  NeutronBlurButton(
                      icon: Icons.save,
                      onPressed: () async {
                        final result = await controller.asyncPayment();
                        if (result == '') {
                          // ignore: use_build_context_synchronously
                          MaterialUtil.showSnackBar(context, result);
                        } else {
                          // ignore: use_build_context_synchronously
                          MaterialUtil.showAlert(context, result);
                        }
                      }),
                ],
              );
            }),
          )),
    );
  }
}
