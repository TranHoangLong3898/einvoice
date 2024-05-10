import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/adminmanager/sourcemanagementcontroller.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/validator/stringvalidator.dart';
import 'package:provider/provider.dart';

class SourceManagementDialog extends StatelessWidget {
  const SourceManagementDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveUtil.isMobile(context);

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: isMobile ? kMobileWidth : kWidth,
            height: kHeight,
            child: Scaffold(
              appBar: AppBar(
                title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_SOURCE_MANAGEMENT)),
                backgroundColor: ColorManagement.mainBackground,
                actions: const [],
              ),
              backgroundColor: ColorManagement.mainBackground,
              body: ChangeNotifierProvider<SourceManager>.value(
                  value: SourceManager(),
                  child: Consumer<SourceManager>(
                    builder: (_, controller, __) {
                      if (controller.isInprogress) {
                        return const Center(
                          widthFactor: 50,
                          heightFactor: 50,
                          child: CircularProgressIndicator(
                            color: ColorManagement.greenColor,
                          ),
                        );
                      }
                      final children = controller.dataSources
                          .where((source) {
                            bool isActive = source['active'] ?? true;
                            if (controller.statusServiceFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_ACTIVE)) return isActive;
                            if (controller.statusServiceFilter ==
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.STATUS_DEACTIVE)) {
                              return !isActive;
                            }
                            return true;
                          })
                          .map((source) => Container(
                                height: SizeManagement.cardHeight,
                                margin: const EdgeInsets.symmetric(
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding,
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                decoration: BoxDecoration(
                                    color: ColorManagement.lightMainBackground,
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8)),
                                child: Row(
                                  children: [
                                    //id
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding,
                                          right: 4),
                                      child: NeutronTextContent(
                                        textOverflow: TextOverflow.clip,
                                        message: source['id'],
                                      ),
                                    )),
                                    //name
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextContent(
                                          tooltip: source['name'],
                                          message: source['name'],
                                        )),
                                    //mapping source
                                    if (!isMobile)
                                      Expanded(
                                          flex: 2,
                                          child: NeutronTextContent(
                                              tooltip: (source['mapping_source'] ==
                                                          null ||
                                                      source['mapping_source'] ==
                                                          '')
                                                  ? MessageUtil
                                                      .getMessageByCode(
                                                          MessageCodeUtil
                                                              .NO_DATA)
                                                  : source['mapping_source'],
                                              message: (source['mapping_source'] ==
                                                          null ||
                                                      source['mapping_source'] ==
                                                          '')
                                                  ? MessageUtil
                                                      .getMessageByCode(
                                                          MessageCodeUtil
                                                              .NO_DATA)
                                                  : source['mapping_source'])),
                                    //ota
                                    if (!isMobile)
                                      Expanded(
                                          child: Center(
                                        child: Checkbox(
                                          checkColor:
                                              ColorManagement.greenColor,
                                          value: source['ota'] ?? false,
                                          onChanged: (bool? value) {},
                                        ),
                                      )),
                                    //switch
                                    Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      child: Switch(
                                          value: source['active'] ?? true,
                                          activeColor:
                                              ColorManagement.greenColor,
                                          inactiveTrackColor:
                                              ColorManagement.mainBackground,
                                          onChanged: (bool value) async {
                                            bool? confirm;
                                            String result;
                                            //false is deactivate, true is activate
                                            if (value == false) {
                                              confirm = await MaterialUtil
                                                  .showConfirm(
                                                      context,
                                                      MessageUtil.getMessageByCode(
                                                          MessageCodeUtil
                                                              .CONFIRM_DEACTIVE,
                                                          [source['name']]));
                                              if (confirm == null ||
                                                  confirm == false) return;
                                              result = await controller
                                                  .toggleActiveSourceFromCloud(
                                                      source['id'])
                                                  .then((value) => value);
                                            } else {
                                              confirm = await MaterialUtil
                                                  .showConfirm(
                                                      context,
                                                      MessageUtil
                                                          .getMessageByCode(
                                                              MessageCodeUtil
                                                                  .CONFIRM_ACTIVE,
                                                              [
                                                            source['name']
                                                          ]));
                                              if (confirm == null ||
                                                  confirm == false) return;
                                              result = await controller
                                                  .toggleActiveSourceFromCloud(
                                                      source['id'])
                                                  .then((value) => value);
                                            }

                                            result =
                                                MessageUtil.getMessageByCode(
                                                    result);
                                            // ignore: use_build_context_synchronously
                                            MaterialUtil.showResult(
                                                context, result);
                                          }),
                                    ),
                                    //edit-button
                                    SizedBox(
                                      width: 40,
                                      child: InkWell(
                                        child: const Icon(Icons.edit),
                                        onTap: () async {
                                          String? result = await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  AddSourceManagementDialog(
                                                    source: source,
                                                  )).then((value) => value);
                                          if (result == null) return;
                                          // ignore: use_build_context_synchronously
                                          MaterialUtil.showSnackBar(
                                              context, result);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList();
                      return Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 65),
                          child: Column(
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  height: SizeManagement.cardHeight,
                                  child: Row(
                                    children: [
                                      //id
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardInsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_ID),
                                          ),
                                        ),
                                      ),
                                      //name
                                      Expanded(
                                        flex: 2,
                                        child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_NAME),
                                        ),
                                      ),
                                      //mapping-source
                                      if (!isMobile)
                                        Expanded(
                                          flex: 2,
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_MAPPING_SOURCE),
                                          ),
                                        ),
                                      //ota
                                      if (!isMobile)
                                        Expanded(
                                          child: Center(
                                            child: NeutronTextTitle(
                                              isPadding: false,
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_OTA),
                                            ),
                                          ),
                                        ),
                                      //active
                                      Container(
                                          width: 100,
                                          alignment: Alignment.center,
                                          child: NeutronDropDown(
                                            textStyle: const TextStyle(
                                                color: ColorManagement
                                                    .mainColorText,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                fontFamily:
                                                    FontManagement.fontFamily),
                                            isCenter: true,
                                            items: [
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_DEACTIVE),
                                              UITitleUtil.getTitleByCode(
                                                  UITitleCode.STATUS_ALL)
                                            ],
                                            value:
                                                controller.statusServiceFilter,
                                            onChanged: (value) {
                                              controller.setStatusFilter(value);
                                            },
                                          )),
                                      const SizedBox(
                                        width: 40,
                                      )
                                    ],
                                  )),
                              //list
                              Expanded(
                                child: ListView(
                                  children: children,
                                ),
                              )
                            ],
                          ),
                        ),
                        //add-button
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                            icon: Icons.add,
                            onPressed: () async {
                              String? result = await showDialog(
                                      context: context,
                                      builder: (ctx) =>
                                          const AddSourceManagementDialog())
                                  .then((value) => value);
                              if (result == null) return;
                              // ignore: use_build_context_synchronously
                              MaterialUtil.showSnackBar(context, result);
                            },
                          ),
                        )
                      ]);
                    },
                  )),
            )));
  }
}

