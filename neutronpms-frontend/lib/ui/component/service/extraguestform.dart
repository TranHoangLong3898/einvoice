import 'package:flutter/material.dart';
import 'package:ihotel/manager/roomextramanager.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/service/extraguestcontroller.dart';
import '../../../manager/bookingmanager.dart';
import '../../../manager/configurationmanagement.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/extraguest.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/pdfutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../validator/numbervalidator.dart';
import '../../controls/neutronexpansionlist.dart';
import '../../controls/neutrontextformfield.dart';
import 'hotelservice/hotelservicedialog.dart';

class ExtraGuestForm extends StatefulWidget {
  final Booking booking;

  const ExtraGuestForm({Key? key, required this.booking}) : super(key: key);

  @override
  State<ExtraGuestForm> createState() => _ExtraGuestFormState();
}

class _ExtraGuestFormState extends State<ExtraGuestForm> {
  late ExtraGuestController controller;
  @override
  void initState() {
    controller = ExtraGuestController(widget.booking);
    super.initState();
  }

  //ExtraGuest-tab on ServiceDiaglog
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.mainBackground,
      width: ResponsiveUtil.isMobile(context) ? kMobileWidth : kWidth,
      height: kHeight,
      child: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<ExtraGuestController>(
          builder: (_, controller, __) =>
              Stack(fit: StackFit.expand, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildPanels(controller)),
            ),
            if (controller.booking.isExtraGuestEditable() &&
                ConfigurationManagement().roomExtra!.childPrice != 0 &&
                ConfigurationManagement().roomExtra!.adultPrice != 0 &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      if (RoomExtraManager().roomExtraConfigs!.adultPrice ==
                              0 &&
                          RoomExtraManager().roomExtraConfigs!.childPrice ==
                              0) {
                        MaterialUtil.showAlert(
                            context,
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.NO_ROOM_EXTRA_CONFIGS));
                        return;
                      }
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddExtraGuestDialog(
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

  Widget _buildPanels(ExtraGuestController controller) {
    if (widget.booking.status != BookingStatus.checkout &&
        (ConfigurationManagement().roomExtra!.childPrice == 0 &&
            ConfigurationManagement().roomExtra!.adultPrice == 0)) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeutronTextContent(
              message: MessageUtil.getMessageByCode(
                  MessageCodeUtil.TEXTALERT_NEED_TO_CONFIG_X_FIRST, [
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST)
              ]),
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            TextButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) =>
                        const HotelServiceDialog(indexSelectedTab: 2));
                controller.rebuild();
              },
              child: NeutronTextContent(
                message: MessageUtil.getMessageByCode(
                  MessageCodeUtil.TEXTALERT_CLICK_HERE,
                ),
                color: ColorManagement.redColor,
              ),
            )
          ],
        ),
      );
    }
    if (controller.extraGuests.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        child: NeutronTextContent(
            message: controller.booking.isExtraGuestEditable()
                ? MessageUtil.getMessageByCode(
                    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                : UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NO_SERVICE_IN_USE)),
      );
    }

    final services = controller.extraGuests.toList();
    services.sort((a, b) => a.created!.compareTo(b.created!));

    return NeutronExpansionPanelList(
      services: services,
      booking: controller.booking,
    );
  }
}

