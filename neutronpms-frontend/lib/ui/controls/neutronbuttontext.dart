import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import '../../util/designmanagement.dart';

class NeutronButtonText extends StatelessWidget {
  final String text;

  const NeutronButtonText({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 45,
        margin: const EdgeInsets.symmetric(
            horizontal: SizeManagement.cardOutsideHorizontalPadding,
            vertical: SizeManagement.cardOutsideVerticalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: ColorManagement.greenColor,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8)),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ));
  }
}

class NeutronTextButton extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;
  final void Function() onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final bool isUpperCase;
  const NeutronTextButton(
      {Key? key,
      required this.message,
      required this.onPressed,
      this.width,
      this.margin = const EdgeInsets.only(
          left: SizeManagement.cardOutsideHorizontalPadding,
          right: SizeManagement.cardInsideHorizontalPadding,
          bottom: SizeManagement.rowSpacing),
      this.color,
      this.height,
      this.isUpperCase = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
            color: color ?? ColorManagement.greenColor,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 3), blurRadius: 4)
            ]),
        height: height ?? SizeManagement.neutronComponentHeight,
        child: Align(
          alignment: Alignment.center,
          child: TextButton(
              onPressed: onPressed,
              child: NeutronTextTitle(
                  message: message, messageUppercase: isUpperCase)),
        ));
  }
}

class NeutronSingleButton extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;
  final String? tooltip;
  final EdgeInsetsGeometry? margin;
  final double? size;

  const NeutronSingleButton(
      {Key? key,
      required this.onPressed,
      required this.icon,
      this.tooltip,
      this.size = SizeManagement.neutronComponentHeight,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin ??
            const EdgeInsets.all(SizeManagement.cardInsideHorizontalPadding),
        height: size ?? SizeManagement.neutronComponentHeight,
        width: size ?? SizeManagement.neutronComponentHeight,
        decoration: BoxDecoration(
            color: ColorManagement.redColor,
            borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 3), blurRadius: 4)
            ]),
        child: IconButton(
            tooltip: tooltip,
            iconSize: 24,
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(maxHeight: 30, maxWidth: 35),
            icon: Icon(icon),
            onPressed: onPressed));
  }
}
