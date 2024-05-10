// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../manager/bikerentalmanager.dart';
import '../../../manager/bookingmanager.dart';
import '../../../manager/suppliermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/bikerental.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../controls/neutrontextformfield.dart';
import '../selectionbookingdialog.dart';

class BikeRentalInvoiceController extends UpdateServiceController {
  final BikeRental service;
  final Booking booking;
  BikeRentalInvoiceController(this.booking, this.service);
  bool? moved = false;

  void changeBike(String newBike) {
    if (newBike == service.bike) return;
    service.bike = newBike;
    notifyListeners();
  }

  Future<String> updateServiceProgress(String progressString) async {
    final progress = BikeRentalProgress.getProgressByString(progressString);
    updating = true;
    notifyListeners();
    final result = await service.updateBikeRentalProgress(progress);
    if (result == MessageCodeUtil.SUCCESS) {
      service.progress = progress;
      service.total = service.getTotal();
    }
    updating = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }

  Future<String> moveServiceToBooking(Booking selectedBooking) async {
    updating = true;
    notifyListeners();
    String result = await service.moveToBooking(selectedBooking);
    if (result == MessageCodeUtil.SUCCESS) {
      moved = true;
    }
    updating = false;
    notifyListeners();
    return result;
  }

  //print bike-rental-contract
  void printBill() {
    Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            (await PDFUtil.buildBikeRentalPDFDoc(booking, service)).save());
  }

  @override
  List<String>? getServiceItems() {
    return null;
  }

  @override
  bool? isServiceItemsChanged() {
    return null;
  }

  @override
  void saveOldItems() {}

  @override
  void updateService() {}

  @override
  Future<String>? updateServiceToDatabase() {
    return null;
  }
}

class BikeRentalInvoiceForm extends StatelessWidget {
  final BikeRental? service;
  final Booking? booking;
  final BikeRentalInvoiceController? controller;
  final BuildContext? parentContext;

