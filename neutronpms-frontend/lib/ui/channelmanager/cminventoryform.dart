import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/cmsutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../controller/channelmanager/cminventorycontroller.dart';
import '../../ui/controls/neutronbutton.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../controls/neutrondatetimepicker.dart';
import '../controls/neutrondropdown.dart';
import '../controls/neutrontexttilte.dart';

class CMInventoryForm extends StatefulWidget {
  const CMInventoryForm({Key? key}) : super(key: key);

  @override
  State<CMInventoryForm> createState() => _CMInventoryFormState();
}

class _CMInventoryFormState extends State<CMInventoryForm> {
  final CMInventoryController cmInventoryController = CMInventoryController();
  late NeutronInputNumberController valueAvailabilityController;
  late NeutronInputNumberController valueRatesController;
  late NeutronInputNumberController valueMaxNightsController;
  late NeutronInputNumberController valueMinNightsController;
  late NeutronInputNumberController valueMaxAvailabilityController;
  late NeutronInputNumberController valueExtraAdultController;
  late NeutronInputNumberController valueExtraChildController;
  late NeutronInputNumberController valueMinStayThroughController;
  late NeutronInputNumberController valueMinStayArrivalController;
  @override
  void initState() {
    valueAvailabilityController = NeutronInputNumberController(
        cmInventoryController.valueAvailabilityController);
    valueRatesController = NeutronInputNumberController(
        cmInventoryController.valueRatesController);
    valueMaxNightsController = NeutronInputNumberController(
        cmInventoryController.valueMaxNightsController);
    valueMinNightsController = NeutronInputNumberController(
        cmInventoryController.valueMinNightsController);
    valueMaxAvailabilityController = NeutronInputNumberController(
        cmInventoryController.valueMaxAvailabilityController);
    valueExtraAdultController = NeutronInputNumberController(
        cmInventoryController.valueExtraAdultController);
    valueExtraChildController = NeutronInputNumberController(
        cmInventoryController.valueExtraChildController);
    valueMinStayThroughController = NeutronInputNumberController(
        cmInventoryController.valueMinStayThroughController);
    valueMinStayArrivalController = NeutronInputNumberController(
        cmInventoryController.valueMinStayArrivalController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    return ChangeNotifierProvider<CMInventoryController>.value(
      value: cmInventoryController,
      child: Consumer<CMInventoryController>(builder: (_, controller, __) {
        if (controller.updating) {
          return const Center(
              child: CircularProgressIndicator(
            color: ColorManagement.greenColor,
          ));
        }
        return Container(
          color: ColorManagement.lightMainBackground,
          padding: const EdgeInsets.symmetric(
              horizontal: SizeManagement.cardOutsideHorizontalPadding),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    bottom: SizeManagement.marginBottomForStack),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: SizeManagement.rowSpacing),
                      NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TYPE),
                          childWidget: buildDropDow(controller)),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: NeutronDropDownCustom(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ROOMTYPE),
                                childWidget: NeutronDropDown(
                                    isPadding: false,
                                    items: ['', ...controller.roomTypeNames],
                                    value: controller.selectedRoomType == ''
                                        ? ''
                                        : RoomTypeManager().getRoomTypeNameByID(
                                            controller.selectedRoomType),
                                    onChanged: (String value) {
                                      controller.changeSelectedRoomType(value);
                                    }),
                              ),
                            ),
                            const SizedBox(width: SizeManagement.rowSpacing),
                            Expanded(
                              child: NeutronDropDownCustom(
                                label: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_RATEPLAN),
                                childWidget: NeutronDropDown(
                                    isPadding: false,
                                    items: controller.getRatePlanNames(),
                                    value: controller.selectedRatePlan == ''
                                        ? ''
                                        : controller.getCmRatePlanNameByID(
                                            controller.selectedRatePlan),
                                    onChanged: (String value) async {
                                      controller.changeSelectedRatePlan(value);
                                    }),
                              ),
                            ),
                          ],
                        ),
                      if (isMobile)
                        NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_RATEPLAN),
                          childWidget: NeutronDropDown(
                              isPadding: false,
                              items: ['', ...controller.roomTypeNames],
                              value: controller.selectedRoomType == ''
                                  ? ''
                                  : RoomTypeManager().getRoomTypeNameByID(
                                      controller.selectedRoomType),
                              onChanged: (String value) {
                                controller.changeSelectedRoomType(value);
                              }),
                        ),
                      if (isMobile)
                        const SizedBox(height: SizeManagement.rowSpacing),
                      if (isMobile)
                        NeutronDropDownCustom(
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_RATEPLAN),
                          childWidget: NeutronDropDown(
                              isPadding: false,
                              items: controller.getRatePlanNames(),
                              value: controller.selectedRatePlan == ''
                                  ? ''
                                  : controller.getCmRatePlanNameByID(
                                      controller.selectedRatePlan),
                              onChanged: (String value) async {
                                controller.changeSelectedRatePlan(value);
                              }),
                        ),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: NeutronDateTimePickerBorder(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_START_DATE),
                              initialDate: controller.start,
                              firstDate: controller.now,
                              lastDate:
                                  controller.now.add(const Duration(days: 700)),
                              isEditDateTime: true,
                              onPressed: (DateTime? picked) {
                                if (picked == null) return;
                                if (picked.compareTo(controller.start) != 0) {
                                  controller.setStart(picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: SizeManagement.rowSpacing),
                          Expanded(
                              child: NeutronDateTimePickerBorder(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_END_DATE),
                            initialDate: controller.end,
                            firstDate: controller.start,
                            lastDate:
                                controller.now.add(const Duration(days: 700)),
                            isEditDateTime: true,
                            onPressed: (DateTime? picked) {
                              if (picked == null) return;
                              if (picked.compareTo(controller.end) != 0) {
                                controller.setEnd(picked);
                              }
                            },
                          ))
                        ],
                      ),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      Row(
                        children: [
                          if (controller.selectedType
                              .contains("Availability")) ...[
                            Expanded(
                              child: valueAvailabilityController.buildWidget(
                                isDouble: true,
                                color: ColorManagement.mainBackground,
                                isDecor: true,
                                label: "Availability",
                              ),
                            ),
                            const SizedBox(width: SizeManagement.rowSpacing),
                          ],
                          if (controller.selectedType.contains("Rate"))
                            Expanded(
                              child: valueRatesController.buildWidget(
                                isDouble: true,
                                color: ColorManagement.mainBackground,
                                isDecor: true,
                                label: "Rate",
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      if (GeneralManager.hotel!.cms == CmsType.hotelLink) ...[
                        Row(
                          children: [
                            if (controller.selectedType
                                .contains("ExtraAdultRate")) ...[
                              Expanded(
                                child: valueExtraAdultController.buildWidget(
                                  isDouble: true,
                                  color: ColorManagement.mainBackground,
                                  isDecor: true,
                                  label: "ExtraAdultRate",
                                ),
                              ),
                              const SizedBox(width: SizeManagement.rowSpacing),
                            ],
                            if (controller.selectedType
                                .contains("ExtraChildRate"))
                              Expanded(
                                child: valueExtraChildController.buildWidget(
                                  isDouble: true,
                                  color: ColorManagement.mainBackground,
                                  isDecor: true,
                                  label: "ExtraChildRate",
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                      ],
                      Row(
                        children: [
                          if (controller.selectedType
                              .contains("MinNights")) ...[
                            Expanded(
                              child: valueMinNightsController.buildWidget(
                                isDouble: true,
                                color: ColorManagement.mainBackground,
                                isDecor: true,
                                label: "MinNights",
                              ),
                            ),
                            const SizedBox(width: SizeManagement.rowSpacing),
                          ],
                          if (controller.selectedType.contains("MaxNights"))
                            Expanded(
                              child: valueMaxNightsController.buildWidget(
                                isDouble: true,
                                color: ColorManagement.mainBackground,
                                isDecor: true,
                                label: "MaxNights",
                              ),
                            ),
                        ],
                      ),
                      if (GeneralManager.hotel!.cms == CmsType.oneCms) ...[
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Row(
                          children: [
                            if (controller.selectedType
                                .contains("MinStayArrival")) ...[
                              Expanded(
                                child:
                                    valueMinStayArrivalController.buildWidget(
                                  isDouble: true,
                                  color: ColorManagement.mainBackground,
                                  isDecor: true,
                                  label: "MinStayArrival",
                                ),
                              ),
                              const SizedBox(width: SizeManagement.rowSpacing),
                            ],
                            if (controller.selectedType
                                .contains("MinStayThrough"))
                              Expanded(
                                child:
                                    valueMinStayThroughController.buildWidget(
                                  isDouble: true,
                                  color: ColorManagement.mainBackground,
                                  isDecor: true,
                                  label: "MinStayThrough",
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        if (controller.selectedType.contains("MaxAvailability"))
                          valueMaxAvailabilityController.buildWidget(
                            isDouble: true,
                            color: ColorManagement.mainBackground,
                            isDecor: true,
                            label: "MaxAvailability",
                          ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                      ],
                      Row(
                        children: [
                          if (controller.selectedType
                              .contains("CloseToArrival")) ...[
                            const Expanded(
                              child: NeutronTextTitle(
                                  fontSize: 12,
                                  messageUppercase: false,
                                  message: "CloseToArrival"),
                            ),
                            SizedBox(
                              width: 40,
                              child: Switch(
                                activeColor: ColorManagement.greenColor,
                                value: controller.isCloseToArrival,
                                onChanged: (value) =>
                                    controller.setCloseToArrival(value),
                              ),
                            ),
                          ],
                          if (controller.selectedType
                              .contains("CloseToDeparture")) ...[
                            const Expanded(
                              child: NeutronTextTitle(
                                  fontSize: 12,
                                  messageUppercase: false,
                                  message: "CloseToDeparture"),
                            ),
                            SizedBox(
                              width: 40,
                              child: Switch(
                                activeColor: ColorManagement.greenColor,
                                value: controller.isCloseToDeparture,
                                onChanged: (value) =>
                                    controller.setCloseToDeparture(value),
                              ),
                            ),
                          ],
                          if (controller.selectedType.contains("StopSell") &&
                              !isMobile) ...[
                            const Expanded(
                              child: NeutronTextTitle(
                                  fontSize: 12,
                                  messageUppercase: false,
                                  message: "StopSell"),
                            ),
                            SizedBox(
                              width: 40,
                              child: Switch(
                                activeColor: ColorManagement.greenColor,
                                value: controller.isStopSell,
                                onChanged: (value) =>
                                    controller.setStopSell(value),
                              ),
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                          ]
                        ],
                      ),
                      if (controller.selectedType.contains("StopSell") &&
                          isMobile) ...[
                        Row(
                          children: [
                            const Expanded(
                              child: NeutronTextTitle(
                                  fontSize: 12,
                                  messageUppercase: false,
                                  message: "StopSell"),
                            ),
                            Expanded(
                              child: Switch(
                                activeColor: ColorManagement.greenColor,
                                value: controller.isStopSell,
                                onChanged: (value) =>
                                    controller.setStopSell(value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                      ],
                      Container(
                        decoration: BoxDecoration(
                            color: ColorManagement.mainBackground,
                            borderRadius: BorderRadius.circular(
                                SizeManagement.borderRadius8)),
                        padding: const EdgeInsets.symmetric(
                            vertical:
                                SizeManagement.cardOutsideVerticalPadding),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const NeutronTextTitle(
                                        fontSize: 12,
                                        message: 'Mon',
                                        isPadding: false,
                                      ),
                                      Checkbox(
                                        checkColor: ColorManagement.greenColor,
                                        value: controller.isMonday,
                                        onChanged: (value) {
                                          controller.setMonDay(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const NeutronTextTitle(
                                        fontSize: 12,
                                        message: 'Tue',
                                        isPadding: false,
                                      ),
                                      Checkbox(
                                        checkColor: ColorManagement.greenColor,
                                        value: controller.isTuesday,
                                        onChanged: (value) {
                                          controller.setTuesday(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const NeutronTextTitle(
                                        fontSize: 12,
                                        message: 'Wed',
                                        isPadding: false,
                                      ),
                                      Checkbox(
                                        checkColor: ColorManagement.greenColor,
                                        value: controller.isWednesday,
                                        onChanged: (value) {
                                          controller.setWednesday(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const NeutronTextTitle(
                                        fontSize: 12,
                                        message: 'Thu',
                                        isPadding: false,
                                      ),
                                      Checkbox(
                                        checkColor: ColorManagement.greenColor,
                                        value: controller.isThursday,
                                        onChanged: (value) {
                                          controller.setThursday(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isMobile) ...[
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Fri',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isFriday,
                                          onChanged: (value) {
                                            controller.setFriday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Sat',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isSaturday,
                                          onChanged: (value) {
                                            controller.setSaturday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Sun',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isSunday,
                                          onChanged: (value) {
                                            controller.setSunday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ]
                              ],
                            ),
                            const SizedBox(height: SizeManagement.rowSpacing),
                            if (isMobile)
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Fri',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isFriday,
                                          onChanged: (value) {
                                            controller.setFriday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Sat',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isSaturday,
                                          onChanged: (value) {
                                            controller.setSaturday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const NeutronTextTitle(
                                          fontSize: 12,
                                          message: 'Sun',
                                          isPadding: false,
                                        ),
                                        Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: controller.isSunday,
                                          onChanged: (value) {
                                            controller.setSunday(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      if (controller.listOption.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeManagement.borderRadius8),
                              color: ColorManagement.mainBackground),
                          margin: const EdgeInsets.only(
                              bottom: SizeManagement.bottomFormFieldSpacing),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal:
                                    SizeManagement.cardInsideHorizontalPadding),
                            title: const NeutronTextContent(
                                message: "Danh Sách Option"),
                            children: [
                              ...controller.listOption
                                  .map((map) => Container(
                                        margin: const EdgeInsets.all(
                                            SizeManagement
                                                .cardInsideVerticalPadding),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: IconButton(
                                                  onPressed: () {
                                                    controller
                                                        .removeOption(map);
                                                  },
                                                  color: Colors.red,
                                                  icon:
                                                      const Icon(Icons.delete)),
                                            ),
                                            if (map.containsKey("RomType"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "RomType")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["RomType"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("RatePlan"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "RatePlan")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["RatePlan"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("from"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "from")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message: map["from"]
                                                              .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("to"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "to")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message: map["to"]
                                                              .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("Availability"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "Availability")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["Availability"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("Rate"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "Rate")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message: map["Rate"]
                                                              .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("ExtraAdultRate"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "ExtraAdultRate")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["ExtraAdultRate"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("ExtraChildRate"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "ExtraChildRate")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["ExtraChildRate"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("MinNights"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "MinNights")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["MinNights"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map.containsKey("MaxNights"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "MaxNights")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["MaxNights"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("MinStayArrival"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "MinStayArrival")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["MinStayArrival"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("MinStayThrough"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "MinStayThrough")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["MinStayThrough"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("MaxAvailability"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "MaxAvailability")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["MaxAvailability"]
                                                                  .toString()))
                                                ],
                                              ),
                                            if (map
                                                .containsKey("CloseToArrival"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "CloseToArrival")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["CloseToArrival"] ==
                                                                      1
                                                                  ? "Yes"
                                                                  : "No"))
                                                ],
                                              ),
                                            if (map.containsKey(
                                                "CloseToDeparture"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              "CloseToDeparture")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["CloseToDeparture"] ==
                                                                      1
                                                                  ? "Yes"
                                                                  : "No"))
                                                ],
                                              ),
                                            if (map.containsKey("StopSell"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "StopSell")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message:
                                                              map["StopSell"] ==
                                                                      1
                                                                  ? "Yes"
                                                                  : "No"))
                                                ],
                                              ),
                                            if (map.containsKey("Days"))
                                              Row(
                                                children: [
                                                  const Expanded(
                                                      child: NeutronTextContent(
                                                          message: "Days")),
                                                  Expanded(
                                                      child: NeutronTextContent(
                                                          message: map["Days"]
                                                              .toString()))
                                                ],
                                              ),
                                            const SizedBox(
                                              height:
                                                  SizeManagement.columnSpacing,
                                            ),
                                            const Divider(
                                              color: ColorManagement.greenColor,
                                              height: 0.8,
                                              thickness: 0.3,
                                            ),
                                            const SizedBox(
                                              height:
                                                  SizeManagement.columnSpacing,
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList()
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: NeutronButton(
                  icon: Icons.save,
                  onPressed: () async {
                    bool? success = await controller.updateInventory();
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
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.CM_UPDATE_INVENTORY_SUCCESS));
                    } else {
                      MaterialUtil.showAlert(
                          context,
                          controller.updateInventoryErrorFromAPI ??
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.UNDEFINED_ERROR));
                    }
                  },
                  icon1: Icons.add,
                  onPressed1: () {
                    if (controller.addOption() != MessageCodeUtil.SUCCESS) {
                      MaterialUtil.showAlert(context, controller.addOption());
                    }
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  DropdownButtonHideUnderline buildDropDow(CMInventoryController controller) =>
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          focusColor: ColorManagement.mainBackground,
          dropdownColor: ColorManagement.lightMainBackground,
          isExpanded: true,
          items: controller.types
              .map((item) => DropdownMenuItem(
                    value: item,
                    enabled: false,
                    child: StatefulBuilder(
                      builder: (context, menuSetState) => Row(
                        children: [
                          Checkbox(
                            fillColor: const MaterialStatePropertyAll(
                                ColorManagement.greenColor),
                            value: controller.selectedType.contains(item),
                            onChanged: (value) {
                              controller.setType(item, value!);
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
          value: controller.selectedType.isEmpty
              ? null
              : controller.selectedType.first,
          onChanged: (value) {},
        ),
      );
}
