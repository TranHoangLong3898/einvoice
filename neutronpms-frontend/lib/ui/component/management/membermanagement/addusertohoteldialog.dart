// ignore_for_file: use_build_context_synchronously

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

class AddUserToHotelDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  AddUserToHotelDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        color: ColorManagement.lightMainBackground,
        width: kMobileWidth,
        child: ChangeNotifierProvider<AddUserToHotelController>.value(
          value: AddUserToHotelController(),
          builder: (context, child) => Consumer<AddUserToHotelController>(
            builder: (_, controller, __) => controller.isInprogress
                ? Container(
                    height: kMobileWidth,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_ADD_MEMMBER),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                              SizeManagement.cardOutsideHorizontalPadding,
                              SizeManagement.rowSpacing,
                              SizeManagement.cardOutsideHorizontalPadding,
                              SizeManagement.bottomFormFieldSpacing,
                            ),
                            child: NeutronTextFormField(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.HINT_EMAIL),
                              isDecor: true,
                              validator: (String? email) {
                                if (email!.isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_EMAIL);
                                }
                                return StringValidator.validateRequiredEmail(
                                    email);
                              },
                              controller: controller.teEmail,
                            )),
                        NeutronButton(
                          icon: Icons.add,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            String result = await controller.addMember();
                            if (result ==
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS)) {
                              Navigator.pop(context, true);
                              MaterialUtil.showSnackBar(context, result);
                            } else {
                              MaterialUtil.showAlert(context, result);
                            }
                          },
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class AddUserToHotelController extends ChangeNotifier {
  bool isInprogress = false;

  TextEditingController teEmail = TextEditingController();

  AddUserToHotelController();

  Future<String> addMember() async {
    if (isInprogress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    isInprogress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('user-addUserToHotel')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'email': teEmail.text,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isInprogress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
