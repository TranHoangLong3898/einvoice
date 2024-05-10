class ExtraHour {
  int? lateHours = 0;
  int? earlyHours = 0;
  num? latePrice = 0;
  num? earlyPrice = 0;
  num? total = 0;

  ExtraHour(
      {this.earlyHours, this.earlyPrice, this.lateHours, this.latePrice}) {
    total = earlyPrice! + latePrice!;
  }

  ExtraHour.fromMap(Map map) {
    earlyHours = map.containsKey('early_hours') ? map['early_hours'] : 0;
    lateHours = map.containsKey('late_hours') ? map['late_hours'] : 0;
    earlyPrice = map.containsKey('early_price') ? map['early_price'] : 0;
    latePrice = map.containsKey('late_price') ? map['late_price'] : 0;
    total = map.containsKey('total') ? map['total'] : earlyPrice! + latePrice!;
  }

  ExtraHour.empty();

  ExtraHour.fromGroup(int totalMoney) {
    total = totalMoney;
  }
}
