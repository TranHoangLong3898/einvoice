import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/controller/overduebookingcontroller.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/modal/activity.dart';
import 'package:ihotel/modal/service/bikerental.dart';
import 'package:ihotel/modal/service/deposit.dart';
import 'package:ihotel/modal/service/extraguest.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/laundry.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/modal/service/service.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/activitiesdialog.dart';
import 'package:ihotel/ui/component/booking/adddepositdialog.dart';
import 'package:ihotel/ui/component/booking_group/add_group_dialog.dart';
import 'package:ihotel/ui/component/report/guest_report_dialog.dart';
import 'package:ihotel/ui/component/report/revenue_by_date_report.dart';
import 'package:ihotel/ui/component/service/bikerentalinvoiceform.dart';
import 'package:ihotel/ui/component/service/electricitywaterform.dart';
import 'package:ihotel/ui/component/service/extraguestform.dart';
import 'package:ihotel/ui/component/service/extrahourform.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/laundryform.dart';
import 'package:ihotel/ui/component/service/minibarform.dart';
import 'package:ihotel/ui/component/service/othersform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutrondeletedalert.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../controller/currentbookingcontroller.dart';
import '../../controller/showallotmentcontroller.dart';
import '../../manager/usermanager.dart';
import '../../modal/booking.dart';
import '../../modal/service/minibar.dart';
import '../../ui/component/booking/bookingdialog.dart';
import '../../ui/component/report/newbookingreport.dart';
import '../../ui/component/searchdialog.dart';
import '../../ui/grid/cell.dart';
import '../../ui/grid/row.dart';
import '../../ui/page/userdrawer.dart';
import '../../util/contextmenuutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../component/booking/checkoutdialog.dart';
import '../component/booking_group/groupdialog.dart';
import '../component/report/cancelbookingreport.dart';
import '../component/report/noshowbookingreport.dart';
import '../component/report/revenuereportdialog.dart';
import '../component/report/servicereportdialog.dart';
import '../grid/statusgrid.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  CurrentBookingsController controller = CurrentBookingsController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OverdueBookingController? overdueBookingController;
  late ScrollController scrollController;

  @override
  void initState() {
    controller.init();
    ActivityController().getActivitiesFromCloud(false);
    overdueBookingController ??= OverdueBookingController();
    overdueBookingController!.getOverdueBookingsFromCloud();
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    controller.cancelStream();
    overdueBookingController?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      drawer: const UserDrawer(),
      floatingActionButton: const AddBookingButton(),
      body: Scrollbar(
        thumbVisibility: false,
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: ChangeNotifierProvider<CurrentBookingsController>.value(
            value: controller,
            child: Consumer<CurrentBookingsController>(
              builder: (_, controller, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Pagination + 7 columns of dates + date picker
                  DateRow(controller: controller),
                  //List of rooms and bookings
                  Expanded(
                    child: StatusPageCoreContent(
                        controller: controller, scaffoldKey: _scaffoldKey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //AppBar on the top of screen, includes these buttons: housekeeping_page, report, add_group, search
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    List<Widget> widgets = [];

    ///SHOW_ALLOTMENT
    if (UserManager
        .canSeeStatusPageNotPartnerAndApproverWithinternalPartner()) {
      widgets.add(ChangeNotifierProvider.value(
        value: ShowAllotmentController(),
        child: Consumer<ShowAllotmentController>(
          builder: (context, controller, child) => IconButton(
            iconSize: 18,
            icon: Icon(
                GeneralManager.showAllotment
                    ? FontAwesomeIcons.eye
                    : FontAwesomeIcons.eyeSlash,
                color: GeneralManager.showAllotment
                    ? ColorManagement.white
                    : ColorManagement.redColor),
            tooltip:
                UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SHOW_ALLOTMENT),
            onPressed: () async {
              controller.onChange(controller.value);
              await controller.save().then((value) => controller.rebuild());
            },
          ),
        ),
      ));
      //overdue booking notification
      widgets.add(ChangeNotifierProvider<OverdueBookingController>.value(
        value: overdueBookingController!,
        child: Consumer<OverdueBookingController>(
          builder: (_, timerController, __) {
            return timerController.overdueBookings.isEmpty
                ? const SizedBox()
                : PopupMenuButton<dynamic>(
                    color: ColorManagement.mainBackground,
                    icon: const FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      color: ColorManagement.redColor,
                      size: 20,
                    ),
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_OVERDUE_ALERT),
                    itemBuilder: (context) {
                      List<PopupMenuEntry<dynamic>> listItem = [];
                      listItem = timerController.overdueBookings.map((booking) {
                        return PopupMenuItem<dynamic>(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            value: booking,
                            child: Container(
                                width: double.maxFinite,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                                          vertical: SizeManagement.rowSpacing),
                                      alignment: Alignment.topLeft,
                                      height: 55,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8)),
                                      child: NeutronTextContent(
                                        message: MessageUtil.getMessageByCode(
                                            booking['type'] == 'overdue-checkin'
                                                ? MessageCodeUtil
                                                    .BOOKING_OVERDUE_TO_CHECKIN
                                                : MessageCodeUtil
                                                    .BOOKING_OVERDUE_TO_CHECKOUT,
                                            [booking['name']]),
                                        textOverflow: TextOverflow.clip,
                                      ),
                                    ),
                                    //click here
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: NeutronTextContent(
                                        color: ColorManagement.redColor,
                                        fontSize: 12,
                                        message: MessageUtil.getMessageByCode(booking[
                                                    'type'] ==
                                                'overdue-checkin'
                                            ? MessageCodeUtil
                                                .TEXTALERT_CLICK_HERE_TO_CHECKIN
                                            : MessageCodeUtil
                                                .TEXTALERT_CLICK_HERE_TO_CHECKOUT),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                )));
                      }).toList();
                      return listItem;
                    },
                    onSelected: (dynamicBooking) async {
                      if (dynamicBooking['sid'] != null) {
                        await BookingManager()
                            .getBasicBookingByID(dynamicBooking['id'])
                            .then((booking) => handleSelection(booking!));
                      } else {
                        await BookingManager()
                            .getBookingByID(dynamicBooking['id'])
                            .then((booking) => handleSelection(booking!));
                      }
                    },
                  );
          },
        ),
      ));
      //notification
      if (GeneralManager().canReadActivity) {
        widgets.add(ChangeNotifierProvider.value(
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
                                child: NeutronTextContent(
                                  message: activityController
                                      .activities![idActivity]!
                                      .decodeDesc(),
                                  tooltip: activityController
                                      .activities![idActivity]!
                                      .decodeDesc(),
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                  color: Colors.white,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                ),
                              ),
                              //created time
                              Align(
                                alignment: Alignment.centerRight,
                                child: NeutronTextContent(
                                  textAlign: TextAlign.end,
                                  fontSize: 12,
                                  message: DateUtil.getDifferenceFromNow(
                                      activityController
                                          .activities![idActivity]!.createdTime
                                          .toDate()),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                      showDialog(
                        context: context,
                        builder: (context) => FutureBuilder(
                            future: _getForm(
                                activityController.activities![selected]!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return snapshot.data ??
                                    const NeutronDeletedAlert();
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const NeutronWaiting(
                                    backgroundColor:
                                        ColorManagement.mainBackground);
                              }
                              return Container();
                            }),
                      );
                    }
                  },
                  onCanceled: () {
                    activityController.turnOffNotification();
                  },
                );
              },
            )));
      }
      if (UserManager.canSeeStatusPage()) {
        widgets.add(
          PopupMenuButton<String>(
            color: ColorManagement.mainBackground,
            icon: const Icon(
              Icons.table_rows,
              color: ColorManagement.white,
            ),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REPORT),
            itemBuilder: (context) => ContextMenuUtil().kReportContextMenu(),
            onSelected: (selected) async {
              if (selected == 'Booking') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const NewBookingReportDialog();
                  },
                );
              } else if (selected == 'Cancel Booking') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const CancelBookingsReport();
                  },
                );
              } else if (selected == 'No Show Booking') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const NoShowBookingsReport();
                  },
                );
              } else if (selected == 'Revenue') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const RevenueReportDialog();
                  },
                );
              } else if (selected == 'Service') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const ServiceReportDialog();
                  },
                );
              } else if (selected == 'Guest') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const GuestReportDialog();
                  },
                );
              } else if (selected == 'Revenue by date') {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return const RevenueByDateReportDialog();
                  },
                );
              }
            },
          ),
        );
      }
    }

    if (UserManager.canSeeStatusPage()) {
      widgets.add(
        IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_ADD_GROUP),
            onPressed: () async {
              await showDialog<String>(
                  context: context,
                  builder: (context) => const PageOneAddGroup());
            }),
      );
    }

    if (UserManager.canSeeStatusPageNotPartnerAndApprover()) {
      widgets.add(
        IconButton(
            icon: const Icon(Icons.search),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
            onPressed: () async {
              await showDialog<String>(
                  context: context, builder: (context) => SearchDialog());
            }),
      );
    }
    return AppBar(
      actions: widgets,
      leading: IconButton(
        tooltip: 'Menu',
        onPressed: () {
          // Scaffold.of(context).openDrawer();
          _scaffoldKey.currentState?.openDrawer();
        },
        icon: const Icon(Icons.menu),
      ),
    );
  }

  void handleSelection(Booking? booking) async {
    if (booking == null) return;
    if (booking.status == BookingStatus.booked) {
      if (booking.isVirtual!) {
        await showDialog<String>(
                builder: (ctx) => CheckOutDialog(
                      booking: booking,
                      basicBookings: booking,
                    ),
                context: context)
            .then((result) {
          if (result == null) return;
          MaterialUtil.showSnackBar(context, result);
        });
      } else {
        bool? confirmResult = await MaterialUtil.showConfirm(
            context,
            MessageUtil.getMessageByCode(
                MessageCodeUtil.CONFIRM_BOOKING_CHECKIN_AT_ROOM,
                [booking.name!, RoomManager().getNameRoomById(booking.room!)]));
        if (confirmResult == null || !confirmResult) return;
        await booking.checkIn().then((result) {
          MaterialUtil.showResult(
              context,
              MessageUtil.getMessageByCode(result,
                  [result.contains('room') ? booking.room! : booking.name!]));
        }).onError((error, stackTrace) {
          error;
        });
      }
    } else if (booking.status == BookingStatus.checkin) {
      if (booking.group!) {
        bool? isConfirmed = await MaterialUtil.showConfirm(
            context,
            MessageUtil.getMessageByCode(
                MessageCodeUtil.CONFIRM_BOOKING_CHECKOUT, [
              '${RoomManager().getNameRoomById(booking.room!)} - ${booking.name}'
            ]));
        if (isConfirmed != null && isConfirmed) {
          await booking.checkOut().then((result) {
            if (result == MessageCodeUtil.SUCCESS) {
              MaterialUtil.showSnackBar(
                  context,
                  MessageUtil.getMessageByCode(
                      MessageCodeUtil.BOOKING_CHECKOUT_SUCCESS,
                      [booking.name!]));
            } else {
              showDialog<String>(
                  builder: (ctx) => GroupDialog(
                        booking: booking,
                      ),
                  context: context);
              MaterialUtil.showAlert(context,
                  MessageUtil.getMessageByCode(result, [booking.name!]));
            }
          });
        }
      } else {
        await showDialog<String>(
                builder: (ctx) => CheckOutDialog(
                      booking: booking,
                      basicBookings: booking,
                    ),
                context: context)
            .then((result) {
          if (result == null) return;
          MaterialUtil.showSnackBar(context, result);
        });
      }
    }
  }

  Future<Widget?> _getForm(Activity activity) async {
    if (activity.type == 'service') {
      Service service = await ServiceManager()
          .getServiceByIDFromCloud(activity.bookingId, activity.id);
      final cat = service.cat;
      Widget childWiget;

      switch (cat) {
        case ServiceManager.MINIBAR_CAT:
          childWiget = MininbarInvoiceForm(service: (service as Minibar));
          break;
        case ServiceManager.EXTRA_GUEST_CAT:
          childWiget = ExtraGuestInvoiceForm(service: (service as ExtraGuest));
          break;
        case ServiceManager.LAUNDRY_CAT:
          childWiget = LaundryInvoiceForm(service: (service as Laundry));
          break;
        case ServiceManager.BIKE_RENTAL_CAT:
          childWiget = BikeRentalInvoiceForm(service: (service as BikeRental));
          break;
        case ServiceManager.OTHER_CAT:
          childWiget = OtherInvoiceForm(service: (service as Other));
          break;
        case ServiceManager.OUTSIDE_RESTAURANT_CAT:
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
    if (activity.type == 'deposit') {
      Deposit? deposit = await BookingManager()
          .getDepositOfBookingByDepositId(activity.bookingId, activity.id);
      Booking? booking =
          await BookingManager().getBookingByID(activity.bookingId);
      if (deposit == null) return null;
      if (booking == null) return null;
      return AddDepositDialog(
        deposit: deposit,
        booking: booking,
      );
    }
    if (activity.type == 'booking') {
      Booking? booking;
      if (activity.sid.isNotEmpty) {
        if (activity.sid == activity.bookingId) {
          await BookingManager()
              .getBookingByID(activity.sid)
              .then((value) => {booking = value})
              .catchError((e) {
            booking = null;
            return e;
          });
        } else {
          await BookingManager()
              .getBasicBookingByID(activity.id)
              .then((value) => {booking = value})
              .catchError((e) {
            booking = null;
            return e;
          });
        }
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
        if (activity.bookingId == activity.sid) {
          return GroupDialog(booking: booking);
        } else {
          return BookingDialog(booking: booking);
        }
      }
    }
    if (activity.type == 'extra_hour' || activity.type == "electricity_water") {
      Booking? booking;
      if (activity.sid.isNotEmpty) {
        await BookingManager()
            .getBookingByID(activity.sid)
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
      if (activity.type == 'electricity_water') {
        return Dialog(
            backgroundColor: ColorManagement.mainBackground,
            child: SizedBox(
                width: kMobileWidth,
                child: ElectricityWaterForm(
                    booking: activity.sid.isNotEmpty
                        ? Booking.fromBookingParent(activity.id, booking!)
                        : booking,
                    isDisable: true)));
      } else {
        return Dialog(
            backgroundColor: ColorManagement.mainBackground,
            child: SizedBox(
                width: kMobileWidth,
                child: ExtraHourForm(
                    booking: activity.sid.isNotEmpty
                        ? Booking.fromBookingParent(activity.id, booking!)
                        : booking,
                    isDisable: true)));
      }
    }
    return null;
  }
}

class AddBookingButton extends StatelessWidget {
  const AddBookingButton({
    Key? key,
  }) : super(key: key);

// Add booking
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await showDialog<String>(
                builder: (ctx) => BookingDialog(
                      booking:
                          Booking.empty(sourceID: SourceManager.directSource),
                    ),
                context: context)
            .then((result) {
          if (result != null) {
            MaterialUtil.showSnackBar(context, result);
          }
        });
      },
      child: const Icon(Icons.add),
    );
  }
}

class StatusPageCoreContent extends StatelessWidget {
  const StatusPageCoreContent(
      {Key? key, required this.controller, required this.scaffoldKey})
      : super(key: key);

  final CurrentBookingsController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        children: [
          //Gridview displays rows corresponding with each room
          StatusGrid(controllerBooking: controller),
          //Filter the bookings which can display on screen
          ...controller.bookings
              .where((booking) {
                bool isCoordinateExist =
                    controller.getBookingCoordinate(booking) != null;
                if (GeneralManager.isFilterTaxDeclare) {
                  return isCoordinateExist && booking.isTaxDeclare!;
                }
                return isCoordinateExist;
              })
              .map((booking) => BookingCell(
                    coordinate: controller.getBookingCoordinate(booking)!,
                    booking: booking,
                    scaffoldContext: scaffoldKey.currentContext!,
                  ))
              .toList()
        ],
      ),
    );
  }
}
