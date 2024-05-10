import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronTextContent extends StatelessWidget {
  final String message;
  final double? fontSize;
  final String? tooltip;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int maxLines;

  const NeutronTextContent(
      {Key? key,
      required this.message,
      this.fontSize,
      this.tooltip,
      this.color,
      this.textAlign = TextAlign.left,
      this.textOverflow,
      this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Text(message,
            overflow: textOverflow ?? TextOverflow.ellipsis,
            textAlign: textAlign,
            maxLines: maxLines,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: fontSize ?? 14.0,
                color: color ?? ColorManagement.lightColorText)),
      );
    }
    return Text(message,
        textAlign: textAlign,
        maxLines: maxLines,
        style: TextStyle(
            overflow: textOverflow ?? TextOverflow.ellipsis,
            fontWeight: FontWeight.normal,
            fontSize: fontSize ?? 14.0,
            color: color ?? ColorManagement.lightColorText));
  }
}
