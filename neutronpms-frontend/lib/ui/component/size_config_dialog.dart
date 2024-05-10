import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/size_config_controller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

/// This allow users to adjust size of StatusPage
class SizeConfigDialog extends StatelessWidget {
  const SizeConfigDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        padding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        child: ChangeNotifierProvider.value(
          value: SizeConfigController(),
          child: Consumer<SizeConfigController>(
            builder: (_, controller, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  NeutronTextHeader(
                    message:
                        '${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SIZE)} = ${controller.value}',
                  ),
                  const SizedBox(height: 8),
                  NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                        MessageCodeUtil.SLIDE_TO_ADJUST_SIZE),
                    fontSize: 12,
                  ),
                  const SizedBox(height: 20),
                  Slider.adaptive(
                    value: controller.value,
                    min: 20,
                    max: 40,
                    divisions: 40,
                    autofocus: true,
                    label: controller.value.toString(),
                    thumbColor: ColorManagement.orangeColor,
                    activeColor: ColorManagement.orangeColor,
                    inactiveColor: ColorManagement.greyColor,
                    onChanged: (double newValue) {
                      controller.onChange(newValue);
                    },
                  ),
                  buildExample(controller),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                    margin: EdgeInsets.zero,
                    onPressed1: () async {
                      await controller
                          .save()
                          .then((value) => controller.rebuild());
                    },
                    icon1: Icons.save,
                    onPressed: controller.reset,
                    icon: Icons.restore_sharp,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildExample(SizeConfigController controller) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      child: Stack(
        children: [
          SizedBox(
            width: GeneralManager.cellWidth,
            height: controller.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: ColorManagement.emptyCellBackground,
                border:
                    Border.all(width: 0.2, color: ColorManagement.borderCell),
              ),
            ),
          ),
          Positioned(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
            height: controller.value - 6,
            width: GeneralManager.cellWidth - 6,
            child: Row(
              children: [
                //Bed
                Container(
                  alignment: Alignment.center,
                  width: GeneralManager.bedCellWidth,
                  color: BookingStatus.getBedNameColorByStatus(
                      BookingStatus.booked),
                  child: Text(
                    '?',
                    style: TextStyle(
                        color: ColorManagement.white,
                        fontSize: 10 + controller.value / 10,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none),
                  ),
                ),
                //Booking name
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 4),
                    color:
                        BookingStatus().getColorByStatus(BookingStatus.booked),
                    child: Text(
                      'OnePMS Booking demo',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BookingStatus.getBookingNameColorByStatus(
                            BookingStatus.booked),
                        fontSize: 10 + controller.value / 10,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
