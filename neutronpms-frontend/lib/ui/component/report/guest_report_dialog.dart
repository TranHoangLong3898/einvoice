import 'package:flutter/material.dart';
import 'package:ihotel/controller/report/guest_report_controller.dart';
import 'package:ihotel/modal/guest_report.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/messageulti.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutronblurbutton.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontexttilte.dart';
import '../../controls/neutronwaiting.dart';

class GuestReportDialog extends StatefulWidget {
  const GuestReportDialog({Key? key}) : super(key: key);

  @override
  State<GuestReportDialog> createState() => _GuestReportDialogState();
}

class _GuestReportDialogState extends State<GuestReportDialog> {
  GuestReportController? _guestReportController;
  @override
  void initState() {
    _guestReportController ??= GuestReportController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : (kWidth + 100);

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: width,
          height: kHeight,
          child: ChangeNotifierProvider<GuestReportController>.value(
            value: _guestReportController!,
            child: Consumer<GuestReportController>(
                builder: ((_, controller, child) => Scaffold(
                      backgroundColor: ColorManagement.mainBackground,
                      appBar: buildAppBar(isMobile),
                      body: Column(
                        children: [
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          isMobile ? buildTitleInMobile() : buildTitleInPC(),
                          const SizedBox(
                            height: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                              child: controller.isLoading
                                  ? child!
                                  : buildContent(isMobile)),
                          // NeutronButtonText(
                          //   text:
                          //       "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_GUEST_REPORT_TOTAL)}: ${NumberUtil.numberFormat.format(controller.getTotalGuest())}",
                          // )
                        ],
                      ),
                    )),
                child: const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor))),
          )),
    );
  }

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
        message: UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_GUEST_REPORT),
      ),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: _guestReportController!.startDate,
          firstDate:
              _guestReportController!.now.subtract(const Duration(days: 365)),
          lastDate: _guestReportController!.now.add(const Duration(days: 365)),
          onChange: _guestReportController!.setStartDate,
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: _guestReportController!.endDate,
          firstDate: _guestReportController!.startDate,
          lastDate:
              _guestReportController!.startDate.add(const Duration(days: 7)),
          onChange: _guestReportController!.setEndDate,
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: () {
            _guestReportController!.loadBasicBookings();
          },
        ),
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            showDialog(
                context: context, builder: (context) => const NeutronWaiting());
            final String result = _guestReportController!.exportToExcel();
            Navigator.pop(context);
            if (result.isNotEmpty) {
              MaterialUtil.showAlert(context, result);
            }
          },
        ),
      ],
    );
  }

  Widget buildTitleInPC() {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
                width: SizeManagement.cardInsideHorizontalPadding * 2),
            SizedBox(
              width: 90,
              child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATE),
                  maxLines: 2),
            ),
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_UNKNOWN),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                textAlign: TextAlign.center,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_DOMESTIC),
              ),
            ),
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                textAlign: TextAlign.center,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_GUEST_FOREIGN),
              ),
            ),
            SizedBox(
              width: 50,
              child: NeutronTextTitle(
                textAlign: TextAlign.center,
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
              ),
            ),
            const SizedBox(
                width: SizeManagement.cardInsideHorizontalPadding * 2),
          ],
        ),
        const SizedBox(
          height: SizeManagement.rowSpacing,
        ),
        Row(
          children: [
            const SizedBox(
                width: SizeManagement.cardInsideHorizontalPadding * 2),
            const SizedBox(
              width: 90,
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NEW_GUEST),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: SizeManagement.rowSpacing),
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_INHOUSE),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NEW_GUEST),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: SizeManagement.rowSpacing),
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_INHOUSE),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_NEW_GUEST),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: SizeManagement.rowSpacing),
                Expanded(
                  child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_INHOUSE),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            const SizedBox(
              width: 50,
            ),
            const SizedBox(
                width: SizeManagement.cardInsideHorizontalPadding * 2),
          ],
        )
      ],
    );
  }

  Widget buildTitleInMobile() {
    return Row(
      children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding * 2),
        SizedBox(
          width: 90,
          child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE),
              maxLines: 2),
        ),
        Expanded(
          child: NeutronTextTitle(
            textAlign: TextAlign.center,
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_TOTAL),
          ),
        ),
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding * 2),
      ],
    );
  }

  Widget buildContent(bool isMobile) {
    if (_guestReportController!.guestReports.isEmpty) {
      return Center(
          child: NeutronTextContent(
              message: MessageUtil.getMessageByCode(MessageCodeUtil.NO_DATA)));
    }
    return isMobile ? buildContentInMobile() : buildContentInPC();
  }

  ListView buildContentInMobile() {
    return ListView(
      children: _guestReportController!.guestReports
          .map((guestReport) =>
              GuestReportContentDetailInMobile(guestReport: guestReport!))
          .toList(),
    );
  }

  ListView buildContentInPC() {
    return ListView(
      children: [
        ..._guestReportController!.guestReports
            .map((guestReport) =>
                GuestReportContentDetailInPC(guestReport: guestReport!))
            .toList(),
        Container(
          height: SizeManagement.cardHeight,
          margin:
              const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
          child: Row(children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            const SizedBox(
              width: 85,
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalNewGuestUnknown()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.rowSpacing,
                ),
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalInhouseGuestUnknown()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalNewGuestDomestic()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.rowSpacing,
                ),
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalInhouseGuestDomestic()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalNewGuestForeign()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.cardOutsideHorizontalPadding,
                ),
                Expanded(
                  child: NeutronTextTitle(
                    color: ColorManagement.positiveText,
                    message: _guestReportController!
                        .getTotalInhouseGuestForeign()
                        .toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )),
            const SizedBox(
              width: 50,
              // child: NeutronTextTitle(
              //     color: ColorManagement.positiveText,
              //     message: _guestReportController.getTotalGuest().toString(),
              //     textAlign: TextAlign.center)
            ),
            const SizedBox(
              width: SizeManagement.rowSpacing + 2,
            ),
          ]),
        )
      ],
    );
  }
}

