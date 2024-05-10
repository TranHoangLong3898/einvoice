import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/adminmanager/packageversioncontroller.dart';
import 'package:ihotel/ui/component/admin/packagevesion/addandupdatepackagedialogdialog.dart';
import 'package:ihotel/ui/controls/neutronblurbutton.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class PackageVersionDialog extends StatefulWidget {
  const PackageVersionDialog({super.key});

  @override
  State<PackageVersionDialog> createState() => _PackageVersionDialogState();
}

class _PackageVersionDialogState extends State<PackageVersionDialog> {
  late final PackageVersionController packageVersionController;

  @override
  void initState() {
    packageVersionController = PackageVersionController();
    super.initState();
  }

  @override
  void dispose() {
    packageVersionController.cancelStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width = isMobile ? kMobileWidth : kWidth + 100;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: width,
          height: kHeight,
          child: ChangeNotifierProvider(
            create: (context) => packageVersionController,
            child: Consumer<PackageVersionController>(
              builder: (_, controller, __) => Scaffold(
                backgroundColor: ColorManagement.mainBackground,
                appBar: AppBar(
                    title: Text(UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_PACKAGE)),
                    actions: [
                      Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: NeutronDropDown(
                          textStyle: const TextStyle(
                              color: ColorManagement.mainColorText,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              fontFamily: FontManagement.fontFamily),
                          isCenter: true,
                          items: controller.listStatus,
                          value: controller.selectStatus,
                          onChanged: (value) {
                            controller.setStatus(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8)
                    ]),
                body: Column(children: [
                  Container(
                    margin: const EdgeInsets.only(
                        right: SizeManagement.cardInsideHorizontalPadding,
                        top: SizeManagement.cardOutsideVerticalPadding,
                        left: SizeManagement.cardInsideHorizontalPadding),
                    height: SizeManagement.cardHeight,
                    child: Row(children: [
                      Expanded(
                          child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ID))),
                      Expanded(
                          child: NeutronTextTitle(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DESCRIPTION_FULL))),
                      if (!isMobile) ...[
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PRICE_TOTAL))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PACKAGE))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_START_DATE))),
                        Expanded(
                            child: NeutronTextTitle(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_END_DATE))),
                      ],
                      const SizedBox(width: 80)
                    ]),
                  ),
                  Expanded(
                      child: controller.dataMap.isEmpty
                          ? const SizedBox()
                          : SingleChildScrollView(
                              child: Column(
                                  children: controller.dataMap.keys
                                      .where((element) => element != "default")
                                      .where((element) =>
                                          (controller.selectStatus ==
                                                  UITitleUtil.getTitleByCode(UITitleCode
                                                      .STATUS_ACTIVE) &&
                                              controller.dataMap[element]
                                                  ["activate"]) ||
                                          (controller.selectStatus ==
                                                  UITitleUtil.getTitleByCode(UITitleCode
                                                      .STATUS_DEACTIVE) &&
                                              !controller.dataMap[element]
                                                  ["activate"]) ||
                                          controller.selectStatus ==
                                              UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL))
                                      .map((e) => isMobile ? buildContentMobile(e, controller) : buildContentMobilePC(e, controller))
                                      .toList()),
                            )),
                  SizedBox(
                    height: 60,
                    child: NeutronBlurButton(
                      margin: 5,
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const AddAndUpdatePackageVersionDialog());
                      },
                    ),
                  )
                ]),
              ),
            ),
          )),
    );
  }

  Widget buildContentMobile(String e, PackageVersionController controller) =>
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            color: ColorManagement.lightMainBackground),
        margin: const EdgeInsets.only(
            left: SizeManagement.cardOutsideHorizontalPadding,
            right: SizeManagement.cardOutsideHorizontalPadding,
            bottom: SizeManagement.bottomFormFieldSpacing),
        child: InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AddAndUpdatePackageVersionDialog(
                      dataPackage: controller.dataMap[e],
                      id: e,
                    ));
          },
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(child: NeutronTextContent(message: e)),
                Expanded(
                    child: NeutronTextContent(
                        message: controller.dataMap[e]["desc"])),
              ],
            ),
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: NumberUtil.numberFormat
                                .format(controller.dataMap[e]["price"]))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PACKAGE),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: controller.getPackageVersion(
                                controller.dataMap[e]["package"]))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_START_DATE),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthYearString(
                                controller.dataMap[e]["start_date"].toDate()))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_END_DATE),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                            message: DateUtil.dateToDayMonthYearString(
                                controller.dataMap[e]["end_date"].toDate()))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: controller.dataMap[e]["activate"]
                          ? controller.isLoading && controller.idPackage == e
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: ColorManagement.greenColor),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    bool? isConfirmed =
                                        await MaterialUtil.showConfirm(
                                            context,
                                            MessageUtil.getMessageByCode(
                                                MessageCodeUtil
                                                    .CONFIRM_DELETE));
                                    if (isConfirmed != null && isConfirmed) {
                                      await controller
                                          .updatePackageVersion(e)
                                          .then((result) {
                                        if (result != MessageCodeUtil.SUCCESS) {
                                          MaterialUtil.showAlert(
                                              context,
                                              MessageUtil.getMessageByCode(
                                                  result));
                                          return;
                                        }
                                        MaterialUtil.showSnackBar(
                                            context,
                                            MessageUtil.getMessageByCode(
                                                result));
                                      });
                                    }
                                  },
                                )
                          : const SizedBox(),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.star),
                        color: controller.dataMap['default'] == e
                            ? ColorManagement.greenColor
                            : null,
                        onPressed: () async {
                          await controller
                              .updateDefaultPackageVersion(e)
                              .then((result) {
                            print(result);
                            if (result != MessageCodeUtil.SUCCESS) {
                              MaterialUtil.showAlert(context,
                                  MessageUtil.getMessageByCode(result));
                              return;
                            }
                            MaterialUtil.showSnackBar(
                                context, MessageUtil.getMessageByCode(result));
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

  Widget buildContentMobilePC(String e, PackageVersionController controller) =>
      InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AddAndUpdatePackageVersionDialog(
                    dataPackage: controller.dataMap[e],
                    id: e,
                  ));
        },
        child: Container(
          margin: const EdgeInsets.only(
              right: SizeManagement.cardInsideHorizontalPadding,
              top: SizeManagement.cardOutsideVerticalPadding,
              left: SizeManagement.cardInsideHorizontalPadding),
          padding: const EdgeInsets.only(left: 10),
          height: SizeManagement.cardHeight,
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          child: Row(children: [
            Expanded(child: NeutronTextContent(message: e)),
            Expanded(
                child:
                    NeutronTextContent(message: controller.dataMap[e]["desc"])),
            Expanded(
                child: NeutronTextContent(
                    message: NumberUtil.numberFormat
                        .format(controller.dataMap[e]["price"]))),
            Expanded(
                child: NeutronTextContent(
                    message: controller
                        .getPackageVersion(controller.dataMap[e]["package"]))),
            Expanded(
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthYearString(
                        controller.dataMap[e]["start_date"].toDate()))),
            Expanded(
                child: NeutronTextContent(
                    message: DateUtil.dateToDayMonthYearString(
                        controller.dataMap[e]["end_date"].toDate()))),
            SizedBox(
              width: 40,
              child: controller.dataMap[e]["activate"]
                  ? controller.isLoading && controller.idPackage == e
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: ColorManagement.greenColor),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool? isConfirmed = await MaterialUtil.showConfirm(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.CONFIRM_DELETE));
                            if (isConfirmed != null && isConfirmed) {
                              await controller
                                  .updatePackageVersion(e)
                                  .then((result) {
                                if (result != MessageCodeUtil.SUCCESS) {
                                  MaterialUtil.showAlert(context,
                                      MessageUtil.getMessageByCode(result));
                                  return;
                                }
                                MaterialUtil.showSnackBar(context,
                                    MessageUtil.getMessageByCode(result));
                              });
                            }
                          },
                        )
                  : null,
            ),
            SizedBox(
              width: 40,
              child: controller.dataMap[e]["activate"]
                  ? IconButton(
                      icon: const Icon(Icons.star),
                      color: controller.dataMap['default'] == e
                          ? ColorManagement.greenColor
                          : null,
                      onPressed: () async {
                        await controller
                            .updateDefaultPackageVersion(e)
                            .then((result) {
                          print(result);
                          if (result != MessageCodeUtil.SUCCESS) {
                            MaterialUtil.showAlert(
                                context, MessageUtil.getMessageByCode(result));
                            return;
                          }
                          MaterialUtil.showSnackBar(
                              context, MessageUtil.getMessageByCode(result));
                        });
                      },
                    )
                  : null,
            )
          ]),
        ),
      );
}
