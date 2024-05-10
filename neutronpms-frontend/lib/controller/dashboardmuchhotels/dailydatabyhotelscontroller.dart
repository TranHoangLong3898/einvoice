// ignore_for_file: unnecessary_null_comparison

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/modal/dailydata.dart';
import 'package:ihotel/ui/component/dashboardmuchhotels/chart/dashboardmuchhotels_chart.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

class DailyDataHotelsController extends ChangeNotifier {
  static DailyDataHotelsController? _instance;
  static DailyDataHotelsController? get instance => _instance;

  DashboardChartController? chartController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  DailyDataHotelsController._singleton();
  factory DailyDataHotelsController.createInstance() =>
      _instance ??= DailyDataHotelsController._singleton();

  late String selectedType;
  Map<String, Map<String, dynamic>> dataRevenue = {};
  Map<int, String> indexTypeRoom = {};
  Map<String?, dynamic> dataRoomCharge = {};
  Map<String, num> dataDailyAlloment = {};
  Map<String, num> totalRevenueAndAmountRoom = {};

  late DateTime now, startDate, endDate;
  late String selectYear;
  late String selectMonth;
  bool isLoading = true;
  Map<String, List<DailyData>> totalMapData = {};
  Map<String, dynamic> rawDataExportExcel = {};
  Map<String, Map<String, dynamic>> dataCostDefault = {};
  List<DailyData> totalData = [];
  Map<String, num> totalRoom = {};
  Map<String, String> mapTypeAccounting = {};
  Set<String> dataSetTypeCost = {};
  List<dynamic> listIdHotels = [];
  List<String> listNameHotels = [];
  Set<String> years = {};
  String selectedNameHotel = "";
  String idHotel = "";
  String uid = "";

