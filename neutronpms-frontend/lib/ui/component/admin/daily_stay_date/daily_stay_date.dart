import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/responsiveutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronblurbutton.dart';
import '../../../controls/neutronbuttontext.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontextstyle.dart';
import '../../../controls/neutrontexttilte.dart';
import 'daily_stay_date_controller.dart';

class DailyStayDatesDialog extends StatefulWidget {
  const DailyStayDatesDialog({Key? key}) : super(key: key);

  @override
  State<DailyStayDatesDialog> createState() => _DailyStayDateStateDialog();
}

class _DailyStayDateStateDialog extends State<DailyStayDatesDialog> {
  DailyStayDatesController? _dailyStayDatesController;

  @override
  void initState() {
    super.initState();
    _dailyStayDatesController ??= DailyStayDatesController();
  }

  @override
  void dispose() {
    _dailyStayDatesController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth;
    }

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<DailyStayDatesController>.value(
          value: _dailyStayDatesController!,
          child:
              Consumer<DailyStayDatesController>(builder: (_, controller, __) {
            return Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  title: const NeutronTextContent(
                    message: 'Daily Stay Date',
                  ),
                  backgroundColor: ColorManagement.mainBackground,
                  actions: [
                    NeutronDatePicker(
                      isMobile: isMobile,
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_START_DATE),
                      initialDate: controller.staysDate,
                      firstDate: controller.staysDate!
                          .subtract(const Duration(days: 365)),
                      lastDate:
                          controller.staysDate!.add(const Duration(days: 365)),
                      onChange: (picked) {
                        controller.setStayDates(picked);
                      },
                    ),
                    NeutronBlurButton(
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_REFRESH),
                      icon: Icons.refresh,
                      onPressed: () {
                        controller.loadBasicBookings();
                      },
                    )
                  ],
                ),
                body: Column(
                  children: [
                    //title
                    !isMobile
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding,
                            ),
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardInsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_CREATE),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SOURCE),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                    )),
                                SizedBox(
                                    width: 60,
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ROOM),
                                    )),
                                Expanded(
                                    child: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_IN),
                                )),
                                Expanded(
                                    child: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_OUT),
                                )),
                                SizedBox(
                                    width: 50,
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      fontSize: 14,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_STATUS),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: NeutronTextTitle(
                                      textAlign: TextAlign.end,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE),
                                    )),
                                // const SizedBox(width: 50)
                              ],
                            ),
                          )
                        : Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding *
                                    2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeutronTextContent(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: NeutronTextContent(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_IN),
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_IN),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: NeutronTextContent(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TOOLTIP_LENGTH_STAY),
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TABLEHEADER_LENGTH_STAY_COMPACT),
                                  ),
                                ),
                                Container(
                                  width: 90,
                                  padding: const EdgeInsets.only(left: 12),
                                  child: NeutronTextContent(
                                    tooltip: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorManagement.greenColor,
                                ),
                              )
                            : ListView(
                                children: isMobile
                                    ? _buildContentMobile()
                                    : _buildContentDekstop(),
                              )),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    SizedBox(
                      height: 65,
                      child: NeutronButtonText(
                          text:
                              "Total Stay ${controller.getTotalBookingStay()}: ${NumberUtil.numberFormat.format(controller.totalMoneyInDate)}"),
                    ),
                  ],
                ));
          }),
        ),
      ),
    );
  }

  List<Widget> _buildContentMobile() {
    return _dailyStayDatesController!.bookings
        .map((booking) => Container(
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
                    Expanded(
                      child: NeutronTextContent(
                          tooltip: booking.name, message: booking.name!),
                    ),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.only(left: 8),
                      child: NeutronTextContent(
                        message: DateUtil.dateToDayMonthString(
                          booking.inDate!,
                        ),
                      ),
                    ),
                    Container(
                        width: 40,
                        padding: const EdgeInsets.only(left: 8),
                        child: NeutronTextContent(
                            message: booking.lengthStay.toString())),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 50,
                      child: Text(
                        NumberUtil.moneyFormat.format(booking.getRoomCharge()),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            color: ColorManagement.positiveText),
                      ),
                    )
                  ],
                ),
                children: [
                  Column(
                    children: [
                      Container(
                        margin:
                            const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_CREATE),
                            )),
                            Expanded(
                                child: NeutronTextContent(
                              message: DateUtil.dateToString(
                                  booking.created!.toDate()),
                            ))
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SOURCE),
                            )),
                            Expanded(
                              child: NeutronTextContent(
                                  message: booking.sourceName!),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, top: 15, bottom: 15),
                        child: Row(
                          children: [
                            Expanded(
                                child: NeutronTextContent(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ROOM),
                            )),
                            Expanded(
                              child: NeutronTextContent(message: booking.room!),
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

  List<Widget> _buildContentDekstop() {
    num index = 0;
    return _dailyStayDatesController!.bookings
        .map((booking) => Container(
              height: SizeManagement.cardHeight,
              margin: const EdgeInsets.symmetric(
                  horizontal: SizeManagement.cardOutsideHorizontalPadding,
                  vertical: SizeManagement.cardOutsideVerticalPadding),
              decoration: BoxDecoration(
                  color: ColorManagement.lightMainBackground,
                  borderRadius:
                      BorderRadius.circular(SizeManagement.borderRadius8)),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.cardInsideHorizontalPadding),
                        child: NeutronTextContent(
                          message: booking.payAtHotel!
                              ? '${++index}) pay_at_hotel'
                              : '${++index}) prepaid',
                        ),
                      )),
                  Expanded(
                    flex: 2,
                    child: NeutronTextContent(message: booking.sourceName!),
                  ),
                  Expanded(
                      flex: 2,
                      child: NeutronTextContent(
                          tooltip: booking.name, message: booking.roomTypeID!)),
                  SizedBox(
                      width: 60,
                      child: NeutronTextContent(message: booking.room!)),
                  Expanded(
                      child: NeutronTextContent(
                          message:
                              DateUtil.dateToDayMonthString(booking.inDate!))),
                  Expanded(
                      child: NeutronTextContent(
                          message:
                              DateUtil.dateToDayMonthString(booking.outDate!))),
                  SizedBox(
                      width: 60,
                      child: NeutronTextContent(
                          message: BookingStatus.getStatusNameByID(
                              booking.status!)!)),
                  Expanded(
                      flex: 2,
                      child: Text(
                        NumberUtil.numberFormat.format(booking.getRoomCharge()),
                        style: NeutronTextStyle.totalNumber,
                        textAlign: TextAlign.end,
                      )),
                ],
              ),
            ))
        .toList();
  }
}
