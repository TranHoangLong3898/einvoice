import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/service/updateservicecontroller.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../../manager/othermanager.dart';
import '../../../manager/suppliermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/other.dart';
import '../../../util/dateutil.dart';
import 'addservicecontroller.dart';

class OtherController extends ChangeNotifier {
  List<Other> others = [];
  final Booking booking;
  OtherController(this.booking) {
    update();
  }

  void update() async {
    others = await booking.getOthers();
    notifyListeners();
  }
}

class AddOtherController extends AddServiceController {
  final Booking? booking;
  late String serviceID;
  late String supplierID;
  late TextEditingController teDesc;
  late TextEditingController teTotal;
  late TextEditingController teSaler;
  String emailSalerOld = '';
  late DateTime date;
  List<String> otherServiceNames = [];
  bool adding = false;

  AddOtherController(this.booking) {
    otherServiceNames = OtherManager().getActiveOtherServiceNames();
    serviceID = OtherManager().getFirstActiveOtherServiceID();
    supplierID = SupplierManager().getFirstSupplierID(serviceID);
    teDesc = TextEditingController();
    teTotal = TextEditingController();
    teSaler = TextEditingController(text: "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
    final now = DateUtil.to12h(Timestamp.now().toDate());
    if (now.compareTo(booking!.inDate!) < 0) {
      date = booking!.inDate!;
    } else if (now.compareTo(booking!.outDate!) > 0) {
      date = booking!.outDate!;
    } else {
      date = now;
    }
  }

  void disposeTextEditingControllers() {
    teDesc.dispose();
    teTotal.dispose();
  }

  void setDate(DateTime newDate) {
    newDate = DateUtil.to12h(newDate);
    if (DateUtil.equal(newDate, date)) return;
    if (newDate.compareTo(booking!.outDate!) > 0) return;

    if (newDate.compareTo(booking!.inDate!) < 0) return;

    date = newDate;

    notifyListeners();
  }

  void setService(String newServiceID) {
    if (newServiceID == serviceID) return;

    serviceID = newServiceID;

    supplierID = SupplierManager().getFirstSupplierID(serviceID);
    notifyListeners();
  }

  void setSupplier(String newSupplierID) {
    if (newSupplierID == supplierID) return;

    supplierID = newSupplierID;
    notifyListeners();
  }

  Future<String> addOther() async {
    final total = num.tryParse(teTotal.text.replaceAll(',', ''));

    if (teSaler.text.isNotEmpty && !isCheckEmail) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }

    if (total == null || total < 0) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_POSITIVE_TOTAL);
    }

    Other other = Other(
        desc: teDesc.text,
        total: total,
        supplierID: supplierID,
        type: serviceID,
        date: Timestamp.fromDate(date),
        name: booking!.name,
        room: booking!.room,
        time: Timestamp.now(),
        saler: teSaler.text);

    if (adding) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    adding = true;
    notifyListeners();
    String result = await booking!
        .addService(other)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    adding = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class UpdateOtherController extends UpdateServiceController {
  final Booking? booking;
  final Other? service;
  Map<String, TextEditingController> teOtherControllers = {};
  Map<String, dynamic> oldItems = {};
  //name of service.type, name of service.supplier
  late String type, supplier;
  //all other-service
  List<String> listService = [];
  //all other-supplier
  List<String> listSupplier = [];
  late TextEditingController teSaler;
  String emailSalerOld = '';

  UpdateOtherController({this.booking, this.service}) {
    if (booking != null) {
      type = OtherManager().getServiceNameByID(service!.type!);
      supplier = SupplierManager().getSupplierNameByID(service!.supplierID!);
      getServiceItems();
      saveOldItems();
      teOtherControllers['description'] =
          TextEditingController(text: service!.desc);
      teOtherControllers['price'] =
          TextEditingController(text: service!.total.toString());
    }
    teSaler = TextEditingController(text: service!.saler ?? "");
    emailSalerOld = teSaler.text;
    if (emailSalerOld.isNotEmpty && emailSalerOld == teSaler.text) {
      isCheckEmail = true;
    }
  }

  void disposeTextEditingControllers() {
    teOtherControllers['description']!.dispose();
    teOtherControllers['price']!.dispose();
  }

  @override
  List<String> getServiceItems() {
    listService.addAll(OtherManager().getActiveOtherServiceNames());
    if (!listService.contains(type)) {
      listService.add(type);
    }
    listSupplier =
        SupplierManager().getActiveSupplierNamesByService(service!.type!);
    if (!listSupplier.contains(supplier)) {
      listSupplier.add(supplier);
    }
    return [];
  }

  @override
  bool isServiceItemsChanged() {
    if (oldItems['type'] != type ||
        emailSalerOld != teSaler.text ||
        oldItems['date'] != service!.date ||
        oldItems['description'] != service!.desc ||
        oldItems['supplier'] != supplier ||
        oldItems['price'] != service!.total) return true;
    return false;
  }

  @override
  void saveOldItems() {
    oldItems['type'] = type;
    oldItems['date'] = service!.date;
    oldItems['description'] = service!.desc;
    oldItems['supplier'] = supplier;
    oldItems['price'] = service!.total;
  }

  void setDate(DateTime newDate) {
    newDate = DateUtil.to12h(newDate);
    if (DateUtil.equal(newDate, service!.date!.toDate())) return;
    if (newDate.compareTo(booking!.outDate!) > 0) return;
    if (newDate.compareTo(booking!.inDate!) < 0) return;
    service!.date = Timestamp.fromDate(newDate);
    notifyListeners();
  }

  void setType(String newType) {
    if (newType == type) return;
    type = newType;
    listSupplier = SupplierManager().getActiveSupplierNamesByService(
        OtherManager().getServiceIDByName(type));
    supplier = listSupplier.first;
    notifyListeners();
  }

  void setSupplier(String newSupplier) {
    if (newSupplier == supplier) return;
    supplier = newSupplier;
    notifyListeners();
  }

  @override
  void updateService() {
    service!.total =
        num.tryParse(teOtherControllers['price']!.text.replaceAll(',', ''))!;
    service!.desc = teOtherControllers['description']!.text;
    service!.type = OtherManager().getServiceIDByName(type);
    service!.supplierID = SupplierManager().getSupplierIDByName(supplier);
    notifyListeners();
  }

  @override
  Future<String> updateServiceToDatabase() async {
    if (teSaler.text.isNotEmpty && !isCheckEmail!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_SALER);
    }
    if (!isServiceItemsChanged()) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }
    if (updating!) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    setProgressUpdating();
    service!.saler = teSaler.text;
    String result = await booking!
        .updateService(service!)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    //result == '' means updating successfully. Then update oldItems = current minibarItems
    if (result == MessageCodeUtil.SUCCESS) {
      saveOldItems();
    } else {
      type = oldItems['type'];
      service!.date = oldItems['date'];
      service!.desc = oldItems['description'];
      supplier = oldItems['supplier'];
      service!.total = oldItems['price'];
      service!.type = OtherManager().getServiceIDByName(type);
      service!.supplierID = SupplierManager().getSupplierIDByName(supplier);
      service!.saler = emailSalerOld;
    }
    setProgressDone();
    return MessageUtil.getMessageByCode(result);
  }
}
