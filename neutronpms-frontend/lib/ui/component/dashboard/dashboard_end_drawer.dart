import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/dashboard/progress/right_content.dart';

class DashboardEndDrawer extends StatelessWidget {
  const DashboardEndDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: RightContent(),
      ),
    );
  }
}
