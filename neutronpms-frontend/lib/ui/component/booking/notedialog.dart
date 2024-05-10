import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/notecontroller.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../modal/booking.dart';
import '../../../ui/controls/neutronbutton.dart';
import '../../../ui/controls/neutrontextformfield.dart';
import '../../../util/designmanagement.dart';
import '../../../util/materialutil.dart';

class NoteDialog extends StatelessWidget {
  final Booking? booking;

  const NoteDialog({Key? key, this.booking}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: ChangeNotifierProvider.value(
          value: NoteController(booking: booking),
          child: Consumer<NoteController>(
            builder: (_, controller, __) => controller.saving
                ? Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxHeight: kMobileWidth),
                    child: const CircularProgressIndicator(
                      color: ColorManagement.greenColor,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_NOTES),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManagement.cardOutsideHorizontalPadding,
                            right: SizeManagement.cardOutsideHorizontalPadding,
                            top: SizeManagement.rowSpacing),
                        child: NeutronTextFormField(
                          paddingVertical: 16,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.HINT_NOTES),
                          isDecor: true,
                          maxLine: 3,
                          controller: controller.notesController,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: SizeManagement.rowSpacing),
                        child: NeutronButton(
                          icon: Icons.save,
                          onPressed: () async {
                            final result = await controller.saveNotes();
                            if (result ==
                                MessageUtil.getMessageByCode(
                                    MessageCodeUtil.SUCCESS)) {
                              // ignore: use_build_context_synchronously
                              MaterialUtil.showSnackBar(context, result);
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            } else {
                              // ignore: use_build_context_synchronously
                              MaterialUtil.showAlert(context, result);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
