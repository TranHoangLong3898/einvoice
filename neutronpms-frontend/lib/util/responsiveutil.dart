import 'package:flutter/material.dart';

class ResponsiveUtil {
  ResponsiveUtil._();

  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width < 1000) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;
}

class ResponesiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponesiveWidget({Key? key, this.mobile, this.tablet, this.desktop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.width >= 1100) {
      return desktop!;
    } else if (size.width >= 850 && tablet != null) {
      return tablet!;
    } else {
      return mobile!;
    }
  }
}
