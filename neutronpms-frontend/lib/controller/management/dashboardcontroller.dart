// ignore_for_file: unnecessary_null_comparison

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/dailyallotmentstatic.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/servicemanager.dart';
import 'package:ihotel/ui/component/dashboard/chart/dashboard_chart.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

import '../../handler/firebasehandler.dart';
import '../../modal/dailydata.dart';
import '../../util/dateutil.dart';
import '../../util/uimultilanguageutil.dart';

class DashboardController extends ChangeNotifier {
  static DashboardController? _instance;
  static DashboardController? get instance => _instance;

  DashboardChartController? chartController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  late List<DailyData> totalData;
  late bool isLoading;
  late DateTime startDate, endDate, selectedDate;
  late String selectedType;
  Map<String, Map<String, dynamic>> dataRevenue = {};
  Map<int, String> indexTypeRoom = {};
  Map<String?, dynamic> dataRoomCharge = {};
  Map<String, num> dataDailyAlloment = {};
  Map<String, num> totalRevenueAndAmountRoom = {};
  Set<String> setYear = {};
  String selectYear = "";

  DashboardController._singleton();

  factory DashboardController.createInstance() =>
      _instance ??= DashboardController._singleton();
  final List<String> periodTypes = [
    UITitleCode.THIS_MONTH,
    UITitleCode.TODAY,
    UITitleCode.LAST_7_DAYS,
    UITitleCode.LAST_1_MONTH,
    UITitleCode.THIS_YEAR,
    UITitleCode.CUSTOM,
  ];

