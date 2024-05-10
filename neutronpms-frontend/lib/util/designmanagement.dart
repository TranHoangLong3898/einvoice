import 'package:flutter/material.dart';

class ColorManagement {
  ColorManagement._();

  //for dashboard

  static const bedSmallCircleBackGround = Color(0xff457b9d);

  static const greyColor = Color(0xffe0e0e0);
  static const yellowColor = Color(0xfff7fa37); //dark: 0xfffecf5b
  static const darkYellowColor = Color(0xfffecf5b);
  static const blueColor = Color(0xff5bc2ea);
  static const greenColor = Color(0xff59b69e);
  static const orangeColor = Color(0xfffda365);
  static const redColor = Color(0xffea6768);
  static const grayColor = Color(0xff484951);
  static const deepBlueColor = Color(0xff5d39fd);
  static const nowDateColor = Color(0xff51627d);

  static const bedNameOfBookedBooking = Color(0xff5bc2ea);
  static const bedNameOfCheckinBooking = Color.fromARGB(255, 230, 82, 90);

  static const bookingNameOfBookedBooking = Color(0xff5bc2ea);
  static const bookingNameOfCheckinBooking = Color.fromARGB(255, 255, 255, 255);
  static const bookingNameOfCheckoutBooking = Color(0xffffffff);
  static const bookingNameOfRepairedBooking = Colors.white;
  static const bookingNameOfMovedBooking = Colors.black45;

  static const bookedBooking = Color(0xffade0f4);
  static const checkinBooking = Color.fromARGB(255, 248, 132, 138);
  static const checkoutBooking = Color.fromARGB(255, 180, 191, 209);
  static const bookingUnconfirmed = Color.fromARGB(255, 209, 193, 52);
  static const repairedBooking = Colors.black;
  static const movedBooking = Colors.black12;

  static const white = Color(0xFFFFFFFF);
  static const textBlack = Color(0xFF000000);

  static const cleanRoomCellBackground = Color(0xff59b59e);
  static const vacantOvernightRoomCellBackground = Color(0xfffecf5b);
  static const roomLeftCellBackground = Color(0xff59b59e);
  static const dateCellBackground = Color(0xFFFFFFFF);
  static const emptyCellBackground = Color(0xFFFFFFFF);

  static const borderCell = Colors.black26;

  static final transparentBackground = Colors.white.withOpacity(0.2);

  static const mainBackground = Color(0xff303136);
  static const lightMainBackground = Color(0xff363940);

  static const negativeText = Color(0xffea6269);
  static const positiveText = Color(0xff72c0ad);

  static const iconMenuEnableColor = Color(0xffffffff);
  static const iconMenuDisableColor = Color(0xffbdbdbd);

  static const mainColorText = Color(0xfffafdff);
  static const lightColorText = Color(0xffd3d8dc);
  static const notesColorText = Color(0xff90a7b3);
  static const trailingIconColor = Color(0xffAAB7B8);
  static const taxDeclareSignal = Color.fromARGB(255, 26, 26, 26);

  static const oddColor = Color.fromARGB(255, 127, 127, 127);
  static const evenColor = lightMainBackground;

  //gradient
  static LinearGradient barsGradient = const LinearGradient(
      colors: [Colors.lightBlueAccent, Colors.greenAccent],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter);

  static LinearGradient barsGradientForToday = const LinearGradient(colors: [
    Color(0xffffa751),
    Color(0xffffe259),
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

  static LinearGradient hoveredBarsGradient = const LinearGradient(
      colors: [Colors.yellow, Colors.yellow],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter);

  static List<Color> colorsPalete = [
    const Color(0xff05a8aa),
    const Color(0xffB8D5B8),
    const Color(0xffD7B49E),
    const Color(0xffDC602E),
    const Color(0xffBC412B),
    const Color(0xff101D42),
    const Color(0xff89D2DC),
    const Color(0xffAB9B96),
    const Color(0xffA1674A),
    const Color(0xff564154),
    const Color(0xff6564DB),
    const Color(0xffffe259),
    const Color(0xffffa751),
  ];

  //color code for static
  static const statisticOrangeColor = Color(0xffe76f51);
  static const statisticDeepBlueColor = Color(0xff5d39fd);
  static const statisticGreenColor = Color(0xff8bcfba);
  static const dashboardComponent = Color(0xffe9ecef);
}

class SizeManagement {
  SizeManagement._();

  static const double smallCircle = 19;
  static const double avatarCircle = 70;
  static const double borderRadius8 = 8;
  static const double cardOutsideHorizontalPadding = 8;
  static const double cardInsideHorizontalPadding = 8;
  static const double cardOutsideVerticalPadding = 8;
  static const double cardHeight = 50;
  static const double rowSpacing = 10;
  static const double bottomFormFieldSpacing = 15;
  static const double dropdownLeftPadding = 10;
  static const double topHeaderTextSpacing = 25;
  static const double marginDailyAllotment = 5;
  static const double widthOfAccountingFromActualPayment = 150;
  static const double marginBottomForStack = 65;
  static const double cardInsideVerticalPadding = 8;
  static const double columnSpacing = 10;
  static const double neutronComponentHeight = 45;
}

class FontManagement {
  FontManagement._();

  static const String fontFamily = 'OpenSans';
}

class StyleManagement {
  StyleManagement._();

  static const content = TextStyle(
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: ColorManagement.lightColorText);

  static const greenColorContent = TextStyle(
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: ColorManagement.positiveText);

  static const title = TextStyle(
      fontSize: 15,
      color: ColorManagement.mainColorText,
      fontWeight: FontWeight.normal);

  static header({Color? color}) => TextStyle(
        color: color ?? Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.normal,
      );
}
