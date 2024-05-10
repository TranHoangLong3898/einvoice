import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/adminmanager/paymentpackageversioncontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/paymentpackageversion.dart';
import 'package:ihotel/ui/component/admin/paymentpackage/addpaymentpackagedialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class PaymentPackageDialog extends StatefulWidget {
  const PaymentPackageDialog({super.key});

  @override
  State<PaymentPackageDialog> createState() => _PaymentPackageDialogState();
}

class _PaymentPackageDialogState extends State<PaymentPackageDialog> {
  late PaymentPackageController paymentPackageController;

  @override
  void initState() {
    paymentPackageController = PaymentPackageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kLargeWidth;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: width,
          height: kHeight,
          child: ChangeNotifierProvider.value(
            value: paymentPackageController,
            child: Consumer<PaymentPackageController>(
              builder: (_, controller, __) => Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                    actions: [
                      NeutronDatePicker(
                        isMobile: isMobile,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_START_DATE),
                        initialDate: controller.startDate,
                        firstDate:
                            controller.now.subtract(const Duration(days: 365)),
                        lastDate: controller.now.add(const Duration(days: 365)),
                        onChange: controller.setStartDate,
                      ),
                      NeutronDatePicker(
                        isMobile: isMobile,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_END_DATE),
                        initialDate: controller.endDate,
                        firstDate: controller.startDate,
                        lastDate:
                            controller.startDate.add(const Duration(days: 30)),
                        onChange: controller.setEndDate,
                      ),
                      NeutronBlurButton(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_REFRESH),
                        icon: Icons.refresh,
                        onPressed: controller.loadPaymentPackage,
                      ),
                    ],
                    title: Text(UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PAYMENT_PACKAGES))),
                body: Column(children: [
                  Container(
                    margin: const EdgeInsets.only(
                        right: SizeManagement.cardInsideHorizontalPadding,
                        top: SizeManagement.cardOutsideVerticalPadding,
                        left: SizeManagement.cardInsideHorizontalPadding),
                    height: SizeManagement.cardHeight,
                    child: Row(children: [
                      Expanded(
                          flex: 2,
                          child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CREATED_TIME))),
                      Expanded(
                          child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TRADING_CODE))),
                      if (isMobile) const SizedBox(width: 60),
                      if (!isMobile) ...[
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_DESCRIPTION_FULL))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PRICE_TOTAL))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STILL_IN_DEBET))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PACKAGE))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CREATOR))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_METHOD))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_BANK))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STATUS)))
                      ]
                    ]),
                  ),
                  Expanded(
                      child: controller.isLoading!
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: ColorManagement.greenColor,
                              ),
                            )
                          : controller.paymentPackageVersion.isEmpty
                              ? const SizedBox()
                              : SingleChildScrollView(
                                  child: Column(
                                      children: controller.paymentPackageVersion
                                          .map((e) => isMobile
                                              ? buildContentMobile(e)
                                              : buildContentPC(e))
                                          .toList()),
                                )),
                  pagination,
                  SizedBox(
                    height: 60,
                    child: NeutronBlurButton(
                      margin: 5,
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const AddPayementPackageDialog());
                      },
                    ),
                  )
                ]),
              ),
            ),
          )),
    );
  }

  Widget buildContentMobile(PaymentPackageVersion e) => InkWell(
        onTap: () {
          if (e.amount == e.stillInDebt) return;
          showDialog(
              context: context,
              builder: (context) =>
                  AddPayementPackageDialog(packageVersion: e));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.only(
              left: SizeManagement.cardOutsideHorizontalPadding,
              right: SizeManagement.cardOutsideHorizontalPadding,
              bottom: SizeManagement.bottomFormFieldSpacing),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: NeutronTextContent(
                        message: DateUtil.dateToDayMonthYearHourMinuteString(
                            e.created!))),
                Expanded(
                    child: NeutronTextContent(message: e.tradingCode ?? "")),
              ],
            ),
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            tooltip: e.desc, message: e.desc ?? "")),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: NumberUtil.numberFormat.format(e.amount))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_STILL_IN_DEBET),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            color: (e.amount! - e.stillInDebt!) > 0
                                ? ColorManagement.redColor
                                : null,
                            message: NumberUtil.numberFormat
                                .format((e.amount! - e.stillInDebt!)))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PACKAGE),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: GeneralManager
                                .hotel?.packageVersion?[e.package]["desc"])),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_CREATOR),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            tooltip: e.creater, message: e.creater ?? ""))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_METHOD),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: PaymentMethodManager()
                                .getPaymentMethodNameById(e.method!))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_BANK),
                    )),
                    Expanded(
                        child: NeutronTextContent(message: e.nameBank ?? "")),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_STATUS),
                    )),
                    Expanded(child: NeutronTextContent(message: e.status ?? ""))
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

  Widget buildContentPC(PaymentPackageVersion e) => InkWell(
        onTap: () {
          if (e.amount == e.stillInDebt) return;
          showDialog(
              context: context,
              builder: (context) =>
                  AddPayementPackageDialog(packageVersion: e));
        },
        child: Container(
          margin: const EdgeInsets.only(
              right: SizeManagement.cardInsideHorizontalPadding,
              top: SizeManagement.cardOutsideVerticalPadding,
              left: SizeManagement.cardInsideHorizontalPadding),
          padding: const EdgeInsets.only(left: 10),
          height: SizeManagement.cardHeight,
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          child: Row(children: [
            Expanded(
                flex: 2,
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthYearHourMinuteString(
                        e.created!))),
            Expanded(child: NeutronTextContent(message: e.tradingCode ?? "")),
            Expanded(
                child:
                    NeutronTextContent(tooltip: e.desc, message: e.desc ?? "")),
            Expanded(
                child: NeutronTextContent(
                    message: NumberUtil.numberFormat.format(e.amount))),
            Expanded(
                child: NeutronTextContent(
                    color: (e.amount! - e.stillInDebt!) > 0
                        ? ColorManagement.redColor
                        : null,
                    message: NumberUtil.numberFormat
                        .format((e.amount! - e.stillInDebt!)))),
            Expanded(
                child: NeutronTextContent(
                    message: GeneralManager.hotel?.packageVersion?[e.package]
                        ["desc"])),
            Expanded(
                child: NeutronTextContent(
                    tooltip: e.creater, message: e.creater ?? "")),
            Expanded(
                child: NeutronTextContent(
                    message: PaymentMethodManager()
                        .getPaymentMethodNameById(e.method!))),
            Expanded(child: NeutronTextContent(message: e.nameBank ?? "")),
            Expanded(child: NeutronTextContent(message: e.status ?? "")),
          ]),
        ),
      );

  Row get pagination => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: paymentPackageController.getPaymentPackageFirstPage,
              icon: const Icon(Icons.skip_previous)),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: paymentPackageController.getPaymentPackagePreviousPage,
              icon: const Icon(
                Icons.navigate_before_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: paymentPackageController.getPaymentPackageNextPage,
              icon: const Icon(
                Icons.navigate_next_sharp,
              )),
          IconButton(
              splashRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: paymentPackageController.getPaymentPackageLastPage,
              icon: const Icon(Icons.skip_next)),
        ],
      );
}
