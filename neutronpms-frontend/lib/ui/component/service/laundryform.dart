import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/service/laundrycontroller.dart';
import '../../../manager/bookingmanager.dart';
import '../../../manager/laundrymanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/laundry.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../../validator/numbervalidator.dart';
import '../../controls/neutronexpansionlist.dart';
import 'hotelservice/hotelservicedialog.dart';

class LaundryForm extends StatefulWidget {
  final Booking booking;

  const LaundryForm({Key? key, required this.booking}) : super(key: key);

  @override
  State<LaundryForm> createState() => _LaundryFormState();
}

class _LaundryFormState extends State<LaundryForm> {
  late LaundryController controller;
  @override
  void initState() {
    controller = LaundryController(widget.booking);
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
        child: Consumer<LaundryController>(
          builder: (_, controller, __) =>
              Stack(fit: StackFit.expand, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildPanels(controller)),
            ),
            //button add laundry
            if (controller.booking.isLaundryEditable() &&
                LaundryManager().getActiveItems().isNotEmpty &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddLaundryDialog(
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

  //build list laundry services of booking
  Widget _buildPanels(LaundryController controller) {
    if (widget.booking.status != BookingStatus.checkout &&
        LaundryManager().getActiveItems().isEmpty) {
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
                    MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY)
              ]),
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            TextButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) =>
                        const HotelServiceDialog(indexSelectedTab: 1));
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
    final services = controller.laundries!.toList();
    if (controller.laundries == null) {
      return Center(
        child: NeutronTextContent(
            message:
                MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR)),
      );
    }

    if (controller.laundries!.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        child: NeutronTextContent(
            message: controller.booking.isLaundryEditable()
                ? MessageUtil.getMessageByCode(
                    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                : UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NO_SERVICE_IN_USE)),
      );
    }
    //sort list by created timestamp
    services.sort((a, b) => a.created!.compareTo(b.created!));
    controller.booking.laundry = 0;
    for (var item in services) {
      controller.booking.laundry += item.getTotal();
    }
    return NeutronExpansionPanelList(
      services: services,
      booking: controller.booking,
    );
  }
}

// ignore: must_be_immutable
class LaundryInvoiceForm extends StatelessWidget {
  //set state for total money each minibar service panel
  final UpdateLaundryController? laundryController;
  final Laundry? service;
  final Booking? booking;
  final GlobalKey? laundryEditForm;
  Map<String, NeutronInputNumberController> laundryInputControllers = {};
  Map<String, NeutronInputNumberController> ironInputControllers = {};

