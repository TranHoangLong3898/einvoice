import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../constants.dart';
import '../../../modal/booking.dart';
import '../../../ui/component/management/bikerentalsuppliermanagementform.dart';
import '../../../ui/component/management/servicesuppliermanagementform.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';

class SupplierManagementDialog extends StatelessWidget {
  final Booking? booking;

  const SupplierManagementDialog({Key? key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = 1000;
    }

    return Dialog(
      child: SizedBox(
        width: width,
        height: height,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_SERVICE_SUPPLIER),
                      child: const Tab(icon: Icon(Icons.store))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_BIKE_RENTAL_SUPPLIER),
                      child: const Tab(icon: Icon(Icons.motorcycle))),
                ],
              ),
              title: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.SIDEBAR_SUPPLIER_MANAGEMENT)),
            ),
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                ServiceSupplierManagementForm(),
                BikeRentalSupplierManagementForm()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
