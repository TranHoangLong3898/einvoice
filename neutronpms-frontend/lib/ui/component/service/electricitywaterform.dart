import 'package:flutter/material.dart';
import 'package:ihotel/controller/electricitywatercontroller.dart';
import 'package:ihotel/modal/service/service.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class ElectricityWaterForm extends StatefulWidget {
  final Booking? booking;
  final Service? service;
  final bool? isDisable;
  final bool isElectricity;

  const ElectricityWaterForm(
      {Key? key,
      this.booking,
      this.isDisable = false,
      this.isElectricity = true,
      this.service})
      : super(key: key);
  @override
  State<ElectricityWaterForm> createState() => _ElectricityWaterFormState();
}

class _ElectricityWaterFormState extends State<ElectricityWaterForm> {
  late ElectricityWaterController extraHourController;
  late NeutronInputNumberController teFirstElectricityORWater,
      teLastElectricityORWater,
      teWaterElectricityORPricer;
  late bool isDisable;
  @override
  void initState() {
    extraHourController = ElectricityWaterController(
        widget.booking!, widget.isElectricity, widget.service);
    isDisable =
        widget.isDisable ?? widget.booking!.status == BookingStatus.checkout;
    teFirstElectricityORWater = NeutronInputNumberController(
        extraHourController.teFirstElectricityORWater);
    teLastElectricityORWater = NeutronInputNumberController(
        extraHourController.teLastElectricityORWater);
    teWaterElectricityORPricer = NeutronInputNumberController(
        extraHourController.teElectricityWaterORPricer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.lightMainBackground,
      width: kMobileWidth,
      child: ChangeNotifierProvider.value(
        value: extraHourController,
        child: Consumer<ElectricityWaterController>(
          builder: (_, controller, __) => controller.saving
              ? Container(
                  constraints: const BoxConstraints(maxHeight: kMobileWidth),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      child: NeutronTextHeader(
                        message: UITitleUtil.getTitleByCode(widget.isElectricity
                            ? UITitleCode.TABLEHEADER_ELECTRICITY
                            : UITitleCode.TABLEHEADER_WATER),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronDateTimePickerBorder(
                        isEditDateTime: true,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATED_TIME),
                        initialDate: controller.createdDate,
                        firstDate: controller.createdDate,
                        lastDate: controller.createdDate
                            .add(const Duration(days: 365)),
                        onPressed: (date) {
                          controller.setCreateDate(date);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SizeManagement.cardInsideVerticalPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INITIAL)),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_START_DATE)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: teFirstElectricityORWater.buildWidget(
                              readOnly: isDisable,
                              isDecor: true,
                              onChanged: (p0) {
                                controller.changeElectricityOrWater();
                              },
                            ),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                            child: NeutronDateTimePickerBorder(
                              isEditDateTime: true,
                              initialDate: controller.firstDate,
                              firstDate: controller.firstDate
                                  .subtract(const Duration(days: 365)),
                              lastDate: controller.firstDate
                                  .add(const Duration(days: 365)),
                              onPressed: (date) {
                                controller.setFirstDate(date);
                              },
                            ),
                          )
                        ],
                      ),
                    ),

                    ///Last
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SizeManagement.cardInsideVerticalPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_FINAL)),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_END_DATE)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: teLastElectricityORWater.buildWidget(
                              readOnly: isDisable,
                              isDecor: true,
                              onChanged: (String newValue) {
                                controller.changeElectricityOrWater();
                              },
                            ),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                            child: NeutronDateTimePickerBorder(
                              isEditDateTime: true,
                              initialDate: controller.lastDate,
                              firstDate: controller.lastDate
                                  .subtract(const Duration(days: 365)),
                              lastDate: controller.lastDate
                                  .add(const Duration(days: 365)),
                              onPressed: (date) {
                                controller.setLastDate(date);
                              },
                            ),
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SizeManagement.cardInsideVerticalPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PRICE)),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TOTAL)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: teWaterElectricityORPricer.buildWidget(
                              readOnly: isDisable,
                              isDecor: true,
                              onChanged: (String newValue) {
                                controller.changeElectricityOrWater();
                              },
                            ),
                          ),
                          const SizedBox(
                              width: SizeManagement.cardInsideVerticalPadding),
                          Expanded(
                              child: NeutronTextFormField(
                            controller: TextEditingController(
                                text: NumberUtil.numberFormat.format(
                                    controller.totalElectricityOrWater)),
                            isDecor: true,
                            readOnly: true,
                          ))
                        ],
                      ),
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    if (!isDisable)
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          final result =
                              await controller.saveElectricityWater();
                          if (!mounted) {
                            return;
                          }
                          if (result ==
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.SUCCESS)) {
                            MaterialUtil.showSnackBar(context, result);
                            Navigator.pop(context);
                          } else {
                            MaterialUtil.showAlert(context, result);
                          }
                        },
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
