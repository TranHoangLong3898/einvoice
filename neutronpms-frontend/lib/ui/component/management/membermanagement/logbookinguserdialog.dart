import 'package:flutter/material.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/ui/component/booking/bookingdialog.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/booking/logboookingcontroller.dart';
import '../../../../manager/generalmanager.dart';
import '../../../../modal/hoteluser.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontexttilte.dart';
import '../../booking/depositdialog.dart';
import '../../service/servicedialog.dart';

class LogBookingUserDialog extends StatelessWidget {
  final HotelUser? user;
  LogBookingUserDialog({Key? key, this.user}) : super(key: key);

  final LogBookingController controller = LogBookingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kWidth;
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            height: kHeight,
            width: width,
            child: ChangeNotifierProvider(
              create: (context) => controller,
              child: Consumer<LogBookingController>(
                builder: (_, controller, __) => Scaffold(
                    backgroundColor: ColorManagement.mainBackground,
                    appBar: AppBar(
                        title: isMobile
                            ? null
                            : NeutronTextHeader(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_LOG_BOOKING)),
                        actions: [
                          NeutronDatePicker(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_START_DATE),
                            initialDate: controller.startDate,
                            firstDate: controller.now
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                controller.now.add(const Duration(days: 365)),
                            onChange: controller.setStartDate,
                          ),
                          NeutronDatePicker(
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_END_DATE),
                              initialDate: controller.endDate,
                              firstDate: controller.startDate,
                              lastDate: controller.startDate
                                  .add(const Duration(days: 7)),
                              onChange: controller.setEndDate),
                        ]),
                    body: Column(children: [
                      const SizedBox(
                          height: SizeManagement.cardOutsideVerticalPadding),
                      isMobile ? buildTitleMobile() : buildTitlePc(),
                      Expanded(
                          child: controller.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.green))
                              : ListView(
                                  children: controller
                                      .getLogBookingUserByDate(user!.email!)
                                      .map((e) => isMobile
                                          ? buildContentMobile(e, context)
                                          : buildContentPc(e, context))
                                      .toList(),
                                ))
                    ])),
              ),
            )));
  }

  Container buildContentMobile(String e, BuildContext context) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideHorizontalPadding),
        child: ExpansionTile(
          title: Row(children: [
            Expanded(
              child: NeutronTextContent(
                  message: DateUtil.dateToDayMonthYearHourMinuteString(
                      controller.activities[e]!.createdTime.toDate())),
            ),
            SizedBox(
              width: 50,
              child:
                  NeutronTextContent(message: controller.activities[e]!.type),
            )
          ]),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardOutsideHorizontalPadding),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                        tooltip:
                            "${controller.activities[e]!.decodeDesc()} ${MessageUtil.getMessageByCode(MessageCodeUtil.PERFORMED_BY)} ${user!.fullname}",
                        message:
                            "${controller.activities[e]!.decodeDesc()} ${MessageUtil.getMessageByCode(MessageCodeUtil.PERFORMED_BY)} ${user!.fullname}"),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  SizeManagement.cardOutsideHorizontalPadding,
                  0),
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardOutsideHorizontalPadding),
              child: Row(
                children: [
                  Expanded(
                      child: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DETAIL),
                  )),
                  Expanded(
                    child: controller.activities[e]!.bookingId == ""
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () async => {
                              await controller
                                  .getBookingDetailByID(
                                      controller.activities[e]!.bookingId,
                                      controller.activities[e]!.type)
                                  .then((value) {
                                if (value == null) return "";
                                if (controller.activities[e]!.type ==
                                    "deposit") {
                                  return showDialog(
                                      context: context,
                                      builder: (context) =>
                                          DepositDialog(booking: value));
                                } else if (controller.activities[e]!.type ==
                                    "service") {
                                  return showDialog(
                                      context: context,
                                      builder: (context) => ServiceDialog(
                                            booking: value,
                                          ));
                                } else {
                                  return showDialog(
                                      context: context,
                                      builder: (context) =>
                                          BookingDialog(booking: value));
                                }
                              })
                            },
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.POPUPMENU_OPEN),
                            icon: Icon(
                              Icons.visibility,
                              color: ColorManagement.iconMenuEnableColor,
                              size: GeneralManager.iconMenuSize,
                            ),
                          ),
                  )
                ],
              ),
            ),
            const SizedBox(height: SizeManagement.cardOutsideVerticalPadding)
          ],
        ),
      );

  Container buildContentPc(String e, BuildContext context) => Container(
        margin: const EdgeInsets.only(
            right: SizeManagement.cardOutsideHorizontalPadding,
            left: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.cardOutsideHorizontalPadding),
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideHorizontalPadding),
        height: SizeManagement.cardHeight,
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.avatarCircle)),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: NeutronTextContent(
                  message: DateUtil.dateToDayMonthYearHourMinuteString(
                      controller.activities[e]!.createdTime.toDate())),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            Expanded(
              flex: 2,
              child: NeutronTextContent(
                tooltip:
                    "${controller.activities[e]!.decodeDesc()} ${MessageUtil.getMessageByCode(MessageCodeUtil.PERFORMED_BY)} ${user!.fullname}",
                message:
                    "${controller.activities[e]!.decodeDesc()} ${MessageUtil.getMessageByCode(MessageCodeUtil.PERFORMED_BY)} ${user!.fullname}",
              ),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 50,
              child:
                  NeutronTextContent(message: controller.activities[e]!.type),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
                width: 50,
                child: controller.activities[e]!.bookingId == ""
                    ? null
                    : IconButton(
                        onPressed: () async => {
                          await controller
                              .getBookingDetailByID(
                                  controller.activities[e]!.bookingId,
                                  controller.activities[e]!.type)
                              .then((Booking? value) {
                            if (value == null) return "";
                            if (controller.activities[e]!.type == "deposit") {
                              return showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DepositDialog(booking: value));
                            } else if (controller.activities[e]!.type ==
                                "service") {
                              return showDialog(
                                  context: context,
                                  builder: (context) => ServiceDialog(
                                        booking: value,
                                      ));
                            } else {
                              return showDialog(
                                  context: context,
                                  builder: (context) =>
                                      BookingDialog(booking: value));
                            }
                          })
                        },
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.POPUPMENU_OPEN),
                        icon: Icon(
                          Icons.visibility,
                          color: ColorManagement.iconMenuEnableColor,
                          size: GeneralManager.iconMenuSize,
                        ),
                      ))
          ],
        ),
      );

  Container buildTitlePc() => Container(
        margin: const EdgeInsets.only(
            right: SizeManagement.cardOutsideHorizontalPadding,
            left: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.cardOutsideHorizontalPadding),
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideHorizontalPadding),
        height: SizeManagement.cardHeight,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: NeutronTextTitle(
                  isPadding: false,
                  textAlign: TextAlign.left,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATED_TIME)),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            Expanded(
              flex: 2,
              child: NeutronTextTitle(
                  isPadding: false,
                  textAlign: TextAlign.left,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DESCRIPTION_FULL)),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 50,
              child: NeutronTextTitle(
                  isPadding: false,
                  textAlign: TextAlign.left,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE)),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 50,
              child: NeutronTextTitle(
                  isPadding: false,
                  textAlign: TextAlign.left,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DETAIL)),
            ),
          ],
        ),
      );

  Container buildTitleMobile() => Container(
        margin: const EdgeInsets.only(
            right: SizeManagement.cardOutsideHorizontalPadding,
            left: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.cardOutsideHorizontalPadding),
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardInsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideHorizontalPadding),
        height: SizeManagement.cardHeight,
        child: Row(
          children: [
            Expanded(
              child: NeutronTextTitle(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATED_TIME)),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 95,
              child: NeutronTextTitle(
                  isPadding: false,
                  textAlign: TextAlign.left,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE)),
            ),
          ],
        ),
      );
}
