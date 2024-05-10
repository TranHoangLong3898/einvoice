import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/adminmanager/addpaymentpackagecontroller.dart';
import 'package:ihotel/modal/paymentpackageversion.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../controls/neutrondropdown.dart';

class AddPayementPackageDialog extends StatefulWidget {
  final PaymentPackageVersion? packageVersion;
  const AddPayementPackageDialog({super.key, this.packageVersion});

  @override
  State<AddPayementPackageDialog> createState() =>
      _AddPayementPackageDialogState();
}

class _AddPayementPackageDialogState extends State<AddPayementPackageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: kMobileWidth,
            height: kHeight / 2.2,
            child: ChangeNotifierProvider(
              create: (context) =>
                  AddPaymentPackageController(widget.packageVersion),
              child: Consumer<AddPaymentPackageController>(
                builder: (_, controller, __) => controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor))
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: SizeManagement
                                              .cardOutsideVerticalPadding,
                                          right: SizeManagement
                                              .cardInsideHorizontalPadding,
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextHeader(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_ADD_PAYMENT_PACKAGES))),
                                  const SizedBox(
                                    height: SizeManagement.topHeaderTextSpacing,
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: SizeManagement
                                              .cardOutsideVerticalPadding,
                                          right: SizeManagement
                                              .cardInsideHorizontalPadding,
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextFormField(
                                        controller: controller.teDesc,
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_DESCRIPTION_FULL),
                                        isDecor: true,
                                        backgroundColor:
                                            ColorManagement.lightMainBackground,
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: SizeManagement
                                              .cardOutsideVerticalPadding,
                                          right: SizeManagement
                                              .cardInsideHorizontalPadding,
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: controller.teStillInDebt
                                          .buildWidget(
                                              readOnly: widget.packageVersion ==
                                                      null
                                                  ? !controller.isStillInDebt
                                                  : !(widget.packageVersion!
                                                          .stillInDebt! >=
                                                      0),
                                              isDecor: true,
                                              color: ColorManagement
                                                  .lightMainBackground,
                                              label: "Số tiền thanh toán",
                                              suffix: Container(
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: ColorManagement
                                                        .greenColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)),
                                                child: IconButton(
                                                    onPressed: () {
                                                      controller
                                                          .setStillInDebt();
                                                    },
                                                    icon: Icon(
                                                      controller.isStillInDebt
                                                          ? Icons.edit
                                                          : Icons.lock,
                                                      size: 17,
                                                    )),
                                              ))),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          top: SizeManagement
                                              .cardOutsideVerticalPadding,
                                          right: SizeManagement
                                              .cardInsideHorizontalPadding,
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronDropDownCustom(
                                        backgroundColor:
                                            ColorManagement.lightMainBackground,
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_METHOD),
                                        childWidget: NeutronDropDown(
                                            isPadding: false,
                                            value: controller.selectMethod,
                                            onChanged: (String newType) {
                                              controller
                                                  .setPackageVersion(newType);
                                            },
                                            items: controller.listMedthod),
                                      )),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: NeutronBlurButton(
                              margin: 5,
                              icon: Icons.save,
                              onPressed: () async {
                                await controller
                                    .updatePackageVersion()
                                    .then((result) {
                                  if (result != MessageCodeUtil.SUCCESS) {
                                    MaterialUtil.showAlert(context,
                                        MessageUtil.getMessageByCode(result));
                                    return;
                                  }
                                  MaterialUtil.showSnackBar(context,
                                      MessageUtil.getMessageByCode(result));
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          )
                        ],
                      ),
              ),
            )));
  }
}
