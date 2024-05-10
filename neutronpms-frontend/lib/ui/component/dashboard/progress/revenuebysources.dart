import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class RevenueBySource extends StatelessWidget {
  const RevenueBySource({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, double> analyticDataRevuneBySource =
        DashboardController.instance!.getDataRevuneBySource();
    Map<String, double> analyticDataRevuneAndCostStage =
        DashboardController.instance!.getDataRevuneAndCostOfStage();
    return Container(
      width: kMobileWidth,
      height: 200,
      margin: const EdgeInsets.only(
          right: SizeManagement.cardOutsideHorizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
      ),
      child: SingleChildScrollView(
        child: DataTable(
            columnSpacing: 8,
            horizontalMargin: 16,
            columns: [
              DataColumn(
                  label: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
                color: ColorManagement.textBlack,
              )),
              DataColumn(
                  label: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE),
                color: ColorManagement.textBlack,
              )),
              DataColumn(
                  label: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PERCENT),
                color: ColorManagement.textBlack,
              )),
            ],
            rows: analyticDataRevuneBySource.keys
                .map(
                  (e) => DataRow(cells: [
                    DataCell(NeutronTextContent(
                      message: SourceManager().getSourceNameByID(e),
                      color: ColorManagement.textBlack,
                    )),
                    DataCell(NeutronTextContent(
                      message: NumberUtil.numberFormat
                          .format(analyticDataRevuneBySource[e]),
                      color: ColorManagement.textBlack,
                    )),
                    DataCell(NeutronTextContent(
                      message:
                          " ${(analyticDataRevuneBySource[e] ?? 0) == 0 ? "0" : NumberUtil.moneyFormat.format(((analyticDataRevuneBySource[e] ?? 0) / analyticDataRevuneAndCostStage["revenue"]!) * 100)} %",
                      color: ColorManagement.textBlack,
                    )),
                  ]),
                )
                .toList()),
      ),
    );
  }
}
