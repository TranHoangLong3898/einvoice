// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotelservice/laundryhotelservicecontroller.dart';
import 'package:ihotel/modal/hotelservice/laundryhotelservice.dart';
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
class LaundryHotelServiceDialog extends StatelessWidget {
  final LaundryHotelService? laundryHotelService;
  late LaundryHotelServiceController controller;
  late NeutronInputNumberController tePlaudryController, tePironController;

  LaundryHotelServiceDialog({Key? key, this.laundryHotelService})
      : super(key: key) {
    controller = LaundryHotelServiceController(laundryHotelService);
    tePlaudryController =
        NeutronInputNumberController(controller.tePlaundryController);
    tePironController =
        NeutronInputNumberController(controller.tePironController);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        height: 520,
        color: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<LaundryHotelServiceController>.value(
          value: controller,
          child: Consumer<LaundryHotelServiceController>(
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
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          SizeManagement.topHeaderTextSpacing),
                                  child: NeutronTextHeader(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.LAUNDRY_ITEM),
                                  ),
                                ),
                                //id
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
                                //input id
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
                                //name
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
                                        UITitleCode.TABLEHEADER_NAME),
                                    isPadding: false,
                                  ),
                                ),
                                //input name
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teNameController,
                                    validator: (value) {
                                      return StringValidator
                                          .validateRequiredNonSpecificCharacterName(
                                              value);
                                    },
                                  ),
                                ),
                                //piron
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
                                        UITitleCode.TABLEHEADER_IRON_PRICE),
                                    isPadding: false,
                                  ),
                                ),
                                //input piron
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: tePironController.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    validator: (String? value) {
                                      if (value == null ||
                                          !NumberValidator
                                              .validateNonNegativeNumber(
                                                  tePironController
                                                      .getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .PRICE_MUST_BE_NUMBER);
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                //plaundry
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
                                        UITitleCode.TABLEHEADER_LAUNDRY_PRICE),
                                    isPadding: false,
                                  ),
                                ),
                                //input plaundry
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
                                  child: tePlaudryController.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    validator: (String? value) {
                                      if (value == null ||
                                          !NumberValidator
                                              .validateNonNegativeNumber(
                                                  tePlaudryController
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
                                    .updateLaundry()
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
