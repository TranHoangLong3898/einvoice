import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';

import '../../../../util/uimultilanguageutil.dart';

class DashboardPieRevenueBySource extends StatelessWidget {
  const DashboardPieRevenueBySource({Key? key}) : super(key: key);

  DashboardController? get controller => DashboardController.instance;

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);

    return PopupMenuButton(
      itemBuilder: (context) => controller!.dataRevenue.keys
          .map(
            (e) => PopupMenuItem(
              height: 30,
              enabled: false,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(color: Colors.black, fontSize: 13),
              child: ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller!.dataRevenue[e]!['color']),
                ),
                title: Text(SourceManager().getSourceNameByID(e)),
                trailing: Text(NumberUtil.moneyFormat
                    .format(controller!.dataRevenue[e]!['revenue'])),
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
