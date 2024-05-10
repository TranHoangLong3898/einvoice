import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';

/// Used in ``WarehouseNoteManagement`` (import, export,...)
///
/// Display when user swaps between screens too fast and throw exception
class SwapTooFast extends StatelessWidget {
  const SwapTooFast({Key? key, this.action}) : super(key: key);

  /// Execute to re-fetch data. This depends on which screen user at
  final Function? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NeutronTextContent(
            message: MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_YOU_SWAP_SCREEN_TOO_FAST)),
        const SizedBox(height: SizeManagement.rowSpacing),
        OutlinedButton(
          onPressed: () {
            action;
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
            shadowColor: MaterialStateProperty.all(Colors.black),
            backgroundColor:
                MaterialStateProperty.all(ColorManagement.orangeColor),
            overlayColor: MaterialStateProperty.all(
                ColorManagement.transparentBackground),
          ),
          child: NeutronTextContent(
              textAlign: TextAlign.center,
              message: MessageUtil.getMessageByCode(
                  MessageCodeUtil.TEXTALERT_TRY_AGAIN)),
        ),
      ],
    );
  }
}
