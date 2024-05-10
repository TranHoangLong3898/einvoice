import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../constants.dart';
import '../../controller/extraservice/selectionbookingcontroller.dart';
import '../../ui/component/extraservice/virtualbookingmanagementdialog.dart';
import '../../ui/controls/neutronbookingcard.dart';
import '../../ui/controls/neutrondropdown.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../controls/neutrondatetimepicker.dart';
import '../controls/neutrontextcontent.dart';

// ignore: must_be_immutable
class SelectionBookingDialog extends StatefulWidget {
  final bool? isSearchSubBooking;

  const SelectionBookingDialog({
    Key? key,
    this.isSearchSubBooking,
  }) : super(key: key);

  @override
  State<SelectionBookingDialog> createState() => _SelectionBookingDialogState();
}

class _SelectionBookingDialogState extends State<SelectionBookingDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: ChangeNotifierProvider.value(
        value: SelectionBookingController(
            isSearchDetail: widget.isSearchSubBooking),
        child: Consumer<SelectionBookingController>(
          builder: (_, controller, __) {
            return Container(
              width: kMobileWidth,
              height: kHeight,
              padding: const EdgeInsets.all(
                  SizeManagement.cardOutsideHorizontalPadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      child: NeutronTextHeader(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SELECT_BOOKING),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              NeutronDropDown(
                                focusColor: ColorManagement.lightMainBackground,
                                items: SelectionBookingMode.modes,
                                value: controller.selectionMode,
                                onChanged: (newMode) {
                                  controller.setMode(newMode);
                                },
                              ),
                              if (controller.selectionMode ==
                                  SelectionBookingMode.sID)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          SizeManagement.dropdownLeftPadding),
                                  child: NeutronTextFormField(
                                    hint: '...',
                                    controller: controller.sIDController,
                                  ),
                                ),
                              if (controller.selectionMode ==
                                  SelectionBookingMode.stayingRoom)
                                NeutronDropDown(
                                    value: controller.room!,
                                    onChanged: (String newRoom) {
                                      controller.setRoom(newRoom);
                                    },
                                    items: [
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil
                                              .TEXTALERT_CHOOSE_ROOM),
                                      ...controller.getStayingRoom()
                                    ]),
                              if (controller.selectionMode ==
                                  SelectionBookingMode.virtual)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_IN_DATE)),
                                    NeutronTextContent(
                                        message: controller.inDate != null
                                            ? DateUtil.dateToString(
                                                controller.inDate!)
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .TEXTALERT_EMPTY)),
                                    IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_CREATED_TIME),
                                        onPressed: () async {
                                          final DateTime now =
                                              Timestamp.now().toDate();

                                          final DateTime? picked =
                                              await showDatePicker(
                                                  builder: (context, child) =>
                                                      DateTimePickerDarkTheme
                                                          .buildDarkTheme(
                                                              context, child!),
                                                  context: context,
                                                  initialDate: controller
                                                          .inDate ??
                                                      Timestamp.now().toDate(),
                                                  firstDate: now.subtract(
                                                      const Duration(
                                                          days: 500)),
                                                  lastDate: now.add(
                                                      const Duration(days: 500)));
                                          if (picked != null) {
                                            controller.setInDate(picked);
                                          }
                                        }),
                                  ],
                                ),
                              if (controller.selectionMode ==
                                  SelectionBookingMode.virtual)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    NeutronTextContent(
                                        message: UITitleUtil.getTitleByCode(
                                            UITitleCode.TABLEHEADER_OUT_DATE)),
                                    NeutronTextContent(
                                        message: controller.outDate != null
                                            ? DateUtil.dateToString(
                                                controller.outDate!)
                                            : MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .TEXTALERT_EMPTY)),
                                    IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_CHECKOUT),
                                        onPressed: () async {
                                          final DateTime now =
                                              Timestamp.now().toDate();

                                          final DateTime? picked =
                                              await showDatePicker(
                                                  builder: (context, child) =>
                                                      DateTimePickerDarkTheme
                                                          .buildDarkTheme(
                                                              context, child!),
                                                  context: context,
                                                  initialDate: controller
                                                          .outDate ??
                                                      Timestamp.now().toDate(),
                                                  firstDate: now.subtract(
                                                      const Duration(
                                                          days: 500)),
                                                  lastDate: now.add(
                                                      const Duration(days: 500)));
                                          if (picked != null) {
                                            controller.setOutDate(picked);
                                          }
                                        }),
                                  ],
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {
                                      controller.search();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      controller.reset();
                                    },
                                  ),
                                  if (controller.selectionMode ==
                                      SelectionBookingMode.virtual)
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const VirtualBookingDialog());
                                      },
                                    )
                                ],
                              ),
                            ])),
                    const SizedBox(height: 10),
                    _buildBookingList(controller)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(SelectionBookingController controller) {
    final bookings = controller.bookings;
    if (bookings == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorManagement.greenColor,
        ),
      );
    }
    if (bookings.isEmpty) {
      return Center(
        child: NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_NO_BOOKINGS)),
      );
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: bookings
            .map((booking) => NeutronBookingCard(
                  booking: booking,
                  roomName: controller.room,
                ))
            .toList());
  }
}
