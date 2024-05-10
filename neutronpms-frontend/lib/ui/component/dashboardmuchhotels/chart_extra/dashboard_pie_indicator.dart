import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';

import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';

import '../../../../util/uimultilanguageutil.dart';

class DashboardPieIndicatorOfMucHotels extends StatelessWidget {
  const DashboardPieIndicatorOfMucHotels({Key? key}) : super(key: key);

  DailyDataHotelsController? get controller =>
      DailyDataHotelsController.instance;

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);

    return PopupMenuButton(
      itemBuilder: (context) => controller!.serviceComponents
          .map(
            (e) => PopupMenuItem(
              height: 30,
              enabled: false,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(color: Colors.white, fontSize: 13),
              child: ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: e['color']),
                ),
                title: Text(e['text'].toString()),
                titleTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 13),
                trailing: Text(NumberUtil.moneyFormat.format(e['value'])),
              ),
            ),
          )
          .toList(),
      icon: const Icon(Icons.notes_rounded, color: Colors.black),
      color: ColorManagement.lightMainBackground,
      tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SHOW_DETAI),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      offset: isMobile ? const Offset(-100, -650) : const Offset(-300, 0),
      padding: EdgeInsets.zero,
    );
  }
}
