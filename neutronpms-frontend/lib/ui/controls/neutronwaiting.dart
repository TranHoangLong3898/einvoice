import 'package:flutter/material.dart';

import '../../util/designmanagement.dart';

class NeutronWaiting extends StatelessWidget {
  final Color? backgroundColor;
  const NeutronWaiting({Key? key, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
          color: backgroundColor ?? ColorManagement.transparentBackground,
        ),
        alignment: Alignment.center,
        child:
            const CircularProgressIndicator(color: ColorManagement.greenColor),
      ),
    );
  }
}
