import 'package:flutter/material.dart';
import 'package:ihotel/controller/report/revenue_by_date_controller.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutronbuttontext.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrontablecell.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';
import '../../controls/neutronwaiting.dart';
import '../service/room_type_form.dart';
import 'detailrevenuebydatereport.dart';

class RevenueByDateReportDialog extends StatefulWidget {
  const RevenueByDateReportDialog({Key? key}) : super(key: key);

  @override
  State<RevenueByDateReportDialog> createState() =>
      _RevenueByDateReportDialogState();
}

class _RevenueByDateReportDialogState extends State<RevenueByDateReportDialog> {
  RevenueByDateController? _revenueByDateController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _revenueByDateController ??= RevenueByDateController();
    super.initState();
  }

  @override
  void dispose() {
    _revenueByDateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : (kLargeWidth + 440);
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
          width: width,
          height: kHeight,
          child: ChangeNotifierProvider<RevenueByDateController>.value(
              value: _revenueByDateController!,
              child: Consumer<RevenueByDateController>(
                child: const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor)),
                builder: (_, controller, child) => Scaffold(
                    floatingActionButton: floatingActionButton(controller),
                    backgroundColor: ColorManagement.mainBackground,
                    appBar: buildAppBar(isMobile),
                    body: Scrollbar(
                      controller: _scrollController,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      thickness: 13,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: width,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: SizeManagement.rowSpacing,
                              ),
                              isMobile ? buildTitleMobile() : buildTitlePc(),
                              const SizedBox(
                                height: SizeManagement.rowSpacing,
                              ),
                              Expanded(
                                  child: controller.isLoading
                                      ? child!
                                      : ListView(
                                          children: isMobile
                                              ? buildListMobile(controller)
                                              : buildListPc(controller),
                                        )),
                              NeutronButtonText(
                                text:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.getTotal())}",
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
              )),
        ));
  }

  FloatingActionButton floatingActionButton(
          RevenueByDateController controller) =>
      FloatingActionButton(
        backgroundColor: ColorManagement.lightMainBackground,
        mini: true,
        tooltip: UITitleUtil.getTitleByCode(
            UITitleCode.TOOLTIP_REVENUE_BY_DATE_REPORT_DETAI),
        onPressed: () async {
          await controller.getTotalAllRevenueByDate().then((value) {
            return showDialog(
              context: context,
              builder: (context) => DetailRevenueByDateReportDialog(
                controller: controller,
              ),
            );
          });
        },
        child: const Icon(Icons.description_sharp),
      );

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
        message:
            UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_REVENUE_BY_DATE),
      ),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: _revenueByDateController!.startDate,
          firstDate:
              _revenueByDateController!.now.subtract(const Duration(days: 365)),
          lastDate:
              _revenueByDateController!.now.add(const Duration(days: 365)),
          onChange: _revenueByDateController!.setStartDate,
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: _revenueByDateController!.endDate,
          firstDate: _revenueByDateController!.startDate,
          lastDate:
              _revenueByDateController!.startDate.add(const Duration(days: 30)),
          onChange: _revenueByDateController!.setEndDate,
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: () {
            _revenueByDateController!.loadRevenueByDate();
          },
        ),
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            showDialog(
                context: context, builder: (context) => const NeutronWaiting());
            final String result = _revenueByDateController!.exportToExcel();
            Navigator.pop(context);
            if (result.isNotEmpty) {
              MaterialUtil.showAlert(context, result);
            }
          },
        ),
      ],
    );
  }

  Container buildTitlePc() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: SizedBox(
              width: 115,
              child: NeutronTextTitle(
                isPadding: false,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
              ),
            ),
          ),
          SizedBox(
              width: 75,
              child: NeutronTextTitle(
                isPadding: false,
                textAlign: TextAlign.center,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_ROOM_QUANTITY),
              )),
          SizedBox(
              width: 75,
              child: NeutronTextTitle(
                isPadding: false,
                textAlign: TextAlign.center,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_QUANTITY),
              )),
          SizedBox(
              width: 120,
              child: NeutronTextTitle(
                isPadding: false,
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_ROOM_CHARGE_TOTAL),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE_COMPACT),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE_COMPACT),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_RESTAURANT),
              )),
          SizedBox(
              width: 150,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
              )),
          SizedBox(
              width: 90,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_ELECTRICITY_WATER),
              )),
          SizedBox(
              width: 95,
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                fontSize: 13,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DISCOUNT),
              )),
          Expanded(
              child: NeutronTextTitle(
            textAlign: TextAlign.end,
            fontSize: 13,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
          )),
        ],
      ),
    );
  }

  Container buildTitleMobile() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Row(
        children: [
          const SizedBox(
            width: SizeManagement.cardOutsideHorizontalPadding,
          ),
          SizedBox(
            width: 115,
            child: NeutronTextContent(
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
            ),
          ),
        ],
      ),
    );
  }

  List<Container> buildListPc(RevenueByDateController controller) {
    return controller.contentRender.entries
        .map((contentRender) => Container(
              height: SizeManagement.cardHeight,
              margin: const EdgeInsets.symmetric(
                  vertical: SizeManagement.cardOutsideVerticalPadding,
                  horizontal: SizeManagement.cardOutsideHorizontalPadding),
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: SizeManagement.cardInsideHorizontalPadding),
                    child: SizedBox(
                      width: 115,
                      child: NeutronTextContent(
                        message: contentRender.key,
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 75,
                      child: NeutronTextContent(
                        textAlign: TextAlign.center,
                        message: contentRender.value['num'].toString(),
                      )),
                  SizedBox(
                      width: 75,
                      child: NeutronTextContent(
                        textAlign: TextAlign.center,
                        message: contentRender.value['guest'].toString(),
                      )),
                  SizedBox(
                      width: 120,
                      child: NeutronFormOpenCell(
                        textAlign: TextAlign.end,
                        context: context,
                        form: RoomTypeFormDetails(
                            mapRoomTypes: contentRender.value['details']),
                        text: NumberUtil.numberFormat
                            .format(contentRender.value['room_charge'])
                            .toString(),
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['minibar'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['extra_hours'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['extra_guest'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['laundry'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['bike_rental'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['other'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['restaurant'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 150,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['inside_restaurant'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 90,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['electricity_water'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      )),
                  SizedBox(
                      width: 95,
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['discount'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.negativeText,
                      )),
                  Expanded(
                    child: NeutronTextContent(
                      message: NumberUtil.numberFormat
                          .format(contentRender.value['total'])
                          .toString(),
                      textAlign: TextAlign.end,
                      color: ColorManagement.positiveText,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  List<Widget> buildListMobile(RevenueByDateController controller) {
    return controller.contentRender.entries
        .map((contentRender) => Container(
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
                      width: 115,
                      child: NeutronTextContent(
                        message: contentRender.key,
                      ),
                    ),
                    const SizedBox(
                      width: SizeManagement.rowSpacing,
                    ),
                    Expanded(
                      child: NeutronTextContent(
                        message: NumberUtil.numberFormat
                            .format(contentRender.value['total'])
                            .toString(),
                        textAlign: TextAlign.end,
                        color: ColorManagement.positiveText,
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            SizeManagement.cardOutsideHorizontalPadding),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ROOM_QUANTITY),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  message:
                                      contentRender.value['num'].toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_GUEST_QUANTITY),
                            )),
                            Expanded(
                                child: NeutronTextContent(
                                    textAlign: TextAlign.center,
                                    message: contentRender.value['guest']
                                        .toString())),
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ROOM_CHARGE_TOTAL),
                            )),
                            Expanded(
                              child: NeutronFormOpenCell(
                                textAlign: TextAlign.center,
                                context: context,
                                form: RoomTypeFormDetails(
                                    mapRoomTypes:
                                        contentRender.value['details']),
                                text: NumberUtil.numberFormat
                                    .format(contentRender.value['room_charge'])
                                    .toString(),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender.value['minibar'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_EXTRA_HOUR_SERVICE_COMPACT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(
                                          contentRender.value['extra_hours'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_EXTRA_GUEST_SERVICE_COMPACT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(
                                          contentRender.value['extra_guest'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender.value['laundry'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                textAlign: TextAlign.center,
                                color: ColorManagement.positiveText,
                                message: NumberUtil.numberFormat
                                    .format(contentRender.value['bike_rental'])
                                    .toString(),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_OTHER),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender.value['other'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_RESTAURANT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender.value['restaurant'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender
                                          .value['inside_restaurant'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ELECTRICITY_WATER),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.positiveText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender
                                          .value['electricity_water'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  textAlign: TextAlign.center,
                                  color: ColorManagement.negativeText,
                                  message: NumberUtil.numberFormat
                                      .format(contentRender.value['discount'])
                                      .toString()),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: SizeManagement.rowSpacing,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
        .toList();
  }
}
