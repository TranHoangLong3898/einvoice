import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/analytic/analytic_cards.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart/dashboardmuchhotels_chart.dart';
// import 'package:ihotel/ui/component/dashboardmuchhotels/chart/dashboardmuchhotels_chartamountroom.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboard_extra_chart.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/dashboardmuchhotels_appbar.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/progress/right_content.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';

class DashboarMuchHotelsContent extends StatelessWidget {
  const DashboarMuchHotelsContent({Key? key, required this.controller})
      : super(key: key);
  final DailyDataHotelsController controller;
  @override
  Widget build(BuildContext context) {
    bool showRightContent = ResponsiveUtil.isDesktop(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        DashboardMuchHotelsAppbar(),
        const SizedBox(height: 12),
        Expanded(
          child: controller.totalData.isEmpty
              ? const Center(
                  child: Text(
                      "Bạn không phải là chủ và quản lý của khách sạn này"),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AnalyticCardsOfMuchHotels(),
                            SizedBox(
                                height: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            DashboarMuchHotelsChart(),
                            SizedBox(
                                height: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            DashboardMuchHotelsExtraChart(),
                            SizedBox(
                                height: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            // ChartRoomChargeAndAmoutRoomHotels()
                          ],
                        ),
                      ),
                    ),
                    if (showRightContent) const RightContentOfMuchHotels(),
                  ],
                ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
