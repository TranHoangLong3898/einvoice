import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboard_line_chart.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboard_pie_serivce.dart';
import 'package:ihotel/util/designmanagement.dart';

class DashboardMuchHotelsExtraChart extends StatelessWidget {
  const DashboardMuchHotelsExtraChart({Key? key}) : super(key: key);

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
            child: DashboardLineChartOfMuchHotels(),
          ),
          SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
          Expanded(
            child: DashboardPieChartOfMuchHotels(),
          ),
        ],
      );
  Widget get smallScreen => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DashboardLineChartOfMuchHotels(),
          SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
          DashboardPieChartOfMuchHotels(),
        ],
      );
}
