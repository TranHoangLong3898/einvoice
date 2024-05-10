import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/booking/checkoutcontroller.dart';
import 'package:ihotel/controller/dashboardmuchhotels/dailydatabyhotelscontroller.dart';
import 'package:ihotel/controller/report/revenuebyroomcontroller.dart';
import 'package:ihotel/controller/warehouse/importcontroller.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/itemmanager.dart';
import 'package:ihotel/manager/othermanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/roomtypemanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/manager/warehousemanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/dailydata.dart';
import 'package:ihotel/modal/guest_report.dart';
import 'package:ihotel/modal/hotelservice/itemrestaurant.dart';
import 'package:ihotel/modal/service/deposit.dart';
import 'package:ihotel/modal/warehouse/inventory/warehousechecknote.dart';
import 'package:ihotel/modal/warehouse/warehouse.dart';
import 'package:ihotel/modal/warehouse/warehouseexport/warehousenoteexport.dart';
import 'package:ihotel/modal/warehouse/warehouseimport/itemimport.dart';
import 'package:ihotel/modal/warehouse/warehouseimport/warehousenoteimport.dart';
import 'package:ihotel/modal/warehouse/warehouseliquidation/warehousenoteliquidation.dart';
import 'package:ihotel/modal/warehouse/warehouselost/warehousenotelost.dart';
import 'package:ihotel/modal/warehouse/warehousenote.dart';
import 'package:ihotel/modal/warehouse/warehousereturn/warehousenotereturn.dart';
import 'package:ihotel/modal/warehouse/warehousetransfer/warehousenotetransfer.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:ihotel/util/unitulti.dart';
import 'package:ihotel/util/warehouseutil.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/booking/groupcontroller.dart';
import '../controller/housekeeping/housekeepingcontroller.dart';
import '../controller/management/statistic_controller.dart';
import '../controller/report/bookinglistcontroller.dart';
import '../manager/configurationmanagement.dart';
import '../manager/minibarmanager.dart';
import '../manager/paymentmethodmanager.dart';
import '../manager/sourcemanager.dart';
import '../manager/systemmanagement.dart';
import '../modal/accounting/actualpayment.dart';
import '../modal/group.dart';
import '../modal/revenue_logs/revenue_log.dart';
import '../modal/room.dart';
import '../modal/service/service.dart';
import '../modal/status.dart';
import '../modal/staydeclaration/staydeclaration.dart';
import '../modal/tax.dart';
import '../ui/component/management/revenue_management/check_revenue_logs_controller.dart';

