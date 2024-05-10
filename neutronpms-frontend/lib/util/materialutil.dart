// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../ui/controls/neutrondialogs.dart';

class MaterialUtil {
  static final Function showSnackBar = (BuildContext context, String text) =>
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(text)));

  static final Function showAlert = (BuildContext context, String text) =>
      showDialog(
          context: context,
          builder: (context) => NeutronAlertDialog(messages: [text]));
  static final Function showAlerts =
      (BuildContext context, List<String> text) => showDialog(
          context: context,
          builder: (context) => NeutronAlertDialog(messages: text));

  static Future<bool?> showConfirm(BuildContext context, String text,
      [String? yesButtonText,
      String? noButtonText,
      bool? barrierDismissible]) async {
    return await showDialog<bool>(
        barrierDismissible: barrierDismissible ?? true,
        context: context,
        builder: (context) => NeutronConfirmDialog(
              nolButtonText: noButtonText,
              yesButtonText: yesButtonText,
              messages: [text],
            ));
  }

  static showResult(BuildContext context, String message) {
    message == MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)
        ? showSnackBar(context, message)
        : showAlert(context, message);
  }
}
