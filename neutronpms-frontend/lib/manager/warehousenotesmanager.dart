import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/usermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/modal/warehouse/warehouse.dart';
import 'package:ihotel/modal/warehouse/warehouselost/warehousenotelost.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:ihotel/util/messageulti.dart';
import '../handler/firebasehandler.dart';
import '../modal/accounting/accounting.dart';
import '../modal/warehouse/inventory/warehousechecknote.dart';
import '../modal/warehouse/warehouseexport/warehousenoteexport.dart';
import '../modal/warehouse/warehouseimport/warehousenoteimport.dart';
import '../modal/warehouse/warehouseliquidation/warehousenoteliquidation.dart';
import '../modal/warehouse/warehousenote.dart';
import '../modal/warehouse/warehousereturn/warehousenotereturn.dart';
import '../modal/warehouse/warehousetransfer/warehousenotetransfer.dart';
import '../util/excelulti.dart';
import '../util/uimultilanguageutil.dart';

class WarehouseNotesManager extends ChangeNotifier {
  WarehouseNotesManager._singleton();

  static final _instance = WarehouseNotesManager._singleton();

  factory WarehouseNotesManager() => _instance;

  DateTime? startDate;
  DateTime? endDate;
  QueryDocumentSnapshot? lastDoc;

  /// first element is type of note, if first element is import or export => the second element is return
  List<String>? noteType = [];
  List<WarehouseNote> data = [];
  final int pageSize = 10;
  bool? isInProgress = false;
  int pageIndex = 0;
  int? startIndex;
  int? endIndex;
  TextEditingController queryString = TextEditingController(text: "");
  bool showMoreExcelOption = false;
  double excelOptionHeight = 60;
  int indexSelectedTab = 0;
  int currentIndex = 0;

  ///true => search by invoice, false => search by creator
  bool isSearchByInvoice = true;

  /// use to show list cost of import note
  List<Accounting> listAccounting = [];

  /// just use for import
  String importType = UITitleCode.ALL;
  String hasCostFilter = UITitleCode.ALL;
  String exportType = UITitleCode.ALL;
  DateTime now = DateTime.now();
  String status = MessageCodeUtil.ALL;