class ExcelUlti {
  static Future<void> exportGuest(List<StayDeclaration> guests) async {
    if (guests.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_GuestDeclaration_${DateUtil.dateToShortString(DateTime.now())}.xlsx";
    final excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;
    // write data
    int row = 1;
    for (var guest in guests) {
      defaultSheet.insertRowIterables([
        row,
        guest.name,
        DateUtil.dateToString(guest.dateOfBirth!),
        guest.gender,
        guest.nationalId,
        guest.passport,
        guest.otherDocId,
        "",
        "",
        "",
        "",
        guest.nationality,
        guest.nationalAddress,
        guest.cityAddress,
        guest.districtAddress,
        guest.communeAddress,
        guest.detailAddress,
        guest.stayType,
        DateUtil.dateToString(guest.inDate!),
        DateUtil.dateToString(guest.outDate!),
        guest.reason,
        RoomManager().getNameRoomById(guest.roomId!)
      ], row++ + 1);
    }
    launchUrlString(
        "https://dichvucong.dancuquocgia.gov.vn/portal/upload/UploadServlet?getfile=thongbaoluutru.xlsm&fileid=cb631df0cfdf4158882f4cf435be9726&csrt=569743380435929872");
    excel.save(fileName: excelName);
  }

  static void exportPaymentManagement(List<Deposit> deposits,
      Map<String, dynamic> dataPayment, DateTime start, DateTime end) {
    String excelName;
    excelName =
        "OnePMS_PaymentManagement_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    ///content right
    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "ID";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Tên";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Mô tả";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Phòng";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Ngày in";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Ngày out";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Trạng thái";
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        "Phương thức thanh toán";
    defaultSheet.cell(CellIndex.indexByString("J1")).value = "Nguồn";
    defaultSheet.cell(CellIndex.indexByString("K1")).value = "Số tiền";
    defaultSheet.cell(CellIndex.indexByString("L1")).value =
        "Ngày thanh toán thực tế";
    defaultSheet.cell(CellIndex.indexByString("M1")).value = "Số tiền thực tế";
    defaultSheet.cell(CellIndex.indexByString("N1")).value = "Số tham chiếu";
    defaultSheet.cell(CellIndex.indexByString("O1")).value = "Ngày tham chiếu";
    defaultSheet.cell(CellIndex.indexByString("P1")).value = "Ghi chú";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Left,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 16; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    num totalMoney = 0;
    for (var deposit
        in deposits.where((element) => element.method != "transfer")) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(deposit.created!.toDate()),
        deposit.sID,
        deposit.name,
        deposit.desc,
        RoomManager().getNameRoomById(deposit.room!),
        DateUtil.dateToDayMonthString(deposit.inDate!),
        DateUtil.dateToDayMonthString(deposit.outDate!),
        deposit.status,
        PaymentMethodManager().getPaymentMethodNameById(deposit.method!),
        SourceManager().getSourceNameByID(deposit.sourceID!),
        deposit.amount,
        deposit.confirmDate != null
            ? DateUtil.dateToDayMonthYearString(deposit.confirmDate!)
            : "#",
        deposit.actualAmount,
        deposit.referenceNumber,
        deposit.referencDate != null
            ? DateUtil.dateToDayMonthYearString(deposit.referencDate!)
            : "#",
        deposit.note,
      ], defaultSheet.maxRows);
      if (deposit.method != PaymentMethodManager.transferMethodID) {
        totalMoney += deposit.amount!;
      }
    }

    int indexOfMaxRow = defaultSheet.maxRows;
    //total row
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
    Data totalTitleCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
    totalTitleCell.value = "Tổng cộng";
    totalTitleCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
    Data totalAmountCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow));
    totalAmountCell.value = totalMoney;
    totalAmountCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    ///content left
    ///
    defaultSheet.merge(
        CellIndex.indexByString("S1"), CellIndex.indexByString("T2"));
    defaultSheet.cell(CellIndex.indexByString("S1")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_PAYMENT_METHOD_REPORT_DETAIL);
    defaultSheet.cell(CellIndex.indexByString("S1")).cellStyle = CellStyle(
        fontSize: 13,
        bold: true,
        backgroundColorHex: "ff59b69e",
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.cell(CellIndex.indexByString("S3")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
    defaultSheet.cell(CellIndex.indexByString("S3")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("T3")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY);
    defaultSheet.cell(CellIndex.indexByString("T3")).cellStyle =
        headerCellStyle;

    MapEntry<String, dynamic> dataDeb =
        dataPayment.entries.where((element) => element.key == "de").first;
    num totalMoneys = 0;
    num i = 4;
    for (var data in dataPayment.entries
        .where((element) => element.key != "de" && element.value != 0)) {
      defaultSheet.cell(CellIndex.indexByString("S$i")).value =
          PaymentMethodManager().getPaymentMethodNameById(data.key);
      defaultSheet.cell(CellIndex.indexByString("S$i")).cellStyle =
          contentCellStyle;

      defaultSheet.cell(CellIndex.indexByString("T$i")).value = data.value;
      defaultSheet.cell(CellIndex.indexByString("T$i")).cellStyle =
          contentCellStyle;
      totalMoneys += data.value;
      i++;
    }

    defaultSheet.cell(CellIndex.indexByString("S$i")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL);
    defaultSheet.cell(CellIndex.indexByString("S$i ")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.cell(CellIndex.indexByString("T$i")).value = totalMoneys;
    defaultSheet.cell(CellIndex.indexByString("T$i")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "#FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(CellIndex.indexByString("S${i + 3}"),
        CellIndex.indexByString("T${i + 3}"));
    defaultSheet.cell(CellIndex.indexByString("S${i + 3}")).value = "Ghi nợ";
    defaultSheet.cell(CellIndex.indexByString("S${i + 3}")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("S${i + 4}")).value =
        PaymentMethodManager().getPaymentMethodNameById(dataDeb.key);
    defaultSheet.cell(CellIndex.indexByString("S${i + 4}")).cellStyle =
        contentCellStyle;

    defaultSheet.cell(CellIndex.indexByString("T${i + 4}")).value =
        dataDeb.value;
    defaultSheet.cell(CellIndex.indexByString("T${i + 4}")).cellStyle =
        contentCellStyle;

    //save
    excel.save(fileName: excelName);
  }

  static void exportRevenue(List<Booking> bookings, Set<String> setMethod,
      DateTime startDate, DateTime endDate) {
    if (bookings.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_Revenue_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Nguồn";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Sid";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Tên";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Phòng";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Hạng phòng";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Ngày in";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Ngày out";
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Số đêm";
    defaultSheet.cell(CellIndex.indexByString("J1")).value = "Tiền phòng";
    defaultSheet.cell(CellIndex.indexByString("K1")).value = "Minibar";
    defaultSheet.cell(CellIndex.indexByString("L1")).value = "Phụ thu giờ";
    defaultSheet.cell(CellIndex.indexByString("M1")).value = "Phụ thu khách";
    defaultSheet.cell(CellIndex.indexByString("N1")).value = "Giặt ủi";
    defaultSheet.cell(CellIndex.indexByString("O1")).value = "Thuê xe";
    defaultSheet.cell(CellIndex.indexByString("P1")).value = "Dịch vụ khác";
    defaultSheet.cell(CellIndex.indexByString("Q1")).value = "Nhà hàng độc lập";
    defaultSheet.cell(CellIndex.indexByString("R1")).value = "Trong nhà hàng";
    defaultSheet.cell(CellIndex.indexByString("S1")).value = "Điện";
    defaultSheet.cell(CellIndex.indexByString("T1")).value = "Nước";
    defaultSheet.cell(CellIndex.indexByString("U1")).value = "Tổng tiền";
    defaultSheet.cell(CellIndex.indexByString("V1")).value = "Giảm giá";
    defaultSheet.cell(CellIndex.indexByString("W1")).value = "Doanh thu";
    defaultSheet.cell(CellIndex.indexByString("X1")).value = "Saler";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 24; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalMoney = 0;
    num totalRevenueNoDiscount = 0;
    num totalDiscount = 0;
    int columnIndex = 23;
    for (var element in setMethod) {
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0))
          .value = element;
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0))
          .cellStyle = titleCellStyle;
      columnIndex++;
    }
    for (var booking in bookings) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(booking.outTime!),
        booking.sourceName,
        booking.sID ?? '',
        booking.name,
        booking.group!
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        booking.group!
            ? booking.roomTypeID
            : RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        booking.lengthStay,
        booking.getRoomCharge(),
        booking.minibar,
        booking.extraHour!.total,
        booking.extraGuest,
        booking.laundry,
        booking.bikeRental,
        booking.other,
        booking.outsideRestaurant,
        booking.insideRestaurant,
        booking.electricity,
        booking.water,
        booking.getRevenueNotDiscout(),
        -booking.discount!,
        booking.getRevenue(),
        booking.saler,
        for (var data in setMethod) booking.getPaymentDetail()[data] ?? 0,
      ], defaultSheet.maxRows);
      isExcelFileHasData = true;
      totalMoney += booking.getRevenue();
      totalRevenueNoDiscount += booking.getRevenueNotDiscout();
      totalDiscount += booking.discount!;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;

      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng doanh thu";
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRevenueNoDiscountTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: indexOfMaxRow));
      totalRevenueNoDiscountTitleCell.value = totalRevenueNoDiscount;
      totalRevenueNoDiscountTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalDiscountTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 21, rowIndex: indexOfMaxRow));
      totalDiscountTitleCell.value = -totalDiscount;
      totalDiscountTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAmountCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 22, rowIndex: indexOfMaxRow));
      totalAmountCell.value = totalMoney;
      totalAmountCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportReprotBooking(List<Booking> bookings, Set<String> setMethod,
      Set<String> dataSetTypeCost, DateTime startDate, DateTime endDate) {
    if (bookings.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_Revenue_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Nguồn";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Sid";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Tên";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Phòng";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Hạng phòng";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Ngày in";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Ngày out";
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Số đêm";
    defaultSheet.cell(CellIndex.indexByString("J1")).value = "Tiền phòng";
    defaultSheet.cell(CellIndex.indexByString("K1")).value = "Minibar";
    defaultSheet.cell(CellIndex.indexByString("L1")).value = "Phụ thu giờ";
    defaultSheet.cell(CellIndex.indexByString("M1")).value = "Phụ thu khách";
    defaultSheet.cell(CellIndex.indexByString("N1")).value = "Giặt ủi";
    defaultSheet.cell(CellIndex.indexByString("O1")).value = "Thuê xe";
    defaultSheet.cell(CellIndex.indexByString("P1")).value = "Dịch vụ khác";
    defaultSheet.cell(CellIndex.indexByString("Q1")).value = "Nhà hàng độc lập";
    defaultSheet.cell(CellIndex.indexByString("R1")).value = "Trong nhà hàng";
    defaultSheet.cell(CellIndex.indexByString("S1")).value = "Tổng tiền";
    defaultSheet.cell(CellIndex.indexByString("T1")).value = "Giảm giá";
    defaultSheet.cell(CellIndex.indexByString("U1")).value = "Doanh thu";
    defaultSheet.cell(CellIndex.indexByString("V1")).value = "Chi phí";
    defaultSheet.cell(CellIndex.indexByString("W1")).value = "Saler";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    for (int i = 0; i < 23; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalMoney = 0;
    num totalRevenueNoDiscount = 0;
    num totalDiscount = 0;
    int columnIndex = 24;
    for (var element in setMethod) {
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0))
          .value = element;
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0))
          .cellStyle = titleCellStyle;
      columnIndex++;
    }
    int columnIndexCost = columnIndex + 1;
    for (var element in dataSetTypeCost) {
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .value = element;
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .cellStyle = titleCellStyle;
      columnIndexCost++;
    }
    Map<String, num> mapCost = {};
    for (var booking in bookings) {
      for (var key in booking.getTotalCostByTypeCost().keys) {
        if (mapCost.containsKey(key)) {
          mapCost[key] = mapCost[key]! + booking.getTotalCostByTypeCost()[key]!;
        } else {
          mapCost[key] = booking.getTotalCostByTypeCost()[key]!;
        }
      }
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(booking.outTime!),
        booking.sourceName,
        booking.sID ?? '',
        booking.name,
        booking.group!
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        booking.group!
            ? booking.roomTypeID
            : RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        booking.lengthStay,
        booking.getRoomCharge(),
        booking.minibar,
        booking.extraHour!.total,
        booking.extraGuest,
        booking.laundry,
        booking.bikeRental,
        booking.other,
        booking.outsideRestaurant,
        booking.insideRestaurant,
        booking.getRevenueNotDiscout(),
        -booking.discount!,
        booking.getRevenue(),
        booking.getTotalAmountCost(),
        booking.saler,
        "",
        for (var data in setMethod) booking.getPaymentDetail()[data] ?? 0,
        "",
        for (var data in dataSetTypeCost) booking.getDetailCost()[data] ?? 0,
      ], defaultSheet.maxRows);
      isExcelFileHasData = true;
      totalMoney += booking.getRevenue();
      totalRevenueNoDiscount += booking.getRevenueNotDiscout();
      totalDiscount += booking.discount!;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;

      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng doanh thu";
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRevenueNoDiscountTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: indexOfMaxRow));
      totalRevenueNoDiscountTitleCell.value = totalRevenueNoDiscount;
      totalRevenueNoDiscountTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalDiscountTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 19, rowIndex: indexOfMaxRow));
      totalDiscountTitleCell.value = -totalDiscount;
      totalDiscountTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAmountCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 20, rowIndex: indexOfMaxRow));
      totalAmountCell.value = totalMoney;
      totalAmountCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      int columnIndexTotalCost = columnIndex + 1;
      for (var element in dataSetTypeCost) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexTotalCost, rowIndex: indexOfMaxRow))
            .value = mapCost[element];
        defaultSheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnIndexTotalCost, rowIndex: indexOfMaxRow))
                .cellStyle =
            CellStyle(
                bold: true,
                italic: false,
                verticalAlign: VerticalAlign.Center,
                horizontalAlign: HorizontalAlign.Right,
                fontSize: 14,
                fontFamily: getFontFamily(FontFamily.Arial));
        columnIndexTotalCost++;
      }

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportBookingSearch(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return;
    }
    String excelName = "OnePMS_Booking_Search.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_GUEST_DECLARE_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("J1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("L1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 12; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalMoney = 0;
    num totalRemaning = 0;
    for (var booking in bookings) {
      defaultSheet.insertRowIterables([
        booking.sourceName,
        booking.name,
        booking.group!
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        booking.declareGuests?.length ?? 0,
        booking.deposit,
        booking.getRoomCharge(),
        booking.getServiceCharge(),
        booking.discount == 0
            ? "0"
            : "-${NumberUtil.numberFormat.format(booking.discount)}",
        booking.getTotalCharge(),
        booking.getRemaining(),
      ], defaultSheet.maxRows);
      isExcelFileHasData = true;
      totalMoney += booking.getTotalCharge()!;
      totalRemaning += booking.getRemaining()!;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng";
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAmountCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
      totalAmountCell.value = totalMoney;
      totalAmountCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRemaingCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: indexOfMaxRow));
      totalRemaingCell.value = totalRemaning;
      totalRemaingCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportBookingGroup(GroupController controller) {
    if (controller.bookings.isEmpty) {
      return;
    }
    String excelName = "OnePMS_Booking_Group.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("J1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRANSFERRED_GROUP);
    defaultSheet.cell(CellIndex.indexByString("L1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TRANSFERRING_GROUP);
    defaultSheet.cell(CellIndex.indexByString("M1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("N1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 14; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data

    bool isExcelFileHasData = false;
    num i = 1;
    String sid = '';
    controller.bookings.sort((a, b) => a.room!.compareTo(b.room!));
    for (var booking in controller.bookings) {
      defaultSheet.insertRowIterables([
        "",
        booking.name,
        RoomManager().getNameRoomById(booking.room!),
        BookingStatus.getStatusString(booking.status!),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        NumberUtil.numberFormat.format(booking.deposit),
        NumberUtil.numberFormat.format(booking.getRoomCharge()),
        NumberUtil.numberFormat.format(booking.getServiceCharge()),
        booking.discount == 0
            ? "0"
            : "-${NumberUtil.numberFormat.format(booking.discount)}",
        NumberUtil.numberFormat.format(booking.transferred),
        NumberUtil.numberFormat.format(booking.transferring),
        NumberUtil.numberFormat.format(booking.getTotalCharge()),
        NumberUtil.numberFormat.format(booking.getRemaining())
      ], defaultSheet.maxRows);
      isExcelFileHasData = true;
      sid = booking.sID!;
      i++;
    }
    defaultSheet.merge(
        CellIndex.indexByString("A2"), CellIndex.indexByString("A$i"),
        customValue: 4);
    defaultSheet.cell(CellIndex.indexByString("A2")).value = sid;
    // defaultSheet.setColWidth(
    //     defaultSheet.cell(CellIndex.indexByString("A2")).colIndex, 30);
    defaultSheet.cell(CellIndex.indexByString("A2")).cellStyle = CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng";
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalDepositCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow));
      totalDepositCell.value =
          NumberUtil.numberFormat.format(controller.getTotalDeposit());
      totalDepositCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRomChargeCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
      totalRomChargeCell.value =
          NumberUtil.numberFormat.format(controller.getTotalRoomCharge());
      totalRomChargeCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalServiceCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: indexOfMaxRow));
      totalServiceCell.value =
          NumberUtil.numberFormat.format(controller.getTotalService());
      totalServiceCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalDiscountCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow));
      totalDiscountCell.value =
          NumberUtil.numberFormat.format(controller.getTotalDiscount());
      totalDiscountCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalTranfferredCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
      totalTranfferredCell.value =
          NumberUtil.numberFormat.format(controller.getTotalTranfferred());
      totalTranfferredCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalTransfferringCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: indexOfMaxRow));
      totalTransfferringCell.value =
          NumberUtil.numberFormat.format(controller.getTotalTransfferring());
      totalTransfferringCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalChargeCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: indexOfMaxRow));
      totalChargeCell.value =
          NumberUtil.numberFormat.format(controller.getTotalCharge());
      totalChargeCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRemaingCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: indexOfMaxRow));
      totalRemaingCell.value =
          NumberUtil.numberFormat.format(controller.getTotalRemaining());
      totalRemaingCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportInOutStayingBooking(BookingListController controller) {
    if (controller.bookings.isEmpty) return;
    String excelName = "OnePMS_${controller.getTitle()}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_GUEST_DECLARE_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("J1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("L1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("M1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("N1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("O1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
    defaultSheet.cell(CellIndex.indexByString("P1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 16; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalRoomCharge = 0;
    num totalDeposit = 0;
    num totalRemaining = 0;
    num totalCharge = 0;
    for (var booking in controller.bookings) {
      defaultSheet.insertRowIterables([
        SourceManager().getSourceNameByID(booking.sourceID!),
        booking.name,
        booking.sID == booking.id
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        booking.sID == booking.id
            ? booking.roomTypeID
            : RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID!),
        booking.sID == booking.id
            ? controller.mapBreakFast![booking.sID]
            : booking.breakfast!
                ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YES)
                : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NO),
        booking.sID == booking.id
            ? booking.adult
            : (booking.adult! + booking.child!),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        NumberUtil.numberFormat.format(booking.declareGuests?.length ?? 0),
        NumberUtil.numberFormat.format(booking.deposit),
        NumberUtil.numberFormat.format(booking.getRoomCharge()),
        NumberUtil.numberFormat.format(booking.getServiceCharge()),
        booking.discount == 0
            ? "0"
            : "-${NumberUtil.numberFormat.format(booking.discount)}",
        NumberUtil.numberFormat.format(booking.getTotalCharge()),
        NumberUtil.numberFormat.format(booking.getRemaining()),
        controller.mapNotes[booking.sID] ?? ""
      ], defaultSheet.maxRows);

      totalDeposit += booking.deposit!;
      totalRemaining += booking.getRemaining()!;
      totalCharge += booking.getTotalCharge()!;
      totalRoomCharge += booking.getRoomCharge();
      isExcelFileHasData = true;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng";
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalDepositCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow));
      totalDepositCell.value = NumberUtil.numberFormat.format(totalDeposit);
      totalDepositCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRoomChargeCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
      totalRoomChargeCell.value =
          NumberUtil.numberFormat.format(totalRoomCharge);
      totalRoomChargeCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalChargeCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: indexOfMaxRow));
      totalChargeCell.value = NumberUtil.numberFormat.format(totalCharge);
      totalChargeCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalRemainingCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: indexOfMaxRow));
      totalRemainingCell.value = NumberUtil.numberFormat.format(totalRemaining);
      totalRemainingCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportRevenueStatistic(StatisticController statisticController) {
    if (statisticController.displayData.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_${statisticController.selectedType}_Statistic_${DateUtil.dateToShortString(statisticController.startDate!)}_${DateUtil.dateToShortString(statisticController.endDate!)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    String headerColorHex = "ff59b69e";

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    // //title for sheets
    CellStyle titelCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        "${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REPORT)} ${statisticController.selectedType}";
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 15,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("C4"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        "Từ: ${DateUtil.dateToDayMonthYearString(statisticController.startDate)} - Đến: ${DateUtil.dateToDayMonthYearString(statisticController.endDate)}";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A5"), CellIndex.indexByString("B5"));
    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("C5"), CellIndex.indexByString("C5"));
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        statisticController.selectedType ==
                MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)
            ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMBER)
            : UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //write data
    bool isExcelFileHasData = false;
    num totalMoney = 0;
    double roomCharge, service, liquidation, discount, child, adult = 0;
    double total = 0;
    num i = 6;
    for (var data in statisticController.displayData) {
      if (statisticController.selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_REVENUE)) {
        roomCharge = data.getRevenueRoomCharge().toDouble();
        service = data.getRevenueService().toDouble();
        liquidation = data.getRevenueLiquidation().toDouble();
        discount = data.getRevenueDiscount().toDouble();
        total = roomCharge + service + liquidation - discount;
      } else if (statisticController.selectedType ==
          MessageUtil.getMessageByCode(
              MessageCodeUtil.STATISTIC_REVENUE_BY_DATE)) {
        roomCharge = data.roomCharge.toDouble();
        service = data.totalService.toDouble();
        liquidation = data.getRevenueLiquidation().toDouble();
        discount = data.discount.toDouble();
        total = roomCharge + service + liquidation - discount;
      } else if (statisticController.selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST)) {
        adult = data.getGuestAdult().toDouble();
        child = data.getGuestChild().toDouble();
        total = adult + child;
      } else if (statisticController.selectedType ==
          MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_ROOM_CHARGE)) {
        total = data
            .getRoomChargeOrNight(
                methodType: statisticController.selectedSubType1,
                roomTypeName: statisticController.selectedSubType2,
                sourceName: statisticController.selectedSubType3,
                roomCharge: true)
            .toDouble();
      }

      defaultSheet.merge(
          CellIndex.indexByString("A$i"), CellIndex.indexByString("B$i"));
      defaultSheet.cell(CellIndex.indexByString("A$i")).value =
          DateUtil.dateToString(data.dateFull!);
      defaultSheet.cell(CellIndex.indexByString("A$i")).cellStyle =
          titelCellStyle;
      defaultSheet.merge(
          CellIndex.indexByString("C$i"), CellIndex.indexByString("C$i"));
      defaultSheet.cell(CellIndex.indexByString("C$i")).value = total;
      defaultSheet.cell(CellIndex.indexByString("C$i")).cellStyle =
          contentCellStyle;
      isExcelFileHasData = true;
      totalMoney += total;
      i++;
    }
    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL);
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 13,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAmountCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indexOfMaxRow));
      totalAmountCell.value = totalMoney;
      totalAmountCell.cellStyle = CellStyle(
          bold: true,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 13,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportPaymentManager(
      Map<String, dynamic> dataPayment, DateTime startDate, DateTime endDate) {
    if (dataPayment.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_Payment_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    String headerColorHex = "ff59b69e";

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    // //title for sheets
    CellStyle titelCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_PAYMENT_METHOD_REPORT_DETAIL);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 15,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("C4"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        "Từ: ${DateUtil.dateToDayMonthYearString(startDate)} - Đến: ${DateUtil.dateToDayMonthYearString(endDate)}";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = CellStyle(
        fontSize: 12,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A5"), CellIndex.indexByString("B5"));
    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle =
        headerCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C5"), CellIndex.indexByString("C5"));
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle =
        headerCellStyle;

    //write data
    bool isExcelFileHasData = false;
    MapEntry<String, dynamic> dataDeb =
        dataPayment.entries.where((element) => element.key == "de").first;
    num totalMoney = 0;
    num i = 6;
    for (var data in dataPayment.entries
        .where((element) => element.key != "de" && element.value != 0)) {
      defaultSheet.merge(
          CellIndex.indexByString("A$i"), CellIndex.indexByString("B$i"));
      defaultSheet.cell(CellIndex.indexByString("A$i")).value =
          PaymentMethodManager().getPaymentMethodNameById(data.key);
      defaultSheet.cell(CellIndex.indexByString("A$i")).cellStyle =
          titelCellStyle;
      defaultSheet.merge(
          CellIndex.indexByString("C$i"), CellIndex.indexByString("C$i"));
      defaultSheet.cell(CellIndex.indexByString("C$i")).value = data.value;
      defaultSheet.cell(CellIndex.indexByString("C$i")).cellStyle =
          contentCellStyle;
      isExcelFileHasData = true;
      totalMoney += data.value;
      i++;
    }

    defaultSheet.merge(
        CellIndex.indexByString("A$i"), CellIndex.indexByString("B$i"));
    defaultSheet.cell(CellIndex.indexByString("A$i")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL);
    defaultSheet.cell(CellIndex.indexByString("A$i ")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));
    defaultSheet.merge(
        CellIndex.indexByString("C$i"), CellIndex.indexByString("C$i"));
    defaultSheet.cell(CellIndex.indexByString("C$i")).value = totalMoney;
    defaultSheet.cell(CellIndex.indexByString("C$i")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "#FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(CellIndex.indexByString("A${i + 3}"),
        CellIndex.indexByString("B${i + 3}"));
    defaultSheet.cell(CellIndex.indexByString("A${i + 3}")).value = "Ghi nợ";
    defaultSheet.cell(CellIndex.indexByString("A${i + 3}")).cellStyle =
        headerCellStyle;
    defaultSheet.merge(CellIndex.indexByString("C${i + 3}"),
        CellIndex.indexByString("C${i + 3}"));
    defaultSheet.cell(CellIndex.indexByString("C${i + 3}")).value = "";
    defaultSheet.cell(CellIndex.indexByString("C${i + 3}")).cellStyle =
        headerCellStyle;

    defaultSheet.merge(CellIndex.indexByString("A${i + 4}"),
        CellIndex.indexByString("B${i + 4}"));
    defaultSheet.cell(CellIndex.indexByString("A${i + 4}")).value =
        PaymentMethodManager().getPaymentMethodNameById(dataDeb.key);
    defaultSheet.cell(CellIndex.indexByString("A${i + 4}")).cellStyle =
        titelCellStyle;
    defaultSheet.merge(CellIndex.indexByString("C${i + 4}"),
        CellIndex.indexByString("C${i + 4}"));
    defaultSheet.cell(CellIndex.indexByString("C${i + 4}")).value =
        dataDeb.value;
    defaultSheet.cell(CellIndex.indexByString("C${i + 4}")).cellStyle =
        contentCellStyle;

    // Saving the files
    if (isExcelFileHasData) {
      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportMinibarReport(
      DateTime startDate,
      DateTime endDate,
      Map<String, int> dataMinibar,
      Map<String, Map<String, dynamic>> mapMinibar) {
    String excelName =
        "OnePMS_Sale_Minibar_Report_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    String headerColorHex = "ff59b69e";

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    // //title for sheets
    CellStyle titelCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("F3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SALE_REPORT_MINIBAR);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 15,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("F4"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        "BẢNG CHI TIẾT - Từ: ${DateUtil.dateToDayMonthYearString(startDate)} - Đến: ${DateUtil.dateToDayMonthYearString(endDate)}";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = CellStyle(
        fontSize: 12,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A5"), CellIndex.indexByString("B5"));
    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATED_TIME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("D5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("D5")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("F5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE);
    defaultSheet.cell(CellIndex.indexByString("F5")).cellStyle =
        headerCellStyle;

    int rowIndex = 6;
    int rowIndexContent = 6;
    for (var key in mapMinibar.keys) {
      defaultSheet.merge(
          CellIndex.indexByString("A$rowIndex"),
          CellIndex.indexByString(
              "B${(rowIndex + mapMinibar[key]!.length) - 1}"));
      defaultSheet.cell(CellIndex.indexByString("A$rowIndex")).value = key;
      defaultSheet.cell(CellIndex.indexByString("A$rowIndex")).cellStyle =
          titelCellStyle;
      for (var keyService in mapMinibar[key]!.keys) {
        defaultSheet.cell(CellIndex.indexByString("C$rowIndexContent")).value =
            MinibarManager().getItemNameByID(keyService.split("-")[1]);
        defaultSheet.cell(CellIndex.indexByString("D$rowIndexContent")).value =
            mapMinibar[key]?[keyService] ?? 0;
        defaultSheet.cell(CellIndex.indexByString("E$rowIndexContent")).value =
            NumberUtil.numberFormat
                .format(double.parse(keyService.split("-")[0]));
        defaultSheet.cell(CellIndex.indexByString("F$rowIndexContent")).value =
            NumberUtil.numberFormat.format(
                double.parse(keyService.split("-")[0]) *
                    mapMinibar[key]![keyService]);
        rowIndexContent++;
      }
      rowIndex = (rowIndex + mapMinibar[key]!.length) - 1;
      rowIndex++;
    }

    bool isExcelFileHasData = true;
    num totalMoney = 0;
    num iTitle = rowIndex + 3;
    defaultSheet.merge(CellIndex.indexByString("A$iTitle"),
        CellIndex.indexByString("F$iTitle"));
    defaultSheet.cell(CellIndex.indexByString("A$iTitle")).value =
        "BẢNG TỔNG HỢP";
    defaultSheet.cell(CellIndex.indexByString("A$iTitle")).cellStyle =
        CellStyle(
            fontSize: 12,
            backgroundColorHex: headerColorHex,
            fontColorHex: "ffffff",
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            textWrapping: TextWrapping.WrapText);

    ///
    num i = iTitle + 1;
    for (var key in dataMinibar.keys) {
      defaultSheet.cell(CellIndex.indexByString("C$i")).value =
          MinibarManager().getItemNameByID(key.split("-")[1]);
      defaultSheet.cell(CellIndex.indexByString("C$i")).cellStyle =
          contentCellStyle;

      defaultSheet.cell(CellIndex.indexByString("D$i")).value =
          dataMinibar[key];
      defaultSheet.cell(CellIndex.indexByString("D$i")).cellStyle =
          contentCellStyle;

      defaultSheet.cell(CellIndex.indexByString("E$i")).value =
          NumberUtil.numberFormat.format(double.parse(key.split("-")[0]));
      defaultSheet.cell(CellIndex.indexByString("E$i")).cellStyle =
          contentCellStyle;

      defaultSheet.cell(CellIndex.indexByString("F$i")).value = NumberUtil
          .numberFormat
          .format(double.parse(key.split("-")[0]) * dataMinibar[key]!);
      defaultSheet.cell(CellIndex.indexByString("F$i")).cellStyle =
          contentCellStyle;
      isExcelFileHasData = true;
      totalMoney += (double.parse(key.split("-")[0]) * dataMinibar[key]!);
      i++;
    }

    // write data
    defaultSheet.merge(
        CellIndex.indexByString("A$i"), CellIndex.indexByString("D$i"));
    defaultSheet.cell(CellIndex.indexByString("A$i")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL);
    defaultSheet.cell(CellIndex.indexByString("A$i ")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));
    defaultSheet.cell(CellIndex.indexByString("F$i")).value = totalMoney;
    defaultSheet.cell(CellIndex.indexByString("F$i")).cellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 14,
        backgroundColorHex: "#FFA500",
        fontFamily: getFontFamily(FontFamily.Arial));

    // Saving the files
    if (isExcelFileHasData) {
      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportRevenueByDateDetail(dynamic controller, bool check) {
    if (controller.rChargeTotal +
            controller.bikeRentalTotal +
            controller.extraGuestTotal +
            controller.extraHourTotal +
            controller.insideRestaurantTotal +
            controller.restaurantTotal +
            controller.minibarTotal +
            controller.laudryTotal +
            controller.otherTotal +
            controller.discountTotal +
            controller.electricityWaterTotal ==
        0) {
      return;
    }
    String excelName =
        "OnePMS_${check ? UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REVENUE_BY_DATE_REPORT_DETAI) : UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REVENUE_REPORT_DETAI)}_Detail_${DateUtil.dateToShortString(controller.startDate)}_${DateUtil.dateToShortString(controller.endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    String headerColorHex = "ff59b69e";

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    num totalOther = (controller.bikeRentalTotal +
            controller.extraHourTotal +
            controller.extraGuestTotal +
            controller.laudryTotal +
            controller.otherTotal +
            controller.minibarTotal +
            controller.electricityWaterTotal) -
        controller.discountTotal;

    num totalAll = totalOther +
        controller.rChargeTotal +
        controller.insideRestaurantTotal +
        controller.restaurantTotal;

    //title for sheets

    CellStyle titleCellStyle = CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle titleColorCellStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#9ceafd",
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle titleColorTotalCellStyle = CellStyle(
        bold: true,
        backgroundColorHex: "#ef7d04",
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 11,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("E3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value = check
        ? UITitleUtil.getTitleByCode(
            UITitleCode.TOOLTIP_REVENUE_BY_DATE_REPORT_DETAI)
        : UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_REVENUE_REPORT_DETAI);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 15,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("E4"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        "Từ: ${DateUtil.dateToDayMonthYearString(controller.startDate)} - Đến: ${DateUtil.dateToDayMonthYearString(controller.endDate)}";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A5"), CellIndex.indexByString("B5"));
    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C5"), CellIndex.indexByString("D5"));
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("E5"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PERCENT);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = titleCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.cell(CellIndex.indexByString("A6")).value =
        "---------- REVENUE ----------";
    defaultSheet.cell(CellIndex.indexByString("A6")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C6"), CellIndex.indexByString("D6"));
    defaultSheet.cell(CellIndex.indexByString("C6")).value = '';
    defaultSheet.cell(CellIndex.indexByString("C6")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("E6"));
    defaultSheet.cell(CellIndex.indexByString("E6")).value = '';
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A7"), CellIndex.indexByString("B7"));
    defaultSheet.cell(CellIndex.indexByString("A7")).value = "Room Revenue";
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C7"), CellIndex.indexByString("D7"));
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        controller.rChargeTotal;
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E7"), CellIndex.indexByString("E7"));
    defaultSheet.cell(CellIndex.indexByString("E7")).value = NumberUtil
        .numberFormat
        .format((controller.rChargeTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E7")).cellStyle =
        titleColorCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));
    defaultSheet.cell(CellIndex.indexByString("A8")).value = "F&B";
    defaultSheet.cell(CellIndex.indexByString("A8")).cellStyle = titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C8"), CellIndex.indexByString("D8"));
    defaultSheet.cell(CellIndex.indexByString("C8")).value = "";
    defaultSheet.cell(CellIndex.indexByString("C8")).cellStyle = titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E8"), CellIndex.indexByString("E8"));
    defaultSheet.cell(CellIndex.indexByString("E8")).value = "";
    defaultSheet.cell(CellIndex.indexByString("E8")).cellStyle = titleCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A9"), CellIndex.indexByString("B9"));
    defaultSheet.cell(CellIndex.indexByString("A9")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT);
    defaultSheet.cell(CellIndex.indexByString("A9")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C9"), CellIndex.indexByString("D9"));
    defaultSheet.cell(CellIndex.indexByString("C9")).value =
        controller.restaurantTotal;
    defaultSheet.cell(CellIndex.indexByString("C9")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E9"), CellIndex.indexByString("E9"));
    defaultSheet.cell(CellIndex.indexByString("E9")).value = NumberUtil
        .numberFormat
        .format((controller.restaurantTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E9")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A10"), CellIndex.indexByString("B10"));
    defaultSheet.cell(CellIndex.indexByString("A10")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INSIDE_RESTAURANT);
    defaultSheet.cell(CellIndex.indexByString("A10")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C10"), CellIndex.indexByString("D10"));
    defaultSheet.cell(CellIndex.indexByString("C10")).value =
        controller.insideRestaurantTotal;
    defaultSheet.cell(CellIndex.indexByString("C10")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E10"), CellIndex.indexByString("E10"));
    defaultSheet.cell(CellIndex.indexByString("E10")).value = NumberUtil
        .numberFormat
        .format((controller.insideRestaurantTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E10")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A11"), CellIndex.indexByString("B11"));
    defaultSheet.cell(CellIndex.indexByString("A11")).value = "Total F&B";
    defaultSheet.cell(CellIndex.indexByString("A11")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C11"), CellIndex.indexByString("D11"));
    defaultSheet.cell(CellIndex.indexByString("C11")).value =
        controller.insideRestaurantTotal + controller.restaurantTotal;
    defaultSheet.cell(CellIndex.indexByString("C11")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E11"), CellIndex.indexByString("E11"));
    defaultSheet.cell(CellIndex.indexByString("E11")).value =
        NumberUtil.numberFormat.format(
            ((controller.insideRestaurantTotal + controller.restaurantTotal) /
                    totalAll) *
                100);
    defaultSheet.cell(CellIndex.indexByString("E11")).cellStyle =
        titleColorCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A12"), CellIndex.indexByString("B12"));
    defaultSheet.cell(CellIndex.indexByString("A12")).value = "Other Services";
    defaultSheet.cell(CellIndex.indexByString("A12")).cellStyle =
        titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C12"), CellIndex.indexByString("D12"));
    defaultSheet.cell(CellIndex.indexByString("C12")).value = "";
    defaultSheet.cell(CellIndex.indexByString("C12")).cellStyle =
        titleCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E12"), CellIndex.indexByString("E12"));
    defaultSheet.cell(CellIndex.indexByString("E12")).value = "";
    defaultSheet.cell(CellIndex.indexByString("E12")).cellStyle =
        titleCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A13"), CellIndex.indexByString("B13"));
    defaultSheet.cell(CellIndex.indexByString("A13")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MINIBAR_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("A13")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C13"), CellIndex.indexByString("D13"));
    defaultSheet.cell(CellIndex.indexByString("C13")).value =
        controller.minibarTotal;
    defaultSheet.cell(CellIndex.indexByString("C13")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E13"), CellIndex.indexByString("E13"));
    defaultSheet.cell(CellIndex.indexByString("E13")).value = NumberUtil
        .numberFormat
        .format((controller.minibarTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E13")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A14"), CellIndex.indexByString("B14"));
    defaultSheet.cell(CellIndex.indexByString("A14")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("A14")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C14"), CellIndex.indexByString("D14"));
    defaultSheet.cell(CellIndex.indexByString("C14")).value =
        controller.extraHourTotal;
    defaultSheet.cell(CellIndex.indexByString("C14")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E14"), CellIndex.indexByString("E14"));
    defaultSheet.cell(CellIndex.indexByString("E14")).value = NumberUtil
        .numberFormat
        .format((controller.extraHourTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E14")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A15"), CellIndex.indexByString("B15"));
    defaultSheet.cell(CellIndex.indexByString("A15")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("A15")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C15"), CellIndex.indexByString("D15"));
    defaultSheet.cell(CellIndex.indexByString("C15")).value =
        controller.extraGuestTotal;
    defaultSheet.cell(CellIndex.indexByString("C15")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E15"), CellIndex.indexByString("E15"));
    defaultSheet.cell(CellIndex.indexByString("E15")).value = NumberUtil
        .numberFormat
        .format((controller.extraGuestTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E15")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A16"), CellIndex.indexByString("B16"));
    defaultSheet.cell(CellIndex.indexByString("A16")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LAUNDRY_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("A16")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C16"), CellIndex.indexByString("D16"));
    defaultSheet.cell(CellIndex.indexByString("C16")).value =
        controller.laudryTotal;
    defaultSheet.cell(CellIndex.indexByString("C16")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E16"), CellIndex.indexByString("E16"));
    defaultSheet.cell(CellIndex.indexByString("E16")).value = NumberUtil
        .numberFormat
        .format((controller.laudryTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E16")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A17"), CellIndex.indexByString("B17"));
    defaultSheet.cell(CellIndex.indexByString("A17")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("A17")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C17"), CellIndex.indexByString("D17"));
    defaultSheet.cell(CellIndex.indexByString("C17")).value =
        controller.bikeRentalTotal;
    defaultSheet.cell(CellIndex.indexByString("C17")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E17"), CellIndex.indexByString("E17"));
    defaultSheet.cell(CellIndex.indexByString("E17")).value = NumberUtil
        .numberFormat
        .format((controller.bikeRentalTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E17")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A18"), CellIndex.indexByString("B18"));
    defaultSheet.cell(CellIndex.indexByString("A18")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER);
    defaultSheet.cell(CellIndex.indexByString("A18")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C18"), CellIndex.indexByString("D18"));
    defaultSheet.cell(CellIndex.indexByString("C18")).value =
        controller.otherTotal;
    defaultSheet.cell(CellIndex.indexByString("C18")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E18"), CellIndex.indexByString("E18"));
    defaultSheet.cell(CellIndex.indexByString("E18")).value = NumberUtil
        .numberFormat
        .format((controller.otherTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E18")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A19"), CellIndex.indexByString("B19"));
    defaultSheet.cell(CellIndex.indexByString("A19")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ELECTRICITY_WATER);
    defaultSheet.cell(CellIndex.indexByString("A19")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C19"), CellIndex.indexByString("D19"));
    defaultSheet.cell(CellIndex.indexByString("C19")).value =
        controller.electricityWaterTotal;
    defaultSheet.cell(CellIndex.indexByString("C19")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E19"), CellIndex.indexByString("E19"));
    defaultSheet.cell(CellIndex.indexByString("E19")).value = NumberUtil
        .numberFormat
        .format((controller.electricityWaterTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E19")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A20"), CellIndex.indexByString("B20"));
    defaultSheet.cell(CellIndex.indexByString("A20")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("A20")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C20"), CellIndex.indexByString("D20"));
    defaultSheet.cell(CellIndex.indexByString("C20")).value =
        controller.discountTotal;
    defaultSheet.cell(CellIndex.indexByString("C20")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E20"), CellIndex.indexByString("E20"));
    defaultSheet.cell(CellIndex.indexByString("E20")).value = NumberUtil
        .numberFormat
        .format((controller.discountTotal / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E20")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A21"), CellIndex.indexByString("B21"));
    defaultSheet.cell(CellIndex.indexByString("A21")).value = "Total other";
    defaultSheet.cell(CellIndex.indexByString("A21")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C21"), CellIndex.indexByString("D21"));
    defaultSheet.cell(CellIndex.indexByString("C21")).value = totalOther;
    defaultSheet.cell(CellIndex.indexByString("C21")).cellStyle =
        titleColorCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E21"), CellIndex.indexByString("E21"));
    defaultSheet.cell(CellIndex.indexByString("E21")).value =
        NumberUtil.numberFormat.format((totalOther / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E21")).cellStyle =
        titleColorCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A22"), CellIndex.indexByString("B22"));
    defaultSheet.cell(CellIndex.indexByString("A22")).value =
        "Total Hotel Revenue";
    defaultSheet.cell(CellIndex.indexByString("A22")).cellStyle =
        titleColorTotalCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C22"), CellIndex.indexByString("D22"));
    defaultSheet.cell(CellIndex.indexByString("C22")).value = totalAll;
    defaultSheet.cell(CellIndex.indexByString("C22")).cellStyle =
        titleColorTotalCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E22"), CellIndex.indexByString("E22"));
    defaultSheet.cell(CellIndex.indexByString("E22")).value =
        NumberUtil.numberFormat.format((totalAll / totalAll) * 100);
    defaultSheet.cell(CellIndex.indexByString("E22")).cellStyle =
        titleColorTotalCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A23"), CellIndex.indexByString("B23"));
    defaultSheet.cell(CellIndex.indexByString("A23")).value =
        "---------- STATISTIC ----------";
    defaultSheet.cell(CellIndex.indexByString("A23")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C23"), CellIndex.indexByString("D23"));
    defaultSheet.cell(CellIndex.indexByString("C23")).value = '';
    defaultSheet.cell(CellIndex.indexByString("C23")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E23"), CellIndex.indexByString("E23"));
    defaultSheet.cell(CellIndex.indexByString("E23")).value = '';
    defaultSheet.cell(CellIndex.indexByString("E23")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A24"), CellIndex.indexByString("B24"));
    defaultSheet.cell(CellIndex.indexByString("A24")).value =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_GUEST);
    defaultSheet.cell(CellIndex.indexByString("A24")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C24"), CellIndex.indexByString("D24"));
    defaultSheet.cell(CellIndex.indexByString("C24")).value =
        controller.mountnGuestTotal;
    defaultSheet.cell(CellIndex.indexByString("C24")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E24"), CellIndex.indexByString("E24"));
    defaultSheet.cell(CellIndex.indexByString("E24")).value = "";
    defaultSheet.cell(CellIndex.indexByString("E24")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A25"), CellIndex.indexByString("B25"));
    defaultSheet.cell(CellIndex.indexByString("A25")).value =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_OCCUPANCY);
    defaultSheet.cell(CellIndex.indexByString("A25")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C25"), CellIndex.indexByString("D25"));
    defaultSheet.cell(CellIndex.indexByString("C25")).value =
        "${NumberUtil.numberFormat.format(controller.occTotal ?? 0)}%";
    defaultSheet.cell(CellIndex.indexByString("C25")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E25"), CellIndex.indexByString("E25"));
    defaultSheet.cell(CellIndex.indexByString("E25")).value = '';
    defaultSheet.cell(CellIndex.indexByString("E25")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A26"), CellIndex.indexByString("B26"));
    defaultSheet.cell(CellIndex.indexByString("A26")).value =
        MessageUtil.getMessageByCode(MessageCodeUtil.STATISTIC_AVERAGE_RATE);
    defaultSheet.cell(CellIndex.indexByString("A26")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C26"), CellIndex.indexByString("D26"));
    defaultSheet.cell(CellIndex.indexByString("C26")).value =
        NumberUtil.numberFormat.format(controller.verageRatetotal ?? 0);
    defaultSheet.cell(CellIndex.indexByString("C26")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E26"), CellIndex.indexByString("E26"));
    defaultSheet.cell(CellIndex.indexByString("E26")).value = '';
    defaultSheet.cell(CellIndex.indexByString("E26")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A27"), CellIndex.indexByString("B27"));
    defaultSheet.cell(CellIndex.indexByString("A27")).value = "Room Available";
    defaultSheet.cell(CellIndex.indexByString("A27")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C27"), CellIndex.indexByString("D27"));
    defaultSheet.cell(CellIndex.indexByString("C27")).value =
        controller.roomAvailableTotal;
    defaultSheet.cell(CellIndex.indexByString("C27")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E27"), CellIndex.indexByString("E27"));
    defaultSheet.cell(CellIndex.indexByString("E27")).value = "";
    defaultSheet.cell(CellIndex.indexByString("E27")).cellStyle =
        contentCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("A28"), CellIndex.indexByString("B28"));
    defaultSheet.cell(CellIndex.indexByString("A28")).value = "Room Sold";
    defaultSheet.cell(CellIndex.indexByString("A28")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("C28"), CellIndex.indexByString("D28"));
    defaultSheet.cell(CellIndex.indexByString("C28")).value =
        controller.roomSoldTotal;
    defaultSheet.cell(CellIndex.indexByString("C28")).cellStyle =
        contentCellStyle;
    defaultSheet.merge(
        CellIndex.indexByString("E28"), CellIndex.indexByString("E28"));
    defaultSheet.cell(CellIndex.indexByString("E28")).value = "";
    defaultSheet.cell(CellIndex.indexByString("E28")).cellStyle =
        contentCellStyle;

    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckInReservationFormGroup(
      Map<Booking?, int> listGroup,
      Group groups,
      bool showPrice,
      bool isShowNotes,
      String notes,
      Map<String, int> dataMeal) {
    String excelName =
        "OnePMS_CheckinReservationFormGroup_${groups.name!.replaceAll(RegExp(r'\s+'), '')}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "H";
    String headerColorHex = "ff59b69e";

    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_RESERVATION_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKING_CODE);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("B5")).value = groups.sID;
    defaultSheet.cell(CellIndex.indexByString("B5")).cellStyle = CellStyle(
      italic: true,
    );

    defaultSheet.cell(CellIndex.indexByString("D5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE);
    defaultSheet.cell(CellIndex.indexByString("D5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        DateUtil.dateToDayMonthYearString(groups.inDate);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
    );

    defaultSheet.cell(CellIndex.indexByString("A6")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_INFOS);
    defaultSheet.cell(CellIndex.indexByString("B6")).value = groups.name;

    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("B7")).value =
        SourceManager().getSourceNameByID(groups.sourceID!);

    defaultSheet.cell(CellIndex.indexByString("A8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("B8")).value = groups.phone;

    //THANK YOU
    defaultSheet.merge(
        CellIndex.indexByString("A9"), CellIndex.indexByString("H9"));
    defaultSheet.cell(CellIndex.indexByString("A9")).value =
        MessageUtil.getMessageByCode(MessageCodeUtil.CONTENT_THANKYOU,
            [GeneralManager.hotel!.name ?? ""]);
    defaultSheet.cell(CellIndex.indexByString("A9")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ROOMTYPE);
    defaultSheet.cell(CellIndex.indexByString("A11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("B11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("B11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("C11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("C11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("D11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);
    defaultSheet.cell(CellIndex.indexByString("D11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("E11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LENGTH_STAY);
    defaultSheet.cell(CellIndex.indexByString("E11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("F11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("F11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("G11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE);
    defaultSheet.cell(CellIndex.indexByString("G11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("H11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL_FULL);
    defaultSheet.cell(CellIndex.indexByString("H11")).cellStyle =
        titleCellStyle;

    //write data
    num totalMoney = 0;
    num totalGust = 0;
    int totalRoom = 0;
    Map<String, Set<num>> setPrice = {};
    int i = 11;
    for (var e in listGroup.entries) {
      String chainPrice = '';
      setPrice[e.key!.id!] = {};
      for (var price in e.key!.price!) {
        setPrice[e.key!.id]!.add(price);
      }
      for (var element in setPrice[e.key!.id]!) {
        element == setPrice[e.key!.id]!.last
            ? chainPrice += element.toString()
            : chainPrice += '${element.toString()}, ';
      }
      defaultSheet.insertRowIterables([
        e.key!.getRoomTypeName(),
        e.value.toString(),
        DateUtil.dateToDayMonthString(e.key!.inDate!),
        DateUtil.dateToDayMonthString(e.key!.outDate!),
        e.key!.lengthStay.toString(),
        '${e.key!.adult! + e.key!.child!}',
        showPrice ? chainPrice : '',
        showPrice
            ? NumberUtil.numberFormat.format(
                e.key!.bookingType == BookingType.monthly
                    ? e.key!.getRoomCharge()
                    : (e.key!.getRoomCharge() * e.value))
            : '',
      ], defaultSheet.maxRows);
      totalMoney += (e.key!.getRoomCharge() * e.value);
      totalRoom += e.value;
      totalGust += (e.key!.adult! + e.key!.child!);

      i++;
    }

    defaultSheet.cell(CellIndex.indexByString("A${i + 1}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("B${i + 1}")).value =
        NumberUtil.numberFormat.format(totalRoom);
    defaultSheet.cell(CellIndex.indexByString("F${i + 1}")).value =
        NumberUtil.numberFormat.format(totalGust);
    defaultSheet.cell(CellIndex.indexByString("H${i + 1}")).value =
        showPrice ? NumberUtil.numberFormat.format(totalMoney) : '';

    defaultSheet.cell(CellIndex.indexByString("G${i + 2}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPOSIT);
    defaultSheet.cell(CellIndex.indexByString("H${i + 2}")).value =
        showPrice ? NumberUtil.numberFormat.format(groups.deposit) : '';

    defaultSheet.cell(CellIndex.indexByString("G${i + 3}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
    defaultSheet.cell(CellIndex.indexByString("H${i + 3}")).value =
        showPrice ? NumberUtil.numberFormat.format(groups.remaining) : '';

    //BREAKFAST
    defaultSheet.merge(CellIndex.indexByString("A${i + 5}"),
        CellIndex.indexByString("B${i + 5}"));
    defaultSheet.cell(CellIndex.indexByString("A${i + 5}")).value =
        "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MEALS)}:${dataMeal["breakfast"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESBREAKFAST)} - ${dataMeal["breakfast"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOBREAKFAST)}";
    defaultSheet.cell(CellIndex.indexByString("A${i + 5}")).cellStyle =
        CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    //lunch
    defaultSheet.merge(CellIndex.indexByString("A${i + 6}"),
        CellIndex.indexByString("B${i + 6}"));
    defaultSheet.cell(CellIndex.indexByString("A${i + 6}")).value =
        "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MEALS)}:  ${dataMeal["lunch"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESLUNCH)} - ${dataMeal["lunch"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOLUNCH)}";
    defaultSheet.cell(CellIndex.indexByString("A${i + 6}")).cellStyle =
        CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );

    //dinner
    defaultSheet.merge(CellIndex.indexByString("A${i + 7}"),
        CellIndex.indexByString("B${i + 7}"));
    defaultSheet.cell(CellIndex.indexByString("A${i + 7}")).value =
        "${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MEALS)}: ${dataMeal["dinner"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESDINNER)} - ${dataMeal["dinner"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NODINNER)}";
    defaultSheet.cell(CellIndex.indexByString("A${i + 7}")).cellStyle =
        CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    if (isShowNotes) {
      defaultSheet.merge(CellIndex.indexByString("A${i + 8}"),
          CellIndex.indexByString("B${i + 8}"));
      defaultSheet.cell(CellIndex.indexByString("A${i + 8}")).value =
          "${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)}: $notes";
      defaultSheet.cell(CellIndex.indexByString("A${i + 8}")).cellStyle =
          CellStyle(
        italic: true,
        horizontalAlign: HorizontalAlign.Right,
      );
    }
    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckInFormGroup(Group group, bool showPrice) {
    String excelName =
        "OnePMS_CheckinFormGroup_${group.name!.replaceAll(RegExp(r'\s+'), '')}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "F";
    String headerColorHex = "ff59b69e";

    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKIN_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));

    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A6")).value = group.name;
    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A8")).value = group.phone;

    //in date + out date
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL_DATE);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C6")).value =
        DateUtil.dateToString(group.inDate!);
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE_DATE);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        DateUtil.dateToString(group.outDate!);

    //invoice total
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("${lastCol}5"));
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("${lastCol}8"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    defaultSheet.cell(CellIndex.indexByString("E6")).value =
        showPrice ? NumberUtil.numberFormat.format(group.roomCharge) : "";
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle = CellStyle(
        fontSize: 15,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    //invoice detail
    defaultSheet.merge(
        CellIndex.indexByString("A10"), CellIndex.indexByString("C10"));
    defaultSheet.cell(CellIndex.indexByString("A10")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.merge(CellIndex.indexByString("D10"),
        CellIndex.indexByString("${lastCol}10"));
    defaultSheet.cell(CellIndex.indexByString("D10")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DETAIL);

    //room
    defaultSheet.merge(
        CellIndex.indexByString("A13"), CellIndex.indexByString("C13"));
    defaultSheet.cell(CellIndex.indexByString("A13")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.merge(CellIndex.indexByString("D13"),
        CellIndex.indexByString("${lastCol}13"));
    defaultSheet.cell(CellIndex.indexByString("D13")).value =
        group.room.toString();
    //adult
    defaultSheet.merge(
        CellIndex.indexByString("A14"), CellIndex.indexByString("C14"));
    defaultSheet.cell(CellIndex.indexByString("A14")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADULT);
    defaultSheet.merge(CellIndex.indexByString("D14"),
        CellIndex.indexByString("${lastCol}14"));
    defaultSheet.cell(CellIndex.indexByString("D14")).value = group.adult;
    // child
    defaultSheet.merge(
        CellIndex.indexByString("A15"), CellIndex.indexByString("C15"));
    defaultSheet.cell(CellIndex.indexByString("A15")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHILD);
    defaultSheet.merge(CellIndex.indexByString("D15"),
        CellIndex.indexByString("${lastCol}15"));
    defaultSheet.cell(CellIndex.indexByString("D15")).value = group.child;
    //source
    defaultSheet.merge(
        CellIndex.indexByString("A16"), CellIndex.indexByString("C16"));
    defaultSheet.cell(CellIndex.indexByString("A16")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.merge(CellIndex.indexByString("D16"),
        CellIndex.indexByString("${lastCol}16"));
    defaultSheet.cell(CellIndex.indexByString("D16")).value =
        SourceManager().getSourceNameByID(group.sourceID!);
    //SID
    defaultSheet.merge(
        CellIndex.indexByString("A17"), CellIndex.indexByString("C17"));
    defaultSheet.cell(CellIndex.indexByString("A17")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.merge(CellIndex.indexByString("D17"),
        CellIndex.indexByString("${lastCol}17"));
    defaultSheet.cell(CellIndex.indexByString("D17")).value = group.sID;
    //room charge
    defaultSheet.merge(
        CellIndex.indexByString("A18"), CellIndex.indexByString("C18"));
    defaultSheet.cell(CellIndex.indexByString("A18")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL);
    defaultSheet.merge(CellIndex.indexByString("D18"),
        CellIndex.indexByString("${lastCol}18"));
    defaultSheet.cell(CellIndex.indexByString("D18")).value =
        showPrice ? NumberUtil.numberFormat.format(group.roomCharge) : '';
    //payment
    defaultSheet.merge(
        CellIndex.indexByString("A19"), CellIndex.indexByString("C19"));
    defaultSheet.cell(CellIndex.indexByString("A19")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.merge(CellIndex.indexByString("D19"),
        CellIndex.indexByString("${lastCol}19"));
    defaultSheet.cell(CellIndex.indexByString("D19")).value =
        showPrice ? NumberUtil.numberFormat.format(group.deposit) : '';
    //remain
    defaultSheet.merge(
        CellIndex.indexByString("A20"), CellIndex.indexByString("C20"));
    defaultSheet.cell(CellIndex.indexByString("A20")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
    defaultSheet.merge(CellIndex.indexByString("D20"),
        CellIndex.indexByString("${lastCol}20"));
    defaultSheet.cell(CellIndex.indexByString("D20")).value =
        NumberUtil.numberFormat.format(group.remaining);

    ///P/s
    defaultSheet.merge(
        CellIndex.indexByString("A22"), CellIndex.indexByString("C22"));
    defaultSheet.cell(CellIndex.indexByString("A22")).value =
        ' * (B): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST)} , (NB): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_BREAKFAST)}';
    defaultSheet.merge(
        CellIndex.indexByString("A23"), CellIndex.indexByString("C23"));
    defaultSheet.cell(CellIndex.indexByString("A23")).value =
        ' * (L): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LUNCH)} , (NL): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_LUNCH)}';
    defaultSheet.merge(
        CellIndex.indexByString("A24"), CellIndex.indexByString("C24"));
    defaultSheet.cell(CellIndex.indexByString("A24")).value =
        ' * (D): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DINNER)} , (ND): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_DINNER)}';
    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckInFormGroupCheckOut(
      Group group,
      GroupController controller,
      bool showPrice,
      bool isShowService,
      bool isShowPayment,
      bool isShowRemaining) {
    String excelName =
        "OnePMS_CheckinFormGroupCheckOut_${controller.getGroup().name!.replaceAll(RegExp(r'\s+'), '')}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "F";
    String headerColorHex = "ff59b69e";

    double totalAmount = 0;
    Tax tax = ConfigurationManagement().tax;
    double serviceFee = tax.serviceFee!;
    double vat = tax.vat!;

    Group groupExcel =
        controller.selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)
            ? group
            : controller.getGroup();
    Map<String, String> mapData =
        controller.bookingParent.bookingType == BookingType.monthly
            ? controller.mapData
            : groupExcel.getRoomChargeDetail();

    double groupRoomCharge = showPrice ? groupExcel.roomCharge!.toDouble() : 0;

    double totalCharge =
        groupRoomCharge + (isShowService ? groupExcel.service!.toDouble() : 0);

    double totalBeforeVAT =
        totalCharge / (1 + vat + serviceFee + vat * serviceFee);
    double serviceFeeMoney = (totalBeforeVAT * serviceFee).roundToDouble();
    double vatMoney =
        ((totalBeforeVAT + serviceFeeMoney) * vat).roundToDouble();
    totalBeforeVAT =
        totalCharge - serviceFeeMoney - vatMoney; //to prevent difference
    double remain = (showPrice
            ? groupExcel.remaining
            : groupExcel.remaining! - groupExcel.roomCharge!)!
        .toDouble();

    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));

    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A6")).value = groupExcel.name;
    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A8")).value = groupExcel.phone;

    //source + sid
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C6")).value =
        SourceManager().getSourceNameByID(groupExcel.sourceID!);
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C8")).value = groupExcel.sID;

    //in date + out date
    defaultSheet.cell(CellIndex.indexByString("D5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL_DATE);
    defaultSheet.cell(CellIndex.indexByString("D5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D6")).value =
        DateUtil.dateToString(groupExcel.inDate!);
    defaultSheet.cell(CellIndex.indexByString("D7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE_DATE);
    defaultSheet.cell(CellIndex.indexByString("D7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        DateUtil.dateToString(groupExcel.outDate!);

    //invoice total
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("${lastCol}5"));
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("${lastCol}8"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    defaultSheet.cell(CellIndex.indexByString("E6")).value = totalCharge;
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle = CellStyle(
        fontSize: 15,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE);
    defaultSheet.cell(CellIndex.indexByString("A11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("B11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("B11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("C11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("C11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("D11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT_PRICE);
    defaultSheet.cell(CellIndex.indexByString("D11")).cellStyle =
        titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("E11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E11")).cellStyle =
        titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("A9")).value =
        'Dịch vụ (Service)';
    defaultSheet.cell(CellIndex.indexByString("A9")).cellStyle = titleCellStyle;
    //write data
    int i = 11;

    if (showPrice) {
      for (var e in mapData.keys) {
        var price = controller.bookingParent.bookingType == BookingType.monthly
            ? int.parse(controller
                .dataPriceByMonth["${e.split(", ")[0]}, ${mapData[e]}"]!
                .split(", ")[1])
            : int.parse(e.split(", ")[1]);
        defaultSheet.insertRowIterables([
          controller.bookingParent.bookingType == BookingType.monthly
              ? e.split(", ")[0]
              : DateUtil.dateToDayMonthYearString(
                  DateTime.parse(e.split(", ")[0])),
          'Tiền phòng (Room Charge)',
          mapData[e]!,
          NumberUtil.numberFormat.format(price),
          NumberUtil.numberFormat
              .format((price * mapData[e]!.split(", ").length))
        ], defaultSheet.maxRows);
        i++;
      }
    }

    if (isShowService) {
      defaultSheet.cell(CellIndex.indexByString("A${i + 1}")).value =
          '${DateUtil.dateToDayMonthString(groupExcel.inDate!)} - ${DateUtil.dateToDayMonthString(groupExcel.outDate!)}';
      defaultSheet.cell(CellIndex.indexByString("B${i + 1}")).value =
          'Tổng tiền dịch vụ (Service Charge)';
      defaultSheet.cell(CellIndex.indexByString("C${i + 1}")).value =
          'Toàn bộ (All)';
      defaultSheet.cell(CellIndex.indexByString("E${i + 1}")).value =
          NumberUtil.numberFormat.format(groupExcel.service);
    }

    // total before service-fee and vat
    defaultSheet.cell(CellIndex.indexByString("C${i + 2}")).value =
        UITitleUtil.getTitleByCode(
            UITitleCode.TABLEHEADER_TOTAL_BEFORE_SERVICEFEE_AND_VAT);
    defaultSheet.cell(CellIndex.indexByString("E${i + 2}")).value =
        NumberUtil.numberFormat.format(totalBeforeVAT);
    //service fee
    defaultSheet.cell(CellIndex.indexByString("C${i + 3}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE_FEE);
    defaultSheet.cell(CellIndex.indexByString("E${i + 3}")).value =
        NumberUtil.numberFormat.format(serviceFeeMoney);
    //vat
    defaultSheet.cell(CellIndex.indexByString("C${i + 4}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_VAT);
    defaultSheet.cell(CellIndex.indexByString("E${i + 4}")).value =
        NumberUtil.numberFormat.format(vatMoney);
    //discount
    defaultSheet.cell(CellIndex.indexByString("C${i + 5}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("E${i + 5}")).value =
        NumberUtil.numberFormat.format(groupExcel.discount);
    //total
    defaultSheet.cell(CellIndex.indexByString("C${i + 6}")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E${i + 6}")).value =
        NumberUtil.numberFormat.format(totalCharge);

    if (isShowPayment) {
      defaultSheet.cell(CellIndex.indexByString("A${i + 8}")).value =
          'Thanh toán (Deposit)';
      defaultSheet.cell(CellIndex.indexByString("A${i + 8}")).cellStyle =
          titleCellStyle;

      defaultSheet.cell(CellIndex.indexByString("A${i + 10}")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE);
      defaultSheet.cell(CellIndex.indexByString("C${i + 10}")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
      defaultSheet.cell(CellIndex.indexByString("E${i + 10}")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE);

      i = i + 11;
      if (controller.bookingParent.paymentDetails != null) {
        for (var e in controller.bookingParent.paymentDetails!.values) {
          List<String> descArray = e.toString().split(specificCharacter);
          totalAmount += double.parse(descArray[1]);
          defaultSheet.insertRowIterables([
            descArray.length < 3
                ? ""
                : DateUtil.dateToDayMonthYearString(
                    DateTime.fromMicrosecondsSinceEpoch(
                        int.parse(descArray[2]))),
            '',
            PaymentMethodManager().getPaymentMethodNameById(descArray[0]),
            "",
            '- ${NumberUtil.numberFormat.format(double.parse(descArray[1]))}'
          ], defaultSheet.maxRows);
          i++;
        }
      }
      print(i);
      defaultSheet.cell(CellIndex.indexByString("C${i + 1}")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE_TOTAL);
      defaultSheet.cell(CellIndex.indexByString("E${i + 1}")).value =
          "- ${NumberUtil.numberFormat.format(totalAmount)}";
    }

    if (isShowRemaining) {
      defaultSheet
          .cell(
              CellIndex.indexByString("C${isShowPayment ? (i + 2) : (i + 7)}"))
          .value = UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
      defaultSheet
          .cell(
              CellIndex.indexByString("E${isShowPayment ? (i + 2) : (i + 7)}"))
          .value = NumberUtil.numberFormat.format(remain);
    }

    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckInForm(Booking booking, bool showPrice) {
    if (booking.isEmpty!) {
      return;
    }
    String excelName =
        "OnePMS_CheckinForm_${booking.name!.replaceAll(RegExp(r'\s+'), '')}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "F";
    String headerColorHex = "ff59b69e";

    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKIN_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));

    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A6")).value = booking.name;
    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A8")).value = booking.phone;

    //in date + out date
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL_DATE);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C6")).value =
        DateUtil.dateToString(booking.inDate!);
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE_DATE);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        DateUtil.dateToString(booking.outDate!);

    //invoice total
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("${lastCol}5"));
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("${lastCol}8"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    defaultSheet.cell(CellIndex.indexByString("E6")).value =
        showPrice ? booking.getTotalCharge() : "";
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle = CellStyle(
        fontSize: 15,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    //invoice detail
    defaultSheet.merge(
        CellIndex.indexByString("A10"), CellIndex.indexByString("C10"));
    defaultSheet.cell(CellIndex.indexByString("A10")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.merge(CellIndex.indexByString("D10"),
        CellIndex.indexByString("${lastCol}10"));
    defaultSheet.cell(CellIndex.indexByString("D10")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DETAIL);
    //breakfast
    defaultSheet.merge(
        CellIndex.indexByString("A11"), CellIndex.indexByString("C11"));
    defaultSheet.cell(CellIndex.indexByString("A11")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST);
    defaultSheet.merge(CellIndex.indexByString("D11"),
        CellIndex.indexByString("${lastCol}11"));
    defaultSheet.cell(CellIndex.indexByString("D11")).value = booking.breakfast!
        ? UITitleUtil.getTitleByCode(UITitleCode.YES)
        : UITitleUtil.getTitleByCode(UITitleCode.NO);

    //LUNCH
    defaultSheet.merge(
        CellIndex.indexByString("A12"), CellIndex.indexByString("C12"));
    defaultSheet.cell(CellIndex.indexByString("A12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LUNCH);
    defaultSheet.merge(CellIndex.indexByString("D12"),
        CellIndex.indexByString("${lastCol}12"));
    defaultSheet.cell(CellIndex.indexByString("D12")).value = booking.lunch!
        ? UITitleUtil.getTitleByCode(UITitleCode.YES)
        : UITitleUtil.getTitleByCode(UITitleCode.NO);

    //Dinner
    defaultSheet.merge(
        CellIndex.indexByString("A13"), CellIndex.indexByString("C13"));
    defaultSheet.cell(CellIndex.indexByString("A13")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DINNER);
    defaultSheet.merge(CellIndex.indexByString("D13"),
        CellIndex.indexByString("${lastCol}13"));
    defaultSheet.cell(CellIndex.indexByString("D13")).value = booking.dinner!
        ? UITitleUtil.getTitleByCode(UITitleCode.YES)
        : UITitleUtil.getTitleByCode(UITitleCode.NO);
    //roomtype
    defaultSheet.merge(
        CellIndex.indexByString("A14"), CellIndex.indexByString("C14"));
    defaultSheet.cell(CellIndex.indexByString("A14")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE);
    defaultSheet.merge(CellIndex.indexByString("D14"),
        CellIndex.indexByString("${lastCol}14"));
    defaultSheet.cell(CellIndex.indexByString("D14")).value =
        RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID!);
    //room
    defaultSheet.merge(
        CellIndex.indexByString("A15"), CellIndex.indexByString("C15"));
    defaultSheet.cell(CellIndex.indexByString("A15")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE);
    defaultSheet.merge(CellIndex.indexByString("D15"),
        CellIndex.indexByString("${lastCol}15"));
    defaultSheet.cell(CellIndex.indexByString("D15")).value =
        RoomManager().getNameRoomById(booking.room!);
    //bed
    defaultSheet.merge(
        CellIndex.indexByString("A16"), CellIndex.indexByString("C16"));
    defaultSheet.cell(CellIndex.indexByString("A16")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BED);
    defaultSheet.merge(CellIndex.indexByString("D16"),
        CellIndex.indexByString("${lastCol}16"));
    defaultSheet.cell(CellIndex.indexByString("D16")).value =
        SystemManagement().getBedNameById(booking.bed ?? '?');
    //adult and child
    defaultSheet.merge(
        CellIndex.indexByString("A17"), CellIndex.indexByString("C17"));
    defaultSheet.cell(CellIndex.indexByString("A17")).value =
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADULT)} / ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHILD)}';
    defaultSheet.merge(CellIndex.indexByString("D17"),
        CellIndex.indexByString("${lastCol}17"));
    defaultSheet.cell(CellIndex.indexByString("D17")).value =
        '${booking.adult} / ${booking.child}';
    //source
    defaultSheet.merge(
        CellIndex.indexByString("A18"), CellIndex.indexByString("C18"));
    defaultSheet.cell(CellIndex.indexByString("A18")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.merge(CellIndex.indexByString("D18"),
        CellIndex.indexByString("${lastCol}18"));
    defaultSheet.cell(CellIndex.indexByString("D18")).value =
        booking.sourceName;
    //SID
    defaultSheet.merge(
        CellIndex.indexByString("A19"), CellIndex.indexByString("C19"));
    defaultSheet.cell(CellIndex.indexByString("A19")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.merge(CellIndex.indexByString("D19"),
        CellIndex.indexByString("${lastCol}19"));
    defaultSheet.cell(CellIndex.indexByString("D19")).value = booking.sID;
    //room charge
    defaultSheet.merge(
        CellIndex.indexByString("A20"), CellIndex.indexByString("C20"));
    defaultSheet.cell(CellIndex.indexByString("A20")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL);
    defaultSheet.merge(CellIndex.indexByString("D20"),
        CellIndex.indexByString("${lastCol}20"));
    defaultSheet.cell(CellIndex.indexByString("D20")).value =
        showPrice ? booking.getTotalCharge() : "";
    //payment
    defaultSheet.merge(
        CellIndex.indexByString("A21"), CellIndex.indexByString("C21"));
    defaultSheet.cell(CellIndex.indexByString("A21")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.merge(CellIndex.indexByString("D21"),
        CellIndex.indexByString("${lastCol}21"));
    defaultSheet.cell(CellIndex.indexByString("D21")).value =
        showPrice ? booking.deposit : "";
    //discount
    defaultSheet.merge(
        CellIndex.indexByString("A22"), CellIndex.indexByString("C22"));
    defaultSheet.cell(CellIndex.indexByString("A22")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.merge(CellIndex.indexByString("D22"),
        CellIndex.indexByString("${lastCol}22"));
    defaultSheet.cell(CellIndex.indexByString("D22")).value =
        -booking.discount!;
    //transfering
    defaultSheet.merge(
        CellIndex.indexByString("A23"), CellIndex.indexByString("C23"));
    defaultSheet.cell(CellIndex.indexByString("A23")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRING);
    defaultSheet.merge(CellIndex.indexByString("D23"),
        CellIndex.indexByString("${lastCol}23"));
    defaultSheet.cell(CellIndex.indexByString("D23")).value =
        booking.transferring;
    //transferred
    defaultSheet.merge(
        CellIndex.indexByString("A24"), CellIndex.indexByString("C24"));
    defaultSheet.cell(CellIndex.indexByString("A24")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRED);
    defaultSheet.merge(CellIndex.indexByString("D24"),
        CellIndex.indexByString("${lastCol}24"));
    defaultSheet.cell(CellIndex.indexByString("D24")).value =
        booking.transferred;
    //remain
    num remain = booking.getRemaining()!;
    if (-kZero < remain && remain < kZero) {
      remain = 0;
    }
    defaultSheet.merge(
        CellIndex.indexByString("A25"), CellIndex.indexByString("C25"));
    defaultSheet.cell(CellIndex.indexByString("A25")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
    defaultSheet.merge(CellIndex.indexByString("D25"),
        CellIndex.indexByString("${lastCol}25"));
    defaultSheet.cell(CellIndex.indexByString("D25")).value =
        showPrice ? remain : "";
    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckOutForm(
      Booking booking,
      CheckOutController controller,
      bool isShowPrice,
      bool isShowService,
      bool isShowPayment,
      bool isShowRemaining,
      bool showDailyRate) {
    if (booking.isEmpty!) {
      return;
    }
    String excelName =
        "OnePMS_CheckoutForm_${booking.name!.replaceAll(RegExp(r'\s+'), '')}.xlsx";

    Map<String, num> dataPrice = {};
    if (controller.selectMonth ==
        UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
      dataPrice = booking.getRoomChargeByDateCostumExprot(
          inDate: controller.startDate, outDate: controller.endDate);
    }

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "F";
    String headerColorHex = "ff59b69e";
    Tax tax = ConfigurationManagement().tax;
    num totalRoom =
        controller.selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)
            ? booking.totalRoomCharge!
            : booking.getRoomCharge();
    num totalChargeRoom =
        controller.selectMonth != UITitleUtil.getTitleByCode(UITitleCode.ALL)
            ? booking.getServiceCharge() +
                (booking.totalRoomCharge ?? 0) -
                booking.discount!
            : booking.getTotalCharge()!;
    num remain =
        controller.selectMonth == UITitleUtil.getTitleByCode(UITitleCode.ALL)
            ? booking.getRemaining()!
            : totalChargeRoom +
                booking.transferred! -
                booking.deposit! -
                booking.transferring!;
    num totalCharge = isShowPrice && isShowService
        ? totalChargeRoom + booking.transferred!
        : isShowPrice
            ? totalRoom + booking.transferred! - booking.discount!
            : totalChargeRoom - totalRoom + booking.transferred!;

    ///
    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));
    defaultSheet.merge(
        CellIndex.indexByString("A10"), CellIndex.indexByString("B10"));

    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A6")).value = booking.name;
    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A8")).value = booking.phone;
    defaultSheet.cell(CellIndex.indexByString("A9")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL);
    defaultSheet.cell(CellIndex.indexByString("A9")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A10")).value = booking.email;

    //room + source
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C6")).value =
        RoomManager().getNameRoomById(booking.room!);
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C8")).value = booking.sourceName;
    defaultSheet.cell(CellIndex.indexByString("C9")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.cell(CellIndex.indexByString("C9")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C10")).value = booking.sID;

    //in date + out date
    defaultSheet.cell(CellIndex.indexByString("D5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL_DATE);
    defaultSheet.cell(CellIndex.indexByString("D5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D6")).value =
        DateUtil.dateToDayMonthYearHourMinuteString(
            (booking.bookingType == BookingType.monthly &&
                    BookingInOutByHour.monthly ==
                        GeneralManager.hotel!.hourBookingMonthly)
                ? DateUtil.to0h(booking.inTime ?? booking.inDate!)
                : DateUtil.to14h(booking.inTime ?? booking.inDate!));
    defaultSheet.cell(CellIndex.indexByString("D7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE_DATE);
    defaultSheet.cell(CellIndex.indexByString("D7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        DateUtil.dateToDayMonthYearHourMinuteString(
            (booking.bookingType == BookingType.monthly &&
                    BookingInOutByHour.monthly ==
                        GeneralManager.hotel!.hourBookingMonthly)
                ? DateUtil.to24h(booking.outTime ?? booking.outDate!)
                : (booking.outTime ?? booking.outDate!));
    defaultSheet.cell(CellIndex.indexByString("D9")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SELECT_DATE);
    defaultSheet.cell(CellIndex.indexByString("D9")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet
        .cell(CellIndex.indexByString("D10"))
        .value = (booking.bookingType == BookingType.monthly &&
            controller.selectMonth !=
                UITitleUtil.getTitleByCode(UITitleCode.ALL) &&
            controller.selectMonth ==
                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
        ? "${DateUtil.dateToDayMonthYearString(controller.startDate)} - ${DateUtil.dateToDayMonthYearString(controller.endDate)}"
        : controller.selectMonth;

    //invoice total
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("${lastCol}5"));
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("${lastCol}10"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    defaultSheet.cell(CellIndex.indexByString("E6")).value = totalCharge;
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle = CellStyle(
        fontSize: 15,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    CellStyle currencyStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center);
    CellStyle moneyStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    //title
    defaultSheet.merge(
        CellIndex.indexByString("A12"), CellIndex.indexByString("B12"));
    defaultSheet.cell(CellIndex.indexByString("A12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("A12")).cellStyle =
        CellStyle(bold: true);
    defaultSheet.merge(
        CellIndex.indexByString("C12"), CellIndex.indexByString("D12"));
    defaultSheet.cell(CellIndex.indexByString("C12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CURRENCY);
    defaultSheet.cell(CellIndex.indexByString("C12")).cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center);
    defaultSheet.merge(
        CellIndex.indexByString("E12"), CellIndex.indexByString("F12"));
    defaultSheet.cell(CellIndex.indexByString("E12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE);
    defaultSheet.cell(CellIndex.indexByString("E12")).cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    List<String> descriptions = [
      if (isShowPrice) UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
      if (isShowService) ...[
        if (booking.extraHour!.total! > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXTRA_HOUR),
        if (booking.extraGuest! > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXTRA_GUEST),
        if (booking.minibar! > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
        if (booking.laundry > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
        if (booking.insideRestaurant! > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
        if (booking.outsideRestaurant! > 0)
          UITitleUtil.getTitleByCode(
              UITitleCode.TABLEHEADER_INDEPENDEMT_RESTAURANT),
        if (booking.bikeRental! > 0)
          UITitleUtil.getTitleByCode(
              UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
        if ((booking.electricity ?? 0) > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ELECTRICITY),
        if ((booking.water ?? 0) > 0)
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WATER),
        // if (booking.other! > 0)
        //   UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER),
      ]
    ];
    List<num> rates = [
      if (isShowPrice) totalRoom,
      if (isShowService) ...[
        if (booking.extraHour!.total! > 0) booking.extraHour!.total!,
        if (booking.extraGuest! > 0) booking.extraGuest!,
        if (booking.minibar! > 0) booking.minibar!,
        if (booking.laundry > 0) booking.laundry,
        if (booking.insideRestaurant! > 0) booking.insideRestaurant ?? 0,
        if (booking.outsideRestaurant! > 0) booking.outsideRestaurant ?? 0,
        if (booking.bikeRental! > 0) booking.bikeRental!,
        if ((booking.electricity ?? 0) > 0) booking.electricity ?? 0,
        if ((booking.water ?? 0) > 0) booking.water ?? 0,
        //   booking.electricityWater?.total ?? 0,
        // if (booking.other! > 0) booking.other!,
      ]
    ];
    int count = rates.length;
    if (booking.transferred != 0) {
      count++;
      descriptions.add(UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRED));
      rates.add(booking.transferred!);
    }
    if (booking.discount != 0) {
      count++;
      descriptions
          .add(UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT));
      rates.add(-booking.discount!);
    }
    //draw currency column
    int indexOther = 12;
    for (int i = 1; i <= count; i++) {
      int indexOfRow = i + 12;
      defaultSheet.merge(CellIndex.indexByString("A$indexOfRow"),
          CellIndex.indexByString("B$indexOfRow"));
      defaultSheet.cell(CellIndex.indexByString("A$indexOfRow")).value =
          descriptions[i - 1];

      defaultSheet.merge(CellIndex.indexByString("C$indexOfRow"),
          CellIndex.indexByString("D$indexOfRow"));
      defaultSheet.cell(CellIndex.indexByString("C$indexOfRow")).value = "VND";
      defaultSheet.cell(CellIndex.indexByString("C$indexOfRow")).cellStyle =
          currencyStyle;

      defaultSheet.merge(CellIndex.indexByString("E$indexOfRow"),
          CellIndex.indexByString("F$indexOfRow"));
      defaultSheet.cell(CellIndex.indexByString("E$indexOfRow")).value =
          rates[i - 1];
      defaultSheet.cell(CellIndex.indexByString("E$indexOfRow")).cellStyle =
          moneyStyle;
      indexOther++;
    }
    // if (booking.other! > 0) {
    //   indexOther = indexOther + 1;
    //   defaultSheet.merge(CellIndex.indexByString("A$indexOther "),
    //       CellIndex.indexByString("B$indexOther"));
    //   defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
    //       UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DETAIL);
    //   defaultSheet.cell(CellIndex.indexByString("A$indexOther")).cellStyle =
    //       currencyStyle;
    //   defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
    //       CellIndex.indexByString("D$indexOther"));
    //   defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
    //       UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TYPE);
    //   defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
    //       currencyStyle;
    //   defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
    //       CellIndex.indexByString("F$indexOther"));
    //   defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
    //       UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    //   defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
    //       currencyStyle;
    // }

    ///
    indexOther = indexOther + 1;
    for (var service in controller.servicesOther) {
      defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
          CellIndex.indexByString("B$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
          OtherManager().getServiceNameByID(service.type!);
      // DateUtil.dateToDayMonthYearString(service.created!.toDate());

      defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
          CellIndex.indexByString("D$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value = "VND";
      // OtherManager().getServiceNameByID(service.type!);
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
          currencyStyle;
      defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
          CellIndex.indexByString("F$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
          NumberUtil.numberFormat.format(service.total);
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
          moneyStyle;
      indexOther++;
    }
    if (showDailyRate) {
      indexOther = indexOther + 1;
      defaultSheet.merge(CellIndex.indexByString("A$indexOther "),
          CellIndex.indexByString("B$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
          UITitleUtil.getTitleByCode(
              UITitleCode.TABLEHEADER_ROOM_CHARGE_DETAIL);
      defaultSheet.cell(CellIndex.indexByString("A$indexOther")).cellStyle =
          currencyStyle;
      defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
          CellIndex.indexByString("D$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
          UITitleUtil.getTitleByCode(booking.bookingType == BookingType.monthly
              ? UITitleCode.TABLEHEADER_MONTH
              : UITitleCode.TABLEHEADER_DATE);
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
          currencyStyle;
      defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
          CellIndex.indexByString("F$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL);
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
          currencyStyle;
      indexOther = indexOther + 1;
      if (booking.bookingType == BookingType.monthly) {
        if (controller.selectMonth ==
            UITitleUtil.getTitleByCode(UITitleCode.ALL)) {
          for (var i = 0;
              i < booking.getMapDayByMonth()["stays_month"]!.length;
              i++) {
            defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                CellIndex.indexByString("B$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
                "";
            defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                CellIndex.indexByString("D$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
                booking.getMapDayByMonth()["stays_month"]!.toList()[i];
            defaultSheet
                .cell(CellIndex.indexByString("C$indexOther"))
                .cellStyle = currencyStyle;
            defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                CellIndex.indexByString("F$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
                isShowPrice
                    ? NumberUtil.numberFormat.format(booking.price![i])
                    : '0';
            defaultSheet
                .cell(CellIndex.indexByString("E$indexOther"))
                .cellStyle = moneyStyle;
            indexOther++;
          }
          for (var i = booking.getMapDayByMonth()["stays_month"]!.length;
              i <
                  (booking.getMapDayByMonth()["stays_day"]!.length +
                      booking.getMapDayByMonth()["stays_month"]!.length);
              i++) {
            defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                CellIndex.indexByString("B$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
                "";
            defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                CellIndex.indexByString("D$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
                booking.getMapDayByMonth()["stays_day"]!.toList()[
                    i - booking.getMapDayByMonth()["stays_month"]!.length];
            defaultSheet
                .cell(CellIndex.indexByString("C$indexOther"))
                .cellStyle = currencyStyle;
            defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                CellIndex.indexByString("F$indexOther"));
            defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
                isShowPrice
                    ? NumberUtil.numberFormat.format(booking.price![i])
                    : '0';
            defaultSheet
                .cell(CellIndex.indexByString("E$indexOther"))
                .cellStyle = moneyStyle;
            indexOther++;
          }
        } else {
          int lengthStaysMonth =
              booking.getMapDayByMonth()["stays_month"]!.length;
          int dayStart = 0;
          int monthStart = 0;
          int yearStart = 0;
          String selectedNew = "";
          if (controller.selectMonth !=
              UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
            dayStart =
                int.parse(controller.selectMonth.split(' - ')[0].split("/")[0]);
            monthStart =
                int.parse(controller.selectMonth.split(' - ')[0].split("/")[1]);
            yearStart =
                int.parse(controller.selectMonth.split(' - ')[0].split("/")[2]);

            selectedNew =
                "${DateUtil.dateToDayMonthYearString(DateTime(yearStart, monthStart, dayStart))} - ${DateUtil.dateToDayMonthYearString(DateTime(yearStart, monthStart + 1, dayStart - 1))}";
          }

          if (controller.getDayByMonth().indexOf(controller.selectMonth) ==
              (controller.getDayByMonth().length - 1)) {
            if (controller.getDayByMonth().contains(selectedNew)) {
              defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                  CellIndex.indexByString("B$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
                  "";
              defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                  CellIndex.indexByString("D$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
                  selectedNew;
              defaultSheet
                  .cell(CellIndex.indexByString("C$indexOther"))
                  .cellStyle = currencyStyle;
              defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                  CellIndex.indexByString("F$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
                  isShowPrice
                      ? booking.price![
                              controller.getDayByMonth().indexOf(selectedNew)]
                          .toString()
                      : '0';
              defaultSheet
                  .cell(CellIndex.indexByString("E$indexOther"))
                  .cellStyle = moneyStyle;
              indexOther++;
            } else {
              for (var i = lengthStaysMonth - (lengthStaysMonth <= 1 ? 1 : 2);
                  i < lengthStaysMonth;
                  i++) {
                defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                    CellIndex.indexByString("B$indexOther"));
                defaultSheet
                    .cell(CellIndex.indexByString("A$indexOther"))
                    .value = "";
                defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                    CellIndex.indexByString("D$indexOther"));
                defaultSheet
                        .cell(CellIndex.indexByString("C$indexOther"))
                        .value =
                    booking.getMapDayByMonth()["stays_month"]!.toList()[i];
                defaultSheet
                    .cell(CellIndex.indexByString("C$indexOther"))
                    .cellStyle = currencyStyle;
                defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                    CellIndex.indexByString("F$indexOther"));
                defaultSheet
                        .cell(CellIndex.indexByString("E$indexOther"))
                        .value =
                    isShowPrice
                        ? NumberUtil.numberFormat.format(booking.price![i])
                        : '0';
                defaultSheet
                    .cell(CellIndex.indexByString("E$indexOther"))
                    .cellStyle = moneyStyle;
                indexOther++;
              }
            }

            for (var i = booking.getMapDayByMonth()["stays_month"]!.length;
                i <
                    (booking.getMapDayByMonth()["stays_day"]!.length +
                        booking.getMapDayByMonth()["stays_month"]!.length);
                i++) {
              defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                  CellIndex.indexByString("B$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
                  "";
              defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                  CellIndex.indexByString("D$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
                  booking.getMapDayByMonth()["stays_day"]!.toList()[
                      i - booking.getMapDayByMonth()["stays_month"]!.length];
              defaultSheet
                  .cell(CellIndex.indexByString("C$indexOther"))
                  .cellStyle = currencyStyle;
              defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                  CellIndex.indexByString("F$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
                  isShowPrice
                      ? NumberUtil.numberFormat.format(booking.price![i])
                      : '0';
              defaultSheet
                  .cell(CellIndex.indexByString("E$indexOther"))
                  .cellStyle = moneyStyle;
              indexOther++;
            }
          } else {
            if (controller.selectMonth !=
                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
              defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                  CellIndex.indexByString("B$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
                  "";
              defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                  CellIndex.indexByString("D$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
                  controller.selectMonth;
              defaultSheet
                  .cell(CellIndex.indexByString("C$indexOther"))
                  .cellStyle = currencyStyle;
              defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                  CellIndex.indexByString("F$indexOther"));
              defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
                  isShowPrice
                      ? booking.price![controller
                              .getDayByMonth()
                              .indexOf(controller.selectMonth)]
                          .toString()
                      : '0';
              defaultSheet
                  .cell(CellIndex.indexByString("E$indexOther"))
                  .cellStyle = moneyStyle;
            } else {
              for (var element in dataPrice.keys) {
                defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
                    CellIndex.indexByString("B$indexOther"));
                defaultSheet
                    .cell(CellIndex.indexByString("A$indexOther"))
                    .value = "";
                defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
                    CellIndex.indexByString("D$indexOther"));
                defaultSheet
                    .cell(CellIndex.indexByString("C$indexOther"))
                    .value = element;
                defaultSheet
                    .cell(CellIndex.indexByString("C$indexOther"))
                    .cellStyle = currencyStyle;
                defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
                    CellIndex.indexByString("F$indexOther"));
                defaultSheet
                    .cell(CellIndex.indexByString("E$indexOther"))
                    .value = isShowPrice ? dataPrice[element].toString() : '0';
                defaultSheet
                    .cell(CellIndex.indexByString("E$indexOther"))
                    .cellStyle = moneyStyle;
                indexOther++;
              }
            }
          }

          // defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
          //     CellIndex.indexByString("B$indexOther"));
          // defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value = "";
          // defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
          //     CellIndex.indexByString("D$indexOther"));
          // defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
          //     controller.selectMonth;
          // defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
          //     currencyStyle;
          // defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
          //     CellIndex.indexByString("F$indexOther"));
          // defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
          //     isShowPrice
          //         ? NumberUtil.numberFormat.format(booking.price![booking
          //             .getBookingByTypeMonth()
          //             .indexOf(DateTime(
          //                 int.parse(controller.selectMonth.split('/')[1]),
          //                 int.parse(controller.selectMonth.split('/')[0])))])
          //         : '0';
          // defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
          //     moneyStyle;
        }
      }
    }

    double vat = totalCharge * tax.vat!;
    double serviceFee = totalCharge * tax.serviceFee!;
    //service fee
    indexOther = indexOther + 3;
    defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
        CellIndex.indexByString("D$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE_FEE);
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
        moneyStyle;
    defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
        CellIndex.indexByString("F$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
        serviceFee;
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
        moneyStyle;
    //VAT
    indexOther = indexOther + 1;
    defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
        CellIndex.indexByString("D$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_VAT);
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
        moneyStyle;
    defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
        CellIndex.indexByString("F$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value = vat;
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
        moneyStyle;
    //subtotal
    indexOther = indexOther + 1;
    defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
        CellIndex.indexByString("D$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUBTOTAL);
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
        moneyStyle;
    defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
        CellIndex.indexByString("F$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
        totalCharge;
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
        moneyStyle;
//transferring
    indexOther = indexOther + 1;
    defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
        CellIndex.indexByString("D$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRING);
    defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
        moneyStyle;
    defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
        CellIndex.indexByString("F$indexOther"));
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
        booking.transferring;
    defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
        moneyStyle;
    //transferring
    // defaultSheet.merge(
    //     CellIndex.indexByString("C26"), CellIndex.indexByString("D26"));
    // defaultSheet.cell(CellIndex.indexByString("C26")).value =
    //     UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRING);
    // defaultSheet.cell(CellIndex.indexByString("C26")).cellStyle = moneyStyle;
    // defaultSheet.merge(
    //     CellIndex.indexByString("E26"), CellIndex.indexByString("F26"));
    // defaultSheet.cell(CellIndex.indexByString("E26")).value =
    //     booking.transferring;
    // defaultSheet.cell(CellIndex.indexByString("E26")).cellStyle = moneyStyle;

    ///detaipaymet
    indexOther = indexOther + 5;
    num index = indexOther + 1;
    num totalAmount = 0;
    if (isShowPayment &&
            (booking.paymentDetails != null &&
                controller.selectMonth ==
                    UITitleUtil.getTitleByCode(UITitleCode.ALL)) ||
        (booking.paymentDetails != null &&
            controller.selectMonth !=
                UITitleUtil.getTitleByCode(UITitleCode.ALL) &&
            controller.isDeposit)) {
      ///title payment
      defaultSheet.merge(CellIndex.indexByString("A$indexOther"),
          CellIndex.indexByString("B$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("A$indexOther")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE);
      defaultSheet.cell(CellIndex.indexByString("A$indexOther")).cellStyle =
          CellStyle(bold: true);
      defaultSheet.merge(CellIndex.indexByString("C$indexOther"),
          CellIndex.indexByString("D$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
      defaultSheet.cell(CellIndex.indexByString("C$indexOther")).cellStyle =
          CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center);
      defaultSheet.merge(CellIndex.indexByString("E$indexOther"),
          CellIndex.indexByString("F$indexOther"));
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE);
      defaultSheet.cell(CellIndex.indexByString("E$indexOther")).cellStyle =
          CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              verticalAlign: VerticalAlign.Center);
      for (var e in booking.paymentDetails!.values) {
        List<String> descArray = e.toString().split(specificCharacter);
        totalAmount += double.parse(descArray[1]);
        defaultSheet.merge(CellIndex.indexByString("A$index"),
            CellIndex.indexByString("B$index"));
        defaultSheet.cell(CellIndex.indexByString("A$index")).value = descArray
                    .length <
                3
            ? ""
            : DateUtil.dateToDayMonthYearString(
                DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2])));
        defaultSheet.merge(CellIndex.indexByString("C$index"),
            CellIndex.indexByString("D$index"));
        defaultSheet.cell(CellIndex.indexByString("C$index")).value =
            PaymentMethodManager().getPaymentMethodNameById(descArray[0]);
        defaultSheet.cell(CellIndex.indexByString("C$index")).cellStyle =
            moneyStyle;
        defaultSheet.merge(CellIndex.indexByString("E$index"),
            CellIndex.indexByString("F$index"));
        defaultSheet.cell(CellIndex.indexByString("E$index")).value =
            '- ${NumberUtil.numberFormat.format(double.parse(descArray[1]))}';
        defaultSheet.cell(CellIndex.indexByString("E$index")).cellStyle =
            moneyStyle;
        index++;
      }
      defaultSheet.merge(CellIndex.indexByString("C$index"),
          CellIndex.indexByString("D$index"));
      defaultSheet.cell(CellIndex.indexByString("C$index")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
      defaultSheet.cell(CellIndex.indexByString("C$index")).cellStyle =
          CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Right,
              verticalAlign: VerticalAlign.Center);
      defaultSheet.merge(CellIndex.indexByString("E$index"),
          CellIndex.indexByString("F$index"));
      defaultSheet.cell(CellIndex.indexByString("E$index")).value =
          '- $totalAmount';
      defaultSheet.cell(CellIndex.indexByString("E$index")).cellStyle =
          moneyStyle;
    }

    if (isShowRemaining) {
      index = index + 1;
      //remain
      defaultSheet.merge(CellIndex.indexByString("C$index"),
          CellIndex.indexByString("D$index"));
      defaultSheet.cell(CellIndex.indexByString("C$index")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
      defaultSheet.cell(CellIndex.indexByString("C$index")).cellStyle =
          moneyStyle;
      defaultSheet.merge(CellIndex.indexByString("E$index"),
          CellIndex.indexByString("F$index"));
      if (-kZero < remain && remain < kZero) {
        remain = 0;
      }
      defaultSheet.cell(CellIndex.indexByString("E$index")).value = remain;
      defaultSheet.cell(CellIndex.indexByString("E$index")).cellStyle =
          CellStyle(fontSize: 11, bold: true);
    }

    //save
    excel.save(fileName: excelName);
  }

  static void exportReceptionCash(
      List<Deposit> deposits, DateTime start, DateTime end) {
    String excelName;
    excelName =
        "OnePMS_ReceptionCash_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Mô tả";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Số tiền";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 3; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    num totalMoney = 0;
    for (var deposit in deposits) {
      String timeInString = deposit.created == null
          ? ''
          : DateUtil.dateToDayMonthHourMinuteString(deposit.created!.toDate());
      defaultSheet.insertRowIterables(
          [timeInString, deposit.desc, deposit.amount], defaultSheet.maxRows);
      totalMoney += deposit.amount!;
    }

    int indexOfMaxRow = defaultSheet.maxRows;
    //total row
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: indexOfMaxRow));
    Data totalTitleCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
    totalTitleCell.value = "Tổng cộng";
    totalTitleCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalAmountCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indexOfMaxRow));
    totalAmountCell.value = totalMoney;
    totalAmountCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //save
    excel.save(fileName: excelName);
  }

  static void exportAccountingManagement(
      List<Accounting> accountings, DateTime start, DateTime end) {
    String excelName =
        "OnePMS_AccountingManagement_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Mô tả";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Nhà cung cấp";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Loại";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Người tạo";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Tổng tiền";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Đã trả";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Còn lại";
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Trạng thái";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 9; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    num totalMoney = 0;
    num totalPaid = 0;
    num totalRemain = 0;
    for (var e in accountings) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(e.created!),
        e.desc,
        SupplierManager().getSupplierNameByID(e.supplier!),
        AccountingTypeManager.getNameById(e.type!),
        e.author,
        e.amount,
        e.actualPayment,
        e.remain,
        e.status
      ], defaultSheet.maxRows);
      totalMoney += e.amount!;
      totalPaid += e.actualPayment!;
      totalRemain += e.remain;
    }

    int indexOfMaxRow = defaultSheet.maxRows;
    //total row
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow));
    Data totalTitleCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
    totalTitleCell.value = "Tổng cộng";
    totalTitleCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalAmountCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow));
    totalAmountCell.value = totalMoney;
    totalAmountCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalPaidCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow));
    totalPaidCell.value = totalPaid;
    totalPaidCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalRemainCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
    totalRemainCell.value = totalRemain;
    totalRemainCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //save
    excel.save(fileName: excelName);
  }

  static void exportActualPaymentManagement(
      List<ActualPayment> data, DateTime start, DateTime end) {
    String excelName =
        "OnePMS_ActualPayment_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Mã chi phí";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Mô tả";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Nhà cung cấp";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Loại";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Người tạo";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Phương thức";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Tổng tiền";
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Trạng thái";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 9; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    num totalMoney = 0;
    for (var e in data) {
      defaultSheet.insertRowIterables([
        e.accountingId,
        DateUtil.dateToDayMonthHourMinuteString(e.created!),
        e.desc,
        SupplierManager().getSupplierNameByID(e.supplier!),
        AccountingTypeManager.getNameById(e.type!),
        e.author,
        PaymentMethodManager().getPaymentMethodNameById(e.method!),
        e.amount,
        e.status
      ], defaultSheet.maxRows);
      totalMoney += e.amount!;
    }

    int indexOfMaxRow = defaultSheet.maxRows;
    //total row
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow));
    Data totalTitleCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
    totalTitleCell.value = "Tổng cộng";
    totalTitleCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalAmountCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
    totalAmountCell.value = totalMoney;
    totalAmountCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //save
    excel.save(fileName: excelName);
  }

  static void exportRevenueByDateReport(
      Map<String, dynamic> data, DateTime start, DateTime end) {
    String excelName =
        "OnePMS_RevenueByDate_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

//title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Ngày";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Hạng Phòng";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "SL Phòng";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Giá phòng";
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        "Tiền phòng một ngày";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "SL Khách";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Minibar";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Extra_hours";
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Extra_guests";
    defaultSheet.cell(CellIndex.indexByString("J1")).value = "Giặt ủi";
    defaultSheet.cell(CellIndex.indexByString("K1")).value = "Khác";
    defaultSheet.cell(CellIndex.indexByString("L1")).value = "Thuê xe";
    defaultSheet.cell(CellIndex.indexByString("M1")).value = "Restaurant";
    defaultSheet.cell(CellIndex.indexByString("N1")).value = "Inside_Res";
    defaultSheet.cell(CellIndex.indexByString("O1")).value = "Điện nước";
    defaultSheet.cell(CellIndex.indexByString("P1")).value = "Giảm giá";
    defaultSheet.cell(CellIndex.indexByString("Q1")).value = "Tổng";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    // total cell style
    CellStyle totalCellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    // total Cell style sub
    CellStyle totalCellSubStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Left,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("B1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("C1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("E1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("F1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("G1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("H1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("I1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("J1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("K1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("L1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("M1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("N1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("O1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("P1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("Q1")).cellStyle = titleCellStyle;

    num totalRoomCharge = 0;
    num totalGuest = 0;
    num totalMinibar = 0;
    num totalExtraHours = 0;
    num totalExtraGuest = 0;
    num totalLaundry = 0;
    num totalBikeRental = 0;
    num totalOther = 0;
    num totalRestaurant = 0;
    num totalInsideRes = 0;
    num totalDiscount = 0;
    num totalFinal = 0;
    num totalElectricityWater = 0;

    for (var e in data.entries) {
      final Map<dynamic, dynamic> detailsRoomType = e.value['details'];
      num maxRowIndex = defaultSheet.maxRows + 1;
      defaultSheet.cell(CellIndex.indexByString('A$maxRowIndex')).value = e.key;

      for (var roomType in detailsRoomType.entries) {
        if (roomType.value['num'] == 0) continue;
        defaultSheet.cell(CellIndex.indexByString('B$maxRowIndex')).value =
            RoomTypeManager().getRoomTypeNameByID(roomType.key);
        defaultSheet.cell(CellIndex.indexByString('C$maxRowIndex')).value =
            roomType.value['num'];
        defaultSheet.cell(CellIndex.indexByString('D$maxRowIndex')).value =
            RoomTypeManager().getRoomTypeByID(roomType.key).price;
        defaultSheet.cell(CellIndex.indexByString('E$maxRowIndex')).value =
            roomType.value['total'];
        maxRowIndex++;
      }

      defaultSheet.cell(CellIndex.indexByString('A$maxRowIndex'))
        ..value = 'Cộng'
        ..cellStyle = totalCellSubStyle;

      defaultSheet.cell(CellIndex.indexByString('E$maxRowIndex')).value =
          e.value['room_charge'];

      defaultSheet
          .cell(CellIndex.indexByString('F${defaultSheet.maxRows}'))
          .value = e.value['guest'];

      defaultSheet
          .cell(CellIndex.indexByString('G${defaultSheet.maxRows}'))
          .value = e.value['minibar'];
      defaultSheet
          .cell(CellIndex.indexByString('H${defaultSheet.maxRows}'))
          .value = e.value['extra_hours'];
      defaultSheet
          .cell(CellIndex.indexByString('I${defaultSheet.maxRows}'))
          .value = e.value['extra_guest'];
      defaultSheet
          .cell(CellIndex.indexByString('J${defaultSheet.maxRows}'))
          .value = e.value['laundry'];
      defaultSheet
          .cell(CellIndex.indexByString('K${defaultSheet.maxRows}'))
          .value = e.value['other'];
      defaultSheet
          .cell(CellIndex.indexByString('L${defaultSheet.maxRows}'))
          .value = e.value['bike_rental'];
      defaultSheet
          .cell(CellIndex.indexByString('M${defaultSheet.maxRows}'))
          .value = e.value['restaurant'];
      defaultSheet
          .cell(CellIndex.indexByString('N${defaultSheet.maxRows}'))
          .value = e.value['inside_restaurant'];
      defaultSheet
          .cell(CellIndex.indexByString('O${defaultSheet.maxRows}'))
          .value = e.value['electricity_water'];
      defaultSheet
          .cell(CellIndex.indexByString('P${defaultSheet.maxRows}'))
          .value = e.value['discount'];
      defaultSheet
          .cell(CellIndex.indexByString('Q${defaultSheet.maxRows}'))
          .value = e.value['total'];

      totalRoomCharge += e.value['room_charge'];
      totalGuest += e.value['guest'];
      totalMinibar += e.value['minibar'];
      totalExtraHours += e.value['extra_hours'];
      totalExtraGuest += e.value['extra_guest'];
      totalLaundry += e.value['laundry'];
      totalBikeRental += e.value['other'];
      totalOther += e.value['bike_rental'];
      totalRestaurant += e.value['restaurant'];
      totalInsideRes += e.value['inside_restaurant'];
      totalDiscount += e.value['discount'];
      totalFinal += e.value['total'];
      totalElectricityWater += e.value['electricity_water'];
    }

    // title cell
    defaultSheet.cell(CellIndex.indexByString('A${defaultSheet.maxRows + 1}'))
      ..cellStyle = titleCellStyle
      ..value = 'Tổng Cộng';
    defaultSheet.cell(CellIndex.indexByString('E${defaultSheet.maxRows}'))
      ..value = totalRoomCharge
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('F${defaultSheet.maxRows}'))
      ..value = totalGuest
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('G${defaultSheet.maxRows}'))
      ..value = totalMinibar
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('H${defaultSheet.maxRows}'))
      ..value = totalExtraHours
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('I${defaultSheet.maxRows}'))
      ..value = totalExtraGuest
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('J${defaultSheet.maxRows}'))
      ..value = totalLaundry
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('K${defaultSheet.maxRows}'))
      ..value = totalBikeRental
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('L${defaultSheet.maxRows}'))
      ..value = totalOther
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('M${defaultSheet.maxRows}'))
      ..value = totalRestaurant
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('N${defaultSheet.maxRows}'))
      ..value = totalInsideRes
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('O${defaultSheet.maxRows}'))
      ..value = totalElectricityWater
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('P${defaultSheet.maxRows}'))
      ..value = totalDiscount
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('Q${defaultSheet.maxRows}'))
      ..value = totalFinal
      ..cellStyle = totalCellStyle;

    excel.save(fileName: excelName);
  }

  static void exportGuestReport(
      List<GuestReport?> data, DateTime start, DateTime end) {
    String excelName =
        "OnePMS_GuestReport_${DateUtil.dateToShortString(start)}_${DateUtil.dateToShortString(end)}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle totalCellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("B2"),
        customValue: 'Thời điểm');
    defaultSheet.merge(
        CellIndex.indexByString("C1"), CellIndex.indexByString("E1"),
        customValue: 'Khách chưa phân loại');
    defaultSheet.merge(
        CellIndex.indexByString("F1"), CellIndex.indexByString("H1"),
        customValue: 'Khách nội địa');
    defaultSheet.merge(
        CellIndex.indexByString("I1"), CellIndex.indexByString("K1"),
        customValue: 'Khách ngoại quốc');
    defaultSheet.merge(
        CellIndex.indexByString("L1"), CellIndex.indexByString("L2"),
        customValue: 'Tổng cộng');
    defaultSheet.cell(CellIndex.indexByString("C2")).value = "Khách mới";
    defaultSheet.cell(CellIndex.indexByString("D2")).value = "Inhouse";
    defaultSheet.cell(CellIndex.indexByString("E2")).value = "Tổng cộng";
    defaultSheet.cell(CellIndex.indexByString("F2")).value = "Khách mới";
    defaultSheet.cell(CellIndex.indexByString("G2")).value = "Inhouse";
    defaultSheet.cell(CellIndex.indexByString("H2")).value = "Tổng cộng";
    defaultSheet.cell(CellIndex.indexByString("I2")).value = "Khách mới";
    defaultSheet.cell(CellIndex.indexByString("J2")).value = "Inhouse";
    defaultSheet.cell(CellIndex.indexByString("K2")).value = "Tổng cộng";

    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("C1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("F1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("I1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("L1")).cellStyle = titleCellStyle;

    //write data
    num totalNewGuestUnknown = 0;
    num totalInhouseGuestUnknown = 0;
    num totalGuestUnknown = 0;
    num totalNewGuestDomestic = 0;
    num totalInhouseGuestDomestic = 0;
    num totalGuestDomestic = 0;
    num totalNewGuestForeign = 0;
    num totalInhouseGuestForeign = 0;
    num totalGuestForeign = 0;
    num totalGuest = 0;

    for (var e in data) {
      defaultSheet.merge(
          CellIndex.indexByString('A${defaultSheet.maxRows + 1}'),
          CellIndex.indexByString('B${defaultSheet.maxRows + 1}'),
          customValue: DateUtil.dateToDayMonthYearString(e!.id));
      defaultSheet
          .cell(CellIndex.indexByString('C${defaultSheet.maxRows + 1}'))
          .value = e.newGuestCountUnknown;
      defaultSheet
          .cell(CellIndex.indexByString('D${defaultSheet.maxRows}'))
          .value = e.inhouseCountUnknown;
      defaultSheet
          .cell(CellIndex.indexByString('E${defaultSheet.maxRows}'))
          .value = e.getTotalGuestUnknown();
      defaultSheet
          .cell(CellIndex.indexByString('F${defaultSheet.maxRows}'))
          .value = e.newGuestCountDomestic;
      defaultSheet
          .cell(CellIndex.indexByString('G${defaultSheet.maxRows}'))
          .value = e.inhouseCountDomestic;
      defaultSheet
          .cell(CellIndex.indexByString('H${defaultSheet.maxRows}'))
          .value = e.getTotalGuestDomestic();
      defaultSheet
          .cell(CellIndex.indexByString('I${defaultSheet.maxRows}'))
          .value = e.newGuestCountForeign;
      defaultSheet
          .cell(CellIndex.indexByString('J${defaultSheet.maxRows}'))
          .value = e.inhouseCountForeign;
      defaultSheet
          .cell(CellIndex.indexByString('K${defaultSheet.maxRows}'))
          .value = e.getTotalGuestForeign();
      defaultSheet
          .cell(CellIndex.indexByString('L${defaultSheet.maxRows}'))
          .value = e.getTotalGuest();

      totalNewGuestUnknown += e.newGuestCountUnknown!;
      totalInhouseGuestUnknown += e.inhouseCountUnknown!;
      totalGuestUnknown += e.getTotalGuestUnknown();

      totalNewGuestDomestic += e.newGuestCountDomestic!;
      totalInhouseGuestDomestic += e.inhouseCountDomestic!;
      totalGuestDomestic += e.getTotalGuestDomestic();

      totalNewGuestForeign += e.newGuestCountForeign!;
      totalInhouseGuestForeign += e.inhouseCountForeign!;
      totalGuestForeign += e.getTotalGuestForeign();

      totalGuest += e.getTotalGuest();
    }

    defaultSheet.merge(CellIndex.indexByString('A${defaultSheet.maxRows + 1}'),
        CellIndex.indexByString('B${defaultSheet.maxRows + 1}'),
        customValue: "Tổng cộng");

    defaultSheet
        .cell(CellIndex.indexByString('A${defaultSheet.maxRows + 1}'))
        .cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString('C${defaultSheet.maxRows}'))
      ..value = totalNewGuestUnknown
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('D${defaultSheet.maxRows}'))
      ..value = totalInhouseGuestUnknown
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('E${defaultSheet.maxRows}'))
      ..value = totalGuestUnknown
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('F${defaultSheet.maxRows}'))
      ..value = totalNewGuestDomestic
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('G${defaultSheet.maxRows}'))
      ..value = totalInhouseGuestDomestic
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('H${defaultSheet.maxRows}'))
      ..value = totalGuestDomestic
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('I${defaultSheet.maxRows}'))
      ..value = totalNewGuestForeign
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('J${defaultSheet.maxRows}'))
      ..value = totalInhouseGuestForeign
      ..cellStyle = totalCellStyle;
    defaultSheet.cell(CellIndex.indexByString('K${defaultSheet.maxRows}'))
      ..value = totalGuestForeign
      ..cellStyle = totalCellStyle;

    defaultSheet.cell(CellIndex.indexByString('L${defaultSheet.maxRows}'))
      ..value = totalGuest
      ..cellStyle = totalCellStyle;

    //save
    excel.save(fileName: excelName);
  }

  static void exportHouseKeeping(
      RoomManager roomManager, HouseKeepingPageController controller) {
    String excelName = "OnePMS_GuestReport.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    List<Room> temp = List.from(roomManager.rooms!)
      ..sort((a, b) => a.name!.compareTo(b.name!));

    CellStyle titleCellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.cell(CellIndex.indexByString("A2")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HINT_NAME);
    defaultSheet.cell(CellIndex.indexByString("A2")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUP);
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("G2")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE);
    defaultSheet.cell(CellIndex.indexByString("G2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("A5"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_OUT);
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("B4"), CellIndex.indexByString("B5"));
    defaultSheet.cell(CellIndex.indexByString("B4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("B4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("C4"), CellIndex.indexByString("C5"));
    defaultSheet.cell(CellIndex.indexByString("C4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS);
    defaultSheet.cell(CellIndex.indexByString("C4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("D4"), CellIndex.indexByString("D5"));
    defaultSheet.cell(CellIndex.indexByString("D4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("D4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("E4"), CellIndex.indexByString("E5"));
    defaultSheet.cell(CellIndex.indexByString("E4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("E4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("F4"), CellIndex.indexByString("F5"));
    defaultSheet.cell(CellIndex.indexByString("F4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);
    defaultSheet.cell(CellIndex.indexByString("F4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("G4"), CellIndex.indexByString("G5"));
    defaultSheet.cell(CellIndex.indexByString("G4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_TIME);
    defaultSheet.cell(CellIndex.indexByString("G4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("H4"), CellIndex.indexByString("H5"));
    defaultSheet.cell(CellIndex.indexByString("H4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_TIME);
    defaultSheet.cell(CellIndex.indexByString("H4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("I4"), CellIndex.indexByString("K4"));
    defaultSheet.cell(CellIndex.indexByString("I4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LINE);
    defaultSheet.cell(CellIndex.indexByString("I4")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("L4"), CellIndex.indexByString("N4"));
    defaultSheet.cell(CellIndex.indexByString("L4")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOWEL);
    defaultSheet.cell(CellIndex.indexByString("L4")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("I5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PILLOW);
    defaultSheet.cell(CellIndex.indexByString("I5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("J5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DUVET);
    defaultSheet.cell(CellIndex.indexByString("J5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WORK_SHEET);
    defaultSheet.cell(CellIndex.indexByString("K1")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("K5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SHEET);
    defaultSheet.cell(CellIndex.indexByString("K5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("L5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FACE);
    defaultSheet.cell(CellIndex.indexByString("L5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("M5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BATH);
    defaultSheet.cell(CellIndex.indexByString("M5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("N5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HAND);
    defaultSheet.cell(CellIndex.indexByString("N5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("O5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_MAT);
    defaultSheet.cell(CellIndex.indexByString("O5")).cellStyle = titleCellStyle;

    defaultSheet.cell(CellIndex.indexByString("P5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BATHROBE);
    defaultSheet.cell(CellIndex.indexByString("P5")).cellStyle = titleCellStyle;

    int columnIndex = 16;
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 3),
        CellIndex.indexByColumnRow(
            columnIndex:
                columnIndex + MinibarManager().getActiveItemsId().length - 1,
            rowIndex: 3));
    Data titleMinibarCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 3));
    titleMinibarCell.value = "Minibar";
    titleMinibarCell.cellStyle = titleCellStyle;

    for (var item in MinibarManager().getActiveItemsId()) {
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 4))
          .value = MinibarManager().getItemNameByID(item);
      defaultSheet
          .cell(
              CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 4))
          .cellStyle = titleCellStyle;
      columnIndex++;
    }

    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 3),
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 4));
    Data titleChangeStatusCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 3));
    titleChangeStatusCell.value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS);
    titleChangeStatusCell.cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndex + 1, rowIndex: 3),
        CellIndex.indexByColumnRow(columnIndex: columnIndex + 1, rowIndex: 4));
    Data titleRemartCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: columnIndex + 1, rowIndex: 3));
    titleRemartCell.value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMARK);
    titleRemartCell.cellStyle = titleCellStyle;

    num i = 6;
    for (var room in temp) {
      bool isIoBooking = controller.isOutToday(room.id!) &&
          room.bookingID != null &&
          room.bookingInfo != null &&
          !controller.isInToday(room.id!);
      bool isCheckOutToday =
          !controller.isOutToday(room.id!) && room.bookingID != null;
      // I/O
      defaultSheet.cell(CellIndex.indexByString("A$i")).value =
          (!controller.isOutToday(room.id!) && room.bookingID == null)
              ? controller.getBookingInByRoomID(room.id!) == null
                  ? ""
                  : "A"
              : (room.bookingID != null && !controller.isOutToday(room.id!))
                  ? "O"
                  : isIoBooking
                      ? "D"
                      : "A,D";
      //room name
      defaultSheet.cell(CellIndex.indexByString("B$i")).value = room.name;
      // status
      defaultSheet.cell(CellIndex.indexByString("C$i")).value =
          room.isClean! ? "VC" : "VD";

      // name guest
      defaultSheet.cell(CellIndex.indexByString("D$i")).value = isCheckOutToday
          ? controller.getBookingInByRoomIdInDay(room.id!)?.name ??
              controller.getBookingWithInByRoomID(room.id!)?.name ??
              ""
          : controller.getBookingOutByRoomID(room.id!) != null
              ? controller.getBookingOutByRoomID(room.id!)?.name ?? ""
              : controller.getBookingInByRoomID(room.id!)?.name ?? "";

      // ngày in
      defaultSheet.cell(CellIndex.indexByString("E$i")).value = isCheckOutToday
          ? DateUtil.dateToDayMonthYearString(
              controller.getBookingInByRoomIdInDay(room.id!)?.inDate ??
                  controller.getBookingWithInByRoomID(room.id!)?.inDate)
          : controller.getBookingInByRoomID(room.id!) != null
              ? DateUtil.dateToDayMonthYearString(
                  controller.getBookingInByRoomID(room.id!)?.inDate)
              : DateUtil.dateToDayMonthYearString(
                  controller.getBookingOutByRoomID(room.id!)?.inDate);

      //ngày out
      defaultSheet.cell(CellIndex.indexByString("F$i")).value = isCheckOutToday
          ? DateUtil.dateToDayMonthYearString(
              controller.getBookingInByRoomIdInDay(room.id!)?.outDate ??
                  controller.getBookingWithInByRoomID(room.id!)?.outDate)
          : controller.getBookingInByRoomID(room.id!) != null
              ? DateUtil.dateToDayMonthYearString(
                  controller.getBookingInByRoomID(room.id!)?.outDate)
              : DateUtil.dateToDayMonthYearString(
                  controller.getBookingOutByRoomID(room.id!)?.outDate);
      i++;
    }
    num n = i + 3;
    defaultSheet.cell(CellIndex.indexByString("A$n")).value =
        "A : ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL)}";
    defaultSheet.cell(CellIndex.indexByString("A${n + 1}")).value =
        "D : ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE)}";
    defaultSheet.cell(CellIndex.indexByString("A${n + 2}")).value =
        "O : ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OCCUPIE)}";
    defaultSheet.cell(CellIndex.indexByString("A${n + 3}")).value =
        "VC : ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CLEAN_ROOM)}";
    defaultSheet.cell(CellIndex.indexByString("A${n + 4}")).value =
        "VD : ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DIRTY_ROOM)}";
    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckCashFlowStatement(
      List<RevenueLog?> revenueLogs, RevenueLogsController controller) {
    String excelName =
        "OnePMS_Check_Cash_Flow_Statement_Report_${DateUtil.dateToShortString(controller.startDate)}_${DateUtil.dateToShortString(controller.endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();
    String headerColorHex = "ff59b69e";

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    // //title for sheets
    CellStyle titelCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        fontSize: 12,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 10,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCellStyle = CellStyle(
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("G3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNT_BOOK);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 15,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.merge(
        CellIndex.indexByString("A4"), CellIndex.indexByString("G4"));
    defaultSheet.cell(CellIndex.indexByString("A4")).value =
        "Từ: ${DateUtil.dateToDayMonthYearString(controller.startDate)} - Đến: ${DateUtil.dateToDayMonthYearString(controller.endDate)}";
    defaultSheet.cell(CellIndex.indexByString("A4")).cellStyle = CellStyle(
        fontSize: 12,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    defaultSheet.cell(CellIndex.indexByString("F5")).value = "ĐVT: VNĐ";

    defaultSheet.cell(CellIndex.indexByString("A7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DATE);
    defaultSheet.cell(CellIndex.indexByString("A7")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("B7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
    defaultSheet.cell(CellIndex.indexByString("B7")).cellStyle =
        headerCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("C7"), CellIndex.indexByString("D7"));
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("E7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RECEIPTS);
    defaultSheet.cell(CellIndex.indexByString("E7")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("F7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT_EXCEL);
    defaultSheet.cell(CellIndex.indexByString("F7")).cellStyle =
        headerCellStyle;

    defaultSheet.cell(CellIndex.indexByString("G7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BALANCE);
    defaultSheet.cell(CellIndex.indexByString("G7")).cellStyle =
        headerCellStyle;

    Map<String, int> methodIndexes = {};
    bool isExcelFileHasData = false;
    num i = 8;

    for (var element in revenueLogs) {
      if (!methodIndexes.containsKey(element!.method)) {
        methodIndexes[element.method] = 0;
      }
    }

    for (var idMethod in methodIndexes.keys) {
      double totalMoneyFirst = 0;
      num totalMoneyLater = 0;
      double totalMoneyClosingBalace = 0;

      ///
      defaultSheet.merge(
          CellIndex.indexByString("C$i"), CellIndex.indexByString("D$i"));
      defaultSheet.cell(CellIndex.indexByString("C$i ")).value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OPENING_BALANCE);
      defaultSheet.cell(CellIndex.indexByString("C$i ")).cellStyle =
          titelCellStyle;

      defaultSheet.cell(CellIndex.indexByString("G$i ")).value =
          controller.getAmountOpeningBalanceByIdMethod(idMethod);
      defaultSheet.cell(CellIndex.indexByString("G$i ")).cellStyle =
          contentCellStyle;

      i = i + 1;
      for (var e
          in revenueLogs.where((element) => element!.method == idMethod)) {
        methodIndexes[e!.method] = methodIndexes[e.method]! + 1;

        defaultSheet.cell(CellIndex.indexByString("A$i")).value =
            DateUtil.dateToDayMonthYearHourMinuteString(e.created!);
        defaultSheet.cell(CellIndex.indexByString("A$i")).cellStyle =
            titelCellStyle;

        defaultSheet.cell(CellIndex.indexByString("B$i")).value = e.type ==
                TypeRevenueLog.typeTransfer
            ? '${PaymentMethodManager().getPaymentMethodNameById(e.method)} -> ${PaymentMethodManager().getPaymentMethodNameById(e.methodTo!)}'
            : PaymentMethodManager().getPaymentMethodNameById(e.method);
        defaultSheet.cell(CellIndex.indexByString("B$i")).cellStyle =
            contentCellStyle;

        defaultSheet.merge(
            CellIndex.indexByString("C$i"), CellIndex.indexByString("D$i"));
        defaultSheet.cell(CellIndex.indexByString("C$i")).value = e.desc;
        defaultSheet.cell(CellIndex.indexByString("C$i")).cellStyle = CellStyle(
            verticalAlign: VerticalAlign.Center,
            horizontalAlign: HorizontalAlign.Left,
            fontSize: 10,
            fontFamily: getFontFamily(FontFamily.Arial));

        defaultSheet.cell(CellIndex.indexByString("E$i")).value =
            e.type != TypeRevenueLog.typeMinus &&
                    e.type != TypeRevenueLog.typeTransfer &&
                    e.type != TypeRevenueLog.typeActualPayment
                ? e.amount.toString()
                : "";
        defaultSheet.cell(CellIndex.indexByString("E$i")).cellStyle =
            contentCellStyle;

        defaultSheet.cell(CellIndex.indexByString("F$i")).value =
            e.type == TypeRevenueLog.typeMinus ||
                    e.type == TypeRevenueLog.typeTransfer ||
                    e.type == TypeRevenueLog.typeActualPayment
                ? e.amount.toString()
                : "";
        defaultSheet.cell(CellIndex.indexByString("F$i")).cellStyle =
            contentCellStyle;

        defaultSheet.cell(CellIndex.indexByString("G$i")).value =
            controller.getAmountBalanceAfterTransaction(e) > 0
                ? controller.getAmountBalanceAfterTransaction(e)
                : controller.getAmountBalanceAfterTransaction(e) > 0
                    ? "- ${controller.getAmountBalanceAfterTransaction(e)}"
                    : controller.getAmountBalanceAfterTransaction(e);

        defaultSheet.cell(CellIndex.indexByString("G$i")).cellStyle =
            contentCellStyle;
        isExcelFileHasData = true;
        totalMoneyFirst +=
            (e.type != 2 && e.type != 4 && e.type != 3) ? e.amount : 0;
        totalMoneyLater +=
            e.type == 2 || e.type == 4 || e.type == 3 ? e.amount : 0;

        totalMoneyClosingBalace =
            controller.getAmountBalanceAfterTransaction(e) > 0
                ? controller.getAmountBalanceAfterTransaction(e)
                : controller.getAmountBalanceAfterTransaction(e) > 0
                    ? controller.getAmountBalanceAfterTransaction(e)
                    : controller.getAmountBalanceAfterTransaction(e);

        ///
        if (methodIndexes[e.method] ==
            revenueLogs
                .where((element) => element!.method == idMethod)
                .length) {
          ///
          defaultSheet.merge(CellIndex.indexByString("C${i + 2}"),
              CellIndex.indexByString("D${i + 2}"));
          defaultSheet.cell(CellIndex.indexByString("C${i + 2}")).value =
              UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_COSTS_INCURRED);
          defaultSheet.cell(CellIndex.indexByString("C${i + 2}")).cellStyle =
              titelCellStyle;

          defaultSheet.cell(CellIndex.indexByString("E${i + 2}")).value =
              totalMoneyFirst;
          defaultSheet.cell(CellIndex.indexByString("E${i + 2}")).cellStyle =
              contentCellStyle;

          defaultSheet.cell(CellIndex.indexByString("F${i + 2}")).value =
              totalMoneyLater;
          defaultSheet.cell(CellIndex.indexByString("F${i + 2}")).cellStyle =
              contentCellStyle;

          ///
          defaultSheet.merge(CellIndex.indexByString("C${i + 3}"),
              CellIndex.indexByString("D${i + 3}"));
          defaultSheet.cell(CellIndex.indexByString("C${i + 3}")).value =
              UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_CLOSING_BALANCE);
          defaultSheet.cell(CellIndex.indexByString("C${i + 3}")).cellStyle =
              titelCellStyle;

          defaultSheet.cell(CellIndex.indexByString("G${i + 3}")).value =
              totalMoneyClosingBalace;
          defaultSheet.cell(CellIndex.indexByString("G${i + 3}")).cellStyle =
              contentCellStyle;

          i = i + 4;
        }
        i++;
      }
    }
    // Saving the files
    if (isExcelFileHasData) {
      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportBookingBreakfast(List<Booking> booking, String selectMeal) {
    String excelName = "OnePMS_${selectMeal}_For_Booking.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    for (int i = 0; i < 6; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalGuest = 0;
    for (var booking in booking) {
      defaultSheet.insertRowIterables([
        RoomManager().getNameRoomById(booking.room!),
        booking.name,
        (booking.child! + booking.adult!),
        booking.phone,
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
      ], defaultSheet.maxRows);
      totalGuest += (booking.child! + booking.adult!);
      isExcelFileHasData = true;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_TOTAL);
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalGuestCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indexOfMaxRow));
      totalGuestCell.value = NumberUtil.numberFormat.format(totalGuest);
      totalGuestCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportBookingToDayReport(List<Booking> booking) {
    String excelName = "OnePMS_Booking_To_Day_Report.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOMTYPE);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_GUEST_QUANTITY);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT_DATE);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE);
    defaultSheet.cell(CellIndex.indexByString("J1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL);
    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REVENUE);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    for (int i = 0; i < 11; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num allRevenueOfBooking = 0;
    num averageRoomPriceBooking = 0;
    for (var booking in booking) {
      defaultSheet.insertRowIterables([
        booking.sID == booking.id
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        booking.sID == booking.id
            ? booking.roomTypeID
            : RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID!),
        booking.sID,
        booking.name,
        SourceManager().getSourceNameByID(booking.sourceID!),
        (booking.child! + booking.adult!),
        DateUtil.dateToDayMonthString(booking.inDate!),
        DateUtil.dateToDayMonthString(booking.outDate!),
        booking.phone,
        NumberUtil.numberFormat
            .format(booking.getRoomCharge() / booking.lengthStay!),
        NumberUtil.numberFormat.format(booking.getRevenue())
      ], defaultSheet.maxRows);
      allRevenueOfBooking += booking.getRevenue();
      averageRoomPriceBooking +=
          (booking.getRoomCharge() / booking.lengthStay!);
      isExcelFileHasData = true;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: indexOfMaxRow));
      totalTitleCell.value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAllRevenueOfBookingCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: indexOfMaxRow));
      totalAllRevenueOfBookingCell.value =
          NumberUtil.numberFormat.format(allRevenueOfBooking);
      totalAllRevenueOfBookingCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalAverageRoomPriceBookingCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
      totalAverageRoomPriceBookingCell.value =
          NumberUtil.numberFormat.format(averageRoomPriceBooking);
      totalAverageRoomPriceBookingCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportServiceReport(
      DateTime startDate, DateTime endDate, List<Service> serviceData) {
    String excelName =
        "OnePMS_Sale_Report_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SALER);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    for (int i = 0; i < 9; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalAllService = 0;
    for (var service in serviceData) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(service.used!.toDate()),
        service.name,
        RoomManager().getNameRoomById(service.room!),
        DateUtil.dateToDayMonthString(service.inDate!),
        DateUtil.dateToDayMonthString(service.outDate!),
        service.cat,
        service.total,
        service.status,
        service.saler
      ], defaultSheet.maxRows);
      totalAllService += service.total!;
      isExcelFileHasData = true;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalGuestCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow));
      totalGuestCell.value = NumberUtil.numberFormat.format(totalAllService);
      totalGuestCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportBookingsReport(DateTime startDate, DateTime endDate,
      List<Booking> bookingData, Map<String, num> mapCost) {
    String excelName =
        "OnePMS_Booking_By_Sale_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OUT);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM_CHARGE_COMPACT);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SERVICE);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DISCOUNT);
    defaultSheet.cell(CellIndex.indexByString("H1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("I1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PAYMENT);
    defaultSheet.cell(CellIndex.indexByString("J1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_REMAIN);
    defaultSheet.cell(CellIndex.indexByString("K1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACCOUNTING);
    defaultSheet.cell(CellIndex.indexByString("L1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PROFIT);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));
    for (int i = 0; i < 12; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    bool isExcelFileHasData = false;
    num totalProfit = 0, totalAll = 0, totalCost = 0;
    for (var booking in bookingData) {
      defaultSheet.insertRowIterables([
        booking.name,
        booking.sID == booking.id
            ? booking.room
            : RoomManager().getNameRoomById(booking.room!),
        DateUtil.dateToDayMonthYearHourMinuteString(booking.inDate!),
        DateUtil.dateToDayMonthYearHourMinuteString(booking.outDate!),
        NumberUtil.numberFormat.format(booking.getRoomCharge()),
        NumberUtil.numberFormat.format(booking.getServiceCharge()),
        booking.discount == 0
            ? "0"
            : "-${NumberUtil.numberFormat.format(booking.discount)}",
        NumberUtil.numberFormat.format(booking.getTotalCharge()),
        NumberUtil.numberFormat.format(booking.deposit),
        NumberUtil.numberFormat.format(booking.getRemaining()),
        NumberUtil.numberFormat.format(mapCost[booking.sID]),
        NumberUtil.numberFormat
            .format(booking.getTotalCharge()! - mapCost[booking.sID]!)
      ], defaultSheet.maxRows);
      totalProfit += (booking.getTotalCharge()! - mapCost[booking.sID]!);
      totalAll += booking.getTotalCharge()!;
      totalCost += mapCost[booking.sID]!.toInt();
      isExcelFileHasData = true;
    }

    // Saving the files
    if (isExcelFileHasData) {
      int indexOfMaxRow = defaultSheet.maxRows;
      //total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value =
          UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
      totalTitleCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalBooking = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
      totalBooking.value = NumberUtil.numberFormat.format(totalAll);
      totalBooking.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalCostCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: indexOfMaxRow));
      totalCostCell.value = NumberUtil.numberFormat.format(totalCost);
      totalCostCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      Data totalProfiCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: indexOfMaxRow));
      totalProfiCell.value = NumberUtil.numberFormat.format(totalProfit);
      totalProfiCell.cellStyle = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Right,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));

      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportDepositForm(Booking? booking, Deposit deposit) {
    String excelName =
        "OnePMS_Deposit_${DateUtil.dateToDayMonthYearHourMinuteString(deposit.created!.toDate())}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    String lastCol = "F";
    String headerColorHex = "ff59b69e";

    //header
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("C3"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_DEPOSIT_FORM);
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = CellStyle(
        fontSize: 18,
        bold: true,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff",
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
        textWrapping: TextWrapping.WrapText);

    //hotel info
    CellStyle hotelInfoStyle = CellStyle(
        fontSize: 14,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: headerColorHex,
        fontColorHex: "ffffff");
    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("${lastCol}1"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        GeneralManager.hotel!.name;
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D2"), CellIndex.indexByString("${lastCol}2"));
    defaultSheet.cell(CellIndex.indexByString("D2")).value =
        '${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}';
    defaultSheet.cell(CellIndex.indexByString("D2")).cellStyle = hotelInfoStyle;
    defaultSheet.merge(
        CellIndex.indexByString("D3"), CellIndex.indexByString("${lastCol}3"));
    defaultSheet.cell(CellIndex.indexByString("D3")).value =
        GeneralManager.hotel!.street;
    defaultSheet.cell(CellIndex.indexByString("D3")).cellStyle = hotelInfoStyle;

    //Guest info
    defaultSheet.merge(
        CellIndex.indexByString("A6"), CellIndex.indexByString("B6"));
    defaultSheet.merge(
        CellIndex.indexByString("A8"), CellIndex.indexByString("B8"));
    defaultSheet.merge(
        CellIndex.indexByString("A10"), CellIndex.indexByString("B10"));

    defaultSheet.cell(CellIndex.indexByString("A5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NAME);
    defaultSheet.cell(CellIndex.indexByString("A5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("A6")).value = booking!.name;

    //room + source
    defaultSheet.cell(CellIndex.indexByString("C5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM);
    defaultSheet.cell(CellIndex.indexByString("C5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C6")).value =
        RoomManager().getNameRoomById(booking.room!);
    defaultSheet.cell(CellIndex.indexByString("C7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE);
    defaultSheet.cell(CellIndex.indexByString("C7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C8")).value = booking.sourceName;
    defaultSheet.cell(CellIndex.indexByString("C9")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID);
    defaultSheet.cell(CellIndex.indexByString("C9")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("C10")).value = booking.sID;

    //in date + out date
    defaultSheet.cell(CellIndex.indexByString("D5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ARRIVAL_DATE);
    defaultSheet.cell(CellIndex.indexByString("D5")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D6")).value =
        DateUtil.dateToDayMonthYearHourMinuteString(
            booking.inTime ?? booking.inDate!);
    defaultSheet.cell(CellIndex.indexByString("D7")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DEPARTURE_DATE);
    defaultSheet.cell(CellIndex.indexByString("D7")).cellStyle = CellStyle(
      italic: true,
    );
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        DateUtil.dateToDayMonthYearHourMinuteString(booking.outTime!);

    //invoice total
    defaultSheet.merge(
        CellIndex.indexByString("E5"), CellIndex.indexByString("${lastCol}5"));
    defaultSheet.merge(
        CellIndex.indexByString("E6"), CellIndex.indexByString("${lastCol}10"));
    defaultSheet.cell(CellIndex.indexByString("E5")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("E5")).cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    defaultSheet.cell(CellIndex.indexByString("E6")).value =
        NumberUtil.numberFormat.format(deposit.amount);
    defaultSheet.cell(CellIndex.indexByString("E6")).cellStyle = CellStyle(
        fontSize: 15,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    //title
    defaultSheet.merge(
        CellIndex.indexByString("A12"), CellIndex.indexByString("B12"));
    defaultSheet.cell(CellIndex.indexByString("A12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("A12")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("C12"), CellIndex.indexByString("F12"));
    defaultSheet.cell(CellIndex.indexByString("C12")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DETAIL);
    defaultSheet.cell(CellIndex.indexByString("C12")).cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("A13"), CellIndex.indexByString("B13"));
    defaultSheet.cell(CellIndex.indexByString("A13")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_CREATED_TIME);
    defaultSheet.cell(CellIndex.indexByString("A13")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("C13"), CellIndex.indexByString("F13"));
    defaultSheet.cell(CellIndex.indexByString("C13")).value =
        DateUtil.dateToDayMonthYearHourMinuteString(deposit.created!.toDate());
    defaultSheet.cell(CellIndex.indexByString("C13")).cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("A14"), CellIndex.indexByString("B14"));
    defaultSheet.cell(CellIndex.indexByString("A14")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT_MONEY);
    defaultSheet.cell(CellIndex.indexByString("A14")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("C14"), CellIndex.indexByString("F14"));
    defaultSheet.cell(CellIndex.indexByString("C14")).value =
        NumberUtil.numberFormat.format(deposit.amount);
    defaultSheet.cell(CellIndex.indexByString("C14")).cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("A15"), CellIndex.indexByString("B15"));
    defaultSheet.cell(CellIndex.indexByString("A15")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_METHOD);
    defaultSheet.cell(CellIndex.indexByString("A15")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("C15"), CellIndex.indexByString("F15"));
    defaultSheet.cell(CellIndex.indexByString("C15")).value =
        PaymentMethodManager().getPaymentMethodNameById(deposit.method!);
    defaultSheet.cell(CellIndex.indexByString("C15")).cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("A16"), CellIndex.indexByString("B16"));
    defaultSheet.cell(CellIndex.indexByString("A16")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DESCRIPTION_FULL);
    defaultSheet.cell(CellIndex.indexByString("A16")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("C16"), CellIndex.indexByString("F16"));
    defaultSheet.cell(CellIndex.indexByString("C16")).value = deposit.desc!;
    defaultSheet.cell(CellIndex.indexByString("C16")).cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("D18"), CellIndex.indexByString("E18"));
    defaultSheet.cell(CellIndex.indexByString("D18")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("D18")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("F18"), CellIndex.indexByString("F18"));
    defaultSheet.cell(CellIndex.indexByString("F18")).value =
        NumberUtil.numberFormat.format(deposit.amount);
    defaultSheet.cell(CellIndex.indexByString("F18")).cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center);

    defaultSheet.merge(
        CellIndex.indexByString("B20"), CellIndex.indexByString("B20"));
    defaultSheet.cell(CellIndex.indexByString("B20")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_GUEST_SIGNATURE);
    defaultSheet.cell(CellIndex.indexByString("B20")).cellStyle =
        CellStyle(bold: true);

    defaultSheet.merge(
        CellIndex.indexByString("E20"), CellIndex.indexByString("E20"));
    defaultSheet.cell(CellIndex.indexByString("E20")).value =
        UITitleUtil.getTitleByCode(UITitleCode.PDF_RECEPTIONIST_SIGNATURE);
    defaultSheet.cell(CellIndex.indexByString("E20")).cellStyle =
        CellStyle(bold: true);

    //save
    excel.save(fileName: excelName);
  }

  static void exporotBooking(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return;
    }
    print(3);
    String excelName = "OnePMS_booking.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    //title for sheets
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Thời gian";
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Nguồn";
    defaultSheet.cell(CellIndex.indexByString("C1")).value = "Sid";
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Tên";
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "In";
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Out";
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Gía";
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Gía";

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 6; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
    }
    bool isExcelFileHasData = false;
    for (var booking in bookings) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(booking.outTime!),
        booking.sourceName,
        booking.sID ?? '',
        booking.name,
        DateUtil.dateToDayMonthYearString(booking.inDate!),
        DateUtil.dateToDayMonthYearString(booking.outDate!),
        NumberUtil.numberFormat.format(booking.getRoomCharge()),
        booking.group!
            ? booking.roomTypeID
            : RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID),
      ], defaultSheet.maxRows);
      isExcelFileHasData = true;
    }
    if (isExcelFileHasData) {
      excel.save(fileName: excelName);
    }
  }

  static Map<String, dynamic>? readWarehousetNoteFromExcelFile(
      FilePickerResult pickedFile, String noteType) {
    Map<String, dynamic>? readResult;
    Uint8List? bytes = pickedFile.files.single.bytes;
    Excel excel;
    try {
      excel = Excel.decodeBytes(bytes!.toList());
    } catch (e) {
      return readResult;
    }
    Sheet? noteData = excel.sheets['$noteType note'];
    if (noteData != null) {
      int columns = 0;
      switch (noteType) {
        case WarehouseNotesType.import:
          columns = 5;
          readResult = WarehouseNoteImport.fromExcelFile(noteData);
          break;
        case WarehouseNotesType.export:
          columns = 3;
          readResult = WarehouseNoteExport.fromExcelFile(noteData);
          break;
        case WarehouseNotesType.liquidation:
          columns = 4;
          readResult = WarehouseNoteLiquidation.fromExcelFile(noteData);
          break;
        case WarehouseNotesType.lost:
          columns = 4;
          readResult = WarehouseNoteLost.fromExcelFile(noteData);
          break;
        case WarehouseNotesType.transfer:
          columns = 4;
          readResult = WarehouseNoteTransfer.fromExcelFile(noteData);
          break;
      }
      List<int> errors = readResult!['errors'];
      if (errors.isNotEmpty) {
        for (var errorRowIndex in errors) {
          for (var i = 0; i < columns; i++) {
            Data cell = noteData.cell(CellIndex.indexByColumnRow(
                columnIndex: i, rowIndex: errorRowIndex));
            cell.value ??= ' ';

            cell.cellStyle = CellStyle(
                backgroundColorHex: '#F4B084',
                fontColorHex: '#000000',
                fontSize: 11,
                fontFamily: 'Calibri');
          }
        }
      }
      readResult['excel'] = excel;
    }

    return readResult;
  }

  static void exporteImportItemWareHouse(
      List<WarehouseNote> importItem, DateTime? startDate, DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_IMPORT_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_HAS_COST);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 6; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }

    num totalMoney = 0;
    for (var e in importItem) {
      if (e is WarehouseNoteReturn) {
        continue;
      }
      ImportController importController =
          ImportController(e as WarehouseNoteImport, null, false);
      ItemImport itemImport = importController.listItem.first;
      WarehouseNoteImport import = e;
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(import.createdTime!),
        import.invoiceNumber ?? "",
        itemImport.supplier,
        import.creator,
        import.getTotal(),
        (import.totalCost == 0 || import.totalCost == null)
            ? UITitleUtil.getTitleByCode(UITitleCode.NO)
            : UITitleUtil.getTitleByCode(UITitleCode.YES)
      ], defaultSheet.maxRows);
      totalMoney += import.getTotal();
    }

    int indexOfMaxRow = defaultSheet.maxRows;
    //total row
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow));
    Data totalTitleCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
    totalTitleCell.value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);
    totalTitleCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    Data totalAmountCell = defaultSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow));
    totalAmountCell.value = totalMoney;
    totalAmountCell.cellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Right,
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //save
    excel.save(fileName: excelName);
  }

  static void exportExporteItemWareHouse(
      List<WarehouseNote> exportItem, DateTime? startDate, DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_EXPORT_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 3; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }
    for (var e in exportItem) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(e.createdTime!),
        e.invoiceNumber ?? "",
        e.creator,
      ], defaultSheet.maxRows);
    }
    //save
    excel.save(fileName: excelName);
  }

  static void exportLiquidationItemWareHouse(
      List<WarehouseNote> liquidationtItem,
      DateTime? startDate,
      DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_LIQUIDATION_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 3; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }

    for (var e in liquidationtItem) {
      WarehouseNoteLiquidation liquidation = e as WarehouseNoteLiquidation;
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(liquidation.createdTime!),
        liquidation.invoiceNumber ?? "",
        liquidation.creator,
      ], defaultSheet.maxRows);
    }
    //save
    excel.save(fileName: excelName);
  }

  static void exportTransferItemWareHouse(List<WarehouseNote> transferItem,
      DateTime? startDate, DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_TRANSFER_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 3; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }

    for (var e in transferItem) {
      WarehouseNoteTransfer transfer = e as WarehouseNoteTransfer;
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(transfer.createdTime!),
        transfer.invoiceNumber ?? "",
        transfer.creator,
      ], defaultSheet.maxRows);
    }
    //save
    excel.save(fileName: excelName);
  }

  static void exportLostItemWareHouse(
      List<WarehouseNote> lostItem, DateTime? startDate, DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_LOST_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 3; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }

    for (var e in lostItem) {
      WarehouseNoteLost lost = e as WarehouseNoteLost;
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(lost.createdTime!),
        lost.invoiceNumber ?? "",
        lost.creator,
      ], defaultSheet.maxRows);
    }
    //save
    excel.save(fileName: excelName);
  }

  static void exportCheckItemWareHouse(List<WarehouseNote> dataWarehouseNote,
      DateTime? startDate, DateTime? endDate) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_CHECK_ITEM)}_${startDate != null ? DateUtil.dateToShortString(startDate) : "startDate"}_${endDate != null ? DateUtil.dateToShortString(endDate) : "endDate"}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("A1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TIME);
    defaultSheet.cell(CellIndex.indexByString("B1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER);
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS);
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATOR);
    defaultSheet.cell(CellIndex.indexByString("F1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECKER);
    defaultSheet.cell(CellIndex.indexByString("G1")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES);

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    for (int i = 0; i < 7; i++) {
      defaultSheet.row(0)[i]!.cellStyle = titleCellStyle;
      defaultSheet.setColumnAutoFit(i);
    }

    for (var note in dataWarehouseNote) {
      defaultSheet.insertRowIterables([
        DateUtil.dateToDayMonthHourMinuteString(note.createdTime!),
        note.invoiceNumber,
        WarehouseManager().getWarehouseNameById(
                (note as WarehouseNoteCheck).warehouse!) ??
            '',
        UITitleUtil.getTitleByCode(note.status!),
        note.creator,
        note.checker,
        note.note
      ], defaultSheet.maxRows);
    }

    //save
    excel.save(fileName: excelName);
  }

  static void exportImportInvoice(WarehouseNoteImport import) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_IMPORT_INVOICE)}_${import.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    // Draw header
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 3),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IMPORT_NOTE_WAREHOUSE),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );
    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 4),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        ' ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}: ${DateUtil.dateToDayMonthYearHourMinuteString(import.createdTime!)}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 5),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${import.invoiceNumber}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    // Title for sheets
    defaultSheet.cell(CellIndex.indexByString("A8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_ITEM);
    defaultSheet.cell(CellIndex.indexByString("B8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT);
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SUPPLIER);
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("E8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("F8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE);
    defaultSheet.cell(CellIndex.indexByString("G8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL);

    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    for (int i = 0; i <= 6; i++) {
      defaultSheet.row(7)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    double totalAmount = 0;
    double totalPrice = 0;
    for (var item in import.list!) {
      totalAmount += item.amount!;
      totalPrice += item.price! * item.amount!;

      defaultSheet.insertRowIterables([
        ItemManager().getItemNameByID(item.id!),
        ItemManager().getItemUnitByID(item.id!),
        SupplierManager().getSupplierNameByID(item.supplier),
        WarehouseManager().getWarehouseNameById(item.warehouse!),
        item.amount,
        item.price,
        item.price! * item.amount!
      ], defaultSheet.maxRows);
    }

    int indexOfMaxRow = defaultSheet.maxRows;

    //total row
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
      cellStyle: titleCellStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
      ),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow),
      totalAmount,
      cellStyle: titleCellStyle,
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow),
      '',
      cellStyle: titleCellStyle,
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow),
      totalPrice,
      cellStyle: titleCellStyle,
    );

    //tong so tien bang chu
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 2),
      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL)}: ${List.generate(100, (index) => ".").join()}',
    );

    //chu ki
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNT),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_APPROVER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );

    //save
    excel.save(fileName: excelName);
  }

  static void exportExportInvoice(WarehouseNoteExport? export) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_EXPORT_INVOICE)}_${export!.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    // Draw header
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      UITitleUtil.getTitleByCode(UITitleCode.HEADER_EXPORT_ITEM_WAREHOUSE),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );
    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 4),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}: ${DateUtil.dateToDayMonthYearHourMinuteString(export.createdTime!)}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 5),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${export.invoiceNumber}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    // Title for sheets
    defaultSheet.cell(CellIndex.indexByString("A8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_ITEM);
    defaultSheet.cell(CellIndex.indexByString("B8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT);
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);

    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    for (int i = 0; i <= 3; i++) {
      defaultSheet.row(7)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    for (var itemExport in export.list!) {
      var itemConfig = ItemManager().getItemById(itemExport.id!);
      defaultSheet.insertRowIterables([
        itemConfig!.name,
        itemConfig.unit,
        WarehouseManager().getWarehouseNameById(itemExport.warehouse!),
        itemExport.amount,
      ], defaultSheet.maxRows);
    }

    int indexOfMaxRow = defaultSheet.maxRows;

    //chu ki
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTANT),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_APPROVER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );

    //save
    excel.save(fileName: excelName);
  }

  static void exportLiquidationInvoice(WarehouseNoteLiquidation liquidation) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_LIQUIDATION_INVOICE)}_${liquidation.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    // Draw header
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 3),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      UITitleUtil.getTitleByCode(
          UITitleCode.TABLEHEADER_WAREHOUSE_LIQUIDATION_NOTE),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );
    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 4),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}: ${DateUtil.dateToDayMonthYearHourMinuteString(liquidation.createdTime!)}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 5),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${liquidation.invoiceNumber}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    // Title for sheets
    defaultSheet.cell(CellIndex.indexByString("A8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_ITEM);
    defaultSheet.cell(CellIndex.indexByString("B8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT);
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_EXPORT_ITEM);
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);
    defaultSheet.cell(CellIndex.indexByString("E8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT_PRICE);
    defaultSheet.cell(CellIndex.indexByString("F8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL);

    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    for (int i = 0; i <= 5; i++) {
      defaultSheet.row(7)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    double totalAmount = 0;
    double totalPrice = 0;
    for (var itemLiquidation in liquidation.list!) {
      var itemConfig = ItemManager().getItemById(itemLiquidation.id!);
      totalAmount += itemLiquidation.amount!;
      totalPrice += itemLiquidation.price! * itemLiquidation.amount!;

      defaultSheet.insertRowIterables([
        itemConfig!.name,
        itemConfig.unit,
        WarehouseManager().getWarehouseNameById(itemLiquidation.warehouse!),
        itemLiquidation.amount,
        itemLiquidation.price,
        itemLiquidation.price! * itemLiquidation.amount!,
      ], defaultSheet.maxRows);
    }

    int indexOfMaxRow = defaultSheet.maxRows;

    //total row
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indexOfMaxRow),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
      cellStyle: titleCellStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
      ),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow),
      totalAmount,
      cellStyle: titleCellStyle,
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow),
      '',
      cellStyle: titleCellStyle,
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow),
      totalPrice,
      cellStyle: titleCellStyle,
    );

    //tong so tien bang chu
    defaultSheet
      ..merge(CellIndex.indexByString('A${indexOfMaxRow + 3}'),
          CellIndex.indexByString('H${indexOfMaxRow + 3}'))
      ..updateCell(
        CellIndex.indexByString('A${indexOfMaxRow + 3}'),
        '${UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL)}: ${List.generate(100, (index) => ".").join()}',
      );

    //chu ki
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTANT),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_APPROVER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );

    //save
    excel.save(fileName: excelName);
  }

  static void exportTransferInvoice(WarehouseNoteTransfer transfer) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_TRANSFER_INVOICE)}_${transfer.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    // Draw header
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 3),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      UITitleUtil.getTitleByCode(
          UITitleCode.TABLEHEADER_WAREHOUSE_TRANSFER_NOTE),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );
    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 4),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}: ${DateUtil.dateToDayMonthYearHourMinuteString(transfer.createdTime!)}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 5),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${transfer.invoiceNumber}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    // Title for sheets
    UITitleUtil.getTitleByCode(UITitleCode.HINT_ITEM);
    defaultSheet.cell(CellIndex.indexByString("B8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HINT_UNIT);
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EXPORT_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RECEIVING_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("E8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT);

    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    for (int i = 0; i <= 5; i++) {
      defaultSheet.row(7)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    for (var itemLiquidation in transfer.list!) {
      var itemConfig = ItemManager().getItemById(itemLiquidation.id!);

      defaultSheet.insertRowIterables([
        itemConfig!.name,
        itemConfig.unit,
        WarehouseManager().getWarehouseNameById(itemLiquidation.fromWarehouse!),
        WarehouseManager().getWarehouseNameById(itemLiquidation.toWarehouse!),
        itemLiquidation.amount,
      ], defaultSheet.maxRows);
    }

    int indexOfMaxRow = defaultSheet.maxRows;

    //chu ki
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTANT),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_APPROVER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );

    //save
    excel.save(fileName: excelName);
  }

  static void exportLostInvoice(WarehouseNoteLost lost) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_LOST_INVOICE)}_${lost.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );
    // Draw header
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 3),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3),
      UITitleUtil.getTitleByCode(UITitleCode.LOSS_AND_DAMAGE_REPORT),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );
    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 4),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}: ${DateUtil.dateToDayMonthYearHourMinuteString(lost.createdTime!)}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    defaultSheet
      ..merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 5),
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 5),
      )
      ..updateCell(
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 5),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)}: ${lost.invoiceNumber}',
        cellStyle: CellStyle(
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontColorHex: 'FFFF0000',
          fontFamily: getFontFamily(FontFamily.Arial),
        ),
      );

    // Title for sheets
    defaultSheet.cell(CellIndex.indexByString("A8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HINT_ITEM);
    defaultSheet.cell(CellIndex.indexByString("B8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HINT_UNIT);
    defaultSheet.cell(CellIndex.indexByString("C8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_WAREHOUSE);
    defaultSheet.cell(CellIndex.indexByString("D8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.HINT_STATUS);
    defaultSheet.cell(CellIndex.indexByString("E8")).value =
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_QUANTITY);

    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    for (int i = 0; i < 5; i++) {
      defaultSheet.row(7)[i]!.cellStyle = titleCellStyle;
    }

    //write data
    double totalAmount = 0;
    for (var itemLost in lost.list!) {
      var itemConfig = ItemManager().getItemById(itemLost.id!);
      totalAmount += itemLost.amount!;
      String status = '';

      switch (itemLost.status) {
        case LostStatus.lost:
          status = UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LOST_ITEM);
          break;
        case LostStatus.expired:
          status = UITitleUtil.getTitleByCode(UITitleCode.STATUS_EXPIRED);
          break;
        case LostStatus.broken:
          status = UITitleUtil.getTitleByCode(UITitleCode.STATUS_DAMAGE);
          break;
        default:
      }

      defaultSheet.insertRowIterables([
        itemConfig!.name,
        itemConfig.unit,
        WarehouseManager().getWarehouseNameById(itemLost.warehouse!),
        status,
        itemLost.amount,
      ], defaultSheet.maxRows);
    }

    int indexOfMaxRow = defaultSheet.maxRows;

    //total row
    defaultSheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
      UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_TOTAL),
      cellStyle: titleCellStyle.copyWith(
        horizontalAlignVal: HorizontalAlign.Center,
      ),
    );

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow),
      totalAmount,
      cellStyle: titleCellStyle,
    );

    //chu ki
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTANT),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 4),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_APPROVER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: indexOfMaxRow + 5),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );

    //save
    excel.save(fileName: excelName);
  }

  static void exportInventoryChecklist(WarehouseNoteCheck checkNote) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_INVENTORY_CHECK_LIST)}_${checkNote.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    defaultSheet.merge(
        CellIndex.indexByString('A4'), CellIndex.indexByString('D5'));

    defaultSheet.updateCell(
      CellIndex.indexByString('A4'),
      UITitleUtil.getTitleByCode(UITitleCode.INVENTORY_CHECKLIST),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );

    defaultSheet.merge(
        CellIndex.indexByString('A6'), CellIndex.indexByString('D6'));
    defaultSheet.merge(
        CellIndex.indexByString('A7'), CellIndex.indexByString('D7'));

    CellStyle cellStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
      fontColorHex: 'FFFF0000',
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    defaultSheet.updateCell(CellIndex.indexByString('A6'),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)} : ${checkNote.invoiceNumber}',
        cellStyle: cellStyle);
    defaultSheet.updateCell(CellIndex.indexByString('A7'),
        WarehouseManager().getWarehouseNameById(checkNote.warehouse!),
        cellStyle: cellStyle);

    // Title for sheets
    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    defaultSheet.setColumnWidth(0, 20);
    defaultSheet.setColumnWidth(1, 10);
    defaultSheet.setColumnWidth(2, 20);
    defaultSheet.setColumnWidth(3, 50);

    defaultSheet.updateCell(CellIndex.indexByString("A9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("B9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("C9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACTUAL_INVENTORY),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("D9"),
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
        cellStyle: titleCellStyle);

    for (var element in checkNote.list!) {
      defaultSheet.insertRowIterables([
        ItemManager().getItemNameByID(element.id!),
        MessageUtil.getMessageByCode(
            ItemManager().getItemUnitByID(element.id!)),
        '',
        '',
      ], defaultSheet.maxRows);
    }

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(
          columnIndex: 3, rowIndex: defaultSheet.maxRows + 4),
      UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECKER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(
          columnIndex: 3, rowIndex: defaultSheet.maxRows),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    //save
    excel.save(fileName: excelName);
  }

  static void exportInventoryBalance(WarehouseNoteCheck checkNote) {
    String excelName =
        "OnePms_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_INVENTORY_CHECK_INVOICE)}_${checkNote.invoiceNumber}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];

    defaultSheet!.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      GeneralManager.hotel!.name,
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      '${GeneralManager.hotel!.street}, ${GeneralManager.hotel!.city}, ${GeneralManager.hotel!.country}',
    );

    defaultSheet.merge(
        CellIndex.indexByString('A4'), CellIndex.indexByString('F5'));

    defaultSheet.updateCell(
      CellIndex.indexByString('A4'),
      UITitleUtil.getTitleByCode(UITitleCode.INVENTORY_CHECKLIST),
      cellStyle: CellStyle(
        bold: true,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 20,
        fontColorHex: 'FF2A2ABB',
        fontFamily: getFontFamily(FontFamily.Arial),
      ),
    );

    defaultSheet.merge(
        CellIndex.indexByString('A6'), CellIndex.indexByString('F6'));
    defaultSheet.merge(
        CellIndex.indexByString('A7'), CellIndex.indexByString('F7'));

    CellStyle cellStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
      fontColorHex: 'FFFF0000',
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    defaultSheet.updateCell(CellIndex.indexByString('A6'),
        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVOICE_NUMBER)} : ${checkNote.invoiceNumber}',
        cellStyle: cellStyle);
    defaultSheet.updateCell(CellIndex.indexByString('A7'),
        WarehouseManager().getWarehouseNameById(checkNote.warehouse!),
        cellStyle: cellStyle);

    // Title for sheets
    CellStyle titleCellStyle = CellStyle(
      bold: false,
      italic: false,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: "ffcacaca",
      fontSize: 14,
      fontFamily: getFontFamily(FontFamily.Arial),
      textWrapping: TextWrapping.WrapText,
    );

    defaultSheet.setColumnWidth(0, 20);
    defaultSheet.setColumnWidth(1, 10);
    defaultSheet.setColumnWidth(2, 20);
    defaultSheet.setColumnWidth(3, 20);
    defaultSheet.setColumnWidth(4, 20);
    defaultSheet.setColumnWidth(5, 50);

    defaultSheet.updateCell(CellIndex.indexByString("A9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("B9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("C9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_INVENTORY),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("D9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ACTUAL_INVENTORY),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("E9"),
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DIFFERENCE),
        cellStyle: titleCellStyle);
    defaultSheet.updateCell(CellIndex.indexByString("F9"),
        UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES),
        cellStyle: titleCellStyle);

    for (var element in checkNote.list!) {
      defaultSheet.insertRowIterables([
        ItemManager().getItemNameByID(element.id!),
        MessageUtil.getMessageByCode(
            ItemManager().getItemUnitByID(element.id!)),
        element.amount,
        element.actualAmount,
        element.amount! - element.actualAmount!,
        element.note
      ], defaultSheet.maxRows);
    }

    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(
          columnIndex: 5, rowIndex: defaultSheet.maxRows + 4),
      UITitleUtil.getTitleByCode(UITitleCode.HEADER_CHECKER),
      cellStyle: CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true),
    );
    defaultSheet.updateCell(
      CellIndex.indexByColumnRow(
          columnIndex: 5, rowIndex: defaultSheet.maxRows),
      UITitleUtil.getTitleByCode(UITitleCode.PDF_SIGNATURE),
      cellStyle: CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        italic: true,
      ),
    );
    //save
    excel.save(fileName: excelName);
  }

  static Future<void> dowloadWarehouseNoteFile(String noteType) async {
    ByteData data =
        await rootBundle.load("assets/excel/OnePms_${noteType}_note.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    Sheet? dataSheet = excel.sheets['Data'];
    for (var i = 0; i < ItemManager().items.length; i++) {
      dataSheet!.updateCell(
          CellIndex.indexByString('A${i + 4}'), ItemManager().items[i].name);
    }
    for (var i = 0;
        i < WarehouseManager().getActiveWarehouseName().length;
        i++) {
      dataSheet!.updateCell(CellIndex.indexByString('B${i + 4}'),
          WarehouseManager().getActiveWarehouseName()[i]);
    }

    if (noteType == WarehouseNotesType.import) {
      for (var i = 0;
          i < SupplierManager().getActiveSupplierNames().length;
          i++) {
        dataSheet!.updateCell(CellIndex.indexByString('C${i + 4}'),
            SupplierManager().getActiveSupplierNames()[i]);
      }
    }

    excel.save(fileName: 'OnePms_${noteType}_note.xlsx');
  }

  static Future<void> dowloaExportItemFile() async {
    ByteData data = await rootBundle.load("assets/excel/OnePms_Item_note.xlsx");
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var excel = Excel.decodeBytes(bytes);
    Sheet? dataSheet = excel.sheets['Sheet1'];
    int rowIndex = 1;
    for (var unit in UnitUlti.getUnits()) {
      dataSheet!.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex), unit);
      rowIndex++;
    }

    excel.save(fileName: "OnePms_Item_note.xlsx");
  }

  static Future<List<dynamic>> readItemFromExcelFile() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    Map<String, dynamic> result = {};
    var bytes = pickedFile?.files.single.bytes;
    Excel excel;
    try {
      excel = Excel.decodeBytes(bytes as List<int>);
    } catch (e) {
      return [];
    }
    String erroUnit = "";
    String nameAndUnitIsEmpty = "";
    Sheet? data = excel.sheets[excel.getDefaultSheet()];
    for (var i = 1; i < data!.rows.length; i++) {
      List<Data?> rowData = data.rows[i];
      String? nameItem = rowData[0]?.value.toString().trim();
      String? unit = rowData[1]?.value.toString().trim();
      double? price = double.parse(rowData[2]?.value?.toString().trim() ?? "0");
      if (data.rows[i][0] == null) {
        if ((nameItem == null && unit != null)) {
          nameAndUnitIsEmpty = "$nameAndUnitIsEmpty - ${i + 1}";
        }
        continue;
      }
      if (!UnitUlti.getUnits().contains(unit)) {
        erroUnit = "$erroUnit - ${i + 1}";
      }
      result[NumberUtil.getSidByConvertToBase62()] = {
        "active": true,
        "cost_price": price,
        "name": nameItem,
        "unit": unit,
        "warehouse": null,
      };
    }
    return [result, erroUnit, nameAndUnitIsEmpty];
  }

  static void exportReprotRoom(
      Map<String, List<Booking>> mapDataBooking,
      Set<String> dataSetTypeCost,
      Set<String> setMethod,
      Map<String, dynamic> totalService,
      Map<String, Map<String, dynamic>> mapPayment,
      RevenueByRoomReportController controller,
      DateTime startDate,
      DateTime endDate) {
    if (mapDataBooking.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_RevenueByRoom_${DateUtil.dateToShortString(startDate)}_${DateUtil.dateToShortString(endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerServiceCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "ff59b69e",
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCostCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "FF2A2ABB",
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentCellStyle = CellStyle(
        bold: true,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle contentLengthRenderCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    //title for sheets
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("A2"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Phòng";
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("B1"), CellIndex.indexByString("B2"));
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Tên";
    defaultSheet.cell(CellIndex.indexByString("B1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("C1"), CellIndex.indexByString("C2"));
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        "Thời hạn hợp đồng";
    defaultSheet.cell(CellIndex.indexByString("C1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("D2"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value = "Hạng phòng";
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("E1"), CellIndex.indexByString("E2"));
    defaultSheet.cell(CellIndex.indexByString("E1")).value = "Tiền cọc";
    defaultSheet.cell(CellIndex.indexByString("E1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("F1"), CellIndex.indexByString("F2"));
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Đơn giá";
    defaultSheet.cell(CellIndex.indexByString("F1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("G1"), CellIndex.indexByString("G2"));
    defaultSheet.cell(CellIndex.indexByString("G1")).value = "Ngày ở";
    defaultSheet.cell(CellIndex.indexByString("G1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("H1"), CellIndex.indexByString("H2"));
    defaultSheet.cell(CellIndex.indexByString("H1")).value = "Thành tiền";
    defaultSheet.cell(CellIndex.indexByString("H1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("I1"), CellIndex.indexByString("I2"));
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Số người";
    defaultSheet.cell(CellIndex.indexByString("I1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("J1"), CellIndex.indexByString("J2"));
    defaultSheet.cell(CellIndex.indexByString("J1")).value = "Số điện ĐK";
    defaultSheet.cell(CellIndex.indexByString("J1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("K1"), CellIndex.indexByString("K2"));
    defaultSheet.cell(CellIndex.indexByString("K1")).value = "Số điện CK";
    defaultSheet.cell(CellIndex.indexByString("K1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("L1"), CellIndex.indexByString("L2"));
    defaultSheet.cell(CellIndex.indexByString("L1")).value = "Tiền điện";
    defaultSheet.cell(CellIndex.indexByString("L1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("M1"), CellIndex.indexByString("M2"));
    defaultSheet.cell(CellIndex.indexByString("M1")).value = "Tiền nước";
    defaultSheet.cell(CellIndex.indexByString("M1")).cellStyle = titleCellStyle;

    ///Dich vụ

    defaultSheet.merge(
        CellIndex.indexByString("N2"), CellIndex.indexByString("N2"));
    defaultSheet.cell(CellIndex.indexByString("N2")).value = "Minibar";
    defaultSheet.cell(CellIndex.indexByString("N2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("O2"), CellIndex.indexByString("O2"));
    defaultSheet.cell(CellIndex.indexByString("O2")).value = "Phụ thu giờ";
    defaultSheet.cell(CellIndex.indexByString("O2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("P2"), CellIndex.indexByString("P2"));
    defaultSheet.cell(CellIndex.indexByString("P2")).value = "Phụ thu khách";
    defaultSheet.cell(CellIndex.indexByString("P2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("Q2"), CellIndex.indexByString("Q2"));
    defaultSheet.cell(CellIndex.indexByString("Q2")).value = "Giặt ủi";
    defaultSheet.cell(CellIndex.indexByString("Q2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("R2"), CellIndex.indexByString("R2"));
    defaultSheet.cell(CellIndex.indexByString("R2")).value = "Thuê xe";
    defaultSheet.cell(CellIndex.indexByString("R2")).cellStyle = titleCellStyle;

    // defaultSheet.merge(
    //     CellIndex.indexByString("S2"), CellIndex.indexByString("S2"));
    // defaultSheet.cell(CellIndex.indexByString("S2")).value = "Dịch vụ khác";
    // defaultSheet.cell(CellIndex.indexByString("S2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("S2"), CellIndex.indexByString("S2"));
    defaultSheet.cell(CellIndex.indexByString("S2")).value =
        "Nhà hàng trong ks";
    defaultSheet.cell(CellIndex.indexByString("S2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("T2"), CellIndex.indexByString("T2"));
    defaultSheet.cell(CellIndex.indexByString("T2")).value =
        "Nhà hàng ngoài ks";
    defaultSheet.cell(CellIndex.indexByString("T2")).cellStyle = titleCellStyle;

    int columnIndexCost =
        defaultSheet.cell(CellIndex.indexByString("T2")).columnIndex + 1;
    if (controller.dataSetOther.isNotEmpty) {
      for (var element in controller.dataSetOther) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = element;
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost++;
      }
    }
    defaultSheet.merge(
        CellIndex.indexByString("N1"),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost - 1, rowIndex: 0));
    defaultSheet.cell(CellIndex.indexByString("N1")).value = "Dịch Vụ";
    defaultSheet.cell(CellIndex.indexByString("N1")).cellStyle =
        headerServiceCellStyle;

    ///Chi phí
    if (dataSetTypeCost.isNotEmpty) {
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 0),
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost + dataSetTypeCost.length - 1,
              rowIndex: 0));
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .value = "Chi phí";
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .cellStyle = headerCostCellStyle;
      for (var element in dataSetTypeCost) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = element;
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost++;
      }
    }

    if (setMethod.isNotEmpty) {
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 0),
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost + setMethod.length - 1,
              rowIndex: 0));
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .value = "Thanh Toán";
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost, rowIndex: 0))
          .cellStyle = headerCostCellStyle;
      for (var element in setMethod) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = element;
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost++;
      }
    }

    ///Thanh toán
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost, rowIndex: 0))
        .value = "Tổng tiền";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0))
        .value = "Giảm giá";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0))
        .value = "Doanh thu";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0))
        .value = "Số ngày trong tháng";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 4, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 4, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 4, rowIndex: 0))
        .value = "Số ngày lấp đầy";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 4, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 5, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 5, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 5, rowIndex: 0))
        .value = "Trạng Thái";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 5, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 6, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 6, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 6, rowIndex: 0))
        .value = "Tỵ lệ %";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 6, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 7, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 7, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 7, rowIndex: 0))
        .value = "Sale";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 7, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 8, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 8, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 8, rowIndex: 0))
        .value = "Ghi chú";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 8, rowIndex: 0))
        .cellStyle = titleCellStyle;

    //write data

    int? totalPriceRoom = 0;
    int totalMinibar = 0;
    int totalExtrahHour = 0;
    int totalExtraGuest = 0;
    num totalGuest = 0;
    num totalNumberDayInMonth = 0;
    num totalNumberDayFilled = 0;
    int totalLaundry = 0;
    int totalBike = 0;
    int totalOther = 0;
    int totalRestaurant = 0;
    int totalInRestaurant = 0;
    num totalElectricity = 0;
    num totalWater = 0;
    int total = 0;
    int totalDiscount = 0;
    int totalRevenue = 0;
    int totalDeposit = 0;
    int totalLengthstay = 0;
    int columnIndexCostContent = 0;
    int columnIndexCostTotal = 0;
    int rowIndex = 3;
    int rowIndexContent = 3;
    int rowIndexStart = 2;
    int rowIndexEnd = 2;
    num totalDepositPayment = 0;
    Map<String, num> mapCost = {};
    Map<String, num> mapTotalPayment = {};
    Map<String, num> mapTotalOther = {};
    Map<String, num> mapLengthRender = {};
    for (var key in mapDataBooking.keys) {
      rowIndexEnd = mapDataBooking[key]!.length;
      defaultSheet.merge(
          CellIndex.indexByString("A$rowIndex"),
          CellIndex.indexByString(
              "A${(rowIndex + mapDataBooking[key]!.length) - 1}"));
      defaultSheet.cell(CellIndex.indexByString("A$rowIndex")).value =
          RoomManager().getNameRoomById(key);
      defaultSheet.cell(CellIndex.indexByString("A$rowIndex")).cellStyle =
          contentCellStyle;

      for (var booking in mapDataBooking[key]!) {
        defaultSheet.cell(CellIndex.indexByString("B$rowIndexContent")).value =
            booking.name;
        defaultSheet.cell(CellIndex.indexByString("C$rowIndexContent")).value =
            "${DateUtil.dateToDayMonthYearString(booking.inDate!)} - ${DateUtil.dateToDayMonthYearString(booking.outDate!)}";
        defaultSheet.cell(CellIndex.indexByString("D$rowIndexContent")).value =
            "${RoomTypeManager().getRoomTypeNameByID(booking.roomTypeID)} - ${booking.bookingType == BookingType.monthly ? "Theo Tháng" : "Thường"}";
        defaultSheet.cell(CellIndex.indexByString("E$rowIndexContent")).value =
            "${booking.totalDepositPayment ?? 0}- ${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOR_GRUOP) : ""}";
        // "${booking.deposit}- ${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_FOR_GRUOP) : ""}";
        defaultSheet.cell(CellIndex.indexByString("F$rowIndexContent")).value =
            booking.bookingType == BookingType.monthly
                ? startDate.month != endDate.month
                    ? booking.price.toString()
                    : booking.price![booking
                        .getBookingByTypeMonth()
                        .indexOf(DateTime(startDate.year, startDate.month))]
                : controller.getAverageRoomRate(booking);
        defaultSheet.cell(CellIndex.indexByString("G$rowIndexContent")).value =
            booking.lengthRender;
        defaultSheet.cell(CellIndex.indexByString("H$rowIndexContent")).value =
            booking.totalRoomCharge;
        defaultSheet.cell(CellIndex.indexByString("I$rowIndexContent")).value =
            booking.child! + booking.adult!;
        defaultSheet.cell(CellIndex.indexByString("J$rowIndexContent")).value =
            controller.serviceElectricity[booking.id]?["initial_number"] ?? 0;
        defaultSheet.cell(CellIndex.indexByString("K$rowIndexContent")).value =
            controller.serviceElectricity[booking.id]?["final_number"] ?? 0;
        defaultSheet.cell(CellIndex.indexByString("L$rowIndexContent")).value =
            booking.electricity;
        defaultSheet.cell(CellIndex.indexByString("M$rowIndexContent")).value =
            booking.water;

        ///dịch vụ
        defaultSheet.cell(CellIndex.indexByString("N$rowIndexContent")).value =
            booking.minibar;
        defaultSheet.cell(CellIndex.indexByString("O$rowIndexContent")).value =
            (booking.extraHour?.total ?? 0);
        defaultSheet.cell(CellIndex.indexByString("P$rowIndexContent")).value =
            booking.extraGuest;
        defaultSheet.cell(CellIndex.indexByString("Q$rowIndexContent")).value =
            booking.laundry;
        defaultSheet.cell(CellIndex.indexByString("R$rowIndexContent")).value =
            booking.bikeRental;
        // defaultSheet.cell(CellIndex.indexByString("S$rowIndexContent")).value =
        //     booking.other;
        defaultSheet.cell(CellIndex.indexByString("S$rowIndexContent")).value =
            booking.insideRestaurant;
        defaultSheet.cell(CellIndex.indexByString("T$rowIndexContent")).value =
            booking.outsideRestaurant;

        ///Chi phí
        columnIndexCostContent = defaultSheet
                .cell(CellIndex.indexByString("T$rowIndexContent"))
                .columnIndex +
            1;
        columnIndexCostTotal = defaultSheet
                .cell(CellIndex.indexByString("T$rowIndexContent"))
                .columnIndex +
            1;

        ///Other
        for (var other in controller.dataSetOther) {
          defaultSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndexCostContent,
                  rowIndex: rowIndexContent - 1))
              .value = controller.serviceOther[booking.id]?[other] ?? 0;
          if (mapTotalOther.containsKey(other)) {
            mapTotalOther[other] = mapTotalOther[other]! +
                (controller.serviceOther[booking.id]?[other] ?? 0);
          } else {
            mapTotalOther[other] =
                controller.serviceOther[booking.id]?[other] ?? 0;
          }
          columnIndexCostContent++;
        }

        ///Chi phí
        for (var cost in dataSetTypeCost) {
          defaultSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndexCostContent,
                  rowIndex: rowIndexContent - 1))
              .value = booking.getDetailCostByRoom(startDate, endDate)[cost]
                  ?[booking.room] ??
              0;
          if (mapCost.containsKey(cost)) {
            mapCost[cost] = mapCost[cost]! +
                (booking.getDetailCostByRoom(startDate, endDate)[cost]
                        ?[booking.room] ??
                    0);
          } else {
            mapCost[cost] = booking.getDetailCostByRoom(
                    startDate, endDate)[cost]?[booking.room] ??
                0;
          }
          columnIndexCostContent++;
        }
        //thanh toans
        for (var deposit in setMethod) {
          defaultSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndexCostContent,
                  rowIndex: rowIndexContent - 1))
              .value = mapPayment[deposit]?[booking.id] ?? 0;

          if (mapTotalPayment.containsKey(deposit)) {
            mapTotalPayment[deposit] = mapTotalPayment[deposit]! +
                (mapPayment[deposit]?[booking.id] ?? 0);
          } else {
            mapTotalPayment[deposit] = mapPayment[deposit]?[booking.id] ?? 0;
          }
          columnIndexCostContent++;
        }

        ///
        defaultSheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnIndexCostContent,
                    rowIndex: rowIndexContent - 1))
                .value =
            booking.getServiceCharge() + (booking.totalRoomCharge ?? 0);

        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCostContent + 1,
                rowIndex: rowIndexContent - 1))
            .value = booking.discount;

        defaultSheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: columnIndexCostContent + 2,
                    rowIndex: rowIndexContent - 1))
                .value =
            booking.getServiceCharge() +
                (booking.totalRoomCharge ?? 0) -
                booking.discount!;

        // defaultSheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: columnIndexCostContent + 3,
        //         rowIndex: rowIndexContent - 1))
        //     .value = DateUtil.getLengthOfMonth(startDate);

        // defaultSheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: columnIndexCostContent + 4,
        //         rowIndex: rowIndexContent - 1))
        //     .value = booking.lengthRender;

        defaultSheet.cell(CellIndex.indexByColumnRow(columnIndex: columnIndexCostContent + 5, rowIndex: rowIndexContent - 1)).value =
            booking.status == BookingStatus.booked
                ? "Đặt Phòng - ${booking.statusPayment == 2 ? "Thanh toán đủ" : booking.statusPayment == 1 ? "Thanh toán 1 phần" : "Chưa thanh toán"}"
                : booking.status == BookingStatus.checkin
                    ? "Nhận Phòng - ${booking.statusPayment == 2 ? "Thanh toán đủ" : booking.statusPayment == 1 ? "Thanh toán 1 phần" : "Chưa thanh toán"}"
                    : "Trả Phòng - Thanh toán đủ";
// print(rowIndexContent);
// print(mapDataBooking[key]!.length);
//         defaultSheet.merge(
//             CellIndex.indexByColumnRow(
//                 columnIndex: columnIndexCostContent + 6,
//                 rowIndex: rowIndexContent - 1),
//             CellIndex.indexByColumnRow(
//                 columnIndex: columnIndexCostContent + 6,
//                 rowIndex: rowIndexContent - 1));
//         defaultSheet
//             .cell(CellIndex.indexByColumnRow(
//                 columnIndex: columnIndexCostContent + 6,
//                 rowIndex: rowIndexContent - 1))
//             .value = "hpa";

        // defaultSheet
        //     .cell(CellIndex.indexByColumnRow(
        //         columnIndex: columnIndexCostContent + 6,
        //         rowIndex: rowIndexContent - 1))
        //     .value = mapDataBooking[key]!.length;

        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCostContent + 7,
                rowIndex: rowIndexContent - 1))
            .value = booking.externalSaler;

        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCostContent + 8,
                rowIndex: rowIndexContent - 1))
            .value = "";
        rowIndexContent++;
        totalLengthstay += (booking.lengthRender ?? 0);
        totalNumberDayInMonth += DateUtil.getLengthOfMonth(startDate);
        totalNumberDayFilled += (booking.lengthRender ?? 0);
        totalGuest += booking.child! + booking.adult!;
        totalElectricity += (booking.electricity ?? 0);
        totalWater += (booking.water ?? 0);
        if (mapLengthRender.containsKey(key)) {
          mapLengthRender[key] = mapLengthRender[key]! + booking.lengthRender!;
        } else {
          mapLengthRender[key] = booking.lengthRender!;
        }
        totalDepositPayment += (booking.totalDepositPayment ?? 0);
      }
      defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 3, rowIndex: rowIndexStart),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 3,
            rowIndex: (rowIndexEnd + rowIndexStart) - 1),
      );
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 3, rowIndex: rowIndexStart))
          .value = DateUtil.getLengthOfMonth(startDate);
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 3, rowIndex: rowIndexStart))
          .cellStyle = contentLengthRenderCellStyle;

      ///
      defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 4, rowIndex: rowIndexStart),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 4,
            rowIndex: (rowIndexEnd + rowIndexStart) - 1),
      );
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 4, rowIndex: rowIndexStart))
          .value = mapLengthRender[key];
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 4, rowIndex: rowIndexStart))
          .cellStyle = contentLengthRenderCellStyle;

      ///
      defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 6, rowIndex: rowIndexStart),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostContent + 6,
            rowIndex: (rowIndexEnd + rowIndexStart) - 1),
      );
      defaultSheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndexCostContent + 6,
                  rowIndex: rowIndexStart))
              .value =
          "${NumberUtil.numberFormat.format((mapLengthRender[key]! / DateUtil.getLengthOfMonth(startDate)) * 100)} %";
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 6, rowIndex: rowIndexStart))
          .cellStyle = contentLengthRenderCellStyle;

      rowIndexStart = (rowIndexEnd + rowIndexStart);
      // rowIndexStart++;

      ///
      rowIndex = (rowIndex + mapDataBooking[key]!.length) - 1;
      rowIndex++;

      totalPriceRoom = (totalService[key]?["priceroom"] ?? 0) + totalPriceRoom;
      totalMinibar = (totalService[key]?["minibar"] ?? 0) + totalMinibar;
      totalExtrahHour =
          (totalService[key]?["extra_hour"] ?? 0) + totalExtrahHour;
      totalExtraGuest =
          (totalService[key]?["extra_guest"] ?? 0) + totalExtraGuest;
      totalLaundry = (totalService[key]?["laundry"] ?? 0) + totalLaundry;
      totalBike = (totalService[key]?["bike"] ?? 0) + totalBike;
      totalOther = (totalService[key]?["other"] ?? 0) + totalOther;
      totalRestaurant =
          (totalService[key]?["restaurant"] ?? 0) + totalRestaurant;
      totalInRestaurant =
          (totalService[key]?["inrestaurant"] ?? 0) + totalInRestaurant;

      totalDiscount = (totalService[key]?["discount"] ?? 0) + totalDiscount;
      totalDeposit = (totalService[key]?["deposit"] ?? 0) + totalDeposit;
      total = (totalService[key]?["total"] ?? 0) + total;
      totalRevenue = (totalService[key]?["revenue"] ?? 0) + totalRevenue;
    }
    // Saving the files
    if (true) {
      int indexOfMaxRow = rowIndex;
      CellStyle cellStyleTotalRow = CellStyle(
          bold: true,
          italic: false,
          verticalAlign: VerticalAlign.Center,
          horizontalAlign: HorizontalAlign.Center,
          fontSize: 14,
          fontFamily: getFontFamily(FontFamily.Arial));
      // total row
      defaultSheet.merge(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow),
          CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: indexOfMaxRow));
      Data totalTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: indexOfMaxRow));
      totalTitleCell.value = "Tổng";
      totalTitleCell.cellStyle = cellStyleTotalRow;

      Data totalDepositTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: indexOfMaxRow));
      totalDepositTitleCell.value = totalDepositPayment;
      totalDepositTitleCell.cellStyle = cellStyleTotalRow;

      Data totalRoomTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: indexOfMaxRow));
      totalRoomTitleCell.value = totalPriceRoom;
      totalRoomTitleCell.cellStyle = cellStyleTotalRow;

      Data totalLengthStayTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: indexOfMaxRow));
      totalLengthStayTitleCell.value = totalLengthstay;
      totalLengthStayTitleCell.cellStyle = cellStyleTotalRow;

      Data totalPriceRoomTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: indexOfMaxRow));
      totalPriceRoomTitleCell.value = totalPriceRoom;
      totalPriceRoomTitleCell.cellStyle = cellStyleTotalRow;

      Data totalGuestTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: indexOfMaxRow));
      totalGuestTitleCell.value = totalGuest;
      totalGuestTitleCell.cellStyle = cellStyleTotalRow;

      Data totalElectricityTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: indexOfMaxRow));
      totalElectricityTitleCell.value = totalElectricity;
      totalElectricityTitleCell.cellStyle = cellStyleTotalRow;

      Data totalWaterTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: indexOfMaxRow));
      totalWaterTitleCell.value = totalWater;
      totalWaterTitleCell.cellStyle = cellStyleTotalRow;

      ///
      Data totalMiniBarTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: indexOfMaxRow));
      totalMiniBarTitleCell.value = totalMinibar;
      totalMiniBarTitleCell.cellStyle = cellStyleTotalRow;

      Data totalExtraHourTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: indexOfMaxRow));
      totalExtraHourTitleCell.value = totalExtrahHour;
      totalExtraHourTitleCell.cellStyle = cellStyleTotalRow;

      Data totalExtraGuestTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: indexOfMaxRow));
      totalExtraGuestTitleCell.value = totalExtraGuest;
      totalExtraGuestTitleCell.cellStyle = cellStyleTotalRow;

      Data totalLaundryTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: indexOfMaxRow));
      totalLaundryTitleCell.value = totalLaundry;
      totalLaundryTitleCell.cellStyle = cellStyleTotalRow;

      Data totalBikeTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: indexOfMaxRow));
      totalBikeTitleCell.value = totalBike;
      totalBikeTitleCell.cellStyle = cellStyleTotalRow;

      // Data totalOtherTitleCell = defaultSheet.cell(
      //     CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: indexOfMaxRow));
      // totalOtherTitleCell.value = totalOther;
      // totalOtherTitleCell.cellStyle = cellStyleTotalRow;

      Data totalInresTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 18, rowIndex: indexOfMaxRow));
      totalInresTitleCell.value = totalInRestaurant;
      totalInresTitleCell.cellStyle = cellStyleTotalRow;

      Data totalOutresTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 19, rowIndex: indexOfMaxRow));
      totalOutresTitleCell.value = totalRestaurant;
      totalOutresTitleCell.cellStyle = cellStyleTotalRow;

      ///other
      for (var other in controller.dataSetOther) {
        Data totalCostTitleCell = defaultSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostTotal, rowIndex: indexOfMaxRow));
        totalCostTitleCell.value = mapTotalOther[other];
        totalCostTitleCell.cellStyle = cellStyleTotalRow;
        columnIndexCostTotal++;
      }

      /// chi phí
      for (var cost in dataSetTypeCost) {
        Data totalCostTitleCell = defaultSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostTotal, rowIndex: indexOfMaxRow));
        totalCostTitleCell.value = mapCost[cost];
        totalCostTitleCell.cellStyle = cellStyleTotalRow;
        columnIndexCostTotal++;
      }

      /// thanh toán
      for (var deposit in setMethod) {
        Data totalCostTitleCell = defaultSheet.cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCostTotal, rowIndex: indexOfMaxRow));
        totalCostTitleCell.value = mapTotalPayment[deposit];
        totalCostTitleCell.cellStyle = cellStyleTotalRow;
        columnIndexCostTotal++;
      }

