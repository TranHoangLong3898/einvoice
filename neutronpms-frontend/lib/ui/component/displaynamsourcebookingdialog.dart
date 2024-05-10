import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../controller/displaynamesourcebookingcontroller.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';

/// This allow users to adjust display name-source of booking
class DisplayNameSourceBookingDialog extends StatelessWidget {
  const DisplayNameSourceBookingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        padding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        child: ChangeNotifierProvider.value(
          value: DisplayNameSourceBookingController(),
          child: Consumer<DisplayNameSourceBookingController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor)),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  NeutronTextHeader(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_BOOKING_NAME),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Radio(
                        value: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_NAME),
                        groupValue: controller.displayOfBooking,
                        activeColor: ColorManagement.greenColor,
                        onChanged: (value) {
                          controller.setNameSource(value!);
                        },
                      ),
                      NeutronTextTitle(
                          messageUppercase: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_NAME)),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Radio(
                        value:
                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}",
                        groupValue: controller.displayOfBooking,
                        activeColor: ColorManagement.greenColor,
                        onChanged: (value) {
                          controller.setNameSource(value!);
                        },
                      ),
                      NeutronTextTitle(
                          messageUppercase: false,
                          message:
                              "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}"),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Radio(
                        value:
                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)}",
                        groupValue: controller.displayOfBooking,
                        activeColor: ColorManagement.greenColor,
                        onChanged: (value) {
                          controller.setNameSource(value!);
                        },
                      ),
                      NeutronTextTitle(
                          messageUppercase: false,
                          message:
                              "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)}"),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                    margin: EdgeInsets.zero,
                    onPressed1: () async {
                      await controller
                          .updateShowNameOrNameSource()
                          .then((result) {
                        if (result != MessageCodeUtil.SUCCESS) {
                          MaterialUtil.showSnackBar(
                              context, MessageUtil.getMessageByCode(result));
                          return;
                        }
                        Navigator.pop(context);
                        MaterialUtil.showSnackBar(
                            context,
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.SUCCESS));
                      });
                    },
                    icon1: Icons.save,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
