// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/hotel/addrateplandialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../manager/rateplanmanager.dart';
import '../../../util/materialutil.dart';
import '../../controls/neutrondropdown.dart';

class RatePlanDialog extends StatelessWidget {
  final RatePlanManager ratePlanManager = RatePlanManager();

  RatePlanDialog({Key? key}) : super(key: key) {
    ratePlanManager.statusServiceFilter =
        UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtil.isMobile(context);
    double width;
    const height = kHeight;
    if (isMobile) {
      width = kMobileWidth;
    } else {
      width = kWidth;
    }

    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: width,
            height: height,
            child: Scaffold(
              backgroundColor: ColorManagement.mainBackground,
              appBar: AppBar(
                title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_RATE_PLAN)),
                backgroundColor: ColorManagement.mainBackground,
              ),
              body: ChangeNotifierProvider<RatePlanManager>.value(
                  value: RatePlanManager(),
                  child:
                      Consumer<RatePlanManager>(builder: (_, controller, __) {
                    if (controller.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: ColorManagement.greenColor));
                    }

                    return Stack(children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 65),
                          child: Column(
                            children: [
                              //title
                              isMobile
                                  ? buildTitleInMobile()
                                  : buildTitleInPC(),
                              Expanded(
                                  child: ListView(
                                children: isMobile
                                    ? buildListInMobile(context)
                                    : buildListInPC(context),
                              )),
                            ],
                          )),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: NeutronButton(
                          icon1: Icons.add,
                          onPressed1: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (ctx) => const AddRatePlanDialog());
                            if (result != null && result != '') {
                              MaterialUtil.showAlert(result);
                            }
                          },
                        ),
                      )
                    ]);
                  })),
            )));
  }

  Widget buildTitleInPC() {
    return Container(
        margin: const EdgeInsets.only(
            left: SizeManagement.cardOutsideHorizontalPadding +
                SizeManagement.cardInsideHorizontalPadding,
            right: SizeManagement.cardOutsideHorizontalPadding),
        height: SizeManagement.cardHeight,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding),
                child: NeutronTextTitle(
                  isPadding: false,
                  message:
                      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ID),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: NeutronTextTitle(
                isPadding: false,
                message: UITitleUtil.getTitleByCode(
                    UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
              ),
            ),
            Expanded(
              child: NeutronTextTitle(
                textAlign: TextAlign.end,
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
              ),
            ),
            SizedBox(
              width: 100,
              child: NeutronTextTitle(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PERCENT),
              ),
            ),
            SizedBox(
              width: 100,
              child: NeutronTextTitle(
                message:
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEFAULT),
              ),
            ),
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
                  items: [
                    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE),
                    UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE),
                    UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
                  ],
                  value: ratePlanManager.statusServiceFilter!,
                  onChanged: (String value) {
                    ratePlanManager.setStatusFilter(value);
                  },
                )),
            const SizedBox(width: 40)
          ],
        ));
  }

  Widget buildTitleInMobile() {
    return Container(
      margin: const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding +
              SizeManagement.cardInsideHorizontalPadding,
          right: SizeManagement.cardOutsideHorizontalPadding),
      height: SizeManagement.cardHeight,
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextTitle(
              isPadding: false,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS),
            ),
          ),
          Expanded(
            child: NeutronTextTitle(
              textAlign: TextAlign.end,
              message:
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: NeutronDropDown(
              textStyle: const TextStyle(
                  color: ColorManagement.mainColorText,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: FontManagement.fontFamily),
              isCenter: true,
              items: [
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE),
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE),
                UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)
              ],
              value: ratePlanManager.statusServiceFilter!,
              onChanged: (value) {
                ratePlanManager.setStatusFilter(value);
              },
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  List<Widget> buildListInPC(BuildContext context) {
    return ratePlanManager.ratePlans.map((rateplan) {
      if ((ratePlanManager.statusServiceFilter ==
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE) &&
              !rateplan.isDelete!) ||
          (ratePlanManager.statusServiceFilter ==
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE) &&
              rateplan.isDelete!) ||
          ratePlanManager.statusServiceFilter ==
              UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
        return Container(
          height: SizeManagement.cardHeight,
          margin: const EdgeInsets.symmetric(
              vertical: SizeManagement.cardOutsideVerticalPadding,
              horizontal: SizeManagement.cardOutsideHorizontalPadding),
          decoration: BoxDecoration(
              color: ColorManagement.lightMainBackground,
              borderRadius:
                  BorderRadius.circular(SizeManagement.borderRadius8)),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding),
                child: NeutronTextContent(
                  message: rateplan.title!,
                ),
              )),
              Expanded(
                  flex: 2,
                  child: NeutronTextContent(
                    tooltip: rateplan.decs,
                    message: rateplan.decs!,
                  )),
              Expanded(
                child: NeutronTextContent(
                  color: ColorManagement.positiveText,
                  textAlign: TextAlign.end,
                  message: NumberUtil.numberFormat.format(rateplan.amount),
                ),
              ),
              SizedBox(
                  width: 100,
                  child: Checkbox(
                    splashRadius: 0,
                    activeColor: ColorManagement.greenColor,
                    mouseCursor: MouseCursor.defer,
                    value: rateplan.percent,
                    onChanged: (bool? value) {},
                  )),
              // set default rateplan
              Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: Switch(
                      value: rateplan.isDefault!,
                      activeColor: ColorManagement.greenColor,
                      inactiveTrackColor: ColorManagement.mainBackground,
                      onChanged: (value) async {
                        if (value == false) return;
                        String result = '';
                        bool? confirm = await MaterialUtil.showConfirm(
                            context,
                            MessageUtil.getMessageByCode(
                                MessageCodeUtil.CONFIRM_SET_DEFAULT_RATE_PLAN,
                                [rateplan.title!]));
                        if (confirm == null || confirm == false) return;
                        result = await ratePlanManager
                            .setDefaultRatePlan(rateplan.title!)
                            .then((value) => value);
                        MaterialUtil.showResult(context, result);
                      })),
              Container(
                width: 100,
                alignment: Alignment.center,
                child: !ratePlanManager.isRatePlanStandardOrOTA(rateplan.title!)
                    ? Switch(
                        value: !rateplan.isDelete!,
                        activeColor: ColorManagement.greenColor,
                        inactiveTrackColor: ColorManagement.mainBackground,
                        onChanged: (value) async {
                          bool? confirm;
                          String result;
                          //false is deactivate, true is activate
                          if (value == false) {
                            confirm = await MaterialUtil.showConfirm(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.CONFIRM_DEACTIVE,
                                    [rateplan.title!]));
                            if (confirm == null || confirm == false) return;
                            result = await ratePlanManager
                                .deactiveRateplan(rateplan.title!)
                                .then((value) => value);
                          } else {
                            confirm = await MaterialUtil.showConfirm(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.CONFIRM_ACTIVE,
                                    [rateplan.title!]));
                            if (confirm == null || confirm == false) return;
                            result = await ratePlanManager
                                .activeRateplan(rateplan.title!)
                                .then((value) => value);
                          }
                          MaterialUtil.showResult(context, result);
                        })
                    : const SizedBox(),
              ),
              !ratePlanManager.isRatePlanStandardOrOTA(rateplan.title!)
                  ? SizedBox(
                      width: 40,
                      child: InkWell(
                        child: const Icon(Icons.edit),
                        onTap: () async {
                          String? result = await showDialog(
                              context: context,
                              builder: (ctx) => AddRatePlanDialog(
                                    ratePlan: rateplan,
                                  ));
                          if (result != null && result.isNotEmpty) {
                            MaterialUtil.showAlert(result);
                          }
                        },
                      ),
                    )
                  : const SizedBox(
                      width: 40,
                    ),
            ],
          ),
        );
      }
      return Container();
    }).toList();
  }

  List<Widget> buildListInMobile(BuildContext context) {
    return ratePlanManager.ratePlans.map((rateplan) {
      if ((ratePlanManager.statusServiceFilter ==
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE) &&
              !rateplan.isDelete!) ||
          (ratePlanManager.statusServiceFilter ==
                  UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE) &&
              rateplan.isDelete!) ||
          ratePlanManager.statusServiceFilter ==
              UITitleUtil.getTitleByCode(UITitleCode.STATUS_ALL)) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
              color: ColorManagement.lightMainBackground),
          margin: const EdgeInsets.symmetric(
              vertical: SizeManagement.cardOutsideVerticalPadding,
              horizontal: SizeManagement.cardOutsideHorizontalPadding),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
                horizontal: SizeManagement.cardInsideHorizontalPadding),
            title: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: NeutronTextContent(message: rateplan.title!),
                ),
                Expanded(
                  child: NeutronTextContent(
                      color: ColorManagement.positiveText,
                      textAlign: TextAlign.end,
                      message: rateplan.amount.toString()),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: ratePlanManager
                          .isRatePlanStandardOrOTA(rateplan.title!)
                      ? const SizedBox()
                      : Switch(
                          value: !rateplan.isDelete!,
                          activeColor: ColorManagement.greenColor,
                          inactiveTrackColor: ColorManagement.mainBackground,
                          onChanged: (value) async {
                            bool? confirm;
                            String result;
                            //false is deactivate, true is activate
                            if (value == false) {
                              confirm = await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CONFIRM_DEACTIVE,
                                      [rateplan.title!]));
                              if (confirm == null || confirm == false) return;
                              result = await ratePlanManager
                                  .deactiveRateplan(rateplan.title!)
                                  .then((value) => value);
                            } else {
                              confirm = await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CONFIRM_ACTIVE,
                                      [rateplan.title!]));
                              if (confirm == null || confirm == false) return;
                              result = await ratePlanManager
                                  .activeRateplan(rateplan.title!)
                                  .then((value) => value);
                            }
                            MaterialUtil.showResult(context, result);
                          }),
                ),
              ],
            ),
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding,
                    right: SizeManagement.cardInsideHorizontalPadding,
                    top: SizeManagement.cardInsideHorizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                    )),
                    Expanded(
                        child: NeutronTextContent(
                      tooltip: rateplan.decs,
                      message: rateplan.decs!,
                    ))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding,
                    right: SizeManagement.cardInsideHorizontalPadding,
                    top: SizeManagement.cardInsideHorizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DEFAULT),
                    )),
                    Expanded(
                        child: Switch(
                            value: rateplan.isDefault!,
                            activeColor: ColorManagement.greenColor,
                            inactiveTrackColor: ColorManagement.mainBackground,
                            onChanged: (value) async {
                              if (value == false) {
                                return;
                              }
                              String result = '';
                              bool? confirm = await MaterialUtil.showConfirm(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil
                                          .CONFIRM_SET_DEFAULT_RATE_PLAN,
                                      [rateplan.title!]));
                              if (confirm == null || confirm == false) {
                                return;
                              }
                              result = await ratePlanManager
                                  .setDefaultRatePlan(rateplan.title!)
                                  .then((value) => value);
                              MaterialUtil.showResult(context, result);
                            }))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: SizeManagement.cardInsideHorizontalPadding,
                    right: SizeManagement.cardInsideHorizontalPadding,
                    top: SizeManagement.cardInsideHorizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                        child: NeutronTextContent(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_PERCENT),
                    )),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: Checkbox(
                        splashRadius: 0,
                        activeColor: ColorManagement.greenColor,
                        mouseCursor: MouseCursor.defer,
                        value: rateplan.percent,
                        onChanged: (bool? value) {},
                      ),
                    )),
                  ],
                ),
              ),
              if (!ratePlanManager.isRatePlanStandardOrOTA(rateplan.title!))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () async {
                          String? result = await showDialog(
                              context: context,
                              builder: (ctx) => AddRatePlanDialog(
                                    ratePlan: rateplan,
                                  ));
                          if (result != null && result.isNotEmpty) {
                            MaterialUtil.showAlert(result);
                          }
                        },
                        icon: const Icon(Icons.edit)),
                  ],
                )
            ],
          ),
        );
      }
      return Container();
    }).toList();
  }
}
