import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/materialutil.dart';
import '../../../controls/neutronblurbutton.dart';

class AsyncDailyDataController extends ChangeNotifier {
  bool isLoading = false;
  late TextEditingController teNameHotel;

  AsyncDailyDataController() {
    teNameHotel = TextEditingController(text: '');
  }
  Future<String> asyncPayment() async {
    isLoading = true;
    notifyListeners();
    final callable =
        FirebaseFunctions.instance.httpsCallable('dailytask-asyncDailyData');
    try {
      await callable({
        'name_hotel': teNameHotel.text,
      });
      isLoading = false;
      notifyListeners();
      return '';
    } on FirebaseFunctionsException catch (error) {
      print(error);
      isLoading = false;
      notifyListeners();
      return 'Fail Async';
    }
  }
}

class AsyncDailyDataDialog extends StatelessWidget {
  const AsyncDailyDataDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: ChangeNotifierProvider<AsyncDailyDataController>.value(
            value: AsyncDailyDataController(),
            child: Consumer<AsyncDailyDataController>(
                builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: ColorManagement.greenColor,
                ));
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Async Daily Data Type'),
                  Row(
                    children: [
                      const SizedBox(
                        width: SizeManagement.rowSpacing,
                      ),
                      const Expanded(
                        child: NeutronTextContent(message: 'Name Hotel'),
                      ),
                      const SizedBox(
                        width: SizeManagement.rowSpacing,
                      ),
                      Expanded(
                        flex: 2,
                        child: NeutronTextFormField(
                          isDecor: true,
                          backgroundColor: ColorManagement.mainBackground,
                          controller: controller.teNameHotel,
                        ),
                      ),
                      const SizedBox(
                        width: SizeManagement.rowSpacing,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: SizeManagement.rowSpacing,
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
