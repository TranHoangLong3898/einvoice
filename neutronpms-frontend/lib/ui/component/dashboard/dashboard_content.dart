import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/dashboard/analytic/analytic_cards.dart';
import 'package:ihotel/ui/component/dashboard/chart/dashboard_chart.dart';
import 'package:ihotel/ui/component/dashboard/chart/dashboard_chartamountroom.dart';
import 'package:ihotel/ui/component/dashboard/chart_extra/dashboard_extra_chart.dart';
import 'package:ihotel/ui/component/dashboard/dashboard_appbar.dart';
import 'package:ihotel/ui/component/dashboard/progress/right_content.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showRightContent = ResponsiveUtil.isDesktop(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        const DashboardAppbar(),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnalyticCards(),
                      SizedBox(
                          height: SizeManagement.cardOutsideHorizontalPadding),
                      DashboardChart(),
                      SizedBox(
                          height: SizeManagement.cardOutsideHorizontalPadding),
                      DashboardExtraChart(),
                      SizedBox(
                          height: SizeManagement.cardOutsideHorizontalPadding),
                      ChartRoomChargeAndAmoutRoom()
                    ],
                  ),
                ),
              ),
              if (showRightContent) const RightContent(),
            ],
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
