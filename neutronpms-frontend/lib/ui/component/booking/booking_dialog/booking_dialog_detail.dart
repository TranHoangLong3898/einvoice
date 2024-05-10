import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/bookingcontroller.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/component/booking/pricedialog.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/numbervalidator.dart';
import 'package:ihotel/validator/stringvalidator.dart';

class BookingDialogDetail extends StatelessWidget {
  const BookingDialogDetail({
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: SizeManagement.rowSpacing),
                  // Sid
                  NeutronTextTitle(
                    isPadding: false,
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronTextFormField(
                    isDecor: true,
                    controller: controller.teSID,
                    readOnly: !controller.booking.isSIDEditable() ||
                        controller.isReadonly,
                  ),
                  const SizedBox(
                      height: SizeManagement.rowSpacing +
                          SizeManagement.bottomFormFieldSpacing),
                  // Room
                  NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ROOM),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronDropDownCustom(
                    childWidget: NeutronDropDown(
                        isPadding: false,
                        value: RoomManager().getNameRoomById(controller.room),
                        isDisabled: controller.isReadonly,
                        onChanged: (String newRoom) {
                          controller.setRoom(newRoom);
                        },
                        items: controller.availableRooms),
                  ),
                  const SizedBox(
                      height: SizeManagement.bottomFormFieldSpacing +
                          SizeManagement.rowSpacing),
                  // Beds
                  NeutronTextTitle(
                    isPadding: false,
                    message:
                        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BED),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronDropDownCustom(
                    childWidget: NeutronDropDown(
                      isDisabled: controller.isReadonly,
                      isPadding: false,
                      value: SystemManagement().getBedNameById(controller.bed),
                      onChanged: (String newBed) {
                        controller.setBed(newBed);
                      },
                      items: controller.bedsOfRoomType,
                    ),
                  ),
                  const SizedBox(
                      height: SizeManagement.rowSpacing +
                          SizeManagement.bottomFormFieldSpacing),
                  // Child and adult
                  Row(
                    children: [
                      Expanded(
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ADULT),
                        ),
                      ),
                      const SizedBox(
                          width: SizeManagement.cardInsideHorizontalPadding),
                      Expanded(
                        child: NeutronTextTitle(
                          isPadding: false,
                          message: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CHILD),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: controller.teAdult!.buildWidget(
                          validator: (String? value) =>
                              NumberValidator.validatePositiveNumber(
                                      value!.replaceAll(',', ''))
                                  ? null
                                  : MessageUtil.getMessageByCode(
                                      MessageCodeUtil.ADULT_MUST_BE_NUMBER),
                          readOnly: !controller.booking.isAdultChildEditable(),
                        ),
                      ),
                      const SizedBox(
                          width: SizeManagement.cardInsideHorizontalPadding),
                      Expanded(
                          child: controller.teChild!.buildWidget(
                        validator: (String? value) =>
                            NumberValidator.validateNonNegativeNumber(
                                    value!.replaceAll(',', ''))
                                ? null
                                : MessageUtil.getMessageByCode(
                                    MessageCodeUtil.CHILD_MUST_BE_NUMBER),
                        readOnly: !controller.booking.isAdultChildEditable(),
                      ))
                    ],
                  ),
                  const SizedBox(
                      height: SizeManagement.bottomFormFieldSpacing +
                          SizeManagement.rowSpacing),
                  // Rate plan and total in PC
                  if (!isMobile) ...[
                    Row(
                      children: [
                        Expanded(
                          child: NeutronTextTitle(
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_RATEPLAN),
                          ),
                        ),
                        const SizedBox(
                            width: SizeManagement.cardInsideHorizontalPadding),
                        Expanded(
                          child: NeutronTextTitle(
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                controller.statusBookingType ==
                                        BookingType.monthly
                                    ? UITitleCode.TABLEHEADER_MONTHLY_RATE
                                    : UITitleCode.TABLEHEADER_TOTAL),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: NeutronDropDownCustom(
                                childWidget: NeutronDropDown(
                                  isPadding: false,
                                  isDisabled: controller.isReadonly,
                                  value: controller.ratePlanID,
                                  onChanged: (String newRatePlan) {
                                    controller.setRatePlan(newRatePlan);
                                  },
                                  items: controller.getRatePlans(),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    SizeManagement.cardInsideHorizontalPadding),
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                  child: controller.teTotalPrice.buildWidget(
                                    readOnly: controller.isReadonly,
                                    onChanged: (String value) =>
                                        controller.divideTotalPrice(value),
                                    validator: (value) => value!.isEmpty
                                        ? MessageUtil.getMessageByCode(
                                            MessageCodeUtil.INPUT_PRICE)
                                        : StringValidator.validatePrice(value),
                                    isDecor: true,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async =>
                                        showPriceDialog(context, controller),
                                    icon: const Icon(Icons.menu_rounded))
                              ],
                            ))
                          ],
                        ),
                        if (controller.statusBookingType == BookingType.monthly)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: NeutronTextContent(
                              fontSize: 14,
                              message:
                                  "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)} : ${NumberUtil.numberFormat.format((controller.getTotalPriceByBookingByDayly(controller.priceAfterMultipleRatePlan).fold(0.0, (previousValue, element) => previousValue + element)))}",
                            ),
                          )
                      ],
                    ),
                  ],
                  // RatePlan + total in Mobile
                  if (isMobile) ...[
                    NeutronTextTitle(
                      isPadding: false,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_RATEPLAN),
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    NeutronDropDownCustom(
                      childWidget: NeutronDropDown(
                          isPadding: false,
                          value: controller.ratePlanID,
                          isDisabled: controller.isReadonly,
                          onChanged: (String newRatePlan) {
                            controller.setRatePlan(newRatePlan);
                          },
                          items: controller.getRatePlans()),
                    ),
                    const SizedBox(
                        height: SizeManagement.bottomFormFieldSpacing +
                            SizeManagement.rowSpacing),
                    // TOTAL mobile
                    NeutronTextTitle(
                      isPadding: false,
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_TOTAL),
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: controller.teTotalPrice.buildWidget(
                            readOnly: controller.isReadonly,
                            onChanged: (String value) =>
                                controller.divideTotalPrice(value),
                            isDecor: true,
                          ),
                        ),
                        IconButton(
                            onPressed: () async =>
                                showPriceDialog(context, controller),
                            icon: const Icon(Icons.menu_rounded))
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          bottomButon
        ],
      ),
    );
  }

  void showPriceDialog(
      BuildContext context, BookingController controller) async {
    final result = await showDialog(
        context: context,
        builder: (context) =>
            controller.statusBookingType == BookingType.monthly
                ? PriceByMonthDialog(
                    staysdayMonth: controller.staysMonth.toList(),
                    staysday: controller.staysDay,
                    priceBooking: controller.priceAfterMultipleRatePlan,
                    isReadonly: controller.isReadonly,
                  )
                : PriceDialog(
                    staysday: controller.staysDay,
                    priceBooking: controller.priceAfterMultipleRatePlan,
                    isReadonly: controller.isReadonly,
                  ));
    if (result != null) {
      controller.setPrice(result);
    }
  }
}
