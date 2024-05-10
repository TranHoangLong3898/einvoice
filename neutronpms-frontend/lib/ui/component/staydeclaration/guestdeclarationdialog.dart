import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/staydeclaration/countrydeclaration.dart';
import 'package:ihotel/modal/staydeclaration/staydeclaration.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class GuestDeclarationDialog extends StatelessWidget {
  final formKey = GlobalKey<FormState>();

  final StayDeclaration? guest;
  GuestDeclarationController? controller;

  GuestDeclarationDialog({Key? key, this.guest}) : super(key: key) {
    controller = GuestDeclarationController(stayDeclaration: guest);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: ChangeNotifierProvider<GuestDeclarationController>.value(
              value: controller!,
              child: Consumer<GuestDeclarationController>(
                  builder: (_, controller, __) {
                final bool isShowDetailAddress =
                    controller.nationalAddress == CountryDeclaration.VIETNAM;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      alignment: Alignment.center,
                      child: NeutronTextHeader(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_GUEST_INFOS)),
                    ),
                    //name
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.rowSpacing,
                          horizontal:
                              SizeManagement.cardInsideHorizontalPadding),
                      child: NeutronTextFormField(
                        labelRequired: true,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_FULL_NAME),
                        controller: controller.teName,
                        isDecor: true,
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return MessageUtil.getMessageByCode(
                                MessageCodeUtil.INPUT_FULL_NAME);
                          }
                          return null;
                        },
                      ),
                    ),
                    //ngay sinh
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.rowSpacing,
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: Row(children: [
                        Expanded(
                            child: NeutronDateTimePickerBorder(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DATE_OF_BIRTH),
                          isRequiredlabel: true,
                          initialDate: controller.dateOfBirth,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 100)),
                          isEditDateTime: true,
                          onPressed: (DateTime picked) {
                            controller.setDate(picked);
                          },
                        )),
                        const SizedBox(
                            width: SizeManagement.cardInsideHorizontalPadding),
                        Expanded(
                            child: NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ACCURACY),
                          isRequiredlabel: true,
                          childWidget: NeutronDropDown(
                            isPadding: false,
                            items: controller.accuracies,
                            value: controller.accuracy,
                            onChanged: (String value) {
                              controller.setAccuracy(value);
                            },
                          ),
                        ))
                      ]),
                    ),
                    //gender
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.rowSpacing,
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: NeutronDropDownCustom(
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_GENDER),
                        isRequiredlabel: true,
                        childWidget: NeutronDropDown(
                            isPadding: false,
                            items: controller.genders,
                            value: controller.gender,
                            onChanged: (String value) {
                              controller.setGender(value);
                            },
                            textStyle: NeutronTextStyle.content),
                      ),
                    ),
                    //reason + stay type
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeManagement.rowSpacing,
                          horizontal:
                              SizeManagement.cardOutsideHorizontalPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: NeutronDropDownCustom(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_STAY_TYPE),
                              isRequiredlabel: true,
                              childWidget: NeutronDropDown(
                                  isPadding: false,
                                  items: controller.stayTypes,
                                  value: controller.stayType,
                                  onChanged: (String value) {
                                    controller.setStayType(value);
                                  },
                                  textStyle: NeutronTextStyle.content),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  SizeManagement.cardInsideHorizontalPadding),
                          Expanded(
                            child: NeutronDropDownCustom(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_REASON),
                              isRequiredlabel: true,
                              childWidget: NeutronDropDown(
                                  isPadding: false,
                                  items: controller.reasons,
                                  value: controller.reason,
                                  onChanged: (String value) {
                                    controller.setReason(value);
                                  },
                                  textStyle: NeutronTextStyle.content),
                            ),
                          )
                        ],
                      ),
                    ),
                    //CMND, CCCD, Số định danh
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextFormField(
                          labelRequired: true,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CMND_CCCD),
                          controller: controller.teNationalId,
                          isDecor: true,
                          validator: (String? value) {
                            if (value!.isNotEmpty &&
                                value.length != 9 &&
                                value.length != 12) {
                              return MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INVALID_CMND_CCCD);
                            }
                            return null;
                          },
                        )),
                    //Passport
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextFormField(
                          labelRequired: true,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PASSPORT),
                          controller: controller.tePassport,
                          isDecor: true,
                        )),
                    //other doc
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextFormField(
                          labelRequired: true,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_OTHER_DOCUMENT),
                          controller: controller.teOtherDoc,
                          isDecor: true,
                        )),
                    //nationality
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return controller.nationalities;
                            }
                            return controller.nationalities.where(
                                (String option) => option
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            GeneralManager().unfocus(context);
                            controller.setNation(selection);
                          },
                          optionsViewBuilder: (context, onSelected, options) {
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
                                    itemBuilder: (context, index) => ListTile(
                                      onTap: () =>
                                          onSelected(options.elementAt(index)),
                                      title: Text(
                                        options.elementAt(index),
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                      minVerticalPadding: 0,
                                      hoverColor: Colors.white38,
                                    ),
                                    itemCount: options.length,
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, textEditingController,
                                  focusNode, onEditingComplete) =>
                              NeutronTextFormField(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_NATIONALITY),
                            labelRequired: true,
                            controller: textEditingController,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            isDecor: true,
                            onChanged: (String address) {
                              if (address.isEmpty) {
                                controller.nationality = '';
                              }
                            },
                          ),
                          initialValue:
                              TextEditingValue(text: controller.nationality),
                        )),
                    //nationalAddress
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return controller.nationalities;
                            }
                            return controller.nationalities.where(
                                (String option) => option
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            GeneralManager().unfocus(context);
                            controller.setNationalAddress(selection);
                          },
                          optionsViewBuilder: (context, onSelected, options) {
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
                                    itemBuilder: (context, index) => ListTile(
                                      onTap: () =>
                                          onSelected(options.elementAt(index)),
                                      title: Text(
                                        options.elementAt(index),
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                      minVerticalPadding: 0,
                                      hoverColor: Colors.white38,
                                    ),
                                    itemCount: options.length,
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (context, textEditingController,
                                  focusNode, onEditingComplete) =>
                              NeutronTextFormField(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_NATIONAL_ADDRESS),
                            labelRequired: true,
                            controller: textEditingController,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            isDecor: true,
                            onChanged: (String address) {
                              controller.setNationalAddress(address);
                            },
                          ),
                          initialValue: TextEditingValue(
                              text: controller.nationalAddress),
                        )),
                    //cityAddress
                    if (isShowDetailAddress)
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: SizeManagement.rowSpacing,
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return controller.listCityAddress;
                              }
                              return controller.listCityAddress.where(
                                  (String option) => option
                                      .toLowerCase()
                                      .contains(
                                          textEditingValue.text.toLowerCase()));
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
                              controller.setCityAddress(selection);
                            },
                            optionsViewBuilder: (context, onSelected, options) {
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
                                      itemBuilder: (context, index) => ListTile(
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
                                                horizontal: 16, vertical: 0),
                                        minVerticalPadding: 0,
                                        hoverColor: Colors.white38,
                                      ),
                                      itemCount: options.length,
                                    ),
                                  ),
                                ),
                              );
                            },
                            fieldViewBuilder: (context, textEditingController,
                                    focusNode, onEditingComplete) =>
                                NeutronTextFormField(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CITY_ADDRESS),
                              labelRequired: true,
                              controller: textEditingController,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              isDecor: true,
                              onChanged: (String address) {
                                controller.setCityAddress(address);
                              },
                            ),
                            initialValue:
                                TextEditingValue(text: controller.cityAddress),
                          )),
                    //districtAddress
                    if (isShowDetailAddress)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronDropDownCustom(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DISTRICT_ADDRESS),
                            isRequiredlabel: true,
                            childWidget: NeutronDropDown(
                              isDisabled: !controller.isValidCityAddress(),
                              isPadding: false,
                              items: ["", ...controller.listDistrictAddress],
                              value: controller.districtAddress,
                              onChanged: (String value) {
                                controller.setDistrictAddress(value);
                              },
                              textStyle: NeutronTextStyle.content,
                            )),
                      ),
                    //communeAddress
                    if (isShowDetailAddress)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronDropDownCustom(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_COMMUNE_ADDRESS),
                            isRequiredlabel: true,
                            childWidget: NeutronDropDown(
                              isDisabled: !controller.isValidDistrictAddress(),
                              isPadding: false,
                              items: ["", ...controller.listCommuneAdress],
                              value: controller.communeAddress,
                              onChanged: (String value) {
                                controller.setCommuneAddress(value);
                              },
                              textStyle: NeutronTextStyle.content,
                            )),
                      ),
                    //detail adress
                    if (isShowDetailAddress)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.rowSpacing,
                            horizontal:
                                SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextFormField(
                          labelRequired: true,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DETAIL_ADDRESS),
                          controller: controller.teDetailAddress,
                          isDecor: true,
                          validator: (String? value) {
                            if (isShowDetailAddress && value!.isEmpty) {
                              return MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INPUT_DETAIL_ADDRESS);
                            }
                            return null;
                          },
                        ),
                      ),

                    NeutronButton(
                      icon: Icons.save,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          String? validation = controller.validate();
                          if (validation != null) {
                            MaterialUtil.showAlert(context,
                                MessageUtil.getMessageByCode(validation));
                            return;
                          }
                          StayDeclaration result = controller.save();
                          Navigator.pop(context, result);
                        }
                      },
                    )
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

