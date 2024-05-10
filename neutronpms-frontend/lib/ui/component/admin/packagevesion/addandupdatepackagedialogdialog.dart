import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/adminmanager/addandupdatepackagecontroller.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class AddAndUpdatePackageVersionDialog extends StatefulWidget {
  final Map<String, dynamic>? dataPackage;
  final String? id;
  const AddAndUpdatePackageVersionDialog(
      {super.key, this.dataPackage, this.id});

  @override
  State<AddAndUpdatePackageVersionDialog> createState() =>
      _AddAndUpdatePackageVersionDialogState();
}

class _AddAndUpdatePackageVersionDialogState
    extends State<AddAndUpdatePackageVersionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: kMobileWidth,
            height: kHeight / 1.5,
            child: ChangeNotifierProvider(
              create: (context) =>
                  AddAndUpdatePackageController(widget.dataPackage, widget.id),
              child: Consumer<AddAndUpdatePackageController>(
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
                                          message: widget.id != null
                                              ? UITitleUtil.getTitleByCode(
                                                  UITitleCode
                                                      .TABLEHEADER_UPDATE_PACKAGES_VERSION)
                                              : UITitleUtil.getTitleByCode(
                                                  UITitleCode
                                                      .TABLEHEADER_ADD_PACKAGES_VERSION))),
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
                                          readOnly: widget.id != null,
                                          controller: controller.teID,
                                          label: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_ID),
                                          backgroundColor: ColorManagement
                                              .lightMainBackground,
                                          isDecor: true)),
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
                                      child: controller.tePrice!.buildWidget(
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_RATEPLAN),
                                        isDecor: true,
                                        color:
                                            ColorManagement.lightMainBackground,
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          top: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Expanded(
                                              child: NeutronTextContent(
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_PACKAGE))),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 0,
                                                  groupValue:
                                                      controller.packageVersion,
                                                  activeColor: ColorManagement
                                                      .greenColor,
                                                  onChanged: (value) {
                                                    controller
                                                        .setPackageVersion(
                                                            value ?? 0);
                                                  },
                                                ),
                                                const NeutronTextContent(
                                                    message: "1 Tháng")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Radio(
                                                  value: 1,
                                                  groupValue:
                                                      controller.packageVersion,
                                                  activeColor: ColorManagement
                                                      .greenColor,
                                                  onChanged: (value) {
                                                    controller
                                                        .setPackageVersion(
                                                            value ?? 1);
                                                  },
                                                ),
                                                const NeutronTextContent(
                                                    message: "1 Năm")
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          top: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronDateTimePickerBorder(
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_START_DATE),
                                        initialDate: controller.startDate,
                                        firstDate: controller.now,
                                        lastDate: controller.startDate!
                                            .add(const Duration(days: 365)),
                                        isEditDateTime: widget.id == null,
                                        onPressed: (DateTime? picked) {
                                          if (picked == null) return;
                                          controller.setStart(picked);
                                        },
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          top: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronDateTimePickerBorder(
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_END_DATE),
                                        initialDate: controller.endDate,
                                        firstDate: controller.startDate!
                                            .subtract(const Duration(days: 1)),
                                        lastDate: controller.endDate!
                                            .add(const Duration(days: 365)),
                                        isEditDateTime: true,
                                        onPressed: (DateTime? picked) {
                                          if (picked == null) return;
                                          controller.setEnd(picked);
                                        },
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
