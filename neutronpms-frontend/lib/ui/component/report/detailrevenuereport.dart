import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/excelulti.dart';

import '../../../controller/report/revenuereportcontroller.dart';

import '../../../util/dateutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/uimultilanguageutil.dart';

class DetailRevenueReportDialog extends StatelessWidget {
  final RevenueReportController controller;
  const DetailRevenueReportDialog({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 65),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: ColorManagement.greenColor,
                          borderRadius: BorderRadius.only(
                              topLeft:
                                  Radius.circular(SizeManagement.borderRadius8),
                              topRight: Radius.circular(
                                  SizeManagement.borderRadius8))),
                      child: Column(
                        children: [
                          const SizedBox(
                              height: SizeManagement.topHeaderTextSpacing),
                          NeutronTextTitle(
                              textAlign: TextAlign.center,
                              messageUppercase: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_REVENUE_REPORT_DETAI)),
                          const SizedBox(height: SizeManagement.rowSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              NeutronTextContent(
                                  message: DateUtil.dateToDayMonthYearString(
                                      controller.startDate)),
                              NeutronTextContent(
                                  message: DateUtil.dateToDayMonthYearString(
                                      controller.endDate))
                            ],
                          ),
                          const SizedBox(height: SizeManagement.rowSpacing),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(columnSpacing: 14, columns: [
                          DataColumn(
                              label: NeutronTextTitle(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE),
                          )),
                          DataColumn(
                              label: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TOTAL_COMPACT))),
                        ], rows: [
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.rChargeTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.minibarTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_EXTRA_HOUR_SERVICE_COMPACT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.extraHourTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_EXTRA_GUEST_SERVICE_COMPACT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.extraGuestTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.laudryTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.bikeRentalTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_OTHER),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.otherTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              maxLines: 2,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_RESTAURANT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.restaurantTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              maxLines: 2,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.insideRestaurantTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ELECTRICITY),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.electricityTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_WATER),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.waterTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.discountTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                            )),
                            DataCell(NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(controller.getAllSeverTotal),
                            ))
                          ]),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_COST_ROOM),
                            )),
                            DataCell(NeutronTextContent(
                              color: ColorManagement.positiveText,
                              message: NumberUtil.numberFormat
                                  .format(controller.costTotal),
                            ))
                          ]),
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                  icon: Icons.file_present_rounded,
                  onPressed: () async {
                    ExcelUlti.exportRevenueByDateDetail(controller, false);
                  },
                ),
              )
            ],
          ),
        ));
  }
}
