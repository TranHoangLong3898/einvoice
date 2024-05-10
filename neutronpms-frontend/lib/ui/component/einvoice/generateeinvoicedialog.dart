// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/einvoice/generateeinvoicecontroller.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/einvoiceutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class GenerateEInvoiceDialog extends StatelessWidget {
  const GenerateEInvoiceDialog(
      {super.key,
      required this.generateElectronicInvoiceController,
      required this.booking});

  final GenerateElectronicInvoiceController generateElectronicInvoiceController;
  final Booking booking;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        height: kHeight,
        width: kMobileWidth,
        child: ChangeNotifierProvider<GenerateElectronicInvoiceController>(
          create: (context) => generateElectronicInvoiceController,
          builder: (context, child) =>
              Consumer<GenerateElectronicInvoiceController>(
            builder: (context, controller, child) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: SizeManagement.topHeaderTextSpacing),
                  child: NeutronTextTitle(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_ELECTRONIC_INVOICE)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NeutronTextContent(
                    message:
                        '(*): ${UITitleUtil.getTitleByCode(UITitleCode.REQUIRED)}',
                    color: ColorManagement.redColor,
                  ),
                ),
                Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.CUSTOMER_CODE),
                              controller: controller.cusCodeTeController,
                            ),
                          ),
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.CUSTOMER_NAME),
                              controller: controller.cusNameTeController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextFormField(
                        isDecor: true,
                        borderColor: ColorManagement.white,
                        label:
                            UITitleUtil.getTitleByCode(UITitleCode.BUYER_NAME),
                        controller: controller.buyerTeController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TAX_CODE),
                              controller: controller.cusTaxCodeTeController,
                            ),
                          ),
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PHONE),
                              controller: controller.cusPhoneTeController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextFormField(
                        isDecor: true,
                        borderColor: ColorManagement.white,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_EMAIL),
                        controller: controller.emailTeController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextFormField(
                        isDecor: true,
                        borderColor: ColorManagement.white,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ADDRESS),
                        controller: controller.custAddressTeController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.BANK_NUMBER),
                              controller: controller.cusBankNoTeController,
                            ),
                          ),
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronTextFormField(
                              isDecor: true,
                              borderColor: ColorManagement.white,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.BANK_NAME),
                              controller: controller.cusBankNameTeController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PAYMENT_METHOD),
                          borderColors: ColorManagement.white,
                          childWidget: NeutronDropDown(
                            items:
                                ElectronicInvoicePaymentMethod.paymentMethod(),
                            value: controller.paymentMethod,
                            onChanged: (String value) =>
                                controller.setPaymentMethod(value),
                          )),
                    ),
                    if (controller.paymentMethod ==
                        ElectronicInvoicePaymentMethod.other)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NeutronTextFormField(
                          isDecor: true,
                          borderColor: ColorManagement.white,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_OTHER_PAYMENT_METHOD),
                          controller: controller.otherPaymentMethodTeController,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: controller.vatRate == -3
                                ? (kMobileWidth - 24) / 2
                                : kMobileWidth - 16,
                            child: NeutronDropDownCustom(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_VAT),
                                borderColors: ColorManagement.white,
                                childWidget: NeutronDropDown(
                                  items: VatRate.vateRate()
                                      .map((e) => UITitleUtil.getTitleByCode(e))
                                      .toList(),
                                  value: UITitleUtil.getTitleByCode(
                                      VatRate.getStringVat(controller.vatRate)),
                                  onChanged: (String value) =>
                                      controller.setVat(value),
                                )),
                          ),
                          if (controller.vatRate == -3)
                            SizedBox(
                              width: (kMobileWidth - 24) / 2,
                              child: controller.otherVat.buildWidget(
                                  borderColor: ColorManagement.white,
                                  isDecor: true,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_OTHER_VAT),
                                  isNegative: false,
                                  isDouble: true),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: NeutronDropDownCustom(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CURRENCY),
                                borderColors: ColorManagement.white,
                                childWidget: NeutronDropDown(
                                  items: CurrencyUnit.currencyUnit(),
                                  value: controller.currentcyUnit,
                                  onChanged: (String value) =>
                                      controller.setCurrentcyUnit(value),
                                )),
                          ),
                          SizedBox(
                            width: (kMobileWidth - 24) / 2,
                            child: controller.exchangeRate.buildWidget(
                                borderColor: ColorManagement.white,
                                isDecor: true,
                                isDouble: true,
                                isNegative: false,
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.EXCHANGE_RATE)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: ColorManagement.white,
                    ),
                    NeutronTextTitle(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_GOODS_SERVICES)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextContent(
                          message:
                              '- ${UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE)} : ${NumberUtil.numberFormat.format(booking.getRoomCharge())}'),
                    ),
                    if (controller.isContainService) ...[
                      if (booking.minibar != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MINIBAR_SERVICE)} : ${NumberUtil.numberFormat.format(booking.minibar)}'),
                        ),
                      if (booking.insideRestaurant != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INSIDE_RESTAURANT)} : ${NumberUtil.numberFormat.format(booking.insideRestaurant)}'),
                        ),
                      if (booking.outsideRestaurant != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT)} : ${NumberUtil.numberFormat.format(booking.outsideRestaurant)}'),
                        ),
                      if (booking.extraGuest != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE)} : ${NumberUtil.numberFormat.format(booking.extraGuest)}'),
                        ),
                      if ((booking.extraHour?.total ?? 0) != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE)} : ${NumberUtil.numberFormat.format(booking.extraHour?.total ?? 0)}'),
                        ),
                      if (booking.electricity != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ELECTRICITY)} : ${NumberUtil.numberFormat.format(booking.electricity)}'),
                        ),
                      if (booking.water != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WATER)} : ${NumberUtil.numberFormat.format(booking.water)}'),
                        ),
                      if (booking.laundry != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LAUNDRY_SERVICE)} : ${NumberUtil.numberFormat.format(booking.laundry)}'),
                        ),
                      if (booking.bikeRental != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE)} : ${NumberUtil.numberFormat.format(booking.bikeRental)}'),
                        ),
                      if (booking.other != 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeutronTextContent(
                              message:
                                  '- ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER)} : ${NumberUtil.numberFormat.format(booking.other)}'),
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextContent(
                          message:
                              '- ${UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL)} : ${NumberUtil.numberFormat.format(booking.getTotalCharge())}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeutronTextFormField(
                        labelRequired: true,
                        isDecor: true,
                        borderColor: ColorManagement.white,
                        label: UITitleUtil.getTitleByCode(
                            UITitleCode.HEADER_TOTAL_WORDS),
                        controller: controller.amountInWordsTeController,
                      ),
                    ),
                  ]),
                ),
                NeutronButton(
                  icon: Icons.add,
                  onPressed: () async {
                    String result = controller.checkData();
                    if (result != MessageCodeUtil.SUCCESS) {
                      MaterialUtil.showAlert(context, result);
                    } else {
                      Navigator.pop(context, true);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
