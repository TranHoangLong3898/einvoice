// ignore_for_file: use_build_context_synchronously

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roles.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/jobulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/stringutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GrantRolesForUserDialog extends StatelessWidget {
  final String email;
  final String uid;
  final List<dynamic> roles;
  late GrantRolesController controller;

  GrantRolesForUserDialog(
      {Key? key, required this.email, required this.uid, required this.roles})
      : super(key: key) {
    controller = GrantRolesController(uid, roles);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        color: ColorManagement.lightMainBackground,
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider<GrantRolesController>.value(
          value: controller,
          builder: (context, child) => Consumer<GrantRolesController>(
            builder: (_, controller, __) => controller.isInprogress
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: NeutronTextHeader(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.HEADER_AUTHORIZED),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SizeManagement.cardOutsideHorizontalPadding,
                            SizeManagement.rowSpacing,
                            SizeManagement.cardOutsideHorizontalPadding,
                            SizeManagement.bottomFormFieldSpacing,
                          ),
                          child: NeutronTextFormField(
                            hint: email,
                            readOnly: true,
                            isDecor: true,
                          )),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                            children: controller.roles.keys
                                .map((key) => CheckboxListTile(
                                    activeColor: (key == Roles.admin ||
                                            key == Roles.owner ||
                                            (key == Roles.manager &&
                                                !UserManager.role!.any(
                                                    (element) =>
                                                        element ==
                                                            Roles.admin ||
                                                        element ==
                                                            Roles.owner)))
                                        ? ColorManagement.greyColor
                                        : ColorManagement.greenColor,
                                    enableFeedback: !(key == Roles.admin ||
                                        (key == Roles.owner &&
                                            !UserManager.role!
                                                .contains(Roles.admin))),
                                    checkColor: Colors.white,
                                    title: NeutronTextContent(
                                      message: StringUtil.capitalize(key),
                                    ),
                                    value: controller.roles[key],
                                    onChanged: (bool? value) {
                                      String admin =
                                          MessageUtil.getMessageByCode(
                                              MessageCodeUtil.JOB_ADMIN);
                                      String owner =
                                          MessageUtil.getMessageByCode(
                                              MessageCodeUtil.JOB_OWNER);
                                      String manager =
                                          MessageUtil.getMessageByCode(
                                              MessageCodeUtil.JOB_MANAGER);
                                      if (key == admin) return;
                                      if (key == owner &&
                                          !UserManager.role!
                                              .contains(Roles.admin)) return;
                                      if (key == manager &&
                                          !UserManager.role!.any((element) =>
                                              element == Roles.admin ||
                                              element == Roles.owner)) return;
                                      controller.updateRoles(key, value!);
                                    }))
                                .toList()),
                      )),
                      Align(
                        alignment: Alignment.center,
                        child: NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            String result = await controller.saveRoles();
                            if (result ==
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS)) {
                              Navigator.pop(context);
                              MaterialUtil.showSnackBar(context, result);
                            } else {
                              MaterialUtil.showAlert(context, result);
                            }
                          },
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class GrantRolesController extends ChangeNotifier {
  bool isInprogress = false;
  String uid;
  List<dynamic> userRoles = [];

  Map<String, bool> roles = {};

  GrantRolesController(this.uid, List<dynamic> userRoles) {
    this.userRoles =
        userRoles.map((e) => JobUlti.convertJobNameFromEnToLocal(e)).toList();
    Roles.getRolesForAuthorize().forEach((element) {
      roles[element] = this.userRoles.contains(element);
    });
  }

  void updateRoles(String roleItem, bool checked) {
    roles[roleItem] = checked;
    notifyListeners();
  }

  Future<String> saveRoles() async {
    if (uid == UserManager.user!.id &&
        !UserManager.role!.contains(Roles.admin)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.CAN_NOT_AUTHORIZE_BY_YOURSELF);
    }
    if (userRoles.any((v) => [Roles.admin, Roles.owner].contains(v)) &&
        !UserManager.role!.any((v) => [Roles.admin, Roles.owner].contains(v))) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.CAN_NOT_AUTHORIZE_YOUR_BOSS);
    }
    if (isInprogress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    List<String> checkedRoles = [];
    roles.forEach((roleItem, checked) {
      if (checked) {
        Map<String, String>? roleMap = MessageUtil.messageMap.values
            .toList()
            .firstWhere(
                (element) => element!['${GeneralManager.locale}'] == roleItem);
        if (roleMap == null) {
          return;
        }
        checkedRoles.add(roleMap['en']!.toLowerCase());
      }
    });

    if (checkedRoles.isEmpty) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.INPUT_AT_LEAST_ONE_ROLE);
    }
    isInprogress = true;
    notifyListeners();
    String result = await FirebaseFunctions.instance
        .httpsCallable('user-grantRolesForUser')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'uid': uid,
          'roles': checkedRoles
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    isInprogress = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}
