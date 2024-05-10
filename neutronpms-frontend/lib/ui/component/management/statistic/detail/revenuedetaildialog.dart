import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/dailydata.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class RevenueDetailDialog extends StatelessWidget {
  final DailyData dailyData;
  final bool isRevenueByDate;

  const RevenueDetailDialog(
      {Key? key, required this.dailyData, required this.isRevenueByDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomCharge = isRevenueByDate
        ? dailyData.roomCharge
        : dailyData.getRevenueRoomCharge();
    final service = isRevenueByDate
        ? dailyData.totalService
        : dailyData.getRevenueService();
    final liquidation = dailyData.getRevenueLiquidation();
    final discount =
        isRevenueByDate ? dailyData.discount : dailyData.getRevenueDiscount();
    final total = roomCharge + service + liquidation - discount;

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
            DataTable(headingRowHeight: 0, columnSpacing: 0, columns: const [
              // DataColumn(label: SizedBox(width: 12)),
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
            ], rows: [
              //Room charge
              DataRow(cells: [
                // DataCell(Container(
                //   width: 10,
                //   height: 10,
                //   color: ColorManagement.deepBlueColor,
                // )),
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(roomCharge),
                  ),
                ),
              ]),
              //service
              DataRow(cells: [
                // DataCell(Container(
                //   width: 10,
                //   height: 10,
                //   color: ColorManagement.greenColor,
                // )),
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_SERVICE),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(service),
                  ),
                )
              ]),
              //liquidation
              DataRow(cells: [
                // DataCell(Container(
                //   width: 10,
                //   height: 10,
                //   color: ColorManagement.yellowColorFromCode,
                // )),
                DataCell(
                  NeutronTextContent(
                    message: MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_LIQUIDATION),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(liquidation),
                  ),
                )
              ]),
              //discount
              DataRow(cells: [
                // DataCell(Container(
                //   width: 10,
                //   height: 10,
                //   color: ColorManagement.redColor,
                // )),
                DataCell(
                  NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DISCOUNT),
                  ),
                ),
                DataCell(
                  NeutronTextContent(
                    color: ColorManagement.negativeText,
                    message: discount == 0
                        ? '0'
                        : '-${NumberUtil.numberFormat.format(discount)}',
                  ),
                )
              ]),
              //total
              DataRow(cells: [
                // DataCell.empty,
                DataCell(
                  NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TOTAL),
                  ),
                ),
                DataCell(
                  NeutronTextTitle(
                    isPadding: false,
                    color: ColorManagement.positiveText,
                    message: NumberUtil.numberFormat.format(total),
                  ),
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
