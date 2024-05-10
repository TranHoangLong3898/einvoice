// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/versionmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class UpdateVersionDialog extends StatelessWidget {
  final UpdateVersionController updateVersionController =
      UpdateVersionController();

  UpdateVersionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 235,
        child: ChangeNotifierProvider.value(
          value: updateVersionController,
          child: Consumer<UpdateVersionController>(
              builder: (_, controller, __) => controller.isInProgress
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding,
                              vertical: SizeManagement.topHeaderTextSpacing),
                          alignment: Alignment.center,
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_UPDATE_VERSION),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: SizeManagement.cardOutsideVerticalPadding,
                              right: SizeManagement.cardOutsideVerticalPadding,
                              bottom: SizeManagement.bottomFormFieldSpacing),
                          child: NeutronTextFormField(
                            controller: controller.teVersion,
                            isDecor: true,
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.SIDEBAR_VERSION),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: SizeManagement.bottomFormFieldSpacing),
                          child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.VERSION_FORMAT_DESCRIPTION),
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.none,
                                fontStyle: FontStyle.italic),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            String result = await controller.update();
                            if (result != MessageCodeUtil.SUCCESS) {
                              MaterialUtil.showAlert(context,
                                  MessageUtil.getMessageByCode(result));
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        )
                      ],
                    )),
        ),
      ),
    );
  }
}

class UpdateVersionController extends ChangeNotifier {
  bool isInProgress = false;
  late TextEditingController teVersion;
  late String oldVersion;

  UpdateVersionController() {
    teVersion = TextEditingController(
        text: VersionManager.versionInCloud ?? GeneralManager.version);
    oldVersion = teVersion.text;
  }

  Future<String> update() async {
    String version = teVersion.text.replaceAll(RegExp(r'\s+'), '').trim();
    if (oldVersion == version) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }
    List<String> versionInArray = version.split('.');
    if (versionInArray.length != 3 ||
        num.tryParse(versionInArray[0]) == null ||
        num.tryParse(versionInArray[1]) == null ||
        num.tryParse(versionInArray[2]) == null) {
      return MessageCodeUtil.INVALID_VERSION;
    }
    isInProgress = true;
    notifyListeners();
    String result = await VersionManager().updateVersionToCloud(version);
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
