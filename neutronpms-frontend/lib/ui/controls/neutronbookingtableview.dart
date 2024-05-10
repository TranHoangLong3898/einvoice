import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../controller/report/bookinglistcontroller.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../../util/numberutil.dart';
import '../../util/pdfutil.dart';
import 'neutronbookingcontextmenu.dart';

class NeutronBookingTableView extends StatelessWidget {
  final BookingListController controller;

  const NeutronBookingTableView({Key? key, required this.controller})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (controller.getBookingsByFilter() == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (controller.getBookingsByFilter()!.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_NO_BOOKINGS)),
      );
    }

    final children = controller.getBookingsByFilter()!.map((booking) {
      return Container(
        height: controller.isShowNote && !controller.chekNoRoomAndSource()
            ? null
            : SizeManagement.cardHeight,
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //source name
                Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardInsideHorizontalPadding,
                          right: 4),
                      child: NeutronTextContent(
                          message: booking.sourceName!,
                          tooltip: booking.sourceName),
                    )),
                //name
                Expanded(
                  flex: 4,
                  child: NeutronTextContent(
                    tooltip: booking.name!,
                    message: booking.name!,
                  ),
                ),
                //room
                Container(
                    constraints:
                        const BoxConstraints(maxWidth: 50, minWidth: 50),
                    child: NeutronTextContent(
                        tooltip: booking.sID == booking.id
                            ? booking.room!
                            : RoomManager().getNameRoomById(booking.room!),
                        message: booking.sID == booking.id
                            ? booking.room!
                            : RoomManager().getNameRoomById(booking.room!))),

                if (!controller.chekNoRoomAndSource()) ...[
                  //roomType
                  Container(
                      constraints:
                          const BoxConstraints(maxWidth: 50, minWidth: 50),
                      child: NeutronTextContent(
                          tooltip: booking.sID == booking.id
                              ? booking.roomTypeID!
                              : RoomTypeManager()
                                  .getRoomTypeNameByID(booking.roomTypeID!),
                          message: booking.sID == booking.id
                              ? booking.roomTypeID!
                              : RoomTypeManager()
                                  .getRoomTypeNameByID(booking.roomTypeID!))),

                  ///BreakFast
                  Container(
                      constraints:
                          const BoxConstraints(maxWidth: 50, minWidth: 50),
                      child: NeutronTextContent(
                        message: booking.sID == booking.id
                            ? controller.mapBreakFast![booking.sID].toString()
                            : booking.breakfast!
                                ? MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_YES)
                                : MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_NO),
                        tooltip: booking.sID == booking.id
                            ? controller.mapBreakFast![booking.sID].toString()
                            : booking.breakfast!
                                ? MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_YES)
                                : MessageUtil.getMessageByCode(
                                    MessageCodeUtil.TEXTALERT_NO),
                      )),
                ],
                //in
                Container(
                  constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                  child: NeutronTextContent(
                      message: DateUtil.dateToDayMonthString(booking.inDate!)),
                ),
                //out
                Container(
                  constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                  child: NeutronTextContent(
                      message: DateUtil.dateToDayMonthString(booking.outDate!)),
                ),
                //guest amount
                SizedBox(
                  width: 70,
                  child: NeutronTextContent(
                      message: '${booking.declareGuests?.length ?? 0}',
                      textAlign: TextAlign.center),
                ),
                //payment
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: NeutronTextContent(
                          color: ColorManagement.positiveText,
                          message:
                              NumberUtil.numberFormat.format(booking.deposit)),
                    )),
                //AVERAGE_ROOM_RATE
                Expanded(
                    flex: 3,
                    child: NeutronTextContent(
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                        message: NumberUtil.numberFormat.format(
                            (booking.getRoomCharge() / booking.lengthStay!)
                                .round()))),
                //room charge
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: NeutronTextContent(
                          color: ColorManagement.positiveText,
                          message: NumberUtil.numberFormat
                              .format(booking.getRoomCharge())),
                    )),
                //service
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: NeutronTextContent(
                          color: ColorManagement.positiveText,
                          message: NumberUtil.numberFormat
                              .format(booking.getServiceCharge())),
                    )),
                //discount
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: NeutronTextContent(
                          color: ColorManagement.negativeText,
                          message: booking.discount == 0
                              ? "0"
                              : "-${NumberUtil.numberFormat.format(booking.discount)}"),
                    )),
                //total
                Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: NeutronTextContent(
                          color: ColorManagement.positiveText,
                          message: NumberUtil.numberFormat
                              .format(booking.getTotalCharge())),
                    )),
                //remain
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: NeutronTextContent(
                        color: ColorManagement.positiveText,
                        message: NumberUtil.numberFormat
                            .format(booking.getRemaining())),
                  ),
                ),
                //print
                Container(
                  width: 35,
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () async {
                      final confirm = await MaterialUtil.showConfirm(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.CONFIRM_SHOW_PRICE));
                      if (confirm == null) return;
                      Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async =>
                              (booking.status == BookingStatus.booked
                                      ? (await PDFUtil.buildCheckInPDFDoc(
                                          booking, confirm,
                                          pngBytes: GeneralManager.policyHotel))
                                      : (await PDFUtil.buildCheckOutPDFDoc(
                                          booking, confirm, true)))
                                  .save());
                    },
                  ),
                ),
                //menu
                Container(
                  width: 35,
                  alignment: Alignment.center,
                  child: NeutronBookingContextMenu(
                    booking: booking,
                    backgroundColor: ColorManagement.lightMainBackground,
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
                  ),
                ),
              ],
            ),
            if (controller.isShowNote && !controller.chekNoRoomAndSource())
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NeutronTextTitle(
                          fontSize: 13,
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.HEADER_NOTES)),
                    ),
                    Expanded(
                      flex: 3,
                      child: NeutronTextContent(
                        tooltip: controller.mapNotes[booking.sID] ?? "",
                        message: controller.mapNotes[booking.sID] ?? "",
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      );
    }).toList();
    return Column(
      children: [
        //title row
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 40,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: SizeManagement.cardInsideHorizontalPadding,
                      right: 4),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_SOURCE),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
                ),
              ),
              if (!controller.chekNoRoomAndSource()) ...[
                Container(
                  constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TYPE),
                  ),
                ),
                if (controller.mapBreakFast != null)
                  Container(
                    constraints:
                        const BoxConstraints(maxWidth: 50, minWidth: 50),
                    child: NeutronTextTitle(
                      fontSize: 13,
                      isPadding: false,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_BREAKFAST),
                    ),
                  ),
              ],
              Container(
                constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT),
                ),
              ),
              SizedBox(
                width: 70,
                child: NeutronTextTitle(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GUEST_DECLARE_AMOUNT),
                    maxLines: 2,
                    fontSize: 13,
                    isPadding: false),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PAYMENT),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Tooltip(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    textAlign: TextAlign.end,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_SERVICE),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DISCOUNT),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TOTAL),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextTitle(
                    fontSize: 13,
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_REMAIN),
                  ),
                ),
              ),
              const SizedBox(width: 78),
            ],
          ),
        ),
        //list booking
        Expanded(
          child: ListView(
            children: children,
          ),
        ),
      ],
    );
  }
}