  LaundryInvoiceForm(
      {Key? key,
      this.service,
      this.booking,
      this.laundryController,
      this.laundryEditForm})
      : super(key: key) {
    if (laundryController != null) {
      laundryController!.getServiceItems().forEach((item) {
        laundryInputControllers[item] = NeutronInputNumberController(
            laundryController!.teLaundryControllers[item]!);
        ironInputControllers[item] = NeutronInputNumberController(
            laundryController!.teIronControllers[item]!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidthOfInputField =
        (ResponsiveUtil.isMobile(context) || laundryController == null)
            ? 68
            : 145;
    final double maxWidthOfNameField =
        (ResponsiveUtil.isMobile(context) || laundryController == null)
            ? 132
            : 288;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: laundryEditForm,
          child: DataTable(
              columnSpacing: 3,
              horizontalMargin: 3,
              columns: <DataColumn>[
                DataColumn(
                  label: Container(
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardOutsideHorizontalPadding),
                      child: NeutronTextTitle(
                        isPadding: false,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ITEM),
                      )),
                ),
                DataColumn(
                  label: Expanded(
                      child: Center(
                          child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT),
                  ))),
                ),
                DataColumn(
                  label: Expanded(
                      child: Center(
                          child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_IRON_AMOUNT),
                  ))),
                ),
              ],
              rows: service!.getItems()!.map((item) {
                final name = LaundryManager().getItemNameByID(item);
                return DataRow(
                  cells: <DataCell>[
                    //name
                    DataCell(Container(
                      constraints: BoxConstraints(
                          maxWidth: maxWidthOfNameField,
                          minWidth: maxWidthOfNameField),
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardOutsideHorizontalPadding),
                      child: NeutronTextContent(
                        message: name,
                        tooltip:
                            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT)}: ${NumberUtil.numberFormat.format(LaundryManager().getLaundryPrice(item))}\n'
                            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IRON_AMOUNT)}: ${NumberUtil.numberFormat.format(LaundryManager().getIronPrice(item))}',
                      ),
                    )),
                    //laundry
                    DataCell(booking == null
                        ? Center(
                            child: NeutronTextContent(
                              message: service!
                                  .getAmount(item, 'laundry')
                                  .toString(),
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxWidthOfInputField,
                              minWidth: maxWidthOfInputField,
                            ),
                            child: laundryInputControllers[item]!.buildWidget(
                              isDouble: true,
                              padding: 0,
                              textAlign: TextAlign.center,
                              readOnly: booking != null &&
                                      booking!.isServiceUpdatable(service!)
                                  ? false
                                  : true,
                              validator: (String? inputData) {
                                //if inputDate empty or not a integer-number -> invalid
                                if (inputData!.isNotEmpty &&
                                    !NumberValidator.validateNonNegativeNumber(
                                        laundryInputControllers[item]!
                                            .getRawString())) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_NUMBER);
                                }
                                return null;
                              },
                              hint: '0',
                              isDecor: false,
                            ),
                          )),
                    //iron
                    DataCell(booking == null
                        ? Center(
                            child: NeutronTextContent(
                              message:
                                  service!.getAmount(item, 'iron').toString(),
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxWidthOfInputField,
                              minWidth: maxWidthOfInputField,
                            ),
                            child: ironInputControllers[item]!.buildWidget(
                              isDouble: true,
                              padding: 0,
                              isDecor: false,
                              textAlign: TextAlign.center,
                              readOnly: booking != null &&
                                      booking!.isServiceUpdatable(service!)
                                  ? false
                                  : true,
                              validator: (String? inputData) {
                                //if inputDate empty or not a integer-number -> invalid
                                if (inputData!.isNotEmpty &&
                                    !NumberValidator.validateNonNegativeNumber(
                                        ironInputControllers[item]!
                                            .getRawString())) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_NUMBER);
                                }
                                return null;
                              },
                              hint: '0',
                            ),
                          )),
                  ],
                );
              }).toList()),
        ),
        Container(
          color: ColorManagement.lightMainBackground,
          margin:
              const EdgeInsets.only(top: 6, bottom: 15, left: 12, right: 12),
          child: NeutronTextFormField(
            controller: laundryController?.teDesc ??
                TextEditingController(text: service!.desc),
            isDecor: true,
            readOnly: laundryController?.teDesc == null,
            label: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
            backgroundColor: ColorManagement.mainBackground,
          ),
        ),
        Container(
          color: ColorManagement.lightMainBackground,
          margin:
              const EdgeInsets.only(top: 6, bottom: 15, left: 12, right: 12),
          child: NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: laundryController?.teSaler ??
                TextEditingController(text: service!.saler),
            readOnly: laundryController?.teSaler == null,
            onChanged: (value) => laundryController!.setEmailSaler(
                value, laundryController?.emailSalerOld ?? service!.saler!),
            suffixIcon: IconButton(
              onPressed: () => laundryController!.checkEmailExists(
                  laundryController?.teSaler.text ?? service!.saler!),
              icon: laundryController?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : laundryController?.isCheckEmail ?? true
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: laundryController?.isCheckEmail ?? true
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
                    (await PDFUtil.buildLaudryPDFDoc(printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class AddLaundryDialog extends StatefulWidget {
  final Booking? booking;
  const AddLaundryDialog({
    Key? key,
    this.booking,
  }) : super(key: key);

  @override
  State<AddLaundryDialog> createState() => _AddLaundryDialogState();
}

class _AddLaundryDialogState extends State<AddLaundryDialog> {
  final formKey = GlobalKey<FormState>();

  AddLaundryController? controller;
  Map<String, NeutronInputNumberController> pLaundryController = {};
  Map<String, NeutronInputNumberController> pIronController = {};

  @override
  void initState() {
    controller ??= AddLaundryController(widget.booking);
    LaundryManager().getActiveItems().forEach((item) {
      pLaundryController[item] =
          NeutronInputNumberController(controller!.teLaundryControllers[item]!);
      pIronController[item] =
          NeutronInputNumberController(controller!.teIronControllers[item]!);
    });
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
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<AddLaundryController>(
            builder: (_, controller, __) {
              if (controller.adding) {
                return const Align(
                  heightFactor: 50,
                  widthFactor: 50,
                  child: CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                );
              }
              return Stack(
                children: [
                  Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 60),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //header
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.topHeaderTextSpacing),
                              child: NeutronTextHeader(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_ADD_LAUNDRY_INVOICE),
                              ),
                            ),
                            Container(
                              color: ColorManagement.lightMainBackground,
                              margin: const EdgeInsets.only(
                                  top: 6,
                                  bottom: 15,
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: NeutronTextFormField(
                                controller: controller.teDesc,
                                isDecor: true,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                                backgroundColor: ColorManagement.mainBackground,
                              ),
                            ),
                            Container(
                              color: ColorManagement.lightMainBackground,
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
                                onChanged: (value) => controller.setEmailSaler(
                                    value, controller.emailSalerOld),
                                suffixIcon: IconButton(
                                  onPressed: () => controller.checkEmailExists(
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: Form(
                                key: formKey,
                                child: DataTable(
                                  columnSpacing: 3,
                                  horizontalMargin: 3,
                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: SizedBox(
                                        width: 128,
                                        child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_TYPE),
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                          alignment: Alignment.center,
                                          width: 70,
                                          child: NeutronTextTitle(
                                              isPadding: false,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_LAUNDRY_AMOUNT))),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        alignment: Alignment.center,
                                        width: 70,
                                        child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_IRON_AMOUNT)),
                                      ),
                                    )
                                  ],
                                  rows: LaundryManager()
                                      .getActiveItems()
                                      .map((item) {
                                    final name =
                                        LaundryManager().getItemNameByID(item);
                                    return DataRow(
                                      cells: <DataCell>[
                                        //name of item
                                        DataCell(Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 128, minWidth: 128),
                                          child: NeutronTextContent(
                                            message: name,
                                            tooltip:
                                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT)}: ${NumberUtil.numberFormat.format(LaundryManager().getLaundryPrice(item))}\n"
                                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IRON_AMOUNT)}: ${NumberUtil.numberFormat.format(LaundryManager().getIronPrice(item))}",
                                          ),
                                        )),
                                        //input laundry
                                        DataCell(SizedBox(
                                          width: 70,
                                          child: pLaundryController[item]!
                                              .buildWidget(
                                                  isDouble: true,
                                                  isDecor: false,
                                                  textAlign: TextAlign.center,
                                                  hint: '0',
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return null;
                                                    }
                                                    return NumberValidator
                                                            .validatePositiveNumber(
                                                                pLaundryController[
                                                                        item]!
                                                                    .getRawString())
                                                        ? null
                                                        : MessageUtil
                                                            .getMessageByCode(
                                                                MessageCodeUtil
                                                                    .INPUT_NUMBER);
                                                  }),
                                        )),
                                        //input iron
                                        DataCell(SizedBox(
                                          width: 70,
                                          child: pIronController[item]!
                                              .buildWidget(
                                            isDouble: true,
                                            isDecor: false,
                                            textAlign: TextAlign.center,
                                            hint: '0',
                                            validator: (String? value) {
                                              if (value!.isEmpty) {
                                                return null;
                                              }
                                              return NumberValidator
                                                      .validatePositiveNumber(
                                                          pIronController[item]!
                                                              .getRawString())
                                                  ? null
                                                  : MessageUtil
                                                      .getMessageByCode(
                                                          MessageCodeUtil
                                                              .INPUT_NUMBER);
                                            },
                                          ),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final result = await controller.addLaundry();
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
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
