import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/component/management/bikemanagerment/bikebookingmangerment.dart';
import 'package:ihotel/ui/component/management/bikemanagerment/bikerentalmanagementdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class BikeRentalDialog extends StatefulWidget {
  const BikeRentalDialog({Key? key}) : super(key: key);

  @override
  State<BikeRentalDialog> createState() => _BikeRentalDialogState();
}

class _BikeRentalDialogState extends State<BikeRentalDialog> {
  @override
  Widget build(BuildContext context) {
    final isNotDesktop = !ResponsiveUtil.isDesktop(context);
    final double width = isNotDesktop ? kMobileWidth : kLargeWidth;
    const double height = kHeight;
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              title: !isNotDesktop
                  ? NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_BIKE_RENTAL_MANAGEMENT))
                  : null,
              backgroundColor: ColorManagement.mainBackground,
              bottom: TabBar(
                tabs: [
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_BIKE_RENTAL),
                      child: const Tab(
                          icon: Icon(Icons.pedal_bike_sharp, size: 20))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_BIKE_BOOKING),
                      child: const Tab(
                          icon: Icon(Icons.book_online_sharp, size: 20))),
                ],
              ),
              leading: isNotDesktop ? const Text('') : null,
              leadingWidth: isNotDesktop ? 0 : null,
            ),
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                BikeRentalManagement(),
                BikeBookingMangement(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
