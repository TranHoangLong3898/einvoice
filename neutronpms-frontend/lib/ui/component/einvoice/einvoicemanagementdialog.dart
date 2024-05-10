// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/einvoice/einvoiceoptioncontroller.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutronswitch.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/einvoiceutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class ElectronicInvoiceManagementDialog extends StatelessWidget {
  const ElectronicInvoiceManagementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider<ElectronicInvoiceOptionController>(
          create: (context) => ElectronicInvoiceOptionController(),
          builder: (context, child) =>
              Consumer<ElectronicInvoiceOptionController>(
            child: const Center(
              child:
                  CircularProgressIndicator(color: ColorManagement.greenColor),
            ),
            builder: (context, controller, child) => controller.isLoading
                ? child!
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.topHeaderTextSpacing),
                        child: NeutronTextTitle(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.SIDEBAR_ELECTRONIC_INVOICE),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      NeutronTextContent(
                          message: UITitleUtil.getTitleByCode(UITitleCode
                              .HEADER_CONNECT_TO_ELECTRONIC_INVOICE_SOFTWARE)),
                      NeutronSwitch(
                        value: controller.isConnect,
                        onChange: (p0) {
                          controller.setConnect(p0);
                        },
                      ),
                      Expanded(
                          child: controller.isConnect
                              ? ListView(
                                  children: [
                                    const Divider(
                                      color: ColorManagement.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: NeutronDropDownCustom(
                                          borderColors: ColorManagement.white,
                                          label: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .ELECTRONIC_INVOCE_SOFTWARE),
                                          childWidget: NeutronDropDown(
                                            isPadding: false,
                                            items: [
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.NO),
                                              ...ElectronicInvoiceSoftWare
                                                  .listSoftWares()
                                            ],
                                            value: controller.software ==
                                                    UITitleCode.NO
                                                ? UITitleUtil.getTitleByCode(
                                                    UITitleCode.NO)
                                                : controller.software,
                                            onChanged: (String value) =>
                                                controller.setSoftware(value),
                                          )),
                                    ),
                                    if (controller.software ==
                                        ElectronicInvoiceSoftWare
                                            .easyInvoice) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: NeutronTextFormField(
                                            isDecor: true,
                                            borderColor: ColorManagement.white,
                                            label: UITitleUtil.getTitleByCode(
                                                UITitleCode.HEADER_USERNAME),
                                            controller: controller
                                                .usernameTeController),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: NeutronTextFormField(
                                            isDecor: true,
                                            borderColor: ColorManagement.white,
                                            label: UITitleUtil.getTitleByCode(
                                                UITitleCode.HEADER_PASSWORD),
                                            controller: controller
                                                .passwordTeController),
                                      )
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: NeutronDropDownCustom(
                                          borderColors: ColorManagement.white,
                                          label: UITitleUtil.getTitleByCode(
                                              UITitleCode.GENERATE_OPTIONS),
                                          childWidget: NeutronDropDown(
                                            isPadding: false,
                                            items:
                                                ElectronicInvoiceGenerateOption
                                                        .options()
                                                    .map((e) => UITitleUtil
                                                        .getTitleByCode(e))
                                                    .toList(),
                                            value: UITitleUtil.getTitleByCode(
                                                controller.generateOption),
                                            onChanged: (String value) =>
                                                controller
                                                    .setSoftGenerateOption(
                                                        value),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: NeutronDropDownCustom(
                                          borderColors: ColorManagement.white,
                                          label: UITitleUtil.getTitleByCode(
                                              UITitleCode.SERVICE_OPTIONS),
                                          childWidget: NeutronDropDown(
                                            isPadding: false,
                                            items: [
                                              UITitleCode.NO,
                                              ...ElectronicInvoiceGenerateOption
                                                  .options()
                                            ]
                                                .map((e) =>
                                                    UITitleUtil.getTitleByCode(
                                                        e))
                                                .toList(),
                                            value: UITitleUtil.getTitleByCode(
                                                controller.serviceOption),
                                            onChanged: (String value) =>
                                                controller
                                                    .setServiceOption(value),
                                          )),
                                    ),
                                  ],
                                )
                              : const SizedBox()),
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          String result = await controller.save();
                          if (result != MessageCodeUtil.SUCCESS) {
                            MaterialUtil.showAlert(context, result);
                          } else {
                            Navigator.pop(context);
                            MaterialUtil.showSnackBar(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS));
                          }
                        },
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
