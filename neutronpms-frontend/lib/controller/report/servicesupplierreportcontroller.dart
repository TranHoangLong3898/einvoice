import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/othermanager.dart';
import '../../manager/servicemanager.dart';
import '../../manager/suppliermanager.dart';
import '../../modal/service/other.dart';
import '../../modal/service/service.dart';
import '../../util/dateutil.dart';

class ServiceSupplierReportController extends ChangeNotifier {
  List<Other> services = [];
  List<Other> filterServices = [];
  DateTime startDate = DateUtil.to12h(Timestamp.now().toDate());
  DateTime endDate = DateUtil.to12h(Timestamp.now().toDate());
  String selectedSupplierName = 'all';
  String selectedStatus = 'all';

  ServiceSupplierReportController();

  Future<String> getServices() async {
    if (endDate.difference(startDate).inDays > 31) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.OVER_X_DAYS, ['31']);
    }
    services = await OtherManager()
        .getOtherServicesByDateRangeFromCloud(startDate, endDate);

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
      filterServices = services;
    } else {
      filterServices = services
          .where((service) =>
              service.supplierID ==
              SupplierManager().getSupplierIDByName(selectedSupplierName))
          .toList();
    }
    if (selectedStatus != 'all') {
      filterServices = filterServices
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
      filterServices.fold(0, (pre, service) => pre + service.total!);
}