  const BikeRentalInvoiceForm({
    Key? key,
    this.service,
    this.booking,
    this.controller,
    this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<BikeRentalInvoiceController?>(
            builder: (_, controller, __) {
              if (controller?.moved ?? false) {
                return Container(
                  margin: const EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.TEXTALERT_MOVED)),
                );
              }
              return DataTable(
                  columnSpacing: 3,
                  horizontalMargin: 3,
                  headingRowHeight: 0,
                  columns: const <DataColumn>[
                    DataColumn(label: Text('')),
                    DataColumn(label: Text(''))
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE)))),
                      DataCell(InkWell(
                        onTap: !(booking != null &&
                                booking!.isBikeRentalEditable() &&
                                service!.progress != 2)
                            ? null
                            : () async {
                                if (controller!.service.progress !=
                                    BikeRentalProgress.checkout) {
                                  String? newBike = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => ChangeBikeDialog(
                                      bikeRental: controller.service,
                                    ),
                                  );
                                  if (newBike == null) return;
                                  if (newBike.isNotEmpty) {
                                    controller.changeBike(newBike);
                                    MaterialUtil.showSnackBar(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .CHANGE_BIKE_SUCCESS));
                                  } else {
                                    MaterialUtil.showAlert(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.CHANGE_BIKE_FAIL));
                                  }
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                              left: SizeManagement.dropdownLeftPadding),
                          child: NeutronTextContent(
                              message:
                                  controller?.service.bike ?? service!.bike!),
                        ),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TYPE)))),
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left: SizeManagement.dropdownLeftPadding),
                          child: NeutronTextContent(
                              message: MessageUtil.getMessageByCode(
                                  controller?.service.type ?? service!.type)))),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SUPPLIER)))),
                      DataCell(Tooltip(
                          message: SupplierManager().getSupplierNameByID(
                              controller?.service.supplierID ??
                                  service!.supplierID!),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: SizeManagement.dropdownLeftPadding),
                            child: NeutronTextContent(
                                message: SupplierManager().getSupplierNameByID(
                                    controller?.service.supplierID ??
                                        service!.supplierID!)),
                          ))),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_START)))),
                      DataCell(Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.dropdownLeftPadding),
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthHourMinuteString(
                                controller?.service.start?.toDate() ??
                                    service!.start!.toDate())),
                      )),
                    ]),
                    if ((controller?.service.progress ?? service!.progress) ==
                        BikeRentalProgress.checkout)
                      DataRow(cells: [
                        DataCell(Padding(
                            padding: const EdgeInsets.only(
                                left: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_END)))),
                        DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left: SizeManagement.dropdownLeftPadding),
                          child: NeutronTextContent(
                              message: DateUtil.dateToDayMonthHourMinuteString(
                                  controller?.service.end?.toDate() ??
                                      service!.end!.toDate())),
                        )),
                      ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE)))),
                      DataCell(Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.dropdownLeftPadding),
                        child: NeutronTextContent(
                            color: ColorManagement.positiveText,
                            message: NumberUtil.numberFormat.format(
                                controller?.service.price ?? service!.price)),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PROGRESS)))),
                      //dropdown menu to check in, check out
                      DataCell(Container(
                        color: BikeRentalProgress.getColorByStatus(
                            controller?.service.progress ?? service!.progress!),
                        padding: const EdgeInsets.only(
                            left: SizeManagement.dropdownLeftPadding,
                            right: SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronDropDown(
                            isPadding: false,
                            isDisabled: booking == null ||
                                !booking!.isBikeRentalEditable() ||
                                service!.progress == 2,
                            focusColor: BikeRentalProgress.getColorByStatus(
                                controller?.service.progress ??
                                    service!.progress!),
                            value: BikeRentalProgress.getStatusString(
                                controller?.service.progress ??
                                    service!.progress!)!,
                            onChanged: (String progressString) async {
                              String result = await controller!
                                  .updateServiceProgress(progressString);
                              MaterialUtil.showResult(parentContext!, result);
                            },
                            items: BikeRentalProgress().getNextProgressString(
                                controller?.service.progress ??
                                    service!.progress!)),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL)))),
                      DataCell(Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.dropdownLeftPadding),
                        child: NeutronTextContent(
                          message: NumberUtil.numberFormat.format(
                              controller?.service.getTotal() ??
                                  service!.getTotal()),
                          color: ColorManagement.positiveText,
                        ),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Padding(
                          padding: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.HINT_SALER)))),
                      DataCell(Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.dropdownLeftPadding),
                        child: NeutronTextContent(
                          message: controller?.service.saler ?? service!.saler!,
                          color: ColorManagement.positiveText,
                        ),
                      )),
                    ]),
                    if (booking != null &&
                        controller?.service.progress !=
                            BikeRentalProgress.booked)
                      DataRow(cells: [
                        //move-button
                        controller!.service.isMovable()
                            ? DataCell(Center(
                                child: IconButton(
                                    icon: const Icon(
                                        Icons.drive_file_move_outline),
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TOOLTIP_MOVE_TO_ANOTHER_BOOKING),
                                    onPressed: () async {
                                      final Booking? selectedBooking =
                                          await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  const SelectionBookingDialog(
                                                    isSearchSubBooking: true,
                                                  ));
                                      if (selectedBooking == null) return;
                                      String result =
                                          await controller.moveServiceToBooking(
                                              selectedBooking);
                                      if (result == MessageCodeUtil.SUCCESS) {
                                        MaterialUtil.showSnackBar(
                                            parentContext,
                                            MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .MOVE_TO_ANOTHER_BOOKING,
                                                [selectedBooking.name!]));
                                      } else {
                                        MaterialUtil.showAlert(
                                            parentContext,
                                            MessageUtil.getMessageByCode(
                                                result));
                                      }
                                    }),
                              ))
                            : DataCell.empty,
                        //Print-button
                        DataCell(Center(
                          child: IconButton(
                              icon: const Icon(Icons.print),
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_PRINT),
                              onPressed: () {
                                controller.printBill();
                              }),
                        ))
                      ]),
                  ]);
            },
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
          onPressed: () async {
            Booking? printBooking = booking ??
                await BookingManager().getBasicBookingByID(service!.bookingID!);
            Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async =>
                    (await PDFUtil.buildBikeRentalOfBookingPDFDoc(
                            printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class ChangeBikeDialog extends StatefulWidget {
  final BikeRental? bikeRental;

  const ChangeBikeDialog({Key? key, this.bikeRental}) : super(key: key);
  @override
  State<ChangeBikeDialog> createState() => _ChangeBikeDialogState();
}

class _ChangeBikeDialogState extends State<ChangeBikeDialog> {
  late String _bike;
  late List<String> bikes;

  @override
  void initState() {
    _bike = widget.bikeRental!.bike!;
    bikes = BikeRentalManager().getAvailableBikesByTypeAndSupplierId(
        widget.bikeRental!.type!, widget.bikeRental!.supplierID!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NeutronTextTitle(
                isPadding: true,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BIKE)),
            const SizedBox(width: 16),
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return bikes;
                  }

                  return bikes.where((String option) {
                    return option
                        .toLowerCase()
                        .startsWith(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _bike = selection;
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: ColorManagement.mainBackground,
                      elevation: 5,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: kMobileWidth -
                                SizeManagement.cardOutsideHorizontalPadding *
                                    2),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) => ListTile(
                            onTap: () => onSelected(options.elementAt(index)),
                            title: Text(
                              options.elementAt(index),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            minVerticalPadding: 0,
                            hoverColor: Colors.white38,
                          ),
                          itemCount: options.length,
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onEditingComplete) {
                  return NeutronTextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    isDecor: false,
                    onChanged: (String value) {
                      _bike = value;
                    },
                  );
                },
                initialValue: TextEditingValue(text: _bike),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 100,
              margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
              child: NeutronButton(
                  icon: Icons.save,
                  onPressed: () async {
                    if (_bike.isEmpty) {
                      MaterialUtil.showAlert(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.NO_AVAILABLE_BIKE_TO_CHANGE));
                      return;
                    }
                    if (await widget.bikeRental!.changeBike(_bike)) {
                      Navigator.pop(context, _bike);
                    } else {
                      Navigator.pop(context, "");
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
