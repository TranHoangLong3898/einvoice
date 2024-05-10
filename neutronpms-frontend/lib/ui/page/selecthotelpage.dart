// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/enum.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/hotel.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/dashboardmuchhotels_page.dart';
import 'package:ihotel/ui/component/hotel/addhoteldialog.dart';
import 'package:ihotel/ui/component/hotel/infohotelsupport.dart';
import 'package:ihotel/ui/component/select_hotel_item.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controller/selecthotelcontroller.dart';
import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';
import '../../util/uimultilanguageutil.dart';
import '../component/updateversiondialog.dart';

class SelectHotelPage extends StatefulWidget {
  const SelectHotelPage({Key? key}) : super(key: key);

  @override
  State<SelectHotelPage> createState() => _SelectHotelPageState();
}

class _SelectHotelPageState extends State<SelectHotelPage> {
  late HotelPageController hotelPageController;

  @override
  void initState() {
    super.initState();
    hotelPageController = HotelPageController();
  }

  @override
  Widget build(BuildContext context) {
    hotelPageController.setContext(context);

    return SafeArea(
      child: ChangeNotifierProvider.value(
        value: hotelPageController,
        child: Consumer<HotelPageController>(
          builder: (_, controller, __) => Scaffold(
            drawer: Drawer(
                backgroundColor: ColorManagement.mainBackground,
                child: ListView(
                  controller: ScrollController(),
                  padding: EdgeInsets.zero,
                  children: [
                    ExpansionTile(
                      collapsedIconColor: ColorManagement.trailingIconColor,
                      iconColor: ColorManagement.trailingIconColor,
                      title: Text(
                        UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_BOARD),
                        style: const TextStyle(color: ColorManagement.white),
                      ),
                      backgroundColor: ColorManagement.lightMainBackground,
                      children: [
                        ListTile(
                          textColor: ColorManagement.lightColorText,
                          leading:
                              const Icon(Icons.dashboard, color: Colors.white),
                          title: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.SIDEBAR_DASHBOARD),
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const DashboarMuchHotelsPage(),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )),
            appBar: AppBar(actions: [
              if (UserManager.isAdminSystem)
                IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_UPDATE_VERSION_NUMBER_TO_CLOUD),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => UpdateVersionDialog());
                  },
                )
            ]),
            backgroundColor: ColorManagement.mainBackground,
            body: Stack(
              children: [
                buildBody(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBody(HotelPageController controller) {
    switch (controller.status) {
      case HotelPageStatus.updateInfo:
        controller.showUserDialog(context);
        break;
      case HotelPageStatus.needUpdateInfo:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.NEED_TO_UPDATE_INFO),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ColorManagement.mainColorText,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: SizeManagement.cardOutsideVerticalPadding),
              ElevatedButton(
                  style: ButtonStyle(elevation: MaterialStateProperty.all(10)),
                  onPressed: () {
                    controller.showUserDialog(context);
                  },
                  child: Text(
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_CLICK_HERE),
                    style: const TextStyle(
                      color: ColorManagement.redColor,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  )),
              const SizedBox(
                height: 30,
              ),
              //sign out button
              _buildSignOutButton(context),
            ],
          ),
        );
      case HotelPageStatus.noHotel:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardOutsideHorizontalPadding),
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.NOT_BELONG_TO_ANY_HOTEL),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorManagement.mainColorText,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              if (UserManager.isAdmin())
                //create new hotel button
                _buildCreateHotelButton(context, controller),
              //Link instruction
              _buildLinkInstruction(context),
              //sign out button
              _buildSignOutButton(context),
              //build multi-language button
              _buildMultiLanguageButton(context)
            ],
          ),
        );
      case HotelPageStatus.hotelNotFoundWithQuery:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            //title
            Center(
              child: NeutronTextHeader(
                message: MessageUtil.getMessageByCode(
                    MessageCodeUtil.TEXTALERT_CHOOSE_YOUR_HOTEL),
              ),
            ),
            //version
            Center(
                child: NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                        MessageCodeUtil.TEXTALERT_VERSION,
                        [GeneralManager.version]))),
            const SizedBox(height: 20),
            _buildSearchHotel(),
            Expanded(
              child: Center(
                child: NeutronTextContent(
                    message:
                        MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)),
              ),
            ),
            if (UserManager.isAdmin())
              //create new hotel button
              _buildCreateHotelButton(context, controller),
            //sign out button
            _buildSignOutButton(context),
            //multi-language
            _buildMultiLanguageButton(context)
          ],
        );
      case HotelPageStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //title
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Center(
                child: NeutronTextHeader(
                  message: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_CHOOSE_YOUR_HOTEL),
                ),
              ),
            ),
            //version
            Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Center(
                    child: NeutronTextContent(
                        message: MessageUtil.getMessageByCode(
                            MessageCodeUtil.TEXTALERT_VERSION,
                            [GeneralManager.version])))),
            _buildSearchHotel(),
            //list
            Expanded(
              child: GridView.count(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.all(
                    SizeManagement.cardOutsideHorizontalPadding),
                crossAxisCount: ResponsiveUtil.isMobile(context) ? 1 : 3,
                mainAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
                crossAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
                childAspectRatio: ResponsiveUtil.isMobile(context) ? 6 : 3,
                children: <Widget>[
                  ...controller.hotels
                      .map(
                        (hotel) => InkWell(
                          onTap: () => handleOnTapHotelItem(hotel),
                          onDoubleTap: () => handleOnDoubleTapHotelItem(hotel),
                          child: SelectHotelItem(
                            imageData: controller.images[hotel.id]!,
                            hotel: hotel,
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            //create new hotel button
            if (UserManager.isAdmin())
              _buildCreateHotelButton(context, controller),
            //Link instruction
            _buildLinkInstruction(context),
            //sign out button
            _buildSignOutButton(context),
            //multi-language
            _buildMultiLanguageButton(context)
          ],
        );
      case HotelPageStatus.loading:
      case null:
    }
    //loading
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: ColorManagement.greenColor,
        ),
        const SizedBox(height: 20),
        NeutronTextContent(
          message: MessageUtil.getMessageByCode(
              MessageCodeUtil.TEXTALERT_LOADING_HOTELS),
        )
      ],
    ));
  }

  Widget _buildCreateHotelButton(
      BuildContext context, HotelPageController controller) {
    return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: NeutronTextStyle.content,
            children: <TextSpan>[
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_IF_YOU_ARE_HOTEL_MANAGER)),
              TextSpan(
                text:
                    ' ${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CLICK_HERE)} ',
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: ColorManagement.redColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final result = await showDialog(
                        context: context,
                        builder: (context) {
                          return const AddHotelDialog();
                        });
                    if (result == null || !result) return;
                    if (UserManager.user!.id != uidAdmin) {
                      controller.getHotelAfterCreate();
                    } else {
                      controller.getHotelsByNameQuery();
                    }
                  },
              ),
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_TO_CREATE_YOUR_HOTEL)),
            ],
          ),
        ));
  }

  Widget _buildLinkInstruction(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
            top: SizeManagement.rowSpacing,
            bottom: SizeManagement.cardInsideHorizontalPadding),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: NeutronTextStyle.content,
            children: <TextSpan>[
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_PLEASE)),
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
                        mode: LaunchMode.externalApplication);
                  },
              ),
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_FOR_INSTRUCTION_VIDEO)),
            ],
          ),
        ));
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          bottom: SizeManagement.cardOutsideVerticalPadding),
      alignment: Alignment.center,
      child: TextButton(
        child: NeutronTextContent(
          message:
              MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_SIGN_OUT),
        ),
        onPressed: () async {
          await GeneralManager.signOut(context);
        },
      ),
    );
  }

  Widget _buildMultiLanguageButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: SizeManagement.cardOutsideVerticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              onPressed: () {
                GeneralManager().setLocale('en');
              },
              child: const NeutronTextContent(message: 'EN')),
          TextButton(
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              onPressed: () {
                GeneralManager().setLocale('vi');
              },
              child: const NeutronTextContent(message: 'VI'))
        ],
      ),
    );
  }

  Widget _buildSearchHotel() {
    if (!UserManager.isAdmin()) {
      return const SizedBox();
    }
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: kMobileWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: NeutronTextFormField(
                backgroundColor: ColorManagement.lightMainBackground,
                isDecor: true,
                label: 'Input name',
                controller: HotelPageController.nameQuery,
                onSubmitted: (String value) =>
                    hotelPageController.getHotelsByNameQuery(),
              ),
            ),
            IconButton(
                onPressed: () => hotelPageController.getHotelsByNameQuery(),
                icon: const Icon(Icons.refresh))
          ],
        ),
      ),
    );
  }

  void handleOnTapHotelItem(Hotel hotel) async {
    hotelPageController.updateHotel(hotel.id!);
    if (UserManager.role == null) {
      MaterialUtil.showAlert(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STILL_NOT_BE_AUTHORIZED));
      return;
    }
    GeneralManager.hotelImage = hotelPageController.images[hotel.id];
    Navigator.pushNamed(context, 'loading');
  }

  void handleOnDoubleTapHotelItem(Hotel hotel) async {
    if (hotel.roles!.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
      UserManager.role =
          List.castFrom(hotel.roles![FirebaseAuth.instance.currentUser!.uid]);
    }
    if (UserManager.isBelongSystem()) {
      final result = await hotelPageController.getInformationOfHotel(hotel.id!);
      if (result != null) {
        await showDialog(
            context: context,
            builder: (context) {
              return InfoHotelSupport(
                hotelInfo: result,
              );
            });
      } else {
        MaterialUtil.showAlert(context,
            MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR));
      }
    }
  }
}
