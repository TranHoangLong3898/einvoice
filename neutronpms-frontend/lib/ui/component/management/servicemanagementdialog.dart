import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/service/bikerental.dart';
import 'package:ihotel/modal/service/extraguest.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/laundry.dart';
import 'package:ihotel/modal/service/minibar.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/ui/component/service/insiderestaurantform.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/management/servicemanagementcontroller.dart';
import '../../../manager/servicemanager.dart';
import '../../../manager/usermanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/service.dart';
import '../../../ui/component/service/bikerentalinvoiceform.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutronwaiting.dart';
import '../service/extraguestform.dart';
import '../service/laundryform.dart';
import '../service/minibarform.dart';
import '../service/othersform.dart';

class ServiceManagementDialog extends StatefulWidget {
  const ServiceManagementDialog({Key? key}) : super(key: key);

  @override
  State<ServiceManagementDialog> createState() =>
      _ServiceManagementDialogState();
}

class _ServiceManagementDialogState extends State<ServiceManagementDialog> {
  ServiceManagementController? controller;

  @override
  void initState() {
    controller ??= ServiceManagementController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : 1000;
    const height = kHeight;

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: ChangeNotifierProvider<ServiceManagementController>.value(
              value: controller!,
              child: Consumer<ServiceManagementController>(
                child: const Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                ),
                builder: (_, controller, child) {
                  final children = controller.services.isEmpty
                      ? Center(
                          child: NeutronTextContent(
                              message: MessageUtil.getMessageByCode(
                                  MessageCodeUtil.NO_DATA)),
                        )
                      : ListView(
                          children: isMobile
                              ? buildContentInMobile()
                              : buildContentInPC());

                  return Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      appBar: buildAppBar(isMobile),
                      body: Stack(fit: StackFit.expand, children: [
                        Container(
                          width: width,
                          height: height,
                          margin: const EdgeInsets.only(bottom: 65),
                          child: Column(
                            children: [
                              isMobile
                                  ? buildTitleInMobile()
                                  : buildTitleInPC(),
                              Expanded(
                                child:
                                    controller.isLoading! ? child! : children,
                              ),
                              const SizedBox(height: SizeManagement.rowSpacing),
                              if (!(controller.totalMoneyServiceOfCurrentPage ==
                                  0))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    NeutronTextTitle(
                                      fontSize: 14,
                                      message:
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} :',
                                    ),
                                    const SizedBox(
                                        width: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    Text(
                                      (isMobile
                                              ? NumberUtil.moneyFormat
                                              : NumberUtil.numberFormat)
                                          .format(controller
                                              .totalMoneyServiceOfCurrentPage),
                                      style: NeutronTextStyle.totalNumber,
                                    ),
                                    SizedBox(
                                        width: (isMobile ? 45 : 165) +
                                            SizeManagement
                                                .cardOutsideHorizontalPadding),
                                  ],
                                ),
                              //pagination
                              SizedBox(
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          controller
                                              .getServicesReportFirstPage();
                                        },
                                        icon: const Icon(Icons.skip_previous)),
                                    IconButton(
                                        onPressed: () {
                                          controller
                                              .getServicesReportPreviousPage();
                                        },
                                        icon: const Icon(
                                            Icons.navigate_before_sharp)),
                                    IconButton(
                                        onPressed: () {
                                          controller
                                              .getServicesReportNextPage();
                                        },
                                        icon: const Icon(
                                            Icons.navigate_next_sharp)),
                                    IconButton(
                                        onPressed: () {
                                          controller
                                              .getServicesReportLastPage();
                                        },
                                        icon: const Icon(Icons.skip_next)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: NeutronButtonText(
                                text:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} ${NumberUtil.numberFormat.format(controller.totalMoneyService)}")),
                      ]));
                },
              ),
            )));
  }

  Container buildTitleInPC() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: 50,
      child: Row(
        children: [
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT),
            ),
          ),
          Expanded(
            child: NeutronDropDown(
              isPadding: false,
              textStyle: NeutronTextStyle.title,
              value: controller!.selectedCat,
              onChanged: (String newCat) async {
                controller!.setCat(newCat);
              },
              items: controller!.cats,
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
                textAlign: TextAlign.end,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT)),
          ),
          const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          Expanded(
            child: NeutronDropDown(
              textStyle: NeutronTextStyle.title,
              value: controller!.selectedStatus,
              onChanged: (String newStatus) async {
                controller!.setStatus(newStatus);
              },
              items: controller!.statues,
            ),
          ),
          if (UserManager.canSeeStatusPage()) const SizedBox(width: 40)
        ],
      ),
    );
  }

  SizedBox buildTitleInMobile() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const SizedBox(
              width: SizeManagement.cardOutsideHorizontalPadding * 2),
          SizedBox(
            width: 60,
            child: NeutronTextContent(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 110,
            child: NeutronDropDown(
              isPadding: false,
              value: controller!.selectedCat,
              onChanged: (String newCat) async {
                controller!.setCat(newCat);
              },
              items: controller!.cats,
            ),
          ),
          Expanded(
            child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
            ),
          ),
        ],
      ),
    );
  }

  List<Container> buildContentInPC() {
    return controller!.services
        .map((service) => Container(
              height: SizeManagement.cardHeight,
              margin: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardOutsideHorizontalPadding,
                  vertical: SizeManagement.cardOutsideVerticalPadding),
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              child: InkWell(
                onTap: () => showServiceDetail(service, context),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthHourMinuteString(
                                service.used!.toDate())),
                      ),
                    ),
                    Expanded(
                      child: NeutronTextContent(
                        message: service.name!,
                      ),
                    ),
                    Expanded(
                        child: NeutronTextContent(
                            tooltip:
                                RoomManager().getNameRoomById(service.room!),
                            message:
                                RoomManager().getNameRoomById(service.room!))),
                    Expanded(
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthString(
                                service.inDate!))),
                    Expanded(
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthString(
                                service.outDate!))),
                    Expanded(child: NeutronTextContent(message: service.cat!)),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(
                          right: SizeManagement.cardInsideHorizontalPadding),
                      child: Text(
                        NumberUtil.numberFormat.format(service.total),
                        textAlign: TextAlign.end,
                        style: NeutronTextStyle.totalNumber,
                      ),
                    )),
                    Expanded(
                        child: NeutronStatusDropdown(
                      currentStatus: service.status!,
                      onChanged: (String newStatus) async {
                        String? result =
                            await controller!.updateStatus(service, newStatus);
                        if (mounted && result != null) {
                          MaterialUtil.showResult(context, result);
                        }
                      },
                      items:
                          ServiceManager().getStatusesByRole(UserManager.role!),
                    )),
                    if (service.sID!.isNotEmpty &&
                        UserManager.canSeeStatusPage())
                      SizedBox(
                          width: 40,
                          child: NeutronBookingContextMenu(
                            booking: Booking.empty(
                                sID: service.sID,
                                group: service.isGroup,
                                id: service.bookingID),
                            backgroundColor:
                                ColorManagement.lightMainBackground,
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_MENU),
                          )),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Container> buildContentInMobile() {
    return controller!.services
        .map((service) => Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8),
                  color: ColorManagement.lightMainBackground),
              margin: const EdgeInsets.only(
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding,
                  bottom: SizeManagement.bottomFormFieldSpacing),
              // Expansion Title
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardInsideHorizontalPadding),
                childrenPadding: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardInsideHorizontalPadding),
                title: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: NeutronTextContent(
                          message:
                              RoomManager().getNameRoomById(service.room!)),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 110,
                      child: NeutronTextContent(message: service.cat!),
                    ),
                    Expanded(
                      child: NeutronTextContent(
                          textAlign: TextAlign.right,
                          color: ColorManagement.positiveText,
                          message:
                              NumberUtil.moneyFormat.format(service.total)),
                    ),
                  ],
                ),
                children: [
                  InkWell(
                    onTap: () => showServiceDetail(service, context),
                    child: Column(
                      children: [
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TIME),
                            )),
                            Expanded(
                                child: NeutronTextContent(
                              message: DateUtil.dateToDayMonthHourMinuteString(
                                  service.used!.toDate()),
                            ))
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_NAME),
                            )),
                            Expanded(
                              child: NeutronTextContent(message: service.name!),
                            )
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_IN),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  message: DateUtil.dateToDayMonthString(
                                      service.inDate!)),
                            )
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_OUT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  message: DateUtil.dateToDayMonthString(
                                      service.outDate!)),
                            )
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_STATUS),
                            )),
                            Expanded(
                                child: NeutronStatusDropdown(
                              currentStatus: service.status!,
                              onChanged: (String newStatus) async {
                                String? result = await controller!
                                    .updateStatus(service, newStatus);
                                if (mounted && result != null) {
                                  MaterialUtil.showResult(context, result);
                                }
                              },
                              items: ServiceManager()
                                  .getStatusesByRole(UserManager.role!),
                            ))
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                      ],
                    ),
                  )
                ],
              ),
            ))
        .toList();
  }

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      title: NeutronTextContent(
        message:
            UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SERVICE_MANAGEMENT),
      ),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: controller!.startDate,
          firstDate: controller!.date.subtract(const Duration(days: 365)),
          lastDate: controller!.date.add(const Duration(days: 365)),
          onChange: (picked) {
            controller!.setStartDate(picked);
          },
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: controller!.endDate,
          firstDate: controller!.startDate,
          lastDate: controller!.startDate.add(const Duration(days: 7)),
          onChange: (picked) {
            controller!.setEndDate(picked);
          },
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: () {
            controller!.loadServices();
          },
        )
      ],
    );
  }

  void showServiceDetail(Service service, BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: const NeutronWaiting()));
    await ServiceManager()
        .getServiceByIDFromCloud(
            service.isGroup! ? service.sID! : service.bookingID!, service.id!)
        .then((fullService) {
      if (mounted) {
        Navigator.pop(context);
      }
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: ColorManagement.mainBackground,
          child: SizedBox(
            width: kMobileWidth,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical, child: _getForm(fullService)),
          ),
        ),
      );
    });
  }

  Widget _getForm(Service service) {
    final cat = service.cat;
    if (cat == ServiceManager.MINIBAR_CAT) {
      return MininbarInvoiceForm(service: (service as Minibar));
    } else if (cat == ServiceManager.EXTRA_GUEST_CAT) {
      return ExtraGuestInvoiceForm(service: (service as ExtraGuest));
    } else if (cat == ServiceManager.LAUNDRY_CAT) {
      return LaundryInvoiceForm(service: (service as Laundry));
    } else if (cat == ServiceManager.BIKE_RENTAL_CAT) {
      return BikeRentalInvoiceForm(service: (service as BikeRental));
    } else if (cat == ServiceManager.OTHER_CAT) {
      return OtherInvoiceForm(service: (service as Other));
    } else if (cat == ServiceManager.OUTSIDE_RESTAURANT_CAT) {
      return RestaurantInvoiceForm(
          service: (service as OutsideRestaurantService), isMobile: true);
    } else if (cat == ServiceManager.INSIDE_RESTAURANT_CAT) {
      return InsideRestaurantInvoiceForm(
          service: (service as InsideRestaurantService));
    } else {
      return Container();
    }
  }
}