class GuestDeclarationController extends ChangeNotifier {
  StayDeclaration? oldGuest, newGuest;

  late TextEditingController teName,
      teNationalId,
      tePassport,
      teOtherDoc,
      teDetailAddress;
  late String gender;
  late String nationality;
  late DateTime dateOfBirth;
  late String accuracy;
  late String nationalAddress, cityAddress, districtAddress, communeAddress;
  late String reason, stayType;

  final List<String> nationalities = CountryDeclaration.nationalities;
  final List<String> accuracies = [
    'D - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE)}',
    'M - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MONTH)}',
    'Y - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_YEAR)}'
  ];
  final List<String> genders = [
    'Chưa có thông tin',
    'Giới tính nam',
    'Giới tính nữ',
    'Khác'
  ];
  final List<String> listNationalAddress = CountryDeclaration.nationalities;
  final List<String> listCityAddress = [];
  final List<String> listDistrictAddress = [];
  final List<String> listCommuneAdress = [];
  final List<String> reasons = [
    "",
    "B2-Đầu tư",
    "Báo chí",
    "Con nuôi",
    "Công tác",
    "Du lịch",
    "Học tập",
    "Hội nghị",
    "Kết hôn",
    "Lao động",
    "Mục đích khác",
    "Thăm thân",
    "Thương mại",
    "Tiếp thị",
    "Viện trợ",
    "Định cư"
  ];
  final List<String> stayTypes = ["Thường trú", "Tạm trú", "Địa chỉ khác"];

