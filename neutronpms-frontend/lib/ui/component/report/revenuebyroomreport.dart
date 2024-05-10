import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/report/revenuebyroomcontroller.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/component/service/costform.dart';
import 'package:ihotel/ui/component/service/electricitywaterdetail.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../ui/component/booking/depositdialog.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutrontablecell.dart';
import '../../controls/neutronwaiting.dart';
import '../service/bikerentalform.dart';
import '../service/extraguestform.dart';
import '../service/extrahourform.dart';
import '../service/laundryform.dart';
import '../service/minibarform.dart';
import '../service/othersform.dart';

class RevenueByRoomReportDialog extends StatefulWidget {
  const RevenueByRoomReportDialog({Key? key}) : super(key: key);

  @override
  State<RevenueByRoomReportDialog> createState() =>
      _RevenueByRoomReportDialogState();
}

class _RevenueByRoomReportDialogState extends State<RevenueByRoomReportDialog> {
  final RevenueByRoomReportController revenueReportController =
      RevenueByRoomReportController();
  final ScrollController _scrollController = ScrollController();
  final now = Timestamp.now().toDate();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    late double widthOut, widthIn;
    const double height = kHeight;
    widthOut = kLargeWidth + 350;
    widthIn = kLargeWidth + 1000;

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: widthOut,
            height: height,
            child: ChangeNotifierProvider.value(
                value: revenueReportController,
                child: Consumer<RevenueByRoomReportController>(
                    builder: (_, controller, __) {
                  return Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      appBar: AppBar(
                        leadingWidth: isMobile ? 0 : 56,
                        leading: isMobile ? Container() : null,
                        title: isMobile
                            ? null
                            : NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .POPUPMENU_REVENUE_BY_ROOM_REPORT)),
                        backgroundColor: ColorManagement.mainBackground,
                        actions: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.all(8),
                            child: NeutronDropDownCustom(
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_BOOKINGTYPE),
                                childWidget: buildDropDow(controller)),
                          ),
                          Container(
                            width: 110,
                            margin: const EdgeInsets.all(8),
                            child: NeutronDropDownCustom(
                              backgroundColor:
                                  ColorManagement.lightMainBackground,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_STAGE),
                              childWidget: NeutronDropDown(
                                isCenter: true,
                                isPadding: false,
                                value: controller.selectedPeriod,
                                items: controller.periodTypes,
                                onChanged: (value) {
                                  controller.setPeriodType(value);
                                },
                              ),
                            ),
                          ),
                          if (controller.selectedPeriod ==
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.THIS_MONTH)) ...[
                            Container(
                              width: 90,
                              margin: const EdgeInsets.all(8),
                              child: NeutronDropDownCustom(
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_YEAR),
                                childWidget: NeutronDropDown(
                                    isCenter: true,
                                    isPadding: false,
                                    onChanged: (value) {
                                      controller.setYear(value);
                                    },
                                    value: controller.selectYear,
                                    items: controller.years),
                              ),
                            ),
                            Container(
                              width: 55,
                              margin: const EdgeInsets.only(bottom: 8, top: 8),
                              child: NeutronDropDownCustom(
                                backgroundColor:
                                    ColorManagement.lightMainBackground,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_MONTH),
                                childWidget: NeutronDropDown(
                                    isCenter: true,
                                    isPadding: false,
                                    onChanged: (value) {
                                      controller.setMonth(value);
                                    },
                                    value: controller.selectMonth,
                                    items: controller.listMonth),
                              ),
                            ),
                          ],
                          if (controller.selectedPeriod !=
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.THIS_MONTH)) ...[
                            NeutronDatePicker(
                              isMobile: isMobile,
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_START_DATE),
                              colorBackground:
                                  ColorManagement.lightMainBackground,
                              initialDate: controller.startDate,
                              firstDate: controller.startDate
                                  .subtract(const Duration(days: 365)),
                              lastDate: controller.startDate
                                  .add(const Duration(days: 365)),
                              onChange: controller.setStartDate,
                            ),
                            NeutronDatePicker(
                              isMobile: isMobile,
                              colorBackground:
                                  ColorManagement.lightMainBackground,
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_END_DATE),
                              initialDate: controller.endDate,
                              firstDate: controller.startDate,
                              lastDate: controller.startDate
                                  .add(const Duration(days: 31)),
                              onChange: controller.setEndDate,
                            ),
                          ],
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
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => WillPopScope(
                                      onWillPop: () => Future.value(false),
                                      child: const NeutronWaiting()));
                              await controller
                                  .getAllBookingForExporting()
                                  .then((bookings) {
                                ExcelUlti.exportReprotRoom(
                                    controller.mapDataBooking,
                                    controller.dataSetTypeCost,
                                    controller.dataSetMethod,
                                    controller.totalService,
                                    controller.mapPayment,
                                    controller,
                                    controller.startDate,
                                    controller.endDate);
                                Navigator.pop(context);
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
                            width: widthIn,
                            child: Column(
                              children: [
                                const SizedBox(
                                    height: SizeManagement.rowSpacing),
                                buildTitlePc(),
                                Expanded(
                                  child: controller.isLoading!
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color:
                                                  ColorManagement.greenColor),
                                        )
                                      : ListView(
                                          children: buildListPc(controller),
                                        ),
                                ),
                                // const SizedBox(
                                //     height: SizeManagement.rowSpacing),
                                // SizedBox(
                                //   height: 30,
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       IconButton(
                                //           onPressed: controller
                                //               .getRevenueByRoomReportFirstPage,
                                //           icon:
                                //               const Icon(Icons.skip_previous)),
                                //       IconButton(
                                //           onPressed: controller
                                //               .getRevenueByRoomReportPreviousPage,
                                //           icon: const Icon(
                                //               Icons.navigate_before_sharp)),
                                //       IconButton(
                                //           onPressed: controller
                                //               .getRevenueByRoomReportNextPage,
                                //           icon: const Icon(
                                //               Icons.navigate_next_sharp)),
                                //       IconButton(
                                //           onPressed: controller
                                //               .getRevenueByRoomReportLastPage,
                                //           icon: const Icon(Icons.skip_next)),
                                //     ],
                                //   ),
                                // ),
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

  List<Container> buildListPc(RevenueByRoomReportController controller) {
    return controller.mapDataBooking.keys
        .map((key) => Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8),
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
                    Container(
                        alignment: Alignment.center,
                        width: 50,
                        child: Tooltip(
                          message: RoomManager().getNameRoomById(key),
                          child: NeutronTextContent(
                            message: RoomManager().getNameRoomById(key),
                          ),
                        )),
                    const SizedBox(width: 475),
                    SizedBox(
                        width: 100,
                        child: Text(
                          NumberUtil.numberFormat.format(
                              controller.totalService[key]["averageroom"]),
                          textAlign: TextAlign.end,
                          style: NeutronTextStyle.positiveNumber,
                        )),
                    SizedBox(
                        width: 75,
                        child: Text(
                          NumberUtil.numberFormat.format(
                              controller.totalService[key]["priceroom"]),
                          textAlign: TextAlign.end,
                          style: NeutronTextStyle.positiveNumber,
                        )),
                    SizedBox(
                        width: 75,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["minibar"]))),
                    SizedBox(
                      width: 95,
                      child: Text(
                          style: NeutronTextStyle.positiveNumber,
                          textAlign: TextAlign.end,
                          NumberUtil.numberFormat.format(
                              controller.totalService[key]["extra_hour"])),
                    ),
                    SizedBox(
                      width: 95,
                      child: Text(
                          style: NeutronTextStyle.positiveNumber,
                          textAlign: TextAlign.end,
                          NumberUtil.numberFormat.format(
                              controller.totalService[key]["extra_guest"])),
                    ),
                    SizedBox(
                      width: 115,
                      child: Text(
                          style: NeutronTextStyle.positiveNumber,
                          textAlign: TextAlign.end,
                          NumberUtil.numberFormat
                              .format(controller.totalService[key]["laundry"])),
                    ),
                    SizedBox(
                      width: 95,
                      child: Text(
                          style: NeutronTextStyle.positiveNumber,
                          textAlign: TextAlign.end,
                          NumberUtil.numberFormat
                              .format(controller.totalService[key]["bike"])),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                          style: NeutronTextStyle.positiveNumber,
                          textAlign: TextAlign.end,
                          NumberUtil.numberFormat
                              .format(controller.totalService[key]["other"])),
                    ),
                    SizedBox(
                        width: 95,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["restaurant"]))),
                    SizedBox(
                        width: 150,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["inrestaurant"]))),
                    SizedBox(
                        width: 90,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["electricity"]))),
                    SizedBox(
                        width: 90,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["water"]))),
                    SizedBox(
                        width: 90,
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["total"]))),
                    SizedBox(
                      width: 70,
                      child: Text(
                          NumberUtil.numberFormat
                              .format(controller.totalService[key]["discount"]),
                          textAlign: TextAlign.end,
                          style: controller.totalService[key]["discount"] != 0
                              ? NeutronTextStyle.negativeNumber
                              : NeutronTextStyle.discountDefaultNumber),
                    ),
                    Expanded(
                      child: Text(
                        NumberUtil.numberFormat
                            .format(controller.totalService[key]["revenue"]),
                        textAlign: TextAlign.end,
                        style: NeutronTextStyle.positiveNumber,
                      ),
                    ),
                    Expanded(
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat.format(
                                controller.totalService[key]["deposit"]))),
                    Expanded(
                        child: Text(
                            style: NeutronTextStyle.positiveNumber,
                            textAlign: TextAlign.end,
                            NumberUtil.numberFormat
                                .format(controller.totalService[key]["cost"])))
                  ],
                ),
                children: [
                  ...controller.mapDataBooking[key]!
                      .map((booking) => Container(
                            height: SizeManagement.cardHeight,
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Row(
                              children: [
                                const SizedBox(width: 42),
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
                                        tooltip: booking.name,
                                        message: booking.name!)),
                                Container(
                                    alignment: Alignment.center,
                                    width: 80,
                                    child: NeutronTextContent(
                                      tooltip: booking.group!
                                          ? booking.roomTypeID
                                          : RoomTypeManager()
                                              .getRoomTypeNameByID(
                                                  booking.roomTypeID),
                                      message: booking.group!
                                          ? booking.roomTypeID!
                                          : RoomTypeManager()
                                              .getRoomTypeNameByID(
                                                  booking.roomTypeID),
                                    )),
                                SizedBox(
                                  width: 50,
                                  child: NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          booking.inDate!)),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          booking.outDate!)),
                                ),
                                SizedBox(
                                  width: 45,
                                  child: NeutronTextContent(
                                      message: booking.lengthRender.toString()),
                                ),
                                SizedBox(
                                    width: 100,
                                    child: Text(
                                      NumberUtil.numberFormat.format(controller
                                          .getAverageRoomRate(booking)),
                                      textAlign: TextAlign.end,
                                      style: NeutronTextStyle.positiveNumber,
                                    )),
                                SizedBox(
                                    width: 75,
                                    child: Text(
                                      NumberUtil.numberFormat
                                          .format(booking.totalRoomCharge),
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
                                          .format(
                                              booking.extraHour?.total ?? 0)),
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
                                        form: OutsideRestaurantForm(
                                            booking: booking),
                                        text: NumberUtil.numberFormat.format(
                                            booking.outsideRestaurant))),
                                SizedBox(
                                    width: 150,
                                    child: NeutronFormOpenCell(
                                        textAlign: TextAlign.end,
                                        context: context,
                                        form: InsideRestaurantForm(
                                            booking: booking),
                                        text: NumberUtil.numberFormat
                                            .format(booking.insideRestaurant))),
                                SizedBox(
                                    width: 90,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ElectricityWaterDetail(
                                            booking: booking,
                                          ),
                                        );
                                      },
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.end,
                                          message: NumberUtil.numberFormat
                                              .format(booking.electricity)),
                                    )),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ElectricityWaterDetail(
                                        booking: booking,
                                        isElectricity: false,
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                      width: 90,
                                      child: NeutronTextContent(
                                          textAlign: TextAlign.end,
                                          message: NumberUtil.numberFormat
                                              .format(booking.water))),
                                ),
                                SizedBox(
                                    width: 90,
                                    child: NeutronFormOpenCell(
                                        textAlign: TextAlign.end,
                                        context: context,
                                        form: OutsideRestaurantForm(
                                            booking: booking),
                                        text: NumberUtil.numberFormat.format(
                                            booking.getServiceCharge() +
                                                (booking.totalRoomCharge ??
                                                    0)))),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                      NumberUtil.numberFormat.format(
                                          booking.discount != 0
                                              ? -booking.discount!
                                              : 0),
                                      textAlign: TextAlign.end,
                                      style: booking.discount != 0
                                          ? NeutronTextStyle.negativeNumber
                                          : NeutronTextStyle
                                              .discountDefaultNumber),
                                ),
                                Expanded(
                                  child: Text(
                                    NumberFormat.decimalPattern().format(
                                        booking.getServiceCharge() +
                                            (booking.totalRoomCharge ?? 0) -
                                            booking.discount!),
                                    textAlign: TextAlign.end,
                                    style: NeutronTextStyle.totalNumber,
                                  ),
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
                                      "${NumberFormat.decimalPattern().format(booking.deposit)} -${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOR_GRUOP) : ""}",
                                      textAlign: TextAlign.end,
                                      style: NeutronTextStyle.totalNumber,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => CostBookingDialog(
                                            booking: booking));
                                  },
                                  child: Text(
                                      textAlign: TextAlign.end,
                                      style: NeutronTextStyle.totalNumber,
                                      NumberFormat.decimalPattern()
                                          .format(booking.totalCost)),
                                )),
                                const SizedBox(width: 30)
                              ],
                            ),
                          ))
                      .toList()
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
              width: 50,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
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
                    UITitleCode.TABLEHEADER_ELECTRICITY),
              )),
          SizedBox(
              width: 90,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WATER),
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
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT),
          )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            fontSize: 13,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COST_ROOM),
          )),
          const SizedBox(width: 30)
        ],
      ),
    );
  }

  DropdownButtonHideUnderline buildDropDow(
          RevenueByRoomReportController controller) =>
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: ColorManagement.mainBackground,
          dropdownColor: ColorManagement.lightMainBackground,
          isExpanded: true,
          items: controller.listTypeBooking
              .map((item) => DropdownMenuItem(
                    value: item,
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) => Row(
                        children: [
                          Checkbox(
                            fillColor: const MaterialStatePropertyAll(
                                ColorManagement.greenColor),
                            value:
                                controller.selectedTypeBooking.contains(item),
                            onChanged: (value) {
                              controller.setBookingType(item, value!);
                              menuSetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeutronTextContent(message: item),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          value: controller.selectedTypeBooking.isEmpty
              ? null
              : controller.selectedTypeBooking.first,
          onChanged: (value) {},
        ),
      );
}
