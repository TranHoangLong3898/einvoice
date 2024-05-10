import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/management/reportmanagement/bookingtodayreportmanagercontroller.dart';
import '../../../../manager/roommanager.dart';
import '../../../../manager/sourcemanager.dart';
import '../../../../modal/booking.dart';
import '../../../../modal/status.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/pdfutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronbookingcontextmenu.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontexttilte.dart';
import '../../booking/bookingdialog.dart';

class BookingToDayReportManagerment extends StatefulWidget {
  const BookingToDayReportManagerment({Key? key}) : super(key: key);

  @override
  State<BookingToDayReportManagerment> createState() =>
      _BookingToDayReportManagermentState();
}

class _BookingToDayReportManagermentState
    extends State<BookingToDayReportManagerment> {
  BookingToDayReportManagementController? controller;
  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  void initState() {
    controller ??= BookingToDayReportManagementController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth;
    const double height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<
            BookingToDayReportManagementController>.value(
          value: controller!,
          child: Consumer<BookingToDayReportManagementController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor));
              }
              return Scaffold(
                floatingActionButton: floatingActionButton(controller),
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  backgroundColor: ColorManagement.mainBackground,
                  title: Text(UITitleUtil.getTitleByCode(
                      UITitleCode.SIDEBAR_BOOKING_BY_DATE)),
                  actions: [
                    IconButton(
                      iconSize: 18,
                      icon: Icon(
                          controller.isShowNote
                              ? Icons.speaker_notes
                              : Icons.speaker_notes_off,
                          color: controller.isShowNote
                              ? ColorManagement.white
                              : ColorManagement.redColor),
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_SHOW_NOTES),
                      onPressed: () async {
                        controller.onChange(controller.isShowNote);
                      },
                    ),
                    NeutronDatePicker(
                      isMobile: isMobile,
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_START_DATE),
                      initialDate: controller.staysDate,
                      firstDate: controller.staysDate!
                          .subtract(const Duration(days: 365)),
                      lastDate:
                          controller.staysDate!.add(const Duration(days: 365)),
                      onChange: (picked) {
                        controller.setDate(picked);
                      },
                    ),
                  ],
                ),
                body: Stack(children: [
                  Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 20 : 90),
                      child: Column(
                        children: [
                          const SizedBox(
                              height:
                                  SizeManagement.cardOutsideVerticalPadding),
                          isMobile ? buildTitleMobile() : buildTitlePc(),
                          Expanded(
                              child: ListView(
                                  children: controller.bookings
                                      .sublist(controller.startIndex,
                                          controller.endIndex)
                                      .map(
                            (booking) {
                              return isMobile
                                  ? buildContentMobile(booking)
                                  : buildContentPC(booking);
                            },
                          ).toList())),
                          const SizedBox(
                              height:
                                  SizeManagement.cardOutsideVerticalPadding),
                        ],
                      )),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(
                              bottom:
                                  SizeManagement.cardInsideHorizontalPadding),
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    controller.getBookingsPreviousPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_before_sharp,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    controller.getBookingsNextPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_next_sharp,
                                  )),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                height: 45,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: ColorManagement.greenColor,
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        child: NeutronTextTitle(
                                      textAlign: TextAlign.center,
                                      message:
                                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT)}: ${controller.setListSid.length}",
                                    )),
                                    Expanded(
                                        child: NeutronTextTitle(
                                      textAlign: TextAlign.center,
                                      message:
                                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE)}: ${controller.getAllRevenueOfBooking()}",
                                    )),
                                    Expanded(
                                      child: NeutronTextTitle(
                                          textAlign: TextAlign.center,
                                          message:
                                              "${UITitleUtil.getTitleByCode(UITitleCode.HEADER_AVERAGE)}: ${controller.getAverageRoomPriceBooking()}"),
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                  )
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton(
          BookingToDayReportManagementController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.redColor,
        mini: true,
        tooltip:
            UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
        onPressed: () async {
          if (controller.bookings.isEmpty) return;
          ExcelUlti.exportBookingToDayReport(controller.bookings);
        },
        child: const Icon(Icons.file_present_rounded),
      );

  Widget buildTitlePc() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 40,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding, right: 4),
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding, right: 4),
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_ROOMTYPE),
                ),
              ),
            ),
            Expanded(
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
              ),
            ),
            Expanded(
              flex: 2,
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                textAlign: TextAlign.left,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_QUANTITY),
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
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 150, minWidth: 150),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                textAlign: TextAlign.left,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextTitle(
                fontSize: 13,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE),
              ),
            ),
            const SizedBox(width: 74),
          ],
        ),
      );

  Widget buildTitleMobile() => Row(
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
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE),
            ),
          ),
        ],
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
                    tooltip: booking.name,
                    message: booking.name!,
                  )),
              const SizedBox(width: 4),
              SizedBox(
                  width: 50,
                  child: NeutronTextContent(
                      tooltip: booking.sID == booking.id
                          ? booking.room
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
                        tooltip: booking.sID == booking.id
                            ? booking.roomTypeID
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID!),
                        message: booking.sID == booking.id
                            ? booking.roomTypeID!
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID!)),
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
                            UITitleCode.TABLEHEADER_SID),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(message: booking.sID!),
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
                            UITitleCode.TABLEHEADER_SOURCE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: SourceManager()
                                  .getSourceNameByID(booking.sourceID!)),
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
                            UITitleCode.TABLEHEADER_GUEST_QUANTITY),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: NumberUtil.moneyFormat
                                  .format(booking.adult! + booking.child!)),
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
                            UITitleCode.TABLEHEADER_PHONE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(message: booking.phone!),
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
                            UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: NumberUtil.numberFormat.format(
                                  booking.getRoomCharge() /
                                      booking.lengthStay!)),
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
                            UITitleCode.TABLEHEADER_REVENUE),
                      )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(booking.getRevenue())),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  if (controller!.isShowNote)
                    Row(
                      children: [
                        Expanded(
                            child: NeutronTextContent(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.HEADER_NOTES),
                        )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: NeutronTextContent(
                              tooltip: controller!.mapNoteBooking[booking.sID],
                              message: controller!.mapNoteBooking[booking.sID]!,
                            ),
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

  Widget buildContentPC(Booking booking) => Container(
        height: controller!.isShowNote ? null : SizeManagement.cardHeight,
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
                //room
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding,
                        right: 4),
                    child: NeutronTextContent(
                        tooltip: booking.sID == booking.id
                            ? booking.room
                            : RoomManager().getNameRoomById(booking.room!),
                        message: booking.sID == booking.id
                            ? booking.room!
                            : RoomManager().getNameRoomById(booking.room!)),
                  ),
                ),
                //rom type
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding,
                        right: 4),
                    child: NeutronTextContent(
                        tooltip: booking.sID == booking.id
                            ? booking.roomTypeID
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID!),
                        message: booking.sID == booking.id
                            ? booking.roomTypeID!
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID!)),
                  ),
                ),
                //sid
                Expanded(
                    child: NeutronTextContent(
                  textAlign: TextAlign.center,
                  message: booking.sID!,
                  tooltip: booking.sID,
                )),
                //name
                Expanded(
                  flex: 2,
                  child: NeutronTextContent(
                    tooltip: booking.name,
                    message: booking.name!,
                  ),
                ),
                //soure
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, minWidth: 100),
                  child: NeutronTextContent(
                      textAlign: TextAlign.left,
                      message:
                          SourceManager().getSourceNameByID(booking.sourceID!)),
                ),

                //guest
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, minWidth: 100),
                  child: NeutronTextContent(
                      textAlign: TextAlign.center,
                      message: (booking.adult! + booking.child!).toString()),
                ),
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
                //phone
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, minWidth: 100),
                  child: NeutronTextContent(message: booking.phone!),
                ),
                //sum
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 150, minWidth: 150),
                  child: NeutronTextContent(
                      message: NumberUtil.numberFormat.format(
                          (booking.getRoomCharge() / booking.lengthStay!)
                              .round())),
                ),
                //revenue
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 100, minWidth: 100),
                  child: NeutronTextContent(
                      message:
                          NumberUtil.numberFormat.format(booking.getRevenue())),
                ),
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
            if (controller!.isShowNote)
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
                        tooltip: controller!.mapNoteBooking[booking.sID] ?? "",
                        message: controller!.mapNoteBooking[booking.sID] ?? "",
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      );
}