  GuestDeclarationController({StayDeclaration? stayDeclaration}) {
    teName = TextEditingController(text: stayDeclaration?.name ?? '');
    teNationalId =
        TextEditingController(text: stayDeclaration?.nationalId ?? '');
    tePassport = TextEditingController(text: stayDeclaration?.passport ?? '');
    teOtherDoc = TextEditingController(text: stayDeclaration?.otherDocId ?? '');
    gender = stayDeclaration?.gender ?? genders.first;
    nationality = stayDeclaration?.nationality ?? CountryDeclaration.VIETNAM;
    nationalAddress =
        stayDeclaration?.nationalAddress ?? CountryDeclaration.VIETNAM;
    teDetailAddress =
        TextEditingController(text: stayDeclaration?.detailAddress ?? '');
    listCityAddress.addAll(CountryDeclaration.vietnameseCountries.keys);
    dateOfBirth = stayDeclaration?.dateOfBirth ?? DateTime.now();
    accuracy = stayDeclaration?.accuracyOfDob ?? accuracies.first;
    reason = stayDeclaration?.reason ?? '';
    stayType = stayDeclaration?.stayType ?? stayTypes.first;
    cityAddress = stayDeclaration?.cityAddress ?? "";
    districtAddress = stayDeclaration?.districtAddress ?? "";
    if (districtAddress.isNotEmpty) {
      listDistrictAddress
          .addAll(CountryDeclaration.vietnameseCountries[cityAddress]!.keys);
    }
    communeAddress = stayDeclaration?.communeAddress ?? "";
    if (communeAddress.isNotEmpty) {
      listCommuneAdress.addAll(CountryDeclaration
          .vietnameseCountries[cityAddress]![districtAddress]!);
    }
    oldGuest = stayDeclaration;
  }

  void setNation(String newNation) {
    if (nationality == newNation) {
      return;
    }
    nationality = newNation;
    notifyListeners();
  }

  void setGender(String newGender) {
    if (gender == newGender) {
      return;
    }
    gender = newGender;
    notifyListeners();
  }

  void setDate(DateTime picked) {
    if (dateOfBirth.isAtSameMomentAs(picked)) {
      return;
    }
    dateOfBirth = picked;
    notifyListeners();
  }

  void setAccuracy(String newAccuracy) {
    if (accuracy == newAccuracy) {
      return;
    }
    accuracy = newAccuracy;
    notifyListeners();
  }

  void setNationalAddress(String newAddress) {
    if (nationalAddress == newAddress) {
      return;
    }
    nationalAddress = newAddress;
    if (nationalAddress == CountryDeclaration.VIETNAM) {
      cityAddress = "";
      districtAddress = "";
      communeAddress = "";
    }
    notifyListeners();
  }

  void setCityAddress(String newCity) {
    if (cityAddress == newCity) {
      return;
    }
    cityAddress = newCity;
    districtAddress = "";
    communeAddress = "";
    listDistrictAddress.clear();
    listCommuneAdress.clear();
    listDistrictAddress.addAll(
        CountryDeclaration.vietnameseCountries[cityAddress]?.keys ?? []);
    notifyListeners();
  }

