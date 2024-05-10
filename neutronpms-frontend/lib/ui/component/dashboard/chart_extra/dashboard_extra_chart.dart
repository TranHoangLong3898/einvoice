import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/dashboard/chart_extra/dashboard_line_chart.dart';
import 'package:ihotel/ui/component/dashboard/chart_extra/dashboard_pie_serivce.dart';
import 'package:ihotel/util/designmanagement.dart';

class DashboardExtraChart extends StatelessWidget {
  const DashboardExtraChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 900) {
      return largeScreen;
    } else {
      return smallScreen;
    }
  }

  Widget get largeScreen => const Row(
        children: [
          Expanded(
            flex: 2,
            child: DashboardLineChart(),
          ),
          SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
          Expanded(
            child: DashboardPieChart(),
          ),
        ],
      );
  Widget get smallScreen => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DashboardLineChart(),
          SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
          DashboardPieChart(),
        ],
      );
}
