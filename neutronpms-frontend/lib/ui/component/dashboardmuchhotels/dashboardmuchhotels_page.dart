import 'package:flutter/material.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/dashboardmuchhotels_content.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/dashboardmuchhotels_end_drawer.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';

class DashboarMuchHotelsPage extends StatefulWidget {
  const DashboarMuchHotelsPage({Key? key}) : super(key: key);

  @override
  State<DashboarMuchHotelsPage> createState() => _DashboarMuchHotelsPageState();
}

class _DashboarMuchHotelsPageState extends State<DashboarMuchHotelsPage> {
  final DailyDataHotelsController controller =
      DailyDataHotelsController.createInstance();
  @override
  void initState() {
    controller.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManagement.mainBackground,
      endDrawer: const DashboarMuchHotelsEndDrawer(),
      key: controller.scaffoldKey,
      body: SafeArea(
        child: Container(
          color: ColorManagement.mainBackground,
          child: ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<DailyDataHotelsController>(
              builder: (_, controller, child) {
                return controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorManagement.greenColor),
                      )
                    : child!;
              },
              child: DashboarMuchHotelsContent(controller: controller),
            ),
          ),
        ),
      ),
    );
  }
}
