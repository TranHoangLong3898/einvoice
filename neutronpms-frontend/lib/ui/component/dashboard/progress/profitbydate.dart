import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class ProfitByDate extends StatelessWidget {
  const ProfitByDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> analyticDataRevuneAndCostStage =
        DashboardController.instance!.getDataRevuneAndCostOfStage();
    return Container(
      width: kMobileWidth,
      height: 160,
      margin: const EdgeInsets.only(
          right: SizeManagement.cardOutsideHorizontalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorManagement.dashboardComponent,
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 4),
          Text(
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PROFIT),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 17),
          ),
          const Divider(
            color: ColorManagement.orangeColor,
            thickness: 1.5,
            height: 2,
            endIndent: 16,
            indent: 16,
          ),
          // revenue
          Row(
            children: [
              Expanded(
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_REVENUE),
                  style: textStyle,
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    NumberUtil.numberFormat
                        .format(analyticDataRevuneAndCostStage['revenue']),
                    textAlign: TextAlign.right,
                    style: textStyle.copyWith(
                      color: analyticDataRevuneAndCostStage['revenue']! > 0
                          ? ColorManagement.positiveText
                          : ColorManagement.negativeText,
                    ),
                  )),
              const SizedBox(width: 4),
              analyticDataRevuneAndCostStage['revenue']! > 0
                  ? progressUpIcon
                  : progressDownIcon,
            ],
          ),
          // Accouting
          Row(
            children: [
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_COST),
                  style: textStyle,
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    NumberUtil.numberFormat
                        .format(analyticDataRevuneAndCostStage['cost']),
                    textAlign: TextAlign.right,
                    style: textStyle.copyWith(
                      color: analyticDataRevuneAndCostStage['cost']! > 0
                          ? ColorManagement.positiveText
                          : ColorManagement.negativeText,
                    ),
                  )),
              const SizedBox(width: 4),
              analyticDataRevuneAndCostStage['cost']! > 0
                  ? progressUpIcon
                  : progressDownIcon,
            ],
          ),
          // profit
          Row(
            children: [
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PROFIT),
                  style: textStyle,
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    NumberUtil.numberFormat.format(
                        analyticDataRevuneAndCostStage['revenue']! -
                            analyticDataRevuneAndCostStage['cost']!),
                    textAlign: TextAlign.right,
                    style: textStyle.copyWith(
                      color: (analyticDataRevuneAndCostStage['revenue']! -
                                  analyticDataRevuneAndCostStage['cost']!) >
                              0
                          ? ColorManagement.positiveText
                          : ColorManagement.negativeText,
                    ),
                  )),
              const SizedBox(width: 4),
              (analyticDataRevuneAndCostStage['revenue']! -
                          analyticDataRevuneAndCostStage['cost']!) >
                      0
                  ? progressUpIcon
                  : progressDownIcon,
            ],
          ),
        ],
      ),
    );
  }

  DashboardController? get controller => DashboardController.instance;

  TextStyle get textStyle => const TextStyle(color: Colors.black, fontSize: 15);

  Widget get progressUpIcon => const Icon(
        FontAwesomeIcons.arrowTrendUp,
        color: ColorManagement.positiveText,
        size: 14,
      );

  Widget get progressDownIcon => const Icon(
        FontAwesomeIcons.arrowTrendDown,
        color: ColorManagement.negativeText,
        size: 14,
      );
}
