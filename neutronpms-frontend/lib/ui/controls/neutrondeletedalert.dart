import 'package:flutter/material.dart';

import '../../util/designmanagement.dart';
import '../../util/messageulti.dart';
import 'neutrontexttilte.dart';

class NeutronDeletedAlert extends StatelessWidget {
  const NeutronDeletedAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        height: 100,
        width: 200,
        alignment: Alignment.center,
        color: ColorManagement.mainBackground,
        child: NeutronTextTitle(
          message: MessageUtil.getMessageByCode(
              MessageCodeUtil.TEXTALERT_THIS_HAD_BEEN_DELETE),
          color: ColorManagement.redColor,
        ),
      ),
    );
  }
}
