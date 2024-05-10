import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../controller/channelmanager/cmavaibilitycontroller.dart';
import '../../ui/controls/neutronbutton.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../controls/neutrondatetimepicker.dart';

class CMAvaibilityForm extends StatefulWidget {
  const CMAvaibilityForm({Key? key}) : super(key: key);

  @override
  State<CMAvaibilityForm> createState() => _CMAvaibilityFormState();
}

class _CMAvaibilityFormState extends State<CMAvaibilityForm> {
  final CMAvaibilityController cmAvaibilityController =
      CMAvaibilityController();
  late NeutronInputNumberController inputPriceController;
  late NeutronInputNumberController inputValueController;
  @override
  void initState() {
    inputPriceController =
        NeutronInputNumberController(cmAvaibilityController.priceController);
    inputValueController =
        NeutronInputNumberController(cmAvaibilityController.valueController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CMAvaibilityController>.value(
      value: cmAvaibilityController,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: Consumer<CMAvaibilityController>(builder: (_, controller, __) {
          if (controller.updating) {
            return const Center(
                child: CircularProgressIndicator(
              color: ColorManagement.greenColor,
            ));
          }
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 60),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      NeutronDropDown(
                          isPadding: false,
                          items: controller.roomTypeNames,
                          value: controller.selectedRoomType,
                          onChanged: (String value) async {
                            controller.changeSelectedRoomType(value);
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: NeutronTextTitle(
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_START_DATE),
                          )),
                          Expanded(
                              child: NeutronTextTitle(
                            isPadding: false,
                            message: DateUtil.dateToHLSString(
                                controller.startAdjust),
                          )),
                          Expanded(
                              child: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  tooltip: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_START_DATE),
                                  onPressed: () async {
                                    final DateTime now =
                                        Timestamp.now().toDate();

                                    final DateTime? picked =
                                        await showDatePicker(
                                            builder: (context, child) =>
                                                DateTimePickerDarkTheme
                                                    .buildDarkTheme(
                                                        context, child!),
                                            context: context,
                                            initialDate: controller.startAdjust,
                                            firstDate: now,
                                            lastDate: now.add(
                                                const Duration(days: 700)));
                                    if (picked != null &&
                                        picked.compareTo(
                                                controller.startAdjust) !=
                                            0) {
                                      controller.setStartAdjust(picked);
                                    }
                                  })),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: NeutronTextTitle(
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_END_DATE),
                          )),
                          Expanded(
                              child: NeutronTextTitle(
                            isPadding: false,
                            message:
                                DateUtil.dateToHLSString(controller.endAdjust),
                          )),
                          Expanded(
                            child: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_END_DATE),
                                onPressed: () async {
                                  final DateTime now = Timestamp.now().toDate();

                                  final DateTime? picked = await showDatePicker(
                                      builder: (context, child) =>
                                          DateTimePickerDarkTheme
                                              .buildDarkTheme(context, child!),
                                      context: context,
                                      initialDate: controller.endAdjust,
                                      firstDate: controller.startAdjust,
                                      lastDate:
                                          now.add(const Duration(days: 700)));
                                  if (picked != null &&
                                      picked.compareTo(controller.endAdjust) !=
                                          0) {
                                    controller.setEndAdjust(picked);
                                  }
                                }),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                checkColor: ColorManagement.greenColor,
                                value: controller.isMonday,
                                onChanged: (value) {
                                  controller.setMonDay(value);
                                },
                                title: const NeutronTextTitle(
                                  fontSize: 12,
                                  message: 'Mon',
                                  isPadding: false,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                checkColor: ColorManagement.greenColor,
                                value: controller.isTuesday,
                                onChanged: (value) {
                                  controller.setTuesday(value);
                                },
                                title: const NeutronTextTitle(
                                  fontSize: 12,
                                  message: 'Tue',
                                  isPadding: false,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                checkColor: ColorManagement.greenColor,
                                value: controller.isWednesday,
                                onChanged: (value) {
                                  controller.setWednesday(value);
                                },
                                title: const NeutronTextTitle(
                                  fontSize: 12,
                                  message: 'Wed',
                                  isPadding: false,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                  checkColor: ColorManagement.greenColor,
                                  value: controller.isThursday,
                                  onChanged: (value) {
                                    controller.setThursday(value);
                                  },
                                  title: const NeutronTextTitle(
                                    fontSize: 12,
                                    message: 'Thu',
                                    isPadding: false,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                  checkColor: ColorManagement.greenColor,
                                  value: controller.isFriday,
                                  onChanged: (value) {
                                    controller.setFriday(value);
                                  },
                                  title: const NeutronTextTitle(
                                    fontSize: 12,
                                    message: 'Fri',
                                    isPadding: false,
                                  )),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                  checkColor: ColorManagement.greenColor,
                                  value: controller.isSaturday,
                                  onChanged: (value) {
                                    controller.setSaturday(value);
                                  },
                                  title: const NeutronTextTitle(
                                    fontSize: 12,
                                    message: 'Sat',
                                    isPadding: false,
                                  )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: CheckboxListTile(
                          checkColor: ColorManagement.greenColor,
                          value: controller.isSunday,
                          onChanged: (value) {
                            controller.setSunday(value);
                          },
                          title: const NeutronTextTitle(
                            fontSize: 12,
                            message: 'Sun',
                            isPadding: false,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: SizeManagement.rowSpacing,
                                  bottom: SizeManagement.rowSpacing,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: inputValueController.buildWidget(
                                color: ColorManagement.lightMainBackground,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.AVAIBILITI_CHANNEL),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: SizeManagement.rowSpacing,
                                  bottom: SizeManagement.rowSpacing,
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: inputPriceController.buildWidget(
                                color: ColorManagement.lightMainBackground,
                                textAlign: TextAlign.right,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.RATE_CHANNEL),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    margin: const EdgeInsets.only(
                        bottom: SizeManagement.rowSpacing),
                    icon: Icons.save,
                    onPressed: () async {
                      final success = await controller.updateAvaibility();
                      if (!mounted) {
                        return;
                      }
                      if (success == MessageCodeUtil.SUCCESS) {
                        MaterialUtil.showSnackBar(
                            context,
                            MessageUtil.getMessageByCode(MessageCodeUtil
                                .CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_SUCCESS));
                      } else {
                        MaterialUtil.showAlert(
                            context, MessageUtil.getMessageByCode(success));
                      }
                    }),
              )
            ],
          );
        }),
      ),
    );
  }
}
