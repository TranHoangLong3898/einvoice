import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/service/bikerental.dart';
import 'package:ihotel/modal/service/extraguest.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/laundry.dart';
import 'package:ihotel/modal/service/minibar.dart';
import 'package:ihotel/modal/service/other.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/ui/component/service/outsiderestaurantform.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/report/servicereportcontroller.dart';
import '../../../manager/servicemanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/service.dart';
import '../../../ui/component/service/bikerentalinvoiceform.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrontextstyle.dart';
import '../service/extraguestform.dart';
import '../service/insiderestaurantform.dart';
import '../service/laundryform.dart';
import '../service/minibarform.dart';
import '../service/othersform.dart';

class ServiceReportDialog extends StatefulWidget {
  const ServiceReportDialog({Key? key}) : super(key: key);

  @override
  State<ServiceReportDialog> createState() => _ServiceReportDialogState();
}

class _ServiceReportDialogState extends State<ServiceReportDialog> {
  final ServiceReportController controller = ServiceReportController();

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
            child: ChangeNotifierProvider<ServiceReportController>.value(
                value: controller,
                child: Consumer<ServiceReportController>(
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    ),
                    builder: (_, controller, child) {
                      return Scaffold(
                          backgroundColor: ColorManagement.mainBackground,
                          appBar: buildAppBar(isMobile),
                          body: Stack(fit: StackFit.expand, children: [
                            Container(
                              width: width,
                              height: height,
                              margin: const EdgeInsets.only(bottom: 65),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //title
                                  isMobile
                                      ? buildTitleInMobile()
                                      : buildTitleInPC(),
                                  //content
                                  Expanded(
                                      child: buildContent(child!, isMobile)),
                                  const SizedBox(
                                      height: SizeManagement.rowSpacing),
                                  if (!(controller
                                          .totalMoneyServiceCurrentPage ==
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
                                                  .totalMoneyServiceCurrentPage),
                                          style: NeutronTextStyle.totalNumber,
                                        ),
                                        SizedBox(
                                            width: (isMobile ? 40 : 250) +
                                                SizeManagement
                                                    .cardOutsideHorizontalPadding),
                                      ],
                                    ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              controller
                                                  .getServicesReportFirstPage();
                                            },
                                            icon: const Icon(
                                                Icons.skip_previous)),
                                        IconButton(
                                            onPressed: () {
                                              controller
                                                  .getServicesReportPreviousPage();
                                            },
                                            icon: const Icon(
                                              Icons.navigate_before_sharp,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              controller
                                                  .getServicesReportNextPage();
                                            },
                                            icon: const Icon(
                                              Icons.navigate_next_sharp,
                                            )),
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
                                        "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.totalMoneyService)}")),
                          ]));
                    }))));
  }

  Widget buildContent(Widget loadingWidget, bool isMobile) {
    if (controller.isLoading!) {
      return loadingWidget;
    }
    if (controller.services.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)),
      );
    }
    return ListView(
        children: isMobile ? buildContentInMobile() : buildContentInPC());
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
              textStyle: NeutronTextStyle.title,
              isPadding: false,
              value: controller.selectedCat,
              onChanged: (String newCat) async {
                controller.setCat(newCat);
              },
              items: controller.cats,
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              textAlign: TextAlign.end,
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              textAlign: TextAlign.end,
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SALER),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
            ),
          ),
          const SizedBox(width: 40)
        ],
      ),
    );
  }

  Container buildTitleInMobile() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding * 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: NeutronTextContent(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NeutronDropDown(
              value: controller.selectedCat,
              onChanged: (String newCat) async {
                controller.setCat(newCat);
              },
              items: controller.cats,
              isPadding: false,
            ),
          ),
          Container(
            width: 90,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 8),
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
    return controller.services
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
                onTap: () => showServiceDetail(service),
                child: Row(
                  children: [
                    const SizedBox(
                        width: SizeManagement.cardInsideHorizontalPadding),
                    Expanded(
                      child: NeutronTextContent(
                          message: DateUtil.dateToDayMonthHourMinuteString(
                              service.used!.toDate())),
                    ),
                    Expanded(child: NeutronTextContent(message: service.name!)),
                    Expanded(
                      child: NeutronTextContent(
                          tooltip: RoomManager().getNameRoomById(service.room!),
                          message:
                              RoomManager().getNameRoomById(service.room!)),
                    ),
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
                        child: Text(
                      NumberUtil.numberFormat.format(service.total),
                      textAlign: TextAlign.end,
                      style:
                          const TextStyle(color: ColorManagement.positiveText),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                      message: service.saler!,
                      tooltip: service.saler,
                      textAlign: TextAlign.end,
                    )),
                    const SizedBox(width: 10),
                    Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: NeutronTextContent(message: service.status!)),
                    if (service.sID!.isNotEmpty)
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
    return controller.services
        .map((service) => Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8),
                  color: ColorManagement.lightMainBackground),
              margin: const EdgeInsets.only(
                  left: SizeManagement.cardOutsideHorizontalPadding,
                  right: SizeManagement.cardOutsideHorizontalPadding,
                  bottom: SizeManagement.bottomFormFieldSpacing),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                    horizontal: SizeManagement.cardInsideHorizontalPadding),
                title: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: NeutronTextContent(
                          tooltip: RoomManager().getNameRoomById(service.room!),
                          message:
                              RoomManager().getNameRoomById(service.room!)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: NeutronTextContent(message: service.cat!)),
                    Container(
                      width: 50,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(left: 8),
                      child: NeutronTextContent(
                        message: NumberUtil.moneyFormat.format(service.total),
                        color: ColorManagement.positiveText,
                      ),
                    ),
                  ],
                ),
                children: [
                  InkWell(
                    onTap: () => showServiceDetail(service),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TIME),
                              )),
                              Expanded(
                                  flex: 2,
                                  child: NeutronTextContent(
                                    message:
                                        DateUtil.dateToDayMonthHourMinuteString(
                                            service.used!.toDate()),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_NAME),
                              )),
                              Expanded(
                                flex: 2,
                                child:
                                    NeutronTextContent(message: service.name!),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STATUS),
                              )),
                              Expanded(
                                flex: 2,
                                child: NeutronTextContent(
                                    message: service.status!),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_IN),
                              )),
                              Expanded(
                                flex: 2,
                                child: NeutronTextContent(
                                    message: DateUtil.dateToDayMonthString(
                                        service.inDate!)),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15, bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_OUT),
                              )),
                              Expanded(
                                flex: 2,
                                child: NeutronTextContent(
                                    message: DateUtil.dateToDayMonthString(
                                        service.outDate!)),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, top: 15, bottom: 15),
                          child: Row(
                            children: [
                              Expanded(
                                  child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SALER),
                              )),
                              Expanded(
                                flex: 2,
                                child: NeutronTextContent(
                                  message: service.saler!,
                                  tooltip: service.saler,
                                ),
                              )
                            ],
                          ),
                        ),
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
      automaticallyImplyLeading: !isMobile,
      title: NeutronTextContent(
          message:
              UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_SERVICE_REPORT)),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: controller.startDate,
          firstDate: controller.date.subtract(const Duration(days: 365)),
          lastDate: controller.date.add(const Duration(days: 365)),
          onChange: (picked) {
            controller.setStartDate(picked);
          },
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: controller.endDate,
          firstDate: controller.startDate,
          lastDate: controller.startDate
              .add(Duration(days: controller.maxTimePeriod)),
          onChange: (picked) {
            controller.setEndDate(picked);
          },
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: () {
            controller.loadServices();
          },
        ),
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            await controller.getAllDetailService().then((value) {
              if (value.isEmpty) return;
              ExcelUlti.exportServiceReport(
                  controller.startDate, controller.endDate, value);
            });
          },
        )
      ],
    );
  }

  void showServiceDetail(Service service) async {
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
          backgroundColor: ColorManagement.lightMainBackground,
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
