import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/report/bookinglistcontroller.dart';
import '../../../ui/controls/neutronbookinglist.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrondropdown.dart';

class BookingListDialog extends StatefulWidget {
  final int type;

  const BookingListDialog({Key? key, required this.type}) : super(key: key);

  @override
  State<BookingListDialog> createState() => _BookingListDialogState();
}

class _BookingListDialogState extends State<BookingListDialog> {
  BookingListController? controller;
  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  void initState() {
    controller ??= BookingListController(widget.type);
    controller!.initializePageIndex();
    super.initState();
  }

  Widget getTotalRow() {
    num totalRoomCharge = 0;
    num totalDeposit = 0;
    num totalRemaining = 0;
    num totalCharge = 0;
    for (var booking in controller!.bookings) {
      totalDeposit += booking.deposit!;
      totalRemaining += booking.getRemaining()!;
      totalCharge += booking.getTotalCharge()!;
      totalRoomCharge += booking.getRoomCharge();
    }
    final isMobile = ResponsiveUtil.isMobile(context);
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, offset: Offset(0, 3), blurRadius: 4)
          ],
          color: ColorManagement.greenColor,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //deposit total
          if (!isMobile)
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT)}: ${NumberUtil.numberFormat.format(totalDeposit)}",
              ),
            )),
          //room charge total
          if (!isMobile)
            Expanded(
                child: Center(
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL)}: ${NumberUtil.numberFormat.format(totalRoomCharge)}",
              ),
            )),
          //charge total
          Expanded(
              child: Center(
            child: NeutronTextTitle(
              fontSize: isMobile ? 14 : null,
              isPadding: false,
              message: isMobile
                  ? "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_COMPACT)}: ${NumberUtil.moneyFormat.format(totalCharge)}"
                  : "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(totalCharge)}",
            ),
          )),
          //remaining total
          Expanded(
              child: Center(
            child: NeutronTextTitle(
              fontSize: isMobile ? 14 : null,
              isPadding: false,
              message: isMobile
                  ? "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN)}: ${NumberUtil.moneyFormat.format(totalRemaining)}"
                  : "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN)}: ${NumberUtil.numberFormat.format(totalRemaining)}",
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth + 130;
    const double height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<BookingListController>.value(
          value: controller!,
          child: Consumer<BookingListController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor));
              }
              return Scaffold(
                floatingActionButton: controller.chekNoRoomAndSource()
                    ? null
                    : floatingActionButton(controller),
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  automaticallyImplyLeading: !isMobile,
                  backgroundColor: ColorManagement.mainBackground,
                  title: Text(
                      "${controller.getTitle()} - ${controller.getLengthBookings}",
                      style: Theme.of(context).textTheme.bodyMedium),
                  actions: [
                    if (!controller.chekNoRoomAndSource()) ...[
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
                      if (widget.type == BookingListType.stayToday)
                        Container(
                          width: 90,
                          margin: const EdgeInsets.all(8),
                          child: NeutronDropDownCustom(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_BREAKFAST),
                            childWidget: NeutronDropDown(
                              isCenter: true,
                              isPadding: false,
                              onChanged: controller.setStatusBreakFast,
                              value: controller.statusBreakFast,
                              items: controller.listBreakFast,
                            ),
                          ),
                        ),
                      if (widget.type != BookingListType.stayToday) ...[
                        NeutronDatePicker(
                          isMobile: isMobile,
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_START_DATE),
                          initialDate: controller.startDate,
                          firstDate: controller.now
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              controller.now.add(const Duration(days: 365)),
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
                              .add(const Duration(days: 7)),
                          onChange: (picked) {
                            controller.setEndDate(picked);
                          },
                        ),
                      ],
                      NeutronBlurButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_REFRESH),
                        icon: Icons.refresh,
                        onPressed: () {
                          controller.loadDataBooking();
                        },
                      )
                    ],
                    IconButton(
                      onPressed: () {
                        controller.setFilter();
                      },
                      icon: const Icon(Icons.filter_alt_outlined),
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_FILTER),
                    )
                  ],
                ),
                body: Stack(children: [
                  Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 20 : 90),
                      child: NeutronBookingList(controller: controller)),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          if (!controller.chekNoRoomAndSource())
                            SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed:
                                          controller.getBookingsPreviousPage,
                                      icon: const Icon(
                                          Icons.navigate_before_sharp)),
                                  IconButton(
                                      onPressed: controller.getBookingsNextPage,
                                      icon: const Icon(
                                          Icons.navigate_next_sharp)),
                                ],
                              ),
                            ),
                          getTotalRow()
                        ],
                      ))
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  FloatingActionButton floatingActionButton(BookingListController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.redColor,
        mini: true,
        tooltip:
            UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
        onPressed: () async {
          await controller.exportToExcel().then((value) {
            if (value.isEmpty) return;
            ExcelUlti.exportInOutStayingBooking(controller);
          });
        },
        child: const Icon(Icons.file_present_rounded),
      );
}