  void initialize() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    selectedType =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY);
    now = DateTime.now();
    selectYear = now.year.toString();
    selectMonth = now.month.toString();
    startDate = DateUtil.to12h(DateTime(now.year, now.month, 1));
    endDate = DateUtil.to12h(
        DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now)));
    await getData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> getData() async {
    listNameHotels.clear();
    listIdHotels.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      if (value.exists) {
        if (value.data()!.containsKey("hotels")) {
          listIdHotels.addAll((value.data()!["hotels"]));
          for (var element in (value.data()!["hotels_name"])) {
            listNameHotels.add(element);
          }
        }
      }
    });
    idHotel = listIdHotels.first;
    selectedNameHotel = listNameHotels.first;
    for (var id in listIdHotels) {
      totalMapData[id] = [];
    }
    await loadingData();
  }

  Future<void> loadingData() async {
    isLoading = true;
    notifyListeners();
    totalData.clear();
    await FirebaseFirestore.instance
        .collection('hotels')
        .doc(idHotel)
        .get()
        .then((value) async {
      Map<String, dynamic>? data = value.data();
      if ((data?["role"][uid] != null &&
              (data?["role"][uid].contains("owner") ||
                  data?["role"][uid].contains("manager"))) ||
          UserManager.isAdminSystem) {
        final rawData =
            await getDailyDataByIDHotels(startDate, endDate, value.id);
        if (rawData == null || rawData.isEmpty) {
          totalData = [];
        } else {
          totalData = rawData.map((dailyData) {
            return DailyData(
              date: dailyData['date'],
              newBooking: dailyData.containsKey('new_booking')
                  ? dailyData['new_booking']
                  : null,
              currentBooking: dailyData.containsKey('current_booking')
                  ? dailyData['current_booking']
                  : null,
              revenue: dailyData.containsKey('revenue')
                  ? dailyData['revenue']
                  : null,
              breakfast: dailyData.containsKey('breakfast')
                  ? dailyData['breakfast']
                  : null,
              guest: dailyData.containsKey('guest') ? dailyData['guest'] : null,
              service: dailyData.containsKey('service')
                  ? dailyData['service']
                  : null,
              deposit: dailyData.containsKey('deposit')
                  ? dailyData['deposit']
                  : null,
              accounting: dailyData.containsKey('cost_management')
                  ? dailyData['cost_management']
                  : null,
              actualPayment: dailyData.containsKey('actual_payment')
                  ? dailyData['actual_payment']
                  : null,
              country: dailyData.containsKey('country')
                  ? dailyData['country']
                  : null,
              typeTourists: dailyData.containsKey('type_tourists')
                  ? dailyData['type_tourists']
                  : null,
            );
          }).toList();
          totalData.sort((a, b) => a.dateFull!.compareTo(b.dateFull!));
          //add empty DailyDatas which have date missed in cloud (the missing dates between startDate and endDate)
          if (totalData.isNotEmpty) {
            int i = 0;
            while (i < totalData.length - 1) {
              int thisIndex = i;
              int nextIndex = i + 1;
              DateTime dateOfThisElement =
                  totalData.elementAt(thisIndex).dateFull!;
              DateTime dateOfNextElement =
                  totalData.elementAt(nextIndex).dateFull!;
              int differenceLength =
                  dateOfNextElement.difference(dateOfThisElement).inDays;
              if (differenceLength > 1) {
                List<DailyData> missingDates = List.generate(
                    differenceLength - 1,
                    (index) => DailyData(
                        date: DateUtil.dateToShortString(
                            dateOfThisElement.add(Duration(days: index + 1)))));
                totalData.insertAll(thisIndex + 1, missingDates);
                i += differenceLength;
              } else {
                i++;
              }
            }
          }
        }
        DateTime firstDateOfRawData =
            totalData.isEmpty ? endDate : totalData.first.dateFull!;
        DateTime endDateOfRawData = totalData.isEmpty
            ? endDate.subtract(const Duration(days: 1))
            : totalData.last.dateFull!;
        totalData = [
          //add empty dailydata
          ...List.generate(firstDateOfRawData.difference(startDate).inDays,
              (index) {
            DateTime day = startDate.add(Duration(days: index));
            return DailyData(date: DateUtil.dateToShortString(day));
          }),
          ...totalData,
          //add empty dailydata
          ...List.generate(endDate.difference(endDateOfRawData).inDays,
              (index) {
            DateTime nextDay = endDateOfRawData.add(Duration(days: index + 1));
            return DailyData(date: DateUtil.dateToShortString(nextDay));
          })
        ];
      }
    });
    isLoading = false;
    notifyListeners();
  }

  Future<List<dynamic>> getDailyDataByIDHotels(
      DateTime startDate, DateTime endDate, String id) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection('hotels').doc(id);
    await documentReference.collection('daily_data').get().then((value) {
      for (var element in value.docs) {
        years.add((element.id.substring(0, 4)));
      }
    });
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    List<dynamic> result = [];
    if (inMonthId == outMonthId) {
      await documentReference
          .collection('daily_data')
          .doc(inMonthId)
          .get()
          .then((snapshot) {
        final data = snapshot.data()!['data'] as Map<String, dynamic>;
        for (var keyOfData in data.keys) {
          if (num.parse(keyOfData) >= num.parse(inDay) &&
              num.parse(keyOfData) <= num.parse(outDay)) {
            data[keyOfData]['date'] = inMonthId + keyOfData;
            result.add(data[keyOfData]);
          }
        }
      }).onError((error, stackTrace) => null);
    } else {
      int startMonth = int.parse(inMonthId.substring(4, 6));
      int endMonth = int.parse(outMonthId.substring(4, 6));
      String startYear = inMonthId.substring(0, 4);
      String endYear = outMonthId.substring(0, 4);
      List<String> monthIds = [];
      if (startYear == endYear) {
        for (var i = startMonth; i <= endMonth; i++) {
          monthIds.add("$endYear${i >= 10 ? i : "0$i"}");
        }
      } else {
        for (var i = startMonth; i <= 12; i++) {
          monthIds.add("$startYear${i >= 10 ? i : "0$i"}");
        }
        for (var i = 1; i <= endMonth; i++) {
          monthIds.add("$endYear${i >= 10 ? i : "0$i"}");
        }
      }
      print("$inDay --- $monthIds ---- $outDay");
      for (var monthId in monthIds) {
        await documentReference
            .collection('daily_data')
            .doc(monthId)
            .get()
            .then((snapshot) {
          final data = snapshot.data()!['data'] as Map<String, dynamic>;
          for (var keyOfData in data.keys) {
            if (monthIds.indexOf(monthId) == 0) {
              if (num.parse(keyOfData) >= num.parse(inDay)) {
                data[keyOfData]['date'] = inMonthId + keyOfData;
                result.add(data[keyOfData]);
              }
            } else if (monthIds.indexOf(monthId) == (monthIds.length - 1)) {
              if (num.parse(keyOfData) <= num.parse(outDay)) {
                data[keyOfData]['date'] = outMonthId + keyOfData;
                result.add(data[keyOfData]);
              }
            } else {
              data[keyOfData]['date'] = monthId + keyOfData;
              result.add(data[keyOfData]);
            }
          }
        }).onError((error, stackTrace) => null);
      }
    }
    return result;
  }

  void setNameHotel(String value) {
    if (selectedNameHotel == value) return;
    selectedNameHotel = value;
    idHotel = listIdHotels[listNameHotels.indexOf(selectedNameHotel)];
    notifyListeners();
  }

  void setYear(String newDate) {
    if (selectYear == newDate) return;
    selectYear = newDate;
    DateTime dateTime =
        DateTime(int.parse(selectYear), int.parse(selectMonth), 1);
    startDate = DateTime(dateTime.year, dateTime.month, 1);
    endDate = DateTime(dateTime.year, dateTime.month,
        DateUtil.getLengthOfMonth(dateTime), 23, 59);
    notifyListeners();
  }

  void setMonth(String newMonth) {
    if (selectMonth == newMonth) return;
    selectMonth = newMonth;
    DateTime dateTime =
        DateTime(int.parse(selectYear), int.parse(selectMonth), 1);
    startDate = DateTime(dateTime.year, dateTime.month, 1);
    endDate = DateTime(dateTime.year, dateTime.month,
        DateUtil.getLengthOfMonth(dateTime), 23, 59);
    notifyListeners();
  }

  Future<Map<String, Map<String, dynamic>>>
      getAllDailyDataForExporting() async {
    for (var id in listIdHotels) {
      totalRoom[id] = 0;
      totalMapData[id] = [];
    }
    rawDataExportExcel.clear();
    dataSetTypeCost.clear();
    mapTypeAccounting.clear();
    rawDataExportExcel = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-getDailyDataByHotels')
        .call({
      "year_moth":
          "$selectYear${int.parse(selectMonth) < 10 ? "0$selectMonth" : selectMonth}"
    }).then((value) {
      return value.data;
    }).onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    print(rawDataExportExcel);
    if (rawDataExportExcel.isEmpty) {
      return {};
    } else {
      for (var key in rawDataExportExcel.keys) {
        if (!listIdHotels.contains(key)) continue;
        for (var element in (rawDataExportExcel[key] as List<dynamic>)) {
          for (var data in (element as Map<String, dynamic>).values) {
            Map<String, dynamic> dailyData = (data as Map<String, dynamic>);
            totalMapData[key]!.add(DailyData(
              date:
                  "$selectYear${int.parse(selectMonth) < 10 ? "0$selectMonth" : selectMonth}01",
              newBooking: dailyData.containsKey('new_booking')
                  ? dailyData['new_booking']
                  : null,
              currentBooking: dailyData.containsKey('current_booking')
                  ? dailyData['current_booking']
                  : null,
              revenue: dailyData.containsKey('revenue')
                  ? dailyData['revenue']
                  : null,
              breakfast: dailyData.containsKey('breakfast')
                  ? dailyData['breakfast']
                  : null,
              guest: dailyData.containsKey('guest') ? dailyData['guest'] : null,
              service: dailyData.containsKey('service')
                  ? dailyData['service']
                  : null,
              deposit: dailyData.containsKey('deposit')
                  ? dailyData['deposit']
                  : null,
              depositPayment: dailyData.containsKey('deposit_payment')
                  ? dailyData['deposit_payment']
                  : null,
              accounting: dailyData.containsKey('cost_management')
                  ? dailyData['cost_management']
                  : null,
              actualPayment: dailyData.containsKey('actual_payment')
                  ? dailyData['actual_payment']
                  : null,
              country: dailyData.containsKey('country')
                  ? dailyData['country']
                  : null,
              typeTourists: dailyData.containsKey('type_tourists')
                  ? dailyData['type_tourists']
                  : null,
            ));
          }
        }
      }
      for (var key in rawDataExportExcel.keys) {
        if (listIdHotels.contains(key)) continue;
        for (var element in (rawDataExportExcel[key] as List<dynamic>)) {
          if (element['room_types'] != null) {
            Map<String, dynamic> dataRoomType =
                (element['room_types'] as Map<String, dynamic>);
            for (var element in dataRoomType.values) {
              if (element["is_delete"] == false) {
                totalRoom[key.split("~")[1]] =
                    totalRoom[key.split("~")[1]]! + element["num"];
              }
            }
          }
          if (element['accounting_type'] != null) {
            Map<String, dynamic> dataAccountingType =
                (element['accounting_type'] as Map<String, dynamic>);
            for (var key in dataAccountingType.keys) {
              mapTypeAccounting[key] = dataAccountingType[key]['name'];
            }
          }
        }
      }
    }
    dataCostDefault.clear();
    Map<String, Map<String, dynamic>> dataCost = {};
    for (var key in totalMapData.keys) {
      if (totalMapData[key]!.isEmpty) continue;
      for (var data in totalMapData[key]!) {
        if (data.accounting == null) continue;
        for (var keyType in data.accounting!.keys) {
          dataSetTypeCost.add(mapTypeAccounting[keyType]!);
          for (var idSup in data.accounting![keyType].keys) {
            for (var element in (data.accounting![keyType][idSup].values)) {
              if (dataCost.containsKey(key)) {
                if (dataCost[key]!.containsKey(mapTypeAccounting[keyType]!)) {
                  dataCost[key]![mapTypeAccounting[keyType]!] += element;
                } else {
                  dataCost[key]![mapTypeAccounting[keyType]!] = element;
                }
              } else {
                dataCost[key] = {mapTypeAccounting[keyType]!: element};
              }
              if (dataCostDefault.containsKey(key)) {
                if (dataCostDefault[key]!.containsKey(keyType)) {
                  dataCostDefault[key]![keyType] += element;
                } else {
                  dataCostDefault[key]![keyType] = element;
                }
              } else {
                dataCostDefault[key] = {keyType: element};
              }
            }
          }
        }
      }
    }
    return dataCost;
  }

  ///

  List<BarChartGroupData> getChartData(int hoveredIndex, bool isMobile) {
    double barWidth = isMobile ? 8.0 : 16.0;
    int indexCount = 0;
    DateTime now = DateTime.now();
    return totalData.map((e) {
      num measure = 0;
      if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
        measure = e.getRevenue();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
        measure = e.revenueByDate;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
        measure = e.night;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        measure = e.roomCharge;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        measure = e.totalService;
      }
      int currentIndex = indexCount++;
      bool isTouched = currentIndex == hoveredIndex;
      var gradient = isTouched
          ? ColorManagement.hoveredBarsGradient
          : (DateUtil.equal(e.dateFull!, now)
              ? ColorManagement.barsGradientForToday
              : ColorManagement.barsGradient);
      return BarChartGroupData(x: int.tryParse(e.date!)!, barRods: [
        BarChartRodData(
            toY: measure.toDouble(),
            gradient: gradient,
            width: barWidth,
            borderSide: isTouched
                ? const BorderSide(color: Colors.yellow, width: 1)
                : const BorderSide(color: Colors.white, width: 0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))
      ], showingTooltipIndicators: [
        if (isTouched) 0
      ]);
    }).toList();
  }

  List<LineChartBarData> getLineChartData() {
    //Line chart for revenue
    double index = 0;
    return [
      LineChartBarData(
        isCurved: true,
        isStrokeJoinRound: false,
        isStrokeCapRound: false,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: ColorManagement.orangeColor,
        // curveSmoothness: 0.1,
        preventCurveOverShooting: true,
        spots: totalData
            .map((e) => FlSpot(++index, e.getRevenue().toDouble()))
            .toList(),
      )
    ];
  }

  List<PieChartSectionData> getPieChartData(double radius) {
    //Pie chart for services in stage
    double totalValue = serviceComponents.fold(0, (p, e) => p + e['value']);
    return serviceComponents
        .map((e) => PieChartSectionData(
              color: e['color'],
              value: e['value'] / totalValue * 360,
              title: NumberUtil.moneyFormat.format(e['value']),
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Color(0xffffffff),
              ),
              showTitle: true,
              titlePositionPercentageOffset: 0.7,
              badgePositionPercentageOffset: 0,
            ))
        .toList();
  }

  List<PieChartSectionData> getPieChartDataBySource(double radius) {
    double totalValue =
        dataRevenue.keys.fold(0, (p, e) => p + dataRevenue[e]!["revenue"]);
    return dataRevenue.keys
        .map((e) => PieChartSectionData(
              color: dataRevenue[e]!['color'],
              value: dataRevenue[e]!["revenue"] / totalValue * 360,
              title: NumberUtil.moneyFormat.format(dataRevenue[e]!["revenue"]),
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Color(0xffffffff),
              ),
              showTitle: true,
              titlePositionPercentageOffset: 0.7,
              badgePositionPercentageOffset: 0,
            ))
        .toList();
  }

  double getMeasureOfServiceComponent(String type) {
    double result = totalData.fold(0.0, (previousValue, next) {
      num typeTotal = 0;
      if (type == ServiceManager.MINIBAR_CAT) {
        typeTotal = next.minibar;
      } else if (type == ServiceManager.EXTRA_GUEST_CAT) {
        typeTotal = next.extraGuest;
      } else if (type == ServiceManager.LAUNDRY_CAT) {
        typeTotal = next.laundry;
      } else if (type == ServiceManager.BIKE_RENTAL_CAT) {
        typeTotal = next.bikeRental;
      } else if (type == ServiceManager.OTHER_CAT) {
        typeTotal = next.other;
      } else if (type == ServiceManager.EXTRA_HOUR) {
        typeTotal = next.extraHour;
      } else if (type == ServiceManager.INSIDE_RESTAURANT_CAT) {
        typeTotal = next.insideRestaurant;
      } else if (type == ServiceManager.OUTSIDE_RESTAURANT_CAT) {
        typeTotal = next.outsideRestaurant;
      } else if (type == ServiceManager.ELECTRICITY_CAT) {
        typeTotal = next.electricity;
      } else if (type == ServiceManager.WATER_CAT) {
        typeTotal = next.water;
      }
      return previousValue + typeTotal.toDouble();
    });
    return result;
  }

  List<Map<String, dynamic>> getDataAnalysisOfStage() {
    List<Map<String, dynamic>> result = [];
    Map<String, dynamic> occupancy = {
      'title':
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY),
      'amount': 0
    };
    Map<String, dynamic> revenueByDate = {
      'title': MessageUtil.getMessageByCode(
          MessageCodeUtil.STATISTIC_REVENUE_BY_DATE),
      'amount': 0
    };
    Map<String, dynamic> roomCharge = {
      'title':
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE),
      'amount': 0
    };
    Map<String, dynamic> service = {
      'title': MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE),
      'amount': 0
    };
    for (DailyData dailyData in totalData) {
      occupancy['amount'] += dailyData.night;
      revenueByDate['amount'] += dailyData.revenueByDate;
      roomCharge['amount'] += dailyData.roomCharge;
      service['amount'] += dailyData.totalService;
    }
    result.addAll([occupancy, revenueByDate, service, roomCharge]);
    return result;
  }

  Map<String, double> getDataRevuneAndCostOfStage() {
    Map<String, double> revenue = {'revenue': 0, 'cost': 0};
    for (DailyData dailyData in totalData) {
      revenue['revenue'] = (revenue['revenue']! + dailyData.revenueByDate);
      revenue['cost'] = (revenue['cost']! + dailyData.cost);
    }
    return revenue;
  }

  Map<String, double> getDataRevuneBySource() {
    Map<String, double> revenue = {};
    dataRevenue.clear();
    int i = 0;
    for (DailyData dailyData in totalData) {
      if (dailyData.deposit != null) {
        for (var value in dailyData.deposit!.values) {
          for (var element in (value as Map<String, dynamic>).keys) {
            if (revenue.containsKey(element)) {
              revenue[element] = revenue[element]! + value[element];
              dataRevenue[element]!["revenue"] =
                  dataRevenue[element]!["revenue"] + value[element];
            } else {
              revenue[element] = value[element];
              dataRevenue[element] = {};
              dataRevenue[element]!["revenue"] = value[element];
              dataRevenue[element]!["color"] =
                  ColorManagement.colorsPalete.elementAt(i++);
            }
          }
        }
      }
    }
    return revenue;
  }

  List<Map<String, dynamic>> getDataAnalysisOfDate() {
    List<Map<String, dynamic>> result = [];
    Map<String, dynamic> occupancy = {
      'title':
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY),
      'amount': 0
    };
    Map<String, dynamic> revenueByDate = {
      'title': MessageUtil.getMessageByCode(
          MessageCodeUtil.STATISTIC_REVENUE_BY_DATE),
      'amount': 0
    };
    Map<String, dynamic> roomCharge = {
      'title':
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE),
      'amount': 0
    };
    Map<String, dynamic> service = {
      'title': MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE),
      'amount': 0
    };
    DailyData dailyData = totalData.firstWhere((element) =>
        element.dateFull!.isAtSameMomentAs(DateUtil.to12h(startDate)));
    occupancy['amount'] += dailyData.night;
    revenueByDate['amount'] += dailyData.revenueByDate;
    roomCharge['amount'] += dailyData.roomCharge;
    service['amount'] += dailyData.totalService;
    result.addAll([occupancy, revenueByDate, service, roomCharge]);
    return result;
  }

  double getMax() {
    if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      return totalData
          .map((e) => e.getRevenue())
          .reduce((value, element) => max(value, element))
          .toDouble();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      return totalData
          .map((e) => e.revenueByDate)
          .reduce((value, element) => max(value, element))
          .toDouble();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
      return totalData
          .map((e) => e.roomCharge)
          .reduce((value, element) => max(value, element))
          .toDouble();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
      return totalData
          .map((e) => e.totalService)
          .reduce((value, element) => max(value, element))
          .toDouble();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      return totalData
          .map((e) => e.night)
          .reduce((value, element) => max(value, element))
          .toDouble();
    }
    return 100;
  }

  double getMin() {
    if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      return totalData
          .map((e) => e.getRevenue())
          .reduce((value, element) => min(value, element))
          .toDouble();
    }
    return 0;
  }

  void setChartController(DashboardChartController controller) {
    chartController = controller;
  }

  void setType(String newType) {
    if (newType == selectedType) {
      return;
    }
    selectedType = newType;
    chartController!.rebuild();
  }

  DateTime getDateByChartIndex(int index) =>
      totalData.elementAt(index).dateFull!;

  List<Map<String, dynamic>> get serviceComponents => [
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_MINIBAR),
          'color': ColorManagement.deepBlueColor,
          'value': getMeasureOfServiceComponent(ServiceManager.MINIBAR_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST),
          'color': ColorManagement.grayColor,
          'value': getMeasureOfServiceComponent(ServiceManager.EXTRA_GUEST_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY),
          'color': ColorManagement.greenColor,
          'value': getMeasureOfServiceComponent(ServiceManager.LAUNDRY_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL),
          'color': ColorManagement.orangeColor,
          'value': getMeasureOfServiceComponent(ServiceManager.BIKE_RENTAL_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OTHER),
          'color': ColorManagement.darkYellowColor,
          'value': getMeasureOfServiceComponent(ServiceManager.OTHER_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR),
          'color': ColorManagement.redColor,
          'value': getMeasureOfServiceComponent(ServiceManager.EXTRA_HOUR),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_INSIDE_RESTAURANT),
          'color': ColorManagement.blueColor,
          'value': getMeasureOfServiceComponent(
              ServiceManager.INSIDE_RESTAURANT_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OUTSIDE_RESTAURANT),
          'color': Colors.purple,
          'value': getMeasureOfServiceComponent(
              ServiceManager.OUTSIDE_RESTAURANT_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY),
          'color': const Color(0xff05a8aa),
          'value': getMeasureOfServiceComponent(ServiceManager.ELECTRICITY_CAT),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_WATER),
          'color': const Color.fromARGB(255, 170, 5, 90),
          'value': getMeasureOfServiceComponent(ServiceManager.WATER_CAT),
        },
      ];

  double getProgressToday(String type) {
    var now = DateTime.now();
    DailyData? today = totalData
        .firstWhere((element) => DateUtil.equal(element.dateFull!, now));
    DailyData? yesterday = totalData.firstWhere((element) => DateUtil.equal(
        element.dateFull!, now.subtract(const Duration(days: 1))));

    if (today == null || yesterday == null) {
      return 0;
    }

    switch (type) {
      case MessageCodeUtil.STATISTIC_OCCUPANCY:
        return (today.night - yesterday.night) / yesterday.night;
      case MessageCodeUtil.STATISTIC_REVENUE:
        return (today.getRevenue() - yesterday.getRevenue()) /
            yesterday.getRevenue();
      case MessageCodeUtil.STATISTIC_REVENUE_BY_DATE:
        return (today.revenueByDate - yesterday.revenueByDate) /
            yesterday.revenueByDate;
      case MessageCodeUtil.STATISTIC_SERVICE:
        return (today.totalService - yesterday.totalService) /
            yesterday.totalService;
      case MessageCodeUtil.STATISTIC_ROOM_CHARGE:
        return (today.roomCharge - yesterday.roomCharge) / yesterday.roomCharge;
      default:
        return 0;
    }
  }

  Map<String, num>? getBookingAmountToday() {
    var now = DateTime.now();
    DailyData? today = totalData
        .firstWhere((element) => DateUtil.equal(element.dateFull!, now));
    DailyData? yesterday = totalData.firstWhere((element) => DateUtil.equal(
        element.dateFull!, now.subtract(const Duration(days: 1))));

    if (today == null || yesterday == null) {
      return null;
    }

    return {
      'today': today.getNewBooking(),
      'yesterday': yesterday.getNewBooking()
    };
  }
}
