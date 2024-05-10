import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/progress/profitbydate.dart';
// import 'package:ihotel/ui/component/dashboardmuchhotels/progress/revenuebysources.dart';
// import 'package:ihotel/constants.dart';
// import 'package:ihotel/ui/component/dashboardmuchhotels/chart_extra/dashboardpierevenuebysource.dart';

class RightContentOfMuchHotels extends StatelessWidget {
  const RightContentOfMuchHotels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ProfitByDateOfMuchHotels(),
        SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
        // const RevenueBySourceOfMuchHotels(),
        // const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
        // Expanded(
        //   child: Container(
        //     width: kMobileWidth,
        //     margin: const EdgeInsets.only(
        //         right: SizeManagement.cardOutsideHorizontalPadding),
        //     decoration: BoxDecoration(
        //       color: ColorManagement.dashboardComponent,
        //       borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
        //     ),
        //     child: const DashboardPieChartRevenueBySourceOfMuchHotels(),
        //   ),
        // ),
      ],
    );
  }
}
