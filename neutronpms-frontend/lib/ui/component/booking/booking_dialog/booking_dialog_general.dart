import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/bookingcontroller.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrondatetimepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutronswitch.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';

class BookingDialogGeneral extends StatelessWidget {
  const BookingDialogGeneral({
    Key? key,
    required this.controller,
    required this.bottomButon,
  }) : super(key: key);

  final BookingController controller;
  final Widget bottomButon;

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      child: Column(
        children: [
          Expanded(
              child: isMobile
                  ? buildContentGeneralInMobile(context)
                  : buildContentGeneralInPc(context)),
          const SizedBox(height: 8),
          bottomButon
        ],
      ),
    );
  }

  Widget buildContentGeneralInPc(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextTitle(
              isRequired: true,
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME)),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            isDecor: true,
            controller: controller.teName,
            readOnly: !controller.booking.isNameEditable(),
            validator: (value) => value!.isEmpty
                ? MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME)
                : null,
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          // Title phone + email
          Row(
            children: [
              Expanded(
                child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PHONE)),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextTitle(
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL),
                ),
              )
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          // Formfield phone + email
          Row(
            children: [
              Expanded(
                child: NeutronTextFormField(
                  isDecor: true,
                  isPhoneNumber: true,
                  controller: controller.tePhone,
                  readOnly: !controller.booking.isPhoneEmailEditable(),
                  validator: (value) => StringValidator.validatePhone(value!),
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextFormField(
                  isDecor: true,
                  controller: controller.teEmail,
                  readOnly: !controller.booking.isPhoneEmailEditable(),
                  validator: (value) =>
                      StringValidator.validateNonRequiredEmail(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          // breafast - pay at hotel + switch
          Row(
            children: [
              Expanded(
                child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_BREAKFAST)),
              ),
              Container(
                width: 60,
                alignment: Alignment.centerRight,
                child: controller.booking.isBreakfastEditable()
                    ? NeutronSwitch(
                        value: controller.breakfast,
                        onChange: (newBreakfast) {
                          controller.setBreakfast(newBreakfast);
                        })
                    : Text(
                        controller.breakfast
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO),
                        style: NeutronTextStyle.title),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PAY_AT_HOTEL)),
              ),
              Container(
                width: 60,
                alignment: Alignment.centerRight,
                child: controller.booking.isPayAtHotelEditable()
                    ? NeutronSwitch(
                        value: controller.payAtHotel,
                        onChange: (payAtHotel) {
                          controller.setPayAtHotel(payAtHotel);
                        })
                    : Text(
                        controller.payAtHotel
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO),
                        style: NeutronTextStyle.title),
              ),
            ],
          ),
          // notes of breafast -pay at hotel
          Row(
            children: [
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_GUESTS_HAVE_BREAKFAST_OR_NOT),
                  style: NeutronTextStyle.notes,
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_GUESTS_WILL_PAY_AT_HOTEL_OR_NOT),
                  style: NeutronTextStyle.notes,
                ),
              ),
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          //lunch+ dinner
          Row(
            children: [
              Expanded(
                child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_LUNCH)),
              ),
              Container(
                width: 60,
                alignment: Alignment.centerRight,
                child: controller.booking.isBreakfastEditable()
                    ? NeutronSwitch(
                        value: controller.lunch,
                        onChange: (newLunch) {
                          controller.setLunch(newLunch);
                        })
                    : Text(
                        controller.lunch
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO),
                        style: NeutronTextStyle.title),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_DINNER)),
              ),
              Container(
                width: 60,
                alignment: Alignment.centerRight,
                child: controller.booking.isPayAtHotelEditable()
                    ? NeutronSwitch(
                        value: controller.dinner,
                        onChange: (newDinner) {
                          controller.setDinner(newDinner);
                        })
                    : Text(
                        controller.dinner
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO),
                        style: NeutronTextStyle.title),
              ),
            ],
          ),
          // notes of lunch + dinner
          Row(
            children: [
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_GUESTS_HAVE_LUNCH_OR_NOT),
                  style: NeutronTextStyle.notes,
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: Text(
                  UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_GUESTS_HAVE_DINNER_OR_NOT),
                  style: NeutronTextStyle.notes,
                ),
              ),
            ],
          ),
          const SizedBox(
              height: SizeManagement.rowSpacing +
                  SizeManagement.bottomFormFieldSpacing),
          Row(
            children: [
              Expanded(
                child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_BOOKINGTYPE),
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_IN_DATE),
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_OUT_DATE),
                ),
              )
            ],
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          Row(
            children: [
              Expanded(
                child: NeutronDropDownCustom(
                  childWidget: NeutronDropDown(
                    isDisabled: controller.booking.bookingType != null,
                    isPadding: false,
                    value: controller.selectTypeBooking,
                    onChanged: (String roomTypeName) async {
                      controller.setBookingType(roomTypeName);
                    },
                    items: controller.listTypeBooking,
                  ),
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronDateTimePickerBorder(
                  formatDate: controller.statusBookingType == BookingType.hourly
                      ? DateUtil.dateToDayMonthYearHourMinuteString
                      : null,
                  onPressed: (DateTime? picked) async {
                    TimeOfDay? timePicked;
                    if (controller.statusBookingType == BookingType.hourly) {
                      timePicked = await NeutronHourPicker(
                              context: context,
                              initTime: controller.hourFrameStart)
                          .pickTime();
                    }
                    if (picked != null) {
                      controller.setInDate(picked, timePicked);
                    }
                  },
                  initialDate:
                      controller.statusBookingType == BookingType.hourly
                          ? controller.inDateHour
                          : controller.inDate,
                  firstDate: controller.getFirstDate(),
                  lastDate: controller.getLastInDate(),
                  isEditDateTime: controller.booking.isInDateEditable(),
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              Expanded(
                child: NeutronDateTimePickerBorder(
                  formatDate: controller.statusBookingType == BookingType.hourly
                      ? DateUtil.dateToDayMonthYearHourMinuteString
                      : null,
                  onPressed: (DateTime? picked) async {
                    TimeOfDay? timePicked;
                    if (controller.statusBookingType == BookingType.hourly) {
                      timePicked = await NeutronHourPicker(
                              context: context,
                              initTime: controller.hourFrameEnd)
                          .pickTime();
                    }
                    if (picked != null) {
                      controller.setOutDate(picked, timePicked);
                    }
                  },
                  initialDate:
                      controller.statusBookingType == BookingType.hourly
                          ? controller.outDateHour
                          : controller.outDate,
                  firstDate: controller.getFirstDate(),
                  lastDate: controller.getLastDate(),
                  isEditDateTime: controller.booking.isOutDateEditable(),
                ),
              ),
            ],
          ),
          const SizedBox(
              height: SizeManagement.rowSpacing +
                  SizeManagement.bottomFormFieldSpacing),
          //roomtype
          NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isDisabled: controller.isReadonly,
              isPadding: false,
              value:
                  RoomTypeManager().getRoomTypeNameByID(controller.roomTypeID),
              onChanged: (String roomTypeName) async {
                controller.setRoomTypeID(roomTypeName);
              },
              items: controller.getRoomTypeNames(),
            ),
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          //source
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isPadding: false,
              value: SourceManager().getSourceNameByID(controller.sourceID),
              isDisabled: controller.isReadonly,
              onChanged: (String newValue) {
                final newSourceID = SourceManager().getSourceIDByName(newValue);
                controller.setSourceID(newSourceID);
              },
              items: controller.getSourceNames(),
            ),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_NOTES),
            isDecor: true,
            maxLine: 4,
            controller: controller.teNotes,
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: controller.teSaler,
            onChanged: (value) => controller.setEmailSaler(value),
            suffixIcon: IconButton(
              onPressed: () => controller.checkEmailExists(),
              icon: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : controller.isCheckEmail
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: controller.isCheckEmail
                  ? ColorManagement.greenColor
                  : ColorManagement.redColor,
            ),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_EXTERNAL_SALER),
            isDecor: true,
            controller: controller.teExternalSaler,
          ),
        ],
      ),
    );
  }

  Widget buildContentGeneralInMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextTitle(
            isRequired: true,
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            isDecor: true,
            controller: controller.teName,
            readOnly: !controller.booking.isNameEditable(),
            validator: (value) => value!.isEmpty
                ? MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME)
                : null,
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          //Phone title
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            isDecor: true,
            controller: controller.tePhone,
            readOnly: !controller.booking.isPhoneEmailEditable(),
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          //Email title
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            isDecor: true,
            controller: controller.teEmail,
            readOnly: !controller.booking.isPhoneEmailEditable(),
            validator: (value) {
              return StringValidator.validateNonRequiredEmail(value);
            },
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          //breakfast  on mobile
          Row(
            children: [
              NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_BREAKFAST)),
              const Spacer(),
              controller.booking.isBreakfastEditable()
                  ? NeutronSwitch(
                      value: controller.breakfast,
                      onChange: (newBreakfast) {
                        controller.setBreakfast(newBreakfast);
                      })
                  : Text(
                      controller.breakfast
                          ? MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_YES)
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_NO),
                      style: NeutronTextStyle.title),
            ],
          ),
          Text(
            UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_GUESTS_HAVE_BREAKFAST_OR_NOT),
            style: NeutronTextStyle.notes,
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          // lunch  on mobile
          Row(
            children: [
              NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_LUNCH)),
              const Spacer(),
              controller.booking.isBreakfastEditable()
                  ? NeutronSwitch(
                      value: controller.lunch,
                      onChange: (newLunch) {
                        controller.setLunch(newLunch);
                      })
                  : Text(
                      controller.lunch
                          ? MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_YES)
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_NO),
                      style: NeutronTextStyle.title),
            ],
          ),
          Text(
            UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_GUESTS_HAVE_LUNCH_OR_NOT),
            style: NeutronTextStyle.notes,
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          // dinner  on mobile
          Row(
            children: [
              NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_BREAKFAST)),
              const Spacer(),
              controller.booking.isBreakfastEditable()
                  ? NeutronSwitch(
                      value: controller.dinner,
                      onChange: (newDinner) {
                        controller.setDinner(newDinner);
                      })
                  : Text(
                      controller.dinner
                          ? MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_YES)
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_NO),
                      style: NeutronTextStyle.title),
            ],
          ),
          Text(
            UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_GUESTS_HAVE_DINNER_OR_NOT),
            style: NeutronTextStyle.notes,
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          //pay at hotel on mobile
          Row(
            children: [
              NeutronTextTitle(
                  isPadding: false,
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.TABLEHEADER_PAY_AT_HOTEL)),
              const Spacer(),
              controller.booking.isPayAtHotelEditable()
                  ? NeutronSwitch(
                      value: controller.payAtHotel,
                      onChange: (payAtHotel) {
                        controller.setPayAtHotel(payAtHotel);
                      })
                  : Text(
                      controller.payAtHotel
                          ? MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_YES)
                          : MessageUtil.getMessageByCode(
                              MessageCodeUtil.TEXTALERT_NO),
                      style: NeutronTextStyle.title),
            ],
          ),
          Text(
            UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_GUESTS_HAVE_BREAKFAST_OR_NOT),
            style: NeutronTextStyle.notes,
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKINGTYPE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isDisabled: controller.booking.bookingType != null,
              isPadding: false,
              value: controller.selectTypeBooking,
              onChanged: (String roomTypeName) async {
                controller.setBookingType(roomTypeName);
              },
              items: controller.listTypeBooking,
            ),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          // start date and end date
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_START),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDateTimePickerBorder(
            formatDate: controller.statusBookingType == BookingType.hourly
                ? DateUtil.dateToDayMonthYearHourMinuteString
                : null,
            onPressed: (DateTime? picked) async {
              TimeOfDay? timePicked;
              if (controller.statusBookingType == BookingType.hourly) {
                timePicked = await NeutronHourPicker(
                        context: context, initTime: controller.hourFrameStart)
                    .pickTime();
              }
              if (picked != null) {
                controller.setInDate(picked, timePicked);
              }
            },
            initialDate: controller.statusBookingType == BookingType.hourly
                ? controller.inDateHour
                : controller.inDate,
            firstDate: controller.getFirstDate(),
            lastDate: controller.getLastInDate(),
            isEditDateTime: controller.booking.isInDateEditable(),
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_END),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDateTimePickerBorder(
            formatDate: controller.statusBookingType == BookingType.hourly
                ? DateUtil.dateToDayMonthYearHourMinuteString
                : null,
            onPressed: (DateTime? picked) async {
              TimeOfDay? timePicked;
              if (controller.statusBookingType == BookingType.hourly) {
                timePicked = await NeutronHourPicker(
                        context: context, initTime: controller.hourFrameEnd)
                    .pickTime();
              }
              if (picked != null) {
                controller.setOutDate(picked, timePicked);
              }
            },
            initialDate: controller.statusBookingType == BookingType.hourly
                ? controller.outDateHour
                : controller.outDate,
            firstDate: controller.getFirstDate(),
            lastDate: controller.getLastDate(),
            isEditDateTime: controller.booking.isOutDateEditable(),
          ),
          const SizedBox(height: SizeManagement.bottomFormFieldSpacing),
          const SizedBox(height: SizeManagement.rowSpacing),
          //roomtype
          NeutronTextTitle(
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isDisabled: controller.isReadonly,
              isPadding: false,
              value:
                  RoomTypeManager().getRoomTypeNameByID(controller.roomTypeID),
              onChanged: (String roomTypeName) async {
                controller.setRoomTypeID(roomTypeName);
              },
              items: controller.getRoomTypeNames(),
            ),
          ),
          const SizedBox(
              height: SizeManagement.bottomFormFieldSpacing +
                  SizeManagement.rowSpacing),
          //source
          NeutronTextTitle(
            isPadding: false,
            message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronDropDownCustom(
            childWidget: NeutronDropDown(
              isPadding: false,
              value: SourceManager().getSourceNameByID(controller.sourceID),
              isDisabled: controller.isReadonly,
              onChanged: (String newValue) {
                final newSourceID = SourceManager().getSourceIDByName(newValue);
                controller.setSourceID(newSourceID);
              },
              items: controller.getSourceNames(),
            ),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_NOTES),
            isDecor: true,
            maxLine: 4,
            controller: controller.teNotes,
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SALER),
            isDecor: true,
            controller: controller.teSaler,
            onChanged: (value) => controller.setEmailSaler(value),
            suffixIcon: IconButton(
              onPressed: () => controller.checkEmailExists(),
              icon: controller.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor),
                    )
                  : controller.isCheckEmail
                      ? const Icon(Icons.check)
                      : const Icon(Icons.cancel),
              color: controller.isCheckEmail
                  ? ColorManagement.greenColor
                  : ColorManagement.redColor,
            ),
          ),
          const SizedBox(height: SizeManagement.rowSpacing),
          NeutronTextFormField(
            paddingVertical: 16,
            label: UITitleUtil.getTitleByCode(
                UITitleCode.TABLEHEADER_EXTERNAL_SALER),
            isDecor: true,
            controller: controller.teExternalSaler,
          ),
        ],
      ),
    );
  }
}
