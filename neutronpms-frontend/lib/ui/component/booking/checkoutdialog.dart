// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/einvoice/generateeinvoicecontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/booking/pricedialog.dart';
import 'package:ihotel/ui/component/einvoice/generateeinvoicedialog.dart';
import 'package:ihotel/ui/component/service/electricitywaterdetail.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/excelulti.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/booking/checkoutcontroller.dart';
import '../../../manager/usermanager.dart';
import '../../../modal/status.dart';
import '../../../ui/component/booking/discountdialog.dart';
import '../../../ui/component/booking/transferdialog.dart';
import '../../../ui/component/service/bikerentalform.dart';
import '../../../ui/component/service/extraguestform.dart';
import '../../../ui/component/service/extrahourform.dart';
import '../../../ui/component/service/laundryform.dart';
import '../../../ui/component/service/minibarform.dart';
import '../../../ui/component/service/othersform.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../controls/neutronshowconfigdialog.dart';
import '../../controls/neutrontextstyle.dart';
import '../service/costform.dart';
import 'depositdialog.dart';

class CheckOutDialog extends StatefulWidget {
  final Booking? booking;
  final Booking? basicBookings;
  final bool isShowCheckoutButton;
  const CheckOutDialog({
    Key? key,
    this.booking,
    this.isShowCheckoutButton = true,
    this.basicBookings,
  }) : super(key: key);

  @override
  State<CheckOutDialog> createState() => _CheckOutDialogState();
}

class _CheckOutDialogState extends State<CheckOutDialog> {
  CheckOutController? controller;

