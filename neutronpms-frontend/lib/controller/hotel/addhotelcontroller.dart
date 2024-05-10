import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/minibarmanager.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/modal/hotel.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/ui/component/service/hotelservice/minibarhotelservicedialog.dart';
import 'package:ihotel/util/autoexportitemsstatus.dart';
import 'package:ihotel/util/countryulti.dart';
import 'package:ihotel/util/messageulti.dart';

class AddHotelController extends ChangeNotifier {
  final String chooseTimezone =
      MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_TIMEZONE);
  late TextEditingController teName;
  late TextEditingController tePhone;
  late TextEditingController teEmail;
  late TextEditingController teStreet;
  String message = '';
  String errorLog = '';
  Uint8List? base64;
  late String teTimezone;
  late String teCurrency;
  late String teCountry;
  late String teCity;
  List<String> listTimezone = [];
  List<String> listCurrency = [];
  List<String> listCountry = CountryUtil.getCountries();
  List<String> listCity = [];
  bool isLoading = false;
  String? autoExportItems;
  final Hotel? hotel;
  bool isLoadingInvalidItem = false;
  AddHotelController({this.hotel}) {
    isLoading = true;
    notifyListeners();
    teName = TextEditingController(text: hotel?.name ?? '');
    tePhone = TextEditingController(text: hotel?.phone ?? '');
    teEmail = TextEditingController(text: hotel?.email ?? '');
    teStreet = TextEditingController(text: hotel?.street ?? '');
    teTimezone = hotel?.timezone ?? chooseTimezone;
    teCurrency = hotel?.currencyCode ?? '';
    teCountry = hotel?.country ?? '';
    teCity = hotel?.city ?? '';
    autoExportItems = hotel?.autoExportItems ?? HotelAutoExportItemsStatus.NO;
    listCity.addAll(CountryUtil.getCitiesByCountry(hotel?.country));
    getCurrencyAndTimeZone();
  }

  void getCurrencyAndTimeZone() async {
    final currencyAssests =
        await rootBundle.loadString('assets/data/currency.json');
    List<dynamic> currencyDecodes = jsonDecode(currencyAssests);
    for (var item in currencyDecodes) {
      listCurrency.add(item['name']);
    }

    final timeZoneAssests =
        await rootBundle.loadString('assets/data/timezone.json');
    List<dynamic> timezoneDecodes = jsonDecode(timeZoneAssests);
    timezoneDecodes.sort((a, b) {
      int compareOffset = a['offset'].compareTo(b['offset']);
      if (compareOffset == 0) {
        String nameOfA = (a['text'] as String).split(')')[1];
        String nameOfB = (b['text'] as String).split(')')[1];
        return nameOfA.compareTo(nameOfB);
      }
      return compareOffset;
    });
    for (var item in timezoneDecodes) {
      listTimezone.add(item['text']);
    }
    listTimezone.insert(
        0, MessageUtil.getMessageByCode(MessageCodeUtil.CHOOSE_TIMEZONE));

    if (hotel != null) {
      final data = await FirebaseStorage.instance
          .ref('img_hotels')
          .child(hotel!.id!)
          .getData()
          .onError((error, stackTrace) => null);
      base64 = data;
    }
    isLoading = false;
    notifyListeners();
  }

  void setTimezone(String timezone) async {
    if (timezone == chooseTimezone) return;
    teTimezone = timezone;
    notifyListeners();
  }

  setCurrency(String value, {bool? isSelectAction}) {
    isSelectAction ??= false;
    if (teCurrency == value && !isSelectAction) return;
    teCurrency = value;
    notifyListeners();
  }

  setCountry(String country) {
    listCity.clear();
    if (!listCountry.contains(country)) {
      teCity = '';
      notifyListeners();
      return;
    }
    teCountry = country;
    listCity.addAll(CountryUtil.getCitiesByCountry(country));
    teCity = '';
    notifyListeners();
  }

  setCity(String city, {bool? isSelectAction}) {
    isSelectAction ??= false;
    if (teCity == city && !isSelectAction) return;
    teCity = city;
    notifyListeners();
  }

  String setImageToHotel(PlatformFile pickedFile) {
    if (pickedFile.size > 1024 * 100) {
      base64 = null;
      return MessageUtil.getMessageByCode(MessageCodeUtil.IMAGE_OVER_MAX_SIZE);
    }
    base64 = pickedFile.bytes;
    notifyListeners();
    return '';
  }

  void setAutoExportItems(String? newValue) {
    if (newValue == autoExportItems) return;
    autoExportItems = newValue;
    notifyListeners();
  }

  // Call httpCallbale to create
  Future<bool> addHotel() async {
    if (!CountryUtil.countries.keys.contains(teCountry)) {
      errorLog = MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_COUNTRY);
      return false;
    }

    if (teCity.isEmpty) {
      errorLog =
          MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_CHOOSE_CITY);
      return false;
    }

    if (!CountryUtil.countries[teCountry]!.contains(teCity)) {
      errorLog = MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_CITY);
      return false;
    }
    if (teTimezone == chooseTimezone) {
      errorLog = MessageUtil.getMessageByCode(
          MessageCodeUtil.TEXTALERT_CHOOSE_TIMEZONE);
      return false;
    }
    if (teCurrency.isEmpty || !listCurrency.contains(teCurrency)) {
      errorLog = MessageUtil.getMessageByCode(
          MessageCodeUtil.TEXTALERT_CHOOSE_CURRENCY);
      return false;
    }

    final hotel = {
      'id_hotel': this.hotel?.id ?? '',
      'name': teName.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
      'phone': tePhone.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
      'email': teEmail.text,
      'street': teStreet.text.replaceAll(RegExp(r"\s\s+"), ' ').trim(),
      'city': teCity,
      'country': teCountry,
      'timezone': teTimezone,
      'currencyCode': teCurrency,
      'auto_export_items': autoExportItems
    };
    isLoading = true;
    notifyListeners();
    try {
      if (this.hotel != null) {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable('hotelmanager-editHotel');
        await callable(hotel);
        if (base64 != null) {
          await FirebaseStorage.instance
              .ref('img_hotels/${this.hotel!.id!}')
              .putData(base64!);
        }
        // Call update hotel to get information hotel after update
        GeneralManager.updateHotel(this.hotel!.id!);
      } else {
        if (base64 == null) {
          isLoading = false;
          errorLog = MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_IMAGE);
          return false;
        }
        HttpsCallable callable = FirebaseFunctions.instance
            .httpsCallable('hotelmanager-createHotel');
        final result = await callable(hotel);
        await FirebaseStorage.instance
            .ref('img_hotels/${result.data}')
            .putBlob(base64);
      }
    } on FirebaseFunctionsException catch (e) {
      errorLog = MessageUtil.getMessageByCode(e.message);
      isLoading = false;
      notifyListeners();
      return false;
    }
    isLoading = false;
    notifyListeners();
    return true;
  }

  List<HotelItem> checkDefaultWarehouseForItem() {
    List<HotelItem> result = [];
    if (autoExportItems != HotelAutoExportItemsStatus.NO) {
      for (var item in MinibarManager().getActiveItems()) {
        String warehouseId = item.defaultWarehouseId ?? '';
        if ((warehouseId == '' ||
                !WarehouseManager()
                    .getActiveWarehouseIds()
                    .contains(warehouseId)) &&
            (autoExportItems == HotelAutoExportItemsStatus.ALL_ITEMS ||
                (autoExportItems ==
                        HotelAutoExportItemsStatus.ONLY_SELECTED_ITEMS &&
                    item.isAutoExport!)) &&
            !result.contains(item)) {
          result.add(item);
        }
      }
      for (var item in RestaurantItemManager().getActiveItems()) {
        String warehouseId = item.defaultWarehouseId ?? '';
        if ((warehouseId == '' ||
                !WarehouseManager()
                    .getActiveWarehouseIds()
                    .contains(warehouseId)) &&
            (autoExportItems == HotelAutoExportItemsStatus.ALL_ITEMS ||
                (autoExportItems ==
                        HotelAutoExportItemsStatus.ONLY_SELECTED_ITEMS &&
                    item.isAutoExport!)) &&
            !result.contains(item)) {
          result.add(item);
        }
      }
    }
    return result;
  }

  Future<void> showItemDialog(BuildContext context, HotelItem item) async {
    isLoadingInvalidItem = true;
    notifyListeners();
    await showDialog(
      context: context,
      builder: (context) => MinibarHotelServiceDialog(item: item),
    );
    isLoadingInvalidItem = false;
    notifyListeners();
  }
}
