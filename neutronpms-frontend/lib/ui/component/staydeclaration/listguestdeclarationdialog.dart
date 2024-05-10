import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/listguestdeclarationcontroller.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../manager/roommanager.dart';
import '../../../manager/sourcemanager.dart';
import '../../../modal/status.dart';
import '../../../util/dateutil.dart';
import '../../../util/excelulti.dart';
import '../../controls/neutrondatetimepicker.dart';
import '../../controls/neutrontextformfield.dart';
import '../../controls/neutrontexttilte.dart';
import '../booking/bookingdialog.dart';

class ListGuestDeclarationDialog extends StatefulWidget {
  const ListGuestDeclarationDialog({Key? key}) : super(key: key);

  @override
  State<ListGuestDeclarationDialog> createState() =>
      _ListGuestDeclarationDialogState();
}

class _ListGuestDeclarationDialogState
    extends State<ListGuestDeclarationDialog> {
  final ListGuestDeclarationController controller =
      ListGuestDeclarationController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth;
    const height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<ListGuestDeclarationController>(
            builder: (_, controller, __) {
              Widget data;
              if (controller.isLoading) {
                data = const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: ColorManagement.greenColor)),
                );
              } else if (controller.guests.isEmpty) {
                data = Expanded(
                    child: Center(
                  child: NeutronTextContent(
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.NO_DATA)),
                ));
              } else {
                data = isMobile ? buildListMobile() : buildListPC();
              }

              return Container(
                width: width,
                height: height,
                padding: const EdgeInsets.only(
                    bottom: SizeManagement.bottomFormFieldSpacing,
                    left: SizeManagement.cardOutsideHorizontalPadding,
                    right: SizeManagement.cardOutsideHorizontalPadding),
                child: Column(
                  children: [
                    //search input
                    isMobile
                        ? buildSearchFieldsInMobile()
                        : buildSearchFieldsInPC(),
                    buildTitle(),
                    const SizedBox(
                        height: SizeManagement.bottomFormFieldSpacing),
                    //list booking
                    data
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Row buildTitle() {
    final isMobile = ResponsiveUtil.isMobile(context);
    return Row(
      children: [
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
        Expanded(
            flex: 2,
            child: NeutronTextTitle(
              fontSize: 14,
              isPadding: false,
              message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME),
            )),
        if (!isMobile)
          Expanded(
              flex: 2,
              child: NeutronTextTitle(
                fontSize: 14,
                isPadding: false,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_NATIONALITY),
              )),
        Expanded(
            child: NeutronTextTitle(
          fontSize: 14,
          isPadding: false,
          message: UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM),
        )),
        if (!isMobile)
          Expanded(
              child: NeutronTextTitle(
            fontSize: 14,
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE),
          )),
        if (!isMobile)
          Expanded(
              child: NeutronTextTitle(
            fontSize: 14,
            isPadding: false,
            message:
                UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE),
          )),
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding)
      ],
    );
  }

  Row buildSearchFieldsInPC() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: ColorManagement.lightMainBackground,
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8)),
            child: Row(children: [
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              //sid
              Expanded(
                child: NeutronTextFormField(
                  label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SID),
                  controller: controller.sIDController,
                ),
              ),
              const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
              //indate
              Container(
                width: 120,
                padding: const EdgeInsets.only(right: 4, left: 8),
                child: NeutronTextContent(
                    message: controller.cin != null
                        ? DateUtil.dateToString(controller.cin!)
                        : UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_IN_DATE)),
              ),
              IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHECKIN),
                  onPressed: () async {
                    final DateTime now = Timestamp.now().toDate();

                    final DateTime? picked = await showDatePicker(
                        builder: (context, child) =>
                            DateTimePickerDarkTheme.buildDarkTheme(
                                context, child!),
                        context: context,
                        initialDate: controller.cin ?? Timestamp.now().toDate(),
                        firstDate: now.subtract(const Duration(days: 500)),
                        lastDate: now.add(const Duration(days: 500)));
                    if (picked != null) {
                      controller.setInDate(picked);
                    }
                  }),
              //outdate
              Container(
                width: 120,
                padding: const EdgeInsets.only(right: 4, left: 8),
                child: NeutronTextContent(
                    message: controller.cout != null
                        ? DateUtil.dateToString(controller.cout!)
                        : UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_OUT_DATE)),
              ),
              IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHECKOUT),
                  onPressed: () async {
                    final DateTime now = Timestamp.now().toDate();

                    final DateTime? picked = await showDatePicker(
                        builder: (context, child) =>
                            DateTimePickerDarkTheme.buildDarkTheme(
                                context, child!),
                        context: context,
                        initialDate:
                            controller.cout ?? Timestamp.now().toDate(),
                        firstDate: now.subtract(const Duration(days: 500)),
                        lastDate: now.add(const Duration(days: 500)));
                    if (picked != null) {
                      controller.setOutDate(picked);
                    }
                  }),
              //source
              Expanded(
                child: NeutronDropDown(
                    focusColor: ColorManagement.lightMainBackground,
                    value: controller.sourceID == null
                        ? UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE)
                        : SourceManager()
                            .getSourceNameByID(controller.sourceID!),
                    onChanged: (String sourceName) async {
                      controller.setSourceID(sourceName);
                    },
                    items: [
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_SOURCE),
                      ...SourceManager().getSourceNames(),
                    ]),
              ),
              //status
              Expanded(
                child: NeutronDropDown(
                    focusColor: ColorManagement.lightMainBackground,
                    value: controller.statusID == null
                        ? UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_STATUS)
                        : UITitleUtil.getTitleByCode(
                            BookingStatus.getStatusNameByID(
                                controller.statusID!)!),
                    onChanged: (String statusName) async {
                      controller.setStatusID(statusName);
                    },
                    items: [
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_STATUS),
                      ...controller.getStatus(),
                    ]),
              ),
              //search icon + reset icon
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.loadBookingSearch();
                },
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESET),
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.reset();
                },
              )
            ]),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 180,
          height: 45,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          child: Row(
            children: [
              Expanded(
                child: NeutronDropDown(
                  focusColor: ColorManagement.lightMainBackground,
                  items: controller.nationalities,
                  value: controller.selectedNationality,
                  onChanged: (String value) {
                    controller.setNationality(value);
                  },
                ),
              ),
              IconButton(
                  padding: const EdgeInsets.all(0),
                  tooltip: UITitleUtil.getTitleByCode(
                      UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                  onPressed: () async {
                    await ExcelUlti.exportGuest(controller.filtedList);
                  },
                  icon: const Icon(FontAwesomeIcons.fileExport, size: 18)),
            ],
          ),
        )
      ],
    );
  }

  Container buildSearchFieldsInMobile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: ColorManagement.mainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //in + out
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                color: ColorManagement.lightMainBackground),
            child: Row(
              children: [
                const SizedBox(
                    width: SizeManagement.cardInsideHorizontalPadding),
                Expanded(
                  flex: 3,
                  child: NeutronTextContent(
                      message: controller.cin != null
                          ? DateUtil.dateToString(controller.cin!)
                          : UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_IN_DATE)),
                ),
                const SizedBox(width: 4),
                IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CHECKIN),
                    onPressed: () async {
                      final DateTime now = Timestamp.now().toDate();

                      final DateTime? picked = await showDatePicker(
                          builder: (context, child) =>
                              DateTimePickerDarkTheme.buildDarkTheme(
                                  context, child!),
                          context: context,
                          initialDate:
                              controller.cin ?? Timestamp.now().toDate(),
                          firstDate: now.subtract(const Duration(days: 500)),
                          lastDate: now.add(const Duration(days: 500)));
                      if (picked != null) {
                        controller.setInDate(picked);
                      }
                    }),
                const SizedBox(width: 4),
                Expanded(
                  flex: 3,
                  child: NeutronTextContent(
                      message: controller.cout != null
                          ? DateUtil.dateToString(controller.cout!)
                          : UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_OUT_DATE)),
                ),
                const SizedBox(width: 4),
                IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_CHECKOUT),
                    onPressed: () async {
                      final DateTime now = Timestamp.now().toDate();

                      final DateTime? picked = await showDatePicker(
                          builder: (context, child) =>
                              DateTimePickerDarkTheme.buildDarkTheme(
                                  context, child!),
                          context: context,
                          initialDate:
                              controller.cout ?? Timestamp.now().toDate(),
                          firstDate: now.subtract(const Duration(days: 500)),
                          lastDate: now.add(const Duration(days: 500)));
                      if (picked != null) {
                        controller.setOutDate(picked);
                      }
                    }),
              ],
            ),
          ),
          //source + status
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                color: ColorManagement.lightMainBackground),
            margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
            child: Row(
              children: [
                Expanded(
                  child: NeutronDropDown(
                      focusColor: ColorManagement.lightMainBackground,
                      value: controller.sourceID == null
                          ? UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_SOURCE)
                          : SourceManager()
                              .getSourceNameByID(controller.sourceID!),
                      onChanged: (String sourceName) async {
                        controller.setSourceID(sourceName);
                      },
                      items: [
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                        ...SourceManager().getSourceNames(),
                      ]),
                ),
                Expanded(
                  child: NeutronDropDown(
                      focusColor: ColorManagement.lightMainBackground,
                      value: controller.statusID == null
                          ? UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_STATUS)
                          : UITitleUtil.getTitleByCode(
                              BookingStatus.getStatusNameByID(
                                  controller.statusID!)!),
                      onChanged: (String statusName) async {
                        controller.setStatusID(statusName);
                      },
                      items: [
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_STATUS),
                        ...controller.getStatus(),
                      ]),
                ),
              ],
            ),
          ),
          //sid + icons
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                color: ColorManagement.lightMainBackground),
            margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: NeutronTextFormField(
                    isDecor: true,
                    backgroundColor: ColorManagement.lightMainBackground,
                    borderColor: ColorManagement.lightMainBackground,
                    label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SID),
                    controller: controller.sIDController,
                  ),
                ),
                IconButton(
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.loadBookingSearch();
                  },
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
                ),
                IconButton(
                  tooltip:
                      UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESET),
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.reset();
                  },
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(maxWidth: 40, minWidth: 40),
                )
              ],
            ),
          ),
          //filter + export to excel
          Container(
            height: 40,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(SizeManagement.borderRadius8),
                color: ColorManagement.lightMainBackground),
            margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
            child: Row(
              children: [
                Expanded(
                  child: NeutronDropDown(
                    focusColor: ColorManagement.lightMainBackground,
                    items: controller.nationalities,
                    value: controller.selectedNationality,
                    onChanged: (String value) {
                      controller.setNationality(value);
                    },
                  ),
                ),
                IconButton(
                    padding: const EdgeInsets.all(0),
                    tooltip: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                    onPressed: () {
                      ExcelUlti.exportGuest(controller.filtedList);
                    },
                    icon: const Icon(FontAwesomeIcons.fileExport, size: 18)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildListPC() {
    return Flexible(
      child: ListView(
        children: controller.filtedList
            .map((stayDeclaration) => InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => BookingDialog(
                              booking: controller
                                  .getBookingContainGuest(stayDeclaration),
                              initialTab: 2,
                            ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        bottom: SizeManagement.rowSpacing),
                    height: SizeManagement.cardHeight,
                    decoration: BoxDecoration(
                        color: ColorManagement.lightMainBackground,
                        borderRadius: BorderRadius.circular(
                            SizeManagement.borderRadius8)),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: SizeManagement.cardInsideHorizontalPadding),
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              tooltip: stayDeclaration.name,
                              message: stayDeclaration.name!,
                            )),
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              tooltip: stayDeclaration.nationality,
                              message: stayDeclaration.nationality!,
                            )),
                        Expanded(
                            child: NeutronTextContent(
                                message: RoomManager()
                                    .getNameRoomById(stayDeclaration.roomId!))),
                        Expanded(
                            child: NeutronTextContent(
                                message: DateUtil.dateToDayMonthString(
                                    stayDeclaration.inDate!))),
                        Expanded(
                            child: NeutronTextContent(
                                message: DateUtil.dateToDayMonthString(
                                    stayDeclaration.outDate!))),
                        const SizedBox(
                            width: SizeManagement.cardInsideHorizontalPadding),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildListMobile() {
    const double widthTitle = 80;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: controller.filtedList
              .map(
                (stayDeclaration) => ExpansionTile(
                  iconColor: ColorManagement.iconMenuEnableColor,
                  collapsedIconColor: ColorManagement.iconMenuEnableColor,
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardInsideHorizontalPadding),
                  childrenPadding: const EdgeInsets.symmetric(
                      horizontal: SizeManagement.cardInsideHorizontalPadding),
                  backgroundColor: ColorManagement.lightMainBackground,
                  subtitle: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal:
                            SizeManagement.cardInsideHorizontalPadding * 2),
                    child: NeutronTextContent(
                      message: stayDeclaration.nationality!,
                      fontSize: 10,
                    ),
                  ),
                  title: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => BookingDialog(
                                booking: controller
                                    .getBookingContainGuest(stayDeclaration),
                                initialTab: 2,
                              ));
                    },
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: NeutronTextContent(
                              tooltip: stayDeclaration.name,
                              message: stayDeclaration.name!,
                            )),
                        Expanded(
                            child: NeutronTextContent(
                                textAlign: TextAlign.center,
                                tooltip: RoomManager()
                                    .getNameRoomById(stayDeclaration.roomId!),
                                message: RoomManager()
                                    .getNameRoomById(stayDeclaration.roomId!))),
                      ],
                    ),
                  ),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 3,
                        horizontalMargin:
                            SizeManagement.cardInsideHorizontalPadding,
                        headingRowHeight: 0,
                        columns: const [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text(''))
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(SizedBox(
                              width: widthTitle,
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NATIONALITY)),
                            )),
                            DataCell(NeutronTextContent(
                                message: stayDeclaration.nationality!))
                          ]),
                          DataRow(cells: [
                            DataCell(SizedBox(
                              width: widthTitle,
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_IN)),
                            )),
                            DataCell(NeutronTextContent(
                                message: DateUtil.dateToDayMonthString(
                                    stayDeclaration.inDate!)))
                          ]),
                          DataRow(cells: [
                            DataCell(SizedBox(
                              width: widthTitle,
                              child: NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_OUT)),
                            )),
                            DataCell(NeutronTextContent(
                                message: DateUtil.dateToDayMonthString(
                                    stayDeclaration.outDate!)))
                          ]),
                        ],
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
