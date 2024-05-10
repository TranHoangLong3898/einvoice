import 'package:flutter/material.dart';
import 'package:ihotel/manager/bikerentalmanager.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/hotelservice/bikehotelservice.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

class BikeHotelServiceController extends ChangeNotifier {
  BikeHotelService? service;
  bool isInProgress = false;
  late bool isAddFeature;
  late TextEditingController teIdController;
  late TextEditingController tePriceController;

  List<String> supplierNames = SupplierManager()
      .getActiveSupplierNamesByService(ServiceManager.BIKE_RENTAL_CAT);

  BikeHotelServiceController(this.service) {
    if (service == null) {
      String defaultType = BikeRentalManager().configs!.keys.first;
      service = BikeHotelService(
          bikeType: defaultType,
          supplierId: SupplierManager()
              .getFirstSupplierID(ServiceManager.BIKE_RENTAL_CAT),
          price: BikeRentalManager().getDefaultPrice(defaultType));
      isAddFeature = true;
      teIdController = TextEditingController();
    } else {
      isAddFeature = false;
      teIdController = TextEditingController(text: service!.id!);
      String supplierNameOfService =
          SupplierManager().getSupplierNameByID(service!.supplierId!);
      if (!supplierNames.contains(supplierNameOfService)) {
        supplierNames.add(supplierNameOfService);
      }
    }
    tePriceController = TextEditingController(text: service!.price.toString());
  }

  void setBikeType(String value) {
    String newBikeType =
        value == MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_MANUAL)
            ? 'manual'
            : 'auto';
    if (service!.bikeType == newBikeType) return;
    service!.bikeType = newBikeType;
    tePriceController.text = NumberUtil.numberFormat
        .format(BikeRentalManager().getDefaultPrice(newBikeType));
    notifyListeners();
  }

  void setSupplier(String supplierName) {
    String idOfChosenSupplier =
        SupplierManager().getSupplierIDByName(supplierName)!;
    if (service!.supplierId == idOfChosenSupplier) return;
    service!.supplierId = idOfChosenSupplier;
    notifyListeners();
  }

  Future<String> updateBike() async {
    if (isInProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    service!.price = num.parse(tePriceController.text.replaceAll(',', ''));
    isInProgress = true;
    notifyListeners();
    String result;
    if (isAddFeature) {
      service!.id =
          teIdController.text.replaceAll(RegExp(r"\s\s+"), ' ').trim();
      result = await ConfigurationManagement.createBikeHotelService(service!)
          .then((value) => value);
    } else {
      result = await ConfigurationManagement.updateBikeHotelService(service!)
          .then((value) => value);
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }
}
