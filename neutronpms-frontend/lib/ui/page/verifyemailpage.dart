import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';

class VerifyEmailController extends ChangeNotifier {
  int countdown = 0;
  Timer? timer;
  late BuildContext context;
  bool isError = false;

  VerifyEmailController();

  void startCountDown() async {
    countdown = 60;
    await FirebaseAuth.instance.currentUser!
        .sendEmailVerification()
        .then((value) {
      isError = false;
    }).onError((error, stackTrace) {
      if (error.toString().contains('unusual activity')) {
        MaterialUtil.showAlert(
            context,
            MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_TOO_MANY_REQUIREMENTS_IN_SHORT_TIME));
      }
      isError = true;
      countdown = 30;
      return;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        Navigator.pop(context);
        timer.cancel();
      }
      if (--countdown <= 0) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void setBuildContext(BuildContext context) {
    this.context = context;
  }

  void cancel() async {
    timer?.cancel();
  }
}

class VerifyEmailPage extends StatefulWidget {
  final VerifyEmailController controller = VerifyEmailController();

  VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    widget.controller.startCountDown();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.setBuildContext(context);
    return Container(
      color: ColorManagement.mainBackground,
      child: ChangeNotifierProvider<VerifyEmailController>.value(
        value: widget.controller,
        child: Consumer<VerifyEmailController>(
          builder: (_, controller, __) {
            List<Widget> children = [
              //email
              Text('Email: ${FirebaseAuth.instance.currentUser!.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: ColorManagement.lightColorText)),
              const SizedBox(height: 20),
              //status
              Text(
                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS)}: ${FirebaseAuth.instance.currentUser!.emailVerified ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_VERIFIED) : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_UNVERIFIED)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: ColorManagement.lightColorText)),
              const SizedBox(height: 20),
              ...controller.countdown > 0
                  ? [
                      if (!controller.isError)
                        const CircularProgressIndicator(
                            color: ColorManagement.greenColor),
                      const SizedBox(height: 20),
                      if (!controller.isError)
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: MessageUtil.getMessageByCode(
                                  MessageCodeUtil.TEXTALERT_PLEASE),
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: ColorManagement.lightColorText),
                              children: [
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        String url =
                                            'https://accounts.google.com/AccountChooser/signinchooser?service=mail&continue=https%3A%2F%2Fmail.google.com%2Fmail%2F&flowName=GlifWebSignIn&flowEntry=AccountChooser';
                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        } else {
                                          print('can not open $url');
                                        }
                                      },
                                    text:
                                        '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CHECK_EMAIL)} ',
                                    style: const TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                        color: ColorManagement.redColor)),
                                TextSpan(
                                  text: MessageUtil.getMessageByCode(
                                      MessageCodeUtil.TEXTALERT_TO_VERIFY),
                                )
                              ]),
                        ),
                      const SizedBox(height: 20),
                      Text(
                          '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YOU_CAN_REQUIRE_TO_RESEND_EMAIL_AFTER)}: ${controller.countdown}s',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: ColorManagement.lightColorText)),
                    ]
                  : [
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: ColorManagement.lightColorText),
                            text: MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_PLEASE),
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.startCountDown();
                                    },
                                  style: const TextStyle(
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      color: ColorManagement.redColor),
                                  text:
                                      '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLICK_HERE).toLowerCase()} '),
                              TextSpan(
                                  text: MessageUtil.getMessageByCode(
                                      MessageCodeUtil
                                          .TEXTALERT_TO_RESEND_EMAIL)),
                            ]),
                      )
                    ],
              const SizedBox(height: 50),
              TextButton(
                child: NeutronTextContent(
                  message: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_SIGN_OUT),
                ),
                onPressed: () async {
                  await GeneralManager.signOut(context);
                },
              ),
            ];

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            );
          },
        ),
      ),
    );
  }
}
