import 'package:flutter/material.dart';
import 'package:ihotel/controller/searchcontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../manager/roommanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';
import '../../util/numberutil.dart';
import '../../util/pdfutil.dart';
import '../../util/responsiveutil.dart';
import '../../util/uimultilanguageutil.dart';
import '../component/booking/bookingdialog.dart';
import 'neutronbookingcontextmenu.dart';

class NeutronSearchBookingList extends StatelessWidget {
  final List<Booking>? bookings;
  final SearchControllers controller;

  const NeutronSearchBookingList(
      {Key? key, this.bookings, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    if (bookings == null) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManagement.greenColor),
      );
    }
    if (bookings!.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_NO_BOOKINGS)),
      );
    }
    return Column(
      children: [
        isMobile ? buildTitleOnMobile() : buildTitleOnPc(),
        Expanded(
          child: ListView(
            children: bookings!
                .map((booking) => isMobile
                    ? buildContentOnMobile(context, booking)
                    : buildContentOnPc(context, booking))
                .toList(),
          ),
        ),
      ],
    );
  }

  Container buildTitleOnPc() => //title row
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
                    left: SizeManagement.cardInsideHorizontalPadding, right: 4),
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
            Container(
              constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
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
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
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
            const SizedBox(width: 70),
          ],
        ),
      );

  Row buildTitleOnMobile() => Row(
        children: [
          const SizedBox(
              width: SizeManagement.cardInsideHorizontalPadding +
                  SizeManagement.cardOutsideHorizontalPadding),
          SizedBox(
            width: 100,
            child: NeutronTextContent(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 50,
            child: NeutronTextContent(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: NeutronTextContent(
              textOverflow: TextOverflow.visible,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
            ),
          ),
        ],
      );

  Container buildContentOnPc(BuildContext context, Booking booking) =>
      Container(
        height: controller.isShowNote ? null : SizeManagement.cardHeight,
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
              mainAxisAlignment: MainAxisAlignment.start,
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
                    isStatus: false,
                    backgroundColor: ColorManagement.lightMainBackground,
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
                  ),
                ),
              ],
            ),
            if (controller.isShowNote)
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
                        tooltip: controller.notes[booking.sID] ?? "",
                        message: controller.notes[booking.sID] ?? "",
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      );

  Container buildContentOnMobile(BuildContext context, Booking booking) =>
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          childrenPadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          title: Row(
            children: [
              SizedBox(
                  width: 100,
                  child: NeutronTextContent(
                    tooltip: booking.name!,
                    message: booking.name!,
                  )),
              const SizedBox(width: 4),
              SizedBox(
                  width: 50,
                  child: NeutronTextContent(
                      tooltip: booking.sID == booking.id
                          ? booking.room!
                          : RoomManager().getNameRoomById(booking.room!),
                      message: booking.sID == booking.id
                          ? booking.room!
                          : RoomManager().getNameRoomById(booking.room!))),
              const SizedBox(width: 4),
              Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: NeutronTextContent(
                        color: ColorManagement.positiveText,
                        message: NumberUtil.moneyFormat
                            .format(booking.getTotalCharge())),
                  )),
            ],
          ),
          children: [
            InkWell(
              onTap: () => showDialog(
                  context: context,
                  builder: (context) => BookingDialog(booking: booking)),
              child: Column(
                children: [
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child:
                              NeutronTextContent(message: booking.sourceName!),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_IN),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: DateUtil.dateToDayMonthString(
                                  booking.inDate!)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_OUT),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: DateUtil.dateToDayMonthString(
                                  booking.outDate!)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PAYMENT),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.moneyFormat
                                  .format(booking.deposit)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: NeutronTextContent(
                            color: ColorManagement.positiveText,
                            message: NumberUtil.moneyFormat
                                .format(booking.getRoomCharge())),
                      ))
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SERVICE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.moneyFormat
                                  .format(booking.getServiceCharge())),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DISCOUNT),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              color: ColorManagement.negativeText,
                              message: NumberUtil.moneyFormat
                                  .format(booking.discount)),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_REMAIN),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.moneyFormat
                                  .format(booking.getRemaining())),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  if (controller.isShowNote)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.HEADER_NOTES)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: NeutronTextContent(
                              tooltip: controller.notes[booking.sID] ?? "",
                              message: controller.notes[booking.sID] ?? "",
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Container(
                    height: 30,
                    margin: const EdgeInsets.only(
                        bottom: SizeManagement.rowSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
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
                                                pngBytes:
                                                    GeneralManager.policyHotel))
                                            : (await PDFUtil
                                                .buildCheckOutPDFDoc(
                                                    booking, confirm, true)))
                                        .save());
                          },
                        ),
                        NeutronBookingContextMenu(
                          icon: Icons.menu_outlined,
                          booking: booking,
                          isStatus: false,
                          backgroundColor: ColorManagement.lightMainBackground,
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_MENU),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
}
