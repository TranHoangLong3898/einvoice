import 'package:flutter/material.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/report/bookingcanapprovercontroller.dart';
import '../../../manager/roommanager.dart';
import '../../../util/dateutil.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';

class BookingCanApproverDialog extends StatefulWidget {
  const BookingCanApproverDialog({Key? key}) : super(key: key);

  @override
  State<BookingCanApproverDialog> createState() =>
      _BookingCanApproverDialogState();
}

class _BookingCanApproverDialogState extends State<BookingCanApproverDialog> {
  BookingCanApproverController? controller;
  @override
  void initState() {
    controller ??= BookingCanApproverController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          height: kHeight,
          width: width,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<BookingCanApproverController>(
              builder: (_, controller, __) => controller.isLoading!
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor))
                  : Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      appBar: AppBar(actions: [
                        Container(
                          width: isMobile ? 70 : 80,
                          margin: const EdgeInsets.all(8),
                          child: NeutronDropDownCustom(
                            childWidget: NeutronDropDown(
                              isCenter: true,
                              isPadding: false,
                              onChanged: controller.setStatus,
                              value: controller.stastus,
                              items: controller.listStatus,
                            ),
                          ),
                        ),
                        NeutronDatePicker(
                          isMobile: isMobile,
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_START_DATE),
                          initialDate: controller.startDate,
                          firstDate: controller.now!
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              controller.now!.add(const Duration(days: 365)),
                          onChange: controller.setStartDate,
                        ),
                        if (controller.startDate != null)
                          NeutronDatePicker(
                            isMobile: isMobile,
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_END_DATE),
                            initialDate: controller.endDate,
                            firstDate: controller.startDate,
                            lastDate: controller.startDate!
                                .add(const Duration(days: 30)),
                            onChange: controller.setEndDate,
                          ),
                        NeutronBlurButton(
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_REFRESH),
                          icon: Icons.refresh,
                          onPressed: controller.loadBooking,
                        ),
                      ]),
                      body: Column(children: [
                        isMobile ? buildTitleMobile() : buildTitlePc(),
                        Expanded(
                            child: ListView(
                                children: controller.bookings
                                    .map((booking) => isMobile
                                        ? buildContentMobile(booking)
                                        : buildContentPc(booking))
                                    .toList())),
                        pagination
                      ]),
                    ),
            ),
          )),
    );
  }

  Row get pagination => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller!.getAccountingFirstPage,
              icon: const Icon(Icons.skip_previous)),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller!.getAccountingPreviousPage,
              icon: const Icon(
                Icons.navigate_before_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller!.getAccountingNextPage,
              icon: const Icon(
                Icons.navigate_next_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: controller!.getAccountingLastPage,
              icon: const Icon(Icons.skip_next)),
        ],
      );

  Container buildContentPc(Booking booking) => Container(
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
                    tooltip: booking.name,
                    message: booking.name!,
                  ),
                ),
                //room
                Container(
                    constraints:
                        const BoxConstraints(maxWidth: 50, minWidth: 50),
                    child: NeutronTextContent(
                        tooltip: booking.sID == booking.id
                            ? booking.room
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
                //confirm
                Container(
                  width: 35,
                  alignment: Alignment.center,
                  child: IconButton(
                      onPressed: () async {
                        await booking.updateStatus(booking).then((result) {
                          if (result != MessageCodeUtil.SUCCESS) {
                            MaterialUtil.showAlert(
                                context, MessageUtil.getMessageByCode(result));
                          } else {
                            MaterialUtil.showSnackBar(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS));
                          }
                        });
                      },
                      icon: const Icon(Icons.app_registration_outlined)),
                ),
                //menu
                Container(
                  width: 35,
                  alignment: Alignment.center,
                  child: NeutronBookingContextMenu(
                    isStatus: false,
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

  Container buildTitlePc() => Container(
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

  SizedBox buildTitleMobile() => SizedBox(
        height: 50,
        child: Column(
          children: [
            const SizedBox(height: SizeManagement.cardOutsideVerticalPadding),
            //title
            Row(
              children: [
                const SizedBox(
                    width: SizeManagement.cardInsideHorizontalPadding +
                        SizeManagement.cardOutsideHorizontalPadding),
                SizedBox(
                  width: 100,
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NAME),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 50,
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROOM),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: NeutronTextContent(
                    textOverflow: TextOverflow.visible,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TOTAL),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SizeManagement.cardOutsideVerticalPadding),
            // Expanded(child: expansionTittle(context)),
          ],
        ),
      );

  Container buildContentMobile(Booking booking) => Container(
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
                        color: ColorManagement.positiveText,
                        message: NumberUtil.moneyFormat
                            .format(booking.getTotalCharge())),
                  )),
            ],
          ),
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
                    child: NeutronTextContent(message: booking.sourceName!),
                  ),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: NeutronTextContent(
                        message:
                            DateUtil.dateToDayMonthString(booking.inDate!)),
                  ),
                )
              ],
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            Row(
              children: [
                Expanded(
                    child: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: NeutronTextContent(
                        message:
                            DateUtil.dateToDayMonthString(booking.outDate!)),
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
                        message:
                            NumberUtil.moneyFormat.format(booking.deposit)),
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
                            (booking.getRoomCharge() / booking.lengthStay!)
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
                        message:
                            NumberUtil.moneyFormat.format(booking.discount)),
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
            Row(
              children: [
                Expanded(
                  child: IconButton(
                      onPressed: () async {
                        await booking.updateStatus(booking).then((result) {
                          if (result != MessageCodeUtil.SUCCESS) {
                            MaterialUtil.showAlert(
                                context, MessageUtil.getMessageByCode(result));
                          } else {
                            MaterialUtil.showSnackBar(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS));
                          }
                        });
                      },
                      icon: const Icon(Icons.app_registration_outlined)),
                ),
                Expanded(
                  child: NeutronBookingContextMenu(
                    icon: Icons.menu_outlined,
                    isStatus: false,
                    booking: booking,
                    backgroundColor: ColorManagement.lightMainBackground,
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
                  ),
                ),
              ],
            )
          ],
        ),
      );
}
