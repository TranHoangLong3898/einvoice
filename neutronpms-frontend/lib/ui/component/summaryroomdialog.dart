import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/summaryroomcontroller.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/ui/component/service/costform.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';

import '../../util/dateutil.dart';
import '../../util/numberutil.dart';
import '../../util/responsiveutil.dart';
import '../../util/uimultilanguageutil.dart';
import '../controls/neutronblurbutton.dart';
import '../controls/neutronbookingcontextmenu.dart';
import '../controls/neutrondatepicker.dart';
import '../controls/neutrontextcontent.dart';
import 'costroomdialog.dart';

class SummaryRoomDialog extends StatefulWidget {
  final String idRom;
  const SummaryRoomDialog({Key? key, required this.idRom}) : super(key: key);

  @override
  State<SummaryRoomDialog> createState() => _SummaryRoomDialogState();
}

class _SummaryRoomDialogState extends State<SummaryRoomDialog> {
  late SummaryRoomController summaryRoomController;
  @override
  void initState() {
    summaryRoomController = SummaryRoomController(widget.idRom);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kWidth;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: kHeight,
        child: ChangeNotifierProvider(
          create: (context) => summaryRoomController,
          child: Consumer<SummaryRoomController>(
            builder: (_, controller, __) => controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor))
                : Scaffold(
                    backgroundColor: ColorManagement.mainBackground,
                    appBar: buildAppBar(isMobile),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: SizeManagement.cardHeight,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground),
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeutronTextContent(
                                      textOverflow: TextOverflow.clip,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_REVENUE)),
                                ),
                                Expanded(
                                  child: NeutronTextContent(
                                      message: NumberUtil.numberFormat.format(
                                          controller.totalAllChargeBooking)),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await showDialog<String>(
                                  builder: (ctx) => CostRoomDialog(
                                      idRom: widget.idRom,
                                      startDate: controller.startDate,
                                      endDate: controller.endDate),
                                  context: context);
                            },
                            child: Container(
                              height: SizeManagement.cardHeight,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground),
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: NeutronTextContent(
                                        textOverflow: TextOverflow.clip,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_COST_OF_THE_ROOM)),
                                  ),
                                  Expanded(
                                    child: NeutronTextContent(
                                        message: NumberUtil.numberFormat
                                            .format(controller.totalCostRoom)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground),
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.only(left: 8),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: NeutronTextContent(
                                        textOverflow: TextOverflow.clip,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_COST_OF_BOOKINGS)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: NeutronTextContent(
                                          message: NumberUtil.numberFormat
                                              .format(
                                                  controller.totalCostBooke)),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  height: 45,
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: ColorManagement.mainBackground,
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: NeutronTextContent(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NAME))),
                                      if (!isMobile) ...[
                                        Expanded(
                                            child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_IN),
                                        )),
                                        Expanded(
                                            child: NeutronTextContent(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_OUT),
                                        ))
                                      ],
                                      const Expanded(
                                          child: NeutronTextContent(
                                        message: "Cost",
                                      )),
                                      Expanded(
                                          child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PAYMENT),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PAYMENT),
                                      )),
                                      Expanded(
                                          child: NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_REMAIN),
                                      )),
                                      const SizedBox(width: 30)
                                    ],
                                  ),
                                ),
                                ...controller.bookings
                                    .map((e) => InkWell(
                                          onTap: () async {
                                            await showDialog<String>(
                                                builder: (ctx) =>
                                                    CostBookingDialog(
                                                        booking: e),
                                                context: context);
                                          },
                                          child: Container(
                                            height: SizeManagement.cardHeight,
                                            padding: const EdgeInsets.all(8),
                                            margin: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    top: BorderSide(
                                                        color: Color.fromARGB(
                                                            255, 75, 77, 82)))),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  message: e.name!,
                                                )),
                                                if (!isMobile) ...[
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                    message: DateUtil
                                                        .dateToDayMonthString(
                                                            e.inDate!),
                                                  )),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                    message: DateUtil
                                                        .dateToDayMonthString(
                                                            e.outDate!),
                                                  ))
                                                ],
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  message: NumberUtil
                                                      .moneyFormat
                                                      .format(controller
                                                          .dataCost[e.id]),
                                                )),
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  message: NumberUtil
                                                      .moneyFormat
                                                      .format(e.deposit),
                                                )),
                                                Expanded(
                                                    child: NeutronTextContent(
                                                  message: NumberUtil
                                                      .moneyFormat
                                                      .format(e.getRemaining()),
                                                )),
                                                SizedBox(
                                                    width: 30,
                                                    child:
                                                        NeutronBookingContextMenu(
                                                      icon: Icons.menu_outlined,
                                                      booking: e,
                                                      backgroundColor:
                                                          ColorManagement
                                                              .lightMainBackground,
                                                      tooltip: UITitleUtil
                                                          .getTitleByCode(
                                                              UITitleCode
                                                                  .TOOLTIP_MENU),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                          Container(
                            height: SizeManagement.cardHeight,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeManagement.borderRadius8),
                                color: ColorManagement.lightMainBackground),
                            margin: const EdgeInsets.symmetric(
                                vertical:
                                    SizeManagement.cardOutsideVerticalPadding,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeutronTextContent(
                                      textOverflow: TextOverflow.clip,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PROFIT)),
                                ),
                                Expanded(
                                  child: NeutronTextContent(
                                      message: NumberUtil.numberFormat.format(
                                          controller.totalAllChargeBooking -
                                              controller
                                                  .totalCostBookingAndRoom)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(bool isMobile) {
    return AppBar(
      leadingWidth: isMobile ? 0 : 56,
      leading: isMobile ? Container() : null,
      title: NeutronTextContent(
          message:
              "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUMMARY_OF_ROOM)} - ${RoomManager().getNameRoomById(widget.idRom)}"),
      backgroundColor: ColorManagement.mainBackground,
      actions: [
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_START_DATE),
          initialDate: summaryRoomController.startDate,
          firstDate:
              summaryRoomController.now.subtract(const Duration(days: 365)),
          lastDate: summaryRoomController.now.add(const Duration(days: 365)),
          onChange: summaryRoomController.setStartDate,
        ),
        NeutronDatePicker(
          isMobile: isMobile,
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_END_DATE),
          initialDate: summaryRoomController.endDate,
          firstDate: summaryRoomController.startDate,
          lastDate:
              summaryRoomController.startDate.add(const Duration(days: 30)),
          onChange: summaryRoomController.setEndDate,
        ),
        NeutronBlurButton(
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REFRESH),
          icon: Icons.refresh,
          onPressed: summaryRoomController.loadCost,
        ),
      ],
    );
  }
}
