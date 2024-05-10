import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotelservice/suppliercontroller.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';

class SupplierDialog extends StatelessWidget {
  const SupplierDialog({Key? key, this.supplier}) : super(key: key);

  final dynamic supplier;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider<SupplierController>.value(
          value: SupplierController(supplier: supplier),
          child: Consumer<SupplierController>(
            builder: (_, controller, __) {
              return controller.isInProgress
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ))
                  : Form(
                      key: controller.formKey,
                      child: Stack(
                        children: [
                          Container(
                            height: kHeight,
                            width: kMobileWidth,
                            margin: const EdgeInsets.only(bottom: 60),
                            color: ColorManagement.lightMainBackground,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          SizeManagement.topHeaderTextSpacing),
                                  child: NeutronTextHeader(
                                    message: controller.isAddFeature
                                        ? UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_CREATE_SUPPLIER)
                                        : UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_UPDATE_SUPPLIER),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextFormField(
                                    readOnly: !controller.isAddFeature,
                                    isDecor: true,
                                    controller: controller.teIdController,
                                    validator: (String? value) {
                                      if (!controller.isAddFeature) return null;
                                      return validateId(value!);
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      top: SizeManagement.rowSpacing),
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
                                //services
                                Expanded(
                                  child: ListView(
                                    children: controller.services.keys
                                        .map((key) => CheckboxListTile(
                                            activeColor:
                                                ColorManagement.greenColor,
                                            checkColor: Colors.white,
                                            title: NeutronTextContent(
                                                message: OtherManager()
                                                    .getServiceNameByID(key)),
                                            value: controller.services[key],
                                            onChanged: (bool? value) {
                                              controller.updateServices(
                                                  key, value!);
                                            }))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: NeutronButton(
                              icon: Icons.save,
                              onPressed: () => handleSave(context, controller),
                            ),
                          )
                        ],
                      ));
            },
          ),
        ),
      ),
    );
  }

  Widget serviceItem(SupplierController controller, String serviceId) {
    return CheckboxListTile(
        activeColor: ColorManagement.greenColor,
        checkColor: Colors.white,
        title: NeutronTextContent(
            message: OtherManager().getServiceNameByID(serviceId)),
        value: controller.services[key],
        onChanged: (bool? value) {
          controller.updateServices(serviceId, value!);
        });
  }

  String? validateId(String? value) {
    if (value == null || value.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_ID);
    }
    if (value.trim().isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.ID_CAN_NOT_BE_BLANK);
    }
    if (value.length > 16) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_SUPPLIER_ID_MAX_LENGTH);
    }
    if (!StringValidator.sidRegex.hasMatch(value)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
    }
    return null;
  }

  void handleSave(BuildContext context, SupplierController controller) async {
    if (controller.formKey.currentState!.validate()) {
      await controller.updateSupplier().then((result) {
        if (result == MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
          Navigator.pop(context, true);
        }
        MaterialUtil.showResult(context, result);
      });
    }
  }
}
