import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/report/servicesupplierreportcontroller.dart';
import '../../../manager/othermanager.dart';
import '../../../manager/servicemanager.dart';
import '../../../manager/usermanager.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutronbookingcontextmenu.dart';
import '../../controls/neutrondatetimepicker.dart';

class ServiceSupplierManagementForm extends StatelessWidget {
  const ServiceSupplierManagementForm({Key? key}) : super(key: key);

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

    return SizedBox(
      width: width,
      height: height,
      child: ChangeNotifierProvider(
        create: (context) => ServiceSupplierReportController(),
        child: Consumer<ServiceSupplierReportController>(
          builder: (_, controller, __) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 65, left: 5, right: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildSearch(context, controller),
                        buildChooseSupplier(controller),
                        DataTable(
                            showCheckboxColumn: false,
                            columnSpacing: 3,
                            horizontalMargin: 6,
                            columns: buildColumns(controller, isMobile),
                            rows: controller.filterServices.map((service) {
                              final statuses = ServiceManager()
                                  .getStatusesByRole(UserManager.role!);
                              return DataRow(
                                cells: <DataCell>[
                                  if (!isMobile)
                                    DataCell(NeutronTextContent(
                                      message: OtherManager()
                                          .getServiceNameByID(service.type!),
                                      tooltip: OtherManager()
                                          .getServiceNameByID(service.type!),
                                    )),
                                  // Description
                                  DataCell(isMobile
                                      ? SizedBox(
                                          width: 90,
                                          child: NeutronTextContent(
                                            message: service.desc!,
                                            tooltip: service.desc,
                                          ),
                                        )
                                      : NeutronTextContent(
                                          message: service.desc!,
                                          tooltip: service.desc,
                                        )),
                                  DataCell(NeutronTextContent(
                                      message: DateUtil.dateToDayMonthString(
                                          service.date!.toDate()))),
                                  if (!isMobile)
                                    DataCell(NeutronTextContent(
                                        tooltip: service.name,
                                        message: service.name!)),
                                  if (!isMobile)
                                    DataCell(NeutronTextContent(
                                        message: (RoomManager()
                                            .getNameRoomById(service.room!)))),
                                  DataCell(NeutronTextContent(
                                      color: ColorManagement.positiveText,
                                      message: NumberUtil.numberFormat
                                          .format(service.total))),
                                  DataCell(NeutronStatusDropdown(
                                    height: double.infinity,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    currentStatus: service.status!,
                                    onChanged: (String newStatus) async {
                                      await controller
                                          .updateServiceStatus(
                                              service, newStatus)
                                          .then((result) {
                                        if (result != null) {
                                          MaterialUtil.showResult(
                                              context, result);
                                        }
                                      });
                                    },
                                    items: statuses,
                                    isDisable:
                                        !statuses.contains(service.status),
                                  )),
                                  if (!isMobile)
                                    service.sID!.isEmpty
                                        ? DataCell.empty
                                        : DataCell(Padding(
                                            padding: const EdgeInsets.only(
                                                left: SizeManagement
                                                    .cardOutsideHorizontalPadding),
                                            child: NeutronBookingContextMenu(
                                              booking: Booking.empty(
                                                  id: service.bookingID),
                                              tooltip:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode.TOOLTIP_MENU),
                                            ),
                                          )),
                                ],
                              );
                            }).toList()),
                      ],
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButtonText(
                      text:
                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.getTotal())}",
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSearch(
      BuildContext context, ServiceSupplierReportController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(DateUtil.dateToDayMonthString(controller.startDate)),
        IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
            onPressed: () async {
              final DateTime now = Timestamp.now().toDate();

              final DateTime? picked = await showDatePicker(
                  builder: (context, child) =>
                      DateTimePickerDarkTheme.buildDarkTheme(context, child!),
                  context: context,
                  initialDate: controller.startDate,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now);
              if (picked != null) {
                controller.setStartDate(picked);
              }
            }),
        Text(DateUtil.dateToDayMonthString(controller.endDate)),
        IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
            onPressed: () async {
              final DateTime now = Timestamp.now().toDate();

              final DateTime? picked = await showDatePicker(
                  builder: (context, child) =>
                      DateTimePickerDarkTheme.buildDarkTheme(context, child!),
                  context: context,
                  initialDate: controller.endDate,
                  firstDate: controller.startDate,
                  lastDate: now);
              if (picked != null) {
                controller.setEndDate(picked);
              }
            }),
        IconButton(
            icon: const Icon(Icons.search),
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
            onPressed: () async {
              await controller.getServices().then((result) {
                if (result !=
                    MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS)) {
                  MaterialUtil.showAlert(context, result);
                }
              });
            }),
      ],
    );
  }

  Widget buildChooseSupplier(ServiceSupplierReportController controller) {
    return Row(
      children: [
        const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
        Text(
            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER)}: '),
        const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
        Expanded(
          child: NeutronDropDown(
            value: controller.selectedSupplierName,
            onChanged: (String newMethod) async {
              controller.setSupplierName(newMethod);
            },
            items: controller.getSupplierNames(),
          ),
        ),
        const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding)
      ],
    );
  }

  List<DataColumn> buildColumns(
      ServiceSupplierReportController controller, bool isMobile) {
    return <DataColumn>[
      if (!isMobile)
        DataColumn(
          label: Text(
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE),
          ),
        ),
      DataColumn(
        label: Text(
          UITitleUtil.getTitleByCode(
              UITitleCode.TABLEHEADER_DESCRIPTION_COMPACT),
        ),
      ),
      DataColumn(
        label: Text(UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_USED)),
      ),
      if (!isMobile)
        DataColumn(
          label: Text(
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
          ),
        ),
      if (!isMobile)
        DataColumn(
          label: Text(
            UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
          ),
        ),
      DataColumn(
        numeric: true,
        label: Text(
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
        ),
      ),
      DataColumn(
        label: Expanded(
          child: NeutronDropDown(
            value: controller.selectedStatus,
            onChanged: (String newStatus) async {
              controller.setStatus(newStatus);
            },
            items: controller.getStatuses(),
            isCenter: true,
            textStyle: const TextStyle(
              // fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      if (!isMobile) const DataColumn(label: Text('')),
    ];
  }
}
