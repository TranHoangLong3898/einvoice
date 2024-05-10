import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ihotel/util/messageulti.dart';

import '../handler/firebasehandler.dart';
import '../manager/requestmanager.dart';
import '../util/numberutil.dart';

class Request {
  String? id;
  String? type;
  String? desc;
  String? item;
  num? amount;
  String? unit;
  num? price;

  Timestamp? createdTime;
  Timestamp? approvedTime;
  Timestamp? orderedTime;
  Timestamp? confirmedTime;

  String? createdBy;
  String? approvedBy;
  String? orderedBy;

  num? approved;
  num? ordered;
  num? confirmed;

  String? orderID;

  Request(
      {this.id,
      this.type,
      this.desc,
      this.item,
      this.amount,
      this.unit,
      this.price,
      this.createdTime,
      this.createdBy,
      this.approvedTime,
      this.approvedBy,
      this.approved,
      this.orderedBy,
      this.orderedTime,
      this.ordered,
      this.confirmed,
      this.confirmedTime,
      this.orderID});

  factory Request.fromSnapshot(DocumentSnapshot doc) => Request(
      id: doc.id,
      type: doc.get('type'),
      desc: doc.get('desc'),
      item: doc.get('item'),
      amount: doc.get('amount'),
      unit: doc.get('unit'),
      createdBy: doc.get('created_by'),
      createdTime: doc.get('created_time'),
      approvedBy: doc.get('approved_by'),
      approvedTime: doc.get('approved_time'),
      approved: doc.get('approved'),
      ordered: doc.get('ordered'),
      orderedBy: doc.get('ordered_by'),
      orderedTime: doc.get('ordered_time'),
      orderID: (doc.data() as Map<String, dynamic>).containsKey('order_id')
          ? doc.get('order_id')
          : null,
      confirmed: doc.get('confirmed'),
      confirmedTime: doc.get('confirmed_time'));

  Future<String> addToCloud() async {
    if (amount == null || amount == 0) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }
    if (desc!.isEmpty) return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    try {
      await FirebaseHandler.hotelRef
          .collection('requests')
          .doc(NumberUtil.getSidByConvertToBase62())
          .set({
        'type': type,
        'desc': desc,
        'item': item,
        'amount': amount,
        'unit': unit,
        'created_by': createdBy ?? FirebaseAuth.instance.currentUser!.email,
        'created_time': createdTime ?? Timestamp.now(),
        'approved_by': null,
        'approved_time': null,
        'approved': RequestManager.statusNotYet,
        'ordered': RequestManager.statusNotYet,
        'ordered_by': null,
        'ordered_time': null,
        'confirmed': RequestManager.statusNotYet,
        'confirmed_time': null
      });
      return MessageCodeUtil.SUCCESS;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }

  Future<String> deleteOnCloud() async {
    try {
      await FirebaseHandler.hotelRef.collection('requests').doc(id).delete();
      return MessageCodeUtil.SUCCESS;
    } on Exception catch (e) {
      print(e.toString());
      return MessageCodeUtil.UNDEFINED_ERROR;
    }
  }

  String getStatus() {
    String status = '';
    if (approved == RequestManager.statusNo) {
      status += 'disapproved';
    } else if (approved == RequestManager.statusNotYet) {
      status += 'not approved yet';
    } else if (approved == RequestManager.statusYes) {
      status += 'approved';

      if (ordered == RequestManager.statusNo) {
        status += ', not ordered';
      } else if (ordered == RequestManager.statusNotYet) {
        status += ', not ordered yet';
      } else if (ordered == RequestManager.statusYes) {
        status += ', ordered';
      }
    }

    return status;
  }
}
