import 'package:flutter/material.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../manager/roomextramanager.dart';
import '../../../modal/booking.dart';
import '../../../modal/service/extrahour.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class ExtraHourController extends ChangeNotifier {
  TextEditingController teEarlyHours = TextEditingController();
  TextEditingController teEarlyPrice = TextEditingController();
  TextEditingController teLateHours = TextEditingController();
  TextEditingController teLatePrice = TextEditingController();

  bool saving = false;

  final Booking booking;
  ExtraHourController(this.booking) {
    teEarlyPrice.text = booking.extraHour!.earlyPrice.toString();
    teLatePrice.text = booking.extraHour!.latePrice.toString();
    teEarlyHours.text = booking.extraHour!.earlyHours.toString();
    teLateHours.text = booking.extraHour!.lateHours.toString();
  }

  void changeEarlyHour() {
    final earlyHours = num.tryParse(teEarlyHours.text.replaceAll(',', '')) ?? 0;
    teEarlyPrice.text = NumberUtil.numberFormat.format(
        RoomExtraManager().getEarlyCheckInPercentByHours(earlyHours) *
            booking.price!.last);
  }

  void changeLateHour() {
    final lateHours = num.tryParse(teLateHours.text.replaceAll(',', '')) ?? 0;
    teLatePrice.text = NumberUtil.numberFormat.format(
        RoomExtraManager().getLateCheckOutPercentByHours(lateHours) *
            booking.price!.last);
  }

  Future<String> saveExtraHours() async {
    int? earlyHours = int.tryParse(teEarlyHours.text.replaceAll(',', ''));
    int? lateHours = int.tryParse(teLateHours.text.replaceAll(',', ''));
    final earlyPrice = num.tryParse(teEarlyPrice.text.replaceAll(',', ''));
    final latePrice = num.tryParse(teLatePrice.text.replaceAll(',', ''));
    if (earlyHours == null ||
        lateHours == null ||
        earlyPrice == null ||
        latePrice == null ||
        earlyHours < 0 ||
        lateHours < 0 ||
        earlyPrice < 0 ||
        latePrice < 0) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.HOUR_AND_PRICE_MUST_BE_POSITIVE);
    }
    if (earlyHours == booking.extraHour!.earlyHours &&
        lateHours == booking.extraHour!.earlyHours &&
        earlyPrice == booking.extraHour!.earlyPrice &&
        latePrice == booking.extraHour!.latePrice) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STILL_NOT_CHANGE_VALUE);
    }

    ExtraHour extraHours = ExtraHour(
        latePrice: latePrice,
        lateHours: lateHours,
        earlyPrice: earlyPrice,
        earlyHours: earlyHours);

    if (saving) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.IN_PROGRESS);
    }
    saving = true;
    notifyListeners();
    final result = await booking
        .updateExtraHours(extraHours)
        .then((value) => value)
        .onError((error, stackTrace) => error.toString());
    saving = false;
    notifyListeners();
    return MessageUtil.getMessageByCode(result);
  }
}

class ExtraHourForm extends StatefulWidget {
  final Booking? booking;
  final bool? isDisable;

  const ExtraHourForm({Key? key, this.booking, this.isDisable = false})
      : super(key: key);
  @override
  State<ExtraHourForm> createState() => _ExtraHourFormState();
}

class _ExtraHourFormState extends State<ExtraHourForm> {
  final double teHourWidth = 65;
  final double tePriceWidth = 100;
  late ExtraHourController extraHourController;
  late NeutronInputNumberController teEarlyHourController,
      teEarlyPriceController,
      teLateHourController,
      teLatePriceController;
  late bool isDisable;
  @override
  void initState() {
    extraHourController = ExtraHourController(widget.booking!);
    isDisable =
        widget.isDisable ?? widget.booking!.status == BookingStatus.checkout;
    teEarlyHourController =
        NeutronInputNumberController(extraHourController.teEarlyHours);
    teEarlyPriceController =
        NeutronInputNumberController(extraHourController.teEarlyPrice);
    teLateHourController =
        NeutronInputNumberController(extraHourController.teLateHours);
    teLatePriceController =
        NeutronInputNumberController(extraHourController.teLatePrice);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManagement.lightMainBackground,
      width: kMobileWidth,
      child: ChangeNotifierProvider.value(
        value: extraHourController,
        child: Consumer<ExtraHourController>(
          builder: (_, controller, __) => controller.saving
              ? Container(
                  constraints: const BoxConstraints(maxHeight: kMobileWidth),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: ColorManagement.greenColor,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(
                          vertical: SizeManagement.topHeaderTextSpacing),
                      child: NeutronTextHeader(
                        message: UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE),
                      ),
                    ),
                    DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 0,
                      horizontalMargin:
                          SizeManagement.cardInsideHorizontalPadding,
                      columns: <DataColumn>[
                        DataColumn(
                          label: NeutronTextTitle(
                              isPadding: false,
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_ITEM)),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Center(
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_HOUR)))),
                        ),
                        DataColumn(
                          label: Expanded(
                              child: Center(
                                  child: NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE)))),
                        ),
                      ],
                      rows: [
                        DataRow(
                          cells: <DataCell>[
                            DataCell(ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: kMobileWidth -
                                      teHourWidth -
                                      tePriceWidth -
                                      SizeManagement
                                              .cardInsideHorizontalPadding *
                                          2,
                                  maxWidth: kMobileWidth -
                                      teHourWidth -
                                      tePriceWidth -
                                      SizeManagement
                                              .cardInsideHorizontalPadding *
                                          2),
                              child: NeutronTextContent(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_EARLY_CHECKIN),
                              ),
                            )),
                            DataCell(ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: teHourWidth, maxWidth: teHourWidth),
                              child: teEarlyHourController.buildWidget(
                                readOnly: isDisable,
                                textAlign: TextAlign.center,
                                isDecor: false,
                                onChanged: (String newValue) {
                                  controller.changeEarlyHour();
                                },
                              ),
                            )),
                            DataCell(ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: tePriceWidth,
                                  maxWidth: tePriceWidth),
                              child: teEarlyPriceController.buildWidget(
                                readOnly: isDisable,
                                textAlign: TextAlign.center,
                                isDecor: false,
                              ),
                            )),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: kMobileWidth -
                                        teHourWidth -
                                        tePriceWidth -
                                        SizeManagement
                                                .cardInsideHorizontalPadding *
                                            2,
                                    maxWidth: kMobileWidth -
                                        teHourWidth -
                                        tePriceWidth -
                                        SizeManagement
                                                .cardInsideHorizontalPadding *
                                            2),
                                child: NeutronTextContent(
                                    message: UITitleUtil.getTitleByCode(
                                        UITitleCode
                                            .TABLEHEADER_LATE_CHECKOUT)))),
                            DataCell(ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: teHourWidth, maxWidth: teHourWidth),
                              child: teLateHourController.buildWidget(
                                readOnly: isDisable,
                                textAlign: TextAlign.center,
                                isDecor: false,
                                onChanged: (String newValue) {
                                  controller.changeLateHour();
                                },
                              ),
                            )),
                            DataCell(ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: tePriceWidth,
                                  maxWidth: tePriceWidth),
                              child: teLatePriceController.buildWidget(
                                readOnly: isDisable,
                                textAlign: TextAlign.center,
                                isDecor: false,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: SizeManagement.rowSpacing),
                    if (!isDisable)
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          final result = await controller.saveExtraHours();
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
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
