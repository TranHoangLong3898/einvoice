// ignore_for_file: must_be_immutable

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/adminmanager/hotelstatisticcontroller.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:provider/provider.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondropdown.dart';

class HotelStatisticDialog extends StatelessWidget {
  HotelStatisticController controller = HotelStatisticController();
  late List<BarChartGroupData> chartData;
  HotelStatisticDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final num width = MediaQuery.of(context).size.width;
    final num height = MediaQuery.of(context).size.height;
    final isVerticalBarchart = width > height;
    return Scaffold(
      appBar: AppBar(
        title: NeutronTextContent(
          message:
              UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_HOTEL_STATISTICS),
        ),
      ),
      backgroundColor: ColorManagement.lightMainBackground,
      body: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<HotelStatisticController>(
          builder: (_, controller, __) {
            if (controller.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                color: ColorManagement.greenColor,
              ));
            }
            chartData = controller.getChartData();
            Map<String, String>? title = controller.getTitle();
            return Container(
              margin: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: NeutronDropDown(
                          items: controller.years.toList(),
                          value: controller.selectYear,
                          onChanged: (value) {
                            controller.setYear(value);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: NeutronDropDown(
                          items: controller.months,
                          value: controller.selectMonth,
                          onChanged: (String value) {
                            controller.setMonth(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (title != null)
                    NeutronTextContent(message: title['hotels']!),
                  if (title != null)
                    NeutronTextContent(message: title['users']!),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                      child: chartData.isEmpty
                          ? Center(
                              child: NeutronTextContent(
                                  message: MessageUtil.getMessageByCode(
                                      MessageCodeUtil.NO_DATA)))
                          : RotatedBox(
                              quarterTurns: isVerticalBarchart ? 0 : -45,
                              child: BarChart(
                                BarChartData(
                                  barTouchData: barTouchData,
                                  titlesData: titlesData,
                                  borderData: borderData,
                                  barGroups: chartData,
                                  gridData: gridData,
                                  alignment: BarChartAlignment.spaceAround,
                                ),
                                swapAnimationCurve: Curves.easeInCubic,
                                swapAnimationDuration:
                                    const Duration(milliseconds: 0),
                              ),
                            )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
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
            // interval: 20.0,
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
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 0,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
            top: BorderSide(color: ColorManagement.orangeColor, width: 0.5),
            bottom: BorderSide(color: ColorManagement.orangeColor, width: 0.5)),
      );

  FlGridData get gridData => const FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
      );
}
