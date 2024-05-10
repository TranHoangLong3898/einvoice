import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/addroomtypecontroller.dart';
import 'package:ihotel/modal/roomtype.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../manager/beds.dart';
import '../../../util/materialutil.dart';
import '../../controls/neutrontexttilte.dart';

class AddRoomTypeDialog extends StatefulWidget {
  const AddRoomTypeDialog({
    this.roomType,
    Key? key,
  }) : super(key: key);
  final RoomType? roomType;

  @override
  State<AddRoomTypeDialog> createState() => _AddRoomTypeDialogState();
}

class _AddRoomTypeDialogState extends State<AddRoomTypeDialog> {
  final formKey = GlobalKey<FormState>();
  AddRoomTypeController? controller;
  late NeutronInputNumberController numGuestControllers;
  late NeutronInputNumberController minPriceControllers;
  late NeutronInputNumberController priceControllers;
  @override
  void initState() {
    controller ??= AddRoomTypeController(widget.roomType);
    numGuestControllers = NeutronInputNumberController(controller!.teNumGuest);
    minPriceControllers = NeutronInputNumberController(controller!.teMinPrice);
    priceControllers = NeutronInputNumberController(controller!.tePrice);
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth;
    }

    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: Form(
              key: formKey,
              child: ChangeNotifierProvider<AddRoomTypeController>.value(
                value: controller!,
                child: Consumer<AddRoomTypeController>(
                  builder: (_, controller, __) {
                    if (controller.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ));
                    }
                    return Stack(children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 65),
                        child: SingleChildScrollView(
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
                                          UITitleCode.HEADER_CREATE_RO0M_TYPE)
                                      : UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_UPDATE_ROOM_TYPE),
                                ),
                              ),
                              // Id Roomtype
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ROOMTYPE_ID),
                                  isPadding: false,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                margin: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: NeutronTextFormField(
                                  readOnly: !controller.isAddFeature,
                                  isDecor: true,
                                  controller: controller.teId,
                                  validator: (value) {
                                    return StringValidator.validateRequiredId(
                                        value);
                                  },
                                ),
                              ),
                              // <<<<<<< HEAD
                              // Name roomType and number guest desktop ui
                              if (!isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                              isRequired: true,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NAME),
                                              isPadding: false),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeManagement
                                                          .borderRadius8),
                                              color: ColorManagement
                                                  .lightMainBackground),
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child: NeutronTextFormField(
                                            isDecor: true,
                                            controller: controller.teName,
                                            validator: (value) {
                                              return StringValidator
                                                  .validateRequiredName(value);
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                              isRequired: true,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_NUMBER_GUEST),
                                              isPadding: false),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeManagement
                                                          .borderRadius8),
                                              color: ColorManagement
                                                  .lightMainBackground),
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child:
                                              numGuestControllers.buildWidget(
                                            isDecor: true,
                                            validator: (String? value) {
                                              return NumberValidator
                                                  .validatePositiveNumberSmallerThan100(
                                                      numGuestControllers
                                                          .getRawString());
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              // Name roomType mobile ui
                              if (isMobile)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                    isPadding: false,
                                  ),
                                ),
                              // Name roomType mobile ui
                              if (isMobile)
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teName,
                                    validator: (value) {
                                      return StringValidator
                                          .validateRequiredName(value);
                                    },
                                  ),
                                ),
                              // Number guest  mobile ui
                              if (isMobile)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                      isRequired: true,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NUMBER_GUEST),
                                      isPadding: false),
                                ),
                              // Number guest  mobile ui
                              if (isMobile)
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: numGuestControllers.buildWidget(
                                    isDecor: true,
                                    validator: (String? value) {
                                      return NumberValidator
                                          .validatePositiveNumberSmallerThan100(
                                              numGuestControllers
                                                  .getRawString());
                                    },
                                  ),
                                ),
                              // Min price and price dekstop ui
                              if (!isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                              isRequired: true,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_MIN_PRICE),
                                              isPadding: false),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeManagement
                                                          .borderRadius8),
                                              color: ColorManagement
                                                  .lightMainBackground),
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child:
                                              minPriceControllers.buildWidget(
                                            isDouble: true,
                                            isDecor: true,
                                            validator: (String? value) {
                                              if (!NumberValidator
                                                  .validateNumber(
                                                      minPriceControllers
                                                          .getRawString())) {
                                                return MessageUtil
                                                    .getMessageByCode(
                                                        MessageCodeUtil
                                                            .INPUT_PRICE);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              vertical:
                                                  SizeManagement.rowSpacing),
                                          child: NeutronTextTitle(
                                              isRequired: true,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PRICE),
                                              isPadding: false),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      SizeManagement
                                                          .borderRadius8),
                                              color: ColorManagement
                                                  .lightMainBackground),
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              right: SizeManagement
                                                  .cardOutsideHorizontalPadding,
                                              bottom: SizeManagement
                                                  .bottomFormFieldSpacing),
                                          child: priceControllers.buildWidget(
                                            isDouble: true,
                                            isDecor: true,
                                            validator: (String? value) {
                                              if (!NumberValidator
                                                  .validateNumber(
                                                      priceControllers
                                                          .getRawString())) {
                                                return MessageUtil
                                                    .getMessageByCode(
                                                        MessageCodeUtil
                                                            .INPUT_PRICE);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              // Min price mobile ui
                              if (isMobile)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  // <<<<<<< HEAD
                                  child: NeutronTextTitle(
                                      isRequired: true,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_MIN_PRICE),
                                      isPadding: false),
                                ),
                              // Min price mobile ui
                              if (isMobile)
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: minPriceControllers.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    validator: (String? value) {
                                      if (!NumberValidator.validateNumber(
                                          minPriceControllers.getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil.INPUT_PRICE);
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              // price mobile ui
                              if (isMobile)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                      isRequired: true,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE),
                                      isPadding: false),
                                ),
                              // price mobile ui
                              if (isMobile)
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: priceControllers.buildWidget(
                                    isDouble: true,
                                    isDecor: true,
                                    validator: (String? value) {
                                      if (!NumberValidator.validateNumber(
                                          priceControllers.getRawString())) {
                                        return MessageUtil.getMessageByCode(
                                            MessageCodeUtil.INPUT_NAME);
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              // Beds
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_BED),
                                    isPadding: false),
                              ),
                              // Beds Twin Triple
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isTwin,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.twin)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.twin)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller
                                              .setBedTwinForRoomType(checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isTriple,
                                        title: NeutronTextContent(
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.triple)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller.setBedTripleForRoomType(
                                              checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Beds quad double
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isQuad,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.quad)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.quad)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller
                                              .setBedQuadForRoomType(checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isDouble,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.double)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.double)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller.setBedDoubleForRoomType(
                                              checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Beds King Single
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isKing,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.king)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.king)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller
                                              .setBedKingForRoomType(checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isSingle,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.single)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.single)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller.setBedSingleForRoomType(
                                              checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Beds Queen Other
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isQueen,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.queen)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.queen)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller.setBedQueenForRoomType(
                                              checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground),
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: CheckboxListTile(
                                        value: controller.isOther,
                                        title: NeutronTextContent(
                                          tooltip: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.other)
                                              .value,
                                          message: controller.beds.entries
                                              .firstWhere((element) =>
                                                  element.key == Beds.other)
                                              .value,
                                        ),
                                        onChanged: (checkbox) {
                                          if (kIsWeb &&
                                              (defaultTargetPlatform ==
                                                      TargetPlatform.iOS ||
                                                  defaultTargetPlatform ==
                                                      TargetPlatform.android)) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          }
                                          controller.setBedOtherForRoomType(
                                              checkbox!);
                                        },
                                        activeColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  ),
                                ],
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
                              final result = await controller.addRoomType();
                              if (!mounted) {
                                return;
                              }
                              if (result == '') {
                                Navigator.pop(context, '');
                              } else {
                                MaterialUtil.showAlert(context, result);
                              }
                            }
                          },
                        ),
                      )
                    ]);
                  },
                ),
              ),
            )));
  }
}
