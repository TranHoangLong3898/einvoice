import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../controller/booking/setextrabedcontroller.dart';
import '../../../modal/booking.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';
import '../../controls/neutrontextformfield.dart';

class SetExtraBedDialog extends StatefulWidget {
  final Booking? booking;

  const SetExtraBedDialog({Key? key, this.booking}) : super(key: key);
  @override
  State<SetExtraBedDialog> createState() => _SetExtraBedDialogState();
}

class _SetExtraBedDialogState extends State<SetExtraBedDialog> {
  final formKey = GlobalKey<FormState>();
  SetExtraBedController? controller;
  late NeutronInputNumberController bedInputController;

  @override
  void initState() {
    controller ??= SetExtraBedController(widget.booking!);
    bedInputController = NeutronInputNumberController(controller!.teBed);
    super.initState();
  }

  @override
  void dispose() {
    controller?.disposeTextEditingControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
          width: kMobileWidth,
          child: Form(
            key: formKey,
            child: ChangeNotifierProvider.value(
              value: controller,
              child: Consumer<SetExtraBedController>(
                builder: (_, controller, __) => controller.updating
                    ? Container(
                        alignment: Alignment.center,
                        constraints:
                            const BoxConstraints(maxHeight: kMobileWidth),
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
                                  vertical:
                                      SizeManagement.topHeaderTextSpacing),
                              child: NeutronTextHeader(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_EXTRA_BED),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(
                                left:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                right:
                                    SizeManagement.cardOutsideHorizontalPadding,
                                top: SizeManagement.rowSpacing),
                            child: bedInputController.buildWidget(
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.HINT_NUMBER_OF_EXTRA_BEDS),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil.CAN_NOT_BE_EMPTY);
                                }
                                num? bed = num.tryParse(
                                    bedInputController.getRawString());
                                if (bed == null || bed < 0 || bed > 9) {
                                  return MessageUtil.getMessageByCode(
                                      MessageCodeUtil
                                          .INPUT_EXTRA_BED_FROM_0_TO_9);
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: SizeManagement.rowSpacing),
                            child: NeutronButton(
                                icon: Icons.save,
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final result =
                                        await controller.updateExtraBed();
                                    if (!mounted) {
                                      return;
                                    }
                                    if (result ==
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil.SUCCESS)) {
                                      Navigator.pop(context);
                                      MaterialUtil.showSnackBar(
                                          context, result);
                                    } else {
                                      MaterialUtil.showAlert(context, result);
                                    }
                                  }
                                }),
                          ),
                        ],
                      ),
              ),
            ),
          )),
    );
  }
}
