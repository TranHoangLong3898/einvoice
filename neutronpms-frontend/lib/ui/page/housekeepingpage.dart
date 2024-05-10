import 'package:flutter/material.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/modal/service/bikerental.dart';
import 'package:ihotel/modal/service/extraguest.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/laundry.dart';
import 'package:ihotel/modal/service/minibar.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/housekeeping/rooms_sorted_by_name.dart';
import 'package:ihotel/ui/component/housekeeping/rooms_sorted_by_roomtype.dart';
import 'package:ihotel/ui/component/housekeeping/rooms_sorted_by_status.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutron_selector.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondeletedalert.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controller/housekeeping/housekeepingcontroller.dart';
import '../../manager/bookingmanager.dart';
import '../../manager/generalmanager.dart';
import '../../manager/roommanager.dart';
import '../../manager/servicemanager.dart';
import '../../manager/usermanager.dart';
import '../../modal/activity.dart';
import '../../modal/booking.dart';
import '../../modal/service/deposit.dart';
import '../../modal/service/service.dart';
import '../../ui/component/housekeeping/nextweekchartdialog.dart';
import '../../ui/page/userdrawer.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/excelulti.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';
import '../component/activitiesdialog.dart';
import '../component/booking/adddepositdialog.dart';
import '../component/booking/bookingdialog.dart';
import '../component/service/bikerentalinvoiceform.dart';
import '../component/service/extraguestform.dart';
import '../component/service/extrahourform.dart';
import '../component/service/laundryform.dart';
import '../component/service/minibarform.dart';
import '../component/service/othersform.dart';
import '../component/service/outsiderestaurantform.dart';
import '../controls/neutrontextcontent.dart';

class HousekeepingPage extends StatefulWidget {
  const HousekeepingPage({Key? key}) : super(key: key);

  @override
  State<HousekeepingPage> createState() => _HousekeepingPageState();
}

class _HousekeepingPageState extends State<HousekeepingPage> {
  late HouseKeepingPageController controller;
  @override
  void initState() {
    ActivityController().getActivitiesFromCloud(true);
    controller = HouseKeepingPageController();
    super.initState();
  }

