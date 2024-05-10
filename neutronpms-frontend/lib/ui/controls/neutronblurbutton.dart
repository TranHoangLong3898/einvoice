import 'package:flutter/material.dart';

import '../../util/designmanagement.dart';

class NeutronBlurButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final String? tooltip;
  final double? margin;
  final Color? color;

  const NeutronBlurButton(
      {Key? key,
      this.onPressed,
      this.icon,
      this.tooltip = '',
      this.margin = 10,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
          onTap: onPressed,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color ?? ColorManagement.redColor,
                borderRadius: BorderRadius.circular(8)),
            margin: EdgeInsets.symmetric(horizontal: margin!, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(icon),
          )),
    );
  }
}
