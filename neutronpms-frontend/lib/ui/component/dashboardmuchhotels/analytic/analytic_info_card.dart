import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class AnalyticInfoCard extends StatelessWidget {
  final Map<String, dynamic> infoStage;
  final Map<String, dynamic> infoDate;

  const AnalyticInfoCard(
      {Key? key, required this.infoStage, required this.infoDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600);
    const moneyStyle = TextStyle(
        color: Colors.black, fontSize: 17, fontWeight: FontWeight.w800);

    return InkWell(
      onTap: () =>
          DailyDataHotelsController.instance!.setType(infoStage['title']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: ColorManagement.dashboardComponent,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  infoStage['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  waitDuration: Duration(milliseconds: 20),
                  textStyle: TextStyle(fontSize: 13),
                  message: 'Click to see detail',
                  child: Icon(
                    FontAwesomeIcons.circleQuestion,
                    color: Colors.black87,
                    size: 16,
                  ),
                )
              ],
            ),
            const Divider(
                color: ColorManagement.orangeColor, thickness: 1.5, height: 2),
            Text(UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE),
                style: titleStyle),
            Text(NumberUtil.numberFormat.format(infoDate['amount']),
                style: moneyStyle),
            const Divider(
                color: Colors.black,
                thickness: 0.25,
                height: 4,
                indent: 20,
                endIndent: 20),
            Text(UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STAGE),
                style: titleStyle),
            Text(NumberUtil.numberFormat.format(infoStage['amount']),
                style: moneyStyle),
          ],
        ),
      ),
    );
  }
}
