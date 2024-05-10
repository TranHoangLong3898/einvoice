import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronTextTitle extends StatelessWidget {
  final String message;
  final bool messageUppercase;
  final Color? color;
  final bool isPadding;
  final double? fontSize;
  final bool isRequired;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const NeutronTextTitle(
      {Key? key,
      required this.message,
      this.messageUppercase = true,
      this.color,
      this.isPadding = true,
      this.textAlign,
      this.isRequired = false,
      this.fontSize = 15,
      this.overflow,
      this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: isPadding ? SizeManagement.dropdownLeftPadding : 0),
      child: RichText(
        maxLines: maxLines ?? 1,
        overflow: overflow ?? TextOverflow.clip,
        text: TextSpan(
            text: messageUppercase ? message.toUpperCase() : message,
            style: TextStyle(
              color: color ?? ColorManagement.mainColorText,
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
            ),
            children: <TextSpan>[
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red))
            ]),
        textAlign: textAlign ?? TextAlign.start,
      ),
    );
  }
}
