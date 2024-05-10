import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/service/bikerentalcontroller.dart';
import '../../../manager/bikerentalmanager.dart';
import '../../../manager/servicemanager.dart';
import '../../../manager/suppliermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../validator/numbervalidator.dart';
import '../../controls/neutronexpansionlist.dart';
import 'hotelservice/hotelservicedialog.dart';

class BikeRentalForm extends StatefulWidget {
  final Booking booking;

  const BikeRentalForm({Key? key, required this.booking}) : super(key: key);

  @override
  State<BikeRentalForm> createState() => _BikeRentalFormState();
}

class _BikeRentalFormState extends State<BikeRentalForm> {
  late BikeRentalController controller;
  @override
  void initState() {
    controller = BikeRentalController(widget.booking);
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
        child: Consumer<BikeRentalController>(
          builder: (_, controller, __) =>
              Stack(fit: StackFit.expand, children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildPanels(controller)),
            ),
            if (controller.booking.isBikeRentalEditable() &&
                ConfigurationManagement().bikeConfigs['auto'] != null &&
                ConfigurationManagement().bikeConfigs['manual'] != null &&
                controller.booking.id != controller.booking.sID)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (ctx) => AddBikeRentalDialog(
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

  Widget _buildPanels(BikeRentalController controller) {
    if (widget.booking.status != BookingStatus.checkout &&
        ConfigurationManagement().bikeConfigs['auto'] == null &&
        ConfigurationManagement().bikeConfigs['manual'] == null) {
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
                    MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL)
              ]),
            ),
            const SizedBox(height: SizeManagement.rowSpacing),
            TextButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) =>
                        const HotelServiceDialog(indexSelectedTab: 3));
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
    if (controller.bikeRentals.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.only(top: SizeManagement.topHeaderTextSpacing),
        alignment: Alignment.center,
        child: NeutronTextContent(
            message: controller.booking.isBikeRentalEditable()
                ? MessageUtil.getMessageByCode(
                    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON)
                : UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NO_SERVICE_IN_USE)),
      );
    }

    final servicePanelModals = controller.bikeRentals.toList();

    servicePanelModals.sort((a, b) => a.created!.compareTo(b.created!));

    return NeutronExpansionPanelList(
      services: servicePanelModals,
      booking: controller.booking,
    );
  }
}

class AddBikeRentalDialog extends StatefulWidget {
  final Booking? booking;

  const AddBikeRentalDialog({Key? key, this.booking}) : super(key: key);

  @override
  State<AddBikeRentalDialog> createState() => _AddBikeRentalDialogState();
}

class _AddBikeRentalDialogState extends State<AddBikeRentalDialog> {
  final formKey = GlobalKey<FormState>();
  late AddBikeRentalController addBikeRentalController;
  NeutronInputNumberController? inputMoneyController;
  @override
  void initState() {
    addBikeRentalController = AddBikeRentalController(widget.booking!);
    inputMoneyController =
        NeutronInputNumberController(addBikeRentalController.tePrice);
    super.initState();
  }

  @override
  void dispose() {
    inputMoneyController = null;
    addBikeRentalController.disposeTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 550,
        child: ChangeNotifierProvider.value(
          value: addBikeRentalController,
          child: Consumer<AddBikeRentalController>(
            builder: (_, controller, __) => controller.adding
                ? const Align(
                    widthFactor: 50,
                    heightFactor: 50,
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Form(
                    key: formKey,
                    child: Stack(children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Title
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        SizeManagement.topHeaderTextSpacing),
                                child: NeutronTextHeader(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode
                                          .HEADER_ADD_BIKE_RENTAL_INVOICE),
                                ),
                              ),
                              //Supplier
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SUPPLIER))),
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
                                      value: SupplierManager()
                                          .getSupplierNameByID(
                                              controller.supplierID),
                                      onChanged: (String newSupplierName) {
                                        controller.setSupplier(newSupplierName);
                                      },
                                      items: SupplierManager()
                                          .getActiveSupplierNamesByService(
                                              ServiceManager.BIKE_RENTAL_CAT)),
                                ),
                              ),
                              //Type
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_TYPE))),
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
                                      value: MessageUtil.getMessageByCode(
                                          controller.type),
                                      onChanged: (String newType) {
                                        controller.setType(newType);
                                      },
                                      items: BikeRentalManager().getTypes()),
                                ),
                              ),
                              //Bike
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_BIKE))),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: Autocomplete<String>(optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return controller.bikes;
                                  }

                                  return controller.bikes
                                      .where((String option) {
                                    return option.toLowerCase().startsWith(
                                        textEditingValue.text.toLowerCase());
                                  });
                                }, onSelected: (String selection) {
                                  controller.setBike(selection);
                                }, optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: ColorManagement.mainBackground,
                                      elevation: 5,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxHeight: 200,
                                            maxWidth: kMobileWidth -
                                                SizeManagement
                                                        .cardOutsideHorizontalPadding *
                                                    2),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(0),
                                          itemBuilder: (context, index) =>
                                              ListTile(
                                            onTap: () => onSelected(
                                                options.elementAt(index)),
                                            title: Text(
                                              options.elementAt(index),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 0),
                                            minVerticalPadding: 0,
                                            hoverColor: Colors.white38,
                                          ),
                                          itemCount: options.length,
                                        ),
                                      ),
                                    ),
                                  );
                                }, fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onEditingComplete) {
                                  Future.delayed(Duration.zero, () async {
                                    textEditingController.text =
                                        controller.bike;
                                  });
                                  return NeutronTextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onEditingComplete: onEditingComplete,
                                    isDecor: true,
                                    onChanged: (String value) {
                                      controller.bike = value;
                                    },
                                  );
                                }),
                              ),
                              //Price
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.bottomFormFieldSpacing,
                                ),
                                child: inputMoneyController!.buildWidget(
                                  validator: (String? value) => NumberValidator
                                          .validatePositiveNumber(
                                              inputMoneyController!
                                                  .getRawString())
                                      ? null
                                      : MessageUtil.getMessageByCode(
                                          MessageCodeUtil.PRICE_MUST_BE_NUMBER),
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
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButton(
                            icon: Icons.save,
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final result = await controller.addBikeRental();
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
