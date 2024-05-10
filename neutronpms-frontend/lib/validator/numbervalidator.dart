// ignore_for_file: prefer_function_declarations_over_variables

import 'package:ihotel/util/messageulti.dart';

class NumberValidator {
  static final Function validatePositiveNumber = (value) {
    final number = num.tryParse(value);
    if (number == null || number <= 0) {
      return false;
    }
    return true;
  };

  static final Function validateNumber = (value) {
    final number = num.tryParse(value);
    return number == null ? false : true;
  };
  static String? validatePositiveNumberSmallerThan100(value) {
    final number = num.tryParse(value);
    if (number == null) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NUM_GUEST);
    }
    if (number < 0 || number > 100) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_RANGE_GUEST_NUMBER);
    }
    return null;
  }

  static bool validateNonNegativeNumber(String value) =>
      double.tryParse(value) != null && double.tryParse(value)! >= 0;

  static bool validatePercentageNumber(String value) {
    if (int.tryParse(value)! < 0 || int.tryParse(value)! > 100) {
      return false;
    }
    return true;
  }
}
