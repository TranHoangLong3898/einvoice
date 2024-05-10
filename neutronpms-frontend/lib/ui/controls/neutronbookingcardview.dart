import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
// import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../controller/report/bookinglistcontroller.dart';
import '../../manager/roomtypemanager.dart';
import '../../modal/status.dart';
import '../../util/materialutil.dart';
import '../../util/pdfutil.dart';
import 'neutronbookingcontextmenu.dart';

class NeutronBookingCardView extends StatelessWidget {
  final BookingListController controller;

  const NeutronBookingCardView({Key? key, required this.controller})
      : super(key: key);

  Widget expansionTittle(BuildContext context) {
    final children = controller
        .getBookingsByFilter()!
        .map((booking) => Container(
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
                                : RoomManager()
                                    .getNameRoomById(booking.room!))),
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
                    onTap: () {
                      // showDialog(
                      //   context: context,
                      //   builder: (context) =>

                      //   BookingDialog(booking: booking));
                    },
                    child: Column(
                      children: [
                        if (!controller.chekNoRoomAndSource()) ...[
                          const SizedBox(height: SizeManagement.rowSpacing),
                          Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TYPE),
                              )),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: NeutronTextContent(
                                      tooltip: booking.sID! == booking.id!
                                          ? booking.roomTypeID!
                                          : RoomTypeManager()
                                              .getRoomTypeNameByID(
                                                  booking.roomTypeID!),
                                      message: booking.sID! == booking.id!
                                          ? booking.roomTypeID!
                                          : RoomTypeManager()
                                              .getRoomTypeNameByID(
                                                  booking.roomTypeID!)),
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
                                    UITitleCode.TABLEHEADER_BREAKFAST),
                              )),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: NeutronTextContent(
                                    message: booking.sID == booking.id
                                        ? controller.mapBreakFast![booking.sID]
                                            .toString()
                                        : booking.breakfast!
                                            ? MessageUtil.getMessageByCode(
                                                MessageCodeUtil.TEXTALERT_YES)
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil.TEXTALERT_NO),
                                    tooltip: booking.sID == booking.id
                                        ? controller.mapBreakFast![booking.sID]
                                            .toString()
                                        : booking.breakfast!
                                            ? MessageUtil.getMessageByCode(
                                                MessageCodeUtil.TEXTALERT_YES)
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil.TEXTALERT_NO),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
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
                                    message: booking.sourceName!),
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
                        if (controller.isShowNote &&
                            !controller.chekNoRoomAndSource())
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
                                    tooltip:
                                        controller.mapNotes[booking.sID] ?? "",
                                    message:
                                        controller.mapNotes[booking.sID] ?? "",
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
                                  final confirm =
                                      await MaterialUtil.showConfirm(
                                          context,
                                          MessageUtil.getMessageByCode(
                                              MessageCodeUtil
                                                  .CONFIRM_SHOW_PRICE));
                                  if (confirm == null) return;
                                  Printing.layoutPdf(
                                      onLayout: (PdfPageFormat format) async =>
                                          (booking.status ==
                                                      BookingStatus.booked
                                                  ? (await PDFUtil
                                                      .buildCheckInPDFDoc(
                                                          booking, confirm,
                                                          pngBytes:
                                                              GeneralManager
                                                                  .policyHotel))
                                                  : (await PDFUtil
                                                      .buildCheckOutPDFDoc(
                                                          booking,
                                                          confirm,
                                                          true)))
                                              .save());
                                },
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
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
        .toList();
    return ListView(children: children);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.getBookingsByFilter() == null) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManagement.greenColor),
      );
    }
    if (controller.getBookingsByFilter()!.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_NO_BOOKINGS)),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 60),
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
          const SizedBox(height: SizeManagement.cardOutsideVerticalPadding),
          Expanded(child: expansionTittle(context)),
        ],
      ),
    );
  }
}
