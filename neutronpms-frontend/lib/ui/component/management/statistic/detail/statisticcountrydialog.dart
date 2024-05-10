import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/dailydata.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';

class StatisticCountryDialog extends StatelessWidget {
  const StatisticCountryDialog({Key? key, required this.dailyData})
      : super(key: key);

  final DailyData dailyData;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: SizeManagement.topHeaderTextSpacing),
              alignment: Alignment.center,
              child: NeutronTextHeader(
                message: DateUtil.dateToString(dailyData.dateFull!),
              ),
            ),
            DataTable(
              headingRowHeight: 0,
              columnSpacing: 3,
              columns: const [
                DataColumn(label: Text('')),
                DataColumn(label: Text('')),
              ],
              rows: dailyData.country?.entries
                      .map(
                        (e) => DataRow(cells: [
                          DataCell(
                            NeutronTextContent(message: e.key),
                          ),
                          DataCell(
                            NeutronTextContent(
                              message: e.value.toString(),
                              color: e.key == 'unknown'
                                  ? ColorManagement.negativeText
                                  : ColorManagement.positiveText,
                            ),
                          ),
                        ]),
                      )
                      .toList() ??
                  [],
            ),
            const SizedBox(height: SizeManagement.topHeaderTextSpacing)
          ],
        ),
      ),
    );
  }
}
