import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/roles.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/ui/component/service/hotelservice/electricitywaterhotelservicedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/listbikehotelservicedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/listlaundrieshotelservicedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/listminibarhotelservice.dart';
import 'package:ihotel/ui/component/service/hotelservice/listotherhotelservicedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/listrestauranthotelservice.dart';
import 'package:ihotel/ui/component/service/hotelservice/roomextrahotelservicedialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class HotelServiceDialog extends StatelessWidget {
  final int? indexSelectedTab;

  const HotelServiceDialog({Key? key, this.indexSelectedTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: DefaultTabController(
          length: tabLength,
          initialIndex: indexSelectedTab ?? 0,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: ColorManagement.mainBackground,
            appBar: AppBar(
              title: NeutronTextContent(
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SERVICE)),
              backgroundColor: ColorManagement.mainBackground,
              bottom: TabBar(
                tabs: [
                  if (showMinibarTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_MINIBAR),
                        child:
                            const Tab(icon: Icon(Icons.emoji_food_beverage))),
                  if (showRestaurantTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_RESTAURANT),
                        child: const Tab(icon: Icon(Icons.restaurant))),
                  if (showLaundryTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_LAUNDRY),
                        child:
                            const Tab(icon: Icon(Icons.local_laundry_service))),
                  if (showExtraGuestTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_EXTRA_GUEST),
                        child: const Tab(icon: Icon(Icons.local_hotel))),
                  if (showBikeTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_BIKE_RENTAL),
                        child: const Tab(icon: Icon(Icons.pedal_bike))),
                  if (showOtherTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_OTHER),
                        child: const Tab(
                            icon: Icon(Icons.miscellaneous_services))),
                  if (showElectricityWaterTab)
                    Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_ELECTRICITY_WATER),
                        child:
                            const Tab(icon: Icon(Icons.electrical_services))),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (showMinibarTab) const ListMinibarHotelService(),
                if (showRestaurantTab) const ListRestaurantHotelService(),
                if (showLaundryTab) const ListLaundriesHotelService(),
                if (showExtraGuestTab) const RoomExtraHotelServiceDialog(),
                if (showBikeTab) const ListBikeHotelService(),
                if (showOtherTab) const ListOtherHotelServiceDialog(),
                if (showElectricityWaterTab)
                  const ElectricityWaterHotelServiceDialog()
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get showMinibarTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.owner);

  bool get showRestaurantTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.owner);

  bool get showLaundryTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.owner);

  bool get showExtraGuestTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.owner);

  bool get showBikeTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.owner);

  bool get showOtherTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.accountant) ||
      UserManager.role!.contains(Roles.owner);

  bool get showElectricityWaterTab =>
      UserManager.role!.contains(Roles.admin) ||
      UserManager.role!.contains(Roles.manager) ||
      UserManager.role!.contains(Roles.support) ||
      UserManager.role!.contains(Roles.accountant) ||
      UserManager.role!.contains(Roles.owner);

  int get tabLength {
    int length = 0;
    if (showMinibarTab) length++;
    if (showRestaurantTab) length++;
    if (showLaundryTab) length++;
    if (showExtraGuestTab) length++;
    if (showBikeTab) length++;
    if (showOtherTab) length++;
    if (showElectricityWaterTab) length++;
    return length;
  }
}
