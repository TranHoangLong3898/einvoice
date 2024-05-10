import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/management/reportmanagement/reportbreakfastmanagementcontroller.dart';
import '../../../../manager/roommanager.dart';
import '../../../../modal/booking.dart';
import '../../../../modal/status.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/pdfutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../controls/neutronbookingcontextmenu.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../booking/bookingdialog.dart';

class ReportBreakfastManagementDialog extends StatefulWidget {
  const ReportBreakfastManagementDialog({Key? key}) : super(key: key);

  @override
  State<ReportBreakfastManagementDialog> createState() =>
      _ReportBreakfastManagementDialogState();
}

class _ReportBreakfastManagementDialogState
    extends State<ReportBreakfastManagementDialog> {
  ReprtBreakfastManagementController? controller;
  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  void initState() {
    controller ??= ReprtBreakfastManagementController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    const double height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<ReprtBreakfastManagementController>.value(
          value: controller!,
          child: Consumer<ReprtBreakfastManagementController>(
            builder: (_, controller, __) {
              return Scaffold(
                floatingActionButton: floatingActionButton(controller),
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  backgroundColor: ColorManagement.mainBackground,
                  title: !isMobile
                      ? Text(
                          UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MEALS))
                      : null,
                  actions: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.all(8),
                      child: NeutronDropDownCustom(
                        backgroundColor: ColorManagement.lightMainBackground,
                        label: MessageUtil.getMessageByCode(
                            MessageCodeUtil.STATISTIC_MEALS),
                        childWidget: NeutronDropDown(
                          isCenter: true,
                          isPadding: false,
                          onChanged: controller.setMeal,
                          value: controller.selectMeal,
                          items: controller.meals,
                        ),
                      ),
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
                body: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor))
                    : Stack(children: [
                        Container(
                            margin: EdgeInsets.only(bottom: isMobile ? 20 : 90),
                            child: Column(
                              children: [
                                const SizedBox(
                                    height: SizeManagement
                                        .cardOutsideVerticalPadding),
                                isMobile ? buildTitleMobile() : buildTitlePc(),
                                Expanded(
                                    child: ListView(
                                        children: controller.bookings
                                            .map(
                                              (booking) => isMobile
                                                  ? buildContentMobile(booking)
                                                  : buildContentPC(booking),
                                            )
                                            .toList())),
                                const SizedBox(
                                    height: SizeManagement
                                        .cardOutsideVerticalPadding),
                              ],
                            )),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
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
          ReprtBreakfastManagementController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.redColor,
        mini: true,
        tooltip:
            UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
        onPressed: () async {
          await controller.exportToExcel().then((value) {
            if (value.isEmpty) return;
            ExcelUlti.exportBookingBreakfast(value, controller.selectMeal);
          });
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
              flex: 2,
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
              flex: 3,
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
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_QUANTITY),
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
            const SizedBox(width: 70),
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
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_GUEST_QUANTITY),
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
                        color: ColorManagement.positiveText,
                        message: NumberUtil.moneyFormat
                            .format(booking.adult! + booking.child!)),
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
        height: SizeManagement.cardHeight,
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //room
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding, right: 4),
                child: NeutronTextContent(
                    tooltip: booking.sID == booking.id
                        ? booking.room
                        : RoomManager().getNameRoomById(booking.room!),
                    message: booking.sID == booking.id
                        ? booking.room!
                        : RoomManager().getNameRoomById(booking.room!)),
              ),
            ),
            //name
            Expanded(
              flex: 3,
              child: NeutronTextContent(
                tooltip: booking.name,
                message: booking.name!,
              ),
            ),
            //guest
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextContent(
                  textAlign: TextAlign.center,
                  message: (booking.adult! + booking.child!).toString()),
            ),
            //phone
            Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 100),
              child: NeutronTextContent(message: booking.phone!),
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
            // ///BreakFast
            // Container(
            //     constraints: const BoxConstraints(maxWidth: 50, minWidth: 50),
            //     child: NeutronTextContent(
            //       message: booking.breakfast
            //           ? MessageUtil.getMessageByCode(
            //               MessageCodeUtil.TEXTALERT_YES)
            //           : MessageUtil.getMessageByCode(
            //               MessageCodeUtil.TEXTALERT_NO),
            //       tooltip: booking.breakfast
            //           ? MessageUtil.getMessageByCode(
            //               MessageCodeUtil.TEXTALERT_YES)
            //           : MessageUtil.getMessageByCode(
            //               MessageCodeUtil.TEXTALERT_NO),
            //     )),
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
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_MENU),
              ),
            ),
          ],
        ),
      );
}
