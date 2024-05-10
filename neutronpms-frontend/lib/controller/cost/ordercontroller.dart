import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';

import '../../manager/requestmanager.dart';
import '../../manager/suppliermanager.dart';
import '../../modal/order.dart';
import '../../modal/request.dart';
import '../../util/numberutil.dart';

class RequestItem {
  final Request? request;
  final TextEditingController tePrice = TextEditingController();

  RequestItem({this.request});
}

class OrderController extends ChangeNotifier {
  OrderSupplier? order;
  List<Request>? requests;
  List<RequestItem>? requestItems;
  final TextEditingController teDesc = TextEditingController();
  late String supplier;
  List<String> suppliers = [];

  bool inProgress = false;

  OrderController({this.order, this.requests}) {
    initialize();
  }

  void initialize() async {
    order ??= OrderSupplier(id: NumberUtil.getRandomID());
    requests ??= await RequestManager().getRequestsByOrderID(order!.id!);
    requestItems =
        requests!.map((request) => RequestItem(request: request)).toList();
    suppliers = SupplierManager().getSupplierNames();
    supplier = suppliers.isEmpty ? '' : suppliers.first;
    notifyListeners();
  }

  void disposeAllTextEditingControllers() {
    for (var requestItem in requestItems!) {
      requestItem.tePrice.dispose();
    }
  }

  Future<String> save() async {
    if (inProgress) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }

    for (var requestItem in requestItems!) {
      requestItem.request!.price = num.tryParse(requestItem.tePrice.text) ?? 0;
      requestItem.request!.orderID = order!.id;
    }
    order!.desc = teDesc.text;
    order!.supplier = supplier;

    final requests = requestItems!.map((e) => e.request).toList();
    inProgress = true;
    final result = await RequestManager().updateOrderToCloud(order!, requests);
    inProgress = false;
    return MessageUtil.getMessageByCode(result);
  }
}
