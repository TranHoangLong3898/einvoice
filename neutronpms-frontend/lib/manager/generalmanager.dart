import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../enum.dart';
import '../handler/firebasehandler.dart';
import '../modal/hotel.dart';
import '../modal/partnerhotel.dart';
import '../modal/status.dart';
import 'usermanager.dart';

class GeneralManager extends ChangeNotifier {
  static final GeneralManager _instance = GeneralManager._singleton();
  GeneralManager._singleton();

  factory GeneralManager() {
    return _instance;
  }

  static String version = '1.2.4';

  static double cellWidth = 180;
  static double cellHeight = 40;
  static double roomTypeCellHeight = cellHeight + 15;
  static double roomleftCellHeight = 18;
  static double roomleftCellWidth = 30;
  static int numDates = 7;
  static int maxLengthStay = 31;
  static int maxLengthStayOta = 365;
  static int sizeDatesForBoard = 7;
  static double cornerRadius = 26;
  static double bookingCellHeight = cellHeight - 6;
  static double bedCellWidth = 15;
  static double dateCellHeight = 88;
  static double taxDeclareSignWidth = 3;
  static double iconMenuSize = 24;
  static DateTime now = DateTime.now();
  static Map<String, dynamic> dataPackage = {};

  static Hotel? hotel;
  static String? hotelID;
  static Uint8List? hotelImage;
  static Uint8List? onepmsLogo;
  static Uint8List? policyHotel;
  static bool showAllotment = true;
  static List<PartnerHotel> listPartnerhotel = [
    PartnerHotel(
        name: 'One PMS',
        logobackground: 'assets/img/logo.png',
        linksSupport: [
          'http://www.facebook.com/groups/onepms.net',
          'https://t.me/onepms_cs',
          'https://zalo.me/g/zaksma521',
          'https://www.youtube.com/channel/UCqAC06VFR8rEaQGqMkpo2HA',
          'https://mail.google.com/mail/u/0/#spam',
        ]),
    PartnerHotel(
      name: 'DS COMPANY',
      logobackground: 'assets/img/logo-dscomnany.png',
      linksSupport: ["", "", "", "", ""],
    ),
    PartnerHotel(
      name: 'DV GROUP',
      logobackground: 'assets/img/logo-dvgroup.png',
      linksSupport: ["", "", "", "", ""],
    ),
  ];

  static PartnerHotel partnerHotel = listPartnerhotel[0];

  static Locale? locale;

  static bool isFilterTaxDeclare = false;

  void setLocale(String localeCode) async {
    if (localeCode == locale?.toLanguageTag()) return;
    final SharedPreferences shareRef = await SharedPreferences.getInstance();
    shareRef.setString('language', localeCode);
    locale = Locale(localeCode);
    notifyListeners();
  }

  Future<void> loadLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String localeCode = prefs.getString('language') ?? 'en';
    cellHeight = prefs.getDouble('cellHeight') ?? 40;
    locale = Locale(localeCode);
  }

  void saveFilterTaxDeclareToLocal() async {
    final SharedPreferences shareRef = await SharedPreferences.getInstance();
    shareRef.setBool('filterTax', isFilterTaxDeclare);
  }

  Future<void> getFilterTaxDeclare() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFilted = prefs.getBool('filterTax') ?? false;
    isFilterTaxDeclare = isFilted;
  }

  static void outStatusPage() {
    SystemManagement().cancelStream();
    hotel = null;
    hotelID = null;
    hotelImage = null;
    // FirebaseHandler.hotelRef = null;
  }

  static Future<void> signOut(BuildContext context) async {
    outStatusPage();
    UserManager.reset();
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, 'landing', (_) => false);
  }

  static void updateHotel(String newHotelID) async {
    hotelID = newHotelID;
    FirebaseHandler.updateHotel();
    hotel = await FirebaseHandler().getCurrentHotel();
  }

  void rebuild() {
    notifyListeners();
  }

  void unfocus(BuildContext context) {
    FocusScope.of(context).focusedChild?.unfocus();
    // if (kIsWeb &&
    //     (defaultTargetPlatform == TargetPlatform.iOS ||
    //         defaultTargetPlatform == TargetPlatform.android)) {
    //   FocusScope.of(context).requestFocus(FocusNode());
    // } else {
    //   FocusScope.of(context).unfocus();
    // }
  }

  bool get canReadActivity => hotel!.package != HotelPackage.BASIC;

  static void openSupportGroup(SupportGroupType value) {
    switch (value) {
      case SupportGroupType.facebook:
        launchUrlString(partnerHotel.linksSupport![0],
            mode: LaunchMode.externalApplication);
        break;
      case SupportGroupType.telegram:
        launchUrlString(partnerHotel.linksSupport![1],
            mode: LaunchMode.externalApplication);
        break;
      case SupportGroupType.zalo:
        launchUrlString(partnerHotel.linksSupport![2],
            mode: LaunchMode.externalApplication);
        break;
      case SupportGroupType.youtube:
        launchUrlString(partnerHotel.linksSupport![3],
            mode: LaunchMode.externalApplication);
        break;
      case SupportGroupType.gmail:
        launchUrlString(partnerHotel.linksSupport![4],
            mode: LaunchMode.externalApplication);
        break;
      default:
        return;
    }
  }

  static void updatePackage() {
    dataPackage["isDuration"] = PackageVersio.free;
    dataPackage["packageName"] = "";
    dataPackage["price"] = 0;
    dataPackage["expirationDate"] = 0;

    if (hotel!.packageVersion!.isEmpty) {
      //free
      dataPackage["isDuration"] = PackageVersio.free;
    } else {
      dataPackage["packageName"] =
          hotel!.packageVersion![hotel!.packageVersion!["default"]]["desc"];

      dataPackage["price"] =
          hotel!.packageVersion![hotel!.packageVersion!["default"]]["price"];

      dataPackage["expirationDate"] = (hotel!.packageVersion![GeneralManager
              .hotel!.packageVersion!["default"]]["end_date"] as Timestamp)
          .toDate()
          .difference(now)
          .inDays;

      // có tính phí
      if (dataPackage["expirationDate"] < 6 &&
          dataPackage["expirationDate"] > 0 &&
          dataPackage["price"] > 0) {
        //gần hết hạn
        dataPackage["isDuration"] = PackageVersio.almostExpired;
      } else if (dataPackage["expirationDate"] <= 0 &&
          dataPackage["price"] > 0) {
        //hết hạn
        dataPackage["isDuration"] = PackageVersio.expired;
      }
      // dùng thử
      if (dataPackage["expirationDate"] < 6 &&
          dataPackage["expirationDate"] > 0 &&
          dataPackage["price"] == 0) {
        //gần hết hạn
        dataPackage["isDuration"] = PackageVersio.almostExpiredFree;
      } else if (dataPackage["expirationDate"] <= 0 &&
          dataPackage["price"] == 0) {
        //hết hạn
        dataPackage["isDuration"] = PackageVersio.expiredFree;
      }
    }
  }

  static Future<void> screenshotHtmlToImgPolicy(
      BuildContext context, String? updatePolicy) async {
    ScreenshotController screenshotController = ScreenshotController();
    policyHotel = await screenshotController
        .captureFromWidget(
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 0.55),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: ColorManagement.white,
                width: kWidth,
                child: HtmlWidget(
                  """ ${updatePolicy ?? GeneralManager.hotel!.policy} """,
                  textStyle: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            pixelRatio: 3,
            delay: const Duration(seconds: 1))
        .then((value) => value);
  }
}
