import 'package:ihotel/manager/configurationmanagement.dart';

class SupplierManager {
  static final SupplierManager _instance = SupplierManager._internal();
  factory SupplierManager() {
    return _instance;
  }

  List<dynamic> dataSuppliers = [];
  static String inhouseSupplier = 'inhouse';

  SupplierManager._internal();

  Future<void> update() async {
    dataSuppliers = ConfigurationManagement().suppliers;
  }

  List<String> getActiveSupplierNamesByService(String service) {
    try {
      return dataSuppliers
          .where((supplier) =>
              (supplier['services'] as List).contains(service) &&
              supplier['active'])
          .map((supplier) => supplier['name'].toString())
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<String> getSupplierNames() {
    try {
      return dataSuppliers
          .map((supplier) => supplier['name'].toString())
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<String> getActiveSupplierIDs(String service) {
    try {
      return dataSuppliers
          .where((supplier) =>
              (supplier['services'] as List).contains(service) &&
              supplier['active'])
          .map((supplier) => supplier['id'].toString())
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<String> getActiveSupplierNames() {
    return dataSuppliers
        .where((supplier) => supplier['active'])
        .map((supplier) => supplier['name'].toString())
        .toList();
  }

  String getFirstSupplierID(String service) {
    try {
      List<String> supplierIDs = getActiveSupplierIDs(service);
      return supplierIDs.contains(inhouseSupplier)
          ? inhouseSupplier
          : supplierIDs.first;
    } catch (e) {
      return '';
    }
  }

  String? getSupplierIDByName(String name) {
    try {
      return dataSuppliers
          .firstWhere((supplier) => supplier['name'] == name)['id']
          .toString();
    } catch (e) {
      return '';
    }
  }

  String getSupplierNameByID(String? id) {
    try {
      return dataSuppliers
          .firstWhere((supplier) => supplier['id'] == id)['name']
          .toString();
    } catch (e) {
      return '';
    }
  }
}