class ExtraGuestInvoiceForm extends StatelessWidget {
  final ExtraGuest? service;
  final Booking? booking;
  final GlobalKey? extraGuestEditForm;
  final UpdateExtraGuestController? extraGuestController;
  const ExtraGuestInvoiceForm(
      {super.key,
      this.service,
      this.booking,
      this.extraGuestEditForm,
      this.extraGuestController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
            key: extraGuestEditForm,
            child: ChangeNotifierProvider.value(
                value: extraGuestController,
                child: Consumer<UpdateExtraGuestController?>(
                  builder: (_, extraGuestController, __) => DataTable(
                      headingRowHeight: 0,
                      columnSpacing: 3,
                      horizontalMargin: 3,
                      columns: <DataColumn>[
                        DataColumn(label: Container()),
                        DataColumn(label: Container()),
                      ],
                      rows: [
                        //Created
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_CREATE)))),
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement.dropdownLeftPadding),
                              child: NeutronTextContent(
                                  message:
                                      DateUtil.dateToDayMonthHourMinuteString(
                                          service!.created!.toDate())))),
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
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                            SizeManagement.dropdownLeftPadding),
                                    child: NeutronTextContent(
                                        message: service!.type!),
                                  )
                                : NeutronDropDown(
                                    value: MessageUtil.getMessageByCode(
                                        extraGuestController!.service!.type!),
                                    onChanged: !booking!.isExtraGuestEditable()
                                        ? null
                                        : (String newType) {
                                            extraGuestController
                                                .updateExtraGuestType(newType);
                                          },
                                    items: [
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.TEXTALERT_ADULT),
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.TEXTALERT_CHILD)
                                      ]),
                          ),
                        ]),
                        //Number
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NUMBER)))),
                          DataCell(Padding(
                            padding: const EdgeInsets.only(
                                left: SizeManagement.dropdownLeftPadding),
                            child: booking == null
                                ? NeutronTextContent(
                                    message: service!.number.toString(),
                                  )
                                : NeutronInputNumberController(
                                        extraGuestController!
                                            .teExtraGuestControllers['number']!)
                                    .buildWidget(
                                    isDecor: false,
                                    padding: 0,
                                    textAlign: TextAlign.left,
                                    readOnly:
                                        booking!.isServiceUpdatable(service!)
                                            ? false
                                            : true,
                                    validator: (String? inputData) {
                                      //if inputData empty or not a integer-number -> invalid
                                      if (inputData == null ||
                                          inputData.isEmpty ||
                                          !NumberValidator.validatePositiveNumber(
                                              NeutronInputNumberController(
                                                      extraGuestController
                                                              .teExtraGuestControllers[
                                                          'number']!)
                                                  .getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .INPUT_POSITIVE_NUMBER);
                                      }
                                      return null;
                                    },
                                    hint: '0',
                                  ),
                          ))
                        ]),
                        //In
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_IN_DATE)))),
                          DataCell(Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement.dropdownLeftPadding),
                                  child: NeutronTextContent(
                                    message:
                                        DateUtil.dateToString(service!.start!),
                                  ),
                                ),
                              ),
                              !(booking != null &&
                                      booking!.isExtraGuestEditable())
                                  ? Container()
                                  : IconButton(
                                      onPressed: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          builder: (context, child) =>
                                              DateTimePickerDarkTheme
                                                  .buildDarkTheme(
                                                      context, child!),
                                          context: context,
                                          initialDate: extraGuestController!
                                              .service!.start!,
                                          firstDate: extraGuestController
                                              .booking!.inDate!,
                                          lastDate: extraGuestController
                                              .booking!.outDate!
                                              .subtract(
                                                  const Duration(days: 1)),
                                        );
                                        if (picked != null) {
                                          extraGuestController
                                              .updateStartDate(picked);
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_today))
                            ],
                          )),
                        ]),
                        //Out
                        DataRow(cells: [
                          DataCell(Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_OUT_DATE)))),
                          DataCell(
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                            SizeManagement.dropdownLeftPadding),
                                    child: NeutronTextContent(
                                      message:
                                          DateUtil.dateToString(service!.end!),
                                    ),
                                  ),
                                ),
                                !(booking != null &&
                                        booking!.isExtraGuestEditable())
                                    ? Container()
                                    : IconButton(
                                        onPressed: () async {
                                          final DateTime? picked =
                                              await showDatePicker(
                                            builder: (context, child) =>
                                                DateTimePickerDarkTheme
                                                    .buildDarkTheme(
                                                        context, child!),
                                            context: context,
                                            initialDate: extraGuestController!
                                                .service!.end!,
                                            firstDate: extraGuestController
                                                .booking!.inDate!
                                                .add(const Duration(days: 1)),
                                            lastDate: extraGuestController
                                                .booking!.outDate!,
                                          );
                                          if (picked != null) {
                                            extraGuestController
                                                .updateEndDate(picked);
                                          }
                                        },
                                        icon: const Icon(Icons.calendar_today))
                              ],
                            ),
                          ),
                        ]),
                        //Price
                        DataRow(
                          cells: [
                            DataCell(Padding(
                                padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronTextContent(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE)))),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: SizeManagement.dropdownLeftPadding),
                                child: booking == null
                                    ? NeutronTextContent(
                                        color: ColorManagement.positiveText,
                                        message: NumberUtil.numberFormat
                                            .format(service!.price!),
                                      )
                                    : NeutronInputNumberController(
                                            extraGuestController!
                                                    .teExtraGuestControllers[
                                                'price']!)
                                        .buildWidget(
                                        isDecor: false,
                                        padding: 0,
                                        textColor: ColorManagement.positiveText,
                                        textAlign: TextAlign.left,
                                        readOnly: booking!
                                                .isServiceUpdatable(service!)
                                            ? false
                                            : true,
                                        validator: (String? inputData) {
                                          //if inputData empty or not a integer-number -> invalid
                                          if (inputData == null ||
                                              inputData.isEmpty ||
                                              !NumberValidator.validatePositiveNumber(
                                                  NeutronInputNumberController(
                                                          extraGuestController
                                                                  .teExtraGuestControllers[
                                                              'price']!)
                                                      .getRawString())) {
                                            return MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .INPUT_POSITIVE_NUMBER);
                                          }
                                          return null;
                                        },
                                        hint: '0',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ))),
        Container(
          color: ColorManagement.lightMainBackground,
          margin:
              const EdgeInsets.only(top: 6, bottom: 15, left: 12, right: 12),
          child: NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: extraGuestController?.teSaler ??
                TextEditingController(text: service!.saler),
            readOnly: extraGuestController?.teSaler == null,
            onChanged: (value) => extraGuestController!.setEmailSaler(
                value, extraGuestController?.emailSalerOld ?? service!.saler!),
            suffixIcon: IconButton(
              onPressed: () => extraGuestController!.checkEmailExists(
                  extraGuestController?.teSaler.text ?? service!.saler!),
              icon: extraGuestController?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : extraGuestController?.isCheckEmail ?? true
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: extraGuestController?.isCheckEmail ?? true
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
                    (await PDFUtil.buildExtraguestPDFDoc(
                            printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class AddExtraGuestDialog extends StatefulWidget {
  final Booking? booking;

  const AddExtraGuestDialog({Key? key, this.booking}) : super(key: key);
  @override
  State<AddExtraGuestDialog> createState() => _AddExtraGuestDialogState();
}

class _AddExtraGuestDialogState extends State<AddExtraGuestDialog> {
  final formKey = GlobalKey<FormState>();

  AddExtraGuestController? controller;
  late NeutronInputNumberController teNumberController, tePriceController;

  @override
  void initState() {
    controller ??= AddExtraGuestController(widget.booking!);
    teNumberController = NeutronInputNumberController(controller!.teNumber);
    tePriceController = NeutronInputNumberController(controller!.tePrice);
    super.initState();
  }

  @override
  void dispose() {
    controller?.disposeTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            height: 610,
            width: kMobileWidth,
            child: Form(
                key: formKey,
                child: ChangeNotifierProvider.value(
                  value: controller,
                  child: Consumer<AddExtraGuestController>(
                    builder: (_, controller, __) => controller.adding
                        ? const Align(
                            heightFactor: 50,
                            widthFactor: 50,
                            child: CircularProgressIndicator(
                              color: ColorManagement.greenColor,
                            ),
                          )
                        : Stack(children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 65),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    //title
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: SizeManagement
                                              .topHeaderTextSpacing),
                                      alignment: Alignment.center,
                                      child: NeutronTextHeader(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .HEADER_ADD_EXTRA_GUEST_INVOICE),
                                      ),
                                    ),
                                    //Type + number
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    vertical: SizeManagement
                                                        .rowSpacing),
                                                child: NeutronTextTitle(
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_TYPE),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    right: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    bottom: SizeManagement
                                                        .bottomFormFieldSpacing),
                                                child: NeutronDropDownCustom(
                                                  childWidget: NeutronDropDown(
                                                      isPadding: false,
                                                      value: MessageUtil
                                                          .getMessageByCode(
                                                              controller.type),
                                                      onChanged:
                                                          (String newType) {
                                                        controller
                                                            .setType(newType);
                                                      },
                                                      items: [
                                                        MessageUtil
                                                            .getMessageByCode(
                                                                MessageCodeUtil
                                                                    .TEXTALERT_ADULT),
                                                        MessageUtil
                                                            .getMessageByCode(
                                                                MessageCodeUtil
                                                                    .TEXTALERT_CHILD)
                                                      ]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    vertical: SizeManagement
                                                        .rowSpacing),
                                                child: NeutronTextTitle(
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_NUMBER),
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    right: SizeManagement
                                                        .cardOutsideHorizontalPadding,
                                                    bottom: SizeManagement
                                                        .bottomFormFieldSpacing),
                                                child: teNumberController
                                                    .buildWidget(
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return null;
                                                    }
                                                    return NumberValidator
                                                            .validateNumber(
                                                                teNumberController
                                                                    .getRawString())
                                                        ? null
                                                        : MessageUtil
                                                            .getMessageByCode(
                                                                MessageCodeUtil
                                                                    .INPUT_NUMBER);
                                                  },
                                                  hint: '0',
                                                  onChanged: (value) {
                                                    controller.updateValue();
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    //In
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_IN_DATE),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child: NeutronDateTimePickerBorder(
                                            isEditDateTime: true,
                                            firstDate:
                                                controller.booking.inDate,
                                            lastDate: controller
                                                .booking.outDate!
                                                .subtract(
                                                    const Duration(days: 1)),
                                            initialDate: controller.startDate,
                                            onPressed: (DateTime? picked) {
                                              if (picked != null) {
                                                controller.setStartDate(picked);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    //out
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            vertical: SizeManagement.rowSpacing,
                                          ),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_OUT_DATE),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child: NeutronDateTimePickerBorder(
                                            isEditDateTime: true,
                                            initialDate: controller.endDate,
                                            firstDate: controller
                                                .booking.inDate!
                                                .add(const Duration(days: 1)),
                                            lastDate:
                                                controller.booking.outDate,
                                            onPressed: (DateTime? picked) {
                                              if (picked != null) {
                                                controller.setEndDate(picked);
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    //Price
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            vertical: SizeManagement.rowSpacing,
                                          ),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_PRICE),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing,
                                          ),
                                          child: tePriceController.buildWidget(
                                            validator: (String? value) =>
                                                NumberValidator
                                                        .validatePositiveNumber(
                                                            value!.replaceAll(
                                                                ',', ''))
                                                    ? null
                                                    : MessageUtil.getMessageByCode(
                                                        MessageCodeUtil
                                                            .INPUT_POSITIVE_NUMBER),
                                            onChanged: (value) {
                                              controller.updateValue();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    //Saler
                                    Container(
                                      color:
                                          ColorManagement.lightMainBackground,
                                      margin: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 15,
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextFormField(
                                        paddingVertical: 16,
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_SALER),
                                        isDecor: true,
                                        controller: controller.teSaler,
                                        onChanged: (value) =>
                                            controller.setEmailSaler(value,
                                                controller.emailSalerOld),
                                        suffixIcon: IconButton(
                                          onPressed: () =>
                                              controller.checkEmailExists(
                                                  controller.teSaler.text),
                                          icon: controller.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: ColorManagement
                                                              .greenColor),
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
                                    //Total
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_TOTAL),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing,
                                          ),
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .dropdownLeftPadding),
                                          child: NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: controller.total,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: NeutronButton(
                                  icon: Icons.save,
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final result =
                                          await controller.addExtraGuest();
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
                ))));
  }
}
