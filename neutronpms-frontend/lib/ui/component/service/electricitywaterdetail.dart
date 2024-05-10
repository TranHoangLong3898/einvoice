import 'package:flutter/material.dart';
import 'package:ihotel/controller/electricitywatercontroller.dart';
import 'package:ihotel/modal/service/service.dart';
import 'package:ihotel/ui/component/service/electricitywaterform.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

import '../../../modal/booking.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class ElectricityWaterDetail extends StatefulWidget {
  final Booking? booking;
  final bool isElectricity;
  const ElectricityWaterDetail(
      {super.key, this.booking, this.isElectricity = true});

  @override
  State<ElectricityWaterDetail> createState() => _ElectricityWaterDetailState();
}

class _ElectricityWaterDetailState extends State<ElectricityWaterDetail> {
  ElectricityWaterListController? controller;
  bool isLoadingDelete = false;

  @override
  void initState() {
    controller ??=
        ElectricityWaterListController(widget.booking!, widget.isElectricity);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          height: kHeight,
          width: isMobile ? kMobileWidth : kWidth,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<ElectricityWaterListController>(
              builder: (_, controller, __) {
                return controller.isLoading || isLoadingDelete
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ColorManagement.greenColor,
                        ),
                      )
                    : Column(children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.rowSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                widget.isElectricity
                                    ? UITitleCode.TABLEHEADER_ELECTRICITY
                                    : UITitleCode.TABLEHEADER_WATER),
                          ),
                        ),
                        const SizedBox(
                            height: SizeManagement.topHeaderTextSpacing),
                        Expanded(
                            child: ListView(
                          children: widget.isElectricity
                              ? controller.electricity!
                                  .map((service) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            vertical: SizeManagement
                                                .cardOutsideVerticalPadding),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground,
                                        ),
                                        child: ExpansionTile(
                                            collapsedTextColor:
                                                ColorManagement.greenColor,
                                            textColor:
                                                ColorManagement.greenColor,
                                            iconColor: ColorManagement.white,
                                            collapsedIconColor:
                                                ColorManagement.white,
                                            title: Row(
                                              children: [
                                                //Create-time-column
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  maxLines: 2,
                                                  message: DateUtil
                                                      .dateToDayMonthHourMinuteString(
                                                          service.created!
                                                              .toDate()),
                                                )),
                                                //MHĐ
                                                if (!isMobile)
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: SizeManagement
                                                              .cardOutsideHorizontalPadding),
                                                      child: Row(
                                                        children: [
                                                          NeutronTextContent(
                                                              message:
                                                                  "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                                          NeutronTextContent(
                                                              message: service
                                                                  .id!
                                                                  .substring(
                                                                      service.id!.length ==
                                                                              15
                                                                          ? 9
                                                                          : 10,
                                                                      service
                                                                          .id!
                                                                          .length)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                //Total-money-column
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: NeutronTextContent(
                                                      message: isMobile
                                                          ? NumberUtil
                                                              .moneyFormat
                                                              .format(
                                                                  service.total)
                                                          : NumberUtil
                                                              .numberFormat
                                                              .format(service
                                                                  .total),
                                                      color: ColorManagement
                                                          .positiveText,
                                                    ),
                                                  ),
                                                ),
                                                //edit button
                                                buildEditButton(
                                                    service, widget.booking!),
                                                //Delete-button
                                                buildDeleteButton(service),
                                              ],
                                            ),
                                            children: [
                                              if (isMobile)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    NeutronTextContent(
                                                        message:
                                                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                                    NeutronTextContent(
                                                        message: service.id!
                                                            .substring(
                                                                service.id!.length ==
                                                                        15
                                                                    ? 9
                                                                    : 10,
                                                                service.id!
                                                                    .length)),
                                                  ],
                                                ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_INITIAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: service
                                                              .initialNumber
                                                              .toString()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TOOLTIP_START_DATE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: DateUtil
                                                              .dateToDayMonthHourMinuteString(
                                                                  service
                                                                      .initialTime!)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_FINAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: service
                                                              .finalNumber
                                                              .toString()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TOOLTIP_END_DATE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: DateUtil
                                                              .dateToDayMonthHourMinuteString(
                                                                  service
                                                                      .finalTime!)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_PRICE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: NumberUtil
                                                              .moneyFormat
                                                              .format(service
                                                                  .priceElectricity)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_TOTAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: NumberUtil
                                                              .moneyFormat
                                                              .format(service
                                                                  .total)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ))
                                  .toList()
                              : controller.water!
                                  .map((service) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            vertical: SizeManagement
                                                .cardOutsideVerticalPadding),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              SizeManagement.borderRadius8),
                                          color: ColorManagement
                                              .lightMainBackground,
                                        ),
                                        child: ExpansionTile(
                                            collapsedTextColor:
                                                ColorManagement.greenColor,
                                            textColor:
                                                ColorManagement.greenColor,
                                            iconColor: ColorManagement.white,
                                            collapsedIconColor:
                                                ColorManagement.white,
                                            title: Row(
                                              children: [
                                                //Create-time-column
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  maxLines: 2,
                                                  message: DateUtil
                                                      .dateToDayMonthHourMinuteString(
                                                          service.created!
                                                              .toDate()),
                                                )),
                                                //MHĐ
                                                if (!isMobile)
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: SizeManagement
                                                              .cardOutsideHorizontalPadding),
                                                      child: Row(
                                                        children: [
                                                          NeutronTextContent(
                                                              message:
                                                                  "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                                          NeutronTextContent(
                                                              message: service
                                                                  .id!
                                                                  .substring(
                                                                      service.id!.length ==
                                                                              15
                                                                          ? 9
                                                                          : 10,
                                                                      service
                                                                          .id!
                                                                          .length)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                //Total-money-column
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: NeutronTextContent(
                                                      message: isMobile
                                                          ? NumberUtil
                                                              .moneyFormat
                                                              .format(
                                                                  service.total)
                                                          : NumberUtil
                                                              .numberFormat
                                                              .format(service
                                                                  .total),
                                                      color: ColorManagement
                                                          .positiveText,
                                                    ),
                                                  ),
                                                ),
                                                //edit button
                                                buildEditButton(
                                                    service, widget.booking!),
                                                //Delete-button
                                                buildDeleteButton(service),
                                              ],
                                            ),
                                            children: [
                                              if (isMobile)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    NeutronTextContent(
                                                        message:
                                                            "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMNER_BILL)}: "),
                                                    NeutronTextContent(
                                                        message: service.id!
                                                            .substring(
                                                                service.id!.length ==
                                                                        15
                                                                    ? 9
                                                                    : 10,
                                                                service.id!
                                                                    .length)),
                                                  ],
                                                ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_INITIAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: service
                                                              .initialNumber
                                                              .toString()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TOOLTIP_START_DATE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: DateUtil
                                                              .dateToDayMonthHourMinuteString(
                                                                  service
                                                                      .initialTime!)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_FINAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: service
                                                              .finalNumber
                                                              .toString()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TOOLTIP_END_DATE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: DateUtil
                                                              .dateToDayMonthHourMinuteString(
                                                                  service
                                                                      .finalTime!)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_PRICE)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: NumberUtil
                                                              .moneyFormat
                                                              .format(service
                                                                  .priceWater)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: UITitleUtil
                                                              .getTitleByCode(
                                                                  UITitleCode
                                                                      .TABLEHEADER_TOTAL)),
                                                    ),
                                                    Expanded(
                                                      child: NeutronTextContent(
                                                          message: NumberUtil
                                                              .moneyFormat
                                                              .format(service
                                                                  .total)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      ))
                                  .toList(),
                        )),
                        NeutronButton(
                          icon: Icons.add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: ColorManagement.mainBackground,
                                child: ElectricityWaterForm(
                                  isElectricity: widget.isElectricity,
                                  booking: widget.booking,
                                ),
                              ),
                            ).whenComplete(() {
                              controller.update();
                            });
                          },
                        )
                      ]);
              },
            ),
          ),
        ));
  }

  Widget buildEditButton(Service service, Booking booking) {
    return Container(
      alignment: Alignment.center,
      width: 26,
      child: IconButton(
        tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
        alignment: Alignment.center,
        icon: const Icon(Icons.edit),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                  backgroundColor: ColorManagement.mainBackground,
                  child: ElectricityWaterForm(
                    booking: booking,
                    service: service,
                    isElectricity: widget.isElectricity,
                  ))).whenComplete(() {
            controller!.update();
          });
        },
      ),
    );
  }

  Widget buildDeleteButton(Service service) {
    return Container(
      alignment: Alignment.center,
      width: 26,
      child: IconButton(
        tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
        alignment: Alignment.center,
        icon: const Icon(Icons.delete),
        onPressed: () async {
          String total = NumberUtil.numberFormat.format(service.total);
          bool? isConfirmed = await MaterialUtil.showConfirm(
              context,
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.CONFIRM_DELETE_INVOICE_WITH_AMOUNT, [total]));
          if (isConfirmed!) {
            setState(() {
              isLoadingDelete = true;
            });
            await widget.booking!.deleteService(service).then((result) {
              if (result == MessageCodeUtil.SUCCESS) {
              } else {
                MaterialUtil.showAlert(
                    context, MessageUtil.getMessageByCode(result));
              }
            }).whenComplete(() {
              controller!.update();
              setState(() {
                isLoadingDelete = false;
              });
            });
          }
        },
      ),
    );
  }
}
