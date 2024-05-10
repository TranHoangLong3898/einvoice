// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/logincontroller.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/ui/component/management/membermanagement/updateuserdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../enum.dart';
import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';
import '../controls/neutrontextstyle.dart';
import '../component/fotgotpassworddialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController loginController;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    loginController = LoginController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = GeneralManager.locale!.toLanguageTag() == 'en';
    final bool isMobile = ResponsiveUtil.isMobile(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip:
            '${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHANGE_LANGUAGE)}: ${MessageUtil.getMessageByCode(isEnglish ? MessageCodeUtil.LANGUAGE_VIETNAMESE : MessageCodeUtil.LANGUAGE_ENGLISH)}',
        backgroundColor:
            const Color.fromARGB(255, 112, 112, 112).withOpacity(0.5),
        hoverColor: const Color.fromARGB(255, 112, 112, 112).withOpacity(0.8),
        onPressed: () {
          String newLocaleCode = isEnglish ? 'vi' : 'en';
          GeneralManager().setLocale(newLocaleCode);
        },
        child: Text(isEnglish ? 'Vi' : 'En'),
      ),
      body: Stack(children: [
        //background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/hotelbackground.jpg'),
                fit: BoxFit.cover),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ),
        //form
        Center(
          child: Container(
            alignment: Alignment.center,
            width: isMobile ? kMobileWidth : 700,
            height: 435,
            decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(8, 8)),
              ],
            ),
            child: Row(
              children: [
                if (!isMobile)
                  Expanded(
                      child: SizedBox(
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            GeneralManager.partnerHotel.logobackground!),
                      ),
                    ),
                  )),
                Container(
                  width: kMobileWidth,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ChangeNotifierProvider<LoginController>.value(
                    value: loginController,
                    child: Consumer<LoginController>(
                      builder: (_, controller, __) => Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: NeutronTextHeader(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.HEADER_SIGN_IN),
                            ),
                          ),
                          //input email
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: ColorManagement.lightColorText,
                                fontFamily: FontManagement.fontFamily,
                              ),
                              onSubmitted: (String value) {
                                focusNode.requestFocus();
                              },
                              controller: controller.emailController,
                              decoration: InputDecoration(
                                label: NeutronTextContent(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.HINT_EMAIL)),
                                errorStyle: const TextStyle(
                                  color: Colors.red,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: ColorManagement.white,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.greenColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.borderCell,
                                      width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.borderCell,
                                      width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.greenColor,
                                      width: 1),
                                ),
                                fillColor: ColorManagement.mainBackground,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              cursorColor: ColorManagement.greenColor,
                            ),
                          ),
                          //input password
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              obscureText: !controller.isShowPassword,
                              style: const TextStyle(
                                color: ColorManagement.lightColorText,
                                fontFamily: FontManagement.fontFamily,
                              ),
                              focusNode: focusNode,
                              onSubmitted: (String value) {
                                login(controller, context);
                              },
                              controller: controller.passwordController,
                              decoration: InputDecoration(
                                label: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.HINT_PASSWORD),
                                ),
                                errorStyle: const TextStyle(color: Colors.red),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: ColorManagement.white,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.greenColor,
                                      width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.borderCell,
                                      width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.borderCell,
                                      width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: ColorManagement.greenColor,
                                      width: 1),
                                ),
                                fillColor: ColorManagement.mainBackground,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                suffix: InkWell(
                                    onTap: () {
                                      controller.toggleShowPasswordStatus();
                                    },
                                    child: Icon(
                                      controller.isShowPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: ColorManagement.lightColorText,
                                      size: 14,
                                    )),
                              ),
                              cursorColor: ColorManagement.greenColor,
                            ),
                          ),
                          //forget-password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const ForgotPasswordDialog());
                              },
                              child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_FORGET_PASSWORD),
                              ),
                            ),
                          ),
                          //remember-me button
                          CheckboxListTile(
                            activeColor: ColorManagement.greenColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.all(0),
                            title: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_REMEMBER_ME)),
                            onChanged: (bool? isChecked) {
                              controller.setRememberMe(isChecked!);
                            },
                            value: controller.isRememberMe,
                          ),
                          //button
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all(
                                    ColorManagement.transparentBackground),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.2)),
                                elevation: MaterialStateProperty.all(10),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                              ),
                              onPressed: () {
                                login(controller, context);
                              },
                              child: NeutronTextContent(
                                  message: MessageUtil.getMessageByCode(
                                      MessageCodeUtil.TEXTALERT_LOGIN)),
                            ),
                          ),
                          //signup
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => UpdateUserDialog(
                                    isSignUpUser: true,
                                    userHotel: HotelUser.emptyWithoutUid(),
                                  ),
                                );
                              },
                              child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_SIGN_UP),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          //open link
                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        GeneralManager.openSupportGroup(
                                            SupportGroupType.facebook),
                                    child: Icon(
                                      FontAwesomeIcons.facebook,
                                      color: Colors.blue.shade400,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                      onTap: () =>
                                          GeneralManager.openSupportGroup(
                                              SupportGroupType.telegram),
                                      child: const Icon(
                                        FontAwesomeIcons.telegram,
                                        color: Colors.white,
                                        size: 24,
                                      )),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      height: 23.5,
                                      width: 25,
                                      child: InkWell(
                                        onTap: () =>
                                            GeneralManager.openSupportGroup(
                                                SupportGroupType.zalo),
                                        child: Image.asset(
                                          'assets/icon/zalo.png',
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: InkWell(
                                  child: const Icon(
                                    FontAwesomeIcons.youtube,
                                    color: ColorManagement.redColor,
                                    size: 28,
                                  ),
                                  onTap: () => GeneralManager.openSupportGroup(
                                      SupportGroupType.youtube),
                                ))
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(bottom: 13),
                            alignment: Alignment.center,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: NeutronTextStyle.content,
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        ' ${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLICK_HERE)} ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: ColorManagement.redColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        launchUrlString(
                                            'https://www.youtube.com/watch?v=3diC6Qy1cBI',
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                  ),
                                  TextSpan(
                                      text: MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .TEXTALERT_FOR_INSTRUCTION_VIDEO)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void login(LoginController controller, BuildContext context) async {
    String result = await controller.login();
    if (result == MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) return;
    MaterialUtil.showAlert(context, result);
  }
}
