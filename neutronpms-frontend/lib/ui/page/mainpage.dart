// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/roles.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/page/userdrawer.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/generalmanager.dart';
import '../../manager/paymentmethodmanager.dart';
import '../../manager/usermanager.dart';
import '../../ui/page/statuspage.dart';
import '../../util/designmanagement.dart';
// import '../../util/responsiveutil.dart';
import 'housekeepingpage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void dispose() {
    RoomManager().cancelStream();
    ConfigurationManagement().cancelStream();
    PaymentMethodManager().cancelStream();
    ItemManager().cancelStream();
    DailyAllotmentStatic().cancel();
    ActivityController().cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _buildBody(context), onWillPop: () async => false);
  }

  Widget _buildBody(BuildContext context) {
    if (UserManager.canSeeStatusPage()) {
      final width = MediaQuery.of(context).size.width;
      int fontSize = GeneralManager.sizeDatesForBoard;
      if (fontSize == 7) {
        int cellWidth = 165;
        int numCell = 9;
        if (width > 1155) {
          cellWidth = width ~/ numCell;
        }
        GeneralManager.cellWidth = cellWidth.toDouble();
        GeneralManager.numDates = numCell - 1;
      }
      if (fontSize == 15) {
        GeneralManager.cellWidth = 110.0;
        GeneralManager.numDates = 16;
      }
      if (fontSize == 30) {
        GeneralManager.cellWidth = 120.0;
        GeneralManager.numDates = 31;
      }

      return StatusPage();
    } else if (UserManager.canSeeHouseKeepingPage()) {
      return HousekeepingPage();
    } else if (UserManager.role!.contains(Roles.warehouseManager)) {
      return Scaffold(
        drawer: const UserDrawer(),
        body: Container(
          color: ColorManagement.mainBackground,
          alignment: Alignment.center,
        ),
        appBar: AppBar(),
      );
    } else {
      return Container(
        color: ColorManagement.mainBackground,
        alignment: Alignment.center,
        child: Text(
          MessageUtil.getMessageByCode(
            MessageCodeUtil.TEXTALERT_NO_PERMISSION,
          ),
          style: TextStyle(
              color: ColorManagement.lightColorText,
              fontWeight: FontWeight.normal,
              fontSize: 14,
              decoration: TextDecoration.none),
        ),
      );
    }
  }
}
