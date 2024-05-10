import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/autoratepricecontroller.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';

class AutoRatePriceDialog extends StatelessWidget {
  const AutoRatePriceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        padding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        child: ChangeNotifierProvider(
          create: (context) => AutoRatePriceController(),
          child: Consumer<AutoRatePriceController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const SizedBox(
                  height: 100,
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
                  SwitchListTile(
                    activeColor: ColorManagement.greenColor,
                    value: controller.autoRate,
                    onChanged: (value) => controller.setAutoRate(value),
                    title: NeutronTextTitle(
                        messageUppercase: false,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.SIDEBAR_SYNC_RATE_TO_CMS)),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                    margin: EdgeInsets.zero,
                    onPressed1: () async {
                      await controller
                          .updateAutoRoomAssignment()
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
