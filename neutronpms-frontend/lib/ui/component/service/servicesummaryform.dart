import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/service/bikerentalform.dart';
import 'package:ihotel/ui/component/service/electricitywaterdetail.dart';
import 'package:ihotel/ui/component/service/electricitywaterform.dart';
import 'package:ihotel/ui/component/service/extraguestform.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/laundryform.dart';
import 'package:ihotel/ui/component/service/minibarform.dart';
import 'package:ihotel/ui/component/service/othersform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutronbuttontext.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/pdfutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/service/servicesummarycontroller.dart';
import '../../../modal/booking.dart';
import '../../../ui/component/service/extrahourform.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../controls/neutronflow.dart';
import '../../controls/neutronwaiting.dart';

class ServiceSummaryForm extends StatefulWidget {
  final Booking? booking;

  const ServiceSummaryForm({Key? key, this.booking}) : super(key: key);

  @override
  State<ServiceSummaryForm> createState() => _ServiceSummaryFormState();
}

class _ServiceSummaryFormState extends State<ServiceSummaryForm>
    with SingleTickerProviderStateMixin {
  ServiceSummaryController? controller;
  late AnimationController menuAnimation;

  @override
  void initState() {
    controller ??= ServiceSummaryController(widget.booking!);
    menuAnimation = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.mainBackground,
      alignment: Alignment.topCenter,
      width: kMobileWidth,
      height: kHeight,
      child: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<ServiceSummaryController>(
          child: const Center(child: CircularProgressIndicator()),
          builder: (_, controller, child) => controller.booking == null
              ? child!
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 85),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            //Title: item + value
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                              .cardOutsideHorizontalPadding +
                                          SizeManagement
                                              .cardInsideHorizontalPadding),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SERVICE)),
                                )),
                                Expanded(
                                    child: NeutronTextTitle(
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PRICE)))
                              ],
                            ),
                            const SizedBox(height: 16),
                            //minibar
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_MINIBAR_SERVICE)),
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(controller
                                                  .booking!.minibar))),
                                  SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: MinibarForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //restaurant inside hotel
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                          text: UITitleUtil.getTitleByCode(
                                              UITitleCode.TOOLTIP_RESTAURANT),
                                          style: NeutronTextStyle.content,
                                          children: [
                                            TextSpan(
                                                text:
                                                    '\n(${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_INSIDE_HOTEL)})',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontStyle:
                                                        FontStyle.italic))
                                          ]),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(controller
                                                  .booking!.insideRestaurant))),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 38,
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: InsideRestaurantForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //restaurant outside hotel
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: RichText(
                                    text: TextSpan(
                                        text: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_RESTAURANT),
                                        style: NeutronTextStyle.content,
                                        children: [
                                          TextSpan(
                                              text:
                                                  '\n(${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_OUTSIDE_HOTEL)})',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic))
                                        ]),
                                    maxLines: 2,
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(controller.booking!
                                                  .outsideRestaurant))),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 38,
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: OutsideRestaurantForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //extra hour
                            InkWell(
                              onTap: controller.booking!.status ==
                                      BookingStatus.checkout
                                  ? null
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              backgroundColor: ColorManagement
                                                  .mainBackground,
                                              child: ExtraHourForm(
                                                  booking:
                                                      controller.booking)));
                                    },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground,
                                ),
                                height: SizeManagement.cardHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_EXTRA_HOUR_SERVICE)),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: NumberUtil.numberFormat
                                                .format(controller.booking!
                                                    .extraHour!.total))),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                    backgroundColor:
                                                        ColorManagement
                                                            .mainBackground,
                                                    child: ExtraHourForm(
                                                        booking: controller
                                                            .booking)));
                                          },
                                          icon: const Icon(Icons.list)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            //extra guest
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_EXTRA_GUEST_SERVICE)),
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(controller
                                                  .booking!.extraGuest))),
                                  SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: () {
                                          if (!controller.booking!.isVirtual!) {
                                            return;
                                          }
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: ExtraGuestForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //laundry
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_LAUNDRY_SERVICE)),
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(controller
                                                  .booking!.laundry))),
                                  SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: LaundryForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //bike rental
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_BIKE_RENTAL_SERVICE)),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: NumberUtil.numberFormat
                                                .format(controller
                                                    .booking!.bikeRental))),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                    backgroundColor:
                                                        ColorManagement
                                                            .mainBackground,
                                                    child: BikeRentalForm(
                                                        booking: controller
                                                            .booking!)));
                                          },
                                          icon: const Icon(Icons.list)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            //other
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement
                                      .cardOutsideVerticalPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground,
                              ),
                              height: SizeManagement.cardHeight,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_OTHER)),
                                  )),
                                  Expanded(
                                      child: NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(
                                                  controller.booking!.other))),
                                  SizedBox(
                                    width: 50,
                                    child: IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                  backgroundColor:
                                                      ColorManagement
                                                          .mainBackground,
                                                  child: OthersForm(
                                                      booking: controller
                                                          .booking!)));
                                        },
                                        icon: const Icon(Icons.list)),
                                  )
                                ],
                              ),
                            ),
                            //electricity
                            InkWell(
                              onTap: controller.booking!.status ==
                                      BookingStatus.checkout
                                  ? null
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              backgroundColor: ColorManagement
                                                  .mainBackground,
                                              child: ElectricityWaterForm(
                                                  booking:
                                                      controller.booking)));
                                    },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground,
                                ),
                                height: SizeManagement.cardHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_ELECTRICITY)),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: NumberUtil.numberFormat
                                                .format(controller
                                                    .booking!.electricity))),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ElectricityWaterDetail(
                                                        booking: controller
                                                            .booking));
                                          },
                                          icon: const Icon(Icons.list)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            //Water
                            InkWell(
                              onTap: controller.booking!.status ==
                                      BookingStatus.checkout
                                  ? null
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                              backgroundColor: ColorManagement
                                                  .mainBackground,
                                              child: ElectricityWaterForm(
                                                  isElectricity: false,
                                                  booking:
                                                      controller.booking)));
                                    },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground,
                                ),
                                height: SizeManagement.cardHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_WATER)),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: NumberUtil.numberFormat
                                                .format(controller
                                                    .booking!.water))),
                                    SizedBox(
                                      width: 50,
                                      child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ElectricityWaterDetail(
                                                        booking:
                                                            controller.booking,
                                                        isElectricity: false));
                                          },
                                          icon: const Icon(Icons.list)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    buildPrintButton(),
                    //total
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: NeutronButtonText(
                        text:
                            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.booking!.getServiceCharge())}',
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildPrintButton() {
    return NeutronFlow(
      animationController: menuAnimation,
      icons: const [Icons.menu, Icons.print, Icons.file_present_rounded],
      functions: [
        () {
          Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async =>
                  (await PDFUtil.buildAllServicePDFDoc(controller!.booking!))
                      .save());
        },
        () async {
          showDialog(
              context: context,
              builder: (context) => WillPopScope(
                  onWillPop: () => Future.value(false),
                  child: const NeutronWaiting()));
          await controller!
              .exportDetailService()
              .then((value) => Navigator.pop(context));
        }
      ],
    );
  }
}
