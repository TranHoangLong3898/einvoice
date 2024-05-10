import 'package:flutter/material.dart';

class RatePlan extends ChangeNotifier {
  final double? amount;
  //title is ID of rate plan
  String? title;
  final String? decs;
  bool? percent;
  bool? isDefault;
  bool? isDelete;
  RatePlan(
      {this.title,
      this.amount,
      this.decs,
      this.percent,
      this.isDelete,
      this.isDefault});

  factory RatePlan.fromSnapShot(dynamic snapshot) {
    return RatePlan(
      amount: snapshot['amount']?.toDouble(),
      percent: snapshot['percent'],
      decs: snapshot['decs'],
      isDelete: snapshot['is_delete'],
      isDefault: snapshot['is_default'],
    );
  }
}
