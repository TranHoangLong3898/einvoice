import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/bikerentalmanager.dart';
import '../../manager/servicemanager.dart';
import '../../manager/suppliermanager.dart';
import '../../modal/service/bikerental.dart';
import '../../modal/service/service.dart';
import '../../util/dateutil.dart';

class BikeRentalSupplierReportController extends ChangeNotifier {
  List<BikeRental> bikeRentals = [];
  List<BikeRental> filterBikeRentals = [];

  DateTime startDate = DateUtil.to12h(Timestamp.now().toDate());
  DateTime endDate = DateUtil.to12h(Timestamp.now().toDate());
  String selectedSupplierName = 'all';
  String selectedStatus = 'all';

  BikeRentalSupplierReportController();

  Future<String> getServices() async {
    if (endDate.difference(startDate).inDays > 16) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.OVER_X_DAYS, ['16']);
    }
    bikeRentals = await BikeRentalManager()
        .getBikeRentalsByDateRangeFromCloud(startDate, endDate);

    filter();

    notifyListeners();

    return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  }

  void setStartDate(DateTime newStartDate) {
    newStartDate = DateUtil.to12h(newStartDate);
    if (DateUtil.equal(newStartDate, startDate)) return;
    if (newStartDate.compareTo(DateUtil.to12h(Timestamp.now().toDate())) > 0) {
      return;
    }

    startDate = newStartDate;

    if (endDate.compareTo(startDate) < 0) {
      endDate = startDate;
    }

    notifyListeners();
  }

  void setEndDate(DateTime newEndDate) {
    newEndDate = DateUtil.to12h(newEndDate);
    if (DateUtil.equal(newEndDate, endDate)) return;
    if (newEndDate.compareTo(DateUtil.to12h(Timestamp.now().toDate())) > 0) {
      return;
    }
    if (newEndDate.compareTo(startDate) < 0) return;

    endDate = newEndDate;

    notifyListeners();
  }

  void setSupplierName(String newSupplierName) {
    if (newSupplierName == selectedSupplierName) return;
    selectedSupplierName = newSupplierName;
    filter();
    notifyListeners();
  }

  void setStatus(String newStatus) {
    if (newStatus == selectedStatus) return;
    selectedStatus = newStatus;
    filter();
    notifyListeners();
  }

  void filter() {
    if (selectedSupplierName == 'all') {
      filterBikeRentals = bikeRentals;
    } else {
      filterBikeRentals = bikeRentals
          .where((service) =>
              service.supplierID ==
              SupplierManager().getSupplierIDByName(selectedSupplierName))
          .toList();
    }
    if (selectedStatus != 'all') {
      filterBikeRentals = filterBikeRentals
          .where((service) => service.status == selectedStatus)
          .toList();
    }
  }

  List<String> getSupplierNames() {
    List<String> suppliers = SupplierManager().getSupplierNames();
    suppliers.add('all');
    return suppliers;
  }

  List<String> getStatuses() {
    List<String> statuses = ServiceManager().getStatuses();
    statuses.add('all');
    return statuses;
  }

  Future<String?> updateServiceStatus(Service service, String status) async {
    if (service.status == status) return null;
    String result = await service.updateStatus(status);
    if (result == MessageCodeUtil.SUCCESS) {
      service.status = status;
      notifyListeners();
    }
    return MessageUtil.getMessageByCode(result);
  }

  num getTotal() =>
      filterBikeRentals.fold(0, (pre, service) => pre + service.total!);
}