  late String selectedPeriod;
  void initialize() async {
    isLoading = true;
    selectedType =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY);
    selectedPeriod = periodTypes.first;
    totalData = [];
    DateTime now = DateTime.now();
    selectedDate = DateUtil.to12h(now);
    startDate = DateTime(now.year, now.month, 1, 12);
    endDate = DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now), 12);
    indexTypeRoom.clear();
    dataRoomCharge.clear();
    dataDailyAlloment.clear();
    selectYear = now.year.toString();
    await loadDailyData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadDailyData() async {
    await getDailyAllotments();
    if (selectedPeriod == UITitleCode.THIS_YEAR) {
      totalData.clear();
      await getDailyDataByYear();
    } else {
      totalData.clear();
      final rawData = await FirebaseHandler().getDailyData(startDate, endDate);
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
            revenue:
                dailyData.containsKey('revenue') ? dailyData['revenue'] : null,
            breakfast: dailyData.containsKey('breakfast')
                ? dailyData['breakfast']
                : null,
            guest: dailyData.containsKey('guest') ? dailyData['guest'] : null,
            service:
                dailyData.containsKey('service') ? dailyData['service'] : null,
            deposit:
                dailyData.containsKey('deposit') ? dailyData['deposit'] : null,
            accounting: dailyData.containsKey('cost_management')
                ? dailyData['cost_management']
                : null,
            actualPayment: dailyData.containsKey('actual_payment')
                ? dailyData['actual_payment']
                : null,
            country:
                dailyData.containsKey('country') ? dailyData['country'] : null,
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
        ...List.generate(endDate.difference(endDateOfRawData).inDays, (index) {
          DateTime nextDay = endDateOfRawData.add(Duration(days: index + 1));
          return DailyData(date: DateUtil.dateToShortString(nextDay));
        })
      ];
    }
  }

  void update() async {
    if (selectedPeriod == UITitleCode.CUSTOM) {
      selectedDate = DateUtil.to12h(startDate);
    }
    isLoading = true;
    notifyListeners();
    await loadDailyData();
    isLoading = false;
    notifyListeners();
  }

  void setPeriodType(String newValue) {
    if (newValue == UITitleUtil.getTitleByCode(selectedPeriod)) return;
    DateTime now = DateTime.now();
    if (newValue == UITitleUtil.getTitleByCode(UITitleCode.TODAY)) {
      startDate = DateUtil.to0h(now);
      endDate = DateUtil.to24h(now);
      selectedDate = DateUtil.to12h(now);
      selectedPeriod = UITitleCode.TODAY;

      update();
    } else if (newValue == UITitleUtil.getTitleByCode(UITitleCode.THIS_MONTH)) {
      startDate = DateTime(now.year, now.month, 1);
      endDate =
          DateTime(now.year, now.month, DateUtil.getLengthOfMonth(now), 23, 59);
      selectedDate = DateUtil.to12h(now);
      selectedPeriod = UITitleCode.THIS_MONTH;

      update();
    } else if (newValue ==
        UITitleUtil.getTitleByCode(UITitleCode.LAST_7_DAYS)) {
      selectedPeriod = UITitleCode.LAST_7_DAYS;
      selectedDate = DateUtil.to12h(now);

      endDate = DateUtil.to24h(now);
      startDate = DateUtil.to0h(endDate.subtract(const Duration(days: 6)));
      update();
    } else if (newValue ==
        UITitleUtil.getTitleByCode(UITitleCode.LAST_1_MONTH)) {
      DateTime dateTimeThisMoth = DateTime(
          (now.month <= 1 ? now.year - 1 : now.year),
          (now.month <= 1 ? 12 : now.month - 1),
          1,
          0);
      startDate = dateTimeThisMoth;
      endDate = DateTime(dateTimeThisMoth.year, dateTimeThisMoth.month,
          DateUtil.getLengthOfMonth(dateTimeThisMoth), 23, 59);
      selectedDate = DateUtil.to12h(startDate);
      selectedPeriod = UITitleCode.LAST_1_MONTH;
      update();
    } else if (newValue == UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
      selectedPeriod = UITitleCode.CUSTOM;
      notifyListeners();
    } else if (newValue == UITitleUtil.getTitleByCode(UITitleCode.THIS_YEAR)) {
      selectedPeriod = UITitleCode.THIS_YEAR;
      update();
    }
  }

  setYearData(String value) {
    if (selectYear == value) return;
    selectYear = value;
    notifyListeners();
    update();
  }

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

  List<BarChartGroupData> getChartDataOfRoomCharge() {
    int index = 0;
    for (var key in RoomTypeManager().getRoomTypeIDsActived()) {
      dataRoomCharge[key] = {};
      dataRoomCharge[key]!["amount"] = 0;
      dataRoomCharge[key]!["price"] = 0;
      dataRoomCharge[key]!["index"] = index;
      index++;
    }
    for (DailyData e in totalData) {
      for (var key in e.getAmountRoomCharge().keys) {
        if (dataRoomCharge.containsKey(key)) {
          dataRoomCharge[key]!["amount"] = dataRoomCharge[key]!["amount"]! +
              e.getAmountRoomCharge()[key]["amount"];
          dataRoomCharge[key]!["price"] = dataRoomCharge[key]!["price"]! +
              e.getAmountRoomCharge()[key]["price"];
        } else {
          dataRoomCharge[key]!["amount"] =
              e.getAmountRoomCharge()[key]["amount"];
          dataRoomCharge[key]!["price"] = e.getAmountRoomCharge()[key]["price"];
        }
      }
    }
    totalRevenueAndAmountRoom["revenue_roomtype"] = 0;
    totalRevenueAndAmountRoom["rooms_used"] = 0;
    totalRevenueAndAmountRoom["rooms_available"] = 0;
    return dataRoomCharge.keys.map((key) {
      indexTypeRoom[dataRoomCharge[key]["index"]] =
          RoomTypeManager().getRoomTypeNameByID(key);
      totalRevenueAndAmountRoom["revenue_roomtype"] =
          totalRevenueAndAmountRoom["revenue_roomtype"]! +
              (dataRoomCharge[key]["price"] ?? 0);
      totalRevenueAndAmountRoom["rooms_used"] =
          totalRevenueAndAmountRoom["rooms_used"]! +
              (dataRoomCharge[key]["amount"] ?? 0);
      totalRevenueAndAmountRoom["rooms_available"] =
          totalRevenueAndAmountRoom["rooms_available"]! +
              (dataDailyAlloment[key] ?? 0);
      return BarChartGroupData(
          barsSpace: 13,
          x: dataRoomCharge[key]["index"],
          barRods: [
            BarChartRodData(
              toY: dataRoomCharge[key]["price"].toDouble(),
              color: Colors.blue,
              width: 10,
            ),
            BarChartRodData(
              toY: dataRoomCharge[key]["amount"].toDouble(),
              color: ColorManagement.greenColor,
              width: 10,
            ),
            BarChartRodData(
              toY: dataDailyAlloment[key]?.toDouble() ?? 0,
              color: ColorManagement.orangeColor,
              width: 10,
            )
          ],
          showingTooltipIndicators: [
            0,
            1,
            2
          ]);
    }).toList();
  }

  double getMaxs() {
    if (dataRoomCharge.isNotEmpty) {
      double dem = 0;
      double dem1 = 0;
      double dem2 = 0;
      for (var key in dataRoomCharge.keys) {
        if (dataRoomCharge[key]["price"] > dem &&
            dataRoomCharge[key]["price"] != 0) {
          dem = dataRoomCharge[key]["price"];
        }
        if (dataRoomCharge[key]["amount"] > dem1 &&
            dataRoomCharge[key]["amount"] != 0) {
          dem1 = dataRoomCharge[key]["amount"];
        }
        if ((dataDailyAlloment[key] ?? 0) > dem2 &&
            (dataDailyAlloment[key] ?? 0) != 0) {
          dem2 = dataDailyAlloment[key]?.toDouble() ?? 0;
        }
      }
      return [dem, dem1, dem2]
          .reduce((value, element) => value > element ? value : element);
    }
    return 10.0;
  }

  getDailyAllotments() async {
    dataDailyAlloment.clear();
    await DailyAllotmentStatic()
        .getDailyAllotmentsByDate(startDate, endDate)
        .then((value) {
      for (var element in value) {
        for (var idRoomType in (element as Map<String, dynamic>).keys) {
          if (idRoomType == "booked" || idRoomType == "non_room") continue;
          if (dataDailyAlloment.containsKey(idRoomType)) {
            dataDailyAlloment[idRoomType] = dataDailyAlloment[idRoomType]! +
                (element[idRoomType]['num'] ?? 0);
          } else {
            dataDailyAlloment[idRoomType] = element[idRoomType]['num'];
          }
        }
      }
    });

    notifyListeners();
  }

  getDailyDataByYear() async {
    setYear.clear();
    List<String> modthYear = [];
    await FirebaseHandler.hotelRef.collection('daily_data').get().then((value) {
      for (var element in value.docs) {
        setYear.add(element.id.substring(0, 4));
      }
    });
    for (var element in setYear) {
      for (var i = 1; i <= 12; i++) {
        modthYear.add("$element${i < 10 ? 0 : ''}$i");
      }
    }
    final rawData =
        await FirebaseHandler().getDailyDataByYear(modthYear, selectYear);

    if (rawData == null || rawData.isEmpty) {
      totalData = [];
    } else {
      totalData = rawData.map((dailyData) {
        print(dailyData["year"]['date']);
        return DailyData(
          date: dailyData["year"]['date'].toString(),
          newBooking: dailyData['new_booking'].isNotEmpty
              ? dailyData['new_booking']
              : null,
          currentBooking: dailyData['current_booking'].isNotEmpty
              ? dailyData['current_booking']
              : null,
          revenue:
              dailyData['revenue'].isNotEmpty ? dailyData['revenue'] : null,
          breakfast:
              dailyData['breakfast'].isNotEmpty ? dailyData['breakfast'] : null,
          guest: dailyData['guest'].isNotEmpty ? dailyData['guest'] : null,
          service:
              dailyData['service'].isNotEmpty ? dailyData['service'] : null,
          deposit:
              dailyData['deposit'].isNotEmpty ? dailyData['deposit'] : null,
          accounting: dailyData['cost_management'].isNotEmpty
              ? dailyData['cost_management']
              : null,
          actualPayment: dailyData['actual_payment'].isNotEmpty
              ? dailyData['actual_payment']
              : null,
          country:
              dailyData['country'].isNotEmpty ? dailyData['country'] : null,
          typeTourists: dailyData['type_tourists'].isNotEmpty
              ? dailyData['type_tourists']
              : null,
        );
      }).toList();
      totalData.sort((a, b) => a.date!.compareTo(b.date!));
    }
    notifyListeners();
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
    /* list result will be formatted:
      result {
        title: "",
        amount: 123,
        // color: Colors.red,
      }
    */
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
    DailyData dailyData = selectedPeriod == UITitleCode.THIS_YEAR
        ? totalData.first
        : totalData.firstWhere(
            (element) => element.dateFull!.isAtSameMomentAs(selectedDate));
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

  void openMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void openEndDrawer() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
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

  void setSelectedDate(DateTime newDate) {
    newDate = DateUtil.to12h(newDate);
    if (DateUtil.equal(newDate, selectedDate)) return;
    selectedDate = newDate;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    newDate = DateUtil.to0h(newDate);
    if (DateUtil.equal(newDate, startDate)) return;
    startDate = newDate;
    if (endDate.isBefore(startDate)) {
      endDate = DateUtil.to24h(newDate);
    } else if (endDate.difference(startDate).inDays > 60) {
      endDate = DateUtil.to24h(startDate.add(const Duration(days: 60)));
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    newDate = DateUtil.to24h(newDate);
    if (DateUtil.equal(newDate, endDate)) return;
    if (newDate.compareTo(startDate) < 0) return;
    if (newDate.difference(startDate).inDays > 60) return;
    endDate = newDate;
    notifyListeners();
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
