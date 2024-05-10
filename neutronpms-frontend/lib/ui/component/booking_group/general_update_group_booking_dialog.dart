import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/updategroupcontroller.dart';
import '../../../manager/generalmanager.dart';
import '../../../manager/rateplanmanager.dart';
import '../../../manager/roomtypemanager.dart';
import '../../../manager/sourcemanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/numberutil.dart';
import '../../../util/responsiveutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../../validator/numbervalidator.dart';
import '../../../validator/stringvalidator.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrondatetimepicker.dart';
import '../../controls/neutrondropdown.dart';
import '../../controls/neutronswitch.dart';
import '../../controls/neutrontextcontent.dart';
import '../../controls/neutrontextformfield.dart';
import '../../controls/neutrontextheader.dart';
import '../../controls/neutrontexttilte.dart';
import '../booking/pricedialog.dart';

class GeneralUpdateGroupDialog extends StatefulWidget {
  const GeneralUpdateGroupDialog(
      {Key? key,
      this.updateGroupController,
      this.pageController,
      this.isUpdate})
      : super(key: key);
  final UpdateGroupController? updateGroupController;
  final PageController? pageController;
  final bool? isUpdate;

  @override
  State<GeneralUpdateGroupDialog> createState() =>
      _GeneralUpdateGroupDialogState();
}

