import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/util/designmanagement.dart';
import '../../modal/hotelstatistic.dart';
import '../../util/messageulti.dart';

class HotelStatisticController extends ChangeNotifier {
  List<StatisticData> cities = [];

  Map<String, dynamic> totalHotel = {};
  Map<String, dynamic> totalUser = {};
  Map<int, dynamic> chartTitleData = {};
  Map<String, Map<String, dynamic>> dataInYear = {};

  Set<String> monthYears = {};
  Set<String> years = {};

  List<String> months = [];
  String selectYear =
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL);
  String selectMonth =
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL);

  bool isLoading = true;
  int totalTitleUsers = 0;
  int totalTitleHotels = 0;

  HotelStatisticController() {
    isLoading = true;
    getData();
  }

  Future<void> getData() async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('system').doc('statistic');
    docRef.get().then((data) {
      num countUsers = 0;
      num countHotels = 0;
      String currentYear = "";
      (data['data'] as Map<String, dynamic>).forEach((monthyear, value) {
        years.add(monthyear.substring(0, 4));
        selectYear = monthyear.substring(0, 4);
        if (currentYear != selectYear) {
          currentYear = selectYear;
          countHotels = 0;
          countUsers = 0;
        }
        if (value["users"] != null) {
          if (value['users']['total'] != 0) {
            monthYears.add(monthyear);
          }
          countUsers += value["users"]["total"];
          totalUser[monthyear] = value['users']['total'];
        }
        if (value["hotels"] != null) {
          if (value['hotels']['total'] != 0) {
            monthYears.add(monthyear);
          }
          countHotels += value["hotels"]["total"];
          totalHotel[monthyear] = value['hotels']['total'];
          (value['hotels'] as Map).forEach((city, amount) {
            if (city == 'total') {
              return;
            }
            cities.add(StatisticData(
              name: city,
              amount: amount,
              monthyear: monthyear,
            ));
          });
        } else {
          if (value['users']['total'] != 0) {
            cities.add(StatisticData(
              name: 'Null',
              amount: 0,
              monthyear: monthyear,
            ));
          }
        }
        dataInYear[monthyear.substring(0, 4)] = {
          'Users': countUsers,
          'Hotels': countHotels
        };
      });
      isLoading = false;
      filterMonthByYear();
      notifyListeners();
    });
  }

  setMonth(String month) {
    if (selectMonth == month) return;
    selectMonth = month;
    notifyListeners();
  }

  setYear(String year) {
    if (selectYear == year) return;
    selectYear = year;
    filterMonthByYear();
    notifyListeners();
  }

  void filterMonthByYear() {
    months.clear();
    months = [MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)];
    months.addAll(monthYears.where((element) {
      if (element ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return true;
      }
      return element.substring(0, 4) == selectYear;
    }).map((e) {
      if (e == MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return e;
      }
      return e.substring(4, 6);
    }));
    selectMonth = months.first;
  }

  List<BarChartGroupData> getChartData() {
    int i = 0;
    List<StatisticData> chartData = [];
    if (selectMonth ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      dataInYear.entries.map((year) {
        if (year.key == selectYear) {
          year.value.entries.map((e) {
            chartData.add(StatisticData(
                amount: e.value, name: e.key, monthyear: year.key));
          }).toList();
        }
      }).toList();
    } else {
      cities
          .where((element) => element.monthyear!.substring(0, 4) == selectYear)
          .where((element) => element.monthyear!.substring(4, 6) == selectMonth)
          .map((e) {
        totalTitleHotels = totalHotel[e.monthyear] ?? 0;
        totalTitleUsers = totalUser[e.monthyear] ?? 0;
        if (totalHotel[e.monthyear] == null) {
          totalTitleHotels = 0;
        }
        chartData.add(StatisticData(
            amount: e.amount, name: e.name, monthyear: e.monthyear));
      }).toList();
    }
    return chartData.map((e) {
      double measure = e.amount!.toDouble();
      chartTitleData[i] = e.name;
      return BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
              toY: measure,
              gradient: ColorManagement.barsGradient,
              width: 30,
              borderSide: const BorderSide(color: Colors.white, width: 0),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)))
        ],
        showingTooltipIndicators: [if (measure > 0) 0],
      );
    }).toList();
  }

  Widget getBottomTitles(double index, TitleMeta meta) {
    String? text;
    chartTitleData.entries.map((e) {
      if (index == e.key) {
        text = e.value;
      }
    }).toList();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(
        text ?? "",
        style: const TextStyle(
          color: ColorManagement.lightColorText,
          fontSize: 13,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  Map<String, String>? getTitle() {
    if (selectMonth !=
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return {
        'hotels':
            '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TOTAL_HOTELS)}: $totalTitleHotels',
        'users':
            '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TOTAL_USERS)}: $totalTitleUsers'
      };
    }
    return null;
  }
}
