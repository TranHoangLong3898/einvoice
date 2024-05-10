import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controller/searchcontroller.dart';
import '../../manager/sourcemanager.dart';
import '../../ui/controls/neutrondropdown.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/designmanagement.dart';
import '../../util/excelulti.dart';
import '../../util/responsiveutil.dart';
import '../controls/neutrondatetimepicker.dart';
import '../controls/neutronsearchbookinglist.dart';

class SearchDialog extends StatelessWidget {
  final SearchControllers searchController = SearchControllers();

  SearchDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    final double width = isMobile ? kMobileWidth : kLargeWidth;
    const double height = kHeight;

    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: width,
        child: ChangeNotifierProvider.value(
          value: searchController,
          child: Consumer<SearchControllers>(
            builder: (_, controller, __) {
              return Stack(fit: StackFit.expand, children: [
                Container(
                  width: width,
                  height: height,
                  margin: !isMobile ? const EdgeInsets.only(bottom: 60) : null,
                  padding: const EdgeInsets.only(
                      top: SizeManagement.rowSpacing,
                      left: SizeManagement.cardOutsideHorizontalPadding,
                      right: SizeManagement.cardOutsideHorizontalPadding),
                  child: Column(
                    children: [
                      //search input
                      Container(
                        height: isMobile ? null : 50,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: isMobile
                                ? ColorManagement.mainBackground
                                : ColorManagement.lightMainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        child: isMobile
                            ? buildSearchInputInMobile(controller, context)
                            : buildSearchInputInPC(controller, context),
                      ),
                      //list booking
                      Expanded(
                        flex: 6,
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: ColorManagement.greenColor))
                            : NeutronSearchBookingList(
                                bookings: controller.bookings,
                                controller: controller),
                      ),
                      //pagination
                      Container(
                        height: isMobile ? 40 : 30,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.getBookingSearchPreviousPage();
                              },
                              icon: const Icon(
                                Icons.navigate_before_sharp,
                              ),
                              padding: const EdgeInsets.all(0),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.getBookingSearchNextPage();
                              },
                              icon: const Icon(
                                Icons.navigate_next_sharp,
                              ),
                              padding: const EdgeInsets.all(0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeManagement.borderRadius8),
                          color: ColorManagement.greenColor,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 3),
                                blurRadius: 4)
                          ]),
                      margin: const EdgeInsets.only(
                        left: SizeManagement.cardOutsideHorizontalPadding,
                        right: SizeManagement.cardOutsideHorizontalPadding,
                        bottom: SizeManagement.rowSpacing,
                      ),
                      height: 45,
                      child: Row(
                        children: [
                          Expanded(
                              child: Center(
                            child: NeutronTextTitle(
                              message:
                                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${NumberUtil.numberFormat.format(controller.getTotal())}',
                            ),
                          )),
                          Expanded(
                              child: Center(
                            child: NeutronTextTitle(
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT)}: ${NumberUtil.numberFormat.format(controller.getPaymentTotal())}'),
                          )),
                          Expanded(
                              child: Center(
                            child: NeutronTextTitle(
                                message:
                                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN)}: ${NumberUtil.numberFormat.format(controller.getRemainTotal())}'),
                          )),
                        ],
                      ),
                    ),
                  )
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget buildSearchInputInMobile(
      SearchControllers controller, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //sid
        NeutronTextFormField(
          isDecor: true,
          backgroundColor: ColorManagement.lightMainBackground,
          borderColor: ColorManagement.lightMainBackground,
          label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SID),
          controller: controller.sIDController,
        ),
        //in out
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.only(
            top: SizeManagement.rowSpacing,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: NeutronDropDown(
                    value: controller.selectDate,
                    onChanged: (String sourceName) async {
                      controller.setSelectDate(sourceName);
                    },
                    items: controller.listSelect),
              ),
              SizedBox(
                  width: 90,
                  child: NeutronDateTimePickerBorder(
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_START_DATE),
                    initialDate: controller.startDate,
                    firstDate:
                        controller.now.subtract(const Duration(days: 365)),
                    lastDate: controller.now.add(const Duration(days: 365)),
                    isEditDateTime: true,
                    onPressed: (DateTime? picked) {
                      if (picked == null) return;
                      controller.setStartDate(picked);
                    },
                  )),
              const SizedBox(width: 4),
              SizedBox(
                  width: 90,
                  child: NeutronDateTimePickerBorder(
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TOOLTIP_END_DATE),
                    initialDate: controller.endDate,
                    firstDate: controller.startDate,
                    lastDate:
                        controller.startDate!.add(const Duration(days: 30)),
                    isEditDateTime: true,
                    onPressed: (DateTime? picked) {
                      if (picked == null) return;
                      controller.setEndDate(picked);
                    },
                  )),
            ],
          ),
        ),
        //source + status
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
          child: Row(
            children: [
              Expanded(
                child: NeutronDropDown(
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
              Expanded(child: buildDropDow(controller)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.POPUPMENU_DECLARE)),
                  Checkbox(
                    value: controller.checkTaxDeclare,
                    checkColor: ColorManagement.greenColor,
                    onChanged: (value) {
                      controller.setTaxDeclare(value!);
                    },
                  )
                ],
              ),
              IconButton(
                iconSize: 18,
                icon: Icon(
                    controller.isShowNote
                        ? Icons.speaker_notes
                        : Icons.speaker_notes_off,
                    color: controller.isShowNote
                        ? ColorManagement.white
                        : ColorManagement.redColor),
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SHOW_NOTES),
                onPressed: () async {
                  controller.onChange();
                },
              ),
              NeutronBlurButton(
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                icon: Icons.file_present_rounded,
                onPressed: () async {
                  await controller.loadingDataBookingExcel().then((value) {
                    ExcelUlti.exportBookingSearch(value);
                  });
                },
              )
            ],
          ),
        ),
        //icons
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.only(top: SizeManagement.rowSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.loadBookingSearch();
                },
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESET),
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.reset();
                },
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildSearchInputInPC(
      SearchControllers controller, BuildContext context) {
    return Row(
      children: [
        //sid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextFormField(
              label: UITitleUtil.getTitleByCode(UITitleCode.HINT_SID),
              controller: controller.sIDController,
            ),
          ),
        ),

        //in + out
        Expanded(
          flex: 3,
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: NeutronDropDown(
                    value: controller.selectDate,
                    onChanged: (String sourceName) async {
                      controller.setSelectDate(sourceName);
                    },
                    items: controller.listSelect),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                        width: 120,
                        child: NeutronDateTimePickerBorder(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_START_DATE),
                          initialDate: controller.startDate,
                          firstDate: controller.now
                              .subtract(const Duration(days: 365)),
                          lastDate:
                              controller.now.add(const Duration(days: 365)),
                          isEditDateTime: true,
                          onPressed: (DateTime? picked) {
                            if (picked == null) return;
                            controller.setStartDate(picked);
                          },
                        )),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 120,
                        child: NeutronDateTimePickerBorder(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_END_DATE),
                          initialDate: controller.endDate,
                          firstDate: controller.startDate ?? controller.now,
                          lastDate: controller.startDate == null
                              ? controller.now.add(const Duration(days: 30))
                              : controller.startDate!
                                  .add(const Duration(days: 30)),
                          isEditDateTime: true,
                          onPressed: (DateTime? picked) {
                            if (picked == null) return;
                            controller.setEndDate(picked);
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        //source + status
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: NeutronDropDown(
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
              Expanded(child: buildDropDow(controller)),
            ],
          ),
        ),
        //Declare
        const SizedBox(width: SizeManagement.cardInsideHorizontalPadding),
        SizedBox(
          width: 150,
          child: Row(
            children: [
              NeutronTextContent(
                  message: UITitleUtil.getTitleByCode(
                      UITitleCode.POPUPMENU_DECLARE)),
              Checkbox(
                value: controller.checkTaxDeclare,
                checkColor: ColorManagement.greenColor,
                onChanged: (value) {
                  controller.setTaxDeclare(value!);
                },
              )
            ],
          ),
        ),
        IconButton(
          iconSize: 18,
          icon: Icon(
              controller.isShowNote
                  ? Icons.speaker_notes
                  : Icons.speaker_notes_off,
              color: controller.isShowNote
                  ? ColorManagement.white
                  : ColorManagement.redColor),
          tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SHOW_NOTES),
          onPressed: () async {
            controller.onChange();
          },
        ),
        NeutronBlurButton(
          tooltip:
              UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
          icon: Icons.file_present_rounded,
          onPressed: () async {
            await controller.loadingDataBookingExcel().then((value) {
              ExcelUlti.exportBookingSearch(value);
            });
          },
        ),
        //search icon + reset icon
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_SEARCH),
                icon: const Icon(Icons.search),
                onPressed: () {
                  controller.loadBookingSearch();
                },
              ),
              IconButton(
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_RESET),
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.reset();
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  DropdownButtonHideUnderline buildDropDow(SearchControllers controller) =>
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: ColorManagement.mainBackground,
          dropdownColor: ColorManagement.lightMainBackground,
          isExpanded: true,
          hint: NeutronTextContent(
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS)),
          items: controller
              .getStatusWithoutMoved()
              .map((item) => DropdownMenuItem(
                    value: item,
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) => Row(
                        children: [
                          Checkbox(
                            fillColor: MaterialStatePropertyAll(
                                controller.getColorByStatusBooking(item)),
                            value: controller.selectedStatus.contains(item),
                            onChanged: (value) {
                              controller.setStatusID(item, value!);
                              menuSetState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeutronTextContent(message: item),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          value: controller.selectedStatus.isEmpty
              ? null
              : controller.selectedStatus.first,
          onChanged: (value) {},
          // selectedItemBuilder: (context) => controller.mapData.keys
          //     .map((item) => NeutronTextContent(
          //         message: controller.selectedStatus.join(', ')))
          //     .toList(),
        ),
      );
}
