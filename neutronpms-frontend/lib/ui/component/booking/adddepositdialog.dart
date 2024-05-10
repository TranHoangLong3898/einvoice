import 'package:flutter/material.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/modal/service/deposit.dart';
import 'package:ihotel/ui/controls/neutrondatepicker.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controller/booking/adddepositcontroller.dart';
import '../../../manager/roommanager.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrondropdown.dart';
import '../../../ui/controls/neutrontextformfield.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../../validator/numbervalidator.dart';
import '../selectionbookingdialog.dart';

class AddDepositDialog extends StatefulWidget {
  final Booking? booking;
  final Deposit? deposit;
  final num? totalPricePayment;

  const AddDepositDialog(
      {Key? key, this.booking, this.deposit, this.totalPricePayment = 0})
      : super(key: key);

  @override
  State<AddDepositDialog> createState() => _AddDepositDialogState();
}

class _AddDepositDialogState extends State<AddDepositDialog> {
  final formKey = GlobalKey<FormState>();
  AddDepositController? controller;
  late NeutronInputNumberController amountController;
  late NeutronInputNumberController actualAmountController;
  late bool isDisable;

  @override
  void initState() {
    controller ??= AddDepositController(
        booking: widget.booking,
        deposit: widget.deposit,
        totalPricePayment: widget.totalPricePayment);
    amountController = NeutronInputNumberController(controller!.teAmount);
    actualAmountController =
        NeutronInputNumberController(controller!.teActualAmount);
    isDisable = widget.booking == null;
    super.initState();
  }

  @override
  void dispose() {
    if (widget.booking != null && controller != null) {
      controller!.teDesc.dispose();
      controller!.teAmount.dispose();
      controller!.teActualAmount.dispose();
      controller!.teNote.dispose();
      controller!.teReferenceNumber.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.lightMainBackground,
        child: ChangeNotifierProvider<AddDepositController>.value(
            value: controller!,
            child: Consumer<AddDepositController>(builder: (_, controller, __) {
              bool isShowChooseBookingButton = !isDisable &&
                  controller.methodID == PaymentMethodManager.transferMethodID;
              double dialogHeight = isShowChooseBookingButton ? 480 : 450;
              if (!isDisable && (controller.isLoading)) {
                return Container(
                  width: kMobileWidth,
                  height: dialogHeight,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                );
              } else {
                return SizedBox(
                  width: kMobileWidth,
                  height: dialogHeight,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: SizeManagement
                                              .cardOutsideHorizontalPadding,
                                          vertical: SizeManagement
                                              .topHeaderTextSpacing),
                                      alignment: Alignment.center,
                                      child: widget.booking != null
                                          ? Text(
                                              widget.booking!.group!
                                                  ? "${UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_GROUP)} ${widget.booking!.name}"
                                                  : "${RoomManager().getNameRoomById(widget.booking!.room!)} - ${widget.booking!.name}",
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            )
                                          : Container()),
                                  //amount
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isRequired: true,
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_AMOUNT_MONEY),
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
                                    child: amountController.buildWidget(
                                      isDouble: true,
                                      isDecor: true,
                                      isNegative: true,
                                      validator: (String? value) =>
                                          NumberValidator.validateNumber(
                                                  amountController
                                                      .getRawString())
                                              ? null
                                              : MessageUtil.getMessageByCode(
                                                  MessageCodeUtil
                                                      .INPUT_POSITIVE_AMOUNT),
                                      readOnly: isDisable,
                                    ),
                                  ),
                                  //desc
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isRequired: true,
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DESCRIPTION_FULL),
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
                                    child: NeutronTextFormField(
                                      isDecor: true,
                                      controller: controller.teDesc,
                                      maxLine: 3,
                                      readOnly: isDisable,
                                    ),
                                  ),
                                  //method
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isRequired: true,
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_METHOD),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        right: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        bottom: SizeManagement
                                            .bottomFormFieldSpacing),
                                    child: !isDisable
                                        ? NeutronDropDownCustom(
                                            childWidget: NeutronDropDown(
                                                isPadding: false,
                                                value: PaymentMethodManager()
                                                    .getPaymentMethodNameById(
                                                        controller.methodID),
                                                onChanged:
                                                    (String newMethodName) {
                                                  controller.setMethodID(
                                                      newMethodName);
                                                },
                                                items: controller.methodNames),
                                          )
                                        : NeutronTextFormField(
                                            isDecor: true,
                                            hint: PaymentMethodManager()
                                                .getPaymentMethodNameById(
                                                    widget.deposit!.method!),
                                            readOnly: isDisable,
                                          ),
                                  ),
                                  //choose booking to transfer
                                  if (isShowChooseBookingButton)
                                    Row(children: [
                                      const SizedBox(
                                          width: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                      Expanded(
                                          child: Tooltip(
                                        message: controller
                                            .getTransferredBookingInfo(),
                                        child: Text(
                                          controller
                                              .getTransferredBookingInfo(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                      const SizedBox(width: 4),
                                      IconButton(
                                          onPressed: () async {
                                            final Booking? selectedBooking =
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        const SelectionBookingDialog());
                                            if (selectedBooking == null) return;
                                            if (mounted &&
                                                selectedBooking.id ==
                                                    controller.idBooking) {
                                              MaterialUtil.showResult(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CAN_NOT_TRANSFER_FOR_YOURSELF));
                                            } else {
                                              controller.setTransferredBooking(
                                                  selectedBooking);
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.drive_file_move_outline)),
                                      const SizedBox(
                                          width: SizeManagement
                                              .cardOutsideHorizontalPadding),
                                    ]),
                                  //actualAmount
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_ACTUAL_AMOUNT),
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
                                    child: actualAmountController.buildWidget(
                                      isDouble: true,
                                      isDecor: true,
                                      isNegative: true,
                                      readOnly: isDisable,
                                    ),
                                  ),
                                  //note
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.HEADER_NOTES),
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
                                    child: NeutronTextFormField(
                                      isDecor: true,
                                      controller: controller.teNote,
                                      maxLine: 3,
                                      readOnly: isDisable,
                                    ),
                                  ),
                                  //teReferenceNumber
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_REFERENCE_NUMBER),
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
                                    child: NeutronTextFormField(
                                      isDecor: true,
                                      controller: controller.teReferenceNumber,
                                      readOnly: isDisable,
                                    ),
                                  ),
                                  //referencDate
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: SizeManagement
                                            .cardOutsideHorizontalPadding,
                                        vertical: SizeManagement.rowSpacing),
                                    child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_REFERENCE_DATE),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 70,
                                    child: NeutronDatePicker(
                                      border: Border.all(
                                          color: ColorManagement.borderCell,
                                          width: 1),
                                      colorBackground:
                                          ColorManagement.mainBackground,
                                      initialDate: controller.referencDate,
                                      firstDate: controller.now
                                          .subtract(const Duration(days: 365)),
                                      lastDate: controller.now
                                          .add(const Duration(days: 365)),
                                      onChange: (picked) {
                                        controller.setReferencDate(picked);
                                      },
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      if (!isDisable)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                              icon: Icons.save,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final result = await controller.addDeposit();
                                  if (!mounted) {
                                    return;
                                  }
                                  if (result == MessageCodeUtil.SUCCESS) {
                                    Navigator.pop(context);
                                  } else {
                                    MaterialUtil.showResult(context,
                                        MessageUtil.getMessageByCode(result));
                                  }
                                }
                              }),
                        ),
                    ],
                  ),
                );
              }
            })));
  }
}
