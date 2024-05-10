import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/restaurantservicecontroller.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../manager/bookingmanager.dart';
import '../../../modal/booking.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronexpansionlist.dart';

class OutsideRestaurantForm extends StatefulWidget {
  final Booking booking;

  const OutsideRestaurantForm({Key? key, required this.booking})
      : super(key: key);

  @override
  State<OutsideRestaurantForm> createState() => _OutsideRestaurantFormState();
}

class _OutsideRestaurantFormState extends State<OutsideRestaurantForm> {
  late RestaurantServiceController controller;

  @override
  void initState() {
    controller = RestaurantServiceController(widget.booking);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.mainBackground,
      width: ResponsiveUtil.isMobile(context) ? kMobileWidth : kWidth,
      height: kHeight,
      child: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<RestaurantServiceController>(
          builder: (_, controller, __) => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Theme(
                  data: Theme.of(context)
                      .copyWith(cardColor: ColorManagement.lightMainBackground),
                  child: _buildPanels(controller))),
        ),
      ),
    );
  }

  Widget _buildPanels(RestaurantServiceController controller) {
    if (controller.resServices.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 16),
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)),
      );
    }

    final services = controller.getServicesBySelectedRestaurant();
    services.sort((a, b) => a.created!.compareTo(b.created!));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //restaurant filter
        Row(
          children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            NeutronTextContent(
              message:
                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT)}:',
            ),
            Expanded(
                child: NeutronDropDown(
              onChanged: (String value) =>
                  controller.setSelectedRestaurant(value),
              items: controller.restaurantInfo.values.toList(),
              value: controller.selectedResName,
            )),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          ],
        ),
        //list service filted by restaurant name
        NeutronExpansionPanelList(
            services: services, booking: controller.booking!),
      ],
    );
  }
}

class RestaurantInvoiceForm extends StatelessWidget {
  final OutsideRestaurantService? service;
  final Booking? booking;
  final bool? isMobile;

  const RestaurantInvoiceForm(
      {Key? key, this.service, this.booking, this.isMobile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = this.isMobile ?? ResponsiveUtil.isMobile(context);
    final double widthNumberField = isMobile ? 89 : 180;
    final double widthNameField = isMobile ? 90 : 194;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        //item charge
        Row(
          children: [
            const SizedBox(width: 15),
            NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BILL)),
            const Spacer(),
            NeutronTextContent(
                message: NumberUtil.numberFormat.format(service!.itemCharge)),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        //surcharge
        Row(
          children: [
            const SizedBox(width: 15),
            NeutronTextContent(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_SURCHARGE)),
            const Spacer(),
            NeutronTextContent(
                message: NumberUtil.numberFormat.format(service!.surcharge)),
            const SizedBox(width: 15),
          ],
        ),
        const Divider(
            endIndent: 20, indent: 20, color: ColorManagement.lightColorText),
        //total bill
        Row(
          children: [
            const SizedBox(width: 15),
            NeutronTextContent(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_TOTAL_BILL)),
            const Spacer(),
            NeutronTextContent(
                color: ColorManagement.positiveText,
                message: NumberUtil.numberFormat.format(service!.totalBill)),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        //discount
        Row(
          children: [
            const SizedBox(width: 15),
            NeutronTextContent(
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DISCOUNT)),
            const Spacer(),
            NeutronTextContent(
                color: ColorManagement.negativeText,
                message: NumberUtil.numberFormat.format(service!.discount)),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        Row(
          children: [
            const SizedBox(width: 15),
            NeutronTextContent(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN)),
            const Spacer(),
            NeutronTextContent(
                color: ColorManagement.positiveText,
                message: NumberUtil.numberFormat.format(service!.total)),
            const SizedBox(width: 15),
          ],
        ),
        const Divider(
            endIndent: 20,
            indent: 20,
            color: Color.fromARGB(255, 192, 194, 195)),
        DataTable(
            columnSpacing: 3,
            horizontalMargin: 3,
            columns: buildDataColumns(widthNameField, widthNumberField),
            rows: service!.items!.map((item) {
              return DataRow(
                cells: <DataCell>[
                  //name
                  DataCell(Container(
                    constraints: BoxConstraints(
                        maxWidth: widthNameField, minWidth: widthNameField),
                    padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding),
                    child: NeutronTextContent(
                      message: item.name,
                      tooltip: item.name,
                    ),
                  )),
                  //price
                  DataCell(Container(
                    constraints: BoxConstraints(
                        maxWidth: widthNumberField, minWidth: widthNumberField),
                    alignment: Alignment.center,
                    child: NeutronTextContent(
                      color: ColorManagement.positiveText,
                      message: NumberUtil.numberFormat.format(item.price),
                    ),
                  )),
                  //value
                  DataCell(Center(
                    child: NeutronTextContent(
                      message: item.quantity.toString(),
                    ),
                  ))
                ],
              );
            }).toList()),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
          onPressed: () async {
            Booking? printBooking = booking ??
                await BookingManager().getBasicBookingByID(service!.bookingID!);
            Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async =>
                    (await PDFUtil.buildOutSideHotelPDFDoc(
                            printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }

  List<DataColumn> buildDataColumns(double widthName, double widthNumber) {
    return <DataColumn>[
      DataColumn(
        label: Container(
            width: widthName,
            padding: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextTitle(
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM))),
      ),
      DataColumn(
        label: Container(
            alignment: Alignment.center,
            width: widthNumber,
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
            )),
      ),
      DataColumn(
        label: Container(
            alignment: Alignment.center,
            width: widthNumber,
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
            )),
      ),
    ];
  }
}
