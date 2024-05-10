import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/responsiveutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../controller/booking/discountcontroller.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';

class DiscountDialog extends StatefulWidget {
  final Booking? booking;

  const DiscountDialog({Key? key, this.booking}) : super(key: key);

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late DiscountController discountController;
  @override
  void initState() {
    discountController = DiscountController(booking: widget.booking);
    super.initState();
  }

  @override
  void dispose() {
    discountController.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveUtil.isMobile(context);
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: isMobile ? kMobileWidth : kWidth,
        height: 500,
        child: ChangeNotifierProvider.value(
          value: discountController,
          child: Consumer<DiscountController>(
            builder: (_, controller, __) => controller.isLoading
                ? const Align(
                    alignment: Alignment.center,
                    widthFactor: 50,
                    heightFactor: 50,
                    child: CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //header
                      Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_DISCOUNT),
                          )),
                      //title
                      if (!isMobile)
                        Container(
                          margin: const EdgeInsets.only(
                              left:
                                  SizeManagement.cardOutsideHorizontalPadding *
                                      2,
                              right:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: NeutronTextTitle(
                                    isPadding: false,
                                    fontSize: 14,
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TIME_COMPACT)),
                              ),
                              Expanded(
                                  flex: 3,
                                  child: NeutronTextTitle(
                                      fontSize: 14,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DESCRIPTION_FULL))),
                              Expanded(
                                  flex: 3,
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      fontSize: 14,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_MODIFIED_BY))),
                              Expanded(
                                  flex: 2,
                                  child: NeutronTextTitle(
                                      textAlign: TextAlign.end,
                                      fontSize: 14,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_AMOUNT_MONEY))),
                              const SizedBox(width: 80),
                            ],
                          ),
                        ),
                      //list
                      (controller.discountOfBooking == null ||
                              controller
                                  .discountOfBooking!.discountDetail!.isEmpty)
                          ? //no-data
                          Expanded(
                              child: Center(
                              child: NeutronTextContent(
                                message: MessageUtil.getMessageByCode(
                                    MessageCodeUtil.NO_DATA),
                              ),
                            ))
                          : //has data
                          Expanded(
                              child: SingleChildScrollView(
                              child: Column(
                                  children: controller
                                      .discountOfBooking!.discountDetail!.keys
                                      .map((key) => _buildDiscountDetail(
                                          controller, key, isMobile, context))
                                      .toList()),
                            )),

                      //total row
                      if ((controller.discountOfBooking != null &&
                          controller
                              .discountOfBooking!.discountDetail!.isNotEmpty))
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                              bottom: SizeManagement.rowSpacing),
                          child: NeutronTextTitle(
                            fontSize: 16,
                            color: ColorManagement.redColor,
                            message:
                                '-${NumberUtil.numberFormat.format(controller.discountOfBooking?.total ?? 0)}',
                          ),
                        ),
                      if (widget.booking!.status != BookingStatus.checkout)
                        NeutronButton(
                          icon: Icons.add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddDiscountDialog(
                                booking: widget.booking!,
                              ),
                            );
                          },
                        )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountDetail(DiscountController controller, String key,
      bool isMobile, BuildContext context) {
    dynamic discountDetail = controller.discountOfBooking!.discountDetail![key];
    //on mobile
    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
            color: ColorManagement.lightMainBackground,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        margin: const EdgeInsets.symmetric(
            vertical: SizeManagement.cardOutsideVerticalPadding,
            horizontal: SizeManagement.cardOutsideVerticalPadding),
        child: ExpansionTile(
          title: Row(
            children: [
              //modified time
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: NeutronTextContent(
                      message: DateUtil.dateToDayMonthHourMinuteString(
                          (discountDetail['modified_time'] as Timestamp)
                              .toDate()),
                      tooltip: DateUtil.dateToDayMonthHourMinuteString(
                          (discountDetail['modified_time'] as Timestamp)
                              .toDate())),
                ),
              ),
              //amount
              NeutronTextContent(
                color: ColorManagement.redColor,
                textOverflow: TextOverflow.clip,
                message:
                    '-${NumberUtil.numberFormat.format(discountDetail['amount'])}',
              ),
            ],
          ),
          children: [
            Column(
              children: [
                //desc
                Container(
                  margin: const EdgeInsets.fromLTRB(
                      SizeManagement.cardOutsideHorizontalPadding,
                      SizeManagement.cardOutsideHorizontalPadding,
                      SizeManagement.cardOutsideHorizontalPadding,
                      0),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 70,
                          child: NeutronTextContent(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DESCRIPTION_COMPACT),
                          )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: NeutronTextContent(
                            message: discountDetail['desc'],
                            tooltip: discountDetail['desc'],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                //modified by
                Container(
                  margin: const EdgeInsets.fromLTRB(
                      SizeManagement.cardOutsideHorizontalPadding,
                      SizeManagement.cardOutsideHorizontalPadding,
                      SizeManagement.cardOutsideHorizontalPadding,
                      SizeManagement.cardOutsideVerticalPadding),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 70,
                          child: NeutronTextContent(
                            textOverflow: TextOverflow.clip,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_MODIFIED_BY),
                          )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: NeutronTextContent(
                              tooltip: discountDetail['modified_by'],
                              message: discountDetail['modified_by']),
                        ),
                      )
                    ],
                  ),
                ),
                //button
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: IconButton(
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_EDIT),
                          color: ColorManagement.white,
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AddDiscountDialog(
                                booking: widget.booking!,
                                discountDetail: discountDetail,
                                discountId: key,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          tooltip: UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_DELETE),
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool? confirmResult = await MaterialUtil.showConfirm(
                                context,
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil
                                        .CONFIRM_DELETE_DISCOUNT_WITH_AMOUNT,
                                    [discountDetail['amount'].toString()]));
                            if (confirmResult == null || !confirmResult) return;
                            String deleteResult =
                                await controller.deleteDiscountOfBooking(key);
                            if (mounted) {
                              MaterialUtil.showResult(context, deleteResult);
                            }
                          },
                        ),
                      ),
                    ])
              ],
            )
          ],
        ),
      );
    }
    //on web
    return Container(
      height: SizeManagement.cardHeight,
      margin: const EdgeInsets.symmetric(
          vertical: SizeManagement.cardOutsideVerticalPadding,
          horizontal: SizeManagement.cardOutsideHorizontalPadding),
      decoration: BoxDecoration(
          color: ColorManagement.lightMainBackground,
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
      child: Row(
        children: [
          //modified_time
          Container(
            width: 60,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(
                left: SizeManagement.cardInsideHorizontalPadding),
            child: NeutronTextContent(
              textOverflow: TextOverflow.clip,
              message: DateUtil.dateToDayMonthHourMinuteString(
                  (discountDetail['modified_time'] as Timestamp).toDate()),
            ),
          ),
          //desc
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: SizeManagement.dropdownLeftPadding),
                child: NeutronTextContent(
                  tooltip: discountDetail['desc'],
                  message: discountDetail['desc'],
                ),
              )),
          //modified_by
          Expanded(
              flex: 3,
              child: NeutronTextContent(
                  message: discountDetail['modified_by'],
                  tooltip: discountDetail['modified_by'])),
          //amount
          Expanded(
              flex: 2,
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: SizeManagement.dropdownLeftPadding),
                  child: NeutronTextContent(
                    textAlign: TextAlign.right,
                    color: ColorManagement.redColor,
                    message: NumberUtil.numberFormat
                        .format(discountDetail['amount']),
                  ))),
          //edit
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EDIT),
              color: ColorManagement.white,
              icon: const Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AddDiscountDialog(
                    booking: widget.booking!,
                    discountDetail: discountDetail,
                    discountId: key,
                  ),
                );
              },
            ),
          ),
          //remove
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_DELETE),
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool? confirmResult = await MaterialUtil.showConfirm(
                    context,
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.CONFIRM_DELETE_DISCOUNT_WITH_AMOUNT,
                        [discountDetail['amount'].toString()]));
                if (confirmResult == null || !confirmResult) return;
                String deleteResult =
                    await controller.deleteDiscountOfBooking(key);
                if (mounted) {
                  MaterialUtil.showResult(context, deleteResult);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddDiscountDialog extends StatefulWidget {
  final Booking? booking;
  final dynamic discountDetail;
  final String? discountId;

  const AddDiscountDialog(
      {Key? key, this.booking, this.discountDetail, this.discountId})
      : super(key: key);

  @override
  State<AddDiscountDialog> createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  late AddDiscountController discountController;
  late NeutronInputNumberController amountController;
  @override
  void initState() {
    discountController = AddDiscountController(
        booking: widget.booking,
        discountDetail: widget.discountDetail,
        discountId: widget.discountId);
    amountController =
        NeutronInputNumberController(discountController.amountController!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: SingleChildScrollView(
          child: ChangeNotifierProvider.value(
            value: discountController,
            child: Consumer<AddDiscountController>(
              builder: (_, controller, __) => controller.saving
                  ? Container(
                      height: kMobileWidth,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: ColorManagement.greenColor,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                vertical: SizeManagement.topHeaderTextSpacing),
                            child: NeutronTextHeader(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.HEADER_DISCOUNT),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextTitle(
                            isRequired: true,
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding,
                              vertical:
                                  SizeManagement.cardOutsideVerticalPadding),
                          child: amountController.buildWidget(
                              isDouble: true,
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_AMOUNT);
                                }
                                num? amount = num.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.INPUT_POSITIVE_AMOUNT);
                                }
                                return null;
                              },
                              hint: '0'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextTitle(
                            isRequired: true,
                            isPadding: false,
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical:
                                  SizeManagement.cardOutsideVerticalPadding,
                              horizontal:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          child: NeutronTextFormField(
                              isDecor: true,
                              controller: controller.descController),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            final result = await controller.saveDiscount();
                            if (!mounted) {
                              return;
                            }
                            if (result ==
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS)) {
                              MaterialUtil.showSnackBar(context, result);
                              Navigator.pop(context);
                            } else {
                              MaterialUtil.showAlert(context, result);
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
