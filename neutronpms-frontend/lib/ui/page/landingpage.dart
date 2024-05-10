import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/enum.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/versionmanager.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutronupdateversion.dart';
import 'package:ihotel/ui/page/verifyemailpage.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../ui/page/selecthotelpage.dart';
import 'loginpage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final VersionManager versionManager = VersionManager();

  late Stream<User?> stream;
  BuildContext? newVersionContext;

  @override
  void initState() {
    super.initState();
    stream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: stream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData && !snapshot.data!.isAnonymous) {
          if (!snapshot.data!.emailVerified && snapshot.data!.uid != uidAdmin) {
            Future.delayed(Duration.zero, () {
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: false,
                builder: (context) => WillPopScope(
                    onWillPop: () async => false, child: VerifyEmailPage()),
              );
            });
          }
          UserManager.user ??= HotelUser.empty(snapshot.data!.uid);
          UserManager.user!.email = snapshot.data!.email;
          SystemManagement().getConfigurationFromCloud();
          return Scaffold(
            backgroundColor: ColorManagement.mainBackground,
            body: Stack(
              children: [
                ChangeNotifierProvider<VersionManager>.value(
                    value: versionManager,
                    child: Consumer<VersionManager>(
                        builder: (_, versionManager, __) {
                      if (versionManager.isLoadding) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: ColorManagement.greenColor));
                      }
                      if (newVersionContext != null) {
                        Navigator.of(newVersionContext!, rootNavigator: true)
                            .pop();
                        newVersionContext = null;
                      }
                      if (versionManager.isNeedToUpdate()) {
                        Future.delayed(Duration.zero, () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              useRootNavigator: false,
                              builder: (newVersionDialogContext) {
                                newVersionContext = newVersionDialogContext;
                                return WillPopScope(
                                    onWillPop: () async => false,
                                    child: const NeutronUpdateVersion());
                              });
                        });
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Image(
                                  image: AssetImage("assets/img/logo.png"),
                                  height: kMobileWidth,
                                  width: kMobileWidth,
                                  fit: BoxFit.cover),
                              NeutronTextContent(
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_VERSION)}: ${GeneralManager.version}',
                              )
                            ],
                          ),
                        );
                      }

                      // ignore: prefer_const_constructors
                      return SelectHotelPage();
                    })),
                //customer support
                Positioned(
                    right: 10,
                    bottom: 10,
                    child: PopupMenuButton<SupportGroupType>(
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_CUSTOMMER_SUPPORT),
                      color: ColorManagement.lightMainBackground,
                      elevation: 5,
                      onSelected: (SupportGroupType value) =>
                          GeneralManager.openSupportGroup(value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          height: 35,
                          textStyle: const TextStyle(
                              color: ColorManagement.mainColorText),
                          value: SupportGroupType.facebook,
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.facebook,
                                color: Colors.blue.shade400,
                                size: 25,
                              ),
                              const SizedBox(width: 16),
                              const Text('Facebook')
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          height: 35,
                          textStyle:
                              TextStyle(color: ColorManagement.mainColorText),
                          value: SupportGroupType.telegram,
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.telegram,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 16),
                              Text('Telegram')
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          height: 35,
                          textStyle: const TextStyle(
                              color: ColorManagement.mainColorText),
                          value: SupportGroupType.zalo,
                          child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  height: 23.5,
                                  width: 25,
                                  child: Image.asset('assets/icon/zalo.png',
                                      color: Colors.blue.shade400)),
                              const SizedBox(width: 16),
                              const Text('Zalo')
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          height: 35,
                          textStyle:
                              TextStyle(color: ColorManagement.mainColorText),
                          value: SupportGroupType.youtube,
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.youtube,
                                color: ColorManagement.redColor,
                                size: 28,
                              ),
                              SizedBox(width: 16),
                              Text('Youtube')
                            ],
                          ),
                        )
                      ],
                      child: CircleAvatar(
                        backgroundColor: ColorManagement.transparentBackground,
                        child: const Icon(Icons.support_agent,
                            color: Colors.white),
                      ),
                    )),
              ],
            ),
          );
        } else {
          // ignore: prefer_const_constructors
          return LoginPage();
        }
      },
    );
  }
}
