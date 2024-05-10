import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrondropdown.dart';
import 'package:ihotel/util/dateutil.dart';
import '../../constants.dart';
import '../../util/designmanagement.dart';
import '../../util/messageulti.dart';
import '../../util/uimultilanguageutil.dart';
import 'neutronbutton.dart';
import 'neutrontexttilte.dart';

// ignore: must_be_immutable
class NeutronShowConfigDialog extends StatefulWidget {
  ///Value of function PDF Map<String,bool> have key to be [ isShowPrice, isShowService, isShowPayment, isShowRemaining, isShowDailyRate]
  final Function(Map<String, bool>)? onPressed;

  ///Value of function PDF Map<String,bool> have key to be [ isShowPrice, isShowService, isShowPayment, isShowRemaining, isShowDailyRate]
  final Function(Map<String, bool>)? onPressed1;
  final bool isGroup;
  final List<String>? listItem;
  final Function(String)? onPressed2;
  void Function(DateTime)? onChangeStartDate;
  DateTime? startDate;
  void Function(DateTime)? onChangeEndDate;
  DateTime? enDate;
  String? value;

  NeutronShowConfigDialog(
      {Key? key,
      this.onPressed,
      this.onPressed1,
      this.isGroup = false,
      this.value,
      this.listItem,
      this.onPressed2,
      this.startDate,
      this.enDate,
      this.onChangeStartDate,
      this.onChangeEndDate})
      : super(key: key);

  @override
  State<NeutronShowConfigDialog> createState() =>
      _NeutronShowConfigDialogState();
}

class _NeutronShowConfigDialogState extends State<NeutronShowConfigDialog> {
  Map<String, bool> showOption = {
    'isShowPrice': true,
    "isShowService": true,
    "isShowPayment": true,
    "isShowRemaining": true,
    "isShowDailyRate": false
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: widget.isGroup
            ? widget.listItem != null
                ? widget.value! ==
                        UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)
                    ? 320
                    : 275
                : 255
            : widget.listItem != null
                ? widget.value! ==
                        UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)
                    ? 320
                    : 265
                : 245,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            NeutronTextTitle(
              fontSize: 20,
              color: ColorManagement.yellowColor,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.MATERIALUTIL_TITLE_CONFIRM),
              isPadding: false,
            ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            Expanded(
              child: InkWell(
                onTap: () {
                  showOption["isShowPrice"] = !showOption["isShowPrice"]!;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: ColorManagement.greenColor,
                      value: showOption["isShowPrice"],
                      onChanged: (value) {
                        showOption["isShowPrice"] = value!;
                        setState(() {});
                      },
                    ),
                    NeutronTextTitle(
                      isRequired: true,
                      messageUppercase: false,
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_SHOW_ROOM_PRICE),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  showOption["isShowService"] = !showOption["isShowService"]!;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: ColorManagement.greenColor,
                      value: showOption["isShowService"],
                      onChanged: (value) {
                        showOption["isShowService"] = value!;
                        setState(() {});
                      },
                    ),
                    NeutronTextTitle(
                      isRequired: true,
                      messageUppercase: false,
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_SHOW_SERVICE),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  showOption["isShowPayment"] = !showOption["isShowPayment"]!;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: ColorManagement.greenColor,
                      value: showOption["isShowPayment"],
                      onChanged: (value) {
                        showOption["isShowPayment"] = value!;
                        setState(() {});
                      },
                    ),
                    NeutronTextTitle(
                      messageUppercase: false,
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_SHOW_PAYMENT),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  showOption["isShowRemaining"] =
                      !showOption["isShowRemaining"]!;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: ColorManagement.greenColor,
                      value: showOption["isShowRemaining"],
                      onChanged: (value) {
                        showOption["isShowRemaining"] = value!;
                        setState(() {});
                      },
                    ),
                    NeutronTextTitle(
                      messageUppercase: false,
                      message: MessageUtil.getMessageByCode(
                          MessageCodeUtil.CONFIRM_SHOW_REMAINING),
                    )
                  ],
                ),
              ),
            ),
            if (!widget.isGroup)
              Expanded(
                child: InkWell(
                  onTap: () {
                    showOption["isShowDailyRate"] =
                        !showOption["isShowDailyRate"]!;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: ColorManagement.greenColor,
                        value: showOption["isShowDailyRate"],
                        onChanged: (value) {
                          showOption["isShowDailyRate"] = value!;
                          setState(() {});
                        },
                      ),
                      NeutronTextTitle(
                        messageUppercase: false,
                        message: MessageUtil.getMessageByCode(
                            widget.listItem != null
                                ? MessageCodeUtil.CONFIRM_SHOW_MONTHLY_RATE
                                : MessageCodeUtil.CONFIRM_SHOW_DAILY_RATE),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            if (widget.listItem != null)
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: NeutronDropDownCustom(
                    backgroundColor: ColorManagement.lightMainBackground,
                    label: UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_MONTHLY),
                    childWidget: NeutronDropDown(
                      isPadding: false,
                      value: widget.value!,
                      onChanged: (String values) async {
                        widget.value = values;
                        widget.onPressed2!.call(values);
                        setState(() {});
                      },
                      items: [
                        UITitleUtil.getTitleByCode(UITitleCode.ALL),
                        ...widget.listItem!
                      ],
                    ),
                  )),
            if (widget.listItem != null &&
                widget.value! == UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: NeutronDatePicker(
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_START_DATE),
                        colorBackground: ColorManagement.lightMainBackground,
                        initialDate: widget.startDate,
                        firstDate: widget.startDate!
                            .subtract(const Duration(days: 365)),
                        lastDate:
                            widget.startDate!.add(const Duration(days: 365)),
                        onChange: (newDate) {
                          setState(() {
                            widget.onChangeStartDate!.call(newDate);
                          });
                          newDate = DateUtil.to0h(newDate);
                          if (DateUtil.equal(newDate, widget.startDate!)) {
                            return;
                          }
                          widget.startDate = newDate;
                          if (widget.enDate!.isBefore(widget.startDate!)) {
                            widget.enDate = DateUtil.to24h(newDate);
                          } else if (widget.enDate!
                                  .difference(widget.startDate!)
                                  .inDays >
                              31) {
                            widget.enDate = DateUtil.to24h(widget.startDate!
                                .add(const Duration(days: 31)));
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: NeutronDatePicker(
                        colorBackground: ColorManagement.lightMainBackground,
                        tooltip: UITitleUtil.getTitleByCode(
                            UITitleCode.TOOLTIP_END_DATE),
                        initialDate: widget.enDate,
                        firstDate: widget.startDate,
                        lastDate:
                            widget.startDate!.add(const Duration(days: 31)),
                        onChange: (newDate) {
                          widget.onChangeEndDate!.call(newDate);
                          setState(() {});
                          newDate = DateUtil.to24h(newDate);
                          if (DateUtil.equal(newDate, widget.enDate!)) return;
                          if (newDate.compareTo(widget.startDate!) < 0) return;
                          if (newDate.difference(widget.startDate!).inDays >
                              61) {
                            return;
                          }
                          widget.enDate = newDate;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            widget.isGroup
                ? Expanded(
                    child: NeutronButton(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      icon: Icons.picture_as_pdf,
                      icon1: Icons.file_present_rounded,
                      tooltip: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_EXPORT_TO_PDF),
                      tooltip1: UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
                      onPressed: () {
                        widget.onPressed!.call(showOption);
                      },
                      onPressed1: () async {
                        widget.onPressed1!.call(showOption);
                      },
                    ),
                  )
                : Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(flex: 3, child: SizedBox()),
                        Expanded(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          ColorManagement.positiveText)),
                              onPressed: () {
                                widget.onPressed!.call(showOption);
                              },
                              child: const Icon(Icons.check)),
                        ),
                        const SizedBox(
                            width: SizeManagement.cardOutsideHorizontalPadding),
                      ],
                    ),
                  ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
          ],
        ),
      ),
    );
  }
}