  @override
  void dispose() {
    controller.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: RoomManager()),
        ChangeNotifierProvider.value(value: controller)
      ],
      child: Consumer2<RoomManager, HouseKeepingPageController>(
        builder: (_, roomManager, controller, __) => Scaffold(
            appBar: _buildAppBar(context, roomManager, controller),
            drawer: const UserDrawer(),
            body: Builder(
              builder: (context) => Container(
                height: double.infinity,
                width: double.infinity,
                color: ColorManagement.lightMainBackground,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: buildChildBody(roomManager, controller)),
              ),
            )),
      ),
    );
  }

  Widget buildChildBody(
      RoomManager roomManager, HouseKeepingPageController controller) {
    Widget child = const SizedBox();
    switch (controller.sortType) {
      case RoomSortType.roomType:
        child = RoomsSortedByRoomType(
            controller: controller, roomManager: roomManager);
        break;
      case RoomSortType.status:
        child = RoomsSortedByStatus(
            controller: controller, roomManager: roomManager);
        break;
      default:
        child =
            RoomsSortedByName(controller: controller, roomManager: roomManager);
        break;
    }
    return child;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context,
      RoomManager roomManager, HouseKeepingPageController controller) {
    return AppBar(
      actions: [
        //export to execl
        IconButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          onPressed: () async {
            ExcelUlti.exportHouseKeeping(roomManager, controller);
          },
          icon: const Icon(Icons.file_present_rounded),
        ),
        //sort
        IconButton(
          onPressed: () async {
            int? newType = await showDialogChooseType();
            if (newType != null) controller.setSortType(newType);
          },
          icon: const Icon(Icons.filter_list_rounded),
        ),
        //notification
        if (GeneralManager().canReadActivity)
          ChangeNotifierProvider<ActivityController>.value(
              value: ActivityController(),
              child: Consumer<ActivityController>(
                builder: (_, activityController, __) {
                  return PopupMenuButton<String>(
                    color: ColorManagement.mainBackground,
                    icon: Badge(
                      smallSize: 12,
                      backgroundColor: ColorManagement.redColor,
                      isLabelVisible: activityController.isHaveNotification,
                      padding: const EdgeInsets.all(0),
                      child: const Icon(
                        Icons.notifications,
                        color: ColorManagement.white,
                      ),
                    ),
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_NOTIFICATION),
                    itemBuilder: (context) {
                      List<PopupMenuEntry<String>> listItem = [];
                      listItem = activityController.activities!.keys
                          .toList()
                          .sublist(
                              0,
                              activityController.activities!.length >= 20
                                  ? 20
                                  : activityController.activities!.length)
                          .map((idActivity) {
                        return PopupMenuItem<String>(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          value: idActivity,
                          child: Container(
                            width: double.maxFinite,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: ColorManagement.lightMainBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //description
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: SizeManagement
                                          .cardOutsideVerticalPadding),
                                  alignment: Alignment.topLeft,
                                  height: 55,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8)),
                                  child: Tooltip(
                                    message: activityController
                                        .activities![idActivity]!
                                        .decodeDesc(),
                                    child: Text(
                                      activityController
                                          .activities![idActivity]!
                                          .decodeDesc(),
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 14,
                                        fontFamily: FontManagement.fontFamily,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                //created time
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: NeutronTextContent(
                                        textAlign: TextAlign.end,
                                        fontSize: 12,
                                        message: DateUtil.getDifferenceFromNow(
                                            activityController
                                                .activities![idActivity]!
                                                .createdTime
                                                .toDate()),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList();
                      if (activityController.activities != null &&
                          activityController.activities!.isNotEmpty) {
                        listItem.add(PopupMenuItem<String>(
                          value: 'more',
                          child: Center(
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.NOTIFICATION_SEE_MORE))),
                        ));
                      } else {
                        listItem.add(PopupMenuItem<String>(
                          value: 'no-activity',
                          child: Center(
                              child: NeutronTextContent(
                                  message: MessageUtil.getMessageByCode(
                                      MessageCodeUtil.NO_DATA))),
                        ));
                      }
                      return listItem;
                    },
                    onSelected: (selected) {
                      activityController.turnOffNotification();
                      if (selected == 'no-activity') return;
                      if (selected == 'more') {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ActivitiesDialog(activityController);
                          },
                        );
                      } else {
                        if (UserManager.canSeeStatusPage()) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                  future: _getForm(activityController
                                      .activities![selected]!),
                                  builder: (context, snapshot) =>
                                      getWidgetByConnectionState(
                                          context, snapshot));
                            },
                          );
                        } else {
                          Activity activity =
                              activityController.activities![selected]!;
                          if (activity.type != 'service') return;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return FutureBuilder(
                                  future: _getForm(activity),
                                  builder: (context, snapshot) =>
                                      getWidgetByConnectionState(
                                          context, snapshot));
                            },
                          );
                        }
                      }
                    },
                    onCanceled: () {
                      activityController.turnOffNotification();
                    },
                  );
                },
              )),
        //chart
        if (UserManager.canSeeHouseKeepingPage())
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_NEXT_WEEK_CHART),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const NextWeekChartDialog(),
              );
            },
          ),
        //settig room
        PopupMenuButton(
            color: ColorManagement.lightMainBackground,
            offset: const Offset(-15, 25),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: "clean all",
                    textStyle: TextStyle(color: Colors.white),
                    mouseCursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        Icon(
                          Icons.done_all_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
                        Text("Clean All Vacant Overnight"),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: "vacant clean",
                    textStyle: const TextStyle(color: Colors.white),
                    mouseCursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Switch(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            activeColor: ColorManagement.greenColor,
                            value: controller.vacantOvernight,
                            onChanged: (bool value) async {
                              await controller
                                  .updateVacantOvernight(
                                      !controller.vacantOvernight)
                                  .then((result) {
                                if (result != MessageCodeUtil.SUCCESS) {
                                  MaterialUtil.showSnackBar(context, result);
                                  return;
                                }
                                Navigator.pop(context);
                                MaterialUtil.showSnackBar(
                                    context,
                                    MessageUtil.getMessageByCode(
                                        MessageCodeUtil.SUCCESS));
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding *
                                2),
                        const Text("Vacant Clean Overnight"),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) async {
              (value == "clean all")
                  ? await controller
                      .updateAllVacantOvernight(roomManager.rooms!)
                      .then((result) {
                      if (result != MessageCodeUtil.SUCCESS) {
                        MaterialUtil.showSnackBar(context, result);
                        return;
                      }
                      MaterialUtil.showSnackBar(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.SUCCESS));
                    })
                  : await controller
                      .updateVacantOvernight(!controller.vacantOvernight)
                      .then((result) {
                      if (result != MessageCodeUtil.SUCCESS) {
                        MaterialUtil.showSnackBar(context, result);
                        return;
                      }
                      MaterialUtil.showSnackBar(
                          context,
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.SUCCESS));
                    });
            },
            child: const Icon(Icons.miscellaneous_services_outlined)),
        //back to status-page
        if (UserManager.canSeeStatusPage())
          IconButton(
            icon: const Icon(Icons.home),
            tooltip:
                UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_STATUS_PAGE),
            onPressed: () => Navigator.pop(context),
          ),
      ],
    );
  }

  Future<Widget?> _getForm(Activity activity) async {
    if (activity.type == 'service') {
      Service? service;
      await ServiceManager()
          .getServiceByIDFromCloud(activity.bookingId, activity.id)
          .then((value) => {service = value})
          .catchError((error) {
        service = null;
        return error;
      });
      final cat = service!.cat;
      Widget childWiget;

      switch (cat) {
        case ServiceManager.MINIBAR_CAT:
          childWiget = MininbarInvoiceForm(service: (service as Minibar));
          break;
        case ServiceManager.EXTRA_GUEST_CAT:
          if (!UserManager.canSeeStatusPage()) {
            return buildForbiddenAlert();
          }
          childWiget = ExtraGuestInvoiceForm(service: (service as ExtraGuest));
          break;
        case ServiceManager.LAUNDRY_CAT:
          childWiget = LaundryInvoiceForm(service: (service as Laundry));
          break;
        case ServiceManager.BIKE_RENTAL_CAT:
          if (!UserManager.canSeeStatusPage()) {
            return buildForbiddenAlert();
          }
          childWiget = BikeRentalInvoiceForm(service: (service as BikeRental));
          break;
        case ServiceManager.OTHER_CAT:
          if (!UserManager.canSeeStatusPage()) {
            return buildForbiddenAlert();
          }
          childWiget = OtherInvoiceForm(service: (service as Other));
          break;
        case ServiceManager.OUTSIDE_RESTAURANT_CAT:
          if (!UserManager.canSeeStatusPage()) {
            return buildForbiddenAlert();
          }
          childWiget = RestaurantInvoiceForm(
              service: (service as OutsideRestaurantService), isMobile: true);
          break;
        case ServiceManager.INSIDE_RESTAURANT_CAT:
          childWiget = InsideRestaurantInvoiceForm(
              service: (service as InsideRestaurantService));
          break;
        default:
          childWiget = Container();
      }
      return Dialog(
          backgroundColor: ColorManagement.mainBackground,
          child: SizedBox(width: kMobileWidth, child: childWiget));
    }
    if (UserManager.canSeeStatusPage() && activity.type == 'deposit') {
      Deposit? deposit = await BookingManager()
          .getDepositOfBookingByDepositId(activity.bookingId, activity.id);
      Booking? booking =
          await BookingManager().getBookingByID(activity.bookingId);
      if (deposit == null) return null;
      if (booking == null) return null;
      return AddDepositDialog(deposit: deposit, booking: booking);
    }
    if (UserManager.canSeeStatusPage() &&
        (activity.type == 'booking' || activity.type == 'extra_hour')) {
      Booking? booking;
      if (activity.sid.isNotEmpty) {
        await BookingManager()
            .getBasicBookingByID(activity.id)
            .then((value) => {booking = value})
            .catchError((e) {
          booking = null;
          return e;
        });
      } else {
        await BookingManager()
            .getBookingByID(activity.id)
            .then((value) => {booking = value})
            .catchError((e) {
          booking = null;
          return e;
        });
      }

      if (booking == null) {
        return null;
      }
      if (activity.type == 'booking') {
        return BookingDialog(
          booking: booking,
        );
      } else {
        return Dialog(
            backgroundColor: ColorManagement.mainBackground,
            child: SizedBox(
                width: kMobileWidth,
                child: ExtraHourForm(booking: booking, isDisable: true)));
      }
    }
    return null;
  }

  Container buildForbiddenAlert() {
    return Container(
      height: kMobileWidth,
      color: ColorManagement.lightMainBackground,
      alignment: Alignment.center,
      child: Text(MessageUtil.getMessageByCode(MessageCodeUtil.FORBIDDEN),
          style: const TextStyle(
              color: ColorManagement.lightColorText,
              decoration: TextDecoration.none,
              fontSize: 14)),
    );
  }

  Widget getWidgetByConnectionState(
      BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data ?? const NeutronDeletedAlert();
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const NeutronWaiting(
          backgroundColor: ColorManagement.mainBackground);
    }
    return Container();
  }

  Future<dynamic> showDialogChooseType() async {
    int currentType = controller.sortType;
    return await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ColorManagement.mainBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: SizeManagement.topHeaderTextSpacing),
            NeutronTextHeader(
              message: UITitleUtil.getTitleByCode(UITitleCode.SORT_TYPE),
            ),
            const SizedBox(height: SizeManagement.topHeaderTextSpacing),
            NeutronSelector(
              itemPadding: const EdgeInsets.symmetric(horizontal: 16),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              onChanged: (index) => currentType = index,
              initIndex: currentType,
              items: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.type_specimen_outlined),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_NAME),
                      color: ColorManagement.mainColorText,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sentiment_satisfied),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_STATUS),
                      color: ColorManagement.mainColorText,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bedroom_parent_outlined),
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_ROOMTYPE),
                      color: ColorManagement.mainColorText,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
            SizedBox(
              width: kMobileWidth,
              child: NeutronButton(
                icon: Icons.save,
                onPressed: () {
                  Navigator.pop(context, currentType);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
