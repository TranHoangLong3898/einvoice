import 'package:flutter/material.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/activity/dashboardmuchhotels_activity_item.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class DashboarMuchHotelsActivity extends StatelessWidget {
  const DashboarMuchHotelsActivity({Key? key}) : super(key: key);

  TextStyle get textStyle => const TextStyle(
      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ChangeNotifierProvider<ActivityController>.value(
        value: ActivityController(),
        child: Consumer<ActivityController>(
          builder: (_, controller, __) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ACTIVITIES),
                  style: textStyle,
                ),
              ),
              ...buildContent(controller),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildContent(ActivityController controller) {
    if (!GeneralManager().canReadActivity) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text(
            MessageUtil.getMessageByCode(
                MessageCodeUtil.PLEASE_UPDATE_PACKAGE_HOTEL),
            maxLines: 3,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        )
      ];
    }
    if (controller.activities!.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Text(
            MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA),
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        )
      ];
    }
    return [
      ...controller.activities!.keys
          .toList()
          .sublist(
              0,
              controller.activities!.length >= controller.endIndex
                  ? controller.endIndex
                  : controller.activities!.length)
          .map((idActivity) => DashboarMuchHotelsActivityItem(
              activity: controller.activities![idActivity]!))
          .toList(),
      const Divider(color: Colors.black54),
      Align(
        alignment: Alignment.bottomCenter,
        child: TextButton(
          onPressed: controller.nextPage,
          child: Text(
            UITitleUtil.getTitleByCode(UITitleCode.NOTIFICATION_SEE_MORE),
            style: textStyle,
          ),
        ),
      )
    ];
  }
}
