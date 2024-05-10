import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/housekeeping/nextweekchartcontroller.dart';
import '../../../util/designmanagement.dart';

class NextWeekChartDialog extends StatelessWidget {
  const NextWeekChartDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        width: kMobileWidth,
        height: 500,
        padding: const EdgeInsets.all(10),
        child: ChangeNotifierProvider.value(
          value: NextWeekChartController(),
          child: Consumer<NextWeekChartController>(
            builder: (_, controller, __) {
              double max = controller.getMax();
              double interval = (max ~/ 4).toDouble();

              return BarChart(
                BarChartData(
                  barGroups: controller.getChartData(),
                  maxY: max,
                  minY: 0,
                  borderData: borderData,
                  barTouchData: barTouchData,
                  backgroundColor: ColorManagement.lightMainBackground,
                  gridData: buildGridData(interval),
                  titlesData: buildTitleData(interval),
                ),
                swapAnimationDuration: const Duration(milliseconds: 200),
              );
            },
          ),
        ),
      ),
    );
  }

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: ColorManagement.orangeColor, width: 1),
        ),
      );

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipMargin: -8,
          getTooltipItem: (_, __, rod, rodIndex) => BarTooltipItem(
            rod.toY.toInt().toString(),
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );

  FlGridData buildGridData(double interval) => FlGridData(
        show: true,
        checkToShowVerticalLine: (v) => false,
        horizontalInterval: interval,
      );

  FlTitlesData buildTitleData(double interval) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 15,
            getTitlesWidget: (double value, meta) => Text(
              meta.formattedValue,
              style: NeutronTextStyle.content,
            ),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 24,
            getTitlesWidget: (double value, meta) => Text(
              meta.formattedValue,
              style: NeutronTextStyle.content,
            ),
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: const SideTitles(showTitles: false),
          axisNameSize: 35,
          axisNameWidget: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_NEXT_WEEK_CHART),
              style: NeutronTextStyle.title.copyWith(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );
}
