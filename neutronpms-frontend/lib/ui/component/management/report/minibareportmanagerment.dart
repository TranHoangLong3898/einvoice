import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../controller/management/reportmanagement/reportminibarmanagercontroller.dart';
import '../../../../manager/minibarmanager.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/excelulti.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/numberutil.dart';
import '../../../controls/neutronbuttontext.dart';

class MinibarReporManagertDialog extends StatefulWidget {
  const MinibarReporManagertDialog({Key? key}) : super(key: key);

  @override
  State<MinibarReporManagertDialog> createState() =>
      _MinibarReporManagertDialogState();
}

class _MinibarReporManagertDialogState
    extends State<MinibarReporManagertDialog> {
  final MinibarReportManagerController controller =
      MinibarReportManagerController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    const height = kHeight;

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: ChangeNotifierProvider<MinibarReportManagerController>.value(
                value: controller,
                child: Consumer<MinibarReportManagerController>(
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
    if (controller.mapService.isEmpty) {
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
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_PRICE_TOTAL),
            ),
          ),
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
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT),
            ),
          ),
        ],
      ),
    );
  }

  List<Container> buildContentInPC() {
    return controller.mapService.entries.map((e) {
      return Container(
        height: SizeManagement.cardHeight,
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideVerticalPadding),
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Row(
          children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            Expanded(
              child: NeutronTextContent(
                  message:
                      MinibarManager().getItemNameByID(e.key.split("-")[1])),
            ),
            Expanded(child: NeutronTextContent(message: e.value.toString())),
            Expanded(
                child: NeutronTextContent(
                    message: NumberUtil.numberFormat
                        .format(double.parse(e.key.split("-")[0])))),
            Expanded(
                child: NeutronTextContent(
                    message: NumberUtil.numberFormat
                        .format(double.parse(e.key.split("-")[0]) * e.value))),
          ],
        ),
      );
    }).toList();
  }

  List<Container> buildContentInMobile() {
    return controller.mapService.entries
        .map((e) => Container(
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
                          message: MinibarManager()
                              .getItemNameByID(e.key.split("-")[1])),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: NeutronTextContent(
                          message: NumberUtil.numberFormat
                              .format(double.parse(e.key.split("-")[0]))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: NeutronTextContent(message: e.value.toString())),
                  ],
                ),
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 15, top: 15),
                        child: Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE_TOTAL),
                            )),
                            Expanded(
                              flex: 2,
                              child: NeutronTextContent(
                                  message: NumberUtil.numberFormat.format(
                                      double.parse(e.key.split("-")[0]) *
                                          e.value)),
                            )
                          ],
                        ),
                      ),
                    ],
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
              .add(Duration(days: controller.maxTimePeriod!)),
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
            if (controller.mapService.isEmpty) return;
            ExcelUlti.exportMinibarReport(
                controller.startDate,
                controller.endDate,
                controller.mapService,
                controller.mapMinibar);
          },
        )
      ],
    );
  }
}
