import 'package:flutter/material.dart';
import 'package:ihotel/controller/management/dashboardcontroller.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/responsiveutil.dart';

import 'analytic_info_card.dart';

class AnalyticCards extends StatelessWidget {
  const AnalyticCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ResponesiveWidget(
      mobile: AnalyticInfoCardGridView(
        crossAxisCount: size.width < 850 ? 2 : 4,
        childAspectRatio: size.width > 700 ? 2 : 1.3,
      ),
      tablet: const AnalyticInfoCardGridView(),
      desktop: AnalyticInfoCardGridView(
        childAspectRatio: size.width < 1400 ? 1.5 : 2.1,
      ),
    );
  }
}

class AnalyticInfoCardGridView extends StatefulWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  const AnalyticInfoCardGridView(
      {Key? key, this.crossAxisCount = 4, this.childAspectRatio = 1.4})
      : super(key: key);

  @override
  State<AnalyticInfoCardGridView> createState() =>
      _AnalyticInfoCardGridViewState();
}

class _AnalyticInfoCardGridViewState extends State<AnalyticInfoCardGridView> {
  late List<Map<String, dynamic>> analyticDataStage, analyticDataDate;

  @override
  void initState() {
    analyticDataStage = DashboardController.instance!.getDataAnalysisOfStage();
    analyticDataDate = DashboardController.instance!.getDataAnalysisOfDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: analyticDataStage.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
        mainAxisSpacing: SizeManagement.cardOutsideHorizontalPadding,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemBuilder: (context, index) => AnalyticInfoCard(
        infoStage: analyticDataStage[index],
        infoDate: analyticDataDate[index],
      ),
    );
  }
}
