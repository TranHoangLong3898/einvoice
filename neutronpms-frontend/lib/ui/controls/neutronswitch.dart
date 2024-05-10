import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';

class NeutronSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChange;
  const NeutronSwitch({this.onChange, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.4,
      child: Switch(
        splashRadius: 20,
        value: value,
        onChanged: onChange,
        activeColor: ColorManagement.white,
        activeThumbImage: const AssetImage('assets/img/check.png'),
        inactiveThumbImage: const AssetImage('assets/img/close.png'),
        activeTrackColor: ColorManagement.greenColor,

        inactiveTrackColor: ColorManagement.greyColor,
        // inactiveThumbColor: ColorManagement.greyPastel,
      ),
    );
  }
}
