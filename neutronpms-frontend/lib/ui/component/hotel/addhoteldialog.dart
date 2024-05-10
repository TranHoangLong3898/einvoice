import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/addhotelcontroller.dart';
import 'package:ihotel/controller/selecthotelcontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/hotel.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../handler/filehandler.dart';

class AddHotelDialog extends StatefulWidget {
  final Hotel? hotel;
  const AddHotelDialog({
    this.hotel,
    Key? key,
  }) : super(key: key);

  @override
  State<AddHotelDialog> createState() => _AddHotelDialog();
}

class _AddHotelDialog extends State<AddHotelDialog> {
  AddHotelController? controller;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller ??= AddHotelController(hotel: widget.hotel);
    super.initState();
  }

  @override
  void dispose() {
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
            child: ChangeNotifierProvider.value(
              value: controller,
              child: Consumer<AddHotelController>(
                builder: (_, controller, __) {
                  if (controller.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ));
                  }
                  return Stack(children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 60),
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
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.HEADER_HOTEL_INFORMATION)),
                            ),
                            // Name
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
                                  isDecor: true,
                                  controller: controller.teName,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil.INPUT_NAME);
                                    }
                                    if (value.trim().isEmpty) {
                                      return MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .NAME_CAN_NOT_BE_BLANK);
                                    }
                                    return null;
                                  }),
                            ),
                            //phone + email on web
                            if (!isMobile)
                              Row(
                                children: [
                                  //phone
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
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_PHONE),
                                            isPadding: false),
                                      ),
                                      Container(
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
                                        child: NeutronTextFormField(
                                          isDecor: true,
                                          controller: controller.tePhone,
                                          isPhoneNumber: true,
                                          validator: (value) =>
                                              StringValidator.validatePhone(
                                                  value!),
                                        ),
                                      )
                                    ],
                                  )),
                                  //email
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
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_EMAIL),
                                            isPadding: false),
                                      ),
                                      Container(
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
                                        child: NeutronTextFormField(
                                          isDecor: true,
                                          controller: controller.teEmail,
                                          validator: (value) => StringValidator
                                              .validateRequiredEmail(value),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            // phone on Mobile
                            if (isMobile)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PHONE),
                                    isPadding: false),
                              ),
                            if (isMobile)
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
                                  isDecor: true,
                                  controller: controller.tePhone,
                                  isPhoneNumber: true,
                                  validator: (value) =>
                                      StringValidator.validatePhone(value!),
                                ),
                              ),
                            //email on mobile
                            if (isMobile)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_EMAIL),
                                    isPadding: false),
                              ),
                            if (isMobile)
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
                                  isDecor: true,
                                  controller: controller.teEmail,
                                  validator: (value) =>
                                      StringValidator.validateRequiredEmail(
                                          value),
                                ),
                              ),
                            // Country on Mobile
                            if (isMobile)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_COUNTRY),
                                    isPadding: false),
                              ),
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
                                  child: Autocomplete<String>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text.isEmpty) {
                                        return controller.listCountry;
                                      }

                                      return controller.listCountry
                                          .where((String option) {
                                        return option.toLowerCase().startsWith(
                                            textEditingValue.text
                                                .toLowerCase());
                                      });
                                    },
                                    onSelected: (String selection) {
                                      if (kIsWeb &&
                                          (defaultTargetPlatform ==
                                                  TargetPlatform.iOS ||
                                              defaultTargetPlatform ==
                                                  TargetPlatform.android)) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      }
                                      controller.setCountry(selection);
                                    },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          color: ColorManagement.mainBackground,
                                          elevation: 5,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxHeight: 200,
                                                maxWidth: kMobileWidth -
                                                    SizeManagement
                                                            .cardOutsideHorizontalPadding *
                                                        2),
                                            child: ListView.builder(
                                              padding: const EdgeInsets.all(0),
                                              itemBuilder: (context, index) =>
                                                  ListTile(
                                                onTap: () => onSelected(
                                                    options.elementAt(index)),
                                                title: Text(
                                                  options.elementAt(index),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 0),
                                                minVerticalPadding: 0,
                                                hoverColor: Colors.white38,
                                              ),
                                              itemCount: options.length,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    fieldViewBuilder: (context,
                                            textEditingController,
                                            focusNode,
                                            onEditingComplete) =>
                                        NeutronTextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onEditingComplete: onEditingComplete,
                                      isDecor: true,
                                      onChanged: (String country) {
                                        controller.setCountry(country);
                                      },
                                    ),
                                    initialValue: TextEditingValue(
                                        text: controller.teCountry),
                                  )),
                            //city on mobile
                            if (isMobile)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CITY),
                                    isPadding: false),
                              ),
                            if (isMobile)
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
                                child: Autocomplete<String>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return controller.listCity;
                                    }
                                    return controller.listCity
                                        .where((String option) {
                                      return option.toLowerCase().startsWith(
                                          textEditingValue.text.toLowerCase());
                                    });
                                  },
                                  onSelected: (String selection) {
                                    if (kIsWeb &&
                                        (defaultTargetPlatform ==
                                                TargetPlatform.iOS ||
                                            defaultTargetPlatform ==
                                                TargetPlatform.android)) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    }
                                    controller.setCity(selection,
                                        isSelectAction: true);
                                  },
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        color: ColorManagement.mainBackground,
                                        elevation: 5,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxHeight: 200,
                                              maxWidth: kMobileWidth -
                                                  SizeManagement
                                                          .cardOutsideHorizontalPadding *
                                                      2),
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(0),
                                            itemBuilder: (context, index) =>
                                                ListTile(
                                              onTap: () => onSelected(
                                                  options.elementAt(index)),
                                              title: Text(
                                                options.elementAt(index),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 0),
                                              minVerticalPadding: 0,
                                              hoverColor: Colors.white38,
                                            ),
                                            itemCount: options.length,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  fieldViewBuilder: (context,
                                      textEditingController,
                                      focusNode,
                                      onEditingComplete) {
                                    if (controller.listCity.isEmpty) {
                                      textEditingController.clear();
                                    }
                                    return NeutronTextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onEditingComplete: onEditingComplete,
                                      isDecor: true,
                                      readOnly: controller.listCity.isEmpty,
                                      backgroundColor:
                                          controller.listCity.isEmpty
                                              ? Colors.grey.shade800
                                              : ColorManagement.mainBackground,
                                      onChanged: (String city) {
                                        controller.setCity(city);
                                      },
                                    );
                                  },
                                  initialValue:
                                      TextEditingValue(text: controller.teCity),
                                ),
                              ),
                            // country + city on web
                            if (!isMobile)
                              Row(
                                children: [
                                  //country
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
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_COUNTRY),
                                            isPadding: false),
                                      ),
                                      Container(
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
                                        child: Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue
                                              textEditingValue) {
                                            if (textEditingValue.text.isEmpty) {
                                              return controller.listCountry;
                                            }

                                            return controller.listCountry
                                                .where((String option) {
                                              return option
                                                  .toLowerCase()
                                                  .startsWith(textEditingValue
                                                      .text
                                                      .toLowerCase());
                                            });
                                          },
                                          onSelected: (String selection) {
                                            if (kIsWeb &&
                                                (defaultTargetPlatform ==
                                                        TargetPlatform.iOS ||
                                                    defaultTargetPlatform ==
                                                        TargetPlatform
                                                            .android)) {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            }
                                            controller.setCountry(selection);
                                          },
                                          optionsViewBuilder:
                                              (context, onSelected, options) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                color: ColorManagement
                                                    .mainBackground,
                                                elevation: 5,
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                      maxHeight: 200,
                                                      maxWidth: kMobileWidth -
                                                          SizeManagement
                                                                  .cardOutsideHorizontalPadding *
                                                              2),
                                                  child: ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    itemBuilder:
                                                        (context, index) =>
                                                            ListTile(
                                                      onTap: () => onSelected(
                                                          options.elementAt(
                                                              index)),
                                                      title: Text(
                                                        options
                                                            .elementAt(index),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 0),
                                                      minVerticalPadding: 0,
                                                      hoverColor:
                                                          Colors.white38,
                                                    ),
                                                    itemCount: options.length,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          fieldViewBuilder: (context,
                                              textEditingController,
                                              focusNode,
                                              onEditingComplete) {
                                            return NeutronTextFormField(
                                              controller: textEditingController,
                                              focusNode: focusNode,
                                              onEditingComplete:
                                                  onEditingComplete,
                                              isDecor: true,
                                              onChanged: (String country) {
                                                controller.setCountry(country);
                                              },
                                            );
                                          },
                                          initialValue: TextEditingValue(
                                              text: controller.teCountry),
                                        ),
                                      )
                                    ],
                                  )),
                                  //city
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
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_CITY),
                                            isPadding: false),
                                      ),
                                      Container(
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
                                        child: Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue
                                              textEditingValue) {
                                            if (textEditingValue.text.isEmpty) {
                                              return controller.listCity;
                                            }
                                            return controller.listCity
                                                .where((String option) {
                                              return option
                                                  .toLowerCase()
                                                  .startsWith(textEditingValue
                                                      .text
                                                      .toLowerCase());
                                            });
                                          },
                                          onSelected: (String selection) {
                                            if (kIsWeb &&
                                                (defaultTargetPlatform ==
                                                        TargetPlatform.iOS ||
                                                    defaultTargetPlatform ==
                                                        TargetPlatform
                                                            .android)) {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            }
                                            controller.setCity(selection,
                                                isSelectAction: true);
                                          },
                                          optionsViewBuilder:
                                              (context, onSelected, options) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Material(
                                                color: ColorManagement
                                                    .mainBackground,
                                                elevation: 5,
                                                child: ConstrainedBox(
                                                  constraints: const BoxConstraints(
                                                      maxHeight: 200,
                                                      maxWidth: kMobileWidth -
                                                          SizeManagement
                                                                  .cardOutsideHorizontalPadding *
                                                              2),
                                                  child: ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    itemBuilder:
                                                        (context, index) =>
                                                            ListTile(
                                                      onTap: () => onSelected(
                                                          options.elementAt(
                                                              index)),
                                                      title: Text(
                                                        options
                                                            .elementAt(index),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 0),
                                                      minVerticalPadding: 0,
                                                      hoverColor:
                                                          Colors.white38,
                                                    ),
                                                    itemCount: options.length,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          fieldViewBuilder: (context,
                                              textEditingController,
                                              focusNode,
                                              onEditingComplete) {
                                            if (controller.listCity.isEmpty) {
                                              textEditingController.clear();
                                            }
                                            return NeutronTextFormField(
                                              controller: textEditingController,
                                              focusNode: focusNode,
                                              onEditingComplete:
                                                  onEditingComplete,
                                              isDecor: true,
                                              readOnly:
                                                  controller.listCity.isEmpty,
                                              backgroundColor:
                                                  controller.listCity.isEmpty
                                                      ? Colors.grey.shade800
                                                      : ColorManagement
                                                          .mainBackground,
                                              onChanged: (String city) {
                                                controller.setCity(city);
                                              },
                                            );
                                          },
                                          initialValue: TextEditingValue(
                                              text: controller.teCity),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            // Street
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                isRequired: true,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STREET),
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
                                  isDecor: true,
                                  controller: controller.teStreet,
                                  validator: (value) {
                                    return StringValidator.validateStreet(
                                        value);
                                  }),
                            ),
                            // Timezone And Currency
                            Container(
                              margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.rowSpacing,
                                  top: SizeManagement.topHeaderTextSpacing),
                              child: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode
                                          .TABLEHEADER_TIMEZONE_CURRENCY),
                                  isPadding: false),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                right:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                bottom: SizeManagement.rowSpacing,
                              ),
                              child: const Divider(
                                color: ColorManagement.lightColorText,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TIMEZONE),
                                  isPadding: false),
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
                                child: NeutronDropDownCustom(
                                  childWidget: NeutronDropDown(
                                    isPadding: false,
                                    value: controller.teTimezone,
                                    items: controller.listTimezone,
                                    onChanged: (value) =>
                                        controller.setTimezone(value),
                                  ),
                                )),
                            // Currency
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_CURRENCY),
                                  isPadding: false),
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
                              child: Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return controller.listCurrency;
                                  }
                                  return controller.listCurrency
                                      .where((String option) {
                                    return option.toLowerCase().startsWith(
                                        textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (String selection) {
                                  if (kIsWeb &&
                                      (defaultTargetPlatform ==
                                              TargetPlatform.iOS ||
                                          defaultTargetPlatform ==
                                              TargetPlatform.android)) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  }
                                  controller.setCurrency(selection,
                                      isSelectAction: true);
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: ColorManagement.mainBackground,
                                      elevation: 5,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: 200,
                                            maxWidth: isMobile
                                                ? kMobileWidth
                                                : kWidth -
                                                    SizeManagement
                                                            .cardOutsideHorizontalPadding *
                                                        2),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(0),
                                          itemBuilder: (context, index) =>
                                              ListTile(
                                            onTap: () => onSelected(
                                                options.elementAt(index)),
                                            title: Text(
                                              options.elementAt(index),
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 0),
                                            minVerticalPadding: 0,
                                            hoverColor: Colors.white38,
                                          ),
                                          itemCount: options.length,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                fieldViewBuilder: (context,
                                    textEditingController,
                                    focusNode,
                                    onEditingComplete) {
                                  return NeutronTextFormField(
                                    hint: MessageUtil.getMessageByCode(
                                        MessageCodeUtil.CHOOSE_CURRENCY),
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onEditingComplete: onEditingComplete,
                                    isDecor: true,
                                    onChanged: (String currency) {
                                      controller.setCurrency(currency);
                                    },
                                  );
                                },
                                initialValue: TextEditingValue(
                                    text: controller.teCurrency),
                              ),
                            ),
                            if (GeneralManager.hotel != null &&
                                GeneralManager.hotel!.isAdvPackage()) ...[
                              const SizedBox(height: 25),
                              NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_AUTOMATICALY_EXPORT_ITEMS),
                              ),
                              const Divider(
                                color: ColorManagement.lightColorText,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      value: '0',
                                      activeColor: ColorManagement.greenColor,
                                      groupValue: controller.autoExportItems,
                                      onChanged: controller.setAutoExportItems,
                                      title: NeutronTextContent(
                                          message: MessageUtil.getMessageByCode(
                                              MessageCodeUtil.TEXTALERT_NO)),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      contentPadding: EdgeInsets.zero,
                                      value: '2',
                                      activeColor: ColorManagement.greenColor,
                                      groupValue: controller.autoExportItems,
                                      onChanged: controller.setAutoExportItems,
                                      title: NeutronTextContent(
                                          message: MessageUtil.getMessageByCode(
                                              MessageCodeUtil
                                                  .TEXTALERT_ONLY_SELECTED_ITEMS)),
                                    ),
                                  ),
                                  if (!isMobile)
                                    Expanded(
                                      child: RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: '1',
                                        activeColor: ColorManagement.greenColor,
                                        groupValue: controller.autoExportItems,
                                        onChanged:
                                            controller.setAutoExportItems,
                                        title: NeutronTextContent(
                                            message:
                                                MessageUtil.getMessageByCode(
                                                    MessageCodeUtil
                                                        .TEXTALERT_ALL_ITEMS)),
                                      ),
                                    ),
                                ],
                              ),
                              if (isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile(
                                        contentPadding: EdgeInsets.zero,
                                        value: '1',
                                        activeColor: ColorManagement.greenColor,
                                        groupValue: controller.autoExportItems,
                                        onChanged:
                                            controller.setAutoExportItems,
                                        title: NeutronTextContent(
                                            message:
                                                MessageUtil.getMessageByCode(
                                                    MessageCodeUtil
                                                        .TEXTALERT_ALL_ITEMS)),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                            // Form Logo
                            Container(
                              margin: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  bottom: SizeManagement.rowSpacing,
                                  top: SizeManagement.topHeaderTextSpacing),
                              child: NeutronTextTitle(
                                  isRequired: true,
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_LOGO),
                                  isPadding: false),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                right:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                bottom: SizeManagement.rowSpacing,
                              ),
                              child: const Divider(
                                color: ColorManagement.lightColorText,
                              ),
                            ),
                            // Set image
                            Container(
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.white38,
                                        blurRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8),
                                    color: ColorManagement.lightMainBackground),
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: InkWell(
                                  child: Text(controller.message != ''
                                      ? controller.message
                                      : UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_CHOOSE_IMAGE)),
                                  onTap: () => pickImage(),
                                )),
                            if (controller.base64 != null)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    vertical: SizeManagement.rowSpacing),
                                width: 100,
                                height: 100,
                                child: Image.memory(controller.base64!),
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
                            List<HotelItem> invalidItem =
                                controller.checkDefaultWarehouseForItem();
                            if (invalidItem.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => InvalidItemsDialog(
                                  addHotelController: controller,
                                ),
                              );
                            } else {
                              final result = await controller.addHotel();
                              if (!mounted) {
                                return;
                              }
                              if (widget.hotel == null) {
                                if (result) {
                                  HotelPageController.nameQuery.text =
                                      controller.teName.text;
                                  Navigator.pop(context, result);
                                } else {
                                  MaterialUtil.showAlert(
                                      context, controller.errorLog);
                                }
                              } else {
                                if (result) {
                                  MaterialUtil.showSnackBar(
                                      context,
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS));
                                } else {
                                  MaterialUtil.showAlert(
                                      context, controller.errorLog);
                                }
                              }
                            }
                          }
                        },
                      ),
                    )
                  ]);
                },
              ),
            ),
          )),
    );
  }

  void pickImage() async {
    PlatformFile? pickedFile = await FileHandler.pickSingleImage(context);
    if (pickedFile == null) {
      return;
    }
    String result = controller!.setImageToHotel(pickedFile);
    if (mounted && result != MessageCodeUtil.SUCCESS) {
      MaterialUtil.showAlert(context, result);
    }
  }
}

