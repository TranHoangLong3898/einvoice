import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/service/othercontroller.dart';
import '../../../manager/bookingmanager.dart';
import '../../../manager/othermanager.dart';
import '../../../manager/suppliermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/other.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../validator/numbervalidator.dart';
import '../../controls/neutronexpansionlist.dart';
import '../../controls/neutrontextformfield.dart';

class OthersForm extends StatefulWidget {
  final Booking booking;

  const OthersForm({Key? key, required this.booking}) : super(key: key);

  @override
  State<OthersForm> createState() => _OthersFormState();
}

class _OthersFormState extends State<OthersForm> {
  late OtherController controller;
  @override
  void initState() {
    controller = OtherController(widget.booking);
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
        child: Consumer<OtherController>(
          builder: (_, controller, __) =>
              Stack(fit: StackFit.expand, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: ColorManagement.lightMainBackground,
                      ),
                      child: _buildPanels(controller))),
            ),
            if (controller.booking.isOtherEditable() &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddOtherDialog(
                          booking: controller.booking,
                        ),
                      );
                      if (result == null) return;
                      controller.update();
                      if (mounted) {
                        MaterialUtil.showSnackBar(context, result);
                      }
                    }),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPanels(OtherController controller) {
    if (controller.others.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 16),
        child: NeutronTextContent(
            message: controller.booking.isExtraGuestEditable()
                ? MessageUtil.getMessageByCode(
                    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                : UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NO_SERVICE_IN_USE)),
      );
    }

    final services = controller.others.toList();
    services.sort((a, b) => a.created!.compareTo(b.created!));

    return NeutronExpansionPanelList(
      services: services,
      booking: controller.booking,
    );
  }
}

// ignore: must_be_immutable
class OtherInvoiceForm extends StatelessWidget {
  final Other? service;
  final Booking? booking;
  final GlobalKey? otherEditForm;
  final UpdateOtherController? otherController;
  NeutronInputNumberController? tePriceController;

