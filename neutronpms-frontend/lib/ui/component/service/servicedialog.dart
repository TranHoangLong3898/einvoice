import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../constants.dart';
import '../../../modal/booking.dart';
import '../../../ui/component/service/bikerentalform.dart';
import '../../../ui/component/service/servicesummaryform.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import 'extraguestform.dart';
import 'laundryform.dart';
import 'minibarform.dart';
import 'othersform.dart';

class ServiceDialog extends StatelessWidget {
  final Booking booking;

  const ServiceDialog({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final bool isHideExtraGuest = booking.isVirtual!;
    final double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: DefaultTabController(
          length: isHideExtraGuest ? 7 : 8,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              backgroundColor: ColorManagement.mainBackground,
              bottom: TabBar(
                isScrollable: isMobile,
                tabs: [
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_STATISTIC),
                      child: const Tab(icon: Icon(Icons.calculate))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_MINIBAR),
                      child: const Tab(icon: Icon(Icons.emoji_food_beverage))),
                  Tooltip(
                      message:
                          '${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESTAURANT)} (${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_INSIDE_HOTEL)})',
                      child: const Tab(icon: Icon(Icons.restaurant))),
                  if (!isHideExtraGuest)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_EXTRA_GUEST),
                        child: const Tab(icon: Icon(Icons.local_hotel))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_LAUNDRY),
                      child:
                          const Tab(icon: Icon(Icons.local_laundry_service))),
                  Tooltip(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_BIKE_RENTAL),
                      child: const Tab(icon: Icon(Icons.directions_bike))),
                  Tooltip(
                      message:
                          UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_OTHER),
                      child: const Tab(icon: Icon(Icons.car_rental))),
                  Tooltip(
                      message:
                          '${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESTAURANT)} (${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_OUTSIDE_HOTEL)})',
                      child: const Tab(icon: Icon(Icons.restaurant_menu))),
                ],
              ),
              title: NeutronTextContent(
                  message: (booking.group! && booking.sID == booking.id)
                      ? UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_GROUP_SERVICE_SUMMARY)
                      : booking.name!),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ServiceSummaryForm(booking: booking),
                MinibarForm(booking: booking),
                InsideRestaurantForm(booking: booking),
                if (!isHideExtraGuest) ExtraGuestForm(booking: booking),
                LaundryForm(booking: booking),
                BikeRentalForm(booking: booking),
                OthersForm(booking: booking),
                OutsideRestaurantForm(booking: booking)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
