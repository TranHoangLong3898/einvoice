import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';

class DashboardLineChartOfMuchHotels extends StatefulWidget {
  const DashboardLineChartOfMuchHotels({Key? key}) : super(key: key);

  @override
  State<DashboardLineChartOfMuchHotels> createState() =>
      _DashboardLineChartOfMuchHotelsState();
}

class _DashboardLineChartOfMuchHotelsState
    extends State<DashboardLineChartOfMuchHotels> {
  DailyDataHotelsController? controller = DailyDataHotelsController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding,
          right: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: controller!.getLineChartData(),
          titlesData: titleData,
          borderData: borderData,
          lineTouchData: lineTouchData,
          gridData: gridData,
          clipData: const FlClipData.all(),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      ),
    );
  }

  TextStyle get titleStyle => const TextStyle(
      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600);

  FlTitlesData get titleData => FlTitlesData(
        topTitles: AxisTitles(
          axisNameSize: 15,
          axisNameWidget: Text(
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_REVENUE_BY_CHECKOUT_DATE),
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          sideTitles: const SideTitles(showTitles: false),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 30,
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              meta.formattedValue,
              textAlign: TextAlign.center,
              style: NeutronTextStyle.content
                  .copyWith(fontSize: 11, color: Colors.black),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (double value, meta) => Text(
                      ResponsiveUtil.isMobile(context) && value % 2 == 0
                          ? ''
                          : meta.formattedValue,
                      style: NeutronTextStyle.content
                          .copyWith(fontSize: 12, color: Colors.black),
                    ))),
      );

  FlBorderData get borderData => FlBorderData(
          border: const Border(
        left: BorderSide(color: Colors.black54, width: 0.5),
        bottom: BorderSide(color: Colors.black54, width: 0.5),
      ));

  LineTouchData get lineTouchData => LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideVertically: true,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return [
              LineTooltipItem(
                NumberUtil.moneyFormat.format(controller!
                    .totalData[touchedSpots.first.spotIndex]
                    .getRevenue()),
                titleStyle.copyWith(color: Colors.white),
              )
            ];
          },
        ),
      );

  FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
              color: Colors.black, dashArray: [15, 15], strokeWidth: 0.5);
        },
      );
}
