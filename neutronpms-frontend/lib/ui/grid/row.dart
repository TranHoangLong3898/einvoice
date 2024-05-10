import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../controller/currentbookingcontroller.dart';
import '../../controller/sizeforfrontdeskboardcontroller.dart';
import '../../manager/generalmanager.dart';
import '../../util/designmanagement.dart';
import '../controls/neutrondatetimepicker.dart';
import '../controls/neutrontextcontent.dart';
import 'cell.dart';

class DateRow extends StatelessWidget {
  final CurrentBookingsController controller;

  const DateRow({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...buildArrowNavigator(),
        ...List<DateCell>.generate(
          GeneralManager.numDates,
          (i) => DateCell(date: controller.currentDate!.add(Duration(days: i))),
        ),
        buildDateNavigator(context)
      ],
    );
  }

  List<Widget> buildArrowNavigator() => [
        //Previous
        Container(
          width: GeneralManager.cellWidth / 4,
          height: GeneralManager.dateCellHeight,
          decoration: const BoxDecoration(
            color: ColorManagement.dateCellBackground,
            border: Border(
              left: BorderSide(width: 0.2, color: ColorManagement.borderCell),
              top: BorderSide(width: 0.2, color: ColorManagement.borderCell),
              bottom: BorderSide(width: 0.2, color: ColorManagement.borderCell),
            ),
          ),
          child: IconButton(
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_PREVIOUS),
            icon: const Icon(Icons.navigate_before,
                color: Colors.black, size: 24.0),
            onPressed: () => controller.setDate(
              controller.currentDate!
                  .subtract(Duration(days: GeneralManager.sizeDatesForBoard)),
            ),
          ),
        ),
        Container(
          width: GeneralManager.cellWidth / 4,
          height: GeneralManager.dateCellHeight,
          decoration: const BoxDecoration(
            color: ColorManagement.dateCellBackground,
            border: Border(
              right: BorderSide(width: 0.2, color: ColorManagement.borderCell),
              top: BorderSide(width: 0.2, color: ColorManagement.borderCell),
              bottom: BorderSide(width: 0.2, color: ColorManagement.borderCell),
            ),
          ),
          child: IconButton(
            tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_NEXT),
            icon: const Icon(Icons.navigate_next,
                color: Colors.black, size: 24.0),
            onPressed: () => controller.setDate(
              controller.currentDate!
                  .add(Duration(days: GeneralManager.sizeDatesForBoard)),
            ),
          ),
        )
      ];

  buildDateNavigator(BuildContext context) => SizedBox(
        width: GeneralManager.cellWidth / 2,
        height: GeneralManager.dateCellHeight,
        child: Row(
          children: [
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorManagement.dateCellBackground,
                    border: Border.all(
                        width: 0.2, color: ColorManagement.borderCell),
                  ),
                  child: IconButton(
                    color: ColorManagement.textBlack,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    tooltip:
                        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DATE),
                    onPressed: () => _selectDate(context),
                  )),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorManagement.dateCellBackground,
                border:
                    Border.all(width: 0.2, color: ColorManagement.borderCell),
              ),
              child: ChangeNotifierProvider.value(
                value: SizeForFrontDeskBoardController(),
                child: Consumer<SizeForFrontDeskBoardController>(
                  builder: (_, sizeFrontBoardcontroller, __) =>
                      Column(children: [
                    Expanded(
                      child: Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_WEEK_DAY),
                        child: TextButton(
                            onPressed: () async {
                              controller.cancelStream();
                              controller.asyncBookingsWithCloud();
                              sizeFrontBoardcontroller.onChange(7);
                              await sizeFrontBoardcontroller.save().then(
                                  (value) =>
                                      sizeFrontBoardcontroller.rebuild());
                            },
                            child: const NeutronTextContent(
                              color: ColorManagement.textBlack,
                              message: "S",
                            )),
                      ),
                    ),
                    Expanded(
                      child: Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_HALF_A_MONTH),
                        child: TextButton(
                            onPressed: () async {
                              controller.cancelStream();
                              controller.asyncBookingsWithCloud();
                              sizeFrontBoardcontroller.onChange(15);
                              await sizeFrontBoardcontroller.save().then(
                                  (value) =>
                                      sizeFrontBoardcontroller.rebuild());
                              await controller
                                  .getAsyncBookingsWithCloudOf15Day();
                            },
                            child: const NeutronTextContent(
                              color: ColorManagement.textBlack,
                              message: "M",
                            )),
                      ),
                    ),
                    Expanded(
                      child: Tooltip(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ONE_MONTH),
                        child: TextButton(
                            onPressed: () async {
                              controller.cancelStream();
                              controller.asyncBookingsWithCloud();
                              sizeFrontBoardcontroller.onChange(30);
                              await sizeFrontBoardcontroller.save().then(
                                  (value) =>
                                      sizeFrontBoardcontroller.rebuild());
                              await controller
                                  .getAsyncBookingsWithCloudOf15Day();
                              await controller
                                  .getAsyncBookingsWithCloudOf25Day();
                              await controller.getAsyncBookingsWithCloud30Day();
                            },
                            child: const NeutronTextContent(
                              color: ColorManagement.textBlack,
                              message: "L",
                            )),
                      ),
                    ),
                  ]),
                ),
              ),
            ))
          ],
        ),
      );

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = Timestamp.now().toDate();
    final DateTime? picked = await showDatePicker(
      builder: (context, child) =>
          DateTimePickerDarkTheme.buildDarkTheme(context, child!),
      context: context,
      initialDate: controller.currentDate!.add(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(Duration(days: 501 - GeneralManager.sizeDatesForBoard)),
    );

    if (picked != null) {
      controller.setDate(picked.subtract(const Duration(days: 1)));
    }
  }
}
