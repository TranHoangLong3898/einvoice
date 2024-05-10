import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/hourinoutbookingcontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';

class HourInOutBookingMonthlyDialog extends StatefulWidget {
  const HourInOutBookingMonthlyDialog({Key? key}) : super(key: key);

  @override
  State<HourInOutBookingMonthlyDialog> createState() =>
      _HourInOutBookingMonthlyDialogState();
}

class _HourInOutBookingMonthlyDialogState
    extends State<HourInOutBookingMonthlyDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        padding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        child: ChangeNotifierProvider(
          create: (context) => HourInOutBookingMonthlyController(),
          child: Consumer<HourInOutBookingMonthlyController>(
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
                  NeutronDropDownCustom(
                    backgroundColor: ColorManagement.mainBackground,
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_HOUR_IN_OUT_BOOKING_MONTHLY),
                    childWidget: NeutronDropDown(
                      isCenter: true,
                      isPadding: false,
                      onChanged: controller.setHourBookingMontnly,
                      value: controller.selectHurInOut,
                      items: controller.listHourInOut,
                    ),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                    margin: EdgeInsets.zero,
                    onPressed1: () async {
                      await controller
                          .updateHourInOutBookingMonthly()
                          .then((result) async {
                        if (!mounted) {
                          return;
                        }
                        if (result == MessageCodeUtil.SUCCESS) {
                          bool? confirmResult = await MaterialUtil.showConfirm(
                              context,
                              MessageUtil.getMessageByCode(MessageCodeUtil
                                  .TEXTALERT_CHANGE_HOUR_SUCCESS_AND_RELOAD));
                          if (confirmResult == null || !confirmResult) {
                            return;
                          }
                          GeneralManager().rebuild();

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          MaterialUtil.showAlert(
                              context, MessageUtil.getMessageByCode(result));
                        }
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