  @override
  void initState() {
    controller ??= CheckOutController(widget.booking!);
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = kMobileWidth;
    double columnWidth = dialogWidth / 2;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: dialogWidth,
        height: kHeight,
        child: ChangeNotifierProvider<CheckOutController>.value(
          value: controller!,
          child: Consumer<CheckOutController>(builder: (_, controller, __) {
            final booking = controller.booking;
            return controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor),
                  )
                : Stack(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(
                              top: SizeManagement.cardOutsideHorizontalPadding),
                          alignment: Alignment.topCenter,
                          child: NeutronTextHeader(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SUMMARY))),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: (booking.status == BookingStatus.booked &&
                                    !booking.isVirtual!)
                                ? 10
                                : 60,
                            top: 30),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                margin: const EdgeInsets.symmetric(
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding,
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: ExpansionTile(
                                  initiallyExpanded:
                                      !UserManager.canSeeAccounting(),
                                  tilePadding: const EdgeInsets.only(left: 8),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: NeutronTextContent(
                                            textOverflow: TextOverflow.clip,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_REVENUE)),
                                      ),
                                      Expanded(
                                        child: NeutronTextContent(
                                            message: NumberUtil.numberFormat
                                                .format(
                                                    booking.getTotalCharge())),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    DataTable(
                                        showCheckboxColumn: false,
                                        columnSpacing: 5,
                                        horizontalMargin: 5,
                                        columns: <DataColumn>[
                                          //name
                                          DataColumn(
                                            label: Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: SizeManagement
                                                      .cardInsideHorizontalPadding),
                                              width: columnWidth,
                                              child: NeutronTextContent(
                                                message: booking.name!,
                                                tooltip: booking.name,
                                              ),
                                            ),
                                          ),
                                          //room
                                          DataColumn(
                                            label: NeutronTextContent(
                                              message: RoomManager()
                                                  .getNameRoomById(
                                                      booking.room!),
                                            ),
                                          ),
                                        ],
                                        rows: [
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_ROOM_CHARGE_FULL)),
                                              )),
                                              DataCell(InkWell(
                                                onTap: () {
                                                  if (booking.bookingType ==
                                                      BookingType.monthly) {
                                                    return;
                                                  }
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) => PriceDialog(
                                                          isReadonly: true,
                                                          priceBooking:
                                                              booking.price,
                                                          staysday: DateUtil
                                                              .getStaysDay(
                                                                  booking
                                                                      .inDate!,
                                                                  booking
                                                                      .outDate!)));
                                                },
                                                child: NeutronTextContent(
                                                    color: ColorManagement
                                                        .positiveText,
                                                    message: NumberUtil
                                                        .numberFormat
                                                        .format(booking
                                                            .getRoomCharge())),
                                              )),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: ExtraHourForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TOOLTIP_EXTRA_HOUR)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking.extraHour!
                                                              .total ??
                                                          0))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: MinibarForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_MINIBAR_SERVICE)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.minibar))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: InsideRestaurantForm(
                                                      booking: booking),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: UITitleUtil
                                                          .getTitleByCode(
                                                              UITitleCode
                                                                  .TOOLTIP_RESTAURANT),
                                                      style: NeutronTextStyle
                                                          .content,
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                '\n(${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_INSIDE_HOTEL)})',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic))
                                                      ]),
                                                  maxLines: 2,
                                                ),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .insideRestaurant))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: OutsideRestaurantForm(
                                                      booking: booking),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: UITitleUtil
                                                          .getTitleByCode(
                                                              UITitleCode
                                                                  .TOOLTIP_RESTAURANT),
                                                      style: NeutronTextStyle
                                                          .content,
                                                      children: [
                                                        TextSpan(
                                                            text:
                                                                '\n(${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_OUTSIDE_HOTEL)})',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic))
                                                      ]),
                                                  maxLines: 2,
                                                ),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .outsideRestaurant))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: ExtraGuestForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_EXTRA_GUEST_SERVICE)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.extraGuest))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: LaundryForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_LAUNDRY_SERVICE)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.laundry))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: BikeRentalForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_BIKE_RENTAL_SERVICE)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.bikeRental))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: OthersForm(
                                                    booking: booking,
                                                  ),
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_OTHER)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking.other))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ElectricityWaterDetail(
                                                  booking: controller.booking,
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_ELECTRICITY)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking
                                                          .electricity))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ElectricityWaterDetail(
                                                        booking:
                                                            controller.booking,
                                                        isElectricity: false),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_WATER)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .positiveText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(booking.water))),
                                            ],
                                          ),
                                          DataRow(
                                            onSelectChanged: (value) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DiscountDialog(
                                                  booking: booking,
                                                ),
                                              );
                                            },
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_DISCOUNT)),
                                              )),
                                              DataCell(NeutronTextContent(
                                                  color: ColorManagement
                                                      .negativeText,
                                                  message: NumberUtil
                                                      .numberFormat
                                                      .format(
                                                          booking.discount))),
                                            ],
                                          ),
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardInsideHorizontalPadding),
                                                child: NeutronTextContent(
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_TOTAL_CHARGE),
                                                ),
                                              )),
                                              DataCell(NeutronTextContent(
                                                color: ColorManagement
                                                    .positiveText,
                                                message: NumberUtil.numberFormat
                                                    .format(booking
                                                        .getTotalCharge()),
                                              )),
                                            ],
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                              if (UserManager.canSeeAccounting() &&
                                  !booking.isVirtual!) ...[
                                InkWell(
                                  onTap: () async {
                                    await showDialog<String>(
                                        builder: (ctx) =>
                                            CostBookingDialog(booking: booking),
                                        context: context);
                                  },
                                  child: Container(
                                    height: SizeManagement.cardHeight,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            SizeManagement.borderRadius8),
                                        color: ColorManagement
                                            .lightMainBackground),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: SizeManagement
                                            .cardOutsideVerticalPadding,
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: NeutronTextContent(
                                              textOverflow: TextOverflow.clip,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_ACCOUNTING)),
                                        ),
                                        SizedBox(
                                          width: 145,
                                          child: NeutronTextContent(
                                              message: NumberUtil.numberFormat
                                                  .format(widget.basicBookings!
                                                      .totalCost)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: SizeManagement.cardHeight,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: SizeManagement
                                          .cardOutsideVerticalPadding,
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: NeutronTextContent(
                                            textOverflow: TextOverflow.clip,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_PROFIT)),
                                      ),
                                      SizedBox(
                                        width: 145,
                                        child: NeutronTextContent(
                                            message: NumberUtil.numberFormat
                                                .format(
                                                    (booking.getTotalCharge()! -
                                                        widget.basicBookings!
                                                            .totalCost!))),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                margin: const EdgeInsets.symmetric(
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding,
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: ExpansionTile(
                                  initiallyExpanded:
                                      !UserManager.canSeeAccounting(),
                                  tilePadding: const EdgeInsets.only(left: 8),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: NeutronTextContent(
                                            textOverflow: TextOverflow.clip,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_PAYMENT)),
                                      ),
                                      Expanded(
                                        child: NeutronTextContent(
                                            message:
                                                "${booking.deposit}/${(booking.getTotalCharge() ?? 0) + booking.transferred!}"),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    if (booking.transferred! > 0)
                                      InkWell(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                TransferDialog(
                                              booking: booking,
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: SizeManagement
                                                      .cardInsideHorizontalPadding),
                                              child: NeutronTextContent(
                                                message: UITitleUtil
                                                    .getTitleByCode(UITitleCode
                                                        .TABLEHEADER_TRANSFERRED),
                                              ),
                                            )),
                                            Expanded(
                                                child: NeutronTextContent(
                                              message: NumberUtil.numberFormat
                                                  .format(booking.transferred),
                                            ))
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => DepositDialog(
                                            booking: booking,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: SizeManagement
                                                    .cardInsideHorizontalPadding),
                                            child: NeutronTextContent(
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_TOTAL_PAYMENT),
                                            ),
                                          )),
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: NumberUtil.numberFormat
                                                .format(booking.deposit),
                                          ))
                                        ],
                                      ),
                                    ),
                                    if (booking.transferring! > 0) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: SizeManagement
                                                    .cardInsideHorizontalPadding),
                                            child: NeutronTextContent(
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_TRANSFERRING),
                                            ),
                                          )),
                                          Expanded(
                                              child: NeutronTextContent(
                                            message: NumberUtil.numberFormat
                                                .format(booking.transferring),
                                          ))
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardInsideHorizontalPadding),
                                          child: NeutronTextContent(
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_REMAIN),
                                          ),
                                        )),
                                        Expanded(
                                            child: NeutronTextContent(
                                          message: NumberUtil.numberFormat
                                              .format(
                                                  booking.getRemaining() ?? 0),
                                        ))
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              if (booking.rentingBikes! > 0)
                                Center(
                                  child: NeutronTextContent(
                                    message: MessageUtil.getMessageByCode(
                                        MessageCodeUtil
                                            .TEXTALERT_X_RENTING_BIKES,
                                        [
                                          booking.rentingBikes?.toString() ?? ''
                                        ]),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      //checkout button
                      if (!(booking.status == BookingStatus.booked &&
                          !booking.isVirtual!))
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_PRINT),
                            tooltip1: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                            tooltip2: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_CHECKOUT),
                            icon: Icons.print,
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) => NeutronShowConfigDialog(
                                        enDate: controller.endDate,
                                        startDate: controller.startDate,
                                        onChangeEndDate: (p0) {
                                          controller.setEndDate(p0);
                                        },
                                        onChangeStartDate: (p0) {
                                          controller.setStartDate(p0);
                                        },
                                        listItem: booking.bookingType ==
                                                BookingType.monthly
                                            ? [
                                                ...controller.getDayByMonth(),
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode.CUSTOM)
                                              ]
                                            : null,
                                        value: controller.selectMonth,
                                        onPressed2: (value) {
                                          controller.setMonth(value);
                                        },
                                        onPressed: (showOption) {
                                          showOption["isShowPrice"]! ||
                                                  showOption["isShowService"]!
                                              ? Printing.layoutPdf(onLayout:
                                                  (PdfPageFormat format) async {
                                                  Navigator.pop(context);
                                                  return (await PDFUtil.buildCheckOutForBookingPDFDoc(
                                                          await controller
                                                              .exportDpfAndExcel(),
                                                          controller,
                                                          showOption[
                                                              "isShowPrice"]!,
                                                          showOption[
                                                              "isShowService"]!,
                                                          showOption[
                                                              "isShowPayment"]!,
                                                          showOption[
                                                              "isShowRemaining"]!,
                                                          showOption[
                                                              "isShowDailyRate"]!))
                                                      .save();
                                                }).whenComplete(() {
                                                  controller.setMonth(
                                                      UITitleUtil
                                                          .getTitleByCode(
                                                              UITitleCode.ALL));
                                                })
                                              : MaterialUtil.showAlert(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .PLEASE_CHOOSE_CHECKBOX));
                                        },
                                      ));
                            },
                            icon1: Icons.file_present_rounded,
                            onPressed1: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => NeutronShowConfigDialog(
                                        enDate: controller.endDate,
                                        startDate: controller.startDate,
                                        onChangeEndDate: (p0) {
                                          controller.setEndDate(p0);
                                        },
                                        onChangeStartDate: (p0) {
                                          controller.setStartDate(p0);
                                        },
                                        listItem: booking.bookingType ==
                                                BookingType.monthly
                                            ? [
                                                ...controller.getDayByMonth(),
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode.CUSTOM)
                                              ]
                                            : null,
                                        value: controller.selectMonth,
                                        onPressed2: (value) {
                                          controller.setMonth(value);
                                        },
                                        onPressed: (showOption) async {
                                          if (showOption["isShowPrice"]! ||
                                              showOption["isShowService"]!) {
                                            ExcelUlti.exportCheckOutForm(
                                                await controller
                                                    .exportDpfAndExcel(),
                                                controller,
                                                showOption["isShowPrice"]!,
                                                showOption["isShowService"]!,
                                                showOption["isShowPayment"]!,
                                                showOption["isShowRemaining"]!,
                                                showOption["isShowDailyRate"]!);
                                            Navigator.pop(context);
                                            controller.setMonth(
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode.ALL));
                                          } else {
                                            MaterialUtil.showAlert(
                                                context,
                                                MessageUtil.getMessageByCode(
                                                    MessageCodeUtil
                                                        .PLEASE_CHOOSE_CHECKBOX));
                                          }
                                        },
                                      ));
                            },
                            icon2: booking.status != BookingStatus.checkout &&
                                    widget.isShowCheckoutButton
                                ? Icons.flight_takeoff
                                : null,
                            onPressed2: () async {
                              GenerateElectronicInvoiceController?
                                  generateElectronicInvoiceController;
                              if (GeneralManager.hotel!
                                  .isConnectToEInvoiceSoftware()) {
                                bool isGenerateEInvoice = true;
                                bool isContainService = true;
                                if (GeneralManager
                                        .hotel!.eInvoiceGenerateOption ==
                                    UITitleCode.GENERATE_BY_SELECTION) {
                                  isGenerateEInvoice = await MaterialUtil.showConfirm(
                                          context,
                                          UITitleUtil.getTitleByCode(UITitleCode
                                              .DO_YOU_WANT_TO_GENERATE_E_INVOICE)) ??
                                      false;
                                }
                                if (GeneralManager
                                        .hotel!.eInvoiceServiceOption ==
                                    UITitleCode.GENERATE_BY_SELECTION) {
                                  isContainService = await MaterialUtil.showConfirm(
                                          context,
                                          UITitleUtil.getTitleByCode(UITitleCode
                                              .GENERATE_INVOICE_FOR_SERVICES)) ??
                                      false;
                                }
                                if (GeneralManager
                                        .hotel!.eInvoiceServiceOption ==
                                    UITitleCode.NO) {
                                  isContainService = false;
                                }

                                if (isGenerateEInvoice) {
                                  generateElectronicInvoiceController =
                                      GenerateElectronicInvoiceController(
                                          widget.booking!, isContainService);
                                  bool? getInvoiceDataResult = await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        GenerateEInvoiceDialog(
                                      generateElectronicInvoiceController:
                                          generateElectronicInvoiceController!,
                                      booking: booking,
                                    ),
                                  );
                                  if (getInvoiceDataResult == null) {
                                    Navigator.pop(context);
                                  }
                                }
                              }
                              String result = '';
                              // String result = await controller.checkOut();
                              if (!mounted) {
                                return;
                              }
                              if (result !=
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.SUCCESS)) {
                                if (generateElectronicInvoiceController !=
                                    null) {
                                  String generateInvoiceResult =
                                      await generateElectronicInvoiceController
                                          .generateEInvoice();
                                  if (generateInvoiceResult !=
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    MaterialUtil.showAlert(context, result);
                                  } else {
                                    Navigator.pop(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .BOOKING_CHECKOUT_SUCCESS,
                                            [booking.name!]));
                                  }
                                }
                                MaterialUtil.showAlert(context, result);
                              } else {
                                Navigator.pop(
                                    context,
                                    MessageUtil.getMessageByCode(
                                        MessageCodeUtil
                                            .BOOKING_CHECKOUT_SUCCESS,
                                        [booking.name!]));
                              }
                            },
                          ),
                        )
                    ],
                  );
          }),
        ),
      ),
    );
  }
}
