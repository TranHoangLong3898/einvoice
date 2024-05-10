import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/insiderestaurantcontroller.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/service/hotelservice/hotelservicedialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../controls/neutronexpansionlist.dart';

class InsideRestaurantForm extends StatefulWidget {
  final Booking booking;

  const InsideRestaurantForm({Key? key, required this.booking})
      : super(key: key);

  @override
  State<InsideRestaurantForm> createState() => _InsideRestaurantFormState();
}

class _InsideRestaurantFormState extends State<InsideRestaurantForm> {
  InsideRestaurantController? controller;

  @override
  void initState() {
    controller ??= InsideRestaurantController(widget.booking);
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
        child: Consumer<InsideRestaurantController>(
          builder: (_, controller, __) => Stack(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildPanels(controller)),
            ),
            if (controller.booking.isInsideRestaurantEditable() &&
                RestaurantItemManager().getActiveItemsId().isNotEmpty &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddInsideRestaurantDialog(
                            booking: controller.booking),
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

  Widget _buildPanels(InsideRestaurantController controller) {
    if (widget.booking.status != BookingStatus.checkout &&
        RestaurantItemManager().getActiveItemsId().isEmpty) {
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
                '${MessageUtil.getMessageByCode(MessageCodeUtil.SERVICE_CATEGORY_RESTAURANT)} (${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_INSIDE_HOTEL)})'
              ]),
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            TextButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) =>
                        const HotelServiceDialog(indexSelectedTab: 0));
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
    final services = controller.insideRestaurants!.toList();
    if (controller.insideRestaurants == null) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: NeutronTextContent(
            message:
                MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR)),
      );
    }

    if (controller.insideRestaurants!.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: NeutronTextContent(
            message: controller.booking.isInsideRestaurantEditable()
                ? MessageUtil.getMessageByCode(
                    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                : UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NO_SERVICE_IN_USE)),
      );
    }

    //sort list by created timestamp
    services.sort((a, b) => a.created!.compareTo(b.created!));
    return NeutronExpansionPanelList(
      services: services,
      booking: controller.booking,
    );
  }
}

class InsideRestaurantInvoiceForm extends StatelessWidget {
  final UpdateInsideRestaurantController? controller;
  final InsideRestaurantService? service;
  final Booking? booking;
  final GlobalKey? editForm;

