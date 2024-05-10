import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class BookingDeposit {
  String id;
  String sid;
  String? note;
  String name;
  DateTime createTime;
  double amount;
  String paymentMethod;
  int status;
  num remain;
  List<DepositHistory> history;

  BookingDeposit({
    required this.id,
    required this.sid,
    required this.name,
    this.note,
    this.remain = 0,
    required this.createTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.history,
  });

  factory BookingDeposit.fromSnapshot(DocumentSnapshot doc) => BookingDeposit(
      id: doc.id,
      amount: doc.get('amount'),
      name: doc.get('name'),
      remain: doc.get('remain'),
      sid: doc.get('sid'),
      createTime: (doc.get('created') as Timestamp).toDate(),
      history: DepositHistory.getDataFromSnapshot(doc.get('history')),
      paymentMethod: doc.get('method'),
      note: doc.get('note'),
      status: doc.get('status'));

  bool isCanNotUpdate(BookingDeposit newDeposit) {
    return (sid != newDeposit.sid ||
            createTime != newDeposit.createTime ||
            amount != newDeposit.amount) &&
        status != newDeposit.status;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookingDeposit &&
        other.id == id &&
        other.sid == sid &&
        other.createTime == createTime &&
        other.history == history &&
        other.note == note &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.name == name;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      sid.hashCode ^
      amount.hashCode ^
      createTime.hashCode ^
      history.hashCode ^
      note.hashCode ^
      status.hashCode ^
      paymentMethod.hashCode ^
      name.hashCode;
}

class DepositHistory {
  String sid;
  String paymentMethod;
  DateTime time;
  double amount;
  bool bookingType;
  String name;
  num status;

  DepositHistory(
      {required this.sid,
      required this.time,
      required this.amount,
      required this.paymentMethod,
      required this.bookingType,
      required this.name,
      required this.status});

  static List<DepositHistory> getDataFromSnapshot(dynamic data) {
    List<DepositHistory> result = [];
    if (data.isEmpty) return result;
    for (var entry in data.entries) {
      List<String> stringData = entry.value.split(specificCharacter);
      result.add(DepositHistory(
        sid: stringData[0],
        paymentMethod: stringData[1],
        amount: double.tryParse(stringData[2]) ?? 0,
        time: Timestamp.fromMicrosecondsSinceEpoch(
                int.tryParse(stringData[3]) ?? 0)
            .toDate(),
        bookingType: bool.tryParse(stringData[4]) ?? false,
        name: stringData[5],
        status: int.parse(stringData[6]),
      ));
    }
    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }
}

class DepositStatus {
  static const int DEPOSIT = 0;
  static const int REFUND = 1;

  static List<String> getStatuses() {
    return [
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEPOSIT),
      UITitleUtil.getTitleByCode(UITitleCode.STATUS_REFUND)
    ];
  }

  static getStatusByString(int status) {
    if (status == DEPOSIT) {
      return UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEPOSIT);
    }
    if (status == REFUND) {
      return UITitleUtil.getTitleByCode(UITitleCode.STATUS_REFUND);
    }
  }
}
