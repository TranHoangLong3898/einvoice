// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotelservice/bikehotelservicecontroller.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/hotelservice/bikehotelservice.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';

// ignore: must_be_immutable
class BikeHotelServiceDialog extends StatelessWidget {
  final BikeHotelService? bikeHotelService;
  late BikeHotelServiceController controller;
  late NeutronInputNumberController tePriceController;

  BikeHotelServiceDialog({Key? key, this.bikeHotelService}) : super(key: key) {
    controller = BikeHotelServiceController(bikeHotelService);
    tePriceController =
        NeutronInputNumberController(controller.tePriceController);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        height: 510,
        color: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<BikeHotelServiceController>.value(
          value: controller,
          child: Consumer<BikeHotelServiceController>(
            builder: (_, controller, __) {
              return controller.isInProgress
                  ? const Align(
                      widthFactor: 50,
                      heightFactor: 50,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ))
                  : Form(
                      key: formKey,
                      child: Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 60),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //header
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          SizeManagement.topHeaderTextSpacing),
                                  child: NeutronTextHeader(
                                    message: controller.isAddFeature
                                        ? UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_CREATE_BIKE)
                                        : UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_UPDATE_BIKE),
                                  ),
                                ),
                                //ID
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ID),
                                    isPadding: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextFormField(
                                    readOnly: !controller.isAddFeature,
                                    isDecor: true,
                                    controller: controller.teIdController,
                                    validator: (value) {
                                      if (!controller.isAddFeature) return null;
                                      return StringValidator.validateRequiredId(
                                          value);
                                    },
                                  ),
                                ),
                                //Type of bike: manual or auto
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TYPE),
                                    isPadding: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronDropDownCustom(
                                    childWidget: NeutronDropDown(
                                      isPadding: false,
                                      value: MessageUtil.getMessageByCode(
                                          controller.service!.bikeType),
                                      items: [
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.TEXTALERT_MANUAL),
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.TEXTALERT_AUTO)
                                      ],
                                      onChanged: (String value) {
                                        controller.setBikeType(value);
                                      },
                                    ),
                                  ),
                                ),
                                //Supplier
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_SUPPLIER),
                                    isPadding: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronDropDownCustom(
                                    childWidget: NeutronDropDown(
                                      isPadding: false,
                                      value: SupplierManager()
                                          .getSupplierNameByID(
                                              controller.service!.supplierId!),
                                      items: controller.supplierNames,
                                      onChanged: (String supplierName) {
                                        controller.setSupplier(supplierName);
                                      },
                                    ),
                                  ),
                                ),
                                //Price
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    isPadding: false,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: tePriceController.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    validator: (String? value) {
                                      if (value == null ||
                                          !NumberValidator
                                              .validatePositiveNumber(
                                                  tePriceController
                                                      .getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .PRICE_MUST_BE_NUMBER);
                                      }
                                      return null;
                                    },
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
                                String result = await controller
                                    .updateBike()
                                    .then((value) => value);
                                if (result ==
                                    MessageUtil.getMessageByCode(
                                        MessageCodeUtil.SUCCESS)) {
                                  Navigator.pop(context);
                                }
                                MaterialUtil.showResult(context, result);
                              }
                            },
                          ),
                        )
                      ]),
                    );
            },
          ),
        ),
      ),
    );
  }
}
