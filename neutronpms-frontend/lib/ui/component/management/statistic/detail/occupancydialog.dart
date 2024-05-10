import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/dailydata.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class OccupancyDialog extends StatefulWidget {
  final List<DailyData> lstData;
  final int index;

  const OccupancyDialog({Key? key, required this.lstData, required this.index})
      : super(key: key);

  @override
  State<OccupancyDialog> createState() => _OccupancyDialogState();
}

class _OccupancyDialogState extends State<OccupancyDialog> {
  late DailyData dailyData;

  @override
  void initState() {
    dailyData = widget.lstData[widget.index];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    num occupancy = dailyData.night /
        (RoomManager().rooms!.length * widget.lstData.length) *
        100;
    num occupancyInDay = dailyData.night / RoomManager().rooms!.length * 100;
    num averageRate = dailyData.roomCharge / dailyData.night;
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
            DataTable(headingRowHeight: 0, columnSpacing: 3, columns: [
              DataColumn(label: Container()),
              DataColumn(label: Container()),
            ], rows: [
              //room
              DataRow(cells: [
                DataCell(
                  NeutronTextContent(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_ROOMS),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    message: dailyData.night.toString(),
                  ),
                ),
              ]),
              //occupancy
              DataRow(cells: [
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.HEADER_OCCUPANCY),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    message: '${NumberUtil.numberFormat.format(occupancy)}%',
                  ),
                )
              ]),
              //occupancy in day
              DataRow(cells: [
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.HEADER_OCCUPANCY_IN_DAY),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    message:
                        '${NumberUtil.numberFormat.format(occupancyInDay)}%',
                  ),
                )
              ]),
              //room charge
              DataRow(cells: [
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message:
                        NumberUtil.numberFormat.format(dailyData.roomCharge),
                  ),
                )
              ]),
              //average
              DataRow(cells: [
                DataCell(
                  NeutronTextContent(
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_AVERAGE),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                      color: ColorManagement.positiveText,
                      message: NumberUtil.numberFormat.format(averageRate)),
                )
              ]),
            ]),
            const SizedBox(height: SizeManagement.topHeaderTextSpacing)
          ],
        ),
      ),
    );
  }
}
