import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';

class ProgressToday extends StatelessWidget {
  const ProgressToday({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double occupancyProgress =
        controller!.getProgressToday(MessageCodeUtil.STATISTIC_OCCUPANCY);
    double revenueProgress =
        controller!.getProgressToday(MessageCodeUtil.STATISTIC_REVENUE);
    double revenueByDateProgress =
        controller!.getProgressToday(MessageCodeUtil.STATISTIC_REVENUE_BY_DATE);
    double serviceProgress =
        controller!.getProgressToday(MessageCodeUtil.STATISTIC_SERVICE);
    double roomChargeProgress =
        controller!.getProgressToday(MessageCodeUtil.STATISTIC_ROOM_CHARGE);

    return Container(
      width: kMobileWidth,
      height: 180,
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
            MessageUtil.getMessageByCode(MessageCodeUtil.TODAY_PROGRESS),
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
          //occupancy
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_OCCUPANCY),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                '${(occupancyProgress * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: textStyle.copyWith(
                  color: occupancyProgress > 0
                      ? ColorManagement.positiveText
                      : ColorManagement.negativeText,
                ),
              )),
              const SizedBox(width: 4),
              occupancyProgress > 0 ? progressUpIcon : progressDownIcon,
            ],
          ),
          // revenue
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_REVENUE),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                '${(revenueProgress * 100).toStringAsFixed(1)}% ',
                textAlign: TextAlign.right,
                style: textStyle.copyWith(
                  color: revenueProgress > 0
                      ? ColorManagement.positiveText
                      : ColorManagement.negativeText,
                ),
              )),
              const SizedBox(width: 4),
              revenueProgress > 0 ? progressUpIcon : progressDownIcon,
            ],
          ),
          // revenue by date
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_REVENUE_BY_DATE),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                '${(revenueByDateProgress * 100).toStringAsFixed(1)}% ',
                textAlign: TextAlign.right,
                style: textStyle.copyWith(
                  color: revenueByDateProgress > 0
                      ? ColorManagement.positiveText
                      : ColorManagement.negativeText,
                ),
              )),
              const SizedBox(width: 4),
              revenueByDateProgress > 0 ? progressUpIcon : progressDownIcon,
            ],
          ),
          // service
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_SERVICE),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                '${(serviceProgress * 100).toStringAsFixed(1)}% ',
                textAlign: TextAlign.right,
                style: textStyle.copyWith(
                  color: serviceProgress > 0
                      ? ColorManagement.positiveText
                      : ColorManagement.negativeText,
                ),
              )),
              const SizedBox(width: 4),
              serviceProgress > 0 ? progressUpIcon : progressDownIcon,
            ],
          ),
          // room charge
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.STATISTIC_ROOM_CHARGE),
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                '${(roomChargeProgress * 100).toStringAsFixed(1)}% ',
                textAlign: TextAlign.right,
                style: textStyle.copyWith(
                  color: roomChargeProgress > 0
                      ? ColorManagement.positiveText
                      : ColorManagement.negativeText,
                ),
              )),
              const SizedBox(width: 4),
              roomChargeProgress > 0 ? progressUpIcon : progressDownIcon,
            ],
          ),
        ],
      ),
    );
  }

  DailyDataHotelsController? get controller =>
      DailyDataHotelsController.instance;

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
