import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/dailyallotmentcontroller.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/component/hotel/roomtypedialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:provider/provider.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutrondatepicker.dart';
import '../../controls/neutrontexttilte.dart';

class DalilyAllotmentDialog extends StatefulWidget {
  const DalilyAllotmentDialog({Key? key}) : super(key: key);

  @override
  State<DalilyAllotmentDialog> createState() => _DalilyAllotmentDialogState();
}

class _DalilyAllotmentDialogState extends State<DalilyAllotmentDialog> {
  DailyAllotmentController? controller;
  @override
  void initState() {
    controller ??= DailyAllotmentController();
    super.initState();
  }

  @override
  void dispose() {
    controller?.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<DailyAllotmentController>(
        child: buildEmptyList(),
        builder: (_, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: ColorManagement.greenColor),
            );
          }
          if (controller.dailyRender.isEmpty) {
            return child!;
          }
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: SizeManagement.cardHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: NeutronMonthPicker(
                            tooltip: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_START_DATE),
                            initialMonth: controller.selectDay,
                            firstMonth: controller.now,
                            lastMonth:
                                controller.now.add(const Duration(days: 365)),
                            onChange: (picked) {
                              controller.setMonthId(picked);
                            },
                          ),
                        ),
                        Expanded(
                          child: NeutronDropDown(
                            value: RoomTypeManager()
                                .getRoomTypeNameByID(controller.roomTypeId),
                            onChanged: (value) {
                              controller.setRoomType(value);
                            },
                            items: RoomTypeManager().getRoomTypeNamesActived(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: DailyAllotmentList(controller: controller)),
                  const SizedBox(height: 60)
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                  icon: Icons.save,
                  onPressed: () async {
                    final result =
                        await controller.updateDailyAllotmentToCloud();
                    if (mounted && result != MessageCodeUtil.SUCCESS) {
                      MaterialUtil.showAlert(context, result);
                    }
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildEmptyList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            children: [
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_PLEASE)),
              TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      Navigator.pop(context);
                      await showDialog(
                          context: context,
                          builder: (context) => RoomTypeDialog());
                    },
                  text: MessageUtil.getMessageByCode(
                          MessageCodeUtil.TEXTALERT_TO_CREATE_ROOMTYPE_AND_ROOM)
                      .toLowerCase(),
                  style: const TextStyle(
                    color: ColorManagement.redColor,
                    fontSize: 20,
                  )),
              TextSpan(
                  text: MessageUtil.getMessageByCode(
                      MessageCodeUtil.TEXTALERT_FOR_HOTEL_TO_USE))
            ]),
      ),
    );
  }
}

class DailyAllotmentList extends StatelessWidget {
  const DailyAllotmentList({Key? key, required this.controller})
      : super(key: key);

  final DailyAllotmentController controller;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    return GridView.count(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      mainAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
      crossAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
      crossAxisCount: isMobile ? 2 : 4,
      childAspectRatio: isMobile ? 1.4 : 1.45,
      children: controller.dailyRender
          .map((data) => DailyAllotmentItem(
                key: Key(data['day']),
                data: data,
                controller: controller,
              ))
          .toList(),
    );
  }
}

class DailyAllotmentItem extends StatelessWidget {
  const DailyAllotmentItem(
      {Key? key, required this.data, required this.controller})
      : super(key: key);

  final Map<String, dynamic> data;

  final DailyAllotmentController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManagement.lightMainBackground,
        borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                SizeManagement.rowSpacing, SizeManagement.rowSpacing, 0, 0),
            child: NeutronTextContent(message: '${data['day']}'),
          ),
          Row(
            children: [
              Expanded(
                child: NeutronNumberInputForDailyAllotment(
                  controller:
                      controller.textEditingControllers[data['roomType']]
                          [data['day']]['num'],
                ),
              ),
              const NeutronTextTitle(
                isPadding: false,
                message: 'Room',
                fontSize: 13,
              ),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(height: SizeManagement.marginDailyAllotment),
          Row(
            children: [
              const NeutronTextTitle(
                message: 'Rate',
                fontSize: 13,
              ),
              Expanded(
                  child: NeutronInputNumberController(
                          controller.textEditingControllers[data['roomType']]
                              [data['day']]['price'])
                      .buildWidget(
                          padding: 0,
                          isDecor: false,
                          isDouble: true,
                          textAlign: TextAlign.right,
                          textColor: ColorManagement.greenColor)),
            ],
          ),
        ],
      ),
    );
  }
}
