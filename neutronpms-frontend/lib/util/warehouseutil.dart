class LostStatus {
  LostStatus._();

  static const String lost = 'lost';
  static const String broken = 'broken';
  static const String expired = 'expired';
}

class WarehouseNotesType {
  WarehouseNotesType._();

  static const String import = 'import';
  static const String export = 'export';
  static const String transfer = 'transfer';
  static const String liquidation = 'liquidation';
  static const String lost = 'lost';
  static const String returnToSupplier = 'return';
  static const String inventoryCheck = 'inventory_check';
  static const String importBalance = 'import_balance';
  static const String exportBalance = 'export_balance';
}

class NoteTypesUlti {
  static const String IMPORT = 'import';
  static const String EXPORT = 'export';
  static const String RETURN = 'return';
  static const String BALANCE = 'balance';
  static const String COMPENSATION = 'compensation';

  static List<String> getTypes() {
    return [IMPORT, EXPORT, RETURN, COMPENSATION, BALANCE];
  }
}

class NoteCostTypesUlti {
  static const String COST = 'cost';
  static const String NOCOST = 'no-cost';

  static List<String> getCostTypes() {
    return [COST, NOCOST];
  }
}

class WarehouseActionType {
  static const String IMPORT = 'import';
  static const String EXPORT = 'export';
  static const String BOTH = 'both';
}

class InventorySatus {
  static const String CHECKING = 'checking';
  static const String CREATELIST = 'create-list';
  static const String CHECKED = 'checked';
  static const String BALANCED = 'balanced';

  static List<String> getInventoryCheckNoteStatus() {
    return [CHECKING, BALANCED];
  }
}

class ItemTypesUlti {
  static const String MATERIAL = 'material';
  static const String TOOL = 'tool';
  static const String FOR_SALE = 'for-sale';

  static List<String> getItemTypes() {
    return [MATERIAL, TOOL, FOR_SALE];
  }
}

class AccountingStatus {
  static const String DONE = 'done';
  static const String NOTYET = 'open';
  static const String PARTIAL = 'partial';

  static List<String> getAccountingStatus() {
    return [DONE, NOTYET, PARTIAL];
  }
}
