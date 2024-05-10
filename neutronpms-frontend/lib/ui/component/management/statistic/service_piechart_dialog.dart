import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/statistic_controller.dart';
import 'package:ihotel/ui/component/management/statistic/detail/chart_indicator.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';

class ServicePieChartDialog extends StatefulWidget {
  final StatisticController statisticController;
  const ServicePieChartDialog({Key? key, required this.statisticController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<ServicePieChartDialog> {
  late StatisticController controller;
  late List<PieChartSectionData> chartData;
  late List<Map<String, dynamic>> indicatorData;

  @override
  void initState() {
    controller = widget.statisticController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    chartData = controller.getPieCharDatas(null, context: context);
    indicatorData = controller.serviceComponents;

    if (chartData.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }

    return isMobile ? buildChartInMobile() : buildChartInPC();
  }

  Row buildChartInPC() {
    return Row(
      children: <Widget>[
        const SizedBox(height: 16),
        //chart
        Expanded(child: buildChart()),
        //note
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMobileWidth),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: indicatorData
                  .map(
                      (e) => ChartIndicator(color: e['color'], text: e['text']))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Column buildChartInMobile() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        //chart
        Expanded(child: buildChart()),
        const SizedBox(height: SizeManagement.rowSpacing),
        //note
        Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 8, 10),
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: indicatorData
                      .sublist(0, indicatorData.length ~/ 2)
                      .map((e) =>
                          ChartIndicator(color: e['color'], text: e['text']))
                      .toList(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: indicatorData
                      .sublist(indicatorData.length ~/ 2)
                      .map((e) =>
                          ChartIndicator(color: e['color'], text: e['text']))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  PieChart buildChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        startDegreeOffset: 0,
        sections: chartData,
      ),
      swapAnimationCurve: Curves.easeInCubic,
      swapAnimationDuration: const Duration(milliseconds: 200),
    );
  }
}
