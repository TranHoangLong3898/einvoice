import 'package:flutter/material.dart';

import '../../util/designmanagement.dart';

class NeutronButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData? icon;
  final void Function()? onPressed1;
  final IconData? icon1;
  final void Function()? onPressed2;
  final IconData? icon2;
  final String? tooltip;
  final String? tooltip1;
  final String? tooltip2;
  final EdgeInsetsGeometry? margin;
  const NeutronButton(
      {Key? key,
      this.onPressed,
      this.icon,
      this.onPressed1,
      this.icon1,
      this.onPressed2,
      this.icon2,
      this.tooltip,
      this.tooltip1,
      this.tooltip2,
      this.margin = const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding,
          right: SizeManagement.cardInsideHorizontalPadding,
          bottom: SizeManagement.rowSpacing)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        width: double.infinity,
        decoration: BoxDecoration(
            color: ColorManagement.greenColor,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 3), blurRadius: 4)
            ]),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (icon != null && onPressed != null)
              IconButton(
                  icon: Icon(icon), onPressed: onPressed, tooltip: tooltip),
            if (icon1 != null && onPressed1 != null)
              IconButton(
                  icon: Icon(icon1), onPressed: onPressed1, tooltip: tooltip1),
            if (icon2 != null && onPressed2 != null)
              IconButton(
                  icon: Icon(icon2), onPressed: onPressed2, tooltip: tooltip2)
          ],
        ));
  }
}
