import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/report/cancelbookingreportcontroller.dart';
import '../../../manager/roommanager.dart';
import '../../../manager/sourcemanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';

class NoShowBookingsReport extends StatefulWidget {
  const NoShowBookingsReport({Key? key}) : super(key: key);

  @override
  State<NoShowBookingsReport> createState() => _NoShowBookingsReportState();
}

class _NoShowBookingsReportState extends State<NoShowBookingsReport> {
  CancelBookingReportController? controller;

  @override
  void initState() {
    controller ??= CancelBookingReportController(BookingStatus.noshow);
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
    double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;
    final now = Timestamp.now().toDate();

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<CancelBookingReportController>.value(
          value: controller!,
          child: Consumer<CancelBookingReportController>(
              builder: (_, controller, __) {
            return Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  automaticallyImplyLeading: !isMobile,
                  title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.POPUPMENU_NO_SHOW_BOOKING_REPORT),
                  ),
                  backgroundColor: ColorManagement.mainBackground,
                  actions: [
                    Container(
                      width: isMobile ? 70 : 100,
                      margin: const EdgeInsets.all(8),
                      child: NeutronDropDownCustom(
                        childWidget: NeutronDropDown(
                          isCenter: true,
                          isPadding: false,
                          onChanged: controller.setSource,
                          value: controller.source ==
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.STATUS_ALL)
                              ? UITitleUtil.getTitleByCode(
                                  UITitleCode.STATUS_ALL)
                              : SourceManager()
                                  .getSourceNameByID(controller.source),
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
                      lastDate: controller.startDate!
                          .add(Duration(days: controller.maxTimePeriod!)),
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
                    )
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
                        isMobile ? buildTitleMobile() : buildTitlePc(),
                        //content
                        Expanded(
                            child: controller.isLoading!
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorManagement.greenColor,
                                    ),
                                  )
                                : ListView(
                                    children: controller.bookings
                                        .map((booking) => isMobile
                                            ? buildContentMobile(booking)
                                            : buildContentPc(booking))
                                        .toList(),
                                  )),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        if (!(controller.roomChargeOfCurrentPage == 0))
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
                                isMobile
                                    ? NumberUtil.moneyFormat.format(
                                        controller.roomChargeOfCurrentPage)
                                    : NumberUtil.numberFormat.format(
                                        controller.roomChargeOfCurrentPage),
                                style: NeutronTextStyle.totalNumber,
                              ),
                              SizedBox(
                                  width: (isMobile ? 40 : 50) +
                                      SizeManagement
                                          .cardOutsideHorizontalPadding),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
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
                ]));
          }),
        ),
      ),
    );
  }

  Container buildTitlePc() => Container(
        margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding,
        ),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding),
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
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
                )),
            SizedBox(
                width: 60,
                child: NeutronTextTitle(
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
                )),
            Expanded(
                child: NeutronTextTitle(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
            )),
            Expanded(
                child: Tooltip(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LENGTH_STAY),
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 14,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LENGTH_STAY_COMPACT),
              ),
            )),
            Expanded(
                flex: 2,
                child: NeutronTextTitle(
                  textAlign: TextAlign.end,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
                )),
            const SizedBox(width: 50)
          ],
        ),
      );

  Container buildTitleMobile() => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding * 2),
        child: Row(
          children: [
            Expanded(
              child: NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.only(left: 8),
              child: NeutronTextContent(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
                message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
              ),
            ),
            Container(
              width: 40,
              padding: const EdgeInsets.only(left: 8),
              child: NeutronTextContent(
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LENGTH_STAY),
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LENGTH_STAY_COMPACT),
              ),
            ),
            Container(
              width: 90,
              padding: const EdgeInsets.only(left: 12),
              child: NeutronTextContent(
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
              ),
            ),
          ],
        ),
      );

  Container buildContentMobile(Booking booking) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.only(
            left: SizeManagement.cardOutsideHorizontalPadding,
            right: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.bottomFormFieldSpacing),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardInsideHorizontalPadding),
          title: Row(
            children: [
              Expanded(
                child: NeutronTextContent(
                    tooltip: booking.name, message: booking.name!),
              ),
              Container(
                width: 50,
                padding: const EdgeInsets.only(left: 8),
                child: NeutronTextContent(
                  message: DateUtil.dateToDayMonthString(booking.cancelled!),
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
                  NumberUtil.moneyFormat.format(booking.getRoomCharge()),
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: ColorManagement.positiveText),
                ),
              )
            ],
          ),
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATE),
                      )),
                      Expanded(
                          child: NeutronTextContent(
                        message:
                            DateUtil.dateToString(booking.created!.toDate()),
                      ))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: Row(
                    children: [
                      Expanded(
                          child: NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                      )),
                      Expanded(
                        child: NeutronTextContent(message: booking.sourceName!),
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
                                ? RoomManager().getNameRoomById(booking.room!)
                                : RoomManager().getNameRoomById(booking.room!)),
                      )
                    ],
                  ),
                ),
                NeutronBookingContextMenu(
                  icon: Icons.menu_outlined,
                  booking: booking,
                  backgroundColor: ColorManagement.lightMainBackground,
                  tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Expanded(
                //       child: NeutronBookingContextMenu(
                //         icon: Icons.menu_outlined,
                //         booking: booking,
                //         backgroundColor: ColorManagement.lightMainBackground,
                //         tooltip: UITitleUtil.getTitleByCode(
                //             UITitleCode.TOOLTIP_MENU),
                //       ),
                //     ),
                //     Expanded(
                //       child: IconButton(
                //         onPressed: () => showDialog(
                //             context: context,
                //             builder: (context) =>
                //                 LogBookingDialog(booking: booking)),
                //         tooltip: UITitleUtil.getTitleByCode(
                //             UITitleCode.POPUPMENU_LOG_BOOKING),
                //         icon: Icon(
                //           Icons.receipt_long_rounded,
                //           color: ColorManagement.iconMenuEnableColor,
                //           size: GeneralManager.iconMenuSize,
                //         ),
                //       ),
                //     )
                //   ],
                // ),
              ],
            )
          ],
        ),
      );

  Container buildContentPc(Booking booking) => Container(
        height: SizeManagement.cardHeight,
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideVerticalPadding),
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: SizeManagement.cardInsideHorizontalPadding),
                  child: NeutronTextContent(
                    message: DateUtil.dateToString(booking.cancelled!),
                  ),
                )),
            Expanded(
              flex: 2,
              child: NeutronTextContent(message: booking.sourceName!),
            ),
            Expanded(
                flex: 2,
                child: NeutronTextContent(
                    tooltip: booking.name, message: booking.name!)),
            SizedBox(
                width: 60,
                child: NeutronTextContent(
                    tooltip: booking.group!
                        ? RoomManager().getNameRoomById(booking.room!)
                        : RoomManager().getNameRoomById(booking.room!),
                    message: booking.group!
                        ? RoomManager().getNameRoomById(booking.room!)
                        : RoomManager().getNameRoomById(booking.room!))),
            Expanded(
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthString(booking.inDate!))),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: SizeManagement.cardInsideHorizontalPadding),
              child: NeutronTextContent(message: booking.lengthStay.toString()),
            )),
            Expanded(
                flex: 2,
                child: Text(
                  NumberUtil.numberFormat.format(booking.getRoomCharge()),
                  style: NeutronTextStyle.totalNumber,
                  textAlign: TextAlign.end,
                )),
            SizedBox(
                width: 50,
                child: NeutronBookingContextMenu(
                  booking: booking,
                  backgroundColor: ColorManagement.lightMainBackground,
                  tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
                )),
            // SizedBox(
            //   width: 40,
            //   child: IconButton(
            //     onPressed: () => showDialog(
            //         context: context,
            //         builder: (context) => LogBookingDialog(booking: booking)),
            //     tooltip: UITitleUtil.getTitleByCode(
            //         UITitleCode.POPUPMENU_LOG_BOOKING),
            //     icon: Icon(
            //       Icons.receipt_long_rounded,
            //       color: ColorManagement.iconMenuEnableColor,
            //       size: GeneralManager.iconMenuSize,
            //     ),
            //   ),
            // )
          ],
        ),
      );
}
