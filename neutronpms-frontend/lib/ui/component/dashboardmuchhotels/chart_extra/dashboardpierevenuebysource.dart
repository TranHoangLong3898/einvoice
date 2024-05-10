import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboard_pie_revenue_by_source.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class DashboardPieChartRevenueBySourceOfMuchHotels extends StatefulWidget {
  const DashboardPieChartRevenueBySourceOfMuchHotels({super.key});

  @override
  State<DashboardPieChartRevenueBySourceOfMuchHotels> createState() =>
      _DashboardPieChartRevenueBySourceOfMuchHotelsState();
}

class _DashboardPieChartRevenueBySourceOfMuchHotelsState
    extends State<DashboardPieChartRevenueBySourceOfMuchHotels> {
  final double height = 250.0;
  DailyDataHotelsController? controller;

  @override
  void initState() {
    controller = DailyDataHotelsController.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding,
          right: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Text(
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (1 > 0)
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                startDegreeOffset: 0,
                sections: controller!.getPieChartDataBySource(height / 2 - 20),
              ),
              swapAnimationCurve: Curves.easeInCubic,
              swapAnimationDuration: const Duration(milliseconds: 200),
            ),
          const Positioned(
            bottom: 10,
            right: 10,
            child: DashboardPieRevenueBySourceOfMuchHotels(),
          ),
        ],
      ),
    );
  }
}
