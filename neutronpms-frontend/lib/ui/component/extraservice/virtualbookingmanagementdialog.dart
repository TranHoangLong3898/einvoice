import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/extraservice/virtualbookingcontroller.dart';
import '../../../modal/booking.dart';
import '../../../modal/status.dart';
import '../../../ui/controls/neutronbookingcontextmenu.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutroniconbutton.dart';
import '../../../util/dateutil.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';

class VirtualBookingManagementDialog extends StatefulWidget {
  const VirtualBookingManagementDialog({Key? key}) : super(key: key);

  @override
  State<VirtualBookingManagementDialog> createState() =>
      _VirtualBookingManagementDialogState();
}

class _VirtualBookingManagementDialogState
    extends State<VirtualBookingManagementDialog> {
  VirtualBookingManagementController? controller;

  @override
  void initState() {
    controller ??= VirtualBookingManagementController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
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
      width = 900;
    }

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: ChangeNotifierProvider<VirtualBookingManagementController>.value(
          value: controller!,
          child: Consumer<VirtualBookingManagementController>(
            builder: (_, controller, __) => Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_VIRTUAL_BOOKINGS),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  actions: [
                    SizedBox(
                      width: 120,
                      child: NeutronDropDown(
                          value: controller.selectDate,
                          onChanged: (String sourceName) async {
                            controller.setSelectDate(sourceName);
                          },
                          items: controller.listSelect),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              tooltip: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_DATE),
                              onPressed:
                                  controller.selectDate !=
                                          UITitleUtil.getTitleByCode(
                                              UITitleCode.STATUS_ALL)
                                      ? () async {
                                          final DateTime now =
                                              Timestamp.now().toDate();

                                          final DateTime? picked =
                                              await showDatePicker(
                                                  builder: (context, child) =>
                                                      DateTimePickerDarkTheme
                                                          .buildDarkTheme(
                                                              context, child!),
                                                  context: context,
                                                  initialDate:
                                                      controller.dateTime ??
                                                          Timestamp.now()
                                                              .toDate(),
                                                  firstDate: now.subtract(
                                                      const Duration(
                                                          days: 500)),
                                                  lastDate: now.add(
                                                      const Duration(days: 500)));
                                          if (picked != null) {
                                            controller.setDateTime(picked);
                                          }
                                        }
                                      : null),
                        ),
                        NeutronTextContent(
                            message: controller.dateTime != null
                                ? DateUtil.dateToString(controller.dateTime!)
                                : UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ALL)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    NeutronIconButton(
                        icon: Icons.search,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_SEARCH),
                        onPressed: () {
                          controller.loadBookingSearch();
                        }),
                    const SizedBox(width: 8),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: ColorManagement.greenColor),
                              )
                            : controller.bookings.isEmpty
                                ? Center(
                                    child: NeutronTextContent(
                                        message:
                                            controller.getEmptyPageNotes()))
                                : Column(
                                    children: [
                                      //title row
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            if (!isMobile)
                                              //sid
                                              Expanded(
                                                flex: 8,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: NeutronTextTitle(
                                                    fontSize: 13,
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(
                                                            UITitleCode
                                                                .TABLEHEADER_SID),
                                                  ),
                                                ),
                                              ),
                                            //name
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: NeutronTextTitle(
                                                  fontSize: 13,
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_NAME),
                                                ),
                                              ),
                                            ),
                                            if (!isMobile)
                                              //out
                                              Expanded(
                                                flex: 4,
                                                child: NeutronTextTitle(
                                                  fontSize: 13,
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_OUT_DATE),
                                                ),
                                              ),
                                            if (!isMobile)
                                              //deposit
                                              Expanded(
                                                flex: 4,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4),
                                                  child: NeutronTextTitle(
                                                    fontSize: 13,
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_PAYMENT),
                                                  ),
                                                ),
                                              ),
                                            if (!isMobile)
                                              //transferring
                                              Expanded(
                                                flex: 5,
                                                child: NeutronTextTitle(
                                                  fontSize: 13,
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_TRANSFERRING),
                                                ),
                                              ),
                                            if (!isMobile)
                                              //service
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8),
                                                  child: NeutronTextTitle(
                                                    fontSize: 13,
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_SERVICE),
                                                  ),
                                                ),
                                              ),
                                            if (!isMobile)
                                              //transferred
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8),
                                                  child: NeutronTextTitle(
                                                    fontSize: 13,
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_TRANSFERRED),
                                                  ),
                                                ),
                                              ),
                                            if (!isMobile)
                                              //discount
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8),
                                                  child: NeutronTextTitle(
                                                    fontSize: 13,
                                                    isPadding: false,
                                                    message: UITitleUtil
                                                        .getTitleByCode(UITitleCode
                                                            .TABLEHEADER_DISCOUNT),
                                                  ),
                                                ),
                                              ),
                                            //remaining
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: NeutronTextTitle(
                                                  fontSize: 13,
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_REMAIN),
                                                ),
                                              ),
                                            ),
                                            //status
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: NeutronTextTitle(
                                                  fontSize: 13,
                                                  isPadding: false,
                                                  message: UITitleUtil
                                                      .getTitleByCode(UITitleCode
                                                          .TABLEHEADER_STATUS),
                                                ),
                                              ),
                                            ),
                                            //menu
                                            Expanded(
                                                flex: 2, child: Container()),
                                          ],
                                        ),
                                      ),
                                      //list booking
                                      Expanded(
                                        child: ListView(
                                          children: controller.bookings
                                              .map((booking) => Container(
                                                    height: SizeManagement
                                                        .cardHeight,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: SizeManagement
                                                            .cardOutsideVerticalPadding,
                                                        horizontal: SizeManagement
                                                            .cardOutsideHorizontalPadding),
                                                    decoration: BoxDecoration(
                                                        color: ColorManagement
                                                            .lightMainBackground,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                SizeManagement
                                                                    .borderRadius8)),
                                                    child: Row(
                                                      children: [
                                                        if (!isMobile)
                                                          //SID
                                                          Expanded(
                                                              flex: 8,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8),
                                                                child:
                                                                    NeutronTextContent(
                                                                  message:
                                                                      booking
                                                                          .sID!,
                                                                ),
                                                              )),
                                                        //name
                                                        Expanded(
                                                          flex: 3,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8),
                                                            child:
                                                                NeutronTextContent(
                                                              tooltip:
                                                                  booking.name,
                                                              message:
                                                                  booking.name!,
                                                            ),
                                                          ),
                                                        ),
                                                        if (!isMobile)
                                                          //out
                                                          Expanded(
                                                            flex: 4,
                                                            child: NeutronTextContent(
                                                                message: DateUtil
                                                                    .dateToDayMonthString(
                                                                        booking
                                                                            .outDate!)),
                                                          ),
                                                        if (!isMobile)
                                                          //deposit
                                                          Expanded(
                                                            flex: 4,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 4),
                                                              child: NeutronTextContent(
                                                                  message: NumberUtil
                                                                      .numberFormat
                                                                      .format(booking
                                                                          .deposit)),
                                                            ),
                                                          ),
                                                        if (!isMobile)
                                                          //transferring
                                                          Expanded(
                                                            flex: 5,
                                                            child: NeutronTextContent(
                                                                message: NumberUtil
                                                                    .numberFormat
                                                                    .format(booking
                                                                        .transferring)),
                                                          ),
                                                        if (!isMobile)
                                                          //service
                                                          Expanded(
                                                              flex: 4,
                                                              child: Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                child: NeutronTextContent(
                                                                    color: ColorManagement
                                                                        .positiveText,
                                                                    message: NumberUtil
                                                                        .numberFormat
                                                                        .format(
                                                                            booking.getServiceCharge())),
                                                              )),
                                                        if (!isMobile)
                                                          //transferred
                                                          Expanded(
                                                              flex: 5,
                                                              child: Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                child: NeutronTextContent(
                                                                    color: ColorManagement
                                                                        .positiveText,
                                                                    message: NumberUtil
                                                                        .numberFormat
                                                                        .format(
                                                                            booking.transferred)),
                                                              )),
                                                        if (!isMobile)
                                                          //discount
                                                          Expanded(
                                                              flex: 4,
                                                              child: Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                child: NeutronTextContent(
                                                                    color: ColorManagement
                                                                        .positiveText,
                                                                    message: booking.discount ==
                                                                            0
                                                                        ? "0"
                                                                        : "-${NumberUtil.numberFormat.format(booking.discount)}"),
                                                              )),
                                                        //remaining
                                                        Expanded(
                                                            flex: 4,
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                              child: NeutronTextContent(
                                                                  color: ColorManagement
                                                                      .negativeText,
                                                                  message: NumberUtil
                                                                      .numberFormat
                                                                      .format(booking
                                                                          .getRemaining())),
                                                            )),
                                                        //status
                                                        Expanded(
                                                            flex: 5,
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                              child: NeutronTextContent(
                                                                  message: BookingStatus
                                                                      .getStatusNameByID(
                                                                          booking
                                                                              .status!)!),
                                                            )),
                                                        //menu
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                              child:
                                                                  NeutronBookingContextMenu(
                                                                booking:
                                                                    booking,
                                                                backgroundColor:
                                                                    ColorManagement
                                                                        .lightMainBackground,
                                                                tooltip: UITitleUtil
                                                                    .getTitleByCode(
                                                                        UITitleCode
                                                                            .TOOLTIP_MENU),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  )),
                    Container(
                      margin: const EdgeInsets.all(
                          SizeManagement.cardOutsideHorizontalPadding),
                      height: 40,
                      decoration: BoxDecoration(
                          color: ColorManagement.greenColor,
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            NeutronIconButton(
                                icon: Icons.navigate_before,
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_PREVIOUS),
                                onPressed: () {
                                  controller.previousPage();
                                }),
                            NeutronIconButton(
                                icon: Icons.add,
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_ADD),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const VirtualBookingDialog());
                                }),
                            NeutronIconButton(
                                icon: Icons.navigate_next,
                                tooltip: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_NEXT),
                                onPressed: () {
                                  controller.nextPage();
                                }),
                          ]),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class VirtualBookingDialog extends StatefulWidget {
  final Booking? booking;

  const VirtualBookingDialog({Key? key, this.booking}) : super(key: key);
  @override
  State<VirtualBookingDialog> createState() => _VirtualBookingDialogState();
}

