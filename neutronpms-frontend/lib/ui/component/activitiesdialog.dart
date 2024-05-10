import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/activitycontroller.dart';
import 'package:ihotel/manager/bookingmanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/activity.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/service/bikerental.dart';
import 'package:ihotel/modal/service/deposit.dart';
import 'package:ihotel/modal/service/extraguest.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/laundry.dart';
import 'package:ihotel/modal/service/minibar.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/modal/service/service.dart';
import 'package:ihotel/ui/component/booking/adddepositdialog.dart';
import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/component/service/bikerentalinvoiceform.dart';
import 'package:ihotel/ui/component/service/extraguestform.dart';
import 'package:ihotel/ui/component/service/extrahourform.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/laundryform.dart';
import 'package:ihotel/ui/component/service/minibarform.dart';
import 'package:ihotel/ui/component/service/othersform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../controls/neutrondeletedalert.dart';

class ActivitiesDialog extends StatefulWidget {
  final ActivityController controller;

  const ActivitiesDialog(this.controller, {Key? key}) : super(key: key);

  @override
  State<ActivitiesDialog> createState() => _ActivitiesDialogState();
}

class _ActivitiesDialogState extends State<ActivitiesDialog> {
  late ActivityController controller;

  @override
  void initState() {
    controller = widget.controller..pageIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : 1000;
    const height = kHeight;

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: ColorManagement.mainBackground,
            child: ChangeNotifierProvider<ActivityController>.value(
                value: controller,
                child: Consumer<ActivityController>(
                    child: const NeutronWaiting(),
                    builder: (_, controller, child) {
                      return Scaffold(
                          backgroundColor: ColorManagement.mainBackground,
                          appBar: AppBar(
                            title: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.SIDEBAR_NOTIFICATION)),
                            backgroundColor: ColorManagement.mainBackground,
                            actions: const [],
                          ),
                          body: controller.isLoading
                              ? child
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //title
                                    if (!isMobile) buildTitleInPC(),
                                    //list activities
                                    Expanded(
                                      child: ListView(
                                          children: isMobile
                                              ? buildContentInMobile()
                                              : buildContentInPc()),
                                    ),
                                    //pagination
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                controller.firstPage();
                                              },
                                              icon: const Icon(
                                                  Icons.skip_previous)),
                                          IconButton(
                                              onPressed: () {
                                                controller.previousPage();
                                              },
                                              icon: const Icon(
                                                  Icons.navigate_before_sharp)),
                                          IconButton(
                                              onPressed: () {
                                                controller.nextPage();
                                              },
                                              icon: const Icon(
                                                  Icons.navigate_next_sharp)),
                                          IconButton(
                                              onPressed: () {
                                                controller.lastPage();
                                              },
                                              icon:
                                                  const Icon(Icons.skip_next)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ));
                    }))));
  }

  Container buildTitleInPC() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: 50,
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ID),
            ),
          ),
          Expanded(
            flex: 2,
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
            ),
          ),
          SizedBox(
            width: 70,
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_BOOKING_ID),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildContentInPc() {
    return controller.activities!.keys
        .toList()
        .sublist(controller.startIndex, controller.endIndex)
        .map((idActivity) {
      String creator = controller.activities![idActivity]!.email == emailAdmin
          ? MessageUtil.getMessageByCode(MessageCodeUtil.JOB_ADMIN)
          : controller.activities![idActivity]!.email;
      return InkWell(
        onTap: () async {
          if (!UserManager.canSeeStatusPage() &&
              controller.activities![idActivity]!.type != 'service') {
            return;
          }
          showDialog(
            context: context,
            builder: (context) {
              return FutureBuilder<Widget?>(
                  future: _getForm(controller.activities![idActivity]!),
                  builder: (context, snapshot) =>
                      getWidgetByConnectionState(context, snapshot));
            },
          );
        },
        child: Container(
          height: SizeManagement.cardHeight,
          margin: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardOutsideHorizontalPadding,
              vertical: SizeManagement.cardOutsideVerticalPadding),
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          child: Row(
            children: [
              Container(
                width: 100,
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding, right: 8),
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthHourMinuteString(widget
                        .controller.activities![idActivity]!.createdTime
                        .toDate())),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: NeutronTextContent(
                    message: controller.activities![idActivity]!.id),
              )),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: NeutronTextContent(
                        tooltip:
                            controller.activities![idActivity]!.decodeDesc(),
                        message:
                            controller.activities![idActivity]!.decodeDesc()),
                  )),
              Container(
                width: 70,
                padding: const EdgeInsets.only(right: 8.0),
                child: NeutronTextContent(
                  message: controller.activities![idActivity]!.type,
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: NeutronTextContent(
                    message: controller.activities![idActivity]!.bookingId),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: NeutronTextContent(tooltip: creator, message: creator),
              )),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> buildContentInMobile() {
    return controller.activities!.keys
        .toList()
        .sublist(controller.startIndex, controller.endIndex)
        .map((idActivity) {
      String creator = controller.activities![idActivity]!.email == emailAdmin
          ? MessageUtil.getMessageByCode(MessageCodeUtil.JOB_ADMIN)
          : controller.activities![idActivity]!.email;
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 8),
          title: Row(
            children: [
              SizedBox(
                width: 50,
                child: NeutronTextContent(
                    textOverflow: TextOverflow.clip,
                    message: DateUtil.dateToDayMonthHourMinuteString(controller
                        .activities![idActivity]!.createdTime
                        .toDate())),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: NeutronTextContent(
                      message:
                          controller.activities![idActivity]!.decodeDesc()),
                ),
              ),
            ],
          ),
          children: [
            InkWell(
                onTap: () async {
                  if (!UserManager.canSeeStatusPage() &&
                      controller.activities![idActivity]!.type != 'service') {
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      return FutureBuilder(
                          future: _getForm(controller.activities![idActivity]!),
                          builder: (context, snapshot) =>
                              getWidgetByConnectionState(context, snapshot));
                    },
                  );
                },
                child: DataTable(
                  horizontalMargin: 8,
                  columnSpacing: 8,
                  headingRowHeight: 0,
                  columns: [
                    DataColumn(label: Container()),
                    DataColumn(label: Container())
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATE),
                      )),
                      DataCell(NeutronTextContent(
                        message: DateUtil.dateToDayMonthHourMinuteString(
                            controller.activities![idActivity]!.createdTime
                                .toDate()),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ID),
                      )),
                      DataCell(NeutronTextContent(
                        textOverflow: TextOverflow.ellipsis,
                        tooltip: controller.activities![idActivity]!.id,
                        message: controller.activities![idActivity]!.id,
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(
                        NeutronTextContent(
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                        ),
                      ),
                      DataCell(NeutronTextContent(
                        textOverflow: TextOverflow.ellipsis,
                        tooltip:
                            controller.activities![idActivity]!.decodeDesc(),
                        message:
                            controller.activities![idActivity]!.decodeDesc(),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_TYPE),
                      )),
                      DataCell(NeutronTextContent(
                        message: controller.activities![idActivity]!.type,
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_BOOKING_ID),
                      )),
                      DataCell(NeutronTextContent(
                        message: controller.activities![idActivity]!.bookingId,
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(NeutronTextContent(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CREATOR),
                      )),
                      DataCell(NeutronTextContent(
                        tooltip: creator,
                        message: creator,
                      ))
                    ]),
                  ],
                ))
          ],
        ),
      );
    }).toList();
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
    if (activity.type == 'booking' || activity.type == 'extra_hour') {
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

  Widget getWidgetByConnectionState(
      BuildContext context, AsyncSnapshot<Widget?> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data ?? const NeutronDeletedAlert();
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const NeutronWaiting();
    }
    return Container();
  }
}