  void setDistrictAddress(String newCity) {
    if (districtAddress == newCity) {
      return;
    }
    districtAddress = newCity;
    communeAddress = "";
    listCommuneAdress.clear();
    if (CountryDeclaration.vietnameseCountries.containsKey(cityAddress) &&
        CountryDeclaration.vietnameseCountries[cityAddress]!
            .containsKey(districtAddress)) {
      listCommuneAdress.addAll(CountryDeclaration
          .vietnameseCountries[cityAddress]![districtAddress]!);
    }
    notifyListeners();
  }

  void setCommuneAddress(String newCity) {
    if (communeAddress == newCity) {
      return;
    }
    communeAddress = newCity;
    notifyListeners();
  }

  void setReason(String newReason) {
    if (reason == newReason) {
      return;
    }
    reason = newReason;
    notifyListeners();
  }

  void setStayType(String newType) {
    if (stayType == newType) {
      return;
    }
    stayType = newType;
    notifyListeners();
  }

  bool isValidCityAddress() {
    return cityAddress.isNotEmpty &&
        CountryDeclaration.vietnameseCountries.containsKey(cityAddress);
  }

  bool isValidDistrictAddress() {
    return districtAddress.isNotEmpty &&
        CountryDeclaration.vietnameseCountries[cityAddress]!
            .containsKey(districtAddress);
  }

  bool isValidCommuneAddress() {
    return communeAddress.isNotEmpty &&
        CountryDeclaration.vietnameseCountries[cityAddress]![districtAddress]!
            .contains(communeAddress);
  }

  String? validate() {
    if (reason.trim().isEmpty) {
      return MessageCodeUtil.PLEASE_CHOOSE_REASON;
    }
    if (teNationalId.text.trim().isEmpty &&
        teOtherDoc.text.trim().isEmpty &&
        tePassport.text.trim().isEmpty) {
      return MessageCodeUtil.PLEASE_INPUT_DOC_ID_FOR_GUEST_DECLARATION;
    }
    if (teNationalId.text.trim().length > 32) {
      return MessageCodeUtil.OVER_CMND_CCCD_MAX_LENGTH;
    }
    if (tePassport.text.trim().length > 32) {
      return MessageCodeUtil.OVER_PASSPORT_MAX_LENGTH;
    }
    if (teOtherDoc.text.trim().length > 32) {
      return MessageCodeUtil.OVER_OTHER_DOCUMENT_MAX_LENGTH;
    }
    if (nationality.isEmpty) {
      return MessageCodeUtil.PLEASE_CHOOSE_NATIONALITY;
    }
    if (nationalAddress.isEmpty) {
      return MessageCodeUtil.PLEASE_CHOOSE_ADDRESS;
    } else if (!CountryDeclaration.nationalities.contains(nationalAddress)) {
      return MessageCodeUtil.INVALID_NATIONAL_ADDRESS;
    } else if (nationalAddress == CountryDeclaration.VIETNAM) {
      if (!isValidCityAddress()) {
        return MessageCodeUtil.INVALID_CITY_ADDRESS;
      }
      if (!isValidDistrictAddress()) {
        return MessageCodeUtil.INVALID_DISTRICT_ADDRESS;
      }
      if (!isValidCommuneAddress()) {
        return MessageCodeUtil.INVALID_COMMUNE_ADDRESS;
      }
    } else if (tePassport.text.trim().isEmpty) {
      return MessageCodeUtil.PLEASE_INPUT_PASSPORT_FOR_FOREINGER;
    }

    String accuracyInEnglish;
    if (accuracy.startsWith("D")) {
      accuracyInEnglish = "D - Date";
    } else if (accuracy.startsWith("M")) {
      accuracyInEnglish = "M - Month";
    } else {
      accuracyInEnglish = "Y - Year";
    }

    newGuest = StayDeclaration(
        nationality: nationality,
        dateOfBirth: dateOfBirth,
        name: teName.text.trim(),
        gender: gender,
        accuracyOfDob: accuracyInEnglish,
        nationalAddress: nationalAddress,
        cityAddress: cityAddress,
        districtAddress: districtAddress,
        communeAddress: communeAddress,
        detailAddress: teDetailAddress.text.trim(),
        nationalId: teNationalId.text.trim(),
        otherDocId: teOtherDoc.text.trim(),
        passport: tePassport.text.trim(),
        reason: reason,
        stayType: stayType);

    if (oldGuest != null && oldGuest!.equalTo(newGuest!)) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }
    return null;
  }

  StayDeclaration save() {
    return newGuest!;
  }
}
