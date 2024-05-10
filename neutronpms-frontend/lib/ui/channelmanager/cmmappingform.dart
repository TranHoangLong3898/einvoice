import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/channelmanager.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/cmsutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../controller/channelmanager/cmmappingcontroller.dart';
import '../../manager/roomtypemanager.dart';
import '../../ui/controls/neutronbutton.dart';
import '../../ui/controls/neutrontextformfield.dart';
import '../../util/dateutil.dart';
import '../../util/designmanagement.dart';
import '../../util/materialutil.dart';
import '../controls/neutrondatetimepicker.dart';

class CMMappingForm extends StatefulWidget {
  const CMMappingForm({Key? key}) : super(key: key);

  @override
  State<CMMappingForm> createState() => _CMMappingFormState();
}

class _CMMappingFormState extends State<CMMappingForm> {
  final CMMappingController cmMappingController = CMMappingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    return ChangeNotifierProvider<CMMappingController>.value(
      value: cmMappingController,
      child: Consumer<CMMappingController>(
        builder: (_, controller, __) {
          if (controller.processing) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorManagement.greenColor,
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeutronDropDownCustom(
                    horizontalContentPadding: 0,
                    verticalContentPadding: 0,
                    borderColors: ColorManagement.white,
                    childWidget: NeutronDropDown(
                      items: CmsType.cmsTypes(),
                      value: controller.cmsType!,
                      onChanged: controller.setCmsType,
                    ),
                  ),
                  Column(
                    children: [
                      if (controller.cmsType == CmsType.hotelLink) ...[
                        NeutronTextFormField(
                          isDecor: true,
                          borderColor: ColorManagement.white,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_HOTEL_ID),
                          controller: controller.mappingHotelIDController,
                        ),
                        const SizedBox(
                          height: SizeManagement.cardInsideVerticalPadding,
                        ),
                        NeutronTextFormField(
                          isDecor: true,
                          borderColor: ColorManagement.white,
                          label: UITitleUtil.getTitleByCode(UITitleCode
                              .HINT_HOTEL_AUTHENTICATION_CHANNEL_KEY),
                          controller: controller.mappingHotelKeyController,
                        ),
                      ],
                      if (controller.cmsType == CmsType.oneCms)
                        NeutronTextFormField(
                          isDecor: true,
                          borderColor: ColorManagement.white,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_PROPERTY_ID),
                          controller: controller.propertyIdController,
                        ),
                      const SizedBox(
                        height: SizeManagement.cardInsideVerticalPadding,
                      ),
                      NeutronButton(
                          margin: const EdgeInsets.all(0),
                          icon: Icons.save,
                          onPressed: () async {
                            bool? success =
                                await controller.saveMappingHotelID();
                            if (!mounted) {
                              return;
                            }
                            if (success!) {
                              MaterialUtil.showSnackBar(
                                  context,
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CM_SAVE_MAPPING_HOTEL_ID_SUCCESS));
                            } else {
                              MaterialUtil.showAlert(
                                  context,
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CM_SAVE_MAPPING_HOTEL_ID_FAIL));
                            }
                          },
                          icon1: Icons.refresh,
                          onPressed1: () async {
                            final result = await controller.syncRoomTypes();
                            if (!mounted) {
                              return;
                            }
                            if (result == MessageCodeUtil.SUCCESS) {
                              MaterialUtil.showSnackBar(
                                  context,
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CM_SYNC_ROOMTYPE_SUCCESS));
                            } else {
                              MaterialUtil.showAlert(context, result);
                            }
                          },
                          icon2: Icons.delete,
                          onPressed2: () async {
                            final result =
                                await controller.clearAllCMRoomTypes();
                            if (!mounted) {
                              return;
                            }
                            if (result == null) {
                              MaterialUtil.showAlert(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CM_WAIT_FOR_PRE_ACTION));
                              return;
                            }

                            if (result) {
                              MaterialUtil.showSnackBar(
                                  context,
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CM_CLEAR_ALL_ROOMTYPE_SUCCESS));
                            } else {
                              MaterialUtil.showAlert(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.UNDEFINED_ERROR));
                            }
                          }),
                    ],
                  ),
                  DataTable(
                      // columnSpacing: 4,
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      columns: [
                        DataColumn(
                            label: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CM))),
                        DataColumn(
                            label: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PMS))),
                        DataColumn(
                            label: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_RATEPLAN)))
                      ],
                      rows: controller.mapCMPMSRoomTypes.keys
                          .map((cmRoomType) => DataRow(cells: [
                                DataCell(Tooltip(
                                    message: ChannelManager()
                                        .getCMRoomTypeNameByID(cmRoomType),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: isMobile ? 90 : 150,
                                          minWidth: isMobile ? 90 : 150),
                                      child: Text(
                                        ChannelManager()
                                            .getCMRoomTypeNameByID(cmRoomType),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))),
                                DataCell(DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor:
                                        ColorManagement.lightMainBackground,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    iconEnabledColor: Colors.white,
                                    value: controller.mapCMPMSRoomTypes[
                                                cmRoomType]['roomTypeID'] ==
                                            ''
                                        ? ''
                                        : RoomTypeManager()
                                            .getActiveRoomTypeNameByID(
                                                controller.mapCMPMSRoomTypes[
                                                    cmRoomType]['roomTypeID']),
                                    onChanged: (String? pmsRoomType) async {
                                      String? result = await controller
                                          .saveMappingRoomTypeNew(
                                              pmsRoomType!, cmRoomType);
                                      if (!mounted) {
                                        return;
                                      }
                                      if (result != null && result != '') {
                                        MaterialUtil.showAlert(
                                            context,
                                            MessageUtil.getMessageByCode(
                                                result));
                                      }
                                    },
                                    items: [
                                      "",
                                      ...RoomTypeManager()
                                          .getRoomTypeNamesActived(),
                                    ].map<DropdownMenuItem<String>>(
                                        (dynamic value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxWidth: isMobile ? 70 : 150,
                                              minWidth: isMobile ? 70 : 150),
                                          child: Tooltip(
                                            message: value,
                                            child: Text(
                                              value,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )),
                                DataCell(DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                      dropdownColor:
                                          ColorManagement.lightMainBackground,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      iconEnabledColor: Colors.white,
                                      value: controller.mapCMPMSRoomTypes[
                                                  cmRoomType]['ratePlanID'] !=
                                              ''
                                          ? ChannelManager()
                                              .getRatePlaneNameById(
                                                  controller.mapCMPMSRoomTypes[
                                                      cmRoomType]['ratePlanID'],
                                                  cmRoomType)
                                          : '',
                                      onChanged: (
                                        String? cmRatePlanName,
                                      ) async {
                                        String? result = await controller
                                            .saveMappingRatePlan(
                                                cmRatePlanName!, cmRoomType);
                                        if (!mounted) {
                                          return;
                                        }
                                        if (result != null && result != '') {
                                          MaterialUtil.showAlert(
                                              context, result);
                                        }
                                      },
                                      items: controller
                                          .ratePlanOfRoomType[cmRoomType]!
                                          .map<DropdownMenuItem<String>>(
                                              (String ratePlan) {
                                        return DropdownMenuItem<String>(
                                          value: ratePlan,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: isMobile ? 70 : 150,
                                                minWidth: isMobile ? 70 : 150),
                                            child: Tooltip(
                                              message: ratePlan,
                                              child: Text(
                                                ratePlan,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList()),
                                )),
                              ]))
                          .toList()),
                  const SizedBox(height: 30),
                  Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_SYNC_AVAIBILITY_PMS_TO_CM),
                      style: Theme.of(context).textTheme.bodyLarge),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateUtil.dateToHLSString(controller.startSync)),
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
                                initialDate: controller.startSync,
                                firstDate: now,
                                lastDate: now.add(const Duration(days: 700)));
                            if (picked != null &&
                                picked.compareTo(controller.startSync) != 0) {
                              controller.setStartSync(picked);
                            }
                          }),
                      Text(DateUtil.dateToHLSString(controller.endSync)),
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
                                initialDate: controller.endSync,
                                firstDate: controller.startSync,
                                lastDate: now.add(const Duration(days: 700)));
                            if (picked != null &&
                                picked.compareTo(controller.endSync) != 0) {
                              controller.setEndSync(picked);
                            }
                          }),
                    ],
                  ),
                  NeutronButton(
                      margin: const EdgeInsets.all(0),
                      icon: Icons.backup,
                      onPressed: () async {
                        bool? success = await controller.syncAvaibility();
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
                                  .CM_SYNC_AVAIBILITY_FROM_PMS_SUCCESS));
                        } else {
                          MaterialUtil.showAlert(
                              context,
                              controller.syncAvaibilityErrorFromAPI ??
                                  MessageUtil.getMessageByCode(MessageCodeUtil
                                      .CM_SYNC_AVAIBILITY_FROM_PMS_FAIL));
                        }
                      }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
