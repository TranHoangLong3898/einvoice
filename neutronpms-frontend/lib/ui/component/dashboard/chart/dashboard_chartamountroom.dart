import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

class ChartRoomChargeAndAmoutRoom extends StatefulWidget {
  const ChartRoomChargeAndAmoutRoom({super.key});
  @override
  State<StatefulWidget> createState() => ChartRoomChargeAndAmoutRoomState();
}

class ChartRoomChargeAndAmoutRoomState
    extends State<ChartRoomChargeAndAmoutRoom> {
  final DashboardController? controller = DashboardController.instance;
  late double max, interval;
  late double min = 0;
  late List<BarChartGroupData> chartData;
  ScrollController categoryScroll = ScrollController();
  @override
  void initState() {
    chartData = controller!.getChartDataOfRoomCharge();
    super.initState();
  }

  void getDatas() {
    max = controller!.getMaxs();
    if (max == 0) {
      max = 10;
    }
    interval = (max - min) / 4;
  }

  @override
  Widget build(BuildContext context) {
    getDatas();
    return SizedBox(
      height: 450,
      width: double.infinity,
      child: RawScrollbar(
        thumbColor: Colors.black,
        controller: categoryScroll,
        child: ListView(
          controller: categoryScroll,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: controller!.indexTypeRoom.length >= 5
              ? Axis.horizontal
              : Axis.vertical,
          children: [
            Container(
              height: 450,
              width: controller!.indexTypeRoom.length == 5
                  ? controller!.indexTypeRoom.length * 230
                  : controller!.indexTypeRoom.length * 195,
              padding: const EdgeInsets.only(
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding * 2),
              decoration: BoxDecoration(
                color: ColorManagement.dashboardComponent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BarChart(
                BarChartData(
                  maxY: max,
                  minY: min,
                  groupsSpace: 15,
                  barTouchData: barTouchData,
                  titlesData: titlesData,
                  barGroups: chartData,
                  borderData: borderData,
                  gridData: gridData,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: const Color.fromARGB(0, 240, 239, 239),
            tooltipMargin: 0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                getToolTipMessage(group, groupIndex, rod, rodIndex)),
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        topTitles: topTitle,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: bottomTitles,
            reservedSize: 65,
          ),
        ),
        leftTitles: leftTitle,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  AxisTitles get topTitle {
    return AxisTitles(
        sideTitles: const SideTitles(showTitles: false),
        axisNameWidget: Column(
          children: [
            const SizedBox(height: 8),
            NeutronTextTitle(
              color: Colors.black,
              message: MessageUtil.getMessageByCode(
                  MessageCodeUtil.STATISTIC_REVENUE_BY_ROOM_TYPE),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: Colors.blue,
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 8),
                NeutronTextContent(
                  color: Colors.black,
                  message:
                      "${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE_BY_ROOM_TYPE)}: ${NumberUtil.moneyFormat.format(controller!.totalRevenueAndAmountRoom["revenue_roomtype"])}",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: ColorManagement.greenColor,
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 8),
                NeutronTextContent(
                  color: Colors.black,
                  message:
                      "${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_USED)}: ${controller!.totalRevenueAndAmountRoom["rooms_used"]}",
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: ColorManagement.orangeColor,
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 8),
                NeutronTextContent(
                  color: Colors.black,
                  message:
                      "${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_STILL_EMPTY)}: ${controller!.totalRevenueAndAmountRoom["rooms_available"]}",
                )
              ],
            )
          ],
        ),
        axisNameSize: 100);
  }

  FlBorderData get borderData => FlBorderData(
      show: true,
      border: const Border(
          top: BorderSide(
              color: Colors.black38, width: 0.5, style: BorderStyle.solid),
          bottom: BorderSide(color: ColorManagement.orangeColor, width: 0.5)));

  FlGridData get gridData => FlGridData(
      show: true,
      checkToShowVerticalLine: (v) => false,
      horizontalInterval: interval);

  BarTooltipItem getToolTipMessage(group, groupIndex, rod, rodIndex) =>
      BarTooltipItem(
          NumberUtil.moneyFormat.format(rod.toY),
          TextStyle(
              fontWeight: FontWeight.bold, color: rod.color, fontSize: 12));

  Widget bottomTitles(double value, TitleMeta meta) {
    final Widget text = SizedBox(
      width: 100,
      child: NeutronTextContent(
          textAlign: TextAlign.center,
          maxLines: 3,
          message: controller!.indexTypeRoom[value]!,
          color: const Color(0xff7589a2),
          fontSize: 14),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }
}