  const InsideRestaurantInvoiceForm(
      {Key? key, this.service, this.booking, this.controller, this.editForm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double maxWidthOfInputField =
        (isMobile || controller == null) ? 89 : 192;
    final double maxWidthOfNameField =
        (isMobile || controller == null) ? 90 : 194;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: editForm,
          child: DataTable(
              columnSpacing: 3,
              horizontalMargin: 3,
              columns: <DataColumn>[
                DataColumn(
                  label: Container(
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardInsideHorizontalPadding),
                      child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM))),
                ),
                DataColumn(
                  label: Expanded(
                      child: Center(
                          child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PRICE),
                  ))),
                ),
                DataColumn(
                  label: Expanded(
                      child: Center(
                          child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_AMOUNT),
                  ))),
                ),
              ],
              rows: service!.getItems()!.map((item) {
                final name = ItemManager().getItemNameByID(item);
                return DataRow(
                  cells: <DataCell>[
                    //name
                    DataCell(Container(
                      constraints: BoxConstraints(
                          maxWidth: maxWidthOfNameField,
                          minWidth: maxWidthOfNameField),
                      padding: const EdgeInsets.only(
                          left: SizeManagement.cardInsideHorizontalPadding),
                      child: NeutronTextContent(
                        message: name!,
                      ),
                    )),
                    //price
                    DataCell(Container(
                      constraints: BoxConstraints(
                          maxWidth: maxWidthOfInputField,
                          minWidth: maxWidthOfInputField),
                      alignment: Alignment.center,
                      child: NeutronTextContent(
                        color: ColorManagement.positiveText,
                        message: NumberUtil.numberFormat
                            .format(service!.getPrice(item)),
                      ),
                    )),
                    //value
                    DataCell(booking == null
                        ? Center(
                            child: NeutronTextContent(
                              message: service!.getAmount(item).toString(),
                            ),
                          )
                        : Container(
                            constraints: BoxConstraints(
                                maxWidth: maxWidthOfInputField,
                                minWidth: maxWidthOfInputField),
                            alignment: Alignment.center,
                            child: controller!.teControllers[item]!.buildWidget(
                              isDecor: false,
                              textAlign: TextAlign.center,
                              readOnly: booking!.isServiceUpdatable(service!)
                                  ? false
                                  : true,
                              validator: (String? inputData) {
                                //if inputData empty or not a integer-number -> invalid
                                if (inputData!.isNotEmpty &&
                                    !NumberValidator.validateNonNegativeNumber(
                                        controller!.teControllers[item]!
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
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: controller?.teSaler ??
                TextEditingController(text: service!.saler),
            readOnly: controller?.teSaler == null,
            onChanged: (value) => controller!.setEmailSaler(
                value, controller?.emailSalerOld ?? service!.saler!),
            suffixIcon: IconButton(
              onPressed: () => controller!.checkEmailExists(
                  controller?.teSaler.text ?? service!.saler!),
              icon: controller?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : controller?.isCheckEmail ?? true
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: controller?.isCheckEmail ?? true
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
                    (await PDFUtil.buildInsideRestaurantPDFDoc(
                            printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class AddInsideRestaurantDialog extends StatefulWidget {
  final Booking? booking;

  const AddInsideRestaurantDialog({Key? key, this.booking}) : super(key: key);

  @override
  State<AddInsideRestaurantDialog> createState() =>
      _AddInsideRestaurantDialogState();
}

class _AddInsideRestaurantDialogState extends State<AddInsideRestaurantDialog> {
  final formKey = GlobalKey<FormState>();

  AddInsideRestaurantController? controller;
  late List<String?> items;
  Map<String, NeutronInputNumberController> teControllers = {};

  @override
  void initState() {
    controller ??= AddInsideRestaurantController(widget.booking);
    items = controller!.getItems();
    for (var item in items) {
      teControllers[item!] =
          NeutronInputNumberController(controller!.teControllers[item]!);
    }
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
      child: Container(
          color: ColorManagement.lightMainBackground,
          width: ResponsiveUtil.isMobile(context) ? kMobileWidth : kWidth,
          height: kHeight,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<AddInsideRestaurantController>(
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
                return Stack(children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //Title
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: SizeManagement.topHeaderTextSpacing),
                            alignment: Alignment.center,
                            child: NeutronTextHeader(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_ADD_RESTAURANT_INVOICE)),
                          ),
                          Container(
                            color: ColorManagement.lightMainBackground,
                            margin: const EdgeInsets.only(
                                top: 6,
                                bottom: 15,
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
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
                                onPressed: () => controller
                                    .checkEmailExists(controller.teSaler.text),
                                icon: controller.isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: ColorManagement.greenColor),
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
                          //Form
                          Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  //display on mobile
                                  if (ResponsiveUtil.isMobile(context))
                                    for (var i = 0; i < items.length; i++)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: SizeManagement.rowSpacing,
                                                left: SizeManagement
                                                    .cardOutsideHorizontalPadding),
                                            child: NeutronTextTitle(
                                                isPadding: false,
                                                message: RestaurantItemManager()
                                                    .getItemNameByID(items[i]!)!
                                                    .toUpperCase()),
                                          ),
                                          //Input field
                                          Container(
                                            color: ColorManagement
                                                .lightMainBackground,
                                            margin: const EdgeInsets.only(
                                                top: 6,
                                                bottom: 15,
                                                left: 15,
                                                right: 15),
                                            child: teControllers.values
                                                .elementAt(i)
                                                .buildWidget(
                                                  validator: (String? value) {
                                                    if (value!.isEmpty) {
                                                      return null;
                                                    }
                                                    return NumberValidator
                                                            .validateNumber(
                                                                teControllers
                                                                    .values
                                                                    .elementAt(
                                                                        i)
                                                                    .getRawString())
                                                        ? null
                                                        : MessageUtil
                                                            .getMessageByCode(
                                                                MessageCodeUtil
                                                                    .INPUT_NUMBER);
                                                  },
                                                  hint: '0',
                                                  color: ColorManagement
                                                      .mainBackground,
                                                ),
                                          ),
                                        ],
                                      ),
                                  //display on web
                                  if (!ResponsiveUtil.isMobile(context))
                                    for (var i = 0; i < items.length; i++)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: SizeManagement
                                                          .rowSpacing,
                                                      bottom: SizeManagement
                                                          .rowSpacing,
                                                      left: SizeManagement
                                                          .cardOutsideHorizontalPadding),
                                                  child: NeutronTextTitle(
                                                      isPadding: false,
                                                      message:
                                                          RestaurantItemManager()
                                                              .getItemNameByID(
                                                                  items[i]!)!
                                                              .toUpperCase()),
                                                ),
                                                //Input field
                                                Container(
                                                  color: ColorManagement
                                                      .lightMainBackground,
                                                  margin: const EdgeInsets.only(
                                                      bottom: SizeManagement
                                                          .bottomFormFieldSpacing,
                                                      left: SizeManagement
                                                          .cardOutsideHorizontalPadding,
                                                      right: SizeManagement
                                                          .cardOutsideHorizontalPadding),
                                                  child: teControllers.values
                                                      .elementAt(i)
                                                      .buildWidget(
                                                        validator:
                                                            (String? value) {
                                                          if (value!.isEmpty) {
                                                            return null;
                                                          }
                                                          return NumberValidator
                                                                  .validateNumber(
                                                                      value)
                                                              ? null
                                                              : MessageUtil
                                                                  .getMessageByCode(
                                                                      MessageCodeUtil
                                                                          .INPUT_NUMBER);
                                                        },
                                                        hint: '0',
                                                        color: ColorManagement
                                                            .mainBackground,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (++i < items.length)
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .only(
                                                        top: SizeManagement
                                                            .rowSpacing,
                                                        bottom: SizeManagement
                                                            .rowSpacing,
                                                        left: SizeManagement
                                                            .cardOutsideHorizontalPadding),
                                                    child: NeutronTextTitle(
                                                        isPadding: false,
                                                        message:
                                                            RestaurantItemManager()
                                                                .getItemNameByID(
                                                                    items[i]!)!
                                                                .toUpperCase()),
                                                  ),
                                                  //Input field
                                                  Container(
                                                    color: ColorManagement
                                                        .lightMainBackground,
                                                    margin: const EdgeInsets
                                                        .only(
                                                        bottom: SizeManagement
                                                            .bottomFormFieldSpacing,
                                                        left: SizeManagement
                                                            .cardOutsideHorizontalPadding,
                                                        right: SizeManagement
                                                            .cardOutsideHorizontalPadding),
                                                    child: teControllers.values
                                                        .elementAt(i)
                                                        .buildWidget(
                                                          validator:
                                                              (String? value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return null;
                                                            }
                                                            return NumberValidator
                                                                    .validateNumber(
                                                                        value)
                                                                ? null
                                                                : MessageUtil
                                                                    .getMessageByCode(
                                                                        MessageCodeUtil
                                                                            .INPUT_NUMBER);
                                                          },
                                                          hint: '0',
                                                          color: ColorManagement
                                                              .mainBackground,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      )
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  //button save
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final result =
                                await controller.addInsideRestaurant();
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
                ]);
              },
            ),
          )),
    );
  }
}
