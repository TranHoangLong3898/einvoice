// ignore_for_file: use_build_context_synchronously

// import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/updateusercontroller.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/hoteluser.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
// import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
// import 'package:ihotel/util/jobulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import '../../../../../constants.dart';
import '../../../../../util/designmanagement.dart';

// ignore: must_be_immutable
class UpdateUserDialog extends StatelessWidget {
  final bool? isSignUpUser;
  final bool? turnOffDialogAfterSuccess;
  final HotelUser? userHotel;
  final updateUserForm = GlobalKey<FormState>();
  UpdateUserController? controller;

  UpdateUserDialog(
      {Key? key,
      this.userHotel,
      this.isSignUpUser,
      this.turnOffDialogAfterSuccess})
      : super(key: key) {
    controller = UpdateUserController(userHotel, isSignUpUser);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        color: ColorManagement.lightMainBackground,
        width: kMobileWidth,
        height: kHeight,
        child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<UpdateUserController>(
              builder: (_, controller, __) {
                return controller.isInprogress
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ))
                    : Form(
                        key: updateUserForm,
                        child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 55),
                            child: SingleChildScrollView(
                              dragStartBehavior: DragStartBehavior.down,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  //title
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    alignment: Alignment.center,
                                    child: NeutronTextHeader(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_USER_INFORMATION),
                                    ),
                                  ),
                                  //email
                                  if (controller.isSignUpUser!)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isRequired: true,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_EMAIL),
                                      ),
                                    ),
                                  if (controller.isSignUpUser!)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        controller:
                                            controller.teEmailController,
                                        isDecor: true,
                                        validator: (String? email) {
                                          if (!isSignUpUser!) return null;
                                          return StringValidator
                                              .validateRequiredEmail(email);
                                        },
                                      ),
                                    ),
                                  //password
                                  if (controller.isSignUpUser!)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isRequired: true,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PASSWORD),
                                      ),
                                    ),
                                  if (controller.isSignUpUser!)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: TextFormField(
                                        obscureText: !controller.isShowPassword,
                                        style: const TextStyle(
                                          color: ColorManagement.lightColorText,
                                        ),
                                        validator: (String? password) {
                                          if (!isSignUpUser!) return null;
                                          return StringValidator
                                              .validatePassword(password);
                                        },
                                        controller:
                                            controller.tePasswordController,
                                        decoration: InputDecoration(
                                          suffix: InkWell(
                                              onTap: () {
                                                controller
                                                    .toggleShowPasswordStatus();
                                              },
                                              child: Icon(
                                                controller.isShowPassword
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: ColorManagement
                                                    .lightColorText,
                                                size: 14,
                                              )),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color:
                                                    ColorManagement.borderCell,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color:
                                                    ColorManagement.borderCell,
                                                width: 1),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color:
                                                    ColorManagement.borderCell,
                                                width: 1),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color:
                                                    ColorManagement.borderCell,
                                                width: 1),
                                          ),
                                          fillColor:
                                              ColorManagement.mainBackground,
                                          filled: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8),
                                        ),
                                        cursorColor: ColorManagement.greenColor,
                                      ),
                                    ),
                                  //name
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: SizeManagement.rowSpacing),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        Expanded(
                                          child: NeutronTextTitle(
                                            isRequired: true,
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_FIRST_NAME),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        Expanded(
                                          child: NeutronTextTitle(
                                            isRequired: true,
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_LAST_NAME),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        Expanded(
                                          child: NeutronTextFormField(
                                            controller: controller
                                                .teFirstNameController,
                                            isDecor: true,
                                            validator: (String? input) {
                                              if (input == null ||
                                                  input.isEmpty) {
                                                return MessageUtil
                                                    .getMessageByCode(
                                                        MessageCodeUtil
                                                            .INPUT_FIRST_NAME);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        Expanded(
                                          child: NeutronTextFormField(
                                            controller:
                                                controller.teLastNameController,
                                            isDecor: true,
                                            validator: (String? input) {
                                              if (input == null ||
                                                  input.isEmpty) {
                                                return MessageUtil
                                                    .getMessageByCode(
                                                        MessageCodeUtil
                                                            .INPUT_LAST_NAME);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                            width: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                      ],
                                    ),
                                  ),
                                  //phone
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isRequired: true,
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PHONE),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing),
                                    child: NeutronTextFormField(
                                      isPhoneNumber: true,
                                      controller: controller.tePhoneController,
                                      isDecor: true,
                                      validator: (String? input) {
                                        return StringValidator
                                            .validatePhoneNumber(input);
                                      },
                                    ),
                                  ),
                                  //gender
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GENDER),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              horizontalTitleGap: 4,
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      right: 4),
                                              title: NeutronTextContent(
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_MALE)),
                                              leading: Radio(
                                                value:
                                                    MessageCodeUtil.GENDER_MALE,
                                                onChanged: (value) {
                                                  controller.setGender(value);
                                                },
                                                activeColor: ColorManagement
                                                    .checkinBooking,
                                                groupValue: controller
                                                    .userHotel!.gender,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              horizontalTitleGap: 4,
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      right: 4),
                                              title: NeutronTextContent(
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_FEMALE)),
                                              leading: Radio(
                                                value: MessageCodeUtil
                                                    .GENDER_FEMALE,
                                                onChanged: (value) {
                                                  controller.setGender(value);
                                                },
                                                activeColor: ColorManagement
                                                    .checkinBooking,
                                                groupValue: controller
                                                    .userHotel!.gender,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              horizontalTitleGap: 4,
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 0),
                                              title: NeutronTextContent(
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_OTHER)),
                                              leading: Radio(
                                                value: MessageCodeUtil
                                                    .GENDER_OTHER,
                                                onChanged: (value) {
                                                  controller.setGender(value);
                                                },
                                                activeColor: ColorManagement
                                                    .checkinBooking,
                                                groupValue: controller
                                                    .userHotel!.gender,
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                  //date-of-birth
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DATE_OF_BIRTH),
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronDateTimePickerBorder(
                                        initialDate:
                                            controller.userHotel!.dateOfBirth,
                                        firstDate: DateTime.now().subtract(
                                            const Duration(days: 365 * 70)),
                                        lastDate: DateTime.now(),
                                        isEditDateTime: true,
                                        onPressed: (DateTime? picked) {
                                          if (picked == null) return;
                                          controller.setDateOfBirth(picked);
                                        },
                                      )),
                                  //job
                                  // Container(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       horizontal: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       vertical: SizeManagement.rowSpacing),
                                  //   child: NeutronTextTitle(
                                  //     isPadding: false,
                                  //     message: UITitleUtil.getTitleByCode(
                                  //         UITitleCode.TABLEHEADER_JOB),
                                  //   ),
                                  // ),
                                  // Container(
                                  //     margin: const EdgeInsets.only(
                                  //         left: SizeManagement
                                  //             .cardOutsideHorizontalPadding,
                                  //         right: SizeManagement
                                  //             .cardOutsideHorizontalPadding,
                                  //         bottom: SizeManagement
                                  //             .bottomFormFieldSpacing),
                                  //     child: NeutronDropDownCustom(
                                  //       childWidget: NeutronDropDown(
                                  //         isPadding: false,
                                  //         value: controller.jobOfUser,
                                  //         items: JobUlti.getJobs(),
                                  //         onChanged: (data) {
                                  //           controller.setJob(data);
                                  //         },
                                  //       ),
                                  //     )),
                                  //national-id
                                  // Container(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       horizontal: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       vertical: SizeManagement.rowSpacing),
                                  //   child: NeutronTextTitle(
                                  //     isRequired: true,
                                  //     isPadding: false,
                                  //     message: UITitleUtil.getTitleByCode(
                                  //         UITitleCode.TABLEHEADER_NATIONAL_ID),
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(
                                  //       left: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       right: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       bottom: SizeManagement
                                  //           .bottomFormFieldSpacing),
                                  //   child: NeutronTextFormField(
                                  //     controller:
                                  //         controller.teNationalIdController,
                                  //     isDecor: true,
                                  //     validator: (value) {
                                  //       return StringValidator
                                  //           .validateNationalId(value!);
                                  //     },
                                  //   ),
                                  // ),
                                  //country + city
                                  // Container(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       horizontal: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       vertical: SizeManagement.rowSpacing),
                                  //   child: Row(
                                  //     children: [
                                  //       Expanded(
                                  //         child: NeutronTextTitle(
                                  //           isRequired: true,
                                  //           isPadding: false,
                                  //           message: UITitleUtil.getTitleByCode(
                                  //               UITitleCode
                                  //                   .TABLEHEADER_COUNTRY),
                                  //         ),
                                  //       ),
                                  //       const SizedBox(
                                  //           width: SizeManagement
                                  //               .cardOutsideHorizontalPadding),
                                  //       Expanded(
                                  //         child: NeutronTextTitle(
                                  //           isRequired: true,
                                  //           isPadding: false,
                                  //           message: UITitleUtil.getTitleByCode(
                                  //               UITitleCode.TABLEHEADER_CITY),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(
                                  //       left: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       right: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       bottom: SizeManagement
                                  //           .bottomFormFieldSpacing),
                                  //   child: Row(children: [
                                  //     //country
                                  //     Expanded(
                                  //       child: Autocomplete<String>(
                                  //         optionsBuilder: (TextEditingValue
                                  //             textEditingValue) {
                                  //           if (textEditingValue.text.isEmpty) {
                                  //             return controller.countries;
                                  //           }

                                  //           return controller.countries
                                  //               .where((String option) {
                                  //             return option
                                  //                 .toLowerCase()
                                  //                 .startsWith(textEditingValue
                                  //                     .text
                                  //                     .toLowerCase());
                                  //           });
                                  //         },
                                  //         onSelected: (String selection) {
                                  //           if (kIsWeb &&
                                  //               (defaultTargetPlatform ==
                                  //                       TargetPlatform.iOS ||
                                  //                   defaultTargetPlatform ==
                                  //                       TargetPlatform
                                  //                           .android)) {
                                  //             FocusScope.of(context)
                                  //                 .requestFocus(FocusNode());
                                  //           }
                                  //           controller.setCountry(selection);
                                  //         },
                                  //         optionsViewBuilder:
                                  //             (context, onSelected, options) {
                                  //           return Align(
                                  //             alignment: Alignment.topLeft,
                                  //             child: Material(
                                  //               color: ColorManagement
                                  //                   .mainBackground,
                                  //               elevation: 5,
                                  //               child: ConstrainedBox(
                                  //                 constraints: const BoxConstraints(
                                  //                     maxHeight: 200,
                                  //                     maxWidth: kMobileWidth -
                                  //                         SizeManagement
                                  //                                 .cardOutsideHorizontalPadding *
                                  //                             2),
                                  //                 child: ListView.builder(
                                  //                   padding:
                                  //                       const EdgeInsets.all(0),
                                  //                   itemBuilder:
                                  //                       (context, index) =>
                                  //                           ListTile(
                                  //                     onTap: () => onSelected(
                                  //                         options.elementAt(
                                  //                             index)),
                                  //                     title: Text(
                                  //                       options
                                  //                           .elementAt(index),
                                  //                       style: const TextStyle(
                                  //                           fontSize: 14,
                                  //                           color:
                                  //                               Colors.white),
                                  //                     ),
                                  //                     contentPadding:
                                  //                         const EdgeInsets
                                  //                             .symmetric(
                                  //                             horizontal: 16,
                                  //                             vertical: 0),
                                  //                     minVerticalPadding: 0,
                                  //                     hoverColor:
                                  //                         Colors.white38,
                                  //                   ),
                                  //                   itemCount: options.length,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           );
                                  //         },
                                  //         fieldViewBuilder: (context,
                                  //                 textEditingController,
                                  //                 focusNode,
                                  //                 onEditingComplete) =>
                                  //             NeutronTextFormField(
                                  //           controller: textEditingController,
                                  //           focusNode: focusNode,
                                  //           onEditingComplete:
                                  //               onEditingComplete,
                                  //           isDecor: true,
                                  //           onChanged: (String country) {
                                  //             controller.setCountry(country);
                                  //           },
                                  //         ),
                                  //         initialValue: TextEditingValue(
                                  //             text: controller
                                  //                 .userHotel!.country!),
                                  //       ),
                                  //     ),
                                  //     const SizedBox(
                                  //         width: SizeManagement
                                  //             .cardOutsideHorizontalPadding),
                                  //     //city
                                  //     Expanded(
                                  //       child: Autocomplete<String>(
                                  //           optionsBuilder: (TextEditingValue
                                  //               textEditingValue) {
                                  //             if (textEditingValue
                                  //                 .text.isEmpty) {
                                  //               return controller.cities;
                                  //             }
                                  //             return controller.cities
                                  //                 .where((String option) {
                                  //               return option
                                  //                   .toLowerCase()
                                  //                   .startsWith(textEditingValue
                                  //                       .text
                                  //                       .toLowerCase());
                                  //             });
                                  //           },
                                  //           onSelected: (String selection) {
                                  //             FocusScope.of(context)
                                  //                 .requestFocus(FocusNode());
                                  //             controller.setCity(selection);
                                  //           },
                                  //           initialValue: TextEditingValue(
                                  //               text: controller
                                  //                   .userHotel!.city!),
                                  //           optionsViewBuilder:
                                  //               (context, onSelected, options) {
                                  //             return Align(
                                  //               alignment: Alignment.topLeft,
                                  //               child: Material(
                                  //                 color: ColorManagement
                                  //                     .mainBackground,
                                  //                 elevation: 5,
                                  //                 child: ConstrainedBox(
                                  //                   constraints: const BoxConstraints(
                                  //                       maxHeight: 200,
                                  //                       maxWidth: kMobileWidth -
                                  //                           SizeManagement
                                  //                                   .cardOutsideHorizontalPadding *
                                  //                               2),
                                  //                   child: ListView.builder(
                                  //                     padding:
                                  //                         const EdgeInsets.all(
                                  //                             0),
                                  //                     itemBuilder:
                                  //                         (context, index) =>
                                  //                             ListTile(
                                  //                       onTap: () => onSelected(
                                  //                           options.elementAt(
                                  //                               index)),
                                  //                       title: Text(
                                  //                         options
                                  //                             .elementAt(index),
                                  //                         style:
                                  //                             const TextStyle(
                                  //                                 fontSize: 14,
                                  //                                 color: Colors
                                  //                                     .white),
                                  //                       ),
                                  //                       contentPadding:
                                  //                           const EdgeInsets
                                  //                               .symmetric(
                                  //                               horizontal: 16,
                                  //                               vertical: 0),
                                  //                       minVerticalPadding: 0,
                                  //                       hoverColor:
                                  //                           Colors.white38,
                                  //                     ),
                                  //                     itemCount: options.length,
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           },
                                  //           fieldViewBuilder: (context,
                                  //               textEditingController,
                                  //               focusNode,
                                  //               onEditingComplete) {
                                  //             if (controller.cities.isEmpty) {
                                  //               textEditingController.clear();
                                  //             }
                                  //             return NeutronTextFormField(
                                  //               controller:
                                  //                   textEditingController,
                                  //               focusNode: focusNode,
                                  //               onEditingComplete:
                                  //                   onEditingComplete,
                                  //               isDecor: true,
                                  //               readOnly:
                                  //                   controller.cities.isEmpty,
                                  //               backgroundColor:
                                  //                   controller.cities.isEmpty
                                  //                       ? Colors.grey.shade800
                                  //                       : ColorManagement
                                  //                           .mainBackground,
                                  //             );
                                  //           }),
                                  //     ),
                                  //   ]),
                                  // ),
                                  //address
                                  // Container(
                                  //   margin: const EdgeInsets.symmetric(
                                  //       horizontal: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       vertical: SizeManagement.rowSpacing),
                                  //   child: NeutronTextTitle(
                                  //     isRequired: true,
                                  //     isPadding: false,
                                  //     message: UITitleUtil.getTitleByCode(
                                  //         UITitleCode.TABLEHEADER_ADDRESS),
                                  //   ),
                                  // ),
                                  // Container(
                                  //   margin: const EdgeInsets.only(
                                  //       left: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       right: SizeManagement
                                  //           .cardOutsideHorizontalPadding,
                                  //       bottom: SizeManagement
                                  //           .bottomFormFieldSpacing),
                                  //   child: NeutronTextFormField(
                                  //     controller:
                                  //         controller.teAddressController,
                                  //     isDecor: true,
                                  //     validator: (String? input) {
                                  //       if (input == null || input.isEmpty) {
                                  //         return MessageUtil.getMessageByCode(
                                  //             MessageCodeUtil.INPUT_ADDRESS);
                                  //       }
                                  //       return null;
                                  //     },
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: NeutronButton(
                                icon: Icons.save,
                                onPressed: () async {
                                  if (!updateUserForm.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  controller.setNewUser();
                                  String result = await controller
                                      .updateUserToCloud()
                                      .then((value) => value);
                                  if (result ==
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    UserManager.user = controller.userHotel;
                                    if ((isSignUpUser ?? false) ||
                                        (turnOffDialogAfterSuccess ?? false)) {
                                      Navigator.pop(
                                          context, MessageCodeUtil.SUCCESS);
                                    }
                                  }
                                  MaterialUtil.showResult(context, result);
                                }),
                          )
                        ]));
              },
            )),
      ),
    );
  }
}
