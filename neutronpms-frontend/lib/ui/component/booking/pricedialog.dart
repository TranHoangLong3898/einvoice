import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/pricecontroller.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import '../../../constants.dart';
import '../../../util/materialutil.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../../validator/stringvalidator.dart';

class PriceDialog extends StatefulWidget {
  final List<DateTime>? staysday;
  final List<num>? priceBooking;
  final bool isCheckGroup;
  final bool isReadonly;

  const PriceDialog(
      {Key? key,
      this.staysday,
      this.priceBooking,
      this.isCheckGroup = false,
      this.isReadonly = false})
      : super(key: key);

  @override
  State<PriceDialog> createState() => _PriceDialogState();
}

class _PriceDialogState extends State<PriceDialog> {
  late PriceController controllerPrice;

  @override
  void initState() {
    super.initState();
    controllerPrice =
        PriceController(widget.staysday!, null, widget.priceBooking!);
  }

  @override
  void dispose() {
    controllerPrice.disposeNeutronInput();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    double dialogWidth =
        kMobileWidth - SizeManagement.cardInsideHorizontalPadding * 2;
    double iconWidth = 40;
    double columnWidth = (dialogWidth - iconWidth) / 2;
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 0,
                      horizontalMargin:
                          SizeManagement.cardInsideHorizontalPadding,
                      columns: [
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.only(
                                right:
                                    SizeManagement.cardInsideHorizontalPadding),
                            width: columnWidth,
                            child: NeutronTextTitle(
                                isPadding: false,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STAYS_DAY)),
                          ),
                        ),
                        DataColumn(
                          label: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE)),
                        ),
                        DataColumn(label: SizedBox(width: iconWidth)),
                      ],
                      rows: [
                        for (var i = 0; i < widget.staysday!.length; i++)
                          DataRow(cells: [
                            DataCell(Container(
                              width: columnWidth,
                              padding: const EdgeInsets.only(
                                  right: SizeManagement
                                      .cardInsideHorizontalPadding),
                              child: NeutronTextContent(
                                  message: DateUtil.dateToStringDDMMYYY(
                                      widget.staysday![i])),
                            )),
                            DataCell(SizedBox(
                              width: columnWidth,
                              child: controllerPrice.moneyController[i]
                                  .buildWidget(
                                readOnly: widget.isReadonly,
                                isDouble: true,
                                textColor: ColorManagement.greenColor,
                                isDecor: false,
                                validator: (value) =>
                                    StringValidator.validatePrice(value!),
                              ),
                            )),
                            DataCell(SizedBox(
                                width: iconWidth,
                                child: InkWell(
                                  onTap: () {
                                    for (var element
                                        in controllerPrice.moneyController) {
                                      element.controller.text = controllerPrice
                                          .moneyController[i].controller.text;
                                    }
                                  },
                                  child: const Icon(Icons.copy_outlined),
                                ))),
                          ]),
                      ],
                    ),
                  ),
                ),
                if (!widget.isCheckGroup && !widget.isReadonly)
                  NeutronButton(
                    icon: Icons.save,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final List<num> result = controllerPrice.getPriceArr();
                        if (result.isEmpty) {
                          MaterialUtil.showAlert(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INPUT_PRICE));
                        } else {
                          Navigator.pop(context, result);
                        }
                      }
                    },
                  )
              ],
            ),
          )),
    );
  }
}

class PriceByMonthDialog extends StatefulWidget {
  final List<String>? staysdayMonth;
  final List<DateTime>? staysday;
  final List<num>? priceBooking;
  final bool isCheckGroup;
  final bool isReadonly;

  const PriceByMonthDialog(
      {Key? key,
      this.staysdayMonth,
      this.priceBooking,
      this.isCheckGroup = false,
      this.isReadonly = false,
      this.staysday})
      : super(key: key);

  @override
  State<PriceByMonthDialog> createState() => _PriceByMonthDialogState();
}

class _PriceByMonthDialogState extends State<PriceByMonthDialog> {
  late PriceController controllerPrice;

  @override
  void initState() {
    super.initState();
    controllerPrice = PriceController(
        widget.staysday, widget.staysdayMonth!, widget.priceBooking!);
  }

