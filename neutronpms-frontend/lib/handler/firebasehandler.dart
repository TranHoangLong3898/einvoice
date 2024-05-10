import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ihotel/util/messageulti.dart';
import '../manager/generalmanager.dart';
import '../modal/hotel.dart';
import '../modal/service/deposit.dart';
import '../util/dateutil.dart';

class FirebaseHandler {
  static const colBookings = 'bookings';
  static const colBasicBookings = 'basic_bookings';
  static const colDeposits = 'deposits';
  static const colBookingDeposits = 'booking_deposits';
  static const colPayments = 'payments';
  static const colServices = 'services';
  static const colRequests = 'requests';
  static const colRevenueLogs = 'revenue_logs';

  static const colOrders = 'orders';
  static const colDailyData = 'daily_data';
  static const colDailyAllotment = 'daily_allotment';
  static const docRevenue = 'revenue';
  static const colManagement = 'management';
  static const colConfigurations = 'configurations';
  static const colItems = 'items';
  static const colOverdueBookings = 'overdue_bookings';
  static const colRestaurants = 'restaurants';
  static const colWarehouses = 'warehouses';
  static const colWarehouseNotes = 'warehouse_notes';
  static const colCostManagement = 'cost_management';
  static const colActualPayment = 'actual_payment';
  static const colPaymentPackage = 'package_payments';

  static DocumentReference hotelRef = FirebaseFirestore.instance
      .collection('hotels')
      .doc(GeneralManager.hotelID);

  static final FirebaseHandler _instance = FirebaseHandler._internal();
  factory FirebaseHandler() {
    return _instance;
  }
  FirebaseHandler._internal();

  static void updateHotel() {
    hotelRef = FirebaseFirestore.instance
        .collection('hotels')
        .doc(GeneralManager.hotelID);
  }

  Future<Hotel> getCurrentHotel() async {
    return await hotelRef
        .get()
        .then((doc) => Hotel.fromSnapshot(doc))
        .catchError((e) => e);
  }

