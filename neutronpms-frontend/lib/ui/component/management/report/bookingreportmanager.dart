import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/component/extraservice/virtualbookingmanagementdialog.dart';
import 'package:ihotel/ui/component/report/detailrevenuereport.dart';
import 'package:ihotel/ui/component/service/bikerentalform.dart';
import 'package:ihotel/ui/component/service/extrahourform.dart';
import 'package:ihotel/ui/component/service/othersform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontablecell.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/report/revenuereportcontroller.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../controls/neutronbookingcontextmenu.dart';
import '../../../controls/neutronbuttontext.dart';
import '../../booking/depositdialog.dart';
import '../../booking_group/groupdialog.dart';
import '../../service/extraguestform.dart';
import '../../service/laundryform.dart';
import '../../service/minibarform.dart';

class BookingReportDialog extends StatefulWidget {
  const BookingReportDialog({Key? key}) : super(key: key);

  @override
  State<BookingReportDialog> createState() => _BookingReportDialogState();
}

class _BookingReportDialogState extends State<BookingReportDialog> {
  final RevenueReportController revenueReportController =
      RevenueReportController();
  final ScrollController _scrollController = ScrollController();
  final now = Timestamp.now().toDate();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    late double widthOut, widthIn;
    const double height = kHeight;
    if (isMobile) {
      widthOut = kMobileWidth;
    } else {
      widthOut = kLargeWidth + 350;
      widthIn = kLargeWidth + 930;
    }
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: widthOut,
            height: height,
            child: ChangeNotifierProvider.value(
                value: revenueReportController,
                child: Consumer<RevenueReportController>(
                    builder: (_, controller, __) {
                  return Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      floatingActionButton: floatingActionButton(controller),
                      appBar: AppBar(
                        leadingWidth: isMobile ? 0 : 56,
                        leading: isMobile ? Container() : null,
                        title: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.POPUPMENU_REVENUE_REPORT)),
                        backgroundColor: ColorManagement.mainBackground,
                        actions: [
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
                              controller.loadRevenues();
                            },
                          ),
                          NeutronBlurButton(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                            icon: Icons.file_present_rounded,
                            onPressed: () async {
                              // showDialog(
                              //     barrierDismissible: false,
                              //     context: context,
                              //     builder: (context) => WillPopScope(
                              //         onWillPop: () => Future.value(false),
                              //         child: const NeutronWaiting()));
                              // List<Booking> bookings =
                              await controller
                                  .getAllBookingForExporting()
                                  .then((bookings) {
                                ExcelUlti.exportReprotBooking(
                                    bookings,
                                    controller.dataSetMethod,
                                    controller.dataSetTypeCost,
                                    controller.startDate,
                                    controller.endDate);
                                // Navigator.pop(context);
                              });
                            },
                          ),
                        ],
                      ),
                      body: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thickness: 13,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: isMobile ? widthOut : widthIn,
                            child: Column(
                              children: [
                                const SizedBox(
                                    height: SizeManagement.rowSpacing),
                                isMobile ? buildTitleMobile() : buildTitlePc(),
                                Expanded(
                                  child: controller.isLoading!
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color:
                                                  ColorManagement.greenColor),
                                        )
                                      : ListView(
                                          children: isMobile
                                              ? buildListMobile(controller)
                                              : buildListPc(controller),
                                        ),
                                ),
                                const SizedBox(
                                    height: SizeManagement.rowSpacing),
                                SizedBox(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: controller
                                              .getRevenueReportFirstPage,
                                          icon:
                                              const Icon(Icons.skip_previous)),
                                      IconButton(
                                          onPressed: controller
                                              .getRevenueReportPreviousPage,
                                          icon: const Icon(
                                              Icons.navigate_before_sharp)),
                                      IconButton(
                                          onPressed: controller
                                              .getRevenueReportNextPage,
                                          icon: const Icon(
                                              Icons.navigate_next_sharp)),
                                      IconButton(
                                          onPressed: controller
                                              .getRevenueReportLastPage,
                                          icon: const Icon(Icons.skip_next)),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height: SizeManagement.rowSpacing),
                                NeutronButtonText(
                                    text:
                                        "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.revenueTotal)}"),
                              ],
                            ),
                          ),
                        ),
                      ));
                }))));
  }

  FloatingActionButton floatingActionButton(
          RevenueReportController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.lightMainBackground,
        mini: true,
        tooltip: UITitleUtil.getTitleByCode(
            UITitleCode.TOOLTIP_REVENUE_REPORT_DETAI),
        onPressed: () async =>
            await controller.getAllBookingForExporting().then((booking) {
          return showDialog(
            context: context,
            builder: (context) => DetailRevenueReportDialog(
              controller: controller,
            ),
          );
        }),
        child: const Icon(Icons.description_sharp),
      );

  List<Container> buildListPc(RevenueReportController controller) {
    return controller.bookings
        .map((booking) => Container(
              height: SizeManagement.cardHeight,
              margin: const EdgeInsets.symmetric(
                  vertical: SizeManagement.cardOutsideVerticalPadding,
                  horizontal: SizeManagement.cardOutsideHorizontalPadding),
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              child: Row(
                children: [
                  Container(
                      width: 95,
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardInsideHorizontalPadding),
                      child: NeutronTextContent(
                          message: DateUtil.dateToDayMonthHourMinuteString(
                        booking.outTime!,
                      ))),
                  SizedBox(
                      width: 70,
                      child: NeutronTextContent(
                          tooltip: booking.sourceName ?? '',
                          message: booking.sourceName ?? '')),
                  SizedBox(
                      width: 100,
                      child: NeutronTextContent(
                          tooltip: booking.sID ?? '',
                          message: booking.sID ?? '')),
                  SizedBox(
                      width: 80,
                      child: NeutronTextContent(
                          tooltip: booking.name, message: booking.name!)),
                  Container(
                      alignment: Alignment.center,
                      width: 50,
                      child: Tooltip(
                        message: booking.group!
                            ? booking.room
                            : RoomManager().getNameRoomById(booking.room!),
                        child: NeutronTextContent(
                          message: booking.group!
                              ? booking.room!
                              : RoomManager().getNameRoomById(booking.room!),
                        ),
                      )),
                  Container(
                      alignment: Alignment.center,
                      width: 80,
                      child: NeutronTextContent(
                        tooltip: booking.group!
                            ? booking.roomTypeID
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID),
                        message: booking.group!
                            ? booking.roomTypeID!
                            : RoomTypeManager()
                                .getRoomTypeNameByID(booking.roomTypeID),
                      )),
                  SizedBox(
                    width: 50,
                    child: NeutronTextContent(
                        message:
                            DateUtil.dateToDayMonthString(booking.inDate!)),
                  ),
                  SizedBox(
                    width: 50,
                    child: NeutronTextContent(
                        message:
                            DateUtil.dateToDayMonthString(booking.outDate!)),
                  ),
                  SizedBox(
                    width: 45,
                    child: NeutronTextContent(
                        message: booking.lengthStay.toString()),
                  ),
                  SizedBox(
                      width: 100,
                      child: Text(
                        NumberUtil.numberFormat
                            .format(controller.getAverageRoomRate(booking)),
                        textAlign: TextAlign.end,
                        style: NeutronTextStyle.positiveNumber,
                      )),
                  SizedBox(
                      width: 75,
                      child: Text(
                        NumberUtil.numberFormat.format(booking.getRoomCharge()),
                        textAlign: TextAlign.end,
                        style: NeutronTextStyle.positiveNumber,
                      )),
                  SizedBox(
                      width: 75,
                      child: NeutronFormOpenCell(
                          textAlign: TextAlign.end,
                          context: context,
                          form: MinibarForm(booking: booking),
                          text: NumberFormat.decimalPattern()
                              .format(booking.minibar))),
                  SizedBox(
                    width: 95,
                    child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: ExtraHourForm(booking: booking),
                        text: NumberFormat.decimalPattern()
                            .format(booking.extraHour!.total)),
                  ),
                  SizedBox(
                    width: 95,
                    child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: ExtraGuestForm(booking: booking),
                        text: NumberFormat.decimalPattern()
                            .format(booking.extraGuest)),
                  ),
                  SizedBox(
                    width: 115,
                    child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: LaundryForm(booking: booking),
                        text: NumberFormat.decimalPattern()
                            .format(booking.laundry)),
                  ),
                  SizedBox(
                    width: 95,
                    child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: BikeRentalForm(booking: booking),
                        text: NumberFormat.decimalPattern()
                            .format(booking.bikeRental)),
                  ),
                  SizedBox(
                    width: 70,
                    child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: OthersForm(booking: booking),
                        text: NumberFormat.decimalPattern()
                            .format(booking.other)),
                  ),
                  SizedBox(
                      width: 95,
                      child: NeutronFormOpenCell(
                          textAlign: TextAlign.end,
                          context: context,
                          form: OutsideRestaurantForm(booking: booking),
                          text: NumberUtil.numberFormat
                              .format(booking.outsideRestaurant))),
                  SizedBox(
                      width: 150,
                      child: NeutronFormOpenCell(
                          textAlign: TextAlign.end,
                          context: context,
                          form: OutsideRestaurantForm(booking: booking),
                          text: NumberUtil.numberFormat
                              .format(booking.insideRestaurant))),
                  SizedBox(
                      width: 90,
                      child: NeutronFormOpenCell(
                          textAlign: TextAlign.end,
                          context: context,
                          form: OutsideRestaurantForm(booking: booking),
                          text: NumberUtil.numberFormat
                              .format(booking.getRevenueNotDiscout()))),
                  SizedBox(
                    width: 70,
                    child: Text(
                        NumberUtil.numberFormat.format(
                            booking.discount != 0 ? -booking.discount! : 0),
                        textAlign: TextAlign.end,
                        style: booking.discount != 0
                            ? NeutronTextStyle.negativeNumber
                            : NeutronTextStyle.discountDefaultNumber),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => DepositDialog(
                          booking: booking,
                        ),
                      ),
                      child: Text(
                        NumberFormat.decimalPattern()
                            .format(booking.getRevenue()),
                        textAlign: TextAlign.end,
                        style: NeutronTextStyle.totalNumber,
                      ),
                    ),
                  ),
                  Expanded(
                    child: NeutronTextContent(
                      message: NumberFormat.decimalPattern()
                          .format(booking.getTotalAmountCost()),
                      tooltip: NumberFormat.decimalPattern()
                          .format(booking.getTotalAmountCost()),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  SizedBox(
                      width: 40,
                      child: NeutronBookingContextMenu(
                        booking: booking,
                        isGroup: false,
                        backgroundColor: ColorManagement.lightMainBackground,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_MENU),
                      )),
                ],
              ),
            ))
        .toList();
  }

  List<Container> buildListMobile(RevenueReportController controller) {
    return controller.bookings
        .map((booking) => Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8),
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
                    SizedBox(
                      width: 40,
                      child: NeutronTextContent(
                        tooltip: booking.group!
                            ? booking.room
                            : RoomManager().getNameRoomById(booking.room!),
                        message: booking.group!
                            ? booking.room!
                            : RoomManager().getNameRoomById(booking.room!),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 50,
                      child: NeutronTextContent(
                        message: DateUtil.dateToDayMonthString(
                          booking.inDate!,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: InkWell(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => DepositDialog(
                            booking: booking,
                          ),
                        ),
                        child: NeutronTextContent(
                          message: NumberUtil.moneyFormat
                              .format(booking.getRevenue()),
                          color: ColorManagement.positiveText,
                        ),
                      ),
                    )
                  ],
                ),
                children: [
                  InkWell(
                    onTap: () {
                      if (booking.isVirtual!) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                VirtualBookingDialog(booking: booking));
                      }
                      if (booking.group!) {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                GroupDialog(booking: booking));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                BookingDialog(booking: booking));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ROOMTYPE),
                              )),
                              Expanded(
                                  child: NeutronTextContent(
                                tooltip: booking.group!
                                    ? booking.roomTypeID
                                    : RoomTypeManager().getRoomTypeNameByID(
                                        booking.roomTypeID!),
                                message: booking.group!
                                    ? booking.roomTypeID!
                                    : RoomTypeManager().getRoomTypeNameByID(
                                        booking.roomTypeID!),
                              ))
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TIME),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                    message:
                                        DateUtil.dateToDayMonthHourMinuteString(
                                  booking.outTime!,
                                )),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_OUT),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                    message: DateUtil.dateToDayMonthString(
                                        booking.outDate!)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SOURCE),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                  message: booking.sourceName!,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SID),
                              )),
                              Expanded(
                                child:
                                    NeutronTextContent(message: booking.sID!),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_LENGTH_STAY_COMPACT),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                    message: booking.lengthStay.toString()),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                    message: NumberUtil.numberFormat.format(
                                        controller
                                            .getAverageRoomRate(booking))),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_ROOM_CHARGE_COMPACT),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                    message: NumberUtil.numberFormat
                                        .format(booking.getRoomCharge())),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                              )),
                              Expanded(
                                  child: NeutronFormOpenCell(
                                      context: context,
                                      form: MinibarForm(booking: booking),
                                      text: NumberFormat.decimalPattern()
                                          .format(booking.minibar)))
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE),
                              )),
                              Expanded(
                                child: NeutronFormOpenCell(
                                    context: context,
                                    form: ExtraHourForm(booking: booking),
                                    text: NumberFormat.decimalPattern()
                                        .format(booking.extraHour!.total)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_EXTRA_GUEST_SERVICE),
                              )),
                              Expanded(
                                child: NeutronFormOpenCell(
                                    context: context,
                                    form: ExtraGuestForm(booking: booking),
                                    text: NumberFormat.decimalPattern()
                                        .format(booking.extraGuest)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                              )),
                              Expanded(
                                child: NeutronFormOpenCell(
                                    context: context,
                                    form: LaundryForm(booking: booking),
                                    text: NumberFormat.decimalPattern()
                                        .format(booking.laundry)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_BIKE_RENTAL_SERVICE),
                              )),
                              Expanded(
                                child: NeutronFormOpenCell(
                                    context: context,
                                    form: BikeRentalForm(booking: booking),
                                    text: NumberFormat.decimalPattern()
                                        .format(booking.bikeRental)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_OTHER),
                              )),
                              Expanded(
                                child: NeutronFormOpenCell(
                                    context: context,
                                    form: OthersForm(booking: booking),
                                    text: NumberFormat.decimalPattern()
                                        .format(booking.other)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_RESTAURANT),
                              )),
                              Expanded(
                                  child: NeutronFormOpenCell(
                                      context: context,
                                      form: OutsideRestaurantForm(
                                          booking: booking),
                                      text: NumberFormat.decimalPattern()
                                          .format(booking.outsideRestaurant)))
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
                              )),
                              Expanded(
                                  child: NeutronFormOpenCell(
                                      context: context,
                                      form: OutsideRestaurantForm(
                                          booking: booking),
                                      text: NumberFormat.decimalPattern()
                                          .format(booking.insideRestaurant)))
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TOTAL),
                              )),
                              Expanded(
                                  child: NeutronFormOpenCell(
                                      context: context,
                                      form: OutsideRestaurantForm(
                                          booking: booking),
                                      text: NumberFormat.decimalPattern()
                                          .format(booking.getRevenue() +
                                              booking.discount!)))
                            ],
                          ),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_DISCOUNT),
                              )),
                              Expanded(
                                child: Text(
                                  booking.discount == 0
                                      ? '0'
                                      : NumberUtil.numberFormat
                                          .format(-booking.discount!),
                                  style: const TextStyle(
                                      color: ColorManagement.negativeText),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SizeManagement.rowSpacing),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_COST_BOOKED),
                              )),
                              Expanded(
                                child: NeutronTextContent(
                                  message: NumberFormat.decimalPattern()
                                      .format(booking.getTotalAmountCost()),
                                  tooltip: NumberFormat.decimalPattern()
                                      .format(booking.getTotalAmountCost()),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SizeManagement.rowSpacing),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ))
        .toList();
  }

  Container buildTitlePc() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          SizedBox(
              width: 95,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding),
                child: NeutronTextTitle(
                  isPadding: false,
                  fontSize: 13,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
                ),
              )),
          SizedBox(
              width: 70,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
              )),
          SizedBox(
              width: 100,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
              )),
          SizedBox(
              width: 80,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
              )),
          SizedBox(
              width: 50,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
              )),
          SizedBox(
              width: 80,
              child: NeutronTextTitle(
                textAlign: TextAlign.center,
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
              )),
          SizedBox(
              width: 50,
              child: NeutronTextTitle(
                isPadding: true,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
              )),
          SizedBox(
              width: 50,
              child: NeutronTextTitle(
                isPadding: true,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT),
              )),
          SizedBox(
              width: 45,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LENGTH_STAY),
              )),
          SizedBox(
              width: 100,
              child: Tooltip(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                child: NeutronTextTitle(
                  textAlign: TextAlign.end,
                  fontSize: 13,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_AVERAGE_ROOM_RATE),
                ),
              )),
          SizedBox(
              width: 75,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
              )),
          SizedBox(
              width: 75,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE_COMPACT),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE_COMPACT),
              )),
          SizedBox(
              width: 115,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
              )),
          SizedBox(
              width: 70,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_RESTAURANT),
              )),
          SizedBox(
              width: 150,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
              )),
          SizedBox(
              width: 90,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_TOTAL_COMPACT),
              )),
          SizedBox(
              width: 70,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DISCOUNT),
              )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            fontSize: 13,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE),
          )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            fontSize: 13,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COST_ROOM),
          )),
          const SizedBox(width: 40)
        ],
      ),
    );
  }

  Container buildTitleMobile() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          Expanded(
            child: NeutronTextContent(
              fontSize: 13,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            ),
          ),
          SizedBox(
            width: 40,
            child: NeutronTextContent(
              fontSize: 13,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 50,
            child: NeutronTextContent(
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
              fontSize: 13,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
            ),
          ),
          SizedBox(
            width: 90 + SizeManagement.cardInsideHorizontalPadding,
            child: NeutronTextContent(
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE),
              fontSize: 13,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE),
            ),
          ),
        ],
      ),
    );
  }
}
