import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/progress/right_content.dart';

class DashboarMuchHotelsEndDrawer extends StatelessWidget {
  const DashboarMuchHotelsEndDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: RightContentOfMuchHotels(),
      ),
    );
  }
}
