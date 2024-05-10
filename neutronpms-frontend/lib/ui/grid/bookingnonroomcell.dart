import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/nonroombydatecontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutronbookingcontextmenu.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/pdfutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class BookingNonRoomCell extends StatefulWidget {
  const BookingNonRoomCell({super.key, required this.dateTime});
  final DateTime dateTime;

  @override
  State<BookingNonRoomCell> createState() => _BookingNonRoomCellState();
}

class _BookingNonRoomCellState extends State<BookingNonRoomCell> {
  late BookingNRoomByDateController controller;

  @override
  void initState() {
    super.initState();
    controller = BookingNRoomByDateController(widget.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth + 130;
    const double height = kHeight;
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<BookingNRoomByDateController>(
            builder: (_, controller, __) => SizedBox(
              width: width,
              height: height,
              child: Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                    title: NeutronTextContent(
                        message:
                            "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_NON_ROOM_BOOKINGS)} - ${DateUtil.dateToDayMonthYearString(widget.dateTime)}")),
                body: Column(children: [
                  isMobile ? buildTitleMobile() : buildTitlePc(),
                  Expanded(
                      child: controller.isLoading!
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorManagement.greenColor,
                              ),
                            )
                          : ListView(
                              children: controller.dataBooking
                                  .map((booking) => isMobile
                                      ? buildContentMobile(booking)
                                      : buildContetPc(booking))
                                  .toList(),
                            )),
                  pagination
                ]),
              ),
            ),
          ),
        ));
  }

  Row get pagination => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getBookingNonRoomFirstPage,
              icon: const Icon(Icons.skip_previous)),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getBookingNonRoomPreviousPage,
              icon: const Icon(
                Icons.navigate_before_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getBookingNonRoomNextPage,
              icon: const Icon(
                Icons.navigate_next_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller.getBookingNonRoomLastPage,
              icon: const Icon(Icons.skip_next)),
        ],
      );

  Widget buildTitlePc() => Container(
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
            const SizedBox(width: 78),
          ],
        ),
      );

  Widget buildTitleMobile() => SizedBox(
        height: 40,
        child: Row(
          children: [
            const SizedBox(
                width: SizeManagement.cardInsideHorizontalPadding +
                    SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 100,
              child: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 50,
              child: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
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
        ),
      );

  Widget buildContetPc(Booking booking) => Container(
        height: SizeManagement.cardHeight,
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
          ],
        ),
      );

  Widget buildContentMobile(Booking booking) => Container(
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
                      tooltip: booking.sID! == booking.id!
                          ? booking.room!
                          : RoomManager().getNameRoomById(booking.room!),
                      message: booking.sID! == booking.id!
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
              onTap: () {},
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
                            UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat.format(
                                  (booking.getRoomCharge() /
                                          booking.lengthStay!)
                                      .round())),
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
