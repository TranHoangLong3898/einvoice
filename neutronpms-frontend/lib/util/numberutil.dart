import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NumberUtil {
  static const String _chars = '1234567890';

  static final moneyFormat = NumberFormat.compact();

  static final numberFormat = NumberFormat.decimalPattern();

  static final percentageFormat = NumberFormat.decimalPercentPattern();

  static String getRandomID() =>
      "${Timestamp.now().millisecondsSinceEpoch}${Random().nextInt(1000)}";

  static String getSidByConvertToBase62() {
    final List<String> base62Chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
            .split('');
    List<String> result = [];
    int decimalNumber = int.parse(getRandomID());
    while (decimalNumber > 0) {
      int remainder = decimalNumber % 62;
      result.insert(0, base62Chars[remainder]);
      decimalNumber ~/= 62;
    }
    return result.join('');
  }

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(Random().nextInt(10))));

  // static String getSidByAutoHotelName() {
  //   final List<String> base62Chars = GeneralManager.hotel!.name!.split(' ');
  //   String result = '';
  //   for (String word in base62Chars) {
  //     if (word.isNotEmpty) {
  //       result += word[0];
  //     }
  //   }
  //   int number = int.parse("000020");
  //   number++;
  //   String resultString = number.toString();
  //   resultString = resultString.padLeft("000020".length, '0');
  //   result = "$result$resultString";
  //   print(result);
  //   return result;
  // }
}
