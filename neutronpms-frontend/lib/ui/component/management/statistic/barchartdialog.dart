import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/statistic_controller.dart';
import 'package:ihotel/ui/component/management/statistic/detail/occupancydialog.dart';
import 'package:ihotel/ui/component/management/statistic/detail/piechartdetaidialog.dart';
import 'package:ihotel/ui/component/management/statistic/detail/revenuedetaildialog.dart';
import 'package:ihotel/ui/component/management/statistic/detail/statisticcountrydialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';

import 'detail/newbookingdialog.dart';

class BarChartDialog extends StatefulWidget {
  final StatisticController statisticController;
  const BarChartDialog({Key? key, required this.statisticController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartDialogState();
}

class BarChartDialogState extends State<BarChartDialog> {
  double min = 0;
  late StatisticController controller;
  late double max, interval;
  late int hoveredIndex, oldChartDataLength = -1;
  late bool isShowDetailTooltip;
  late List<BarChartGroupData> chartData;

  @override
  void initState() {
    controller = widget.statisticController;
    hoveredIndex = -1;
    isShowDetailTooltip = false;
    super.initState();
  }

  void getDatas() {
    min = controller.getMin();
    max = controller.getMax();
    if (max == 0) {
      max = 10;
    }
    interval = (max - min) / 4;
    chartData = controller.getChartData(hoveredIndex);
  }

  @override
  Widget build(BuildContext context) {
    getDatas();

    if (chartData.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }

    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: chartData,
        gridData: gridData,
        alignment: BarChartAlignment.spaceAround,
        maxY: max,
        minY: min,
      ),
      swapAnimationCurve: Curves.easeInCubic,
      swapAnimationDuration: const Duration(milliseconds: 0),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        allowTouchBarBackDraw: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: isShowDetailTooltip
              ? const Color.fromARGB(255, 201, 201, 201)
              : Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 4,
          tooltipRoundedRadius: 8,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
              controller.getTooltipMessage(group, groupIndex, rod, rodIndex,
                  hoveredIndex, isShowDetailTooltip),
        ),
        touchCallback: touchCallback,
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 5,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: controller.getBottomTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              axisSide: meta.axisSide,
              space: 4.0,
              child: Text(meta.formattedValue,
                  style: const TextStyle(
                      color: ColorManagement.lightColorText,
                      fontSize: 13,
                      overflow: TextOverflow.clip)),
            ),
          ),
        ),
        topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 12,
                getTitlesWidget: (v, m) => const Text(''))),
        rightTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) => const Text(''))),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
            top: BorderSide(color: ColorManagement.orangeColor, width: 0.5),
            bottom: BorderSide(color: ColorManagement.orangeColor, width: 0.5)),
      );

  FlGridData get gridData => FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: interval);

  void touchCallback(
      FlTouchEvent touchEvent, BarTouchResponse? barTouchResponse) {
    //click event
    if (handleClickEvent(touchEvent, barTouchResponse)) {
      return;
    }

    //hover event
    setState(() {
      if (!touchEvent.isInterestedForInteractions ||
          barTouchResponse == null ||
          barTouchResponse.spot == null) {
        hoveredIndex = -1;
        isShowDetailTooltip = false;
        return;
      }
      hoveredIndex = barTouchResponse.spot!.touchedBarGroupIndex;
      isShowDetailTooltip = controller.isShowDetailToolTip(
          hoveredIndex,
          barTouchResponse.spot!.touchedBarGroupIndex,
          barTouchResponse.spot!.touchedRodData);
    });
  }

  bool handleClickEvent(
      FlTouchEvent touchEvent, BarTouchResponse? barTouchResponse) {
    if (touchEvent is! FlTapUpEvent ||
        barTouchResponse?.spot?.touchedBarGroupIndex == null) {
      return false;
    }

    int index = barTouchResponse!.spot!.touchedBarGroupIndex;
    if (controller.selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      showDialog(
        context: context,
        builder: (context) =>
            OccupancyDialog(lstData: controller.displayData, index: index),
      );
      return true;
    } else if (controller.selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      var pickedItem = controller.displayData[index];
      showDialog(
          context: context,
          builder: (context) => RevenueDetailDialog(
              dailyData: pickedItem, isRevenueByDate: false));
      return true;
    } else if (controller.selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      var pickedItem = controller.displayData[index];
      showDialog(
          context: context,
          builder: (context) => RevenueDetailDialog(
              dailyData: pickedItem, isRevenueByDate: true));
      return true;
    } else if (controller.selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      var pickedItem = controller.displayData[index];
      showDialog(
          context: context,
          builder: (context) => RevenueDetailDialog(
              dailyData: pickedItem, isRevenueByDate: false));
      return true;
    } else if ((controller.selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_DEPOSIT) ||
            controller.selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_SERVICE)) &&
        controller.selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      //show piechart
      var pickedItem = controller.displayData[index];
      showDialog(
          context: context,
          builder: (context) => PieChartDetaiDialog(
                controller: controller,
                dailyData: pickedItem,
              ));
      return true;
    } else if (controller.selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_COUNTRY)) {
      var dailyData = controller.displayData[index];
      if (dailyData.country?.isEmpty ?? true) {
        return false;
      }
      showDialog(
        context: context,
        builder: (context) => StatisticCountryDialog(dailyData: dailyData),
      );
      return true;
    } else if (controller.selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NEW_BOOKING)) {
      var dailyData = controller.displayData[index];
      if (controller.bookings.isEmpty) {
        return false;
      }
      showDialog(
        context: context,
        builder: (context) => NewBookingDetailDialog(
            dailyData: dailyData, bookings: controller.bookings),
      );
      return true;
    }
    return false;
  }
}