class InvalidItemsDialog extends StatelessWidget {
  const InvalidItemsDialog({Key? key, required this.addHotelController})
      : super(key: key);
  final AddHotelController addHotelController;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: SizeManagement.topHeaderTextSpacing),
              child: NeutronTextTitle(
                fontSize: 16,
                message:
                    MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_ITEM),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardInsideHorizontalPadding,
                  vertical: SizeManagement.cardInsideVerticalPadding),
              child: NeutronTextContent(
                maxLines: 4,
                color: ColorManagement.redColor,
                message: MessageUtil.getMessageByCode(MessageCodeUtil
                    .TEXTALERT_ITEMS_HAVE_NOT_BEEN_SET_DEFAULT_WAREHOUSE_FOR_INGREDIENTS),
              ),
            ),
            const Divider(
              color: ColorManagement.white,
              indent: 5,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChangeNotifierProvider<AddHotelController>.value(
                  value: addHotelController,
                  child: Consumer<AddHotelController>(
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: ColorManagement.greenColor)),
                      builder: (_, controller, child) {
                        List<HotelItem> invalidItems =
                            controller.checkDefaultWarehouseForItem();
                        return controller.isLoadingInvalidItem
                            ? child!
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 150,
                                        childAspectRatio: 5,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10),
                                itemCount: invalidItems.length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    controller.showItemDialog(
                                        context, invalidItems[index]);
                                  },
                                  child: NeutronTextContent(
                                      message:
                                          '[ ${invalidItems[index].name} ]',
                                      tooltip: invalidItems[index].name),
                                ),
                              );
                      })),
            )),
          ],
        ),
      ),
    );
  }
}
