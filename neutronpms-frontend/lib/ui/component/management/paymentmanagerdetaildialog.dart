import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../controller/management/paymentmanagementcontroller.dart';
import '../../../manager/paymentmethodmanager.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';

class DetailPaymentManagerDialog extends StatelessWidget {
  final PaymentManagementController controller;
  const DetailPaymentManagerDialog({Key? key, required this.controller})
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
                              message: UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_PAYMENT_METHOD_REPORT_DETAIL)),
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
                            maxLines: 2,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_METHOD),
                          )),
                          DataColumn(
                              label: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_AMOUNT_MONEY))),
                        ], rows: [
                          ...controller.dataPayment.entries
                              .where((element) => element.value != 0)
                              .map(
                            (e) {
                              controller.totalAll += e.value;
                              return DataRow(cells: [
                                DataCell(NeutronTextContent(
                                  maxLines: 2,
                                  message: PaymentMethodManager()
                                      .getPaymentMethodNameById(e.key),
                                )),
                                DataCell(NeutronTextContent(
                                  message:
                                      NumberUtil.numberFormat.format(e.value),
                                ))
                              ]);
                            },
                          ).toList(),
                          DataRow(cells: [
                            DataCell(NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                            )),
                            DataCell(NeutronTextContent(
                              message: NumberUtil.numberFormat
                                  .format(controller.totalAll),
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
                    ExcelUlti.exportPaymentManager(controller.dataPayment,
                        controller.startDate, controller.endDate);
                  },
                ),
              )
            ],
          ),
        ));
  }
}
