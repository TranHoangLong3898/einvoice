import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/statistic_controller.dart';
import 'package:ihotel/enum.dart';
import 'package:ihotel/ui/component/management/statistic/barchartdialog.dart';
import 'package:ihotel/ui/component/management/statistic/service_piechart_dialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class StatisticDialog extends StatefulWidget {
  const StatisticDialog({Key? key}) : super(key: key);

  @override
  State<StatisticDialog> createState() => _StatisticDialogState();
}

class _StatisticDialogState extends State<StatisticDialog> {
  final StatisticController statisticController = StatisticController();
  final DateTime now = Timestamp.now().toDate();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final num width = MediaQuery.of(context).size.width;
    final num height = MediaQuery.of(context).size.height;
    final isVerticalBarchart = width > height;

    return ChangeNotifierProvider<StatisticController>.value(
      key: widget.key,
      value: statisticController,
      child: Consumer<StatisticController>(
        child: const Center(
          child: CircularProgressIndicator(color: ColorManagement.greenColor),
        ),
        builder: (_, controller, child) {
          return Scaffold(
            appBar: buildAppBar(isMobile),
            backgroundColor: ColorManagement.lightMainBackground,
            body: Card(
              margin: const EdgeInsets.all(10),
              elevation: 10,
              color: ColorManagement.mainBackground,
              shadowColor: Colors.white30,
              child: controller.isLoading
                  ? child
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildFilter(),
                        ...controller
                            .getDescription()
                            .map((desc) => Center(
                                child: NeutronTextContent(message: desc)))
                            .toList(),
                        Expanded(
                            child: controller.chartType == ChartType.bar
                                ? RotatedBox(
                                    quarterTurns: isVerticalBarchart ? 0 : -45,
                                    child: BarChartDialog(
                                        statisticController:
                                            statisticController),
                                  )
                                : ServicePieChartDialog(
                                    statisticController: statisticController))
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(bool isMobile) => AppBar(
        title: NeutronTextContent(
            message: isMobile
                ? ''
                : UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_STATISTIC)),
        actions: [
          SizedBox(
            width: isMobile ? 100 : 150,
            child: NeutronDatePicker(
              // formatDate: isMobile ? DateUtil.dateToDayMonthString : null,
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
              initialDate: statisticController.startDate,
              firstDate: now.subtract(const Duration(days: 365)),
              lastDate: now.add(const Duration(days: 365)),
              onChange: (picked) {
                statisticController.setStartDate(picked);
              },
            ),
          ),
          SizedBox(
            width: isMobile ? 100 : 150,
            child: NeutronDatePicker(
              // formatDate: isMobile ? DateUtil.dateToDayMonthString : null,
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
              initialDate: statisticController.endDate,
              firstDate: statisticController.startDate,
              lastDate: now.add(const Duration(days: 365)),
              onChange: (picked) {
                statisticController.setEndDate(picked);
              },
            ),
          ),
          //refresh
          IconButton(
            constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
            icon: const Icon(Icons.refresh),
            onPressed: () {
              statisticController.update();
            },
          )
        ],
      );

  Widget buildFilter() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //select type
            SizedBox(
              width: 160,
              child: NeutronDropDown(
                focusColor: ColorManagement.lightMainBackground,
                items: statisticController.types,
                value: statisticController.selectedType,
                onChanged: (value) {
                  statisticController.setType(value);
                },
              ),
            ),
            if (statisticController.subTypes1.isNotEmpty)
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            // select sub type 1
            if (statisticController.subTypes1.length > 2)
              SizedBox(
                width: 160,
                child: NeutronDropDown(
                  focusColor: ColorManagement.lightMainBackground,
                  items: statisticController.subTypes1,
                  value: statisticController.selectedSubType1,
                  onChanged: (value) {
                    statisticController.setSubType1(value);
                  },
                ),
              ),
            if (statisticController.subTypes2.isNotEmpty)
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            //select sub type 2
            if (statisticController.subTypes2.isNotEmpty)
              SizedBox(
                width: 120,
                child: NeutronDropDown(
                  focusColor: ColorManagement.lightMainBackground,
                  items: statisticController.subTypes2,
                  value: statisticController.selectedSubType2,
                  onChanged: (value) {
                    statisticController.setSubType2(value);
                  },
                ),
              ),
            //select sub type 3
            if (statisticController.subTypes3.isNotEmpty)
              SizedBox(
                width: 120,
                child: NeutronDropDown(
                  focusColor: ColorManagement.lightMainBackground,
                  items: statisticController.subTypes3,
                  value: statisticController.selectedSubType3,
                  onChanged: (value) {
                    statisticController.setSubType3(value);
                  },
                ),
              ),

            if (statisticController.selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_SERVICE) &&
                statisticController.selectedSubType1 ==
                    MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL))
              SizedBox(
                  width: 50,
                  child: IconButton(
                    tooltip: statisticController.chartType == ChartType.pie
                        ? UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_SWAP_BAR_CHART)
                        : UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_SWAP_PIE_CHART),
                    icon: const Icon(
                      Icons.swap_calls,
                      color: ColorManagement.white,
                    ),
                    onPressed: () {
                      statisticController.swapChartType();
                    },
                  )),
            if (statisticController.selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_REVENUE) ||
                statisticController.selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_REVENUE_BY_DATE) ||
                statisticController.selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_ROOM_CHARGE) ||
                statisticController.selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_GUEST))
              Container(
                height: 45,
                alignment: Alignment.center,
                child: NeutronBlurButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                  icon: Icons.file_present_rounded,
                  onPressed: () async {
                    ExcelUlti.exportRevenueStatistic(statisticController);
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
