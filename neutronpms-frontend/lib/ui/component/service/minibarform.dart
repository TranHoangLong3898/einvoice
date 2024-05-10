import 'package:flutter/material.dart';
import 'package:ihotel/manager/itemmanager.dart';
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
import '../../../controller/booking/service/minibarcontroller.dart';
import '../../../manager/bookingmanager.dart';
import '../../../manager/minibarmanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/minibar.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/pdfutil.dart';
import '../../controls/neutronexpansionlist.dart';

class MinibarForm extends StatefulWidget {
  final Booking booking;

  const MinibarForm({Key? key, required this.booking}) : super(key: key);

  @override
  State<MinibarForm> createState() => _MinibarFormState();
}

class _MinibarFormState extends State<MinibarForm> {
  MinibarController? controller;

  @override
  void initState() {
    controller ??= MinibarController(widget.booking);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Minibar-tab on ServiceDiaglog
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.mainBackground,
      width: ResponsiveUtil.isMobile(context) ? kMobileWidth : kWidth,
      height: kHeight,
      child: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<MinibarController>(
          builder: (_, controller, __) => Stack(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildPanels(controller)),
            ),
            //button add minibar invoice
            if (controller.booking.isMinibarEditable() &&
                MinibarManager().getActiveItemsId().isNotEmpty &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddMinibarDialog(
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

  //build list minibar services of booking
  Widget _buildPanels(MinibarController controller) {
    if (widget.booking.status != BookingStatus.checkout &&
        MinibarManager().getActiveItemsId().isEmpty) {
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
                    MessageCodeUtil.SERVICE_CATEGORY_MINIBAR)
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
    final services = controller.minibars!.toList();
    if (controller.minibars == null) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: NeutronTextContent(
            message:
                MessageUtil.getMessageByCode(MessageCodeUtil.UNDEFINED_ERROR)),
      );
    }

    if (controller.minibars!.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: NeutronTextContent(
            message: controller.booking.isMinibarEditable()
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

// ignore: must_be_immutable
class MininbarInvoiceForm extends StatelessWidget {
  //set state for total money each minibar service panel
  final UpdateMinibarController? minibarController;
  final Minibar? service;
  final Booking? booking;
  final GlobalKey? minibarEditForm;
  Map<String, NeutronInputNumberController> inputControllers = {};

  MininbarInvoiceForm(
      {Key? key,
      this.service,
      this.booking,
      this.minibarController,
      this.minibarEditForm})
      : super(key: key) {
    if (minibarController != null) {
      minibarController!.teMinibarControllers.forEach((key, value) {
        inputControllers[key] = NeutronInputNumberController(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double maxWidthOfInputField =
        (isMobile || minibarController == null) ? 89 : 192;
    final double maxWidthOfNameField =
        (isMobile || minibarController == null) ? 90 : 194;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        //list items of minibar service
        Form(
          key: minibarEditForm,
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
                            child: inputControllers[item]!.buildWidget(
                              isDecor: false,
                              textAlign: TextAlign.center,
                              readOnly: booking!.isServiceUpdatable(service!)
                                  ? false
                                  : true,
                              validator: (String? inputData) {
                                //if inputData empty or not a integer-number -> invalid
                                if (inputData!.isNotEmpty &&
                                    !NumberValidator.validateNonNegativeNumber(
                                        inputControllers[item]!
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
            controller: minibarController?.teDesc ??
                TextEditingController(text: service!.desc),
            isDecor: true,
            readOnly: minibarController?.teDesc == null,
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
            controller: minibarController?.teSaler ??
                TextEditingController(text: service!.saler),
            readOnly: minibarController?.teSaler == null,
            onChanged: (value) => minibarController!.setEmailSaler(
                value, minibarController?.emailSalerOld ?? service!.saler!),
            suffixIcon: IconButton(
              onPressed: () => minibarController!.checkEmailExists(
                  minibarController?.teSaler.text ?? service!.saler!),
              icon: minibarController?.isLoading ?? false
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : minibarController?.isCheckEmail ?? true
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: minibarController?.isCheckEmail ?? true
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
                    (await PDFUtil.buildMinibarPDFDoc(printBooking!, service!))
                        .save());
          },
          icon: const Icon(Icons.print),
        )
      ],
    );
  }
}

class AddMinibarDialog extends StatefulWidget {
  final Booking? booking;
  const AddMinibarDialog({
    Key? key,
    this.booking,
  }) : super(key: key);

  @override
  State<AddMinibarDialog> createState() => _AddMinibarDialogState();
}

class _AddMinibarDialogState extends State<AddMinibarDialog> {
  final formKey = GlobalKey<FormState>();

  AddMinibarController? controller;
  late List<String> minibarItems;
  Map<String, NeutronInputNumberController> teMinibarControllers = {};

  @override
  void initState() {
    controller ??= AddMinibarController(widget.booking);
    minibarItems = controller!.getMinibarItems();
    for (var item in minibarItems) {
      teMinibarControllers[item] =
          NeutronInputNumberController(controller!.teMinibarControllers[item]!);
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
    bool isMobile = ResponsiveUtil.isMobile(context);
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        color: ColorManagement.lightMainBackground,
        width: isMobile ? kMobileWidth : kWidth,
        height: kHeight,
        child: Form(
          key: formKey,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<AddMinibarController>(
              builder: (_, controller, __) {
                if (controller.adding) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  );
                }
                return Stack(
                  children: [
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
                                  vertical:
                                      SizeManagement.topHeaderTextSpacing),
                              alignment: Alignment.center,
                              child: NeutronTextHeader(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_ADD_MINIBAR_INVOICE)),
                            ),
                            Container(
                              color: ColorManagement.lightMainBackground,
                              margin: const EdgeInsets.only(
                                  top: 6, bottom: 15, left: 15, right: 15),
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
                                  top: 6, bottom: 15, left: 15, right: 15),
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
                            if (isMobile)
                              for (var i = 0; i < minibarItems.length; i++)
                                buildItem(i),
                            //display on web
                            if (!isMobile)
                              for (var i = 0; i < minibarItems.length; i++)
                                Row(
                                  children: [
                                    Expanded(child: buildItem(i)),
                                    if (++i < minibarItems.length)
                                      Expanded(child: buildItem(i)),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ),
                    //button save
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: NeutronButton(
                        icon: Icons.save,
                        onPressed: handleSave,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildItem(int itemIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin:
              const EdgeInsets.only(top: SizeManagement.rowSpacing, left: 15),
          child: NeutronTextTitle(
              isPadding: false,
              message: MinibarManager()
                  .getItemNameByID(minibarItems[itemIndex])
                  .toUpperCase()),
        ),
        //Input field
        Container(
          color: ColorManagement.lightMainBackground,
          margin:
              const EdgeInsets.only(top: 6, bottom: 15, left: 15, right: 15),
          child: teMinibarControllers.values.elementAt(itemIndex).buildWidget(
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return null;
                  }
                  return NumberValidator.validateNumber(
                          value.replaceAll(',', '').trim())
                      ? null
                      : MessageUtil.getMessageByCode(
                          MessageCodeUtil.INPUT_NUMBER);
                },
                hint: '0',
                color: ColorManagement.mainBackground,
              ),
        ),
      ],
    );
  }

  void handleSave() async {
    if (formKey.currentState!.validate()) {
      final result = await controller!.addMinibar();
      if (!mounted) {
        return;
      }
      if (result == MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
        Navigator.pop(context, result);
      } else {
        MaterialUtil.showAlert(context, result);
      }
    }
  }
}
