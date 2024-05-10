import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../util/messageulti.dart';

class ElectricityWaterHotelServiceDialog extends StatefulWidget {
  const ElectricityWaterHotelServiceDialog({Key? key}) : super(key: key);

  @override
  State<ElectricityWaterHotelServiceDialog> createState() =>
      _ListOtherHotelServiceState();
}

class _ListOtherHotelServiceState
    extends State<ElectricityWaterHotelServiceDialog> {
  late ConfigurationManagement controller;

  @override
  void initState() {
    controller = ConfigurationManagement();
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    // final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider<ConfigurationManagement>.value(
        value: controller,
        child: Consumer<ConfigurationManagement>(builder: (_, controller, __) {
          if (controller.isInProgress) {
            return const Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor));
          }
          return Stack(children: [
            Container(
                margin: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    const SizedBox(
                      height: SizeManagement.topHeaderTextSpacing,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ELECTRICITY),
                              fontSize: 14,
                            ),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_WATER),
                              fontSize: 14,
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: controller.electricityWater["electricity"]!
                                .buildWidget(
                                    color: ColorManagement.lightMainBackground),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: controller.electricityWater["water"]!
                                .buildWidget(
                                    color: ColorManagement.lightMainBackground),
                          )),
                        ],
                      ),
                    ),
                  ],
                )),
            //add-button
            Align(
              alignment: Alignment.bottomCenter,
              child: NeutronButton(
                icon1: Icons.save,
                onPressed1: () async {
                  await controller
                      .createElectricityWaterHotelService()
                      .then((result) {
                    if (result != MessageCodeUtil.SUCCESS) {
                      MaterialUtil.showResult(context, result);
                    }
                  });
                },
              ),
            )
          ]);
        }));
  }
}
