import 'package:flutter/material.dart';

import '../../controller/report/bookinglistcontroller.dart';
import '../../util/responsiveutil.dart';
import 'neutronbookingcardview.dart';
import 'neutronbookingtableview.dart';

class NeutronBookingList extends StatelessWidget {
  final BookingListController controller;

  const NeutronBookingList({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    return isMobile
        ? NeutronBookingCardView(controller: controller)
        : NeutronBookingTableView(controller: controller);
  }
}
