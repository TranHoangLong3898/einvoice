import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronFormOpenCell extends StatelessWidget {
  final Widget? form;
  final BuildContext? context;
  final String text;
  final TextAlign? textAlign;

  const NeutronFormOpenCell(
      {Key? key,
      this.form,
      this.context,
      required this.text,
      this.textAlign = TextAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
            backgroundColor: ColorManagement.lightMainBackground, child: form),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: NeutronTextStyle.positiveNumber,
      ),
    );
  }
}
