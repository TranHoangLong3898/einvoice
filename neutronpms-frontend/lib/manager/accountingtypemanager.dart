import '../modal/accounting/accounting.dart';

class AccountingTypeManager {
  static List<AccountingType?> accountingTypes = [];

  static void update(Map<String, dynamic> data) {
    accountingTypes.clear();
    if (data.isEmpty) {
      return;
    }
    for (MapEntry<String, dynamic> entry in data.entries) {
      accountingTypes.add(AccountingType.fromMapEntry(entry));
    }
    accountingTypes.sort((a, b) => a!.name!.compareTo(b!.name!));
  }

  static String? getNameById(String id) =>
      accountingTypes
          .firstWhere((element) => element!.id == id, orElse: () => null)
          ?.name ??
      "";

  static String? getIdByName(String name) =>
      accountingTypes
          .firstWhere((element) => element!.name == name, orElse: () => null)
          ?.id ??
      "";

  static List<String> get listNames =>
      accountingTypes.map((e) => e!.name!).toList();

  static List<String> get listNamesActive => accountingTypes
      .where((element) => element!.isActive == true)
      .map((e) => e!.name!)
      .toList();
}