  Query getQuery() {
    Query query;
    if (noteType![0] == WarehouseNotesType.export ||
        noteType![0] == WarehouseNotesType.import) {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colWarehouseNotes)
          .where('type', whereIn: noteType);
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colWarehouseNotes)
          .where('type', isEqualTo: noteType![0]);
    }
    if (startDate != null) {
      query = query.where('created_time',
          isGreaterThanOrEqualTo: DateUtil.to0h(startDate!));
    }

    if (endDate != null) {
      query = query.where('created_time',
          isLessThanOrEqualTo: DateUtil.to24h(endDate!));
    }

    if (!UserManager.canSeeWareHouseManagement()) {
      query = query.where('creator', isEqualTo: UserManager.user!.email);
    }
    if (queryString.text.isNotEmpty) {
      query = isSearchByInvoice
          ? query.where('invoice', isEqualTo: queryString.text)
          : query.where('creator', isEqualTo: queryString.text);
      pageIndex = 0;
    }

    query = query.orderBy('created_time', descending: true);
    return query;
  }

  Future<void> getWarehouseNotes() async {
    if ((isInProgress ?? false) || noteType == null) {
      return;
    }
    //this to prevent when query is not done but type change
    String tempType = noteType![0];
    isInProgress = true;
    // notifyListeners();
    QuerySnapshot snapshot = await getQuery().limit(pageSize).get();
    data.clear();
    if (snapshot.size > 0) {
      lastDoc = snapshot.docs.last;
      for (var doc in snapshot.docs) {
        if (noteType![0] != tempType) {
          data.clear();
          lastDoc = null;
          isInProgress = null;
          notifyListeners();
          return;
        }
        switch (doc['type']) {
          case WarehouseNotesType.import:
          case WarehouseNotesType.importBalance:
            data.add(WarehouseNoteImport.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.export:
          case WarehouseNotesType.exportBalance:
            data.add(WarehouseNoteExport.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.transfer:
            data.add(WarehouseNoteTransfer.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.liquidation:
            data.add(WarehouseNoteLiquidation.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.lost:
            data.add(WarehouseNoteLost.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.returnToSupplier:
            data.add(WarehouseNoteReturn.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.inventoryCheck:
            data.add(WarehouseNoteCheck.fromDocumentSnapshot(doc));
            break;
          default:
            print('Wrong type: $noteType');
            break;
        }
      }
    } else {
      lastDoc = null;
      if (noteType![0] != tempType) {
        data.clear();
        isInProgress = null;
        notifyListeners();
        return;
      }
    }

    updateIndex();
    isInProgress = false;
    notifyListeners();
  }

  Future<WarehouseNote?> getWarehouseNoteByInvoiceNum(
      String invoiceNum, String warehouseNoteType) async {
    QuerySnapshot snapshot = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colWarehouseNotes)
        .where('type', isEqualTo: warehouseNoteType)
        .where('invoice', isEqualTo: invoiceNum)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    if (warehouseNoteType == WarehouseNotesType.import) {
      return WarehouseNoteImport.fromDocumentSnapshot(snapshot.docs.first);
    } else if (warehouseNoteType == WarehouseNotesType.returnToSupplier) {
      return WarehouseNoteReturn.fromDocumentSnapshot(snapshot.docs.first);
    }
    return null;
  }

  Future<void> getCostByInvoiceNum(String invoiceNum) async {
    listAccounting.clear();

    QuerySnapshot snapshot = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('invoice_num', isEqualTo: invoiceNum)
        .get();
    if (snapshot.docs.isEmpty) {
      return;
    }
    for (var doc in snapshot.docs) {
      listAccounting.add(Accounting.fromQueryDocumentSnapshot(doc));
    }
    notifyListeners();
  }

  Future<WarehouseNote?> getWareImportNoteByReturnInvoiceNum(
      String invoiceNum) async {
    QuerySnapshot snapshot = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colWarehouseNotes)
        .where('type', isEqualTo: WarehouseNotesType.import)
        .where('return_invoice_number', isEqualTo: invoiceNum)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return WarehouseNoteImport.fromDocumentSnapshot(snapshot.docs.first);
  }

  WarehouseNoteReturn? getReturnNote(String importInvoiceNum) {
    List<WarehouseNoteReturn> returnList =
        data.whereType<WarehouseNoteReturn>().toList();
    try {
      return returnList.firstWhere(
          (element) => element.importInvoiceNumber == importInvoiceNum);
    } catch (e) {
      return null;
    }
  }

  Future<String> createNote(
    String id,
    DateTime now,
    String invoiceNumber,
    String noteType,
    Map<String, dynamic> dataList,
    dynamic optional,
    Map<String, String>? warehouseActions,
  ) async {
    if (noteType != WarehouseNotesType.inventoryCheck) {
      String checkCreatePermissionResult =
          checkCreatePermission(warehouseActions!, now);
      if (checkCreatePermissionResult != MessageCodeUtil.SUCCESS) {
        return checkCreatePermissionResult;
      }
    }

    Map<String, dynamic> dataToCreate = {
      'hotel_id': GeneralManager.hotelID,
      'id': id,
      'created_time': now.toString(),
      'invoice': invoiceNumber,
      'list': dataList,
      'type': noteType
    };
    if (optional != null) {
      if (noteType == WarehouseNotesType.import) {
        dataToCreate['return_invoice_number'] = optional;
      }
      if (noteType == WarehouseNotesType.returnToSupplier) {
        dataToCreate['import_invoice_number'] = optional;
      }

      if (noteType == WarehouseNotesType.inventoryCheck) {
        if (optional['note'] != null) {
          dataToCreate['note'] = optional['note'];
        }
        if (optional['status'] != null) {
          dataToCreate['status'] = optional['status'];
        }
        if (optional['warehouse'] != null) {
          dataToCreate['warehouse'] = optional['warehouse'];
        }
      }
    }
    String result = await FirebaseFunctions.instance
        .httpsCallable('warehouse-createWarehouseNote')
        .call(dataToCreate)
        .then((value) => value.data)
        .onError((error, stackTrace) {
      return (error as FirebaseFunctionsException).message;
    });
    return result;
  }

  Future<String> updateNote(
    WarehouseNote warehouseNote,
    DateTime now,
    String invoiceNumber,
    String noteType,
    Map<String, dynamic> dataList,
    dynamic optional,
  ) async {
    if (noteType != WarehouseNotesType.inventoryCheck) {
      String checkPermissionResult = checkModifyPermission(warehouseNote);
      if (checkPermissionResult != MessageCodeUtil.SUCCESS) {
        return checkPermissionResult;
      }
    }

    Map<String, dynamic> dataToCreate = {
      'hotel_id': GeneralManager.hotelID,
      'note_id': warehouseNote.id,
      'invoice': invoiceNumber,
      'list': dataList,
      'created_time': now.toString(),
      'type': noteType,
    };
    if (optional != null) {
      if (noteType == WarehouseNotesType.import) {
        dataToCreate['return_invoice_number'] = optional;
      }
      if (noteType == WarehouseNotesType.returnToSupplier) {
        dataToCreate['import_invoice_number'] = optional;
      }

      if (noteType == WarehouseNotesType.inventoryCheck) {
        if (optional['note'] != null) {
          dataToCreate['note'] = optional['note'];
        }
        if (optional['status'] != null) {
          dataToCreate['status'] = optional['status'];
        }
        if (optional['warehouse'] != null) {
          dataToCreate['warehouse'] = optional['warehouse'];
        }
        if (optional['isCreateNote'] != null) {
          dataToCreate['is_create_note'] = optional['isCreateNote'];
        }
      }
    }
    String result = await FirebaseFunctions.instance
        .httpsCallable('warehouse-editWarehouseNote')
        .call(dataToCreate)
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    return result;
  }

  Future<String> deleteWarehouseNote(WarehouseNote warehouseNote) async {
    isInProgress = true;
    notifyListeners();
    String checkPermissionResult = checkModifyPermission(warehouseNote);
    if (checkPermissionResult != MessageCodeUtil.SUCCESS) {
      isInProgress = false;
      notifyListeners();
      return checkPermissionResult;
    }
    String result = await FirebaseFunctions.instance
        .httpsCallable('warehouse-deleteWarehouseNote')
        .call({'hotel_id': GeneralManager.hotelID, 'id': warehouseNote.id})
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
    if (result == MessageCodeUtil.SUCCESS) {
      data.removeWhere((element) => element.id == warehouseNote.id);
      updateIndex();
    }
    isInProgress = false;
    notifyListeners();
    return result;
  }

  void updateIndex() {
    startIndex = pageIndex * pageSize > data.length ? 0 : pageIndex * pageSize;
    endIndex = pageIndex * pageSize + pageSize > data.length
        ? data.length
        : pageIndex * pageSize + pageSize;
  }

  Future<void> nextPage() async {
    if (data.length > (pageIndex * pageSize + pageSize)) {
      pageIndex++;
      updateIndex();
      notifyListeners();
      return;
    }
    if (lastDoc == null) {
      return;
    }
    isInProgress = true;
    notifyListeners();
    QuerySnapshot snapshot =
        await getQuery().startAfterDocument(lastDoc!).limit(pageSize).get();
    if (snapshot.size > 0) {
      lastDoc = snapshot.docs.last;
      for (var doc in snapshot.docs) {
        switch (doc['type']) {
          case WarehouseNotesType.import:
          case WarehouseNotesType.importBalance:
            data.add(WarehouseNoteImport.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.export:
          case WarehouseNotesType.exportBalance:
            data.add(WarehouseNoteExport.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.transfer:
            data.add(WarehouseNoteTransfer.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.liquidation:
            data.add(WarehouseNoteLiquidation.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.lost:
            data.add(WarehouseNoteLost.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.returnToSupplier:
            data.add(WarehouseNoteReturn.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.inventoryCheck:
            data.add(WarehouseNoteCheck.fromDocumentSnapshot(doc));
            break;
          default:
            print('Wrong type: $noteType');
            break;
        }
      }
    } else {
      lastDoc = null;
    }
    if (data.length > (pageIndex * pageSize + pageSize)) {
      pageIndex++;
      updateIndex();
    }
    isInProgress = false;
    notifyListeners();
  }

  void previousPage() {
    if (pageIndex == 0) return;
    --pageIndex;
    if (pageIndex < 0) pageIndex = 0;
    updateIndex();
    notifyListeners();
  }

  void setStartDate(DateTime? newStart) {
    if (newStart != null && (startDate?.isAtSameMomentAs(newStart) ?? false)) {
      return;
    }
    startDate = newStart;
    notifyListeners();
  }

  void setEndDate(DateTime? newEnd) {
    if (newEnd != null && (endDate?.isAtSameMomentAs(newEnd) ?? false)) {
      return;
    }
    endDate = newEnd;
    notifyListeners();
  }

  void initProperties(String value) {
    data.clear();
    noteType = [];
    pageIndex = 0;
    lastDoc = null;
    showMoreExcelOption = false;
    noteType!.add(value);
    if (value == WarehouseNotesType.import ||
        value == WarehouseNotesType.export) {
      noteType!.add(WarehouseNotesType.returnToSupplier);
      if (value == WarehouseNotesType.import) {
        noteType!.add(WarehouseNotesType.importBalance);
        importType = UITitleCode.ALL;
        hasCostFilter = UITitleCode.ALL;
      } else {
        noteType!.add(WarehouseNotesType.exportBalance);
        exportType = UITitleCode.ALL;
      }
    }
    getWarehouseNotes();
  }

  void setQueryString(String newQuery) {
    if (queryString.text == newQuery) return;
    queryString = TextEditingController(text: newQuery);
    queryString.selection = TextSelection.fromPosition(
        TextPosition(offset: queryString.text.length));
    notifyListeners();
  }

  void setImportType(String newType) {
    String tempType = NoteTypesUlti.getTypes().firstWhere(
      (element) => UITitleUtil.getTitleByCode(element) == newType,
      orElse: () => UITitleCode.ALL,
    );
    if (tempType == importType) return;
    importType = tempType;
    notifyListeners();
  }

  void sethasCostFilter(String newType) {
    String tempType = NoteCostTypesUlti.getCostTypes().firstWhere(
      (element) => UITitleUtil.getTitleByCode(element) == newType,
      orElse: () => UITitleCode.ALL,
    );
    if (tempType == hasCostFilter) return;
    hasCostFilter = tempType;
    notifyListeners();
  }

  void setExportType(String newType) {
    String tempType = NoteTypesUlti.getTypes().firstWhere(
      (element) => UITitleUtil.getTitleByCode(element) == newType,
      orElse: () => UITitleCode.ALL,
    );
    if (tempType == exportType) return;
    exportType = tempType;
    notifyListeners();
  }

  Iterable<WarehouseNote> filterData() {
    return data.sublist(startIndex!, endIndex);
  }

  Iterable<WarehouseNote> exportFilter() {
    Iterable<WarehouseNote> result = filterData();
    if (noteType![0] == WarehouseNotesType.export) {
      result = result.where((note) => noteType!.contains(note.type));
      if (exportType == NoteTypesUlti.EXPORT) {
        result = result
            .where((element) => element.type == WarehouseNotesType.export);
      }
      if (exportType == NoteTypesUlti.BALANCE) {
        result = result.where(
            (element) => element.type == WarehouseNotesType.exportBalance);
      }
      if (exportType == NoteTypesUlti.RETURN) {
        result = result.whereType<WarehouseNoteReturn>();
      }
    }
    return result;
  }

  Iterable<WarehouseNote> importFilter() {
    Iterable<WarehouseNote> result = filterData();
    if (noteType![0] == WarehouseNotesType.import) {
      result = result.where(
          (note) => note.type == noteType![0] || note.type == noteType![2]);
      if (importType == NoteTypesUlti.COMPENSATION) {
        result = result.whereType<WarehouseNoteImport>().where((element) =>
            (element.returnInvoiceNum != '') &&
            element.type != WarehouseNotesType.importBalance);
      }
      if (importType == NoteTypesUlti.IMPORT) {
        result = result.whereType<WarehouseNoteImport>().where((element) =>
            (element.returnInvoiceNum == null ||
                element.returnInvoiceNum == '') &&
            element.type != WarehouseNotesType.importBalance);
      }
      if (importType == NoteTypesUlti.BALANCE) {
        result = result.whereType<WarehouseNoteImport>().where(
            (element) => element.type == WarehouseNotesType.importBalance);
      }
      if (hasCostFilter == NoteCostTypesUlti.COST) {
        result = result.whereType<WarehouseNoteImport>().where(
            (element) => (element.totalCost != 0 && element.totalCost != null));
      }
      if (hasCostFilter == NoteCostTypesUlti.NOCOST) {
        result = result.whereType<WarehouseNoteImport>().where(
            (element) => (element.totalCost == null || element.totalCost == 0));
      }
    }
    return result;
  }

  void exportWarehouseNoteDataToExcel() async {
    List<WarehouseNote> dataWarehouseNote = [];
    QuerySnapshot snapshot = await getQuery().get();
    if (snapshot.size > 0) {
      for (var doc in snapshot.docs) {
        final type = (doc.data() as Map<String, dynamic>)['type'];
        switch (type) {
          case WarehouseNotesType.import:
            dataWarehouseNote
                .add(WarehouseNoteImport.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.export:
            dataWarehouseNote
                .add(WarehouseNoteExport.fromDocumentSnapshot(doc));

            break;
          case WarehouseNotesType.transfer:
            dataWarehouseNote
                .add(WarehouseNoteTransfer.fromDocumentSnapshot(doc));

            break;
          case WarehouseNotesType.liquidation:
            dataWarehouseNote
                .add(WarehouseNoteLiquidation.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.lost:
            dataWarehouseNote.add(WarehouseNoteLost.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.returnToSupplier:
            dataWarehouseNote
                .add(WarehouseNoteReturn.fromDocumentSnapshot(doc));
            break;
          case WarehouseNotesType.inventoryCheck:
            dataWarehouseNote.add(WarehouseNoteCheck.fromDocumentSnapshot(doc));
            break;
        }
      }
      switch (noteType![0]) {
        case WarehouseNotesType.import:
          ExcelUlti.exporteImportItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;
        case WarehouseNotesType.export:
          ExcelUlti.exportExporteItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;
        case WarehouseNotesType.liquidation:
          ExcelUlti.exportLiquidationItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;
        case WarehouseNotesType.transfer:
          ExcelUlti.exportTransferItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;

        case WarehouseNotesType.lost:
          ExcelUlti.exportLostItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;
        case WarehouseNotesType.inventoryCheck:
          ExcelUlti.exportCheckItemWareHouse(
              dataWarehouseNote, startDate, endDate);
          break;
      }
    }
  }

  Future<Map<String, dynamic>?>? readExcelFile(
      String noteType, FilePickerResult pickedFile) async {
    isInProgress = true;
    notifyListeners();
    Map<String, dynamic>? readFileResult =
        ExcelUlti.readWarehousetNoteFromExcelFile(pickedFile, noteType);

    isInProgress = false;
    notifyListeners();
    return readFileResult;
  }

  void changeShowOption(bool isShow) {
    showMoreExcelOption = isShow;

    notifyListeners();
  }

  Future<bool> checkCostByImportInvoiceNumber(
      String invoiceNumber, double total) async {
    List<Accounting> accountings =
        await getCostByImportInvoiceNumber(invoiceNumber);
    if (accountings.isEmpty) return true;
    double totalCost = 0;
    for (var accounting in accountings) {
      totalCost += accounting.amount!;
    }
    if (totalCost > total) {
      return false;
    }
    return true;
  }

  Future<List<Accounting>> getCostByImportInvoiceNumber(
      String importNote) async {
    List<Accounting> accountings = [];
    QuerySnapshot snapshot = await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .where('invoice_num', isEqualTo: importNote)
        .get();
    if (snapshot.docs.isEmpty) return accountings;
    for (var doc in snapshot.docs) {
      accountings.add(Accounting.fromDocumentData(doc));
    }
    return accountings;
  }

  String checkCreatePermission(
      Map<String, String> warehouseActions, DateTime createTime) {
    if (GeneralManager.hotel!.financialDate != null &&
        GeneralManager.hotel!.financialDate!.isAfter(createTime) &&
        noteType![0] == WarehouseNotesType.import) {
      return MessageCodeUtil
          .NOT_ALLOWED_TO_CREATE_BEFORE_THE_FINANCIAL_CLOSING_DATE;
    }
    if (!UserManager.canCRUDWarehouseNote()) {
      for (var entry in warehouseActions.entries) {
        Warehouse warehouse = WarehouseManager().getWarehouseById(entry.key)!;
        if (entry.value == WarehouseActionType.BOTH) {
          if (!warehouse.permission!.roleImport!
              .contains(UserManager.user!.id)) {
            return MessageCodeUtil.FORBIDDEN;
          }
          if (!warehouse.permission!.roleExport!
              .contains(UserManager.user!.id)) {
            return MessageCodeUtil.FORBIDDEN;
          }
        } else {
          if (entry.value == WarehouseActionType.IMPORT) {
            if (!warehouse.permission!.roleImport!
                .contains(UserManager.user!.id)) {
              return MessageCodeUtil.FORBIDDEN;
            }
          }
          if (entry.value == WarehouseActionType.EXPORT) {
            if (!warehouse.permission!.roleExport!
                .contains(UserManager.user!.id)) {
              return MessageCodeUtil.FORBIDDEN;
            }
          }
        }
      }
    }

    return MessageCodeUtil.SUCCESS;
  }

  String checkModifyPermission(WarehouseNote warehouseNote) {
    if (GeneralManager.hotel!.financialDate != null &&
        warehouseNote.actualCreated != null &&
        GeneralManager.hotel!.financialDate!
            .isAfter(warehouseNote.createdTime!)) {
      return MessageCodeUtil
          .NOT_ALLOWED_TO_BE_MODIFIED_PRIOR_TO_THE_FINANCIAL_CLOSING_DATE;
    }
    if (UserManager.canCRUDWarehouseNote()) {
      if (warehouseNote.actualCreated == null) {
        if (now
            .subtract(const Duration(days: 45))
            .isAfter(warehouseNote.createdTime!)) {
          return MessageCodeUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS;
        }
      } else {
        if (now
            .subtract(const Duration(days: 45))
            .isAfter(warehouseNote.actualCreated!)) {
          return MessageCodeUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS;
        }
      }
    } else {
      if (warehouseNote.creator != UserManager.user!.email) {
        return MessageCodeUtil.USER_NOT_BE_AUTHORIZED;
      }
      if (warehouseNote.actualCreated == null
          ? true
          : now
                  .subtract(const Duration(hours: 24))
                  .compareTo(warehouseNote.actualCreated!) >
              0) {
        return MessageCodeUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_24H;
      }
    }
    return MessageCodeUtil.SUCCESS;
  }

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void checkSearch() {
    isSearchByInvoice = !isSearchByInvoice;
    notifyListeners();
  }

  String getRemainCostOfImportNote(double total) {
    for (var cost in listAccounting) {
      total -= cost.amount!;
    }
    return total.toString();
  }

  void addCostForImportNote(Accounting cost, WarehouseNoteImport importNote) {
    listAccounting.add(cost);
    if (importNote.totalCost != null) {
      importNote.totalCost = importNote.totalCost! + cost.amount!;
    } else {
      importNote.totalCost = cost.amount;
    }
    notifyListeners();
  }

  // just use for inventory checking
  void setStatus(String newStatus) {
    String statusCode = InventorySatus.getInventoryCheckNoteStatus().firstWhere(
      (element) => UITitleUtil.getTitleByCode(element) == newStatus,
      orElse: () => UITitleCode.ALL,
    );

    if (statusCode == status) return;
    status = statusCode;
    notifyListeners();
  }
}
