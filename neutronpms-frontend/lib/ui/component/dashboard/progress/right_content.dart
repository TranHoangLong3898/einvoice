import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/ui/component/dashboard/chart_extra/dashboardpierevenuebysource.dart';
import 'package:ihotel/ui/component/dashboard/progress/profitbydate.dart';
import 'package:ihotel/ui/component/dashboard/progress/revenuebysources.dart';
// import 'package:ihotel/ui/component/dashboard/progress/new_booking_today.dart';
// import 'package:ihotel/ui/component/dashboard/progress/progress_today.dart';
import 'package:ihotel/util/designmanagement.dart';

class RightContent extends StatelessWidget {
  const RightContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfitByDate(),
        const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
        const RevenueBySource(),
        const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
        // const NewBookingToday(),
        // const SizedBox(height: SizeManagement.cardOutsideHorizontalPadding),
        Expanded(
          child: Container(
            width: kMobileWidth,
            margin: const EdgeInsets.only(
                right: SizeManagement.cardOutsideHorizontalPadding),
            decoration: BoxDecoration(
              color: ColorManagement.dashboardComponent,
              borderRadius: BorderRadius.circular(SizeManagement.borderRadius8),
            ),
            // child: const DashboardActivity(),
            child: const DashboardPieChartRevenueBySource(),
          ),
        ),
      ],
    );
  }
}
