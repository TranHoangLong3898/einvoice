import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/hotelservice/roomextrahotelservicecontroller.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:provider/provider.dart';

class RoomExtraHotelServiceDialog extends StatefulWidget {
  const RoomExtraHotelServiceDialog({Key? key}) : super(key: key);

  @override
  State<RoomExtraHotelServiceDialog> createState() =>
      _RoomExtraHotelServiceState();
}

class _RoomExtraHotelServiceState extends State<RoomExtraHotelServiceDialog> {
  late RoomExtraHotelServiceController controller;
  late NeutronInputNumberController adultPriceController, childPriceController;
  late ConfigurationManagement management;

  @override
  void initState() {
    management = ConfigurationManagement();
    controller = RoomExtraHotelServiceController(management);
    adultPriceController =
        NeutronInputNumberController(controller.teAdultPriceController);
    childPriceController =
        NeutronInputNumberController(controller.teChildPriceController);
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        ChangeNotifierProvider.value(value: management),
      ],
      child:
          Consumer2<RoomExtraHotelServiceController, ConfigurationManagement>(
              builder: (_, controller, configurationManagement, __) {
        if (controller.isInProgress) {
          return const Center(
            widthFactor: 50,
            heightFactor: 50,
            child: CircularProgressIndicator(color: ColorManagement.greenColor),
          );
        }
        if (configurationManagement.roomExtra!.childPrice !=
                num.tryParse(controller.oldChildPrice) ||
            configurationManagement.roomExtra!.adultPrice !=
                num.tryParse(controller.oldAdultPrice)) {
          controller.oldAdultPrice =
              configurationManagement.roomExtra!.adultPrice.toString();
          controller.oldChildPrice =
              configurationManagement.roomExtra!.childPrice.toString();
          controller.teChildPriceController.text = NumberUtil.numberFormat
              .format(num.parse(controller.oldChildPrice));
          controller.teAdultPriceController.text = NumberUtil.numberFormat
              .format(num.parse(controller.oldAdultPrice));
        }
        return Stack(children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: controller.isUpdatablePrice
                    ? 65
                    : SizeManagement.cardOutsideVerticalPadding),
            child: Container(
              margin: const EdgeInsets.only(
                  top: SizeManagement.cardOutsideVerticalPadding,
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding),
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //adult
                    Container(
                      padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding,
                      ),
                      height: SizeManagement.cardHeight,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: ColorManagement.mainBackground,
                                  width: 1))),
                      child: Row(
                        children: [
                          Expanded(
                              child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ADULT_PRICE),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: adultPriceController.buildWidget(
                              isDecor: false,
                              isDouble: true,
                              textColor: ColorManagement.positiveText,
                              textAlign: TextAlign.end,
                              color: ColorManagement.lightMainBackground,
                              validator: (String? value) {
                                if (value == null ||
                                    value == '' ||
                                    num.parse(adultPriceController
                                            .getRawString()) <
                                        0) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.PRICE_MUST_BE_NUMBER);
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                if (adultPriceController.getRawString() !=
                                    configurationManagement
                                        .roomExtra!.adultPrice
                                        .toString()) {
                                  controller.setUpdateStatus(true);
                                } else {
                                  controller.setUpdateStatus(false);
                                }
                              },
                            ),
                          )),
                          const SizedBox(width: 20)
                        ],
                      ),
                    ),
                    //child
                    Container(
                      padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding,
                      ),
                      height: SizeManagement.cardHeight,
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: ColorManagement.mainBackground,
                                  width: 1))),
                      child: Row(
                        children: [
                          Expanded(
                              child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CHILD_PRICE),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: childPriceController.buildWidget(
                              isDecor: false,
                              isDouble: true,
                              textColor: ColorManagement.positiveText,
                              textAlign: TextAlign.end,
                              color: ColorManagement.lightMainBackground,
                              validator: (String? value) {
                                if (value == null ||
                                    value == '' ||
                                    num.parse(childPriceController
                                            .getRawString()) <
                                        0) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.PRICE_MUST_BE_NUMBER);
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                if (childPriceController.getRawString() !=
                                    configurationManagement
                                        .roomExtra!.childPrice
                                        .toString()) {
                                  controller.setUpdateStatus(true);
                                } else {
                                  controller.setUpdateStatus(false);
                                }
                              },
                            ),
                          )),
                          const SizedBox(width: 20)
                        ],
                      ),
                    ),
                    //early-check-in
                    ExpansionTile(
                      collapsedIconColor: ColorManagement.mainColorText,
                      iconColor: ColorManagement.mainColorText,
                      onExpansionChanged: (value) {
                        controller.changeEditButtonEarlyCheckinStatus(value);
                      },
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      title: Row(
                        children: [
                          Expanded(
                            child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_EARLY_CHECKIN),
                            ),
                          ),
                          if (controller.isShowEditButtonEarlyCheckin)
                            IconButton(
                                color: ColorManagement.greenColor,
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  controller.isAddEarlyCheckIn = true;
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AddRatioExtraHourDialog(controller));
                                })
                        ],
                      ),
                      children: _buildDetail(configurationManagement, true),
                    ),
                    const Divider(
                        color: ColorManagement.mainBackground, height: 1),
                    //late-check-out
                    ExpansionTile(
                      collapsedIconColor: ColorManagement.mainColorText,
                      iconColor: ColorManagement.mainColorText,
                      onExpansionChanged: (value) =>
                          controller.changeEditButtonLateCheckoutStatus(value),
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      title: Row(
                        children: [
                          Expanded(
                            child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_LATE_CHECKOUT),
                            ),
                          ),
                          if (controller.isShowEditButtonLateCheckout)
                            IconButton(
                                color: ColorManagement.greenColor,
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  controller.isAddEarlyCheckIn = false;
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AddRatioExtraHourDialog(controller));
                                })
                        ],
                      ),
                      children: _buildDetail(configurationManagement, false),
                    )
                  ],
                ),
              ),
            ),
          ),
          // //edit-button
          if (controller.isUpdatablePrice)
            Align(
              alignment: Alignment.bottomCenter,
              child: NeutronButton(
                icon: Icons.save,
                onPressed: () async {
                  String result =
                      await controller.updatePrice().then((value) => value);
                  if (mounted) {
                    MaterialUtil.showResult(context, result);
                  }
                },
              ),
            )
        ]);
      }),
    );
  }

  List<Widget> _buildDetail(
      ConfigurationManagement management, bool isEarlyCheckin) {
    SplayTreeMap map = isEarlyCheckin
        ? management.roomExtra!.earlyCheckIn!
        : management.roomExtra!.lateCheckOut!;
    return [
      //title
      Container(
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding * 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: NeutronTextTitle(
                  fontSize: 13,
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RULE),
                )),
            Expanded(
                child: Center(
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PERCENT),
              ),
            )),
            //size of delete-button + padding right
            const SizedBox(width: 40),
          ],
        ),
      ),
      ...map.keys
          .map((key) => Container(
                constraints: const BoxConstraints(
                  maxHeight: 40,
                  minHeight: 40,
                ),
                margin: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardInsideHorizontalPadding * 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                    border: Border(
                        top:
                            BorderSide(color: ColorManagement.mainBackground))),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: NeutronTextContent(
                          message: controller.getDesc(key, isEarlyCheckin),
                        )),
                    Expanded(
                        child: Center(
                      child: NeutronTextContent(
                        message: '${map[key] * 100}%',
                      ),
                    )),
                    IconButton(
                        constraints:
                            const BoxConstraints(minWidth: 40, maxWidth: 40),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 8),
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_DELETE),
                        onPressed: () async {
                          bool? confirmRemove;
                          await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CONFIRM_DELETE))
                              .then((value) => confirmRemove = value);
                          if (confirmRemove == null || !confirmRemove!) {
                            return;
                          }
                          String result = await controller
                              .removeExtraHour(key, isEarlyCheckin)
                              .then((value) => value);
                          if (mounted) {
                            MaterialUtil.showResult(context, result);
                          }
                        },
                        icon: const Icon(Icons.delete))
                  ],
                ),
              ))
          .toList(),
      Container(
        constraints: const BoxConstraints(
          maxHeight: 40,
          minHeight: 40,
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding * 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(color: ColorManagement.mainBackground))),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: NeutronTextContent(
                  message: controller.getDesc(null, isEarlyCheckin),
                )),
            const Expanded(
                child: Center(
              child: NeutronTextContent(
                message: '100%',
              ),
            )),
            const SizedBox(width: 40)
          ],
        ),
      )
    ];
  }
}

