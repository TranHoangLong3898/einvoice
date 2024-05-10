import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboard_pie_indicator.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../../../util/messageulti.dart';

class DashboardPieChartOfMuchHotels extends StatefulWidget {
  const DashboardPieChartOfMuchHotels({Key? key}) : super(key: key);

  @override
  State<DashboardPieChartOfMuchHotels> createState() =>
      _DashboardPieChartOfMuchHotelsState();
}

class _DashboardPieChartOfMuchHotelsState
    extends State<DashboardPieChartOfMuchHotels> {
  final double height = 300.0;
  DailyDataHotelsController? controller;

  @override
  void initState() {
    controller = DailyDataHotelsController.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double totalValue =
        controller!.serviceComponents.fold(0, (p, e) => p + e['value']);
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
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (totalValue > 0)
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                startDegreeOffset: 0,
                sections: controller!.getPieChartData(height / 2 - 20),
              ),
              swapAnimationCurve: Curves.easeInCubic,
              swapAnimationDuration: const Duration(milliseconds: 200),
            ),
          const Positioned(
            bottom: 10,
            right: 10,
            child: DashboardPieIndicatorOfMucHotels(),
          ),
        ],
      ),
    );
  }
}
