class ElectricityWater {
  num? firstWaterNumber = 0;
  num? firstElectricityNumber = 0;
  num? waterPrice = 0;
  num? lastWaterNumber = 0;
  num? lastElectricityNumber = 0;
  num? electricityPrice = 0;
  num total = 0;

  ElectricityWater(
      {this.firstWaterNumber,
      this.firstElectricityNumber,
      this.lastElectricityNumber,
      this.lastWaterNumber,
      this.electricityPrice,
      this.waterPrice}) {
    total = waterPrice! + electricityPrice!;
  }

  ElectricityWater.fromMap(Map map) {
    firstWaterNumber = map.containsKey('first_water') ? map['first_water'] : 0;
    firstElectricityNumber =
        map.containsKey('first_electricity') ? map['first_electricity'] : 0;
    lastWaterNumber = map.containsKey('last_water') ? map['last_water'] : 0;
    lastElectricityNumber =
        map.containsKey('last_electricity') ? map['last_electricity'] : 0;
    waterPrice = map.containsKey('water_price') ? map['water_price'] : 0;
    electricityPrice =
        map.containsKey('electricity_price') ? map['electricity_price'] : 0;
    total = map.containsKey('total')
        ? map['total']
        : waterPrice! + electricityPrice!;
  }

  ElectricityWater.empty();

  ElectricityWater.fromGroup(int totalMoney) {
    total = totalMoney;
  }
}
