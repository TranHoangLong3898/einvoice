import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../../../../manager/roommanager.dart';
import '../../../../../modal/booking.dart';
import '../../../../../modal/dailydata.dart';
import '../../../../../util/dateutil.dart';
import '../../../../../util/numberutil.dart';
import '../../../../../util/uimultilanguageutil.dart';
import '../../../../controls/neutrontextcontent.dart';
import '../../../../controls/neutrontextstyle.dart';

class NewBookingDetailDialog extends StatelessWidget {
  final DailyData? dailyData;
  final List<Booking>? bookings;
  const NewBookingDetailDialog({Key? key, this.dailyData, this.bookings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: SingleChildScrollView(
            child: Column(children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardOutsideHorizontalPadding,
                ),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: NeutronTextTitle(
                      isPadding: false,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_SOURCE),
                    )),
                    Expanded(
                        flex: 2,
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_NAME),
                        )),
                    SizedBox(
                        width: 60,
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ROOM),
                        )),
                    Expanded(
                        child: NeutronTextTitle(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_IN),
                    )),
                    SizedBox(
                        width: 50,
                        child: NeutronTextTitle(
                          textAlign: TextAlign.end,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        )),
                    const SizedBox(width: 30)
                  ],
                ),
              ),
              ...bookings!
                  .where((element) =>
                      (element.created!.toDate().day < 10
                          ? "0${element.created!.toDate().day.toString()}"
                          : element.created!.toDate().day.toString()) ==
                      dailyData!.date)
                  .map((booking) {
                return Container(
                  height: SizeManagement.cardHeight,
                  margin: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardOutsideHorizontalPadding,
                      vertical: SizeManagement.cardOutsideVerticalPadding),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                      color: ColorManagement.lightMainBackground,
                      borderRadius:
                          BorderRadius.circular(SizeManagement.borderRadius8)),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 50,
                          child:
                              NeutronTextContent(message: booking.sourceName!)),
                      Expanded(
                          child: NeutronTextContent(
                              tooltip: booking.name, message: booking.name!)),
                      SizedBox(
                          width: 50,
                          child: NeutronTextContent(
                              tooltip: booking.group!
                                  ? booking.room
                                  : RoomManager()
                                      .getNameRoomById(booking.room!),
                              message: booking.group!
                                  ? booking.room!
                                  : RoomManager()
                                      .getNameRoomById(booking.room!))),
                      Expanded(
                          child: NeutronTextContent(
                              message: DateUtil.dateToDayMonthString(
                                  booking.inDate!))),
                      SizedBox(
                          width: 70,
                          child: Text(
                            NumberUtil.numberFormat
                                .format(booking.getRoomCharge()),
                            style: NeutronTextStyle.totalNumber,
                            textAlign: TextAlign.end,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ]),
          ),
        ));
  }
}
