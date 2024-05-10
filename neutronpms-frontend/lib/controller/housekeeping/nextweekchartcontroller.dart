import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';

import '../../handler/firebasehandler.dart';
import '../../manager/roommanager.dart';
import '../../modal/dailydata.dart';

class NextWeekChartController extends ChangeNotifier {
  late List<DailyData> lstData;

  NextWeekChartController() {
    final startDate = Timestamp.now().toDate();
    final endDate = startDate.add(const Duration(days: 7));
    lstData = List.generate(
      8,
      (index) => DailyData(
        date: DateUtil.dateToShortString(startDate.add(Duration(days: index))),
      ),
    );
    loadData(startDate, endDate);
  }

  Future<void> loadData(DateTime startDate, DateTime endDate) async {
    final rawData = await FirebaseHandler().getDailyData(startDate, endDate);
    lstData = rawData
        .map((dailyData) => DailyData(
              date: dailyData['date'],
              currentBooking: dailyData.containsKey('current_booking')
                  ? dailyData['current_booking']
                  : null,
            ))
        .toList();
    lstData.sort(
        (a, b) => int.tryParse(a.date!)!.compareTo(int.tryParse(b.date!)!));
    notifyListeners();
  }

  List<BarChartGroupData> getChartData() {
    return lstData.map((data) {
      return BarChartGroupData(
        x: int.tryParse(data.date!)!,
        barRods: [
          BarChartRodData(
            toY: data.night.toDouble(),
            gradient: ColorManagement.barsGradient,
            width: 16,
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          )
        ],
        showingTooltipIndicators: [if (data.night > 0) 0],
      );
    }).toList();
  }

  double getMax() => RoomManager().getRoomIDs().length.toDouble();
}
