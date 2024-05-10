import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import '../../../constants.dart';
import '../../../util/designmanagement.dart';
import '../../../util/uimultilanguageutil.dart';

class InfoHotelSupport extends StatelessWidget {
  final Map<String, dynamic>? hotelInfo;

  const InfoHotelSupport({Key? key, this.hotelInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hotel = hotelInfo!['hotel'];
    final List<dynamic> users = hotelInfo!['users'];

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
            const NeutronTextTitle(message: 'Info Hotel'),
            const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
            // Phone
            Container(
              margin: const EdgeInsets.only(
                  bottom: SizeManagement.bottomFormFieldSpacing,
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding),
              child: NeutronTextFormField(
                  isDecor: true,
                  controller: TextEditingController(text: hotel['phone']),
                  readOnly: true,
                  label: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_PHONE)),
            ),
            // address
            Container(
              margin: const EdgeInsets.only(
                  bottom: SizeManagement.bottomFormFieldSpacing,
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding),
              child: NeutronTextFormField(
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADDRESS),
                isDecor: true,
                controller: TextEditingController(
                    text:
                        '${hotel['street']} ${hotel['city']} ${hotel['country']}'),
                readOnly: true,
              ),
            ),
            // Email
            Container(
              margin: const EdgeInsets.only(
                  bottom: SizeManagement.bottomFormFieldSpacing,
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding),
              child: NeutronTextFormField(
                label:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL),
                isDecor: true,
                controller: TextEditingController(text: hotel['email']),
                readOnly: true,
              ),
            ),
            const Divider(color: ColorManagement.lightColorText),
            const NeutronTextTitle(message: 'Info Owner'),
            if (users.isNotEmpty)
              Flexible(child: ListView(children: _buildInfoOwner(users))),
            const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoOwner(List<dynamic> users) {
    return users
        .map((user) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // address
                Container(
                  margin: const EdgeInsets.only(
                      top: SizeManagement.rowSpacing,
                      bottom: SizeManagement.bottomFormFieldSpacing,
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding),
                  child: NeutronTextFormField(
                    isDecor: true,
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ADDRESS),
                    controller: TextEditingController(
                      text:
                          '${user['address']} ${user['city']} ${user['country']}',
                    ),
                    readOnly: true,
                  ),
                ),
                //email
                Container(
                  margin: const EdgeInsets.only(
                      bottom: SizeManagement.bottomFormFieldSpacing,
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding),
                  child: NeutronTextFormField(
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_EMAIL),
                    isDecor: true,
                    controller: TextEditingController(text: user['email']),
                    readOnly: true,
                  ),
                ),
                // Phone
                Container(
                  margin: const EdgeInsets.only(
                      bottom: SizeManagement.bottomFormFieldSpacing,
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding),
                  child: NeutronTextFormField(
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PHONE),
                    isDecor: true,
                    controller: TextEditingController(text: user['phone']),
                    readOnly: true,
                  ),
                ),
                // Name
                Container(
                  margin: const EdgeInsets.only(
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding),
                  child: NeutronTextFormField(
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NAME),
                    isDecor: true,
                    controller: TextEditingController(
                        text: '${user['first_name']} ${user['last_name']}'),
                    readOnly: true,
                  ),
                ),
              ],
            ))
        .toList();
  }
}