  OtherInvoiceForm({
    Key? key,
    this.service,
    this.booking,
    this.otherEditForm,
    this.otherController,
  }) : super(key: key) {
    if (otherController != null) {
      tePriceController = NeutronInputNumberController(
          otherController!.teOtherControllers['price']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
            key: otherEditForm,
            child: ChangeNotifierProvider.value(
                value: otherController,
                child: Consumer<UpdateOtherController?>(
                  builder: (ctx, extraGuestController, child) => DataTable(
                      headingRowHeight: 0,
                      columnSpacing: 3,
                      horizontalMargin: 3,
                      columns: <DataColumn>[
                        DataColumn(label: Container()),
                        DataColumn(label: Container())
                      ],
                      rows: [
                        //Date
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_DATE)))),
                          DataCell(
                            booking == null
                                ? NeutronTextContent(
                                    message: DateUtil.dateToString(
                                        service!.date!.toDate()))
                                : Row(children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: SizeManagement
                                                .dropdownLeftPadding),
                                        child: NeutronTextContent(
                                          message: DateUtil.dateToString(
                                              service!.date!.toDate()),
                                        ),
                                      ),
                                    ),
                                    !(booking != null &&
                                            booking!.isExtraGuestEditable())
                                        ? Container()
                                        : IconButton(
                                            padding: const EdgeInsets.only(
                                                right: SizeManagement
                                                    .cardInsideHorizontalPadding),
                                            onPressed: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                builder: (context, child) =>
                                                    DateTimePickerDarkTheme
                                                        .buildDarkTheme(
                                                            context, child!),
                                                context: context,
                                                initialDate:
                                                    extraGuestController!
                                                        .service!.inDate!,
                                                firstDate: extraGuestController
                                                    .booking!.inDate!,
                                                lastDate: extraGuestController
                                                    .booking!.outDate!,
                                              );
                                              if (picked != null) {
                                                otherController!
                                                    .setDate(picked);
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.calendar_today)),
                                  ]),
                          )
                        ]),
                        //Type
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TYPE)))),
                          DataCell(
                            booking == null
                                ? NeutronTextContent(
                                    message: OtherManager()
                                        .getServiceNameByID(service!.type!))
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        right: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronDropDown(
                                        value: otherController!.type,
                                        onChanged: (String newType) {
                                          otherController!.setType(newType);
                                        },
                                        items: otherController!.listService),
                                  ),
                          ),
                        ]),
                        //Description
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode
                                          .TABLEHEADER_DESCRIPTION_FULL)))),
                          DataCell(
                            booking == null
                                ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 170, minWidth: 170),
                                    child: Tooltip(
                                      message: service!.desc,
                                      child: NeutronTextContent(
                                        message: service!.desc!,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                            SizeManagement.dropdownLeftPadding),
                                    child: NeutronTextFormField(
                                      textAlign: TextAlign.left,
                                      readOnly: booking!.isOtherEditable()
                                          ? false
                                          : true,
                                      controller: extraGuestController!
                                          .teOtherControllers['description'],
                                      validator: (inputData) {
                                        return null;
                                      },
                                    ),
                                  ),
                          ),
                        ]),
                        //Supplier
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SUPPLIER)))),
                          DataCell(
                            booking == null
                                ? NeutronTextContent(
                                    message: SupplierManager()
                                        .getSupplierNameByID(
                                            service!.supplierID!))
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        right: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronDropDown(
                                      value: otherController!.supplier,
                                      onChanged: (String newSupplier) {
                                        otherController!
                                            .setSupplier(newSupplier);
                                      },
                                      items: otherController!.listSupplier,
                                    ),
                                  ),
                          ),
                        ]),
                        //Price
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_PRICE)))),
                          DataCell(booking == null
                              ? NeutronTextContent(
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(service!.total))
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement.dropdownLeftPadding),
                                  child: tePriceController!.buildWidget(
                                    textColor: ColorManagement.positiveText,
                                    isDecor: false,
                                    readOnly:
                                        booking!.isServiceUpdatable(service!)
                                            ? false
                                            : true,
                                    validator: (String? inputData) {
                                      //if inputData empty or not a integer-number -> invalid
                                      if (inputData == null ||
                                          inputData.isEmpty ||
                                          !NumberValidator
                                              .validatePositiveNumber(
                                                  tePriceController!
                                                      .getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil.INPUT_PRICE);
                                      }
                                      return null;
                                    },
                                    hint: '0',
                                  ),
                                )),
                        ]),
                      ]),
                ))),
        Container(
          color: ColorManagement.lightMainBackground,
          margin: const EdgeInsets.only(
              top: 6,
              bottom: 15,
              left: SizeManagement.cardOutsideHorizontalPadding,
              right: SizeManagement.cardOutsideHorizontalPadding),
          child: NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: otherController?.teSaler ??
                TextEditingController(text: service!.saler),
            readOnly: otherController?.teSaler == null,
            onChanged: (value) => otherController!.setEmailSaler(
                value, otherController?.emailSalerOld ?? service!.saler!),
            suffixIcon: IconButton(
              onPressed: () => otherController!.checkEmailExists(
                  otherController?.teSaler.text ?? service!.saler!),
              icon: otherController?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : otherController?.isCheckEmail ?? true
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: otherController?.isCheckEmail ?? true
                  ? ColorManagement.greenColor
                  : ColorManagement.redColor,
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
          onPressed: () async {
            Booking? printBooking = booking ??
                await BookingManager().getBasicBookingByID(service!.bookingID!);
            Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async =>
                    (await PDFUtil.buildOtherPDFDoc(printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class AddOtherDialog extends StatefulWidget {
  final Booking booking;

  const AddOtherDialog({Key? key, required this.booking}) : super(key: key);

  @override
  State<AddOtherDialog> createState() => _AddOtherDialogState();
}

class _AddOtherDialogState extends State<AddOtherDialog> {
  final formKey = GlobalKey<FormState>();

  AddOtherController? controller;
  late NeutronInputNumberController priceController;

  @override
  void initState() {
    controller ??= AddOtherController(widget.booking);
    priceController = NeutronInputNumberController(controller!.teTotal);
    super.initState();
  }

  @override
  void dispose() {
    controller!.disposeTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        height: kHeight,
        width: kMobileWidth,
        child: Form(
          key: formKey,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<AddOtherController>(
              builder: (_, controller, __) => controller.adding
                  ? const Center(
                      heightFactor: kMobileWidth,
                      child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ))
                  : Stack(children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Title
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        SizeManagement.topHeaderTextSpacing),
                                child: NeutronTextHeader(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_ADD_SERVICE_INVOICE),
                                ),
                              ),
                              //Date
                              Padding(
                                  padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    top: SizeManagement.rowSpacing,
                                    bottom: SizeManagement.rowSpacing,
                                  ),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_DATE))),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: NeutronDateTimePickerBorder(
                                  isEditDateTime: true,
                                  firstDate: controller.booking!.inDate,
                                  lastDate: controller.booking!.outDate,
                                  initialDate: controller.date,
                                  onPressed: (DateTime? picked) {
                                    if (picked != null) {
                                      controller.setDate(picked);
                                    }
                                  },
                                ),
                              ),
                              //Service
                              Padding(
                                  padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom: SizeManagement.rowSpacing,
                                    top: SizeManagement.rowSpacing,
                                  ),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SERVICE))),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: NeutronDropDownCustom(
                                  childWidget: NeutronDropDown(
                                      isPadding: false,
                                      value: OtherManager().getServiceNameByID(
                                          controller.serviceID),
                                      onChanged: (String newServiceName) {
                                        final newServiceID = OtherManager()
                                            .getServiceIDByName(newServiceName);
                                        controller.setService(newServiceID);
                                      },
                                      items: controller.otherServiceNames),
                                ),
                              ),
                              //Description
                              Padding(
                                  padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom: SizeManagement.rowSpacing,
                                    top: SizeManagement.rowSpacing,
                                  ),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DESCRIPTION_FULL))),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: NeutronTextFormField(
                                  isDecor: true,
                                  controller: controller.teDesc,
                                ),
                              ),
                              //Supplier
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.rowSpacing,
                                  top: SizeManagement.rowSpacing,
                                ),
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_SUPPLIER)),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: NeutronDropDownCustom(
                                  childWidget: NeutronDropDown(
                                    value: SupplierManager()
                                        .getSupplierNameByID(
                                            controller.supplierID),
                                    onChanged: (String newSupplierName) {
                                      final newSupplierID = SupplierManager()
                                          .getSupplierIDByName(newSupplierName);
                                      controller.setSupplier(newSupplierID!);
                                    },
                                    items: SupplierManager()
                                        .getActiveSupplierNamesByService(
                                            controller.serviceID),
                                  ),
                                ),
                              ),
                              //Price
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.rowSpacing,
                                  top: SizeManagement.rowSpacing,
                                ),
                                child: NeutronTextTitle(
                                    isRequired: true,
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE)),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: priceController.buildWidget(
                                  validator: (String? value) =>
                                      NumberValidator.validatePositiveNumber(
                                              priceController.getRawString())
                                          ? null
                                          : MessageUtil.getMessageByCode(
                                              MessageCodeUtil.INPUT_PRICE),
                                  hint: "0",
                                ),
                              ),
                              Container(
                                color: ColorManagement.lightMainBackground,
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: NeutronTextFormField(
                                  paddingVertical: 16,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.HINT_SALER),
                                  isDecor: true,
                                  controller: controller.teSaler,
                                  onChanged: (value) =>
                                      controller.setEmailSaler(
                                          value, controller.emailSalerOld),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        controller.checkEmailExists(
                                            controller.teSaler.text),
                                    icon: controller.isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                                color:
                                                    ColorManagement.greenColor),
                                          )
                                        : controller.isCheckEmail
                                            ? const Icon(Icons.check)
                                            : const Icon(Icons.cancel),
                                    color: controller.isCheckEmail
                                        ? ColorManagement.greenColor
                                        : ColorManagement.redColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //add-button
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButton(
                            icon: Icons.save,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final result = await controller.addOther();
                                if (!mounted) {
                                  return;
                                }
                                if (result ==
                                    MessageUtil.getMessageByCode(
                                        MessageCodeUtil.SUCCESS)) {
                                  Navigator.pop(context, result);
                                } else {
                                  MaterialUtil.showAlert(context, result);
                                }
                              }
                            }),
                      ),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}
