class Warehouse {
  String? id;
  String? name;
  bool? isActive;
  Map<String, dynamic>? items = {};
  Permission? permission;

  Warehouse({this.id, this.name, this.isActive, this.items, this.permission});

  factory Warehouse.fromJson(String id, dynamic data) => Warehouse(
        id: id,
        name: data['name'],
        isActive: data['active'] ?? false,
        items: data['items'] ?? {},
        permission: data['permission'] != null
            ? Permission.fromJson(data['permission'])
            : Permission.emtpy(),
      );

  num? getAmountOfItem(String itemId) {
    try {
      return (items![itemId] as num);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => '\nName: $name, permission: $permission';
}

class Permission {
  Permission({this.roleImport, this.roleExport});

  List<String>? roleImport;

  List<String>? roleExport;

  factory Permission.emtpy() => Permission(roleExport: [], roleImport: []);

  factory Permission.fromJson(Map<String, dynamic> data) {
    List<String> imports =
        (data['import'] as List<dynamic>).map((e) => e.toString()).toList();
    List<String> exports =
        (data['export'] as List<dynamic>).map((e) => e.toString()).toList();
    return Permission(roleExport: exports, roleImport: imports);
  }

  @override
  String toString() => '\nImports: $roleImport\nExports: $roleExport\n';
}
