// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/report/bikerentalsupplierreportcontroller.dart';
import '../../../manager/servicemanager.dart';
import '../../../manager/usermanager.dart';
import '../../../ui/controls/neutronbuttontext.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../controls/neutrondatetimepicker.dart';

class BikeRentalSupplierManagementForm extends StatelessWidget {
  const BikeRentalSupplierManagementForm({Key? key}) : super(key: key);

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
      child: ChangeNotifierProvider.value(
        value: BikeRentalSupplierReportController(),
        child: Consumer<BikeRentalSupplierReportController>(
          builder: (_, controller, __) {
            final statuses =
                ServiceManager().getStatusesByRole(UserManager.role!);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(DateUtil.dateToDayMonthString(
                                controller.startDate)),
                            IconButton(
                                icon: const Icon(Icons.calendar_today),
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_START_DATE),
                                onPressed: () async {
                                  final DateTime now = Timestamp.now().toDate();

                                  final DateTime? picked = await showDatePicker(
                                      builder: (context, child) =>
                                          DateTimePickerDarkTheme
                                              .buildDarkTheme(context, child!),
                                      context: context,
                                      initialDate: controller.startDate,
                                      firstDate: now
                                          .subtract(const Duration(days: 365)),
                                      lastDate: now);
                                  if (picked != null) {
                                    controller.setStartDate(picked);
                                  }
                                }),
                            Text(DateUtil.dateToDayMonthString(
                                controller.endDate)),
                            IconButton(
                                icon: const Icon(Icons.calendar_today),
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_END_DATE),
                                onPressed: () async {
                                  final DateTime now = Timestamp.now().toDate();

                                  final DateTime? picked = await showDatePicker(
                                      builder: (context, child) =>
                                          DateTimePickerDarkTheme
                                              .buildDarkTheme(context, child!),
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
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_SEARCH),
                                onPressed: () async {
                                  final result = await controller.getServices();
                                  if (result !=
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    MaterialUtil.showAlert(context, result);
                                  }
                                }),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            Text(UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SUPPLIER)),
                            const SizedBox(
                                width: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            Expanded(
                              child: NeutronDropDown(
                                value: controller.selectedSupplierName,
                                onChanged: (String newMethod) async {
                                  controller.setSupplierName(newMethod);
                                },
                                items: controller.getSupplierNames(),
                              ),
                            ),
                            isMobile
                                ? const SizedBox(
                                    width: SizeManagement
                                        .cardOutsideHorizontalPadding)
                                : const Expanded(child: Text(''))
                          ],
                        ),
                        DataTable(
                          horizontalMargin: 6,
                          showCheckboxColumn: false,
                          columnSpacing: 3,
                          columns: <DataColumn>[
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SUPPLIER),
                                ),
                              ),
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TYPE),
                                ),
                              ),
                            DataColumn(
                              label: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_BIKE),
                              ),
                            ),
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NAME),
                                ),
                              ),
                            if (!isMobile)
                              DataColumn(
                                label: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ROOM),
                                ),
                              ),
                            DataColumn(
                              label: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_START),
                              ),
                            ),
                            if (!isMobile)
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_PRICE),
                                ),
                              ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TOTAL),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: NeutronDropDown(
                                  isCenter: true,
                                  value: controller.selectedStatus,
                                  onChanged: (String newStatus) async {
                                    controller.setStatus(newStatus);
                                  },
                                  items: controller.getStatuses(),
                                ),
                              ),
                            ),
                          ],
                          rows: controller.filterBikeRentals
                              .map((bikeRental) => DataRow(
                                    cells: <DataCell>[
                                      if (!isMobile)
                                        DataCell(NeutronTextContent(
                                            message: SupplierManager()
                                                .getSupplierNameByID(
                                                    bikeRental.supplierID!))),
                                      if (!isMobile)
                                        DataCell(NeutronTextContent(
                                            message: bikeRental.type!)),
                                      DataCell(NeutronTextContent(
                                          message: bikeRental.bike!)),
                                      if (!isMobile)
                                        DataCell(NeutronTextContent(
                                            message: bikeRental.name!)),
                                      if (!isMobile)
                                        DataCell(NeutronTextContent(
                                            message: RoomManager()
                                                .getNameRoomById(
                                                    bikeRental.room!))),
                                      DataCell(NeutronTextContent(
                                          message: DateUtil
                                              .dateToDayMonthHourMinuteString(
                                                  bikeRental.start!.toDate()))),
                                      if (!isMobile)
                                        DataCell(NeutronTextContent(
                                            color: ColorManagement.positiveText,
                                            message: NumberUtil.numberFormat
                                                .format(bikeRental.price))),
                                      DataCell(NeutronTextContent(
                                          color: ColorManagement.positiveText,
                                          message: NumberUtil.numberFormat
                                              .format(bikeRental.getTotal()))),
                                      DataCell(NeutronStatusDropdown(
                                        height: double.infinity,
                                        width: double.infinity,
                                        currentStatus: bikeRental.status!,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2),
                                        isDisable: !statuses
                                            .contains(bikeRental.status),
                                        onChanged: (String newStatus) async {
                                          String? result = await controller
                                              .updateServiceStatus(
                                                  bikeRental, newStatus);
                                          if (result != null) {
                                            MaterialUtil.showResult(
                                                context, result);
                                          }
                                        },
                                        items: statuses,
                                      )),
                                    ],
                                  ))
                              .toList(),
                        ),
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
}
