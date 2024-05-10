import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/warehouse/warehousecontroller.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';
import '../../../manager/generalmanager.dart';
import '../../../manager/roles.dart';
import '../../../modal/warehouse/warehouse.dart';
import '../../../util/designmanagement.dart';
import '../../../util/uimultilanguageutil.dart';

// ignore: must_be_immutable
class WarehouseDialog extends StatelessWidget {
  final Warehouse? warehouse;
  WarehouseController? warehouseController;
  final _formKey = GlobalKey<FormState>();

  WarehouseDialog({Key? key, this.warehouse}) : super(key: key) {
    warehouseController = WarehouseController(warehouse);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: SingleChildScrollView(
          child: SizedBox(
            width: kMobileWidth,
            child: Form(
              key: _formKey,
              child: ChangeNotifierProvider<WarehouseController>.value(
                value: warehouseController!,
                child: Consumer<WarehouseController>(
                    builder: (_, warehouseController, __) => warehouseController
                            .isInProgress
                        ? Container(
                            height: kMobileWidth,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                                color: ColorManagement.greenColor),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: SizeManagement.rowSpacing,
                                horizontal: SizeManagement
                                    .cardOutsideHorizontalPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical:
                                        SizeManagement.topHeaderTextSpacing,
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                  ),
                                  child: NeutronTextHeader(
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_WAREHOUSE)),
                                ),
                                //id
                                NeutronTextFormField(
                                  controller: warehouseController.teId,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ID),
                                  labelRequired: true,
                                  isDecor: true,
                                  readOnly: warehouse != null,
                                  validator: (String? id) {
                                    return StringValidator.validateRequiredId(
                                        id);
                                  },
                                ),
                                const SizedBox(
                                  height: 2 * SizeManagement.rowSpacing,
                                ),
                                //name
                                NeutronTextFormField(
                                  controller: warehouseController.teName,
                                  label: UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NAME),
                                  labelRequired: true,
                                  isDecor: true,
                                  validator: (String? name) {
                                    return StringValidator.validateRequiredName(
                                        name);
                                  },
                                ),
                                const SizedBox(
                                  height: 2 * SizeManagement.rowSpacing,
                                ),
                                //import role
                                ExpansionTile(
                                  collapsedIconColor:
                                      ColorManagement.trailingIconColor,
                                  iconColor: ColorManagement.trailingIconColor,
                                  title: NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_IMPORT_ROLE),
                                    maxLines: 2,
                                  ),
                                  children: [
                                    SizedBox(
                                      height: 97,
                                      child: ListView(
                                        children: warehouseController.users!
                                            .where((element) => GeneralManager
                                                .hotel!.roles![element.id]
                                                .contains(
                                                    Roles.warehouseManager))
                                            .map((user) => SizedBox(
                                                  height: 30,
                                                  width: double.infinity,
                                                  child: CheckboxListTile(
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    contentPadding:
                                                        const EdgeInsets.all(0),
                                                    value: warehouseController
                                                        .grantRoleImports
                                                        .contains(user.id),
                                                    onChanged: (bool? value) =>
                                                        warehouseController
                                                            .setUserForImportRoleWarehouse(
                                                                user.id!,
                                                                value!),
                                                    activeColor: ColorManagement
                                                        .orangeColor,
                                                    title: Transform.translate(
                                                      offset:
                                                          const Offset(-20, 0),
                                                      child: NeutronTextContent(
                                                          message: user.email!),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  endIndent: 16,
                                  indent: 16,
                                  color: Colors.white,
                                ),
                                //export role
                                ExpansionTile(
                                  collapsedIconColor:
                                      ColorManagement.trailingIconColor,
                                  iconColor: ColorManagement.trailingIconColor,
                                  title: NeutronTextTitle(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_EXPORT_ROLE),
                                    maxLines: 2,
                                  ),
                                  children: [
                                    SizedBox(
                                      height: 97,
                                      child: ListView(
                                          children: warehouseController.users!
                                              .where((element) => GeneralManager
                                                  .hotel!.roles![element.id]
                                                  .contains(
                                                      Roles.warehouseManager))
                                              .map((user) => SizedBox(
                                                    height: 30,
                                                    width: double.infinity,
                                                    child: CheckboxListTile(
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .leading,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      value: warehouseController
                                                          .grantRoleExports
                                                          .contains(user.id),
                                                      onChanged: (bool?
                                                              value) =>
                                                          warehouseController
                                                              .setUserForExportRoleWarehouse(
                                                                  user.id!,
                                                                  value!),
                                                      activeColor:
                                                          ColorManagement
                                                              .orangeColor,
                                                      title:
                                                          Transform.translate(
                                                        offset: const Offset(
                                                            -20, 0),
                                                        child:
                                                            NeutronTextContent(
                                                                message: user
                                                                    .email!),
                                                      ),
                                                    ),
                                                  ))
                                              .toList()),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 2 * SizeManagement.rowSpacing,
                                ),
                                NeutronButton(
                                  icon: Icons.save,
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    String result = await warehouseController
                                        .updateWarehouse();
                                    if (result == MessageCodeUtil.SUCCESS) {
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);
                                    }
                                    // ignore: use_build_context_synchronously
                                    MaterialUtil.showResult(context,
                                        MessageUtil.getMessageByCode(result));
                                  },
                                )
                              ],
                            ),
                          )),
              ),
            ),
          ),
        ));
  }
}
