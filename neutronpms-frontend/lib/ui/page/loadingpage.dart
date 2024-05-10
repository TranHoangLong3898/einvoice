// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrondialogalert.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';

import '../../manager/channelmanager.dart';
import '../../manager/paymentmethodmanager.dart';
import '../../manager/roommanager.dart';
import '../../manager/usermanager.dart';
import '../../util/designmanagement.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  RoomManager? roomManager;
  ConfigurationManagement configurationManagement = ConfigurationManagement();

  @override
  void initState() {
    configurationManagement.asyncData();
    PaymentMethodManager().updatePaymentMothed();
    ItemManager().asyncItemsFromCloud();
    WarehouseManager().getWarehousesFromCloud();
    if (UserManager.canSeeStatusPage()) {
      DailyAllotmentStatic().changeHotel();
      DailyAllotmentStatic()
          .listenDailyAllotmentFromCloud(Timestamp.now().toDate());
    }
    roomManager ??= RoomManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManagement.mainBackground,
      body: Center(
        child: ChangeNotifierProvider.value(
          value: roomManager,
          child: Consumer<RoomManager>(
              builder: (_, roomManager, child) {
                if (roomManager.rooms == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ),
                      const SizedBox(height: 20),
                      NeutronTextContent(
                        message: MessageUtil.getMessageByCode(
                            MessageCodeUtil.TEXTALERT_LOADING_ROOMS),
                      )
                    ],
                  );
                } else {
                  return child!;
                }
              },
              child: FutureBuilder(
                future: loadingManagers(),
                builder: (context, snapshot) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ),
                      const SizedBox(height: 20),
                      NeutronTextContent(
                        message: MessageUtil.getMessageByCode(
                            MessageCodeUtil.TEXTALERT_LOADING_CONFIGS),
                      )
                    ],
                  );
                },
              )),
        ),
      ),
    );
  }

// Update for user login first time after create hotel
// get document from collect configuration, beds and payment methods
  Future<void> loadingManagers() async {
    if (GeneralManager.hotel!.policy!.isNotEmpty) {
      await GeneralManager.screenshotHtmlToImgPolicy(context, null);
    }
    await SystemManagement().update();

    if (UserManager.canManageChannels()) {
      await ChannelManager().update();
    }

    Navigator.pushReplacementNamed(context, 'main');
    if (GeneralManager.dataPackage["isDuration"] != PackageVersio.free &&
        !UserManager.isAdmin()) {
      if (GeneralManager.dataPackage["isDuration"] == PackageVersio.expired ||
          GeneralManager.dataPackage["isDuration"] ==
              PackageVersio.expiredFree) {
        RoomManager().cancelStream();
        ConfigurationManagement().cancelStream();
        PaymentMethodManager().cancelStream();
        ItemManager().cancelStream();
        DailyAllotmentStatic().cancel();
        ActivityController().cancel();
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      showDialog(
          barrierDismissible: GeneralManager.dataPackage["isDuration"] !=
                  PackageVersio.expired &&
              GeneralManager.dataPackage["isDuration"] !=
                  PackageVersio.expiredFree,
          context: context,
          builder: (context) =>
              const ShowAlertCheckCheckPackageVersionDialog()).then((value) {
        GeneralManager.dataPackage["isDuration"] = 0;
      });
    }
  }
}
