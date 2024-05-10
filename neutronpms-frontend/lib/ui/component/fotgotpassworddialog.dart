// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:provider/provider.dart';
import '../../controller/forgotpasswordcontroller.dart';
import '../../enum.dart';
import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';
import '../controls/neutronbutton.dart';
import '../controls/neutrontextformfield.dart';
import '../controls/neutrontexttilte.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: kMobileWidth,
          child: ChangeNotifierProvider(
            create: (context) => ForgotPasswordController(),
            child: Consumer<ForgotPasswordController>(
              child: Container(
                alignment: Alignment.center,
                height: 150,
                child: const CircularProgressIndicator(
                    color: ColorManagement.greenColor),
              ),
              builder: (_, controller, child) {
                if (controller.isLoading) {
                  return child!;
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 25),
                    //tiêu đề
                    NeutronTextTitle(
                      message: UITitleUtil.getTitleByCode(UITitleCode
                          .TABLEHEADER_ENTER_EMAIL_TO_RETRIEVE_PASSWORD),
                    ),
                    //nhập email
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 25, bottom: 15),
                      child: NeutronTextFormField(
                        hint:
                            UITitleUtil.getTitleByCode(UITitleCode.HINT_EMAIL),
                        isDecor: true,
                        controller: controller.forgotEmailController,
                        onSubmitted: (String value) =>
                            getPassword(context, controller),
                      ),
                    ),
                    //button gửi
                    NeutronButton(
                      icon: Icons.email,
                      onPressed: () => getPassword(context, controller),
                    )
                  ],
                );
              },
            ),
          )),
    );
  }

  void getPassword(
      BuildContext context, ForgotPasswordController controller) async {
    String result = await controller.forgetPassword();
    if (result == MessageCodeUtil.SUCCESS) {
      Navigator.pop(context);
      GeneralManager.openSupportGroup(SupportGroupType.gmail);
      MaterialUtil.showAlert(
          context,
          MessageUtil.getMessageByCode(MessageCodeUtil
              .TEXTALERT_WE_HAVE_SENT_A_PASSWORD_RESET_LINK_TO_YOUR_EMAIL));
      return;
    }
    MaterialUtil.showAlert(context, result);
  }
}
