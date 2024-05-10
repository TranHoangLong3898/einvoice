import 'dart:typed_data';

import 'package:ihotel/modal/status.dart';

class HotelItem {
  String? id;
  String? name;
  String? type;
  String? unit;
  double? costPrice;
  double? sellPrice;
  String? defaultWarehouseId;
  Uint8List? image;
  bool? isActive;
  bool? isAutoExport;

  HotelItem(
      {this.id,
      this.name,
      this.type,
      this.unit,
      this.image,
      this.costPrice,
      this.sellPrice,
      this.defaultWarehouseId,
      this.isAutoExport,
      this.isActive});

  factory HotelItem.fromMap(String id, Map<String, dynamic> doc) => HotelItem(
      id: id,
      name: doc['name'],
      unit: doc['unit'],
      defaultWarehouseId: doc['warehouse'],
      costPrice: doc['cost_price']?.toDouble() ?? 0,
      sellPrice: doc['sell_price']?.toDouble() ?? 0,
      isActive: doc['active'] ?? false,
      isAutoExport: doc['auto_export'] ?? false,
      type: doc['type'] ?? ItemType.other);

  factory HotelItem.copy(HotelItem other) => HotelItem(
      id: other.id,
      image: other.image,
      name: other.name,
      unit: other.unit,
      defaultWarehouseId: other.defaultWarehouseId,
      costPrice: other.costPrice,
      sellPrice: other.sellPrice,
      isActive: other.isActive,
      isAutoExport: other.isAutoExport,
      type: other.type);

  bool equalTo(HotelItem other) {
    return id == other.id &&
        name == other.name &&
        unit == other.unit &&
        defaultWarehouseId == other.defaultWarehouseId &&
        costPrice == other.costPrice &&
        sellPrice == other.sellPrice &&
        isActive == other.isActive &&
        isAutoExport == other.isAutoExport &&
        type == other.type &&
        image == other.image;
  }

  @override
  bool operator ==(Object other) {
    if (other is HotelItem) {
      return id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ItemRestaurant: id=$id, name=$name, costPrice=$costPrice, sellPrice=$sellPrice, unit=$unit, warehouse=$defaultWarehouseId, type=$type, autoExport=$isAutoExport, active=$isActive\n';
  }
}