class NeutronShowConfigDialogExprortExcelAndDpf extends StatefulWidget {
  ///Value of function PDF Map<String,bool> have key to be [ isShowPrice, isShowNotes]
  final Function(Map<String, bool>)? onPressedpDF;

  ///Value of function EXC Map<String,bool> have key to be [ isShowPrice, isShowNotes]
  final Function(Map<String, bool>)? onPressedExcel;
  final bool isNotesInBooking;
  final IconData iconPDF;
  final IconData? iconExcel;
  const NeutronShowConfigDialogExprortExcelAndDpf(
      {Key? key,
      this.onPressedpDF,
      this.onPressedExcel,
      this.isNotesInBooking = false,
      this.iconPDF = Icons.picture_as_pdf,
      this.iconExcel = Icons.file_present_rounded})
      : super(key: key);

  @override
  State<NeutronShowConfigDialogExprortExcelAndDpf> createState() =>
      _NeutronShowConfigDialogExprortExcelAndDpfState();
}

class _NeutronShowConfigDialogExprortExcelAndDpfState
    extends State<NeutronShowConfigDialogExprortExcelAndDpf> {
  Map<String, bool> showOption = {
    'isShowPrice': true,
    'isShowNotes': true,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: widget.isNotesInBooking ? 180 : 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            NeutronTextTitle(
              fontSize: 20,
              color: ColorManagement.yellowColor,
              message: UITitleUtil.getTitleByCode(
                  UITitleCode.MATERIALUTIL_TITLE_CONFIRM),
              isPadding: false,
            ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            InkWell(
              onTap: () {
                showOption["isShowPrice"] = !showOption["isShowPrice"]!;
                setState(() {});
              },
              child: Row(
                children: [
                  Checkbox(
                    activeColor: ColorManagement.greenColor,
                    value: showOption["isShowPrice"],
                    onChanged: (value) {
                      showOption["isShowPrice"] = value!;
                      setState(() {});
                    },
                  ),
                  NeutronTextTitle(
                    messageUppercase: false,
                    message: MessageUtil.getMessageByCode(
                        MessageCodeUtil.CONFIRM_SHOW_PRICE),
                  )
                ],
              ),
            ),
            widget.isNotesInBooking
                ? InkWell(
                    onTap: () {
                      showOption["isShowNotes"] = !showOption["isShowNotes"]!;
                      setState(() {});
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          activeColor: ColorManagement.greenColor,
                          value: showOption["isShowNotes"],
                          onChanged: (value) {
                            showOption["isShowNotes"] = value!;
                            setState(() {});
                          },
                        ),
                        NeutronTextTitle(
                          messageUppercase: false,
                          message: MessageUtil.getMessageByCode(
                              MessageCodeUtil.CONFIRM_SHOW_NOTES),
                        )
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
            NeutronButton(
              margin: const EdgeInsets.all(
                  SizeManagement.cardOutsideHorizontalPadding),
              icon: widget.iconPDF,
              icon1: widget.iconExcel,
              tooltip:
                  UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_TO_PDF),
              tooltip1: UITitleUtil.getTitleByCode(
                  UITitleCode.TOOLTIP_EXPORT_TO_EXCEL),
              onPressed: () {
                widget.onPressedpDF!.call(showOption);
              },
              onPressed1: () async {
                widget.onPressedExcel!.call(showOption);
              },
            ),
            const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
          ],
        ),
      ),
    );
  }
}
