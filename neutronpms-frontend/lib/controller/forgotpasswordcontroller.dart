import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../util/messageulti.dart';
import '../../validator/stringvalidator.dart';

class ForgotPasswordController extends ChangeNotifier {
  bool isLoading = false;
  late TextEditingController forgotEmailController;

  ForgotPasswordController() {
    forgotEmailController = TextEditingController(text: '');
  }

  Future<String> forgetPassword() async {
    String? validEmail =
        StringValidator.validateRequiredEmail(forgotEmailController.text);
    if (validEmail != null) {
      return validEmail;
    }
    isLoading = true;
    notifyListeners();
    String result = await FirebaseAuth.instance
        .sendPasswordResetEmail(email: forgotEmailController.text)
        .then((value) => MessageCodeUtil.SUCCESS)
        .onError((error, stackTrace) =>
            MessageUtil.getMessageByCode(error.toString()));
    isLoading = false;
    notifyListeners();
    return result;
  }
}
