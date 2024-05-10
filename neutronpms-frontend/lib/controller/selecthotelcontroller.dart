// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../handler/firebasehandler.dart';
import '../manager/generalmanager.dart';
import '../manager/roles.dart';
import '../manager/usermanager.dart';
import '../modal/hotel.dart';
import '../modal/hoteluser.dart';
import '../ui/component/management/membermanagement/updateuserdialog.dart';
import '../util/messageulti.dart';

class HotelPageController extends ChangeNotifier {
  List<Hotel> hotels = [];
  Map<String, Uint8List?> images = {};
  HotelUser? userHotel;
  HotelPageStatus? status;

  BuildContext? thisContext;

  //this is for admin-account search hotels by name
  static late TextEditingController nameQuery;
  late SharedPreferences sharedPreferences;

  HotelPageController() {
    initialize();
  }

  void initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? lastQueryName = sharedPreferences.getString('name-query');
    if (lastQueryName == null || lastQueryName.isEmpty) {
      lastQueryName = 'Treetopia - Neutron TESTING';
    }
    nameQuery = TextEditingController(text: lastQueryName);
    if (!UserManager.isAdmin()) {
      status = HotelPageStatus.loading;
      getHotelsByUidOfUser();
    } else {
      getHotelsByNameQuery();
    }
  }

  void setContext(BuildContext context) {
    thisContext = context;
  }

  void getHotelAfterCreate() async {
    status = HotelPageStatus.loading;
    notifyListeners();
    hotels = await FirebaseHandler().getHotelIDsByUser(UserManager.user!.id!);
    if (hotels.isNotEmpty) {
      hotels.forEach((hotel) async {
        await getImage(hotel.id!);
        if (images.values.length == hotels.length) {
          status = HotelPageStatus.success;
          notifyListeners();
        }
      });
    } else {
      status = HotelPageStatus.noHotel;
      notifyListeners();
    }
  }

  void getHotelsByUidOfUser() async {
    hotels = await FirebaseHandler().getHotelIDsByUser(UserManager.user!.id!);
    if (hotels.isNotEmpty) {
      hotels.forEach((hotel) async {
        await getImage(hotel.id!);
        if (images.values.length == hotels.length) {
          status = HotelPageStatus.success;
          notifyListeners();
        }
      });
    } else {
      status = HotelPageStatus.noHotel;
    }
    userHotel = await UserManager.getSystemUserById(UserManager.user!.id!)
        .then((value) => value);
    if (userHotel == null || !userHotel!.isFullOfInformation()) {
      status = HotelPageStatus.updateInfo;
    } else {
      UserManager.user = userHotel;
    }
    notifyListeners();
  }

  Future<void> showUserDialog(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      String? result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => UpdateUserDialog(
          userHotel: userHotel!,
          turnOffDialogAfterSuccess: true,
        ),
      );
      if (result == null) {
        status = HotelPageStatus.needUpdateInfo;
      } else {
        UserManager.user = userHotel;
        status =
            hotels.isEmpty ? HotelPageStatus.noHotel : HotelPageStatus.success;
      }
      notifyListeners();
    });
  }

  Future<void> getImage(String hotelId) async {
    Uint8List? imageInUinit8List =
        await FirebaseHandler().getImgByHotelId(hotelId);
    images[hotelId] = imageInUinit8List!;
  }

  void updateHotel(String hotelID) {
    final hotel = hotels.firstWhere((element) => element.id == hotelID);
    if (hotel.roles!.containsKey(FirebaseAuth.instance.currentUser!.uid)) {
      UserManager.role =
          List.castFrom(hotel.roles![FirebaseAuth.instance.currentUser!.uid]);
      Roles.updateRolesForAuthorize();
    }
    if (UserManager.role == null || UserManager.role!.isEmpty) {
      UserManager.reset();
      return;
    }

    UserManager.user!.id = FirebaseAuth.instance.currentUser!.uid;
    GeneralManager.hotel = hotel;
    GeneralManager.hotelID = hotel.id;
    GeneralManager.updatePackage();
    FirebaseHandler.updateHotel();
    if (GeneralManager.hotel!.isProPackage()) {
      GeneralManager().getFilterTaxDeclare();
    } else {
      GeneralManager.isFilterTaxDeclare = false;
    }
    print(
        'Login to hotel: ${GeneralManager.hotel!.name} - ${GeneralManager.hotel!.package} - by email: ${UserManager.user!.email} - with role: ${UserManager.role}');
  }

  Future<Map<String, dynamic>?> getInformationOfHotel(String hotelID) async {
    status = HotelPageStatus.loading;
    notifyListeners();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('hotelmanager-getInfoHotel')
          .call({'hotel_id': hotelID});
      final infoHotel = result.data;
      final dataResult = infoHotel['result'];
      if (dataResult == MessageCodeUtil.SUCCESS) {
        status = HotelPageStatus.success;
        notifyListeners();
        return infoHotel;
      } else {
        status = HotelPageStatus.success;
        notifyListeners();
        return null;
      }
    } catch (e) {
      status = HotelPageStatus.success;
      notifyListeners();
      return null;
    }
  }

  void getHotelsByNameQuery() async {
    status = HotelPageStatus.loading;
    notifyListeners();
    hotels = await FirebaseHandler()
        .getHotelsWithApproximateQuery(nameQuery.text.trim());
    sharedPreferences.setString('name-query', nameQuery.text.trim());
    if (hotels.isNotEmpty) {
      hotels.forEach((hotel) async {
        images.clear();
        await getImage(hotel.id!);

        if (images.values.length == hotels.length) {
          status = HotelPageStatus.success;
          notifyListeners();
        }
      });
    } else {
      status = HotelPageStatus.hotelNotFoundWithQuery;
    }
    userHotel = await UserManager.getSystemUserById(UserManager.user!.id!)
        .then((value) => value);
    UserManager.user = userHotel;
    notifyListeners();
  }
}