// ignore: must_be_immutable
class AddSourceManagementDialog extends StatefulWidget {
  final dynamic source;

  const AddSourceManagementDialog({Key? key, this.source}) : super(key: key);

  @override
  State<AddSourceManagementDialog> createState() =>
      _AddSourceManagementDialogState();
}

class _AddSourceManagementDialogState extends State<AddSourceManagementDialog> {
  late SourceManagementController controller;
  @override
  void initState() {
    controller = SourceManagementController(widget.source);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        width: kMobileWidth,
        color: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<SourceManagementController>.value(
          value: controller,
          child: Consumer<SourceManagementController>(
            builder: (_, controller, __) {
              return controller.isInProgress
                  ? ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: kMobileWidth),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: ColorManagement.greenColor,
                        ),
                      ),
                    )
                  : Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextHeader(
                                message: controller.isAddFeature
                                    ? UITitleUtil.getTitleByCode(
                                        UITitleCode.HEADER_CREATE_SOURCE)
                                    : UITitleUtil.getTitleByCode(
                                        UITitleCode.HEADER_UPDATE_SOURCE),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  top: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                isRequired: true,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ID),
                                isPadding: false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextFormField(
                                readOnly: !controller.isAddFeature,
                                isDecor: true,
                                controller: controller.teIdController,
                                validator: (value) {
                                  return StringValidator.validateRequiredId(
                                      value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  top: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                isRequired: true,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_NAME),
                                isPadding: false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextFormField(
                                isDecor: true,
                                controller: controller.teNameController,
                                validator: (value) {
                                  return StringValidator
                                      .validateRequiredNonSpecificCharacterName(
                                          value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  right: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  top: SizeManagement.rowSpacing),
                              child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_MAPPING_SOURCE),
                                isPadding: false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding,
                                  vertical: SizeManagement.rowSpacing),
                              child: NeutronTextFormField(
                                isDecor: true,
                                controller:
                                    controller.teMappingSourceController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    right: SizeManagement
                                        .cardOutsideHorizontalPadding,
                                    top: SizeManagement.rowSpacing,
                                    bottom:
                                        SizeManagement.bottomFormFieldSpacing),
                                child: Row(
                                  children: [
                                    //ota
                                    Expanded(
                                      child: CheckboxListTile(
                                        contentPadding: const EdgeInsets.all(0),
                                        title: NeutronTextTitle(
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_OTA),
                                          isPadding: false,
                                        ),
                                        checkColor: ColorManagement.greenColor,
                                        onChanged: (bool? value) {
                                          controller.setOTA(value!);
                                        },
                                        value: controller.isOta,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: SizeManagement
                                          .cardOutsideHorizontalPadding,
                                    ),
                                    //active
                                    SizedBox(
                                        width: 170,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: NeutronTextTitle(
                                              message:
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_STATUS),
                                            )),
                                            Switch(
                                                value: controller.isActive,
                                                activeColor:
                                                    ColorManagement.greenColor,
                                                inactiveTrackColor:
                                                    ColorManagement
                                                        .mainBackground,
                                                onChanged: (bool value) async {
                                                  if (controller.isAddFeature) {
                                                    return;
                                                  }
                                                  controller.setActive(value);
                                                }),
                                          ],
                                        )),
                                  ],
                                )),
                            NeutronButton(
                              icon: Icons.save,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  String result = await controller
                                      .updateSource()
                                      .then((value) => value);
                                  if (!mounted) {
                                    return;
                                  }
                                  if (result ==
                                      MessageUtil.getMessageByCode(
                                          MessageCodeUtil.SUCCESS)) {
                                    Navigator.pop(context, result);
                                  } else {
                                    MaterialUtil.showAlert(context, result);
                                  }
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