class _GeneralUpdateGroupDialogState extends State<GeneralUpdateGroupDialog> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);

    return ChangeNotifierProvider.value(
      value: widget.updateGroupController,
      child: Consumer<UpdateGroupController>(
          builder: (_, updateControllerGroup, __) {
        if (updateControllerGroup.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: ColorManagement.greenColor,
          ));
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 65),
              child: SingleChildScrollView(
                controller: ScrollController(),
                scrollDirection: Axis.vertical,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //header
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.topHeaderTextSpacing),
                        child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_BOOKING_GROUP)),
                      ),
                      //name
                      Container(
                        padding: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            bottom: SizeManagement.bottomFormFieldSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding,
                            right: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextFormField(
                          isDecor: true,
                          controller: updateControllerGroup.teName,
                          validator: (value) => value!.isEmpty
                              ? MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INPUT_NAME)
                              : null,
                          label:
                              UITitleUtil.getTitleByCode(UITitleCode.HINT_NAME),
                        ),
                      ),
                      //phone + email
                      !isMobile
                          ? Container(
                              margin: const EdgeInsets.only(
                                top: SizeManagement.rowSpacing,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: SizeManagement.rowSpacing,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing,
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextFormField(
                                          isDecor: true,
                                          isPhoneNumber: true,
                                          controller:
                                              updateControllerGroup.tePhone,
                                          validator: (value) =>
                                              StringValidator.validatePhone(
                                                  value!),
                                          label: UITitleUtil.getTitleByCode(
                                              UITitleCode.HINT_PHONE)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: SizeManagement.rowSpacing,
                                          bottom: SizeManagement
                                              .bottomFormFieldSpacing,
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextFormField(
                                        isDecor: true,
                                        controller:
                                            updateControllerGroup.teEmail,
                                        validator: (value) {
                                          return StringValidator
                                              .validateNonRequiredEmail(value);
                                        },
                                        label: UITitleUtil.getTitleByCode(
                                            UITitleCode.HINT_EMAIL),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: SizeManagement.rowSpacing,
                                      bottom:
                                          SizeManagement.bottomFormFieldSpacing,
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  child: NeutronTextFormField(
                                      isDecor: true,
                                      controller: updateControllerGroup.tePhone,
                                      isPhoneNumber: true,
                                      validator: (value) =>
                                          StringValidator.validatePhone(value!),
                                      label: UITitleUtil.getTitleByCode(
                                          UITitleCode.HINT_PHONE)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: SizeManagement.rowSpacing,
                                      bottom:
                                          SizeManagement.bottomFormFieldSpacing,
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: updateControllerGroup.teEmail,
                                    validator: (value) {
                                      return StringValidator
                                          .validateNonRequiredEmail(value);
                                    },
                                    label: UITitleUtil.getTitleByCode(
                                        UITitleCode.HINT_EMAIL),
                                  ),
                                ),
                              ],
                            ),

                      //breakfast + pay at hotel
                      !isMobile
                          ? Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                              isPadding: false,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_BREAKFAST)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        child: NeutronSwitch(
                                            value: widget.updateGroupController!
                                                .breakfast,
                                            onChange: (newBreakfast) {
                                              updateControllerGroup
                                                  .setBreakfast(newBreakfast);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                              isPadding: false,
                                              message: UITitleUtil
                                                  .getTitleByCode(UITitleCode
                                                      .TABLEHEADER_PAY_AT_HOTEL)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        child: NeutronSwitch(
                                            value: widget.updateGroupController!
                                                .payAtHotel,
                                            onChange: (newPayAtHotel) {
                                              updateControllerGroup
                                                  .setPayAtHotel(newPayAtHotel);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_BREAKFAST)),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronSwitch(
                                          value:
                                              updateControllerGroup.breakfast,
                                          onChange: (newBreakfast) {
                                            updateControllerGroup
                                                .setBreakfast(newBreakfast);
                                          }),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode
                                                  .TABLEHEADER_PAY_AT_HOTEL)),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronSwitch(
                                          value:
                                              updateControllerGroup.payAtHotel,
                                          onChange: (newPayAtHotel) {
                                            updateControllerGroup
                                                .setPayAtHotel(newPayAtHotel);
                                          }),
                                    )
                                  ],
                                ),
                              ],
                            ),

                      const SizedBox(
                          height: SizeManagement.bottomFormFieldSpacing),
                      //lunch+ dinner
                      !isMobile
                          ? Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                              isPadding: false,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_LUNCH)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        child: NeutronSwitch(
                                            value: updateControllerGroup.lunch,
                                            onChange: (newLunch) {
                                              updateControllerGroup
                                                  .setLunch(newLunch);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardOutsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                              isPadding: false,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DINNER)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        child: NeutronSwitch(
                                            value: updateControllerGroup.dinner,
                                            onChange: (newDinner) {
                                              updateControllerGroup
                                                  .setDinner(newDinner);
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_LUNCH)),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronSwitch(
                                          value: updateControllerGroup.lunch,
                                          onChange: (newLunch) {
                                            updateControllerGroup
                                                .setLunch(newLunch);
                                          }),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      margin: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_DINNER)),
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      child: NeutronSwitch(
                                          value: updateControllerGroup.dinner,
                                          onChange: (newDinner) {
                                            updateControllerGroup
                                                .setDinner(newDinner);
                                          }),
                                    )
                                  ],
                                ),
                              ],
                            ),
                      const SizedBox(
                          height: SizeManagement.bottomFormFieldSpacing),
                      //in AND out
                      isMobile
                          ? buildContentCountryOnMobile(updateControllerGroup)
                          : buildContentCountryOnPc(updateControllerGroup),
                      !isMobile
                          ? Row(
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_BOOKINGTYPE)),
                                )),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_IN_DATE),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_OUT_DATE),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                        isPadding: false,
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode
                                                .TABLEHEADER_BOOKINGTYPE)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronDropDownCustom(
                                      childWidget: NeutronDropDown(
                                        isDisabled: updateControllerGroup
                                                .bookings?.first.bookingType !=
                                            null,
                                        isPadding: false,
                                        value: updateControllerGroup
                                            .selectTypeBooking,
                                        onChanged: (String roomTypeName) async {
                                          updateControllerGroup
                                              .setBookingType(roomTypeName);
                                        },
                                        items: updateControllerGroup
                                            .listTypeBooking,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_IN_DATE),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronDateTimePickerBorder(
                                      isEditDateTime: updateControllerGroup
                                          .checkAllBookingBookeIn,
                                      initialDate: updateControllerGroup.inDate,
                                      firstDate:
                                          updateControllerGroup.getFirstDate(),
                                      lastDate:
                                          updateControllerGroup.getLastDate(),
                                      onPressed: (DateTime? picked) async {
                                        if (picked != null) {
                                          updateControllerGroup
                                              .setInDate(picked);
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_OUT_DATE),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: SizeManagement.rowSpacing,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing,
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronDateTimePickerBorder(
                                      isEditDateTime: updateControllerGroup
                                          .checkAllBookingOut,
                                      initialDate:
                                          updateControllerGroup.outDate,
                                      firstDate:
                                          updateControllerGroup.getFirstDate(),
                                      lastDate: updateControllerGroup.inDate!
                                          .add(Duration(
                                              days: updateControllerGroup
                                                          .bookings
                                                          ?.first
                                                          .bookingType ==
                                                      BookingType.dayly
                                                  ? GeneralManager.maxLengthStay
                                                  : 365)),
                                      onPressed: (DateTime? picked) async {
                                        if (picked != null) {
                                          updateControllerGroup
                                              .setOutDate(picked);
                                        }
                                      },
                                    ),
                                  )
                                ]),
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronDropDownCustom(
                                  childWidget: NeutronDropDown(
                                    isDisabled: updateControllerGroup
                                            .bookings?.first.bookingType !=
                                        null,
                                    isPadding: false,
                                    value:
                                        updateControllerGroup.selectTypeBooking,
                                    onChanged: (String roomTypeName) async {
                                      updateControllerGroup
                                          .setBookingType(roomTypeName);
                                    },
                                    items:
                                        updateControllerGroup.listTypeBooking,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronDateTimePickerBorder(
                                  isEditDateTime: updateControllerGroup
                                      .checkAllBookingBookeIn,
                                  initialDate: updateControllerGroup.inDate,
                                  firstDate:
                                      updateControllerGroup.getFirstDate(),
                                  lastDate: updateControllerGroup.getLastDate(),
                                  onPressed: (DateTime? picked) async {
                                    if (picked != null) {
                                      updateControllerGroup.setInDate(picked);
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing,
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                child: NeutronDateTimePickerBorder(
                                  isEditDateTime:
                                      updateControllerGroup.checkAllBookingOut,
                                  initialDate: updateControllerGroup.outDate,
                                  firstDate:
                                      updateControllerGroup.getFirstDate(),
                                  lastDate: updateControllerGroup.inDate!.add(
                                      Duration(
                                          days: updateControllerGroup.bookings
                                                      ?.first.bookingType ==
                                                  BookingType.dayly
                                              ? GeneralManager.maxLengthStay
                                              : 365)),
                                  onPressed: (DateTime? picked) async {
                                    if (picked != null) {
                                      updateControllerGroup.setOutDate(picked);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      //source
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_SOURCE),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            bottom: SizeManagement.bottomFormFieldSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding,
                            right: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronDropDownCustom(
                          childWidget: NeutronDropDown(
                              isPadding: false,
                              value: SourceManager().getSourceNameByID(
                                  updateControllerGroup.sourceID),
                              items: SourceManager().getActiveSourceNames(),
                              onChanged: (String newValue) {
                                final newSourceID =
                                    SourceManager().getSourceIDByName(newValue);
                                updateControllerGroup.setSourceID(newSourceID);
                              }),
                        ),
                      ),
                      // sid
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_SID),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            bottom: SizeManagement.bottomFormFieldSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding,
                            right: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextFormField(
                          isDecor: true,
                          controller: updateControllerGroup.teSourceID,
                          validator: (value) {
                            return StringValidator.validateSid(value!);
                          },
                        ),
                      ),
                      // Rate Plan
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_RATEPLAN),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing,
                            bottom: SizeManagement.bottomFormFieldSpacing,
                            left: SizeManagement.cardOutsideHorizontalPadding,
                            right: SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronDropDownCustom(
                          childWidget: NeutronDropDown(
                              isPadding: false,
                              value: updateControllerGroup.ratePlanID,
                              items:
                                  RatePlanManager().getTitleOfActiveRatePlans(),
                              onChanged: (String ratePlanID) {
                                updateControllerGroup.setRatePlanID(ratePlanID);
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding,
                            vertical:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextFormField(
                          paddingVertical: 16,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_SALER),
                          isDecor: true,
                          controller: updateControllerGroup.teSaler,
                          onChanged: (value) =>
                              updateControllerGroup.setEmailSaler(value),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                updateControllerGroup.checkEmailExists(),
                            icon: updateControllerGroup.isLoadingCheckEmail
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: ColorManagement.greenColor),
                                  )
                                : updateControllerGroup.isCheckEmail
                                    ? const Icon(Icons.check)
                                    : const Icon(Icons.cancel),
                            color: updateControllerGroup.isCheckEmail
                                ? ColorManagement.greenColor
                                : ColorManagement.redColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding,
                            vertical:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextFormField(
                          paddingVertical: 16,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_EXTERNAL_SALER),
                          isDecor: true,
                          controller: updateControllerGroup.teExternalSaler,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal:
                                SizeManagement.cardOutsideHorizontalPadding),
                        child: NeutronTextFormField(
                          paddingVertical: 16,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_NOTES),
                          isDecor: true,
                          maxLine: 4,
                          controller: updateControllerGroup.teNotes,
                        ),
                      ),
                      if (updateControllerGroup.isCheckUpdateDate) ...[
                        DataTable(
                            columnSpacing: isMobile ? 0 : 5,
                            horizontalMargin: isMobile ? 0 : 3,
                            headingRowHeight: 50,
                            columns: <DataColumn>[
                              DataColumn(
                                label: SizedBox(
                                  width: isMobile ? 95 : 130,
                                  child: NeutronTextTitle(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOMTYPE),
                                      fontSize: 13),
                                ),
                              ),
                              if (!isMobile)
                                DataColumn(
                                  label: NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ROOM_QUANTITY),
                                    fontSize: 13,
                                  ),
                                ),
                              DataColumn(
                                label: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_QUANTITY),
                                  fontSize: 13,
                                ),
                              ),
                              DataColumn(
                                label: NeutronTextTitle(
                                  message: UITitleUtil.getTitleByCode(
                                      (updateControllerGroup
                                                  .selectTypeBooking ==
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode
                                                      .TABLEHEADER_MONTHLY))
                                          ? UITitleCode
                                              .TABLEHEADER_PRICE_PER_MONTHLY
                                          : UITitleCode
                                              .TABLEHEADER_PRICE_PER_NIGHT),
                                  fontSize: 13,
                                ),
                              ),
                              if (!isMobile)
                                DataColumn(
                                  label: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 100,
                                      minWidth: 100,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding),
                                    child: NeutronTextTitle(
                                      textAlign: TextAlign.end,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                            rows: <DataRow>[
                              ...updateControllerGroup.listRoomTypeID
                                  .map(
                                    (roomTypeID) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(Container(
                                            constraints: BoxConstraints(
                                                maxWidth: isMobile ? 95 : 130,
                                                minWidth: isMobile ? 95 : 130),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: SizeManagement
                                                    .cardOutsideHorizontalPadding),
                                            child: NeutronTextContent(
                                              tooltip: RoomTypeManager()
                                                  .getRoomTypeNameByID(
                                                      roomTypeID),
                                              maxLines: 2,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              message:
                                                  '${RoomTypeManager().getRoomTypeNameByID(roomTypeID)} ${isMobile ? "(${updateControllerGroup.availableRooms[roomTypeID]!.length})" : ""}',
                                            ))),
                                        if (!isMobile)
                                          DataCell(ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 20),
                                              child: Tooltip(
                                                message: RoomTypeManager()
                                                    .getRoomTypeNameByID(
                                                        roomTypeID),
                                                child: NeutronTextTitle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  message: updateControllerGroup
                                                      .availableRooms[
                                                          roomTypeID]!
                                                      .length
                                                      .toString(),
                                                ),
                                              ))),
                                        DataCell(SizedBox(
                                          width: 80,
                                          child: updateControllerGroup
                                              .teNums[roomTypeID]!
                                              .buildWidget(
                                            readOnly: true,
                                            onChanged: (String value) async {
                                              await updateControllerGroup
                                                  .updatePricePerNight(
                                                      roomTypeID, value);
                                            },
                                            textAlign: TextAlign.end,
                                            isDecor: false,
                                            validator: (String? value) =>
                                                NumberValidator
                                                        .validateNonNegativeNumber(
                                                            updateControllerGroup
                                                                .teNums[
                                                                    roomTypeID]!
                                                                .getRawString())
                                                    ? null
                                                    : MessageUtil
                                                        .getMessageByCode(
                                                            MessageCodeUtil
                                                                .INPUT_NUMBER),
                                          ),
                                        )),
                                        DataCell(InkWell(
                                          onTap: () async {
                                            if (updateControllerGroup
                                                        .staysDate ==
                                                    null ||
                                                updateControllerGroup
                                                            .pricesPerNight[
                                                        roomTypeID] ==
                                                    null) {
                                              return;
                                            }
                                            if (widget
                                                        .updateGroupController!
                                                        .pricesPerNight[
                                                            roomTypeID]!
                                                        .length !=
                                                    updateControllerGroup
                                                        .staysDate!.length &&
                                                updateControllerGroup
                                                        .statusBookingType !=
                                                    BookingType.monthly) {
                                              return;
                                            }
                                            final List<num>? result =
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        updateControllerGroup
                                                                    .statusBookingType ==
                                                                BookingType
                                                                    .monthly
                                                            ? PriceByMonthDialog(
                                                                staysdayMonth:
                                                                    updateControllerGroup
                                                                        .staysMonth
                                                                        .toList(),
                                                                staysday: widget
                                                                    .updateGroupController!
                                                                    .staysDate!,
                                                                priceBooking: widget
                                                                        .updateGroupController!
                                                                        .pricesPerNight[
                                                                    roomTypeID]!,
                                                              )
                                                            : PriceDialog(
                                                                staysday: widget
                                                                    .updateGroupController!
                                                                    .staysDate!,
                                                                priceBooking: widget
                                                                        .updateGroupController!
                                                                        .pricesPerNight[
                                                                    roomTypeID]!,
                                                                // bookingType:
                                                                //     updateControllerGroup
                                                                //         .statusBookingType,
                                                              ));
                                            if (result != null) {
                                              updateControllerGroup
                                                  .updatePricePerNightWithPriceDialog(
                                                      result, roomTypeID);
                                            }
                                          },
                                          child: Container(
                                              constraints: const BoxConstraints(
                                                  minWidth: 100, maxWidth: 100),
                                              margin: const EdgeInsets.only(
                                                  left: SizeManagement
                                                      .cardOutsideHorizontalPadding,
                                                  right: SizeManagement
                                                      .cardOutsideHorizontalPadding),
                                              child: NeutronTextTitle(
                                                maxLines: 2,
                                                textAlign: TextAlign.end,
                                                color: ColorManagement
                                                    .positiveText,
                                                isPadding: false,
                                                message: updateControllerGroup
                                                                .pricesPerNight[
                                                            roomTypeID] ==
                                                        null
                                                    ? '0'
                                                    : NumberUtil.numberFormat
                                                        .format(widget
                                                            .updateGroupController!
                                                            .getTotalPricePerNight(
                                                                roomTypeID)),
                                              )),
                                        )),
                                        if (!isMobile)
                                          DataCell(Container(
                                              constraints: const BoxConstraints(
                                                maxWidth: 100,
                                                minWidth: 100,
                                              ),
                                              margin: const EdgeInsets.only(
                                                  left: SizeManagement
                                                      .cardOutsideHorizontalPadding,
                                                  right: SizeManagement
                                                      .cardOutsideHorizontalPadding),
                                              child: NeutronTextTitle(
                                                maxLines: 2,
                                                textAlign: TextAlign.end,
                                                color: ColorManagement
                                                    .positiveText,
                                                isPadding: false,
                                                message: updateControllerGroup
                                                                    .priceTotalAndQuantityRoomTotal[
                                                                roomTypeID]
                                                            ['price'] ==
                                                        null
                                                    ? '0'
                                                    : NumberUtil.numberFormat
                                                        .format(widget
                                                                .updateGroupController!
                                                                .priceTotalAndQuantityRoomTotal[
                                                            roomTypeID]['price']),
                                              )))
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ]),
                        const Divider(
                            height: 1,
                            color: ColorManagement.borderCell,
                            thickness: 1),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.HEADER_TOTAL),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                                child: NeutronTextTitle(
                                    maxLines: 2,
                                    textAlign: TextAlign.end,
                                    color: ColorManagement.positiveText,
                                    isPadding: false,
                                    message: NumberUtil.numberFormat.format(
                                        widget.updateGroupController!
                                            .getTotalPrices()))),
                            SizedBox(
                                width: isMobile
                                    ? SizeManagement
                                        .cardOutsideHorizontalPadding
                                    : 38),
                          ],
                        ),
                      ],
                      const SizedBox(height: SizeManagement.rowSpacing),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.isUpdate!)
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                    icon: updateControllerGroup.isCheckUpdateDate
                        ? Icons.skip_next_sharp
                        : null,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        String result =
                            updateControllerGroup.validateRoomToSecondPage();
                        if (result == MessageCodeUtil.SUCCESS) {
                          widget.updateGroupController!.updateRoomPick();
                          widget.pageController!.animateToPage(1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeIn);
                        } else {
                          MaterialUtil.showAlert(context, result);
                        }
                      }
                    },
                    icon1: updateControllerGroup.isCheckUpdateDate
                        ? null
                        : Icons.save,
                    onPressed1: () async {
                      final result = await updateControllerGroup.updateGroup();
                      if (!mounted) {
                        return;
                      }
                      if (result ==
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.SUCCESS)) {
                        Navigator.pop(
                            context,
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.BOOKING_GROUP_CREATE_SUCCESS,
                                [widget.updateGroupController!.teName!.text]));
                      } else {
                        MaterialUtil.showAlert(context, result);
                      }
                    }),
              )
          ],
        );
      }),
    );
  }

  Widget buildContentCountryOnPc(UpdateGroupController controller) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
            Expanded(
              child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_TRAVEL)),
            ),
            const SizedBox(
                width: 2 * SizeManagement.cardInsideHorizontalPadding),
            Expanded(
              child: NeutronTextTitle(
                isPadding: false,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COUNTRY),
              ),
            ),
            const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
          ],
        ),
        const SizedBox(height: SizeManagement.rowSpacing),
        Row(
          children: [
            const SizedBox(
              width: SizeManagement.cardOutsideHorizontalPadding,
            ),
            // international and domestic
            Expanded(
              child: NeutronDropDownCustom(
                childWidget: NeutronDropDown(
                  isPadding: false,
                  value: controller.getTypeTouristsNameByID(),
                  onChanged: controller.setTypeTourists,
                  items: controller.listTypeTourists,
                ),
              ),
            ),
            const SizedBox(
                width: 2 * SizeManagement.cardInsideHorizontalPadding),
            // auto-complete country
            Expanded(
              child: Autocomplete<String>(
                  key: Key(controller.teCountry),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return controller.listCountry.where(
                        (element) => element.startsWith(textEditingValue.text));
                  },
                  fieldViewBuilder:
                      (context, textEditingValue, focusNode, onFieldSubmitted) {
                    if (controller.teCountry.isNotEmpty) {
                      textEditingValue.text = controller.teCountry;
                    } else {
                      textEditingValue.text = '';
                    }
                    return NeutronTextFormField(
                      isDecor: true,
                      controller: textEditingValue,
                      focusNode: focusNode,
                    );
                  },
                  onSelected: (String selection) {
                    controller.setCountry(selection);
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: ColorManagement.mainBackground,
                        elevation: 5,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 200,
                              maxWidth: kMobileWidth -
                                  SizeManagement.cardOutsideHorizontalPadding *
                                      2),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemBuilder: (context, index) => ListTile(
                              onTap: () => onSelected(options.elementAt(index)),
                              title: Text(
                                options.elementAt(index),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              minVerticalPadding: 0,
                              hoverColor: Colors.white38,
                            ),
                            itemCount: options.length,
                          ),
                        ),
                      ),
                    );
                  },
                  initialValue: TextEditingValue(text: controller.teCountry)),
            ),
            const SizedBox(
              width: SizeManagement.cardOutsideHorizontalPadding,
            ),
          ],
        ),
        const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
      ],
    );
  }

  Widget buildContentCountryOnMobile(UpdateGroupController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardInsideHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRAVEL),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isPadding: false,
              value: controller.getTypeTouristsNameByID(),
              onChanged: controller.setTypeTourists,
              items: controller.listTypeTourists,
            ),
          ),
          // country
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          // title Country
          NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_COUNTRY),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Autocomplete<String>(
              key: Key(controller.teCountry),
              optionsBuilder: (textEditingValue) {
                // textEditingValue.text = controllerBooking.teCountry.text;
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return controller.listCountry.where(
                    (element) => element.startsWith(textEditingValue.text));
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                if (controller.teCountry.isNotEmpty) {
                  textEditingController.text = controller.teCountry;
                } else {
                  textEditingController.text = '';
                }
                return NeutronTextFormField(
                  isDecor: true,
                  controller: textEditingController,
                  focusNode: focusNode,
                );
              },
              onSelected: (String selection) {
                controller.setCountry(selection);
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: ColorManagement.mainBackground,
                    elevation: 5,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: 200,
                          maxWidth: kMobileWidth -
                              SizeManagement.cardOutsideHorizontalPadding * 2),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context, index) => ListTile(
                          onTap: () => onSelected(options.elementAt(index)),
                          title: Text(
                            options.elementAt(index),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          minVerticalPadding: 0,
                          hoverColor: Colors.white38,
                        ),
                        itemCount: options.length,
                      ),
                    ),
                  ),
                );
              },
              initialValue: TextEditingValue(text: controller.teCountry)),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
        ],
      ),
    );
  }
}
