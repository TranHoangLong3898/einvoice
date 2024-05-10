import 'package:flutter/material.dart';
import 'package:ihotel/controller/hotel/addroomcontroller.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/modal/room.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class AddRoomDialog extends StatelessWidget {
  final Room? room;
  final String? roomType;
  final formKey = GlobalKey<FormState>();

  AddRoomDialog({Key? key, this.room, this.roomType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SizedBox(
            width: kMobileWidth,
            child: ChangeNotifierProvider<AddRoomController>.value(
              value: AddRoomController(room, roomType),
              child: Consumer<AddRoomController>(
                builder: (_, controller, __) {
                  return controller.isLoading
                      ? Container(
                          height: kMobileWidth,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: ColorManagement.greenColor,
                          ))
                      : Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          SizeManagement.topHeaderTextSpacing),
                                  child: NeutronTextHeader(
                                    message: controller.isAddFeature
                                        ? UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_CREATE_RO0M)
                                        : UITitleUtil.getTitleByCode(
                                            UITitleCode.HEADER_UPDATE_ROOM),
                                  ),
                                ),
                                // Id Roomtype
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ROOM_ID),
                                    isPadding: false,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    readOnly: !controller.isAddFeature,
                                    isDecor: true,
                                    controller: controller.teId,
                                    validator: (value) {
                                      return StringValidator.validateRequiredId(
                                          value);
                                    },
                                  ),
                                ),
                                // Name roomType
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_NAME),
                                    isPadding: false,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8),
                                      color:
                                          ColorManagement.lightMainBackground),
                                  margin: const EdgeInsets.only(
                                      left: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      right: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      bottom: SizeManagement
                                          .bottomFormFieldSpacing),
                                  child: NeutronTextFormField(
                                    isDecor: true,
                                    controller: controller.teName,
                                    validator: (value) {
                                      return StringValidator
                                          .validateRequiredName(value);
                                    },
                                  ),
                                ),
                                // Dropdown roomtype
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                      vertical: SizeManagement.rowSpacing),
                                  child: NeutronTextTitle(
                                    isRequired: true,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ROOMTYPE),
                                    isPadding: false,
                                  ),
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            SizeManagement.borderRadius8),
                                        color: ColorManagement
                                            .lightMainBackground),
                                    margin: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing),
                                    child: NeutronDropDownCustom(
                                      childWidget: NeutronDropDown(
                                        isPadding: false,
                                        value: controller.teRoomType != ''
                                            ? RoomTypeManager()
                                                .getRoomTypeNameByID(
                                                    controller.teRoomType)
                                            : UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_CHOOSE),
                                        onChanged: (value) {
                                          controller.setRoomTypeId(value);
                                        },
                                        items: [
                                          UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_CHOOSE),
                                          ...RoomTypeManager()
                                              .getRoomTypeNamesActived()
                                        ],
                                      ),
                                    )),
                                NeutronButton(
                                  icon: Icons.save,
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final result = await controller.addRoom();
                                      if (result.isEmpty) {
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context, result);
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        MaterialUtil.showAlert(context, result);
                                      }
                                    }
                                  },
                                )
                              ],
                            ),
                          ));
                },
              ),
            )));
  }
}
