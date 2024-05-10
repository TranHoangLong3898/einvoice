import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controller/channelmanager/cmbookingcontroller.dart';
import '../../manager/roomtypemanager.dart';
import '../../ui/controls/neutronbutton.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../../util/numberutil.dart';
import '../controls/neutrondatetimepicker.dart';
import '../controls/neutrondropdown.dart';

class CMBookingForm extends StatefulWidget {
  const CMBookingForm({Key? key}) : super(key: key);

  @override
  State<CMBookingForm> createState() => _CMBookingFormState();
}

class _CMBookingFormState extends State<CMBookingForm> {
  final CMBookingController cmBookingController = CMBookingController();
  late NeutronInputNumberController valuePeriodController, numberController;

  @override
  void initState() {
    valuePeriodController =
        NeutronInputNumberController(cmBookingController.valuePeriod);
    numberController =
        NeutronInputNumberController(cmBookingController.numberController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CMBookingController>.value(
      value: cmBookingController,
      child: Consumer<CMBookingController>(
        builder: (_, controller, __) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: DateUtil.dateToHLSString(controller.start),
                      )),
                      IconButton(
                          icon: const Icon(Icons.calendar_today),
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_START_DATE),
                          onPressed: () async {
                            final DateTime now = Timestamp.now().toDate();

                            final DateTime? picked = await showDatePicker(
                                builder: (context, child) =>
                                    DateTimePickerDarkTheme.buildDarkTheme(
                                        context, child!),
                                context: context,
                                initialDate: controller.start,
                                firstDate:
                                    now.subtract(const Duration(days: 700)),
                                lastDate: now.add(const Duration(days: 700)));
                            if (picked != null &&
                                picked.compareTo(controller.start) != 0) {
                              controller.setStart(picked);
                            }
                          }),
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: DateUtil.dateToHLSString(controller.end),
                      )),
                      IconButton(
                          icon: const Icon(Icons.calendar_today),
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_END_DATE),
                          onPressed: () async {
                            final DateTime now = Timestamp.now().toDate();

                            final DateTime? picked = await showDatePicker(
                                builder: (context, child) =>
                                    DateTimePickerDarkTheme.buildDarkTheme(
                                        context, child!),
                                context: context,
                                initialDate: controller.end,
                                firstDate: controller.start,
                                lastDate: now.add(const Duration(days: 700)));
                            if (picked != null &&
                                picked.compareTo(controller.end) != 0) {
                              controller.setEnd(picked);
                            }
                          }),
                    ],
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: ColorManagement.lightMainBackground,
                      style: Theme.of(context).textTheme.bodyMedium,
                      iconEnabledColor: Colors.white,
                      value: controller.dateFilter,
                      onChanged: (String? value) async {
                        controller.changeDateFilter(value!);
                      },
                      items: controller.filters
                          .map<DropdownMenuItem<String>>((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                              width: kMobileWidth - 45, child: Text(value)),
                        );
                      }).toList(),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: ColorManagement.lightMainBackground,
                      style: Theme.of(context).textTheme.bodyMedium,
                      iconEnabledColor: Colors.white,
                      value: controller.bookingStatus,
                      onChanged: (String? value) async {
                        controller.changeBookingStatus(value!);
                      },
                      items: controller.statuses
                          .map<DropdownMenuItem<String>>((dynamic value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: SizedBox(
                              width: kMobileWidth - 45, child: Text(value)),
                        );
                      }).toList(),
                    ),
                  ),
                  numberController.buildWidget(
                    isDecor: true,
                    color: ColorManagement.lightMainBackground,
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.HINT_NUMBER_OF_BOOKINGS),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                      margin: const EdgeInsets.all(0),
                      icon: Icons.get_app,
                      onPressed: () async {
                        final result = await controller.getBookings();
                        if (!mounted) {
                          return;
                        }
                        if (result == null) {
                          MaterialUtil.showAlert(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.IN_PROGRESS));
                          return;
                        }
                        if (!result) {
                          MaterialUtil.showAlert(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.FAILED));
                        }
                      }),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronTextTitle(
                    isPadding: false,
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ADJUST_RELEASE_PERIOD),
                  ),
                  NeutronDropDown(
                      isPadding: false,
                      items: ['', ...controller.roomTypeNames],
                      value: controller.selectedRoomTypePeriod == ''
                          ? ''
                          : RoomTypeManager().getRoomTypeNameByID(
                              controller.selectedRoomTypePeriod),
                      onChanged: (String value) async {
                        controller.changeSelectedRoomTypePeriod(value);
                      }),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_START_DATE),
                      )),
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: DateUtil.dateToHLSString(controller.start),
                      )),
                      Expanded(
                        child: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_END_DATE),
                            onPressed: () async {
                              final DateTime now = Timestamp.now().toDate();

                              final DateTime? picked = await showDatePicker(
                                  builder: (context, child) =>
                                      DateTimePickerDarkTheme.buildDarkTheme(
                                          context, child!),
                                  context: context,
                                  initialDate: controller.start,
                                  firstDate: now,
                                  lastDate: now.add(const Duration(days: 700)));
                              if (picked != null &&
                                  picked.compareTo(controller.start) != 0) {
                                controller.setStart(picked);
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  Row(
                    children: [
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_END_DATE),
                      )),
                      Expanded(
                          child: NeutronTextTitle(
                        isPadding: false,
                        message: DateUtil.dateToHLSString(controller.end),
                      )),
                      Expanded(
                        child: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_END_DATE),
                            onPressed: () async {
                              final DateTime now = Timestamp.now().toDate();

                              final DateTime? picked = await showDatePicker(
                                  builder: (context, child) =>
                                      DateTimePickerDarkTheme.buildDarkTheme(
                                          context, child!),
                                  context: context,
                                  initialDate: controller.end,
                                  firstDate: controller.start,
                                  lastDate: now.add(const Duration(days: 700)));
                              if (picked != null &&
                                  picked.compareTo(controller.end) != 0) {
                                controller.setEnd(picked);
                              }
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  valuePeriodController.buildWidget(
                    color: ColorManagement.lightMainBackground,
                    isDecor: true,
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.HINT_INPUT_VALUE_HERE),
                  ),
                  const SizedBox(height: SizeManagement.rowSpacing),
                  NeutronButton(
                      margin: const EdgeInsets.all(0),
                      icon: Icons.save,
                      onPressed: () async {
                        final success = await controller.updateReleasePeriod();
                        if (!mounted) {
                          return;
                        }
                        if (success == null) {
                          MaterialUtil.showAlert(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.IN_PROGRESS));
                          return;
                        }
                        if (success) {
                          MaterialUtil.showSnackBar(
                              context,
                              MessageUtil.getMessageByCode(MessageCodeUtil
                                  .CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_SUCCESS));
                        } else {
                          MaterialUtil.showAlert(
                              context,
                              controller.updateReleasePeriodErrorFromAPI ??
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.UNDEFINED_ERROR));
                        }
                      }),
                  if (controller.bookings != null)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: (controller.bookings as List)
                            .map((booking) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ColorManagement.lightMainBackground,
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.smallCircle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(booking['NotificationType'] +
                                          '-' +
                                          booking['BookingStatus']),
                                      Text(booking['BookingSource']['Name'] +
                                          (booking.containsKey('ExtBookingRef')
                                              ? (" - ${booking['ExtBookingRef']}")
                                              : '')),
                                      Text(booking['Guests']['FirstName'] +
                                          " " +
                                          booking['Guests']['LastName']),
                                      Text(booking['CheckIn'] +
                                          " - " +
                                          booking['CheckOut']),
                                      Text(
                                          '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(booking['Amount'])}'),
                                      ...(booking['Rooms'] as List)
                                          .map((room) => Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      ' + (${room['BookingItemStatus']}) Room: ${room['RoomType']}. Price: ${room['Amount']}.'),
                                                ],
                                              ))
                                          .toList(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                              icon: const Icon(Icons.get_app),
                                              onPressed: () async {
                                                bool? result = await controller
                                                    .syncBooking(booking);
                                                if (!mounted) {
                                                  return;
                                                }
                                                if (result == null) {
                                                  MaterialUtil.showAlert(
                                                      context,
                                                      MessageUtil
                                                          .getMessageByCode(
                                                              MessageCodeUtil
                                                                  .IN_PROGRESS));
                                                  return;
                                                }
                                                if (result) {
                                                  MaterialUtil.showSnackBar(
                                                      context,
                                                      MessageUtil.getMessageByCode(
                                                          MessageCodeUtil
                                                              .CM_SYNC_BOOKING_SUCCESS));
                                                } else {
                                                  MaterialUtil.showAlert(
                                                      context,
                                                      controller
                                                              .syncBookingErrorFromAPI ??
                                                          MessageUtil
                                                              .getMessageByCode(
                                                                  MessageCodeUtil
                                                                      .UNDEFINED_ERROR));
                                                }
                                              }),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.notifications_active),
                                              onPressed: () async {
                                                final success = await controller
                                                    .notifyBooking(
                                                        booking['BookingId']);
                                                if (!mounted) {
                                                  return;
                                                }
                                                if (success == null) {
                                                  MaterialUtil.showAlert(
                                                      context,
                                                      MessageUtil
                                                          .getMessageByCode(
                                                              MessageCodeUtil
                                                                  .IN_PROGRESS));
                                                  return;
                                                }
                                                if (success) {
                                                  MaterialUtil.showSnackBar(
                                                      context,
                                                      MessageUtil.getMessageByCode(
                                                          MessageCodeUtil
                                                              .CM_NOTIFY_SUCCESS));
                                                } else {
                                                  MaterialUtil.showAlert(
                                                      context,
                                                      controller
                                                              .notifyBookingErrorFromAPI ??
                                                          MessageUtil
                                                              .getMessageByCode(
                                                                  MessageCodeUtil
                                                                      .FAILED));
                                                }
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ))
                            .toList())
                ]),
          ),
        ),
      ),
    );
  }
}