  @override
  void dispose() {
    controllerPrice.disposeNeutronInput();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: kMobileWidth,
          height: kHeight,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical:
                                  SizeManagement.cardOutsideVerticalPadding,
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_STAYS_DAY)),
                              ),
                              Expanded(
                                flex: 2,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE)),
                              ),
                              const Expanded(child: SizedBox(width: 70)),
                            ],
                          ),
                        ),
                        for (var i = 0; i < widget.staysdayMonth!.length; i++)
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeManagement.borderRadius8),
                                  color: ColorManagement.lightMainBackground),
                              margin: const EdgeInsets.symmetric(
                                  vertical:
                                      SizeManagement.cardOutsideVerticalPadding,
                                  horizontal: SizeManagement
                                      .cardOutsideHorizontalPadding),
                              child: ExpansionTile(
                                collapsedIconColor: (widget.staysdayMonth!.last
                                            .contains(
                                                widget.staysdayMonth![i]) &&
                                        widget.staysday!.isNotEmpty)
                                    ? ColorManagement.greenColor
                                    : ColorManagement.textBlack,
                                tilePadding: const EdgeInsets.only(left: 8),
                                title: Row(children: [
                                  SizedBox(
                                    width: 100,
                                    child: NeutronTextContent(
                                        fontSize: 12,
                                        maxLines: 2,
                                        message:
                                            "${widget.staysdayMonth![i].split("-")[0]}-00:00\n${widget.staysdayMonth![i].split("-")[1]}-23:59"),
                                  ),
                                  Expanded(
                                    child: controllerPrice.moneyController[i]
                                        .buildWidget(
                                      readOnly: widget.isReadonly,
                                      isDouble: true,
                                      textColor: ColorManagement.greenColor,
                                      isDecor: false,
                                      validator: (value) =>
                                          StringValidator.validatePrice(value!),
                                      onChanged: (value) {
                                        if (widget.staysdayMonth!.last.contains(
                                                widget.staysdayMonth![i]) &&
                                            widget.staysday!.isNotEmpty) {
                                          int start =
                                              widget.staysdayMonth!.length;
                                          int end =
                                              (widget.staysdayMonth!.length +
                                                  widget.staysday!.length);
                                          DateTime startDate =
                                              widget.staysday![0];
                                          DateTime endDate = widget.staysday![
                                              widget.staysday!.length - 1];
                                          controllerPrice
                                              .setPriceMediumAllByDay(
                                                  start,
                                                  end,
                                                  value,
                                                  startDate,
                                                  endDate);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      width: 30,
                                      child: InkWell(
                                        onTap: () {
                                          controllerPrice.setPriceAllByMonth(
                                              widget.staysdayMonth!.length,
                                              controllerPrice.moneyController[i]
                                                  .controller.text);
                                          if (widget.staysday!.isNotEmpty) {
                                            int start =
                                                widget.staysdayMonth!.length;
                                            int end =
                                                (widget.staysdayMonth!.length +
                                                    widget.staysday!.length);
                                            DateTime startDate =
                                                widget.staysday![0];
                                            DateTime endDate = widget.staysday![
                                                widget.staysday!.length - 1];
                                            controllerPrice
                                                .setPriceMediumAllByDay(
                                                    start,
                                                    end,
                                                    controllerPrice
                                                        .moneyController[i]
                                                        .controller
                                                        .text
                                                        .replaceAll(',', ''),
                                                    startDate,
                                                    endDate);
                                          }
                                        },
                                        child: const Icon(
                                          Icons.copy_outlined,
                                          size: 18,
                                        ),
                                      )),
                                ]),
                                children: [
                                  if (widget.staysdayMonth!.last
                                          .contains(widget.staysdayMonth![i]) &&
                                      widget.staysday!.isNotEmpty)
                                    for (var i = widget.staysdayMonth!.length;
                                        i <
                                            (widget.staysdayMonth!.length +
                                                widget.staysday!.length);
                                        i++)
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                SizeManagement.borderRadius8),
                                            color: ColorManagement
                                                .lightMainBackground),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: SizeManagement
                                                .cardOutsideHorizontalPadding),
                                        child: Row(children: [
                                          SizedBox(
                                            width: 100,
                                            child: NeutronTextContent(
                                                fontSize: 12,
                                                maxLines: 2,
                                                message: DateUtil
                                                    .dateToStringDDMMYYY(
                                                        widget.staysday![i -
                                                            widget
                                                                .staysdayMonth!
                                                                .length])),
                                          ),
                                          Expanded(
                                            child: controllerPrice
                                                .moneyController[i]
                                                .buildWidget(
                                              readOnly: widget.isReadonly,
                                              isDouble: true,
                                              textColor:
                                                  ColorManagement.greenColor,
                                              isDecor: false,
                                              validator: (value) =>
                                                  StringValidator.validatePrice(
                                                      value!),
                                            ),
                                          ),
                                          SizedBox(
                                              width: 30,
                                              child: InkWell(
                                                onTap: () {
                                                  controllerPrice.setPriceAll(
                                                      widget.staysdayMonth!
                                                          .length,
                                                      (widget.staysdayMonth!
                                                              .length +
                                                          widget.staysday!
                                                              .length),
                                                      controllerPrice
                                                          .moneyController[i]
                                                          .controller
                                                          .text);
                                                },
                                                child: const Icon(
                                                  Icons.copy_outlined,
                                                  size: 18,
                                                ),
                                              )),
                                        ]),
                                      )
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
                if (!widget.isCheckGroup && !widget.isReadonly)
                  NeutronButton(
                    icon: Icons.save,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final List<num> result = controllerPrice.getPriceArr();
                        if (result.isEmpty) {
                          MaterialUtil.showAlert(
                              context,
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.INPUT_PRICE));
                        } else {
                          Navigator.pop(context, result);
                        }
                      }
                    },
                  )
              ],
            ),
          )),
    );
  }
}
