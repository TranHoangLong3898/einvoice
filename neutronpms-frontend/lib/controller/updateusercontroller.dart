import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/hoteluser.dart';
// import 'package:ihotel/util/countryulti.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
// import 'package:ihotel/util/jobulti.dart';

class UpdateUserController extends ChangeNotifier {
  late bool? isSignUpUser;
  bool isInprogress = false;
  bool isShowPassword = false;

  final HotelUser? userHotel;
  late TextEditingController teEmailController;
  late TextEditingController tePasswordController;
  late TextEditingController teFirstNameController;
  late TextEditingController teLastNameController;
  late TextEditingController tePhoneController;
  // late TextEditingController teAddressController;
  // late TextEditingController teNationalIdController;
  // List<String> countries = [...CountryUtil.getCountries()];
  // List<String> cities = [];
  // late String jobOfUser;

  UpdateUserController(this.userHotel, this.isSignUpUser) {
    isSignUpUser ??= false;
    teEmailController = TextEditingController(text: '');
    tePasswordController = TextEditingController(text: '');
    teFirstNameController =
        TextEditingController(text: userHotel?.firstName ?? '');
    teLastNameController =
        TextEditingController(text: userHotel?.lastName ?? '');
    tePhoneController = TextEditingController(text: userHotel?.phone ?? '');
    userHotel?.gender ??= MessageCodeUtil.GENDER_MALE;
    DateTime nowDate = DateTime.now();
    userHotel?.dateOfBirth ??=
        DateTime(nowDate.year - 18, nowDate.month, nowDate.day);
    // teAddressController = TextEditingController(text: userHotel?.address ?? '');
    // teNationalIdController =
    //     TextEditingController(text: userHotel?.nationalId ?? '');

    // jobOfUser = (userHotel?.job == null
    //     ? JobUlti.getJobs().first
    //     : JobUlti.convertJobNameFromEnToLocal(userHotel!.job))!;
    // cities.addAll(CountryUtil.getCitiesByCountry(userHotel?.country));
    // userHotel?.country ??= '';
    // userHotel?.city ??= '';
  }

  void setNewUser() {
    userHotel!.firstName =
        teFirstNameController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim();
    userHotel!.lastName =
        teLastNameController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim();
    userHotel!.phone = tePhoneController.text;
    // userHotel!.address =
    //     teAddressController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim();
    // userHotel!.nationalId =
    //     teNationalIdController.text.replaceAll(RegExp(r'\s\s+'), ' ').trim();
  }

  void setDateOfBirth(DateTime picked) {
    if (userHotel!.dateOfBirth!.isAtSameMomentAs(picked)) return;
    userHotel!.dateOfBirth = picked;
    notifyListeners();
  }

  void setGender(value) {
    if (userHotel!.gender == value) return;
    userHotel!.gender = value;
    notifyListeners();
  }

  // void setJob(data) {
  //   if (jobOfUser == data) return;
  //   jobOfUser = data;
  //   notifyListeners();
  // }

  // void setCountry(String country) {
  //   cities.clear();
  //   if (!countries.contains(country)) {
  //     userHotel!.city = '';
  //     notifyListeners();
  //     return;
  //   }
  //   userHotel!.country = country;
  //   cities.addAll(CountryUtil.getCitiesByCountry(country));
  //   userHotel!.city = cities.first;
  //   notifyListeners();
  // }

  // void setCity(String city) {
  //   if (userHotel!.city == city) return;
  //   userHotel!.city = city;
  //   notifyListeners();
  // }

  void toggleProgressStatus() {
    isInprogress = !isInprogress;
    notifyListeners();
  }

  void toggleShowPasswordStatus() {
    if (tePasswordController.text.isEmpty) {
      isShowPassword = false;
    } else {
      isShowPassword = !isShowPassword;
    }
    notifyListeners();
  }

  Future<String> updateUserToCloud() async {
    // if (userHotel!.job ==
    //     MessageUtil.getMessageByCode(MessageCodeUtil.JOB_CHOOSE)) {
    //   return MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CHOOSE_JOB);
    // }
    // if (!CountryUtil.countries.keys.contains(userHotel!.country)) {
    //   return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_COUNTRY);
    // }

    // if (!CountryUtil.countries[userHotel!.country]!.contains(userHotel!.city)) {
    //   return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_CITY);
    // }
    toggleProgressStatus();
    try {
      // userHotel!.job = JobUlti.convertJobNameFromLocalToEn(jobOfUser);
      String result;
      if (isSignUpUser!) {
        result = await FirebaseFunctions.instance
            .httpsCallable('user-register')
            .call({
          "email": teEmailController.text,
          "password": tePasswordController.text,
          "first_name": userHotel!.firstName,
          "last_name": userHotel!.lastName,
          "phone": userHotel!.phone,
          "gender": userHotel!.gender,
          "date_of_birth": DateUtil.dateToShortString(userHotel!.dateOfBirth!),
          // "job": userHotel!.job,
          // "national_id": userHotel!.nationalId,
          // "address": userHotel!.address,
          // "country": userHotel!.country,
          // "city": userHotel!.city,
          "language": GeneralManager.locale!.toLanguageTag()
        }).then((value) => value.data);
        if (result == MessageCodeUtil.SUCCESS) {
          FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: teEmailController.text,
                  password: tePasswordController.text)
              .then((value) {
            UserManager.user!.id = value.user!.uid;
            print('Register and login successfully!');
          }).onError((error, stackTrace) {
            print(error);
          });
        }
      } else {
        result = await FirebaseFunctions.instance
            .httpsCallable('user-addUserInfo')
            .call({
          "first_name": userHotel!.firstName,
          "last_name": userHotel!.lastName,
          "phone": userHotel!.phone,
          "gender": userHotel!.gender,
          "date_of_birth": DateUtil.dateToShortString(userHotel!.dateOfBirth!),
          // "job": userHotel!.job,
          // "national_id": userHotel!.nationalId,
          // "address": userHotel!.address,
          // "country": userHotel!.country,
          // "city": userHotel!.city
        }).then((value) => value.data);
      }
      return MessageUtil.getMessageByCode(result);
    } catch (e) {
      return MessageUtil.getMessageByCode(
          (e as FirebaseFunctionsException).message);
    } finally {
      toggleProgressStatus();
    }
  }
}