class _VirtualBookingDialogState extends State<VirtualBookingDialog> {
  VirtualBookingController? controller;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller ??= VirtualBookingController(widget.booking);
    super.initState();
  }

  @override
  void dispose() {
    controller?.disposeAllTextEditingController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now().toDate();

    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: 525,
        child: Form(
          key: formKey,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<VirtualBookingController>(
              builder: (_, controller, __) => controller.processing
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 65),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //title
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: NeutronTextHeader(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.SIDEBAR_VIRTUAL_BOOKINGS),
                                  ),
                                ),
                                //name
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isRequired: true,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_NAME),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing),
                                        child: NeutronTextFormField(
                                          isDecor: true,
                                          controller: controller.teName,
                                          validator: (value) => value!.isEmpty
                                              ? MessageUtil.getMessageByCode(
                                                  MessageCodeUtil.INPUT_NAME)
                                              : null,
                                        )),
                                  ],
                                ),
                                //phone
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isRequired: true,
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_PHONE),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        controller: controller.tePhone,
                                        validator: (String? value) {
                                          return StringValidator
                                              .validatePhoneNumber(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                //email
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_EMAIL),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing),
                                        child: NeutronTextFormField(
                                            isDecor: true,
                                            controller: controller.teEmail,
                                            validator: (value) {
                                              return StringValidator
                                                  .validateNonRequiredEmail(
                                                      value);
                                            })),
                                  ],
                                ),
                                //out-date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement.rowSpacing),
                                      child: NeutronTextTitle(
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_OUT),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing),
                                      child: NeutronDateTimePickerBorder(
                                        isEditDateTime: true,
                                        firstDate:
                                            controller.outDate.compareTo(now) <
                                                    0
                                                ? controller.outDate
                                                : now,
                                        lastDate:
                                            now.add(const Duration(days: 499)),
                                        initialDate: controller.outDate,
                                        onPressed: (DateTime? picked) {
                                          if (picked != null) {
                                            controller.setOutDate(picked);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                if (!controller.isAdd)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            vertical:
                                                SizeManagement.rowSpacing),
                                        child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_SID),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding,
                                            bottom: SizeManagement
                                                .bottomFormFieldSpacing),
                                        child: NeutronTextFormField(
                                            isDecor: true,
                                            hint: UITitleUtil.getTitleByCode(
                                                UITitleCode.HINT_SID),
                                            controller: controller.teSID),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        //button
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                              icon: Icons.save,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  String result =
                                      await controller.updateVirtualBooking();
                                  if (!mounted) {
                                    return;
                                  }
                                  if (result ==
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    MaterialUtil.showSnackBar(context, result);
                                    Navigator.pop(
                                        context, controller.getAddedBooking());
                                  } else {
                                    MaterialUtil.showAlert(context, result);
                                  }
                                }
                              }),
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
