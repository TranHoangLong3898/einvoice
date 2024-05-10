import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/ui/component/dashboard/dashboard_end_drawer.dart';
import 'package:ihotel/ui/page/userdrawer.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';

import 'dashboard_content.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = DashboardController.createInstance();
  @override
  void initState() {
    controller.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManagement.mainBackground,
      drawer: const UserDrawer(),
      endDrawer: const DashboardEndDrawer(),
      key: controller.scaffoldKey,
      body: SafeArea(
        child: Container(
          color: ColorManagement.mainBackground,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<DashboardController>(
              builder: (_, controller, child) {
                return controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor),
                      )
                    : child!;
              },
              child: const DashboardContent(),
            ),
          ),
        ),
      ),
    );
  }
}