class GuestReportContentDetailInPC extends StatelessWidget {
  const GuestReportContentDetailInPC({Key? key, required this.guestReport})
      : super(key: key);

  final GuestReport guestReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeManagement.cardHeight,
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      margin: const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
      child: Row(children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
        SizedBox(
            width: 90,
            child: NeutronTextContent(
              message: DateUtil.dateToDayMonthYearString(guestReport.id),
            )),
        Expanded(
            child: Row(
          children: [
            Expanded(
              child: NeutronTextContent(
                message: guestReport.newGuestCountUnknown.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: SizeManagement.rowSpacing,
            ),
            Expanded(
              child: NeutronTextContent(
                message: guestReport.inhouseCountUnknown.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )),
        Expanded(
            child: Row(
          children: [
            Expanded(
              child: NeutronTextContent(
                  message: guestReport.newGuestCountDomestic.toString(),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(
              width: SizeManagement.rowSpacing,
            ),
            Expanded(
              child: NeutronTextContent(
                  message: guestReport.inhouseCountDomestic.toString(),
                  textAlign: TextAlign.center),
            ),
          ],
        )),
        Expanded(
            child: Row(
          children: [
            Expanded(
              child: NeutronTextContent(
                  message: guestReport.newGuestCountForeign.toString(),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(
              width: SizeManagement.rowSpacing,
            ),
            Expanded(
              child: NeutronTextContent(
                  message: guestReport.inhouseCountForeign.toString(),
                  textAlign: TextAlign.center),
            ),
          ],
        )),
        SizedBox(
            width: 50,
            child: NeutronTextContent(
                message: guestReport.getTotalGuest().toString(),
                textAlign: TextAlign.center)),
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
      ]),
    );
  }
}

class GuestReportContentDetailInMobile extends StatelessWidget {
  const GuestReportContentDetailInMobile({Key? key, required this.guestReport})
      : super(key: key);

  final GuestReport guestReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      margin: const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
      child: ExpansionTile(
        backgroundColor: ColorManagement.lightMainBackground,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding),
        childrenPadding:
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        leading: SizedBox(
          width: 90,
          child: NeutronTextContent(
              message: DateUtil.dateToDayMonthYearString(guestReport.id)),
        ),
        collapsedIconColor: ColorManagement.lightColorText,
        iconColor: ColorManagement.lightColorText,
        title: NeutronTextContent(
          textAlign: TextAlign.center,
          message: guestReport.getTotalGuest().toString(),
          tooltip: guestReport.getTotalGuest().toString(),
          fontSize: 15,
        ),
        children: [
          const SizedBox(height: 8),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ColorManagement.mainBackground,
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white10,
                  blurRadius: 10,
                  offset: Offset(5, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NeutronTextTitle(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GUEST_UNKNOWN),
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.rowSpacing,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NEW_GUEST)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport.newGuestCountUnknown
                                    .toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INHOUSE)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message:
                                    guestReport.inhouseCountUnknown.toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport
                                    .getTotalGuestUnknown()
                                    .toString()),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ColorManagement.mainBackground,
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white10,
                  blurRadius: 10,
                  offset: Offset(5, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NeutronTextTitle(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GUEST_DOMESTIC),
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.rowSpacing,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NEW_GUEST)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport.newGuestCountDomestic
                                    .toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INHOUSE)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport.inhouseCountDomestic
                                    .toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport
                                    .getTotalGuestDomestic()
                                    .toString()),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: ColorManagement.mainBackground,
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white10,
                  blurRadius: 10,
                  offset: Offset(5, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NeutronTextTitle(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GUEST_FOREIGN),
                  ),
                ),
                const SizedBox(
                  width: SizeManagement.rowSpacing,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NEW_GUEST)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport.newGuestCountForeign
                                    .toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INHOUSE)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message:
                                    guestReport.inhouseCountForeign.toString()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: NeutronTextContent(
                                message:
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} :"),
                          ),
                          const SizedBox(
                            width: SizeManagement.rowSpacing,
                          ),
                          Expanded(
                            child: NeutronTextContent(
                                message: guestReport
                                    .getTotalGuestForeign()
                                    .toString()),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
