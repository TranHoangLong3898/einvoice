import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../validator/stringvalidator.dart';

class LoginController extends ChangeNotifier {
  bool? isRememberMe;
  bool isShowPassword = false;
  TextEditingController? emailController;
  TextEditingController? passwordController;

  LoginController() {
    emailController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');
    isRememberMe = true;
  }

  void setRememberMe(bool value) {
    isRememberMe = value;
    notifyListeners();
  }

  void toggleShowPasswordStatus() {
    if (passwordController!.text.isEmpty) {
      isShowPassword = false;
    } else {
      isShowPassword = !isShowPassword;
    }
    notifyListeners();
  }

  Future<String> login() async {
    String? validdateEmail =
        StringValidator.validateRequiredEmail(emailController!.text);
    if (validdateEmail != null) {
      return validdateEmail;
    }

    String? validdatePassword =
        StringValidator.validatePassword(passwordController!.text);
    if (validdatePassword != null) {
      return validdatePassword;
    }

    try {
      if (kIsWeb) {
        Persistence persistence =
            isRememberMe! ? Persistence.LOCAL : Persistence.SESSION;
        await FirebaseAuth.instance.setPersistence(persistence).onError(
            (error, stackTrace) =>
                print('setPersistence Error: ${error.toString()}'));
      }
      String result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController!.text, password: passwordController!.text)
          .then((value) => MessageCodeUtil.SUCCESS)
          .onError((error, stackTrace) {
        print('loginError: $error');
        return (error as FirebaseAuthException).code;
      });
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR);
    }
  }
}
