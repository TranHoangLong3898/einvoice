import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:provider/provider.dart';

import '../../../controller/booking/logboookingcontroller.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutrontextcontent.dart';

class LogBookingDialog extends StatelessWidget {
  final Booking? booking;
  final bool isGroup;
  LogBookingDialog({Key? key, this.booking, this.isGroup = false})
      : super(key: key);

  final LogBookingController controller = LogBookingController();
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kWidth;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: kHeight,
        child: ChangeNotifierProvider(
          create: (context) => controller,
          child: Consumer<LogBookingController>(
            builder: (context, controller, child) {
              return Column(children: [
                const SizedBox(height: SizeManagement.topHeaderTextSpacing),
                NeutronTextHeader(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.HEADER_LOG_BOOKING)),
                const SizedBox(height: SizeManagement.topHeaderTextSpacing),
                isMobile ? buildTitleMobile() : buildTitlePc(),
                Expanded(
                    child: controller.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.green))
                        : ListView(
                            children: controller
                                .getLogBooking(booking!, isGroup)
                                .map((e) => isMobile
                                    ? buildContentMobile(e)
                                    : buildContentPc(e))
                                .toList(),
                          ))
              ]);
            },
          ),
        ),
      ),
    );
  }

  Container buildContentMobile(String e) => Container(
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
                          tooltip: controller.activities[e]!.decodeDesc(),
                          message: controller.activities[e]!.decodeDesc()))
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
                        UITitleCode.TABLEHEADER_CREATOR),
                  )),
                  Expanded(
                    child: NeutronTextContent(
                        tooltip: controller.activities[e]!.email,
                        message: controller.activities[e]!.email),
                  )
                ],
              ),
            ),
            const SizedBox(height: SizeManagement.cardOutsideVerticalPadding)
          ],
        ),
      );

  Container buildContentPc(String e) => Container(
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
                  tooltip: controller.activities[e]!.decodeDesc(),
                  message: controller.activities[e]!.decodeDesc()),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            SizedBox(
              width: 50,
              child: NeutronTextContent(
                  textAlign: TextAlign.center,
                  message: controller.activities[e]!.type),
            ),
            const SizedBox(width: SizeManagement.cardOutsideHorizontalPadding),
            Expanded(
              child: NeutronTextContent(
                  tooltip: controller.activities[e]!.email,
                  message: controller.activities[e]!.email),
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
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
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

  Container buildTitlePc() => Container(
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
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATED_TIME)),
            ),
            Expanded(
              flex: 2,
              child: NeutronTextTitle(
                  textAlign: TextAlign.left,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_DESCRIPTION_FULL)),
            ),
            SizedBox(
              width: 50,
              child: NeutronTextTitle(
                  textAlign: TextAlign.center,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE)),
            ),
            Expanded(
              child: NeutronTextTitle(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_CREATOR)),
            ),
          ],
        ),
      );
}