//LAST
      Data totalsTitleCell = defaultSheet.cell(CellIndex.indexByColumnRow(
          columnIndex: columnIndexCostContent, rowIndex: indexOfMaxRow));
      totalsTitleCell.value = total;
      totalsTitleCell.cellStyle = cellStyleTotalRow;

      Data totalDiscountTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 1,
              rowIndex: indexOfMaxRow));
      totalDiscountTitleCell.value = totalDiscount;
      totalDiscountTitleCell.cellStyle = cellStyleTotalRow;

      Data totalRevenueTitleCell = defaultSheet.cell(CellIndex.indexByColumnRow(
          columnIndex: columnIndexCostContent + 2, rowIndex: indexOfMaxRow));
      totalRevenueTitleCell.value = totalRevenue;
      totalRevenueTitleCell.cellStyle = cellStyleTotalRow;

      Data totalDayInMonthTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 3,
              rowIndex: indexOfMaxRow));
      totalDayInMonthTitleCell.value = totalNumberDayInMonth;
      totalDayInMonthTitleCell.cellStyle = cellStyleTotalRow;

      Data totalDayFilledTitleCell = defaultSheet.cell(
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostContent + 4,
              rowIndex: indexOfMaxRow));
      totalDayFilledTitleCell.value = totalNumberDayFilled;
      totalDayFilledTitleCell.cellStyle = cellStyleTotalRow;
      //save
      excel.save(fileName: excelName);
    }
  }

  static void exportReprotDailyDataHotels(
    DailyDataHotelsController controller,
    Map<String, List<DailyData>> totalData,
    Set<String> dataSetTypeCost,
    Map<String, Map<String, dynamic>> dataCost,
  ) {
    if (totalData.isEmpty) {
      return;
    }
    String excelName =
        "OnePMS_ReportByHotels_${DateUtil.dateToShortString(controller.startDate)}_${DateUtil.dateToShortString(controller.endDate)}.xlsx";
    //create file
    final Excel excel = Excel.createExcel();

    Sheet defaultSheet = excel.sheets[excel.getDefaultSheet()]!;

    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: "ffcacaca",
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerServiceCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "ff59b69e",
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    CellStyle headerCostCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: "FF2A2ABB",
        fontSize: 15,
        fontFamily: getFontFamily(FontFamily.Arial));

    //title for sheets
    defaultSheet.merge(
        CellIndex.indexByString("A1"), CellIndex.indexByString("A2"));
    defaultSheet.cell(CellIndex.indexByString("A1")).value = "Tên Tòa";
    defaultSheet.cell(CellIndex.indexByString("A1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("B1"), CellIndex.indexByString("B2"));
    defaultSheet.cell(CellIndex.indexByString("B1")).value = "Tổng Số Phòng";
    defaultSheet.cell(CellIndex.indexByString("B1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("C1"), CellIndex.indexByString("C2"));
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        "Tỷ lệ % full phòng";
    defaultSheet.cell(CellIndex.indexByString("C1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("D1"), CellIndex.indexByString("D2"));
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        "Tiền đặt cọc cho chủ";
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("E1"), CellIndex.indexByString("E2"));
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        "Tiền đặt cọc của khách";
    defaultSheet.cell(CellIndex.indexByString("E1")).cellStyle = titleCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("F1"), CellIndex.indexByString("H1"));
    defaultSheet.cell(CellIndex.indexByString("F1")).value = "Tiền Phòng";
    defaultSheet.cell(CellIndex.indexByString("F1")).cellStyle =
        headerServiceCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("F2"), CellIndex.indexByString("F2"));
    defaultSheet.cell(CellIndex.indexByString("F2")).value = "Thuê";
    defaultSheet.cell(CellIndex.indexByString("F2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("G2"), CellIndex.indexByString("G2"));
    defaultSheet.cell(CellIndex.indexByString("G2")).value = "Thu";
    defaultSheet.cell(CellIndex.indexByString("G2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("H2"), CellIndex.indexByString("H2"));
    defaultSheet.cell(CellIndex.indexByString("H2")).value = "Chênh lệch";
    defaultSheet.cell(CellIndex.indexByString("H2")).cellStyle = titleCellStyle;

    ///
    defaultSheet.merge(
        CellIndex.indexByString("I1"), CellIndex.indexByString("K1"));
    defaultSheet.cell(CellIndex.indexByString("I1")).value = "Tiền Điện";
    defaultSheet.cell(CellIndex.indexByString("I1")).cellStyle =
        headerServiceCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("I2"), CellIndex.indexByString("I2"));
    defaultSheet.cell(CellIndex.indexByString("I2")).value = "Nộp";
    defaultSheet.cell(CellIndex.indexByString("I2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("J2"), CellIndex.indexByString("J2"));
    defaultSheet.cell(CellIndex.indexByString("J2")).value = "Thu";
    defaultSheet.cell(CellIndex.indexByString("J2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("K2"), CellIndex.indexByString("K2"));
    defaultSheet.cell(CellIndex.indexByString("K2")).value = "Chênh lệnh";
    defaultSheet.cell(CellIndex.indexByString("K2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("L1"), CellIndex.indexByString("N1"));
    defaultSheet.cell(CellIndex.indexByString("L1")).value = "Tiền Nước";
    defaultSheet.cell(CellIndex.indexByString("L1")).cellStyle =
        headerServiceCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("L2"), CellIndex.indexByString("L2"));
    defaultSheet.cell(CellIndex.indexByString("L2")).value = "Nộp";
    defaultSheet.cell(CellIndex.indexByString("L2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("M2"), CellIndex.indexByString("M2"));
    defaultSheet.cell(CellIndex.indexByString("M2")).value = "Thu";
    defaultSheet.cell(CellIndex.indexByString("M2")).cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByString("N2"), CellIndex.indexByString("N2"));
    defaultSheet.cell(CellIndex.indexByString("N2")).value = "Chênh lệnh";
    defaultSheet.cell(CellIndex.indexByString("N2")).cellStyle = titleCellStyle;

    ///////////////////
    ///
    List<String> costDefault = ["tdccc", "ttn", "tdn", "tnn"];
    for (var element in costDefault) {
      if (dataSetTypeCost.contains(controller.mapTypeAccounting[element])) {
        dataSetTypeCost.remove(controller.mapTypeAccounting[element]);
      }
    }

    num getTotalMinibar = 0;
    num getTotalHour = 0;
    num getTotalGuest = 0;
    num getTotalLaundry = 0;
    num getTotalBike = 0;
    num getTotalOther = 0;
    num getTotalInRes = 0;
    num getTotalOutRes = 0;
    for (var key in totalData.keys) {
      if (totalData[key]!.isEmpty) continue;
      num getTotalNight =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.night) ?? 0;
      num getTotalRoomCharge = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.roomCharge) ??
          0;
      num getTotalElectricity = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.electricity) ??
          0;

      num getTotalWater =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.water) ?? 0;
      getTotalMinibar =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.minibar) ??
              0;
      getTotalHour =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.extraHour) ??
              0;

      getTotalGuest = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.extraGuest) ??
          0;
      getTotalLaundry =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.laundry) ??
              0;

      getTotalBike = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.bikeRental) ??
          0;
      getTotalOther =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.other) ?? 0;

      getTotalInRes = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.insideRestaurant) ??
          0;

      getTotalOutRes = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.outsideRestaurant) ??
          0;

      num getTotalCost =
          totalData[key]?.fold(0, (pre, data) => (pre ?? 0) + data.cost) ?? 0;

      num getTotalRevenue = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.revenueByDate) ??
          0;

      num getTotalDepositPayment = totalData[key]
              ?.fold(0, (pre, data) => (pre ?? 0) + data.getDepositPayment()) ??
          0;

      num totalCostTDCCN = controller.dataCostDefault[key]!.containsKey("tdccc")
          ? controller.dataCostDefault[key]!['tdccc']
          : 0;

      num totalCostTTN = controller.dataCostDefault[key]!.containsKey("ttn")
          ? controller.dataCostDefault[key]!['ttn']
          : 0;

      num totalCostND = controller.dataCostDefault[key]!.containsKey("tdn")
          ? controller.dataCostDefault[key]!['tdn']
          : 0;

      num totalCostNN = controller.dataCostDefault[key]!.containsKey("tnn")
          ? controller.dataCostDefault[key]!['tnn']
          : 0;

      defaultSheet.insertRowIterables([
        controller.listNameHotels[controller.listIdHotels.indexOf(key)],
        controller.totalRoom[key],
        "${NumberUtil.numberFormat.format((getTotalNight) / ((controller.totalRoom[key] ?? 0) * (totalData[key]?.length ?? 0)) * 100)} %",
        totalCostTDCCN,
        getTotalDepositPayment,
        totalCostTTN,
        getTotalRoomCharge,
        getTotalRoomCharge - totalCostTTN,
        totalCostND,
        getTotalElectricity,
        getTotalElectricity - totalCostND,
        totalCostNN,
        getTotalWater,
        getTotalWater - totalCostNN,
        if (getTotalMinibar > 0) getTotalMinibar,
        if (getTotalHour > 0) getTotalHour,
        if (getTotalGuest > 0) getTotalGuest,
        if (getTotalLaundry > 0) getTotalLaundry,
        if (getTotalBike > 0) getTotalBike,
        if (getTotalOther > 0) getTotalOther,
        if (getTotalInRes > 0) getTotalInRes,
        if (getTotalOutRes > 0) getTotalOutRes,
        for (var keyType in dataSetTypeCost) dataCost[key]?[keyType] ?? 0,
        getTotalRevenue,
        getTotalCost,
        (NumberUtil.numberFormat.format(getTotalRevenue - getTotalCost))
      ], defaultSheet.maxRows);
    }
    num totalALLService = getTotalMinibar +
        getTotalHour +
        getTotalGuest +
        getTotalLaundry +
        getTotalBike +
        getTotalOther +
        getTotalInRes +
        getTotalOutRes;

    int columnIndexCost =
        defaultSheet.cell(CellIndex.indexByString("N2")).columnIndex + 1;

    if (totalALLService > 0) {
      ///Dich vụ
      if (getTotalMinibar > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Minibar";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }

      if (getTotalHour > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Phụ thu giờ";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }

      if (getTotalGuest > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Phụ thu khách";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }

      if (getTotalLaundry > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Giặt ủi";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }
      if (getTotalBike > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Thuê xe";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }
      if (getTotalOther > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Dịch vụ khác";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }
      if (getTotalInRes > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Nhà hàng trong ks";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }
      if (getTotalOutRes > 0) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = "Nhà hàng ngoài ks";
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost = columnIndexCost + 1;
      }

      defaultSheet.merge(
          CellIndex.indexByString("O1"),
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost - 1, rowIndex: 0));
      defaultSheet.cell(CellIndex.indexByString("O1")).value = "Dịch Vụ";
      defaultSheet.cell(CellIndex.indexByString("O1")).cellStyle =
          headerServiceCellStyle;
    }
    int columnIndexCostDetail = columnIndexCost;

    ///Chi phí
    if (dataSetTypeCost.isNotEmpty) {
      for (var element in dataSetTypeCost) {
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .value = element;
        defaultSheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndexCost, rowIndex: 1))
            .cellStyle = titleCellStyle;
        columnIndexCost++;
      }
      defaultSheet.merge(
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostDetail, rowIndex: 0),
          CellIndex.indexByColumnRow(
              columnIndex: columnIndexCost - 1, rowIndex: 0));
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostDetail, rowIndex: 0))
          .value = "Chi phí";
      defaultSheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: columnIndexCostDetail, rowIndex: 0))
          .cellStyle = headerCostCellStyle;
    }

    ///Thanh toán
    defaultSheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: columnIndexCost, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost, rowIndex: 0))
        .value = "Tổng Thu";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0))
        .value = "Tổng Chi";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 1, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0))
        .value = "THU RÒNG";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 2, rowIndex: 0))
        .cellStyle = titleCellStyle;

    defaultSheet.merge(
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0),
        CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 1));
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0))
        .value = "Tỷ suất sinh lời trên vốn ( %)";
    defaultSheet
        .cell(CellIndex.indexByColumnRow(
            columnIndex: columnIndexCost + 3, rowIndex: 0))
        .cellStyle = titleCellStyle;
    // Saving the files
    if (true) {
      excel.save(fileName: excelName);
    }
  }

  static void exportWareHouse(Warehouse warehouse) {
    String excelName =
        "OnePMS_${UITitleUtil.getTitleByCode(UITitleCode.FILE_NAME_WAREHOUSE)}_${warehouse.name}.xlsx";

    //create file
    final Excel excel = Excel.createExcel();
    Sheet? defaultSheet = excel.sheets[excel.getDefaultSheet()];
    CellStyle titleCellStyle = CellStyle(
        bold: false,
        italic: false,
        verticalAlign: VerticalAlign.Center,
        backgroundColorHex: 'ffcacaca',
        fontSize: 14,
        fontFamily: getFontFamily(FontFamily.Arial));

    //title for sheets
    defaultSheet!.cell(CellIndex.indexByString("B1")).value =
        (UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ITEM));
    defaultSheet.cell(CellIndex.indexByString("B1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("C1")).value =
        (UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_STATUS));
    defaultSheet.cell(CellIndex.indexByString("C1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("D1")).value =
        (UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_AMOUNT));
    defaultSheet.cell(CellIndex.indexByString("D1")).cellStyle = titleCellStyle;
    defaultSheet.cell(CellIndex.indexByString("E1")).value =
        (UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_UNIT));
    defaultSheet.cell(CellIndex.indexByString("E1")).cellStyle = titleCellStyle;

    for (int i = 0; i < 4; i++) {
      defaultSheet.setColumnAutoFit(i);
    }

    for (var idItem in warehouse.items!.keys) {
      final HotelItem? item = ItemManager().getItemById(idItem);
      final num amount = warehouse.getAmountOfItem(idItem) ?? 0;
      defaultSheet.insertRowIterables(
        [
          warehouse.items!.keys.toList().indexOf(idItem) + 1,
          item!.name,
          (item.isActive ?? false)
              ? UITitleUtil.getTitleByCode(UITitleCode.STATUS_ACTIVE)
              : UITitleUtil.getTitleByCode(UITitleCode.STATUS_DEACTIVE),
          amount,
          MessageUtil.getMessageByCode(item.unit)
        ],
        defaultSheet.maxRows,
      );
    }
    //save
    excel.save(fileName: excelName);
  }
}
