import 'package:flutter/material.dart';
import 'package:ihotel/modal/activity.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';

class DashboarMuchHotelsActivityItem extends StatelessWidget {
  const DashboarMuchHotelsActivityItem({Key? key, required this.activity})
      : super(key: key);

  final Activity activity;

  TextStyle get style => const TextStyle(
      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin:
          const EdgeInsets.only(top: SizeManagement.cardOutsideVerticalPadding),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: const BoxDecoration(
          border: Border(
        top: BorderSide(width: 0.2, color: Colors.black),
      )),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //description
          Container(
            margin:
                const EdgeInsets.symmetric(vertical: SizeManagement.rowSpacing),
            alignment: Alignment.topLeft,
            child: Tooltip(
              message: activity.decodeDesc(),
              waitDuration: const Duration(milliseconds: 300),
              child: Text(
                activity.decodeDesc(),
                style: style,
                textAlign: TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          //created time
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              DateUtil.getDifferenceFromNow(activity.createdTime.toDate()),
              textAlign: TextAlign.right,
              style: style.copyWith(
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }
}
