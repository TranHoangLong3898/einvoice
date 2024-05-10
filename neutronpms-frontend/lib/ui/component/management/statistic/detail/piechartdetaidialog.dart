import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../../../../controller/management/statistic_controller.dart';
import '../../../../../modal/dailydata.dart';
import '../../../../../util/dateutil.dart';
import '../../../../controls/neutrontextheader.dart';
import 'chart_indicator.dart';

class PieChartDetaiDialog extends StatelessWidget {
  final StatisticController controller;
  final DailyData dailyData;

  const PieChartDetaiDialog({
    Key? key,
    required this.controller,
    required this.dailyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double minEdge = screenWidth > screenHeight ? screenHeight : screenWidth;
    double dialogWidth = minEdge - 100;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: dialogWidth,
        height: dialogWidth,
        child: Column(
          children: [
            NeutronTextHeader(
              message: DateUtil.dateToString(dailyData.dateFull!),
            ),
            Expanded(
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  startDegreeOffset: 0,
                  sections:
                      controller.getPieChartOfDate(dailyData, dialogWidth),
                ),
                swapAnimationCurve: Curves.easeInCubic,
                swapAnimationDuration: const Duration(milliseconds: 200),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 8, 10),
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller
                          .getDataOfDate(dailyData)
                          .sublist(0,
                              controller.getDataOfDate(dailyData).length ~/ 2)
                          .map((e) => ChartIndicator(
                              color: e['color'], text: e['text']))
                          .toList(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller
                          .getDataOfDate(dailyData)
                          .sublist(
                              controller.getDataOfDate(dailyData).length ~/ 2)
                          .map((e) => ChartIndicator(
                              color: e['color'], text: e['text']))
                          .toList(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
