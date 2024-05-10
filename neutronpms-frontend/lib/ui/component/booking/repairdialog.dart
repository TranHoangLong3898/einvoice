import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/repaircontroller.dart';
import '../../../manager/generalmanager.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class RepairDialog extends StatefulWidget {
  final Booking? booking;

  const RepairDialog({
    Key? key,
    this.booking,
  }) : super(key: key);
  @override
  State<RepairDialog> createState() => _RepairDialogState();
}

class _RepairDialogState extends State<RepairDialog> {
  RepairController? controller;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller ??= RepairController(widget.booking!);
    super.initState();
  }

  @override
  void dispose() {
    controller?.disposeAllTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = 410;
    }
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: width,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: ChangeNotifierProvider.value(
              value: controller,
              child: Consumer<RepairController>(builder: (_, controller, __) {
                if (controller.updating) {
                  return Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxHeight: kMobileWidth),
                    child: const CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //header
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      child: NeutronTextHeader(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.HEADER_REPAIR_INFORMATION),
                      ),
                    ),
                    //description
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8),
                          color: ColorManagement.lightMainBackground),
                      margin: const EdgeInsets.only(
                          left: SizeManagement.cardOutsideHorizontalPadding,
                          right: SizeManagement.cardOutsideHorizontalPadding,
                          bottom: SizeManagement.bottomFormFieldSpacing),
                      child: NeutronTextFormField(
                          paddingVertical: 16,
                          isDecor: true,
                          controller: controller.teDesc,
                          validator: (value) => value!.isEmpty
                              ? MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INPUT_DESCRIPTION)
                              : null,
                          maxLine: 3,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_DESCRIPTION)),
                    ),
                    //in + out on web version
                    !isMobile
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  Expanded(
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_IN),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  Expanded(
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_OUT),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                ],
                              ),
                              const SizedBox(height: SizeManagement.rowSpacing),
                              Row(
                                children: [
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  Expanded(
                                    child: NeutronDateTimePickerBorder(
                                      onPressed: (DateTime? picked) {
                                        if (picked != null) {
                                          controller.setInDate(picked);
                                        }
                                      },
                                      initialDate: controller.inDate,
                                      firstDate: controller.getFirstDate(),
                                      lastDate: controller.getLastDate(),
                                      isEditDateTime:
                                          controller.booking.isInDateEditable(),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  Expanded(
                                    child: NeutronDateTimePickerBorder(
                                      onPressed: (DateTime? picked) {
                                        if (picked != null) {
                                          controller.setOutDate(picked);
                                        }
                                      },
                                      initialDate: controller.outDate,
                                      firstDate: controller.getFirstDate(),
                                      lastDate: controller.getLastDate(),
                                      isEditDateTime: controller.booking
                                          .isOutDateEditable(),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      SizeManagement.bottomFormFieldSpacing),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronTextTitle(
                                  isPadding: false,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_IN),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronDateTimePickerBorder(
                                  onPressed: (DateTime? picked) {
                                    if (picked != null) {
                                      controller.setInDate(picked);
                                    }
                                  },
                                  initialDate: controller.inDate,
                                  firstDate: controller.getFirstDate(),
                                  lastDate: controller.getLastDate(),
                                  isEditDateTime:
                                      controller.booking.isInDateEditable(),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronTextTitle(
                                  isPadding: false,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_OUT),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronDateTimePickerBorder(
                                  onPressed: (DateTime? picked) {
                                    if (picked != null) {
                                      controller.setOutDate(picked);
                                    }
                                  },
                                  initialDate: controller.outDate,
                                  firstDate: controller.inDate
                                      .add(const Duration(days: 1)),
                                  lastDate: controller.inDate.add(Duration(
                                      days: GeneralManager.maxLengthStay)),
                                  isEditDateTime:
                                      controller.booking.isOutDateEditable(),
                                ),
                              ),
                            ],
                          ),
                    NeutronButton(
                      icon: widget.booking!.isEmpty! ? Icons.add : Icons.save,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final result = await controller.updateRepair();
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
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