class AddRatioExtraHourDialog extends StatefulWidget {
  final RoomExtraHotelServiceController controller;

  const AddRatioExtraHourDialog(this.controller, {Key? key}) : super(key: key);

  @override
  State<AddRatioExtraHourDialog> createState() =>
      _AddRatioExtraHourDialogState();
}

class _AddRatioExtraHourDialogState extends State<AddRatioExtraHourDialog> {
  late NeutronInputNumberController teHourController, teRatioControler;

  @override
  void initState() {
    teHourController =
        NeutronInputNumberController(widget.controller.teHourController);
    teRatioControler =
        NeutronInputNumberController(widget.controller.teRatioController);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.teHourController.clear();
    widget.controller.teRatioController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: Form(
          key: formKey,
          child: ChangeNotifierProvider<RoomExtraHotelServiceController>.value(
            value: widget.controller,
            child: Consumer<RoomExtraHotelServiceController>(
              builder: (context, controller, child) => controller.isInProgress
                  ? const SizedBox(
                      height: kMobileWidth,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ColorManagement.greenColor,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          alignment: Alignment.center,
                          child: NeutronTextHeader(
                              message: controller.isAddEarlyCheckIn
                                  ? UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_EARLY_CHECK_IN)
                                  : UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_LATE_CHECK_OUT)),
                        ),
                        Row(
                          children: [
                            //hour
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                          .cardOutsideHorizontalPadding /
                                      2,
                                ),
                                child: teHourController.buildWidget(
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_HOUR),
                                  isDecor: true,
                                  isDouble: true,
                                  validator: (String? value) {
                                    if (value == null ||
                                        !NumberValidator.validatePositiveNumber(
                                            teHourController.getRawString())) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .INPUT_POSITIVE_NUMBER);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            //ratio
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  left: SizeManagement
                                          .cardOutsideHorizontalPadding /
                                      2,
                                ),
                                child: teRatioControler.buildWidget(
                                  suffixText: '%',
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_RATIO),
                                  isDecor: true,
                                  isDouble: true,
                                  validator: (String? value) {
                                    if (value == null ||
                                        value == '' ||
                                        num.parse(teRatioControler
                                                .getRawString()) <
                                            0) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .INPUT_POSITIVE_NUMBER);
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                            height: SizeManagement.bottomFormFieldSpacing),
                        NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              String result = await widget.controller
                                  .addExtraHour()
                                  .then((value) => value);

                              if (!mounted) {
                                return;
                              }
                              if (result ==
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.SUCCESS)) {
                                Navigator.pop(context);
                              }
                              MaterialUtil.showResult(context, result);
                            }
                          },
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
