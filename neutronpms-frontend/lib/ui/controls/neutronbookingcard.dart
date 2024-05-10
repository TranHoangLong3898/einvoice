// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../modal/booking.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';
import '../../util/numberutil.dart';
import 'neutrontextcontent.dart';

class NeutronBookingCard extends StatelessWidget {
  final Booking? booking;
  final String? roomName;
  const NeutronBookingCard({
    Key? key,
    this.booking,
    this.roomName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: ColorManagement.lightMainBackground,
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Row(
          children: [
            Expanded(
              child: NeutronTextContent(
                  tooltip: booking!.name!, message: booking!.name!),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.only(left: 5),
              child: NeutronTextContent(
                message: DateUtil.dateToDayMonthString(
                  booking!.inDate!,
                ),
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                NumberUtil.moneyFormat.format(booking!.getRoomCharge()),
                style: const TextStyle(color: ColorManagement.positiveText),
              ),
            )
          ],
        ),
        children: [
          InkWell(
            onTap: () => showDialog(
                context: context,
                builder: (context) => BookingDialog(booking: booking!)),
            child: Column(
              children: [
                //create
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATE),
                      )),
                      Expanded(
                          child: Center(
                        child: NeutronTextContent(
                          message:
                              DateUtil.dateToString(booking!.created!.toDate()),
                        ),
                      ))
                    ],
                  ),
                ),
                //source
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                      )),
                      Expanded(
                        child: Center(
                            child: NeutronTextContent(
                                message: booking!.sourceName!)),
                      )
                    ],
                  ),
                ),
                //room
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM),
                      )),
                      Expanded(
                        child: Center(
                            child: NeutronTextContent(
                                message: booking!.room == null
                                    ? 'Group'
                                    : RoomManager()
                                        .getNameRoomById(booking!.room!))),
                      )
                    ],
                  ),
                ),
                //in
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_IN),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              message: DateUtil.dateToString(booking!.inDate!)),
                        ),
                      )
                    ],
                  ),
                ),
                //out
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_OUT),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              message:
                                  DateUtil.dateToString(booking!.outDate!)),
                        ),
                      )
                    ],
                  ),
                ),
                //payment
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PAYMENT),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.deposit)),
                        ),
                      )
                    ],
                  ),
                ),
                //Room charge
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.getRoomCharge())),
                        ),
                      )
                    ],
                  ),
                ),
                //service
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SERVICE),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.getServiceCharge())),
                        ),
                      )
                    ],
                  ),
                ),
                //discount
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DISCOUNT),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.negativeText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.discount)),
                        ),
                      )
                    ],
                  ),
                ),
                //total
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_TOTAL),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.getTotalCharge())),
                        ),
                      )
                    ],
                  ),
                ),
                //remain
                Container(
                  margin: const EdgeInsets.all(
                      SizeManagement.cardOutsideHorizontalPadding),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_REMAIN),
                      )),
                      Expanded(
                        child: Center(
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(booking!.getRemaining())),
                        ),
                      )
                    ],
                  ),
                ),
                NeutronButton(
                  icon: Icons.drive_file_move_outline,
                  onPressed: () async {
                    final confirm = await MaterialUtil.showConfirm(
                        context,
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.CONFIRM_SELECT_BOOKING,
                            [booking!.name!]));
                    if (confirm!) {
                      Navigator.pop(context, booking);
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
