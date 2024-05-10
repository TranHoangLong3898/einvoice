import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
// import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/report/newbookingreportcontroller.dart';
import '../../../manager/sourcemanager.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrondropdown.dart';

class NewBookingReportDialog extends StatefulWidget {
  const NewBookingReportDialog({Key? key}) : super(key: key);

  @override
  State<NewBookingReportDialog> createState() => _NewBookingReportDialogState();
}

class _NewBookingReportDialogState extends State<NewBookingReportDialog> {
  NewBookingReportController? controller;

  @override
  void initState() {
    controller ??= NewBookingReportController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;

    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth + 300;
    }
    final now = Timestamp.now().toDate();

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<NewBookingReportController?>.value(
          value: controller,
          child: Consumer<NewBookingReportController>(
              builder: (_, controller, __) {
            final children = controller.bookings.map((booking) {
              return !isMobile
                  ? Container(
                      height: controller.isShowNote
                          ? null
                          : SizeManagement.cardHeight,
                      margin: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding,
                          vertical: SizeManagement.cardOutsideVerticalPadding),
                      decoration: BoxDecoration(
                          color: ColorManagement.lightMainBackground,
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          booking.created!.toDate()),
                                    ),
                                  )),
                              Expanded(
                                flex: 2,
                                child: NeutronTextContent(
                                    message: booking.sourceName!),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: NeutronTextContent(
                                      tooltip: booking.name,
                                      message: booking.name!)),
                              SizedBox(
                                  width: 60,
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
                                  flex: 3,
                                  child: NeutronTextContent(
                                      message:
                                          DateUtil.dateToDayMonthYearString(
                                              booking.inDate))),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardInsideHorizontalPadding),
                                child: NeutronTextContent(
                                    message: booking.lengthStay.toString()),
                              )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    NumberUtil.numberFormat.format(
                                        controller.getAverageRoomRate(booking)),
                                    style: NeutronTextStyle.totalNumber,
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    NumberUtil.numberFormat
                                        .format(booking.getRoomCharge()),
                                    style: NeutronTextStyle.totalNumber,
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    NumberUtil.numberFormat
                                        .format(booking.deposit),
                                    style: NeutronTextStyle.totalNumber,
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    NumberUtil.numberFormat
                                        .format(booking.getRemaining()),
                                    style: NeutronTextStyle.totalNumber,
                                    textAlign: TextAlign.end,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    controller.getStatusByBookingStatus(
                                        booking.status!),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ColorManagement.negativeText),
                                    textAlign: TextAlign.end,
                                  )),
                              SizedBox(
                                  width: 40,
                                  child: NeutronBookingContextMenu(
                                    booking: booking,
                                    backgroundColor:
                                        ColorManagement.lightMainBackground,
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TOOLTIP_MENU),
                                  )),
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
                                      tooltip:
                                          controller.mapNotes[booking.sID] ??
                                              "",
                                      message:
                                          controller.mapNotes[booking.sID] ??
                                              "",
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8),
                          color: ColorManagement.lightMainBackground),
                      margin: const EdgeInsets.only(
                          left: SizeManagement.cardOutsideHorizontalPadding,
                          right: SizeManagement.cardOutsideHorizontalPadding,
                          bottom: SizeManagement.bottomFormFieldSpacing),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal:
                                SizeManagement.cardInsideHorizontalPadding),
                        title: Row(
                          children: [
                            Expanded(
                              child: NeutronTextContent(
                                  tooltip: booking.name,
                                  message: booking.name!),
                            ),
                            Container(
                              width: 50,
                              padding: const EdgeInsets.only(left: 8),
                              child: NeutronTextContent(
                                message: DateUtil.dateToDayMonthString(
                                  booking.inDate!,
                                ),
                              ),
                            ),
                            Container(
                                width: 40,
                                padding: const EdgeInsets.only(left: 8),
                                child: NeutronTextContent(
                                    message: booking.lengthStay.toString())),
                            Container(
                              alignment: Alignment.centerRight,
                              width: 50,
                              child: Text(
                                NumberUtil.moneyFormat
                                    .format(booking.getRoomCharge()),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: ColorManagement.positiveText),
                              ),
                            )
                          ],
                        ),
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      tooltip: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_AVERAGE_ROOM_RATE),
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_AVERAGE_ROOM_RATE),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: NumberUtil.numberFormat.format(
                                          controller
                                              .getAverageRoomRate(booking)),
                                    ))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_CREATE),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: DateUtil.dateToString(
                                          booking.created!.toDate()),
                                    ))
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SOURCE),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          message: booking.sourceName!),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15, bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ROOM),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                          message: booking.group!
                                              ? booking.room!
                                              : RoomManager().getNameRoomById(
                                                  booking.room!)),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15, bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_NOTES),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                        tooltip:
                                            controller.mapNotes[booking.sID] ??
                                                "",
                                        message:
                                            controller.mapNotes[booking.sID] ??
                                                "",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 15, bottom: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: NeutronTextContent(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_STATUS),
                                    )),
                                    Expanded(
                                      child: NeutronTextContent(
                                        color: ColorManagement.negativeText,
                                        message:
                                            controller.getStatusByBookingStatus(
                                                booking.status!),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              NeutronBookingContextMenu(
                                icon: Icons.menu_outlined,
                                booking: booking,
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_MENU),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
            }).toList();
            return Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  automaticallyImplyLeading: !isMobile,
                  title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.POPUPMENU_BOOKING_REPORT),
                  ),
                  backgroundColor: ColorManagement.mainBackground,
                  actions: [
                    if (!isMobile)
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
                    Container(
                      width: isMobile ? 70 : 100,
                      margin: const EdgeInsets.all(8),
                      child: NeutronDropDownCustom(
                        childWidget: NeutronDropDown(
                          isCenter: true,
                          isPadding: false,
                          onChanged: controller.setsetStatusSource,
                          value: controller.statusSource ==
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.STATUS_ALL)
                              ? UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ALL)
                              : SourceManager()
                                  .getSourceNameByID(controller.statusSource),
                          items: [
                            UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL),
                            ...SourceManager().getActiveSourceNames()
                          ],
                        ),
                      ),
                    ),
                    NeutronDatePicker(
                      isMobile: isMobile,
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_START_DATE),
                      initialDate: controller.startDate,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now.add(const Duration(days: 365)),
                      onChange: (picked) {
                        controller.setStartDate(picked);
                      },
                    ),
                    NeutronDatePicker(
                      isMobile: isMobile,
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_END_DATE),
                      initialDate: controller.endDate,
                      firstDate: controller.startDate,
                      lastDate: controller.startDate
                          .add(Duration(days: controller.maxTimePeriod)),
                      onChange: (picked) {
                        controller.setEndDate(picked);
                      },
                    ),
                    NeutronBlurButton(
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_REFRESH),
                      icon: Icons.refresh,
                      onPressed: () {
                        controller.loadBasicBookings();
                      },
                    ),
                    // NeutronBlurButton(
                    //   tooltip: UITitleUtil.getTitleByCode(
                    //       UITitleCode.TOOLTIP_REFRESH),
                    //   icon: Icons.refresh,
                    //   onPressed: () async {
                    //     print("2");
                    //     await controller
                    //         .getAllBookingForExporting()
                    //         .then((value) {
                    //       ExcelUlti.exporotBooking(value);
                    //     });
                    //   },
                    // )
                  ],
                ),
                body: Stack(fit: StackFit.expand, children: [
                  Container(
                    width: width,
                    height: height,
                    margin: const EdgeInsets.only(bottom: 65),
                    child: Column(
                      children: [
                        //title
                        !isMobile
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                ),
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardInsideHorizontalPadding),
                                        child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_CREATE),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
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
                                        flex: 3,
                                        child: NeutronTextTitle(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_IN),
                                        )),
                                    Expanded(
                                        child: Tooltip(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TOOLTIP_LENGTH_STAY),
                                      child: NeutronTextTitle(
                                        isPadding: false,
                                        fontSize: 14,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_LENGTH_STAY_COMPACT),
                                      ),
                                    )),
                                    Expanded(
                                        flex: 2,
                                        child: Tooltip(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_AVERAGE_ROOM_RATE),
                                          child: NeutronTextTitle(
                                            textAlign: TextAlign.end,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_AVERAGE_ROOM_RATE),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          textAlign: TextAlign.end,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.ROOM_CHARGE),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          textAlign: TextAlign.end,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_PAID),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          textAlign: TextAlign.end,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_REMAIN),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          textAlign: TextAlign.end,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_STATUS),
                                        )),
                                    const SizedBox(width: 40)
                                  ],
                                ),
                              )
                            : Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding *
                                        2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_NAME),
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      padding: const EdgeInsets.only(left: 8),
                                      child: NeutronTextContent(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_IN),
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_IN),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      padding: const EdgeInsets.only(left: 8),
                                      child: NeutronTextContent(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_LENGTH_STAY),
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_LENGTH_STAY_COMPACT),
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      padding: const EdgeInsets.only(left: 12),
                                      child: NeutronTextContent(
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PRICE),
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PRICE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Expanded(
                            child: controller.isLoading!
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorManagement.greenColor,
                                    ),
                                  )
                                : ListView(
                                    children: children,
                                  )),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        if (controller.roomChargeOfCurrentPage != 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              NeutronTextTitle(
                                fontSize: 14,
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} :',
                              ),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              Text(
                                "${controller.totalLengthStayOnPage.toString()} ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMNIGHT_WITH_TOTAL)} ${isMobile ? NumberUtil.moneyFormat.format(controller.roomChargeOfCurrentPage) : NumberUtil.numberFormat.format(controller.roomChargeOfCurrentPage)}",
                                style: NeutronTextStyle.totalNumber,
                              ),
                              SizedBox(
                                  width: (isMobile ? 32 : 50) +
                                      SizeManagement
                                          .cardOutsideHorizontalPadding),
                            ],
                          ),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    controller.getBasicBookingsFirstPage();
                                  },
                                  icon: const Icon(Icons.skip_previous)),
                              IconButton(
                                  onPressed: () {
                                    controller.getBasicBookingsPreviousPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_before_sharp,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    controller.getBasicBookingsNextPage();
                                  },
                                  icon: const Icon(
                                    Icons.navigate_next_sharp,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    controller.getBasicBookingsLastPage();
                                  },
                                  icon: const Icon(Icons.skip_next)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButtonText(
                        text:
                            "${controller.lengthStay} ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMNIGHT_WITH_TOTAL)} ${NumberUtil.numberFormat.format(controller.roomCharge)}"),
                  ),
                ]));
          }),
        ),
      ),
    );
  }
}
