import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:provider/provider.dart';

class DashboardChart extends StatefulWidget {
  const DashboardChart({Key? key}) : super(key: key);

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  final DashboardController? controller = DashboardController.instance;
  final DashboardChartController chartController = DashboardChartController();
  int hoveredIndex = -1;
  late double max, min, interval;

  @override
  void initState() {
    controller!.setChartController(chartController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding,
          right: SizeManagement.cardOutsideHorizontalPadding * 2),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ChangeNotifierProvider.value(
        value: chartController,
        child: Consumer<DashboardChartController>(
            builder: (_, chartController, __) {
          getMinMaxOfChart();
          return BarChart(
            BarChartData(
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    tooltipMargin: 4,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        getToolTipMessage(group, groupIndex, rod, rodIndex),
                  ),
                  touchCallback: (touchEvent, barTouchResponse) =>
                      handleHoverEvent(touchEvent, barTouchResponse),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: const Border(
                        top: BorderSide(
                            color: Colors.black38,
                            width: 0.5,
                            style: BorderStyle.solid),
                        bottom: BorderSide(
                            color: ColorManagement.orangeColor, width: 0.5))),
                gridData: FlGridData(
                    show: true,
                    checkToShowVerticalLine: (v) => false,
                    horizontalInterval: interval),
                groupsSpace: 15,
                maxY: max,
                minY: min,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: bottomTitle,
                  leftTitles: leftTitle,
                  topTitles: topTitle,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: controller!.getChartData(
                    hoveredIndex, ResponsiveUtil.isMobile(context))),
            swapAnimationDuration: const Duration(milliseconds: 300),
          );
        }),
      ),
    );
  }

  void getMinMaxOfChart() {
    min = controller!.getMin();
    max = controller!.getMax();
    if (max == min) {
      max = min + 100;
    }
    interval = (max - min) / 4;
  }

  AxisTitles get bottomTitle => AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, meta) => Text(
                  ResponsiveUtil.isMobile(context) && value % 2 == 0
                      ? ''
                      : meta.formattedValue,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                )),
      );

  AxisTitles get leftTitle => AxisTitles(
      sideTitles: SideTitles(
          showTitles: true,
          interval: interval,
          reservedSize: 40,
          getTitlesWidget: (double value, meta) => Text(
                meta.formattedValue,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              )));

  AxisTitles get topTitle => AxisTitles(
      sideTitles: const SideTitles(showTitles: false),
      axisNameWidget: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: controller!.selectedType,
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              if (controller!.selectedType ==
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_REVENUE))
                const TextSpan(
                  text: '',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                )
            ]),
      ),
      axisNameSize: 50);

  BarTooltipItem getToolTipMessage(group, groupIndex, rod, rodIndex) {
    DateTime hoveredDate = controller!.getDateByChartIndex(groupIndex);
    return BarTooltipItem(
        '${DateUtil.dateToDayMonthString(hoveredDate)}\n---\n${NumberUtil.moneyFormat.format(rod.toY)}',
        const TextStyle(color: Colors.white, fontSize: 12));
  }

  void handleHoverEvent(
      FlTouchEvent touchEvent, BarTouchResponse? barTouchResponse) {
    if (!touchEvent.isInterestedForInteractions ||
        barTouchResponse == null ||
        barTouchResponse.spot == null) {
      hoveredIndex = -1;
    } else {
      hoveredIndex = barTouchResponse.spot!.touchedBarGroupIndex;
    }
    chartController.rebuild();
  }
}

//this class is only for rebuild dashboard chart
class DashboardChartController extends ChangeNotifier {
  DashboardChartController();

  void rebuild() {
    notifyListeners();
  }
}