  Future<List<dynamic>> getDailyData(
      DateTime startDate, DateTime endDate) async {
    final inDay = DateUtil.dateToShortStringDay(startDate);
    final outDay = DateUtil.dateToShortStringDay(endDate);
    final inMonthId = DateUtil.dateToShortStringYearMonth(startDate);
    final outMonthId = DateUtil.dateToShortStringYearMonth(endDate);
    List<dynamic> result = [];
    if (inMonthId == outMonthId) {
      await hotelRef
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
        await hotelRef
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

  /// sang nay
  Future<List<dynamic>> getDailyDataByYear(
      List<String> modthYear, String selectedYear) async {
    List<dynamic> result = [];

    for (var monthId in modthYear) {
      if (monthId.substring(0, 4) == selectedYear) {
        Map<String, Map<String, dynamic>?> mapDailyDataYear = {};
        mapDailyDataYear["year"] = {};
        mapDailyDataYear["year"]!['date'] = {};
        mapDailyDataYear["breakfast"] = {};
        mapDailyDataYear["new_booking"] = {};
        mapDailyDataYear["current_booking"] = {};
        mapDailyDataYear["revenue"] = {};
        mapDailyDataYear["guest"] = {};
        mapDailyDataYear["service"] = {};
        mapDailyDataYear["deposit"] = {};
        mapDailyDataYear["cost_management"] = {};
        mapDailyDataYear["actual_payment"] = {};
        mapDailyDataYear["country"] = {};
        mapDailyDataYear["type_tourists"] = {};
        await hotelRef
            .collection('daily_data')
            .doc(monthId)
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!['data'] as Map<String, dynamic>;
            mapDailyDataYear["year"]!['date'] =
                "$monthId${monthId.substring(4, 6)}";
            for (var keyOfData in data.keys) {
              print("dem $monthId $keyOfData");
              for (var element
                  in (data[keyOfData] as Map<String, dynamic>).keys) {
                if (element == "breakfast") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      mapDailyDataYear[element]![key] += value;
                    } else {
                      mapDailyDataYear[element]![key] = (value ?? 0);
                    }
                  });
                } else if (element == "new_booking") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      value.forEach((key1, value1) {
                        if (mapDailyDataYear[element]![key].containsKey(key1)) {
                          value1.forEach((key2, value2) {
                            if (mapDailyDataYear[element]![key][key1]
                                .containsKey(key2)) {
                              value2.forEach((key3, value3) {
                                if (mapDailyDataYear[element]![key][key1][key2]
                                    .containsKey(key3)) {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] += value3 ?? 0;
                                } else {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] = (value3 ?? 0);
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![key][key1][key2] =
                                  value2;
                            }
                          });
                        } else {
                          mapDailyDataYear[element]![key][key1] = value1;
                        }
                      });
                    } else {
                      mapDailyDataYear[element]![key] = value;
                    }
                  });
                } else if (element == "current_booking") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      value.forEach((key1, value1) {
                        if (mapDailyDataYear[element]![key].containsKey(key1)) {
                          value1.forEach((key2, value2) {
                            if (mapDailyDataYear[element]![key][key1]
                                .containsKey(key2)) {
                              value2.forEach((key3, value3) {
                                if (mapDailyDataYear[element]![key][key1][key2]
                                    .containsKey(key3)) {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] += value3 ?? 0;
                                } else {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] = (value3 ?? 0);
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![key][key1][key2] =
                                  value2;
                            }
                          });
                        } else {
                          mapDailyDataYear[element]![key][key1] = value1;
                        }
                      });
                    } else {
                      mapDailyDataYear[element]![key] = value;
                    }
                  });
                } else if (element == "revenue") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      mapDailyDataYear[element]![key] += value;
                    } else {
                      mapDailyDataYear[element]![key] = (value ?? 0);
                    }
                  });
                } else if (element == "guest") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      mapDailyDataYear[element]![key] += value;
                    } else {
                      mapDailyDataYear[element]![key] = (value ?? 0);
                    }
                  });
                } else if (element == "service") {
                  data[keyOfData][element].forEach((keyService, value) {
                    if (keyService == "minibar") {
                      if (mapDailyDataYear[element]!.containsKey(keyService)) {
                        value.forEach((key1, value1) {
                          if (key1 == "total") {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              mapDailyDataYear[element]![keyService][key1] +=
                                  value1;
                            } else {
                              mapDailyDataYear[element]![keyService][keyService]
                                  [key1] = (value1 ?? 0);
                            }
                          } else {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              value1.forEach((key2, value2) {
                                if (mapDailyDataYear[element]![keyService][key1]
                                    .containsKey(key2)) {
                                  value2.forEach((key3, value3) {
                                    if (mapDailyDataYear[element]![keyService]
                                            [key1][key2]
                                        .containsKey(key3)) {
                                      mapDailyDataYear[element]![keyService]
                                          [key1][key2][key3] += value3;
                                    } else {
                                      mapDailyDataYear[element]![keyService]
                                          [key1][key2][key3] = (value3 ?? 0);
                                    }
                                  });
                                } else {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] = value2;
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![keyService][key1] =
                                  value1;
                            }
                          }
                        });
                      } else {
                        mapDailyDataYear[element]![keyService] = value;
                      }
                    } else if (keyService == "inside_restaurant") {
                      if (mapDailyDataYear[element]!.containsKey(keyService)) {
                        value.forEach((key1, value1) {
                          if (key1 == "total") {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              mapDailyDataYear[element]![keyService][key1] +=
                                  value1;
                            } else {
                              mapDailyDataYear[element]![keyService][keyService]
                                  [key1] = (value1 ?? 0);
                            }
                          } else {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              value1.forEach((key2, value2) {
                                if (mapDailyDataYear[element]![keyService][key1]
                                    .containsKey(key2)) {
                                  value2.forEach((key3, value3) {
                                    if (mapDailyDataYear[element]![keyService]
                                            [key1][key2]
                                        .containsKey(key3)) {
                                      mapDailyDataYear[element]![keyService]
                                          [key1][key2][key3] += value3;
                                    } else {
                                      mapDailyDataYear[element]![keyService]
                                          [key1][key2][key3] = (value3 ?? 0);
                                    }
                                  });
                                } else {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] = value2;
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![keyService][key1] =
                                  value1;
                            }
                          }
                        });
                      } else {
                        mapDailyDataYear[element]![keyService] = value;
                      }
                    } else if (keyService == "other") {
                      if (mapDailyDataYear[element]!.containsKey(keyService)) {
                        value.forEach((key1, value1) {
                          if (key1 == "total") {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              mapDailyDataYear[element]![keyService][key1] +=
                                  value1;
                            } else {
                              mapDailyDataYear[element]![keyService][keyService]
                                  [key1] = (value1 ?? 0);
                            }
                          } else {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              value1.forEach((key2, value2) {
                                if (mapDailyDataYear[element]![keyService][key1]
                                    .containsKey(key2)) {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] += value2;
                                } else {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] = (value2 ?? 0);
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![keyService][key1] =
                                  value1;
                            }
                          }
                        });
                      } else {
                        mapDailyDataYear[element]![keyService] = value;
                      }
                    } else if (keyService == "restaurant") {
                      if (mapDailyDataYear[element]!.containsKey(keyService)) {
                        value.forEach((key1, value1) {
                          if (key1 == "total") {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              mapDailyDataYear[element]![keyService][key1] +=
                                  value1;
                            } else {
                              mapDailyDataYear[element]![keyService][keyService]
                                  [key1] = (value1 ?? 0);
                            }
                          } else {
                            if (mapDailyDataYear[element]![keyService]
                                .containsKey(key1)) {
                              value1.forEach((key2, value2) {
                                if (mapDailyDataYear[element]![keyService][key1]
                                    .containsKey(key2)) {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] += value2;
                                } else {
                                  mapDailyDataYear[element]![keyService][key1]
                                      [key2] = (value2 ?? 0);
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![keyService][key1] =
                                  value1;
                            }
                          }
                        });
                      } else {
                        mapDailyDataYear[element]![keyService] = value;
                      }
                    } else {
                      if (mapDailyDataYear[element]!.containsKey(keyService)) {
                        value.forEach((key1, value2) {
                          if (mapDailyDataYear[element]![keyService]
                              .containsKey(key1)) {
                            mapDailyDataYear[element]![keyService][key1] +=
                                value2;
                          } else {
                            mapDailyDataYear[element]![keyService][key1] =
                                (value2 ?? 0);
                          }
                        });
                      } else {
                        mapDailyDataYear[element]![keyService] = value;
                      }
                    }
                  });
                } else if (element == "deposit") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      value.forEach((key1, value1) {
                        if (mapDailyDataYear[element]![key].containsKey(key1)) {
                          mapDailyDataYear[element]![key][key1] += value1;
                        } else {
                          mapDailyDataYear[element]![key][key1] = (value1 ?? 0);
                        }
                      });
                    } else {
                      mapDailyDataYear[element]![key] = value;
                    }
                  });
                } else if (element == "cost_management") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      value.forEach((key2, value2) {
                        if (mapDailyDataYear[element]![key]!
                            .containsKey(key2)) {
                          value2.forEach((key3, value3) {
                            if (mapDailyDataYear[element]![key][key2]
                                .containsKey(key3)) {
                              mapDailyDataYear[element]![key][key2][key3] +=
                                  value3;
                            } else {
                              mapDailyDataYear[element]![key][key2][key3] =
                                  (value3 ?? 0);
                            }
                          });
                        } else {
                          mapDailyDataYear[element]![key][key2] = value2;
                        }
                      });
                    } else {
                      mapDailyDataYear[element]![key] = value;
                    }
                  });
                } else if (element == "actual_payment") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      value.forEach((key1, value1) {
                        if (mapDailyDataYear[element]![key].containsKey(key1)) {
                          value1.forEach((key2, value2) {
                            if (mapDailyDataYear[element]![key][key1]
                                .containsKey(key2)) {
                              value2.forEach((key3, value3) {
                                if (mapDailyDataYear[element]![key][key1][key2]
                                    .containsKey(key3)) {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] += value3 ?? 0;
                                } else {
                                  mapDailyDataYear[element]![key][key1][key2]
                                      [key3] = (value3 ?? 0);
                                }
                              });
                            } else {
                              mapDailyDataYear[element]![key][key1][key2] =
                                  value2;
                            }
                          });
                        } else {
                          mapDailyDataYear[element]![key][key1] = value1;
                        }
                      });
                    } else {
                      mapDailyDataYear[element]![key] = value;
                    }
                  });
                } else if (element == "country") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      mapDailyDataYear[element]![key] += value;
                    } else {
                      mapDailyDataYear[element]![key] = (value ?? 0);
                    }
                  });
                } else if (element == "type_tourists") {
                  data[keyOfData][element].forEach((key, value) {
                    if (mapDailyDataYear[element]!.containsKey(key)) {
                      mapDailyDataYear[element]![key] += value;
                    } else {
                      mapDailyDataYear[element]![key] = (value ?? 0);
                    }
                  });
                }
              }
            }
          } else {
            mapDailyDataYear["year"]?['date'] =
                "$monthId${monthId.substring(4, 6)}";
          }
        }).onError((error, stackTrace) => null);
        result.add(mapDailyDataYear);
      }
    }
    return result;
  }

  Future<List<Deposit>?> getCashLogs(
      DateTime startDate, DateTime endDate) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day, 0);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 24);
      List<Deposit> cashLogs = [];
      final snapshot = await hotelRef
          .collection('cash_logs')
          .where('created', isGreaterThanOrEqualTo: start)
          .where('created', isLessThan: end)
          .get();
      for (var doc in snapshot.docs) {
        cashLogs.add(Deposit(
            id: doc.id,
            amount: doc.get('amount'),
            created: doc.get('created'),
            desc: doc.get('desc')));
      }

      cashLogs.sort((a, b) => a.created!.compareTo(b.created!));

      return cashLogs;
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<num?> getReceptionCash() async {
    try {
      final doc = await hotelRef
          .collection(FirebaseHandler.colManagement)
          .doc('reception_cash')
          .get();
      return doc.get('total');
    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> addCashLog(Deposit cashLog, num totalCash) async {
    try {
      // add cash log total previous todo
      // update field status open passed failed to whole document
      final result = await FirebaseFunctions.instance
          .httpsCallable('cashlog-addCashLogToCloud')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'cashlog_amount': cashLog.amount,
        'cashlog_desc': cashLog.desc,
        'total_cash': totalCash
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (e) {
      return e.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }

// get hotels by UID of user
  Future<List<Hotel>> getHotelIDsByUser(String userID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('hotels')
          .where('users', arrayContains: userID)
          .get();

      List<Hotel> hotels = [];
      for (final doc in snapshot.docs) {
        hotels.add(Hotel.fromSnapshot(doc));
      }
      return hotels;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }

  /*
    this method is only used by admin account
   */
  Future<List<Hotel>> getHotelsWithApproximateQuery(String hotelName) async {
    try {
      List<Hotel> hotels = [];
      await FirebaseFirestore.instance
          .collection('hotels')
          .where('name', isGreaterThanOrEqualTo: hotelName)
          .where('name', isLessThanOrEqualTo: '$hotelName~')
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          hotels.add(Hotel.fromSnapshot(doc));
        }
      });
      return hotels;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<Uint8List?> getImgByHotelId(String hotelId) async {
    return await FirebaseStorage.instance
        .ref()
        .child('img_hotels')
        .child(hotelId)
        .getData()
        .then((value) => value)
        .onError((error, stackTrace) => null);
  }
}
