import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/hotel/userofhotelcontroller.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/ui/component/management/membermanagement/addusertohoteldialog.dart';
import 'package:ihotel/ui/component/management/membermanagement/grantrolesforuserdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/jobulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../manager/generalmanager.dart';
import 'logbookinguserdialog.dart';

class ListUsersDialog extends StatefulWidget {
  const ListUsersDialog({Key? key}) : super(key: key);

  @override
  State<ListUsersDialog> createState() => _ListUsersDialogState();
}

class _ListUsersDialogState extends State<ListUsersDialog> {
  UserOfHotelController? controller;
  @override
  void initState() {
    controller ??= UserOfHotelController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: isMobile ? kMobileWidth : kLargeWidth,
        child: Scaffold(
          backgroundColor: ColorManagement.mainBackground,
          appBar: AppBar(
            title: NeutronTextContent(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.SIDEBAR_LIST_MEMBER)),
            backgroundColor: ColorManagement.mainBackground,
          ),
          body: ChangeNotifierProvider<UserOfHotelController>.value(
            value: controller!,
            builder: (context, child) => Consumer<UserOfHotelController>(
              builder: (_, controller, __) => controller.isInprogress
                  ? const Center(
                      widthFactor: 50,
                      heightFactor: 50,
                      child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ),
                    )
                  : Column(
                      children: [
                        //header
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_LIST_MEMBER),
                          ),
                        ),
                        //title
                        if (!isMobile)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Row(
                              children: [
                                //name
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: NeutronTextTitle(
                                          fontSize: 13,
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_NAME)),
                                    )),
                                //role
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: NeutronTextTitle(
                                        fontSize: 13,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_ROLE),
                                      ),
                                    )),
                                //date_of_birth
                                Expanded(
                                    flex: 2,
                                    child: NeutronTextTitle(
                                        fontSize: 13,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_DATE_OF_BIRTH))),
                                //email
                                Expanded(
                                    flex: 3,
                                    child: NeutronTextTitle(
                                        fontSize: 13,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_EMAIL))),
                                //gender
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: NeutronTextTitle(
                                          fontSize: 13,
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_GENDER)),
                                    )),
                                // //job
                                // Expanded(
                                //     flex: 2,
                                //     child: NeutronTextTitle(
                                //         fontSize: 13,
                                //         isPadding: false,
                                //         message: UITitleUtil.getTitleByCode(
                                //             UITitleCode.TABLEHEADER_JOB))),
                                // //national-id
                                // Expanded(
                                //     flex: 2,
                                //     child: NeutronTextTitle(
                                //         fontSize: 13,
                                //         isPadding: false,
                                //         message: UITitleUtil.getTitleByCode(
                                //             UITitleCode
                                //                 .TABLEHEADER_NATIONAL_ID))),
                                //phone
                                Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: NeutronTextTitle(
                                          fontSize: 13,
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_PHONE)),
                                    )),
                                const SizedBox(
                                  width: 120,
                                ),
                              ],
                            ),
                          ),
                        //list
                        Expanded(
                            child: SingleChildScrollView(
                          child: Column(
                            children: controller.users
                                .map((user) => _buildUserInfo(user))
                                .toList(),
                          ),
                        )),
                        //add
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                            icon: Icons.add,
                            onPressed: () async {
                              bool? isSuccess = await showDialog(
                                context: context,
                                builder: (context) => AddUserToHotelDialog(),
                              );
                              if (isSuccess != null && isSuccess) {
                                await controller.getUsersOfHotel();
                              }
                            },
                          ),
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(HotelUser user) {
    List<String> userRoles = [];
    String roles = '';
    if (controller!.roles.keys.contains(user.id)) {
      for (String value in controller!.roles[user.id]) {
        roles += "${JobUlti.convertJobNameFromEnToLocal(value)}, ";
        userRoles.add(value);
      }
      roles = roles.substring(0, roles.length - 2);
    }

    if (ResponsiveUtil.isMobile(context)) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: NeutronTextContent(
                      message: user.fullname!, tooltip: user.fullname),
                ),
              ),
              NeutronTextContent(
                  textOverflow: TextOverflow.clip,
                  message: DateUtil.dateToString(user.dateOfBirth!)),
            ],
          ),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NAME),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                      message: user.fullname!,
                      tooltip: user.fullname,
                    ),
                  )
                ],
              ),
            ),
            //role
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROLE),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                      tooltip: roles.isNotEmpty ? roles : null,
                      message: roles.isNotEmpty
                          ? roles
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.NO_DATA),
                    ),
                  )
                ],
              ),
            ),
            //date_of_birth
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DATE_OF_BIRTH),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                        message: DateUtil.dateToString(user.dateOfBirth!)),
                  )
                ],
              ),
            ),
            //email
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_EMAIL),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                      message: user.email!,
                      tooltip: user.email,
                    ),
                  )
                ],
              ),
            ),
            //gender
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GENDER),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                        message: MessageUtil.getMessageByCode(user.gender)),
                  )
                ],
              ),
            ),
            // //job
            // Container(
            //   margin: const EdgeInsets.fromLTRB(
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //           child: NeutronTextContent(
            //         message:
            //             UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_JOB),
            //       )),
            //       Expanded(
            //         child: NeutronTextContent(
            //           message: JobUlti.convertJobNameFromEnToLocal(user.job)!,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            //national-id
            // Container(
            //   margin: const EdgeInsets.fromLTRB(
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       SizeManagement.cardOutsideHorizontalPadding,
            //       0),
            //   child: Row(
            //     children: [
            //       Expanded(
            //           child: NeutronTextContent(
            //         message: UITitleUtil.getTitleByCode(
            //             UITitleCode.TABLEHEADER_NATIONAL_ID),
            //       )),
            //       Expanded(
            //         child: NeutronTextContent(message: user.nationalId!),
            //       )
            //     ],
            //   ),
            // ),
            //phone
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideVerticalPadding),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PHONE),
                  )),
                  Expanded(
                    child: NeutronTextContent(message: user.phone!),
                  )
                ],
              ),
            ),
            //button
            if (UserManager.canGrantRoleForOtherUser(userRoles))
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_GRANT_ROLE),
                  color: ColorManagement.white,
                  icon: const Icon(Icons.verified_user_outlined),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => GrantRolesForUserDialog(
                        email: user.email!,
                        uid: user.id!,
                        roles: controller!.roles.keys.contains(user.id)
                            ? controller!.roles[user.id]
                            : [],
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_REMOVE_FROM_HOTEL),
                  color: ColorManagement.redColor,
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    bool? confirmResult = await MaterialUtil.showConfirm(
                        context,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.CONFIRM_REMOVE_USER_FROM_HOTEL,
                            [user.firstName!]));
                    if (confirmResult == null || !confirmResult) return;
                    String deleteResult =
                        await controller!.removeMember(user.id!);
                    if (mounted) {
                      MaterialUtil.showResult(context, deleteResult);
                    }
                  },
                ),
                IconButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) => LogBookingUserDialog(user: user)),
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.POPUPMENU_LOG_BOOKING),
                  icon: Icon(
                    Icons.receipt_long_rounded,
                    color: ColorManagement.iconMenuEnableColor,
                    size: GeneralManager.iconMenuSize,
                  ),
                ),
              ])
          ],
        ),
      );
    }
    return Container(
      height: SizeManagement.cardHeight,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: Row(
        children: [
          //name
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: NeutronTextContent(
                  tooltip: user.fullname,
                  message: user.fullname!,
                ),
              )),
          //role
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: NeutronTextContent(
                  tooltip:
                      controller!.roles.keys.contains(user.id) ? roles : null,
                  message: roles.isNotEmpty
                      ? roles
                      : MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA),
                ),
              )),
          //date_of_birth
          Expanded(
              flex: 2,
              child: NeutronTextContent(
                  message: DateUtil.dateToString(user.dateOfBirth!))),
          //email
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: user.email,
                message: user.email!,
              )),
          //gender
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: NeutronTextContent(
                  message: MessageUtil.getMessageByCode(user.gender),
                ),
              )),
          // //job
          // Expanded(
          //     flex: 2,
          //     child: NeutronTextContent(
          //       message: JobUlti.convertJobNameFromEnToLocal(user.job)!,
          //     )),
          // //national-id
          // Expanded(
          //     flex: 2,
          //     child: NeutronTextContent(
          //         message: user.nationalId!, tooltip: user.nationalId)),
          //phone
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: NeutronTextContent(
                    message: user.phone!, tooltip: user.phone),
              )),
          //grant roles icon
          SizedBox(
            width: 40,
            child: UserManager.canGrantRoleForOtherUser(userRoles)
                ? IconButton(
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_GRANT_ROLE),
                    color: ColorManagement.white,
                    icon: const Icon(Icons.verified_user_outlined),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => GrantRolesForUserDialog(
                          email: user.email!,
                          uid: user.id!,
                          roles: controller!.roles.keys.contains(user.id)
                              ? controller!.roles[user.id]
                              : [],
                        ),
                      );
                    },
                  )
                : null,
          ),
          //remove
          SizedBox(
            width: 40,
            child: UserManager.canGrantRoleForOtherUser(userRoles)
                ? IconButton(
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_REMOVE_FROM_HOTEL),
                    color: ColorManagement.redColor,
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      bool? confirmResult = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.CONFIRM_REMOVE_USER_FROM_HOTEL,
                              [user.firstName!]));
                      if (confirmResult == null || !confirmResult) return;
                      String deleteResult =
                          await controller!.removeMember(user.id!);
                      if (mounted) {
                        MaterialUtil.showResult(context, deleteResult);
                      }
                    },
                  )
                : null,
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => LogBookingUserDialog(user: user)),
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_LOG_BOOKING),
              icon: Icon(
                Icons.receipt_long_rounded,
                color: ColorManagement.iconMenuEnableColor,
                size: GeneralManager.iconMenuSize,
              ),
            ),
          )
        ],
      ),
    );
  }
}
