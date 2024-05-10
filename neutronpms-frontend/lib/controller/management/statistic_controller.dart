// ignore_for_file: unnecessary_null_comparison

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/enum.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../handler/firebasehandler.dart';
import '../../../modal/dailydata.dart';
import '../../../util/dateutil.dart';
import '../../../util/messageulti.dart';
import '../../manager/usermanager.dart';
import '../../modal/booking.dart';
import '../../modal/status.dart';

class StatisticController extends ChangeNotifier {
  List<DailyData> totalData = [], displayData = [];
  List<Booking> bookings = [];
  late bool isLoading;
  ChartType chartType = ChartType.bar;

  DateTime selectedDate = Timestamp.now().toDate();
  late String selectedType,
      selectedSubType1,
      selectedSubType2,
      selectedSubType3,
      selectedSubType4;

  DateTime? startDate, endDate, oldStartDate, oldEndDate;
  late int lengthDays;

  //index to filter listData
  late int startIndex, endIndex;

  final List<String> types = [
    MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY),
    if (UserManager.canSeeStatisticForHousekeeping()) ...[
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE_BY_DATE),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NEW_BOOKING),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS),
    ],
    MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST),
    if (UserManager.canSeeStatisticForHousekeeping()) ...[
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_COUNTRY),
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TYPE_TOURISTS)
    ],
  ];
  List<String> subTypes1 = [], subTypes2 = [], subTypes3 = [], subTypes4 = [];

  StatisticController() {
    selectedType =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY);
    subTypes1
        .addAll([MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)]);
    subTypes2 = [
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
      ...RoomTypeManager().getFullRoomTypeNames()
    ];
    subTypes3 = [
      MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
      ...SourceManager().getSourceNames()
    ];
    selectedSubType1 = subTypes1.first;
    selectedSubType2 = subTypes2.first;
    selectedSubType3 = subTypes3.first;
    isLoading = true;
    startDate = DateTime(selectedDate.year, selectedDate.month, 1, 12);
    // endDate = startDate.add(Duration(days: 1));
    endDate = DateTime(selectedDate.year, selectedDate.month,
        DateUtil.getLengthOfMonth(selectedDate), 12);
    lengthDays = endDate!.difference(startDate!).inDays + 1;
    initialize();
  }

  void initialize() async {
    await loadData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadData() async {
    if (oldEndDate == null ||
        oldStartDate == null ||
        startDate!.isBefore(oldStartDate!) ||
        endDate!.isAfter(oldEndDate!)) {
      final rawData =
          await FirebaseHandler().getDailyData(startDate!, endDate!);

      if (rawData == null || rawData.isEmpty) {
        totalData.clear();
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
            dinner:
                dailyData.containsKey('dinner') ? dailyData['dinner'] : null,
            lunch: dailyData.containsKey('lunch') ? dailyData['lunch'] : null,
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
        int i = 0;
        while (i < totalData.length - 1) {
          int thisIndex = i;
          int nextIndex = i + 1;
          DateTime dateOfThisElement = totalData.elementAt(thisIndex).dateFull!;
          DateTime dateOfNextElement = totalData.elementAt(nextIndex).dateFull!;
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

      oldStartDate = startDate;
      oldEndDate = endDate;
      DateTime firstDateOfRawData =
          totalData.isEmpty ? endDate! : totalData.first.dateFull!;
      DateTime endDateOfRawData = totalData.isEmpty
          ? endDate!.subtract(const Duration(days: 1))
          : totalData.last.dateFull!;
      totalData = [
        //add empty dailydata
        ...List.generate(firstDateOfRawData.difference(startDate!).inDays,
            (index) {
          DateTime day = startDate!.add(Duration(days: index));
          return DailyData(date: DateUtil.dateToShortString(day));
        }),
        ...totalData,
        //add empty dailydata
        ...List.generate(endDate!.difference(endDateOfRawData).inDays, (index) {
          DateTime nextDay = endDateOfRawData.add(Duration(days: index + 1));
          return DailyData(date: DateUtil.dateToShortString(nextDay));
        })
      ];
    }
    startIndex = totalData.indexWhere(
        (element) => element.dateFull!.isAtSameMomentAs(startDate!));
    endIndex = totalData
        .indexWhere((element) => element.dateFull!.isAtSameMomentAs(endDate!));
    displayData = totalData.sublist(startIndex, endIndex + 1);
  }

  void update() async {
    isLoading = true;
    notifyListeners();
    await loadData();
    if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NEW_BOOKING)) {
      loadBasicBookings();
    }
    isLoading = false;
    notifyListeners();
  }

  void setStartDate(DateTime newDate) {
    newDate = DateUtil.to12h(newDate);
    if (DateUtil.equal(newDate, startDate!)) return;
    startDate = newDate;
    if (endDate!.isBefore(startDate!)) {
      endDate = startDate;
    }
    notifyListeners();
  }

  void setEndDate(DateTime newDate) {
    newDate = DateUtil.to12h(newDate);
    if (DateUtil.equal(newDate, endDate!)) return;
    if (newDate.compareTo(startDate!) < 0) return;
    if (newDate.difference(startDate!).inDays > 31) return;

    endDate = newDate;
    notifyListeners();
  }

  void swapChartType() {
    chartType = chartType == ChartType.bar ? ChartType.pie : ChartType.bar;
    notifyListeners();
  }

  void setType(String type) {
    if (type == selectedType) return;
    selectedType = type;
    subTypes1.clear();
    subTypes2.clear();
    subTypes3.clear();
    subTypes4.clear();
    chartType = ChartType.bar;
    if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS)) {
      subTypes1.addAll([
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_BREAKFAST),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LUNCH),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DINNER)
      ]);
      subTypes2.addAll([
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)
      ]);
      selectedSubType1 = subTypes1.first;
      selectedSubType2 = subTypes2.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
      subTypes1.addAll([
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)
      ]);
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE) ||
        selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LIQUIDATION),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)
      ];
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_ROOM_CHARGE) ||
        selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_NEW_BOOKING)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PAY_AT_HOTEL),
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_PREPAID)
      ];
      subTypes2 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...RoomTypeManager().getFullRoomTypeNames()
      ];
      subTypes3 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...SourceManager().getSourceNames()
      ];
      selectedSubType1 = subTypes1.first;
      selectedSubType2 = subTypes2.first;
      selectedSubType3 = subTypes3.first;
      loadBasicBookings();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      subTypes1.addAll(
          [MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)]);
      subTypes2 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...RoomTypeManager().getFullRoomTypeNames()
      ];
      subTypes3 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...SourceManager().getSourceNames()
      ];
      selectedSubType1 = subTypes1.first;
      selectedSubType2 = subTypes2.first;
      selectedSubType3 = subTypes3.first;
      loadBasicBookings();
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        MessageUtil.getMessageByCode(MessageCodeUtil.SERVICE_CATEGORY_MINIBAR),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_INSIDE_RESTAURANT),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_OUTSIDE_RESTAURANT),
        MessageUtil.getMessageByCode(MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL),
        MessageUtil.getMessageByCode(MessageCodeUtil.SERVICE_CATEGORY_OTHER),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY),
        MessageUtil.getMessageByCode(MessageCodeUtil.SERVICE_CATEGORY_WATER)
      ];
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...PaymentMethodManager().getPaymentMethodName()
      ];
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      subTypes1 = [MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)];
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...AccountingTypeManager.listNames
      ];
      subTypes2 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...SupplierManager().getSupplierNames()
      ];
      subTypes3 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        'open',
        'partial',
        'done'
      ];
      selectedSubType1 = subTypes1.first;
      selectedSubType2 = subTypes2.first;
      selectedSubType3 = subTypes3.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...AccountingTypeManager.listNames
      ];
      subTypes2 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...SupplierManager().getSupplierNames()
      ];
      subTypes3 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        ...PaymentMethodManager().getPaymentMethodName()
      ];
      subTypes4 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
        'open',
        'failed',
        'done'
      ];
      selectedSubType1 = subTypes1.first;
      selectedSubType2 = subTypes2.first;
      selectedSubType3 = subTypes3.first;
      selectedSubType4 = subTypes4.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_COUNTRY)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
      ];
      selectedSubType1 = subTypes1.first;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TYPE_TOURISTS)) {
      subTypes1 = [
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL),
      ];
      selectedSubType1 = subTypes1.first;
    }
    notifyListeners();
  }

  void setSubType1(String subType1) {
    if (subType1 == selectedSubType1) return;
    selectedSubType1 = subType1;
    chartType = ChartType.bar;
    notifyListeners();
  }

  void setSubType2(String subType2) {
    if (subType2 == selectedSubType2) return;
    selectedSubType2 = subType2;
    chartType = ChartType.bar;
    notifyListeners();
  }

  void setSubType3(String subType3) {
    if (subType3 == selectedSubType3) return;
    selectedSubType3 = subType3;
    chartType = ChartType.bar;
    notifyListeners();
  }

  List<PieChartSectionData> getPieCharDatas(int? hoveredIndex,
      {BuildContext? context}) {
    // if (selectedType ==
    //         MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE) &&
    //     selectedSubType1 ==
    //         MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL) &&
    //     chartType == ChartType.pie) {
    double screenWidth = MediaQuery.of(context!).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double normalRadius = 0;
    if (screenWidth > screenHeight) {
      normalRadius = screenHeight / 2 - 100;
    } else {
      normalRadius = screenWidth / 2 - 20;
    }
    double totalValue = serviceComponents.fold(0, (p, e) => p + e['value']);
    return serviceComponents.asMap().entries.map((e) {
      final radius = normalRadius;

      return PieChartSectionData(
        color: e.value['color'],
        value: e.value['value'] / totalValue * 360,
        title: NumberUtil.moneyFormat.format(e.value['value']),
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: Color(0xffffffff)),
        showTitle: true,
        titlePositionPercentageOffset: 0.7,
        badgePositionPercentageOffset: 0,
      );
    }).toList();
    // }
  }

  List<BarChartGroupData> getChartData(int hoveredIndex,
      {BuildContext? context}) {
    if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double roomCharge = e.getRevenueRoomCharge().toDouble();
        double service = e.getRevenueService().toDouble();
        double liquidation = e.getRevenueLiquidation().toDouble();
        double discount = e.getRevenueDiscount().toDouble();
        double total = roomCharge + service + liquidation - discount;
        bool isHovered = currentIndex == hoveredIndex;

        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
              width: 16,
              toY: total,
              gradient: isHovered
                  ? ColorManagement.hoveredBarsGradient
                  : ColorManagement.barsGradient,
              backDrawRodData: BackgroundBarChartRodData(show: false),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              rodStackItems: [
                BarChartRodStackItem(-discount, 0, Colors.transparent),
                BarChartRodStackItem(0, roomCharge, Colors.transparent),
                BarChartRodStackItem(
                    roomCharge, roomCharge + service, Colors.transparent),
                BarChartRodStackItem(roomCharge + service,
                    roomCharge + service + liquidation, Colors.transparent),
              ],
            ),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_REVENUE_BY_DATE) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double roomCharge = e.roomCharge.toDouble();
        double service = e.totalService.toDouble();
        double liquidation = e.getRevenueLiquidation().toDouble();
        double discount = e.discount.toDouble();
        double total = roomCharge + service + liquidation - discount;
        bool isHovered = currentIndex == hoveredIndex;

        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
              width: 16,
              toY: total,
              gradient: isHovered
                  ? ColorManagement.hoveredBarsGradient
                  : ColorManagement.barsGradient,
              backDrawRodData: BackgroundBarChartRodData(show: false),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              rodStackItems: [
                BarChartRodStackItem(-discount, 0, Colors.transparent),
                BarChartRodStackItem(0, roomCharge, Colors.transparent),
                BarChartRodStackItem(
                    roomCharge, roomCharge + service, Colors.transparent),
                BarChartRodStackItem(roomCharge + service,
                    roomCharge + service + liquidation, Colors.transparent),
              ],
            ),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double adult = e.getGuestAdult().toDouble();
        double child = e.getGuestChild().toDouble();
        double total = adult + child;
        bool isHovered = currentIndex == hoveredIndex;
        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
                width: 16,
                toY: total,
                backDrawRodData: BackgroundBarChartRodData(show: false),
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    child,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticGreenColor,
                    BorderSide.none,
                  ),
                  BarChartRodStackItem(
                    child,
                    total,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticOrangeColor,
                    BorderSide.none,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6))),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_BREAKFAST) &&
        selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double adult = e.getBreakfastAdult().toDouble();
        double child = e.getBreakfastChild().toDouble();
        double total = adult + child;
        bool isHovered = currentIndex == hoveredIndex;
        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
                width: 16,
                toY: total,
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    child,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticGreenColor,
                    BorderSide.none,
                  ),
                  BarChartRodStackItem(
                    child,
                    total,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticOrangeColor,
                    BorderSide.none,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6))),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LUNCH) &&
        selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double adult = e.getLunchAdult().toDouble();
        double child = e.getLunchChild().toDouble();
        double total = adult + child;
        bool isHovered = currentIndex == hoveredIndex;
        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
                width: 16,
                toY: total,
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    child,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticGreenColor,
                    BorderSide.none,
                  ),
                  BarChartRodStackItem(
                    child,
                    total,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticOrangeColor,
                    BorderSide.none,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6))),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DINNER) &&
        selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double adult = e.getDinnerAdult().toDouble();
        double child = e.getDinnerChild().toDouble();
        double total = adult + child;
        bool isHovered = currentIndex == hoveredIndex;
        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
                width: 16,
                toY: total,
                rodStackItems: [
                  BarChartRodStackItem(
                    0,
                    child,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticGreenColor,
                    BorderSide.none,
                  ),
                  BarChartRodStackItem(
                    child,
                    total,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticOrangeColor,
                    BorderSide.none,
                  ),
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6))),
          ],
        );
      }).toList();
    } else if (selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_TYPE_TOURISTS) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return displayData.map((e) {
        int currentIndex = displayData.indexOf(e);
        double domestic = e.domesticGuest;
        double foreign = e.foreignGuest;
        double unknown = e.unknownGuest;
        double total = domestic + foreign + unknown;
        bool isHovered = currentIndex == hoveredIndex;

        return BarChartGroupData(
          x: int.parse(e.date!),
          showingTooltipIndicators: [if (total > 0) 0],
          barRods: [
            BarChartRodData(
              width: 16,
              toY: total,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
              rodStackItems: [
                BarChartRodStackItem(
                    0,
                    unknown,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticOrangeColor,
                    BorderSide.none),
                BarChartRodStackItem(
                    unknown,
                    unknown + foreign,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticGreenColor,
                    BorderSide.none),
                BarChartRodStackItem(
                    unknown + foreign,
                    total,
                    isHovered
                        ? Colors.yellow
                        : ColorManagement.statisticDeepBlueColor,
                    BorderSide.none),
              ],
            ),
          ],
        );
      }).toList();
    }

    return displayData.map((e) {
      double measure = getMeasure(e).toDouble();
      int currentIndex = displayData.indexOf(e);
      bool isTouched = currentIndex == hoveredIndex;
      return BarChartGroupData(
        x: int.parse(e.date!),
        barRods: [
          BarChartRodData(
              toY: measure,
              gradient: isTouched
                  ? ColorManagement.hoveredBarsGradient
                  : ColorManagement.barsGradient,
              width: 16,
              borderSide: isTouched
                  ? const BorderSide(color: Colors.yellow, width: 1)
                  : const BorderSide(color: Colors.white, width: 0),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)))
        ],
        showingTooltipIndicators: [if (measure > 0) 0],
      );
    }).toList();
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: ColorManagement.lightColorText,
        fontSize: 13,
        overflow: TextOverflow.clip);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(meta.formattedValue, style: style),
    );
  }

  num getMeasure(DailyData data) {
    if (selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_ROOM_CHARGE) ||
        selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      return data.getRoomChargeOrNight(
          methodType: selectedSubType1,
          roomTypeName: selectedSubType2,
          sourceName: selectedSubType3,
          roomCharge: selectedType ==
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.STATISTIC_ROOM_CHARGE));
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NEW_BOOKING)) {
      return data.getNewBooking(
          methodType: selectedSubType1,
          roomTypeName: selectedSubType2,
          sourceName: selectedSubType3);
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      return data.night;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return data.getRevenue();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        return data.getRevenueRoomCharge();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        return data.getRevenueService();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LIQUIDATION)) {
        return data.getRevenueLiquidation();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)) {
        return data.getRevenueDiscount();
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return data.revenueByDate;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        return data.roomCharge;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        return data.totalService;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LIQUIDATION)) {
        return data.getRevenueLiquidation();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)) {
        return data.discount;
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_BREAKFAST)) {
        if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
          return data.getBreakfast();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
          return data.getBreakfastAdult();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
          return data.getBreakfastChild();
        }
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LUNCH)) {
        if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
          return data.getLunch();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
          return data.getLunchAdult();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
          return data.getLunchChild();
        }
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DINNER)) {
        if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
          return data.getDinder();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
          return data.getDinnerAdult();
        } else if (selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
          return data.getDinnerChild();
        }
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return data.getGuest();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
        return data.getGuestAdult();
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
        return data.getGuestChild();
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return data.totalService;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_MINIBAR)) {
        return data.minibar;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST)) {
        return data.extraGuest;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR)) {
        return data.extraHour;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY)) {
        return data.laundry;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL)) {
        return data.bikeRental;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OTHER)) {
        return data.other;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OUTSIDE_RESTAURANT)) {
        return data.outsideRestaurant;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_INSIDE_RESTAURANT)) {
        return data.insideRestaurant;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY)) {
        return data.electricity;
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_WATER)) {
        return data.water;
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return data.totalDeposit;
      } else {
        return data.getDepositByMethod(selectedSubType1);
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)) {
      String? type, supplierId, status;
      if (selectedSubType1 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        type = AccountingTypeManager.getIdByName(selectedSubType1)!;
      }
      if (selectedSubType2 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        supplierId = SupplierManager().getSupplierIDByName(selectedSubType2)!;
      }
      if (selectedSubType3 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        status = selectedSubType3;
      }
      return data.getCostManagement(
          type: type, status: status, supplier: supplierId);
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)) {
      String? type, supplierId, status, method;
      if (selectedSubType1 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        type = AccountingTypeManager.getIdByName(selectedSubType1)!;
      }
      if (selectedSubType2 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        supplierId = SupplierManager().getSupplierIDByName(selectedSubType2)!;
      }
      if (selectedSubType3 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        method =
            PaymentMethodManager().getPaymentMethodIdByName(selectedSubType3)!;
      }
      if (selectedSubType4 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        status = selectedSubType4;
      }
      return data.getActualPlayment(
          type: type, status: status, supplier: supplierId, method: method);
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_COUNTRY)) {
      return data.countryTotal;
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TYPE_TOURISTS)) {
      return data.typeTouristsTotal;
    }
    return 0;
  }

  double getMax() {
    try {
      if (selectedType ==
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.STATISTIC_ROOM_CHARGE) ||
          selectedType ==
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.STATISTIC_OCCUPANCY)) {
        var result = totalData
            .map((dailyData) => dailyData.getRoomChargeOrNight(
                methodType: selectedSubType1,
                roomTypeName: selectedSubType2,
                sourceName: selectedSubType3,
                roomCharge: selectedType ==
                    MessageUtil.getMessageByCode(
                        MessageCodeUtil.STATISTIC_ROOM_CHARGE)))
            .reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NEW_BOOKING)) {
        var result = totalData
            .map((dailyData) => dailyData.getNewBooking(
                methodType: selectedSubType1,
                roomTypeName: selectedSubType2,
                sourceName: selectedSubType3))
            .reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
        var result = totalData
            .map((dailyData) =>
                dailyData.getRevenueRoomCharge() +
                dailyData.getRevenueService())
            .reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
        var result = totalData
            .map((dailyData) => dailyData.roomCharge + dailyData.totalService)
            .reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS)) {
        num result = 0;
        if (selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_BREAKFAST)) {
          result = displayData
              .map((dailyData) => dailyData.getBreakfast())
              .reduce(max);
        } else if (selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LUNCH)) {
          result =
              displayData.map((dailyData) => dailyData.getLunch()).reduce(max);
        } else if (selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DINNER)) {
          result =
              displayData.map((dailyData) => dailyData.getDinder()).reduce(max);
        }
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
        var result =
            displayData.map((dailyData) => dailyData.getGuest()).reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        var result =
            displayData.map((dailyData) => dailyData.totalService).reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)) {
        var result =
            displayData.map((dailyData) => dailyData.totalDeposit).reduce(max);
        if (result == 0) result = 1000;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
        var result =
            displayData.map((dailyData) => dailyData.night).reduce(max);
        if (result == 0) result = 5;
        return result.toDouble();
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)) {
        var result = totalData
            .map((dailyData) => dailyData.getCostManagement(
                type: selectedSubType1 ==
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.STATISTIC_ALL)
                    ? null
                    : AccountingTypeManager.getIdByName(selectedSubType1),
                supplier: selectedSubType2 ==
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.STATISTIC_ALL)
                    ? null
                    : SupplierManager().getSupplierIDByName(selectedSubType2),
                status: selectedSubType3 ==
                        MessageUtil.getMessageByCode(
                            MessageCodeUtil.STATISTIC_ALL)
                    ? null
                    : selectedSubType3))
            .reduce(max);
        if (result == 0) result = 1000;
        return result;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)) {
        var result = totalData
            .map((dailyData) => dailyData.getActualPlayment(
                  type: selectedSubType1 ==
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.STATISTIC_ALL)
                      ? null
                      : AccountingTypeManager.getIdByName(selectedSubType1),
                  supplier: selectedSubType2 ==
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.STATISTIC_ALL)
                      ? null
                      : SupplierManager().getSupplierIDByName(selectedSubType2),
                  method: selectedSubType3 ==
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.STATISTIC_ALL)
                      ? null
                      : PaymentMethodManager()
                          .getPaymentMethodIdByName(selectedSubType3),
                  status: selectedSubType4 ==
                          MessageUtil.getMessageByCode(
                              MessageCodeUtil.STATISTIC_ALL)
                      ? null
                      : selectedSubType4,
                ))
            .reduce(max);
        if (result == 0) result = 1000;
        return result;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_COUNTRY)) {
        var result =
            totalData.map((dailyData) => dailyData.countryTotal).reduce(max);
        if (result == 0) result = 1000;
        return result;
      } else if (selectedType ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STATISTIC_TYPE_TOURISTS)) {
        var result = totalData.map((dailyData) {
          return dailyData.typeTouristsTotal;
        }).reduce(max);
        if (result == 0) result = 1000;
        return result;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  double getMin() {
    return 0;
  }

  bool isShowDetailToolTip(
      int hoveredIndex, int groupIndex, BarChartRodData rod) {
    if (selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL) &&
        rod.rodStackItems.length > 1 &&
        hoveredIndex == groupIndex &&
        (selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_REVENUE) ||
            selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_REVENUE_BY_DATE) ||
            selectedType ==
                MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST) ||
            selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_TYPE_TOURISTS))) {
      return true;
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS) &&
        rod.rodStackItems.length > 1 &&
        hoveredIndex == groupIndex &&
        selectedSubType2 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      return true;
    }

    return false;
  }

  BarTooltipItem getTooltipMessage(
      BarChartGroupData group,
      int groupIndex,
      BarChartRodData rod,
      int rodIndex,
      int hoveredIndex,
      bool isShowDetailTooltip) {
    if (!isShowDetailTooltip) {
      return BarTooltipItem(NumberUtil.moneyFormat.format(rod.toY),
          const TextStyle(color: Colors.white, fontSize: 12));
    }
    if ((selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_REVENUE) ||
            selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) &&
        hoveredIndex == groupIndex) {
      return BarTooltipItem(
          '\n${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[1].toY)}\n'
          '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[2].toY - rod.rodStackItems[2].fromY)}\n'
          '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LIQUIDATION)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[3].toY - rod.rodStackItems[3].fromY)}\n',
          const TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
          children: [
            TextSpan(
                text:
                    '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)}: ',
                style: const TextStyle(fontSize: 13),
                children: [
                  TextSpan(
                      text:
                          '${NumberUtil.moneyFormat.format(rod.rodStackItems[0].toY - rod.rodStackItems[0].fromY)}\n',
                      style:
                          const TextStyle(color: ColorManagement.negativeText)),
                ]),
            const TextSpan(
                text: '-------------\n',
                style: TextStyle(color: Colors.black54, fontSize: 10)),
            TextSpan(
                text:
                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_COMPACT)}: ',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: NumberUtil.moneyFormat.format(rod.toY + rod.fromY),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          ]);
    } else if ((selectedType ==
                MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST) ||
            selectedType ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.STATISTIC_MEALS)) &&
        hoveredIndex == groupIndex) {
      return BarTooltipItem(
          '\n${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[0].toY)}\n',
          const TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
          children: [
            TextSpan(
              text:
                  '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[1].toY - rod.rodStackItems[1].fromY)}     \n',
            ),
            const TextSpan(
              text: '----------\n',
              style: TextStyle(color: Colors.black54, fontSize: 10),
            ),
            TextSpan(
                text:
                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_COMPACT)}: ',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: NumberUtil.moneyFormat.format(rod.toY + rod.fromY),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          ]);
    } else if (selectedType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_TYPE_TOURISTS) &&
        hoveredIndex == groupIndex) {
      return BarTooltipItem(
          '\n${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_UNKNOWN)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[0].toY)}\n',
          const TextStyle(color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
          children: [
            TextSpan(
              text:
                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOREIGN)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[1].toY - rod.rodStackItems[1].fromY)}     \n',
            ),
            TextSpan(
              text:
                  '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DOMESTIC)}: ${NumberUtil.moneyFormat.format(rod.rodStackItems[2].toY - rod.rodStackItems[2].fromY)}     \n',
            ),
            const TextSpan(
              text: '----------\n',
              style: TextStyle(color: Colors.black54, fontSize: 10),
            ),
            TextSpan(
                text:
                    '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_COMPACT)}: ',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: NumberUtil.moneyFormat.format(rod.toY + rod.fromY),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          ]);
    }
    return BarTooltipItem(
        "", const TextStyle(color: Colors.white, fontSize: 12));
  }

  double getMeasureOfServiceComponent(String? type, DateTime? date) {
    double result = displayData.fold(0, (previousValue, next) {
      if (date == null ||
          (date != null && next.dateFull!.isAtSameMomentAs(date))) {
        num typeTotal = 0;
        if (type == null ||
            type ==
                MessageUtil.getMessageByCode(
                    MessageCodeUtil.SERVICE_CATEGORY_MINIBAR)) {
          typeTotal = next.minibar;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST)) {
          typeTotal = next.extraGuest;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY)) {
          typeTotal = next.laundry;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL)) {
          typeTotal = next.bikeRental;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_OTHER)) {
          typeTotal = next.other;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR)) {
          typeTotal = next.extraHour;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_RESTAURANT)) {
          typeTotal = next.outsideRestaurant;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY)) {
          typeTotal = next.electricity;
        } else if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.SERVICE_CATEGORY_WATER)) {
          typeTotal = next.water;
        }
        return previousValue + typeTotal.toDouble();
      }
      return previousValue + 0;
    });
    return result;
  }

  List<Map<String, dynamic>> get serviceComponents => [
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_MINIBAR),
          'color': ColorManagement.deepBlueColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_MINIBAR),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST),
          'color': ColorManagement.grayColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY),
          'color': ColorManagement.greenColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL),
          'color': ColorManagement.orangeColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OTHER),
          'color': ColorManagement.darkYellowColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_OTHER),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR),
          'color': ColorManagement.redColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_RESTAURANT),
          'color': ColorManagement.blueColor,
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_RESTAURANT),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY),
          'color': const Color(0xff05a8aa),
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY),
              null),
        },
        {
          'text': MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_WATER),
          'color': const Color.fromARGB(255, 115, 5, 170),
          'value': getMeasureOfServiceComponent(
              MessageUtil.getMessageByCode(
                  MessageCodeUtil.SERVICE_CATEGORY_WATER),
              null),
        },
      ];

  List<PieChartSectionData> getPieChartOfDate(
      DailyData date, double dialogWidth) {
    List<PieChartSectionData> pieChartData = [];
    var data = getDataOfDate(date);
    data.asMap().entries.map((e) {
      pieChartData.add(PieChartSectionData(
        value: e.value['value'] / e.value.length * 360,
        title: NumberUtil.moneyFormat.format(e.value['value']),
        color: e.value['color'],
        radius: dialogWidth / 2 - 50,
        titleStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: Color(0xffffffff)),
        showTitle: true,
        titlePositionPercentageOffset: 0.7,
        badgePositionPercentageOffset: 0,
      ));
    }).toList();
    return pieChartData;
  }

  List<Map<String, dynamic>> getDataOfDate(DailyData date) {
    List<Map<String, dynamic>> result = [];
    if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      int i = 0;
      date.deposit!.forEach((key, value) {
        result.add({
          'text': PaymentMethodManager().getPaymentMethodNameById(key),
          'value': value.values.fold(0, (p, e) => p + e),
          'color': ColorManagement.colorsPalete.elementAt(i++),
        });
      });
    } else if (selectedType ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE) &&
        selectedSubType1 ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
      int i = 0;

      date.service!.forEach((key, value) {
        if (value['total'] != 0) {
          result.add({
            'text': key,
            'value': value['total'],
            'color': ColorManagement.colorsPalete.elementAt(i++),
          });
        }
      });
    }
    return result;
  }

  num getTotal(String type) {
    if (type ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.STATISTIC_ROOM_CHARGE) ||
        type ==
            MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      return displayData.fold(
          0,
          (pre, data) =>
              pre +
              data.getRoomChargeOrNight(
                  methodType: selectedSubType1,
                  roomTypeName: selectedSubType2,
                  sourceName: selectedSubType3,
                  roomCharge: type ==
                      MessageUtil.getMessageByCode(
                          MessageCodeUtil.STATISTIC_ROOM_CHARGE)));
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NIGHT)) {
      return displayData.fold(
          0,
          (pre, data) =>
              pre +
              data.getRoomChargeOrNight(
                  methodType: selectedSubType1,
                  roomTypeName: selectedSubType2,
                  sourceName: selectedSubType3));
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.getRevenue());
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        return displayData.fold(
            0, (pre, data) => pre + data.getRevenueRoomCharge());
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        return displayData.fold(
            0, (pre, data) => pre + data.getRevenueService());
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)) {
        return displayData.fold(
            0, (pre, data) => pre + data.getRevenueDiscount());
      }
    } else if (type ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.revenueByDate);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        return displayData.fold(0, (pre, data) => pre + data.roomCharge);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
        return displayData.fold(0, (pre, data) => pre + data.totalService);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DISCOUNT)) {
        return displayData.fold(0, (pre, data) => pre + data.discount);
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_BREAKFAST)) {
      if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.getBreakfast());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
        return displayData.fold(
            0, (pre, data) => pre + data.getBreakfastAdult());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
        return displayData.fold(
            0, (pre, data) => pre + data.getBreakfastChild());
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_LUNCH)) {
      if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.getLunch());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
        return displayData.fold(0, (pre, data) => pre + data.getLunchAdult());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
        return displayData.fold(0, (pre, data) => pre + data.getLunchChild());
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DINNER)) {
      if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.getDinder());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
        return displayData.fold(0, (pre, data) => pre + data.getDinnerAdult());
      } else if (selectedSubType2 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
        return displayData.fold(0, (pre, data) => pre + data.getDinnerChild());
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.getGuest());
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ADULT)) {
        return displayData.fold(0, (pre, data) => pre + data.getGuestAdult());
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_CHILD)) {
        return displayData.fold(0, (pre, data) => pre + data.getGuestChild());
      }
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.totalService);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_MINIBAR)) {
        return displayData.fold(0, (pre, data) => pre + data.minibar);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST)) {
        return displayData.fold(0, (pre, data) => pre + data.extraGuest);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR)) {
        return displayData.fold(0, (pre, data) => pre + data.extraHour);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY)) {
        return displayData.fold(0, (pre, data) => pre + data.electricity);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_WATER)) {
        return displayData.fold(0, (pre, data) => pre + data.water);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY)) {
        return displayData.fold(0, (pre, data) => pre + data.laundry);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL)) {
        return displayData.fold(0, (pre, data) => pre + data.bikeRental);
      } else if (selectedSubType1 ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.SERVICE_CATEGORY_OTHER)) {
        return displayData.fold(0, (pre, data) => pre + data.other);
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)) {
      if (selectedSubType1 ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        return displayData.fold(0, (pre, data) => pre + data.totalDeposit);
      } else {
        return displayData.fold(
            0, (pre, data) => pre + data.getDepositByMethod(selectedSubType1));
      }
    } else if (type ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)) {
      String? type, supplierId, status;
      if (selectedSubType1 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        type = AccountingTypeManager.getIdByName(selectedSubType1)!;
      }
      if (selectedSubType2 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        supplierId = SupplierManager().getSupplierIDByName(selectedSubType2)!;
      }
      if (selectedSubType3 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        status = selectedSubType3;
      }
      return displayData.fold(
          0,
          (pre, data) =>
              pre +
              data.getCostManagement(
                  type: type, status: status, supplier: supplierId));
    } else if (type ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)) {
      String? type, supplierId, status, method;
      if (selectedSubType1 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        type = AccountingTypeManager.getIdByName(selectedSubType1)!;
      }
      if (selectedSubType2 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        supplierId = SupplierManager().getSupplierIDByName(selectedSubType2)!;
      }
      if (selectedSubType3 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        method =
            PaymentMethodManager().getPaymentMethodIdByName(selectedSubType3)!;
      }
      if (selectedSubType4 !=
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ALL)) {
        status = selectedSubType4;
      }
      return displayData.fold(
          0,
          (pre, data) =>
              pre +
              data.getActualPlayment(
                  type: type,
                  status: status,
                  supplier: supplierId,
                  method: method));
    }
    return 0;
  }

  num getTotalRoomCharge() =>
      displayData.fold(0, (pre, data) => pre + data.roomCharge);

  num getTotalNight() => displayData.fold(0, (pre, data) => pre + data.night);

  List<String> getDescription() {
    if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
      final num roomCharge = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE));
      final num night = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NIGHT));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)}: ${NumberUtil.numberFormat.format(roomCharge)} (${NumberUtil.numberFormat.format(roomCharge / getTotalRoomCharge() * 100)}%)',
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_AVERAGE_RATE)}: ${NumberUtil.numberFormat.format(roomCharge / night)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)) {
      final num roomCharge = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE));
      final num night = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_NIGHT));
      final num occ =
          night / (RoomManager().rooms!.length * displayData.length) * 100;
      final num rate = roomCharge / night;
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY)}: ${NumberUtil.numberFormat.format(occ)}%',
        if (UserManager.canSeeStatisticForHousekeeping()) ...[
          '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)}: ${NumberUtil.numberFormat.format(roomCharge)}',
          '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_AVERAGE_RATE)}: ${NumberUtil.numberFormat.format(rate)}'
        ]
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
      final num total = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
      final num total = getTotal(MessageUtil.getMessageByCode(
          MessageCodeUtil.STATISTIC_REVENUE_BY_DATE));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_MEALS)) {
      final num total = getTotal(selectedSubType1);
      return ['$selectedSubType1: ${NumberUtil.numberFormat.format(total)}'];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
      final num total = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE)) {
      final num total = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_SERVICE));
      return [
        '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)) {
      final num total = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_DEPOSIT)}: ${NumberUtil.numberFormat.format(total)} - Tranfser Deposit: ${displayData.fold(0.0, (pre, data) => pre + data.getDepositByMethod(PaymentMethodManager().getPaymentMethodNameById("transferdeposit")))}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)) {
      final num total = getTotal(
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACCOUNTING)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)) {
      final num total = getTotal(MessageUtil.getMessageByCode(
          MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT));
      return [
        '${MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT)}: ${NumberUtil.numberFormat.format(total)}'
      ];
    } else if (selectedType ==
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_TYPE_TOURISTS)) {
      final num unknownType = displayData.fold(
          0, (previousValue, element) => previousValue + element.unknownGuest);
      final num domesticType = displayData.fold(
          0, (previousValue, element) => previousValue + element.domesticGuest);
      final num foreignType = displayData.fold(
          0, (previousValue, element) => previousValue + element.foreignGuest);
      return [
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_UNKNOWN)}: ${NumberUtil.numberFormat.format(unknownType)}',
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_DOMESTIC)}: ${NumberUtil.numberFormat.format(domesticType)}',
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_FOREIGN)}: ${NumberUtil.numberFormat.format(foreignType)}'
      ];
    }
    return [''];
  }

  void loadBasicBookings() async {
    isLoading = true;
    notifyListeners();
    bookings.clear();
    await getInitQueryBasicBookingByCreatedRange().get().then((value) {
      getDataBooking(value);
    });
  }

  Query getInitQueryBasicBookingByCreatedRange() {
    return FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colBookings)
        .where('created', isGreaterThanOrEqualTo: startDate)
        .where('created', isLessThanOrEqualTo: endDate)
        .where('virtual', isEqualTo: false)
        .orderBy('created')
        .where('status', whereIn: [
      BookingStatus.booked,
      BookingStatus.checkin,
      BookingStatus.checkout
    ]);
  }

  void getDataBooking(QuerySnapshot snapshot) {
    for (var booking in snapshot.docs) {
      if (booking.get('group')) {
        Booking bookingGroup = Booking.groupFromSnapshot(booking);
        int lengthStay = 0;
        for (var subBooking in bookingGroup.subBookings!.entries) {
          if (subBooking.value['status'] == BookingStatus.cancel ||
              subBooking.value['status'] == BookingStatus.noshow) {
            continue;
          }
          Booking subBookingTepm =
              Booking.fromBookingParent(subBooking.key, bookingGroup);
          lengthStay += subBookingTepm.lengthStay!;
        }
        bookingGroup.lengthStay = lengthStay;
        if (bookingGroup.lengthStay != 0) {
          bookings.add(bookingGroup);
        }
      } else {
        bookings.add(Booking.fromSnapshot(booking));
      }
    }
    isLoading = false;
    notifyListeners();
  }
}
