import 'package:flutter/material.dart';

class NeutronIconButton extends StatelessWidget {
  final IconData? icon;
  final void Function()? onPressed;
  final String? tooltip;
  const NeutronIconButton({
    Key? key,
    this.icon,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 18,
        tooltip: tooltip,
        constraints: const BoxConstraints(maxHeight: 30, maxWidth: 35),
        icon: Icon(icon),
        onPressed: onPressed);
  }
}
