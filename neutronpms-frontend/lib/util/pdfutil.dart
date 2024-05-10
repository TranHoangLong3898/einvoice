// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:ihotel/controller/booking/checkoutcontroller.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/restaurantitemmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/manager/sourcemanager.dart';
import 'package:ihotel/manager/systemmanagement.dart';
import 'package:ihotel/modal/electricitywater.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/tax.dart';
import 'package:ihotel/ui/controls/neutrontextstyle.dart';
import 'package:ihotel/util/dateutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../constants.dart';
import '../controller/booking/groupcontroller.dart';
import '../manager/generalmanager.dart';
import '../manager/itemmanager.dart';
import '../manager/laundrymanager.dart';
import '../manager/othermanager.dart';
import '../manager/paymentmethodmanager.dart';
import '../modal/booking.dart';
import '../modal/group.dart';
import '../modal/service/bikerental.dart';
import '../modal/service/deposit.dart';
import '../modal/service/extraguest.dart';
import '../modal/service/laundry.dart';
import '../modal/service/minibar.dart';
import '../modal/service/other.dart';
import '../modal/service/outsiderestaurantservice.dart';
import '../modal/status.dart';
import 'numberutil.dart';

class PDFUtil {
  static PdfColor mainColor = PdfColor.fromHex('59b69e');
  static const double HORIZONTAL_PADDING = 25;
  static const double PADDING_BELOW_TABLE = 20;

  static Future<Document> buildCheckInPDFDoc(Booking booking, bool showPrice,
      {Uint8List? pngBytes}) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) => [
              _buildHeader(
                  UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKIN_FORM)),
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  height: 80,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //title
                        Row(children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_GUEST_INFOS),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Container(
                            width: 150,
                            alignment: Alignment.centerRight,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INVOICE_TOTAL),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                        ]),
                        //content
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //customer
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(booking.name!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.phone!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.email!,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //in + out date
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                booking.inDate),
                                            style: NeutronTextStyle.pdfContent),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_DEPARTURE_DATE),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                booking.outDate),
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //total
                                Container(
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        showPrice
                                            ? NumberUtil.numberFormat.format(
                                                booking.getTotalCharge())
                                            : '',
                                        style: TextStyle(
                                            color: mainColor, fontSize: 18))),
                              ]),
                        ),
                      ])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Table.fromTextArray(
                    context: context,
                    border: TableBorder(
                        top: BorderSide(color: mainColor, width: 2),
                        bottom: BorderSide(color: mainColor, width: 2)),
                    cellAlignments: <int, Alignment>{
                      0: Alignment.centerLeft,
                      1: Alignment.centerLeft,
                    },
                    cellStyle: NeutronTextStyle.pdfContent,
                    rowDecoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: PdfColor.fromHex('#d3d8dc'), width: 0.1)),
                    ),
                    cellHeight: 20,
                    headerStyle: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    headers: [
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DETAIL),
                    ],
                    data: <List<String>>[
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_BREAKFAST),
                        booking.breakfast!
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_LUNCH),
                        booking.lunch!
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DINNER),
                        booking.dinner!
                            ? MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_YES)
                            : MessageUtil.getMessageByCode(
                                MessageCodeUtil.TEXTALERT_NO)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOMTYPE),
                        booking.getRoomTypeName()
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM),
                        RoomManager().getNameRoomById(booking.room!)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BED),
                        SystemManagement().getBedNameById(booking.bed ?? '?')
                      ],
                      <String>[
                        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ADULT)} / ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHILD)}',
                        '${booking.adult} / ${booking.child}'
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                        booking.sourceName!
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
                        booking.sID!
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL),
                        showPrice
                            ? NumberUtil.numberFormat
                                .format(booking.getRoomCharge())
                            : ''
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PAYMENT),
                        showPrice
                            ? NumberUtil.numberFormat.format(booking.deposit)
                            : ''
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_DISCOUNT),
                        NumberUtil.numberFormat.format(booking.discount)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.PDF_TRANSFERRING),
                        NumberUtil.numberFormat.format(booking.transferring)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.PDF_TRANSFERRED),
                        NumberUtil.numberFormat.format(booking.transferred)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_REMAIN),
                        showPrice
                            ? NumberUtil.numberFormat
                                .format(booking.getRemaining())
                            : ''
                      ],
                    ]),
              ),
              SizedBox(height: 10),
              //signature
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_GUEST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                    textAlign: TextAlign.center)
              ]),
              //img policy
              SizedBox(height: 10),
              if (GeneralManager.hotel!.policy!.isNotEmpty && pngBytes != null)
                Image(MemoryImage(pngBytes)),
              Expanded(child: SizedBox()),
              footer
            ]));
    return doc;
  }

  static Future<Document> buildGroupCheckInPDFDoc(
      Group group, bool showPrice) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (Context context) => [
              _buildHeader(
                  UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKIN_FORM)),
              Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: HORIZONTAL_PADDING),
                  height: 100,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //title
                        Row(children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_CUSTOMER),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_IN),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Container(
                            width: 150,
                            alignment: Alignment.centerRight,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INVOICE_TOTAL),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                        ]),
                        //content
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //customer
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(group.name!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(group.phone!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(group.email!,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //in + out date
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                            DateUtil
                                                .dateToDayMonthYearHourMinuteString(
                                                    DateUtil.to14h(
                                                        group.inDate!)),
                                            style: NeutronTextStyle.pdfContent),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_OUT),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(
                                            DateUtil
                                                .dateToDayMonthYearHourMinuteString(
                                                    group.outDate!),
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //total
                                Container(
                                    width: 150,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        showPrice
                                            ? NumberUtil.numberFormat
                                                .format(group.roomCharge)
                                            : '',
                                        style: TextStyle(
                                            color: mainColor, fontSize: 20))),
                              ]),
                        ),
                      ])),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
                child: Table.fromTextArray(
                    border: TableBorder(
                        top: BorderSide(color: mainColor, width: 2),
                        bottom: BorderSide(color: mainColor, width: 2)),
                    cellAlignments: <int, Alignment>{
                      0: Alignment.centerLeft,
                      1: Alignment.centerLeft,
                    },
                    columnWidths: <int, TableColumnWidth>{
                      0: const FixedColumnWidth(30),
                      1: const FixedColumnWidth(150)
                    },
                    cellStyle: NeutronTextStyle.pdfContent,
                    rowDecoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: PdfColor.fromHex('#d3d8dc'), width: 0.1)),
                    ),
                    cellHeight: 30,
                    headerStyle: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    headers: [
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DETAIL),
                    ],
                    context: context,
                    data: <List<String>>[
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM),
                        group.room.toString()
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ADULT),
                        group.adult.toString()
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_CHILD),
                        group.child.toString()
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SOURCE),
                        SourceManager().getSourceNameByID(group.sourceID!)
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SID),
                        group.sID!
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_ROOM_CHARGE_FULL),
                        showPrice
                            ? NumberUtil.numberFormat.format(group.roomCharge)
                            : ''
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PAYMENT),
                        showPrice
                            ? NumberUtil.numberFormat.format(group.deposit)
                            : ''
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_REMAIN),
                        showPrice
                            ? NumberUtil.numberFormat.format(group.remaining)
                            : ''
                      ],
                    ]),
              ),
              SizedBox(height: 5),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          ' * (B): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BREAKFAST)} , (NB): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_BREAKFAST)}',
                          style: NeutronTextStyle.pdfSmallContent),
                      Text(
                          ' * (L): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_LUNCH)} , (NL): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_LUNCH)}',
                          style: NeutronTextStyle.pdfSmallContent),
                      Text(
                          ' * (D): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_DINNER)} , (ND): ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NON_DINNER)}',
                          style: NeutronTextStyle.pdfSmallContent)
                    ]),
              ),
              SizedBox(height: PADDING_BELOW_TABLE),

              //signature
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_GUEST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                    textAlign: TextAlign.center)
              ]),
              Expanded(child: Container()),
              footer
            ]));
    return doc;
  }

  static Future<Document> buildCheckOutPDFDoc(
      Booking booking, bool showPrice, bool showService) async {
    //chu y 3thang dung no
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double serviceFee = tax.serviceFee!;
          double vat = tax.vat!;
          num totalCharge = showPrice && showService
              ? booking.getTotalCharge()!
              : showPrice
                  ? booking.getRoomCharge()
                  : booking.getTotalCharge()! - booking.getRoomCharge();
          double totalBeforeVAT =
              totalCharge / (1 + vat + serviceFee + vat * serviceFee);
          double serviceFeeMoney =
              (totalBeforeVAT * serviceFee).roundToDouble();
          double vatMoney =
              ((totalBeforeVAT + serviceFeeMoney) * vat).roundToDouble();
          totalBeforeVAT =
              totalCharge - serviceFeeMoney - vatMoney; //to prevent difference

          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 120,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PHONE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_EMAIL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.email ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + source + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  RoomManager().getNameRoomById(
                                                      booking.room!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SOURCE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sourceName!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          DateUtil.to14h(booking
                                                                  .inTime ??
                                                              booking.inDate!)),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Container(
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              NumberUtil.numberFormat
                                                  .format(totalCharge),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 20))),
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.center,
                          2: Alignment.centerRight
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CURRENCY),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: <List<String>>[
                          <String>[
                            UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
                            'VND',
                            showPrice
                                ? NumberUtil.numberFormat
                                    .format(booking.getRoomCharge())
                                : ''
                          ],
                          if (showService) ...[
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_EXTRA_HOUR),
                              'VND',
                              NumberUtil.numberFormat
                                  .format(booking.extraHour!.total)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TOOLTIP_EXTRA_GUEST),
                              'VND',
                              NumberUtil.numberFormat.format(booking.extraGuest)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                              'VND',
                              NumberUtil.numberFormat.format(booking.minibar)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_RESTAURANT),
                              'VND',
                              NumberUtil.numberFormat
                                  .format(booking.outsideRestaurant)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                              'VND',
                              NumberUtil.numberFormat.format(booking.laundry)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
                              'VND',
                              NumberUtil.numberFormat.format(booking.bikeRental)
                            ],
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_OTHER),
                              'VND',
                              NumberUtil.numberFormat.format(booking.other)
                            ],
                          ],
                          if (booking.transferred != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.PDF_TRANSFERRED),
                              'VND',
                              NumberUtil.numberFormat
                                  .format(booking.transferred)
                            ],
                          if (booking.discount != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                              'VND',
                              '-${NumberUtil.numberFormat.format(booking.discount)}'
                            ],
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //total before service-fee and vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(UITitleCode
                                .TABLEHEADER_TOTAL_BEFORE_SERVICEFEE_AND_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(totalBeforeVAT),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //service fee
                    serviceFeeMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SERVICE_FEE),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat
                                        .format(serviceFeeMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    SizedBox(height: 8),
                    //vat
                    vatMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_VAT),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat.format(vatMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    //subtotal
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SUBTOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(totalCharge),
                              style: NeutronTextStyle.pdfContent),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                    //payment
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PAYMENT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(
                                  booking.deposit! - booking.otaDeposit!),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //transferring
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.PDF_TRANSFERRING),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat
                                  .format(booking.transferring),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //remaining
                    Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: mainColor, width: 0.1))),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_REMAIN),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat
                                  .format(booking.getRemaining()),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                  ]),
            ),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        })); //
    return doc;
  }

  static Future<Document> buildCheckOutForBookingPDFDoc(
      Booking booking,
      CheckOutController controller,
      bool showPrice,
      bool showService,
      bool showPayment,
      bool showRemaining,
      bool showDailyRate) async {
    print(
        "$showPrice - $showService -$showPayment - $showRemaining -  $showDailyRate");
    List<DateTime> listDate =
        DateUtil.getStaysDay(booking.inDate!, booking.outDate!);
    Map<String, num> dataPrice = {};
    if (controller.selectMonth ==
        UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
      dataPrice = booking.getRoomChargeByDateCostumExprot(
          inDate: controller.startDate, outDate: controller.endDate);
    }

    //chu y 3thang dung no
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          int lengthStaysMonth =
              booking.getMapDayByMonth()["stays_month"]!.length;
          double totalAmount = 0;
          Tax tax = ConfigurationManagement().tax;
          double serviceFee = tax.serviceFee!;
          double vat = tax.vat!;
          num totalRoom = controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? booking.totalRoomCharge!
              : booking.getRoomCharge();
          num totalChargeRoom = controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? booking.getServiceCharge() +
                  (booking.totalRoomCharge ?? 0) -
                  booking.discount!
              : booking.getTotalCharge()!;

          num remain = controller.selectMonth ==
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? booking.getRemaining()!
              : totalChargeRoom +
                  booking.transferred! -
                  booking.deposit! -
                  booking.transferring!;

          ///
          num totalCharge = showPrice && showService
              ? totalChargeRoom + booking.transferred!
              : showPrice
                  ? totalRoom + booking.transferred! - booking.discount!
                  : totalChargeRoom - totalRoom + booking.transferred!;

          double totalBeforeVAT =
              totalCharge / (1 + vat + serviceFee + vat * serviceFee);

          double serviceFeeMoney =
              (totalBeforeVAT * serviceFee).roundToDouble();

          double vatMoney =
              ((totalBeforeVAT + serviceFeeMoney) * vat).roundToDouble();

          totalBeforeVAT =
              totalCharge - serviceFeeMoney - vatMoney; //to prevent difference

          int dayStart = 0;
          int monthStart = 0;
          int yearStart = 0;
          String selectedNew = "";
          if (controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL) &&
              controller.selectMonth !=
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
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 120,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PHONE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_EMAIL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.email ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + source + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  RoomManager().getNameRoomById(
                                                      booking.room!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SOURCE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sourceName!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil.dateToDayMonthYearHourMinuteString(
                                                      (booking.bookingType ==
                                                                  BookingType
                                                                      .monthly &&
                                                              BookingInOutByHour
                                                                      .monthly ==
                                                                  GeneralManager
                                                                      .hotel!
                                                                      .hourBookingMonthly)
                                                          ? DateUtil.to0h(
                                                              booking.inTime ??
                                                                  booking
                                                                      .inDate!)
                                                          : DateUtil.to14h(
                                                              booking.inTime ??
                                                                  booking
                                                                      .inDate!)),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil.dateToDayMonthYearHourMinuteString(
                                                      (booking.bookingType ==
                                                                  BookingType
                                                                      .monthly &&
                                                              BookingInOutByHour
                                                                      .monthly ==
                                                                  GeneralManager
                                                                      .hotel!
                                                                      .hourBookingMonthly)
                                                          ? DateUtil.to24h(
                                                              booking.outTime ??
                                                                  booking
                                                                      .outDate!)
                                                          : (booking.outTime ??
                                                              booking
                                                                  .outDate!)),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SELECT_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  (booking.bookingType ==
                                                              BookingType
                                                                  .monthly &&
                                                          controller
                                                                  .selectMonth !=
                                                              UITitleUtil
                                                                  .getTitleByCode(
                                                                      UITitleCode
                                                                          .ALL) &&
                                                          controller
                                                                  .selectMonth ==
                                                              UITitleUtil
                                                                  .getTitleByCode(
                                                                      UITitleCode
                                                                          .CUSTOM))
                                                      ? "${DateUtil.dateToDayMonthYearString(controller.startDate)} - ${DateUtil.dateToDayMonthYearString(controller.endDate)}"
                                                      : controller.selectMonth,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Container(
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              NumberUtil.numberFormat
                                                  .format(totalCharge),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 20))),
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.center,
                          2: Alignment.centerRight
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CURRENCY),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: <List<String>>[
                          <String>[
                            UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
                            'VND',
                            showPrice
                                ? NumberUtil.numberFormat.format(totalRoom)
                                : '0'
                          ],
                          if (showService) ...[
                            if (booking.extraHour!.total! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_EXTRA_HOUR),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.extraHour!.total)
                              ],
                            if (booking.extraGuest! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_EXTRA_GUEST),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.extraGuest)
                              ],
                            if (booking.minibar! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                                'VND',
                                NumberUtil.numberFormat.format(booking.minibar)
                              ],
                            if (booking.insideRestaurant! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.insideRestaurant)
                              ],
                            if (booking.outsideRestaurant! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_INDEPENDEMT_RESTAURANT),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.outsideRestaurant)
                              ],
                            if (booking.laundry > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                                'VND',
                                NumberUtil.numberFormat.format(booking.laundry)
                              ],
                            if (booking.bikeRental! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_BIKE_RENTAL_SERVICE),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.bikeRental)
                              ],
                            // if (booking.electricity! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_ELECTRICITY),
                            //     'VND',
                            //     NumberUtil.numberFormat
                            //         .format(booking.electricity!)
                            //   ],
                            // if (booking.water! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_WATER),
                            //     'VND',
                            //     NumberUtil.numberFormat.format(booking.water!)
                            //   ],
                            // if (booking.other! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_OTHER),
                            //     'VND',
                            //     NumberUtil.numberFormat.format(booking.other)
                            //   ],
                            // if (booking.other! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_DETAIL),
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_TYPE),
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_TOTAL)
                            //   ],
                            if (booking.other! > 0)
                              ...controller.servicesOther
                                  .map((e) => <String>[
                                        OtherManager()
                                            .getServiceNameByID(e.type!),
                                        // DateUtil.dateToDayMonthYearString(
                                        //     e.created!.toDate()),
                                        'VND',
                                        NumberUtil.numberFormat.format(e.total)
                                      ])
                                  .toList()
                          ],
                          if (booking.transferred != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.PDF_TRANSFERRED),
                              'VND',
                              NumberUtil.numberFormat
                                  .format(booking.transferred)
                            ],
                          if (booking.discount != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                              'VND',
                              '-${NumberUtil.numberFormat.format(booking.discount)}'
                            ],
                        ]),
                    //Booking  -electricityWater
                    if (booking.electricity != 0 || booking.water != 0) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Container(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ELECTRICITY_WATER),
                                  style: NeutronTextStyle.pdfTableHeader),
                            ),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_INITIAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_FINAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                    ],
                    //ĐIỆN
                    if (booking.electricity! > 0) ...[
                      ...controller.servicesElectricity
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: controller.servicesElectricity
                                                    .indexOf(e) ==
                                                0
                                            ? Text(
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode
                                                        .TABLEHEADER_ELECTRICITY),
                                                textAlign: TextAlign.center)
                                            : SizedBox()),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthString(e.initialTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthString(e.finalTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            e.priceElectricity.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                    //Nươc
                    if (booking.water! > 0) ...[
                      ...controller.servicesWater
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: controller.servicesWater
                                                    .indexOf(e) ==
                                                0
                                            ? Text(
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode
                                                        .TABLEHEADER_WATER),
                                                textAlign: TextAlign.center)
                                            : SizedBox()),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthString(e.initialTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthString(e.finalTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.priceWater.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList()
                    ],
                    SizedBox(height: PADDING_BELOW_TABLE),
                    if (showDailyRate) ...[
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                  style: TextStyle(
                                      color: mainColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ROOM_CHARGE_DETAIL))),
                          Expanded(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  UITitleUtil.getTitleByCode(
                                      booking.bookingType == BookingType.monthly
                                          ? UITitleCode.TABLEHEADER_MONTH
                                          : UITitleCode.TABLEHEADER_DATE))),
                          Expanded(
                              child: Text(
                                  textAlign: TextAlign.end,
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ROOM_CHARGE_FULL)))
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: mainColor, width: 0.2))),
                      ),
                      if (booking.bookingType == BookingType.monthly) ...[
                        if (controller.selectMonth ==
                            UITitleUtil.getTitleByCode(UITitleCode.ALL)) ...[
                          for (var i = 0;
                              i <
                                  booking
                                      .getMapDayByMonth()["stays_month"]!
                                      .length;
                              i++)
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('#d3d8dc'),
                                            width: 0.1))),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("")),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            booking
                                                .getMapDayByMonth()[
                                                    "stays_month"]!
                                                .toList()[i])),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.end,
                                            showPrice
                                                ? NumberUtil.numberFormat
                                                    .format(booking.price![i])
                                                : '0'))
                                  ],
                                )),
                          for (var i = booking
                                  .getMapDayByMonth()["stays_month"]!
                                  .length;
                              i <
                                  (booking
                                          .getMapDayByMonth()["stays_day"]!
                                          .length +
                                      booking
                                          .getMapDayByMonth()["stays_month"]!
                                          .length);
                              i++)
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('#d3d8dc'),
                                            width: 0.1))),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("")),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            booking
                                                    .getMapDayByMonth()[
                                                        "stays_day"]!
                                                    .toList()[
                                                i -
                                                    booking
                                                        .getMapDayByMonth()[
                                                            "stays_month"]!
                                                        .length])),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.end,
                                            showPrice
                                                ? NumberUtil.numberFormat
                                                    .format(booking.price![i])
                                                : '0'))
                                  ],
                                )),
                        ],
                        if (controller.selectMonth !=
                            UITitleUtil.getTitleByCode(UITitleCode.ALL)) ...[
                          if (controller
                                  .getDayByMonth()
                                  .indexOf(controller.selectMonth) ==
                              (controller.getDayByMonth().length - 1)) ...[
                            if (controller
                                .getDayByMonth()
                                .contains(selectedNew))
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.center,
                                              selectedNew)),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? booking.price![controller
                                                          .getDayByMonth()
                                                          .indexOf(selectedNew)]
                                                      .toString()
                                                  : '0'))
                                    ],
                                  )),
                            if (!controller
                                .getDayByMonth()
                                .contains(selectedNew))
                              for (var i = lengthStaysMonth -
                                      (lengthStaysMonth <= 1 ? 1 : 2);
                                  i < lengthStaysMonth;
                                  i++)
                                Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color:
                                                    PdfColor.fromHex('#d3d8dc'),
                                                width: 0.1))),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("")),
                                        Expanded(
                                            child: Text(
                                                textAlign: TextAlign.center,
                                                booking
                                                    .getMapDayByMonth()[
                                                        "stays_month"]!
                                                    .toList()[i])),
                                        Expanded(
                                            child: Text(
                                                textAlign: TextAlign.end,
                                                showPrice
                                                    ? NumberUtil.numberFormat
                                                        .format(
                                                            booking.price![i])
                                                    : '0'))
                                      ],
                                    )),
                            for (var i = booking
                                    .getMapDayByMonth()["stays_month"]!
                                    .length;
                                i <
                                    (booking
                                            .getMapDayByMonth()["stays_day"]!
                                            .length +
                                        booking
                                            .getMapDayByMonth()["stays_month"]!
                                            .length);
                                i++)
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            booking
                                                    .getMapDayByMonth()[
                                                        "stays_day"]!
                                                    .toList()[
                                                i -
                                                    booking
                                                        .getMapDayByMonth()[
                                                            "stays_month"]!
                                                        .length]),
                                      ),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? NumberUtil.numberFormat
                                                      .format(booking.price![i])
                                                  : '0'))
                                    ],
                                  )),
                          ],
                          if (controller
                                  .getDayByMonth()
                                  .indexOf(controller.selectMonth) !=
                              (controller.getDayByMonth().length - 1)) ...[
                            if (controller.selectMonth !=
                                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.center,
                                              controller.selectMonth)),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? booking.price![controller
                                                          .getDayByMonth()
                                                          .indexOf(controller
                                                              .selectMonth)]
                                                      .toString()
                                                  : '0'))
                                    ],
                                  )),
                            if (controller.selectMonth ==
                                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
                              ...dataPrice.keys
                                  .map((key) => Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: PdfColor.fromHex(
                                                      '#d3d8dc'),
                                                  width: 0.1))),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text("")),
                                          Expanded(
                                              child: Text(
                                                  textAlign: TextAlign.center,
                                                  key)),
                                          Expanded(
                                              child: Text(
                                                  textAlign: TextAlign.end,
                                                  showPrice
                                                      ? dataPrice[key]
                                                          .toString()
                                                      : '0'))
                                        ],
                                      )))
                                  .toList(),
                          ]
                        ]
                      ],
                      if (booking.bookingType != BookingType.monthly)
                        for (var i = 0; i < listDate.length; i++)
                          Container(
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('#d3d8dc'),
                                          width: 0.1))),
                              child: Row(
                                children: [
                                  Expanded(child: Text("")),
                                  Expanded(
                                      child: Text(
                                          textAlign: TextAlign.center,
                                          DateUtil.dateToStringDDMMYYY(
                                              listDate[i]))),
                                  Expanded(
                                      child: Text(
                                          textAlign: TextAlign.end,
                                          showPrice
                                              ? NumberUtil.numberFormat
                                                  .format(booking.price![i])
                                              : '0'))
                                ],
                              )),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: mainColor, width: 0.2))),
                      ),
                    ],
                    //total before service-fee and vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(UITitleCode
                                .TABLEHEADER_TOTAL_BEFORE_SERVICEFEE_AND_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(totalBeforeVAT),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //service fee
                    serviceFeeMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SERVICE_FEE),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat
                                        .format(serviceFeeMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    SizedBox(height: 8),
                    //vat
                    vatMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_VAT),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat.format(vatMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    //subtotal
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SUBTOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(totalCharge),
                              style: NeutronTextStyle.pdfContent),
                        )
                      ]),
                    ),

                    if (showPayment) ...[
                      Divider(height: 10, thickness: 0.5, color: mainColor),
                      Text('Thanh toán (Deposit)'),
                      SizedBox(height: 4),
                      //title
                      Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_DATE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_METHOD),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      if ((booking.paymentDetails != null &&
                              controller.selectMonth ==
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.ALL)) ||
                          (booking.paymentDetails != null &&
                              controller.selectMonth !=
                                  UITitleUtil.getTitleByCode(UITitleCode.ALL) &&
                              controller.isDeposit)) ...[
                        //content
                        ...booking
                            .getDetailPayments(
                                controller.startDate, controller.endDate)
                            .map((e) {
                          List<String> descArray =
                              e.toString().split(specificCharacter);
                          totalAmount += double.parse(descArray[1]);
                          return Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          descArray.length < 3
                                              ? ""
                                              : DateUtil.dateToDayMonthYearString(
                                                  DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          int.parse(
                                                              descArray[2]))),
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  descArray[0]),
                                          textAlign: TextAlign.right)),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          '- ${NumberUtil.numberFormat.format(double.parse(descArray[1]))}',
                                          textAlign: TextAlign.right)),
                                ],
                              ));
                        }).toList(),
                        //total
                        Container(
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: PdfColor.fromHex('cccccc'),
                                        width: 0.2))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child:
                                        Text("", textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        UITitleUtil.getTitleByCode(UITitleCode
                                            .TABLEHEADER_PRICE_TOTAL),
                                        textAlign: TextAlign.right)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        "- ${NumberUtil.numberFormat.format(totalAmount)}",
                                        textAlign: TextAlign.right)),
                              ],
                            )),
                      ],
                    ],

                    SizedBox(height: 8),
                    showRemaining
                        //remaining
                        ? Container(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: mainColor, width: 0.1))),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_REMAIN),
                                    style:
                                        NeutronTextStyle.pdfContentMainColor),
                              )),
                              Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat.format(remain),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: PdfColor.fromHex('#424242'))),
                              )
                            ]),
                          )
                        : SizedBox(height: 20),
                  ]),
            ),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        })); //
    return doc;
  }

  static Future<Document> buildGroupCheckOutPDFDoc(
      Group group,
      GroupController controller,
      bool showPrice,
      bool isShowService,
      bool isShowPayment,
      bool isShowRemaining) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Group groupDpf = controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? group
              : controller.getGroup();
          Map<String, String> mapData =
              controller.bookingParent.bookingType == BookingType.monthly
                  ? controller.mapData
                  : groupDpf.getRoomChargeDetail();
          double totalAmount = 0;
          Tax tax = ConfigurationManagement().tax;
          double serviceFee = tax.serviceFee!;
          double vat = tax.vat!;

          double groupRoomCharge =
              showPrice ? groupDpf.roomCharge!.toDouble() : 0;

          double totalCharge = groupRoomCharge +
              (isShowService ? groupDpf.service!.toDouble() : 0);

          double totalBeforeVAT =
              totalCharge / (1 + vat + serviceFee + vat * serviceFee);
          double serviceFeeMoney =
              (totalBeforeVAT * serviceFee).roundToDouble();
          double vatMoney =
              ((totalBeforeVAT + serviceFeeMoney) * vat).roundToDouble();
          totalBeforeVAT =
              totalCharge - serviceFeeMoney - vatMoney; //to prevent difference
          double remain = (showPrice
                  ? groupDpf.remaining
                  : groupDpf.remaining! - groupDpf.roomCharge!)!
              .toDouble();

          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //title
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 110,
                      child: Row(children: [
                        //customer info
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_NAME),
                                  style: NeutronTextStyle.pdfLightContent),
                              SizedBox(height: 3),
                              Text(groupDpf.name!,
                                  style: NeutronTextStyle.pdfContent),
                              Spacer(),
                              Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_PHONE),
                                  style: NeutronTextStyle.pdfLightContent),
                              SizedBox(height: 3),
                              Text(groupDpf.phone!,
                                  style: NeutronTextStyle.pdfContent),
                              Spacer(),
                              Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_EMAIL),
                                  style: NeutronTextStyle.pdfLightContent),
                              SizedBox(height: 3),
                              Text(groupDpf.email ?? "",
                                  style: NeutronTextStyle.pdfContent),
                            ])),
                        //source + sid
                        Expanded(
                            child: Column(
                          children: [
                            Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SOURCE),
                                style: NeutronTextStyle.pdfLightContent),
                            SizedBox(height: 6),
                            Text(
                                SourceManager()
                                    .getSourceNameByID(groupDpf.sourceID!),
                                style: NeutronTextStyle.pdfContent),
                            Spacer(),
                            Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SID),
                                style: NeutronTextStyle.pdfLightContent),
                            SizedBox(height: 6),
                            Text(groupDpf.sID!,
                                style: NeutronTextStyle.pdfContent),
                          ],
                        )),
                        //indate outdate
                        Expanded(
                            child: Column(
                          children: [
                            Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                style: NeutronTextStyle.pdfLightContent),
                            SizedBox(height: 6),
                            Text(
                                DateUtil.dateToDayMonthYearHourMinuteString(
                                    DateUtil.to14h(groupDpf.inDate!)),
                                style: NeutronTextStyle.pdfContent),
                            Spacer(),
                            Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_DEPARTURE_DATE),
                                style: NeutronTextStyle.pdfLightContent),
                            SizedBox(height: 6),
                            Text(
                                DateUtil.dateToDayMonthYearHourMinuteString(
                                    (controller.bookingParent.bookingType ==
                                                BookingType.monthly &&
                                            BookingInOutByHour.monthly ==
                                                GeneralManager
                                                    .hotel!.hourBookingMonthly)
                                        ? DateUtil.to24h(groupDpf.outDate!)
                                        : groupDpf.outDate!),
                                style: NeutronTextStyle.pdfContent),
                            Spacer(),
                            Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SELECT_DATE),
                                style: NeutronTextStyle.pdfLightContent),
                            SizedBox(height: 6),
                            Text(controller.selectMonth,
                                style: NeutronTextStyle.pdfContent),
                          ],
                        )),
                        //invoice total
                        Container(
                            width: 150,
                            alignment: Alignment.centerRight,
                            child: Column(children: [
                              Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_INVOICE_TOTAL),
                                  style: NeutronTextStyle.pdfLightContent),
                              Spacer(),
                              Text(NumberUtil.numberFormat.format(totalCharge),
                                  style: TextStyle(
                                      color: mainColor, fontSize: 20)),
                              Spacer(),
                            ]))
                      ]),
                    ),
                    Divider(height: 8, thickness: 0.5, color: mainColor),
                    Text('Dịch vụ (Service)'),
                    SizedBox(height: 4),
                    //table header
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_DATE),
                                  style: NeutronTextStyle.pdfTableHeader,
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                                  style: NeutronTextStyle.pdfTableHeader,
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ROOM),
                                  style: NeutronTextStyle.pdfTableHeader,
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_UNIT_PRICE),
                                  style: NeutronTextStyle.pdfTableHeader,
                                  textAlign: TextAlign.right)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                  style: NeutronTextStyle.pdfTableHeader,
                                  textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    // table content
                    if (showPrice)
                      ...mapData.keys.map((e) {
                        var price = controller.bookingParent.bookingType ==
                                BookingType.monthly
                            ? int.parse(controller.dataPriceByMonth[
                                    "${e.split(", ")[0]}, ${mapData[e]}"]!
                                .split(", ")[1])
                            : int.parse(e.split(", ")[1]);
                        return Container(
                            height: mapData.length > 9 ? 65 : 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: PdfColor.fromHex('cccccc'),
                                        width: 0.2))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        controller.bookingParent.bookingType ==
                                                BookingType.monthly
                                            ? e.split(", ")[0]
                                            : DateUtil.dateToDayMonthYearString(
                                                DateTime.parse(
                                                    e.split(", ")[0])),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 2,
                                    child: Text('Tiền phòng (Room Charge)',
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 2,
                                    child: Text(mapData[e]!,
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        NumberUtil.numberFormat.format(price),
                                        textAlign: TextAlign.right)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        NumberUtil.numberFormat.format((price *
                                            mapData[e]!.split(", ").length)),
                                        textAlign: TextAlign.right)),
                              ],
                            ));
                      }).toList(),

                    if (isShowService)
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                  '${DateUtil.dateToDayMonthString(groupDpf.inDate!)} - ${DateUtil.dateToDayMonthString(groupDpf.outDate!)}',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text('Tổng tiền dịch vụ (Service Charge)',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text('Toàn bộ (All)',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  NumberUtil.numberFormat
                                      .format(groupDpf.service),
                                  textAlign: TextAlign.right)),
                        ]),
                      ),

                    if (isShowService && controller.servicesOther.isNotEmpty)
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(children: [
                          Expanded(
                              flex: 1,
                              child: Text('Chi tiết other',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_CREATED_TIME),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TYPE),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_ROOM),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_TOTAL),
                                  textAlign: TextAlign.right)),
                        ]),
                      ),
                    if (isShowService && controller.servicesOther.isNotEmpty)
                      for (var other in controller.servicesOther)
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(children: [
                            Expanded(
                                flex: 1,
                                child: Text('', textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    DateUtil.dateToDayMonthYearString(
                                        other.created!.toDate()),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    OtherManager()
                                        .getServiceNameByID(other.type!),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    RoomManager().getNameRoomById(other.room!),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    NumberUtil.numberFormat.format(other.total),
                                    textAlign: TextAlign.right)),
                          ]),
                        ),

                    // Table.fromTextArray(
                    SizedBox(height: 10),
                    // total before service-fee and vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(UITitleCode
                                .TABLEHEADER_TOTAL_BEFORE_SERVICEFEE_AND_VAT),
                            style: NeutronTextStyle.pdfSmallContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(totalBeforeVAT),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 4),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfSmallContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFeeMoney),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 4),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfSmallContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vatMoney),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 4),
                    //discount
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DISCOUNT),
                            style: NeutronTextStyle.pdfSmallContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(groupDpf.discount),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 4),
                    //total
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TOTAL),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(totalCharge),
                              style: NeutronTextStyle.pdfContentMainColor)),
                    ]),

                    if (isShowPayment) ...[
                      Divider(height: 10, thickness: 0.5, color: mainColor),
                      Text('Thanh toán (Deposit)'),
                      SizedBox(height: 4),
                      //title
                      Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_DATE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_METHOD),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.right)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                      ),
                      if (controller.bookingParent.paymentDetails != null &&
                          (controller.isDepositAllBooking ||
                              controller.selectMonth ==
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.ALL))) ...[
                        //content
                        ...controller.bookingParent.paymentDetails!.values
                            .map((e) {
                          List<String> descArray =
                              e.toString().split(specificCharacter);
                          totalAmount += double.parse(descArray[1]);
                          return Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          descArray.length < 3
                                              ? ""
                                              : DateUtil.dateToDayMonthYearString(
                                                  DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          int.parse(
                                                              descArray[2]))),
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          PaymentMethodManager()
                                              .getPaymentMethodNameById(
                                                  descArray[0]),
                                          textAlign: TextAlign.right)),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          '- ${NumberUtil.numberFormat.format(double.parse(descArray[1]))}',
                                          textAlign: TextAlign.right)),
                                ],
                              ));
                        }).toList(),
                        //total
                        Container(
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: PdfColor.fromHex('cccccc'),
                                        width: 0.2))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child:
                                        Text("", textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        UITitleUtil.getTitleByCode(UITitleCode
                                            .TABLEHEADER_PRICE_TOTAL),
                                        textAlign: TextAlign.right)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        "- ${NumberUtil.numberFormat.format(totalAmount)}",
                                        textAlign: TextAlign.right)),
                              ],
                            )),
                      ],
                    ],

                    SizedBox(height: 10),
                    //total
                    if (isShowRemaining)
                      Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_REMAIN),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                            alignment: Alignment.centerRight,
                            width: 150,
                            child: Text(NumberUtil.numberFormat.format(remain),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: PdfColor.fromHex('#424242')))),
                      ]),
                  ]),
            ),
            SizedBox(height: 20),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Spacer(),
            footer
          ];
        })); //
    return doc;
  }

  static Future<Document> buildBikeRentalPDFDoc(
      Booking booking, BikeRental bikeRental) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    String numberBill = bikeRental.id!
        .substring(bikeRental.id!.length == 15 ? 9 : 10, bikeRental.id!.length);
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) => [
              _buildHeader(
                  UITitleUtil.getTitleByCode(UITitleCode.PDF_BIKE_RENTAL_FORM)),
              Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: HORIZONTAL_PADDING),
                  height: 100,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //title
                        Row(children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_GUEST_INFOS),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ID),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                          Expanded(
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INVOICE_TOTAL),
                                style: NeutronTextStyle.pdfLightContent),
                          ),
                        ]),
                        //content
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //customer
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(booking.name!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.phone!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.email!,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //id + room
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(bikeRental.id!,
                                            style: NeutronTextStyle.pdfContent),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_ROOM),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(
                                            RoomManager()
                                                .getNameRoomById(booking.room!),
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //total
                                Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                            bikeRental.progress ==
                                                    BikeRentalProgress.checkout
                                                ? NumberUtil.numberFormat
                                                    .format(bikeRental.total)
                                                : '',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontSize: 20)),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_NUMNER_BILL),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(numberBill,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                )
                              ]),
                        ),
                      ])),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
                child: Table.fromTextArray(
                    context: context,
                    border: TableBorder(
                        top: BorderSide(color: mainColor, width: 2),
                        bottom: BorderSide(color: mainColor, width: 2)),
                    cellAlignments: <int, Alignment>{
                      0: Alignment.centerLeft,
                      1: Alignment.centerLeft,
                    },
                    cellStyle: NeutronTextStyle.pdfContent,
                    rowDecoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: PdfColor.fromHex('#d3d8dc'), width: 0.1)),
                    ),
                    cellHeight: 30,
                    headerStyle: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                    headers: [
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DETAIL),
                    ],
                    data: <List<String>>[
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_TYPE),
                        bikeRental.type!
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_BIKE),
                        bikeRental.bike!
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_START),
                        DateUtil.dateToDayMonthYearHourMinuteString(
                            bikeRental.start!.toDate())
                      ],
                      if (bikeRental.progress == BikeRentalProgress.checkout)
                        <String>[
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_END),
                          DateUtil.dateToDayMonthYearHourMinuteString(
                              bikeRental.end!.toDate())
                        ],
                      <String>[
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_PRICE_PER_DAY),
                        NumberUtil.numberFormat.format(bikeRental.price)
                      ],
                      if (bikeRental.progress == BikeRentalProgress.checkout)
                        <String>[
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TOTAL),
                          NumberUtil.numberFormat.format(bikeRental.total)
                        ],
                    ]),
              ),
              SizedBox(height: 50),
              //signature
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_GUEST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: NeutronTextStyle.pdfContent,
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                    textAlign: TextAlign.center)
              ]),
              Expanded(child: Container()),
              footer
            ]));
    return doc;
  }

  static Future<Document> buildAllServicePDFDoc(Booking booking) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          num serviceCharge = booking.getServiceCharge();
          double vat = serviceCharge * tax.vat!;
          double serviceFee = serviceCharge * tax.serviceFee!;
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_SERVICE_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.room!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Container(
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              NumberUtil.numberFormat
                                                  .format(serviceCharge),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 20))),
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.center,
                          2: Alignment.centerRight
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CURRENCY),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: <List<String>>[
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_EXTRA_HOUR),
                            'VND',
                            NumberUtil.numberFormat
                                .format(booking.extraHour!.total)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_EXTRA_GUEST),
                            'VND',
                            NumberUtil.numberFormat.format(booking.extraGuest)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                            'VND',
                            NumberUtil.numberFormat.format(booking.minibar)
                          ],
                          <String>[
                            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT)} (${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_INSIDE_HOTEL)})',
                            'VND',
                            NumberUtil.numberFormat
                                .format(booking.insideRestaurant)
                          ],
                          <String>[
                            '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT)} (${UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_OUTSIDE_HOTEL)})',
                            'VND',
                            NumberUtil.numberFormat
                                .format(booking.outsideRestaurant)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                            'VND',
                            NumberUtil.numberFormat.format(booking.laundry)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
                            'VND',
                            NumberUtil.numberFormat.format(booking.bikeRental)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_OTHER),
                            'VND',
                            NumberUtil.numberFormat.format(booking.other)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ELECTRICITY),
                            'VND',
                            NumberUtil.numberFormat.format(booking.electricity)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_WATER),
                            'VND',
                            NumberUtil.numberFormat.format(booking.water)
                          ],
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceCharge),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildDepositPDFDoc(
      Booking booking, Deposit deposit) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_DEPOSIT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room!
                                                              .split(", ")
                                                              .length <
                                                          2
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Container(
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              NumberUtil.numberFormat
                                                  .format(deposit.amount),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 20))),
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DETAIL),
                        ],
                        data: <List<String>>[
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TOOLTIP_CREATED_TIME),
                            DateUtil.dateToDayMonthYearHourMinuteString(
                                deposit.created!.toDate())
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                            NumberUtil.numberFormat.format(deposit.amount)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_METHOD),
                            PaymentMethodManager()
                                .getPaymentMethodNameById(deposit.method!)
                          ],
                          <String>[
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                            deposit.desc!
                          ],
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(deposit.amount),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildInsideRestaurantPDFDoc(
      Booking booking, InsideRestaurantService service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_RESTAURANT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 20)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_UNIT_PRICE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: service.items!.entries
                            .map((e) => [
                                  RestaurantItemManager()
                                      .getItemNameByID(e.key),
                                  NumberUtil.numberFormat
                                      .format(e.value['price']),
                                  NumberUtil.numberFormat
                                      .format(e.value['amount']),
                                  NumberUtil.numberFormat.format(
                                      e.value['amount'] * e.value['price'])
                                ])
                            .toList()),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildExtraguestPDFDoc(
      Booking booking, ExtraGuest service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_EXTRA_GUEST_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 17)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                          4: Alignment.centerRight,
                          5: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CREATED_TIME),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TYPE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_GUEST_NUMBER),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_LENGTH_STAY_COMPACT),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE_TOTAL),
                        ],
                        data: [
                          [
                            DateUtil.dateToDayMonthHourMinuteString(
                                service.created!.toDate()),
                            MessageUtil.getMessageByCode(service.type),
                            NumberUtil.numberFormat.format(service.price),
                            NumberUtil.numberFormat.format(service.number),
                            NumberUtil.numberFormat.format(
                                service.end!.difference(service.start!).inDays),
                            NumberUtil.numberFormat.format(service.price! *
                                service.end!.difference(service.start!).inDays *
                                service.number!)
                          ]
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildBikeRentalOfBookingPDFDoc(
      Booking booking, BikeRental service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(UITitleUtil.getTitleByCode(
                UITitleCode.PDF_BIKE_RENTAL_BILL_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 17)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                          4: Alignment.centerRight,
                          5: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CREATED_TIME),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_BIKE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TYPE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PROGRESS),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE_TOTAL),
                        ],
                        data: [
                          [
                            DateUtil.dateToDayMonthHourMinuteString(
                                service.created!.toDate()),
                            service.bike,
                            MessageUtil.getMessageByCode(service.type),
                            NumberUtil.numberFormat.format(service.price),
                            BikeRentalProgress.getStatusString(
                                service.progress!),
                            NumberUtil.numberFormat.format(service.getTotal())
                          ]
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildOtherPDFDoc(
      Booking booking, Other service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_OTHER_BILL_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 17)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CREATED_TIME),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TYPE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: [
                          [
                            DateUtil.dateToDayMonthHourMinuteString(
                                service.created!.toDate()),
                            OtherManager().getServiceNameByID(service.type!),
                            NumberUtil.numberFormat.format(service.total),
                          ]
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildOutSideHotelPDFDoc(
      Booking booking, OutsideRestaurantService service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_OUTSIDE_HOTEL_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 17)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                          4: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CREATED_TIME),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE_TOTAL),
                        ],
                        data: [
                          ...service.items!
                              .map((e) => [
                                    DateUtil.dateToDayMonthHourMinuteString(
                                        service.created!.toDate()),
                                    e.name,
                                    NumberUtil.numberFormat.format(e.price),
                                    e.quantity.toString(),
                                    NumberUtil.numberFormat
                                        .format(e.price * e.quantity),
                                  ])
                              .toList(),
                        ]),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildAllServiceOfBookingPDFDoc(
      Booking booking,
      List<Minibar> minibarData,
      List<InsideRestaurantService> insiderRestautant,
      List<ExtraGuest> extraGuestData,
      List<Laundry> laundryData,
      List<BikeRental> bikeRentalData,
      List<Other> otherData,
      List<OutsideRestaurantService> outsideRestaurantServiceData,
      List<Electricity> electricity,
      List<Water> waterData) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          num totalMinibar = 0;
          num totalInRestaurant = 0;
          num totalextraguest = 0;
          num totalaudry = 0;
          num totaBikeRental = 0;
          num totaOther = 0;
          num totaOutRes = 0;
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_DETAIL_ALL_SERVICE)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(booking
                                                          .getServiceCharge()),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 17)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text("00000",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Divider(height: 10, thickness: 0.5, color: mainColor),
                    //minibar
                    if (minibarData.isNotEmpty) ...[
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      //title minibar
                      Container(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ITEM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_AMOUNT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      //content Minibar
                      ...minibarData.map((minibar) {
                        String numberBill = minibar.id!.substring(
                            minibar.id!.length == 15 ? 9 : 10,
                            minibar.id!.length);
                        return Column(children: [
                          Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          "${DateUtil.dateToDayMonthHourMinuteString(minibar.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(minibar.room!) : ""}\nMHD: $numberBill ",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 2,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                ],
                              )),
                          ...minibar.getItems()!.map((e) {
                            totalMinibar +=
                                minibar.getPrice(e) * minibar.getAmount(e);
                            return Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            ItemManager().getItemNameByID(e)!,
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat
                                                .format(minibar.getPrice(e)),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            minibar.getAmount(e).toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                minibar.getPrice(e) *
                                                    minibar.getAmount(e)),
                                            textAlign: TextAlign.center)),
                                  ],
                                ));
                          }).toList(),
                        ]);
                      }).toList(),
                      //total minibar
                      Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      NumberUtil.numberFormat
                                          .format(totalMinibar),
                                      textAlign: TextAlign.center)),
                            ],
                          )),
                    ],
                    //in res
                    if (insiderRestautant.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_INSIDE_HOTEL),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      //title In Restaurant
                      Container(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ITEM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_AMOUNT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      //content inrestaurant
                      ...insiderRestautant.map((insiderestautant) {
                        String numberBill = insiderestautant.id!.substring(
                            insiderestautant.id!.length == 15 ? 9 : 10,
                            insiderestautant.id!.length);
                        return Column(children: [
                          Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          "${DateUtil.dateToDayMonthHourMinuteString(insiderestautant.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(insiderestautant.room!) : ""}\nMHD: $numberBill",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 2,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                ],
                              )),
                          ...insiderestautant.getItems()!.map((e) {
                            totalInRestaurant += insiderestautant.getPrice(e) *
                                insiderestautant.getAmount(e);
                            return Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            ItemManager().getItemNameByID(e)!,
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                insiderestautant.getPrice(e)),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            insiderestautant
                                                .getAmount(e)
                                                .toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                insiderestautant.getPrice(e) *
                                                    insiderestautant
                                                        .getAmount(e)),
                                            textAlign: TextAlign.center)),
                                  ],
                                ));
                          }).toList(),
                        ]);
                      }).toList(),
                      //total inrestaurant
                      Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      NumberUtil.numberFormat
                                          .format(totalInRestaurant),
                                      textAlign: TextAlign.center)),
                            ],
                          )),
                    ],

                    //extraguest
                    if (extraGuestData.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      SizedBox(height: 4),
                      Table.fromTextArray(
                          context: context,
                          border: TableBorder(
                              top: BorderSide(color: mainColor, width: 2)),
                          cellAlignments: <int, Alignment>{
                            0: Alignment.centerLeft,
                            1: Alignment.centerRight,
                            2: Alignment.centerRight,
                            3: Alignment.centerRight,
                            4: Alignment.centerRight,
                            5: Alignment.centerRight,
                          },
                          cellStyle: NeutronTextStyle.pdfContent,
                          rowDecoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('#d3d8dc'),
                                    width: 0.1)),
                          ),
                          cellHeight: 30,
                          headerStyle: TextStyle(
                              color: mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          headers: [
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATED_TIME),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TYPE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_GUEST_NUMBER),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_LENGTH_STAY_COMPACT),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE_TOTAL),
                          ],
                          data: [
                            ...extraGuestData.map((extraguest) {
                              String numberBill = extraguest.id!.substring(
                                  extraguest.id!.length == 15 ? 9 : 10,
                                  extraguest.id!.length);
                              totalextraguest += extraguest.price! *
                                  extraguest.outDate!
                                      .difference(extraguest.start!)
                                      .inDays *
                                  extraguest.number!;
                              return [
                                "${DateUtil.dateToDayMonthHourMinuteString(extraguest.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(extraguest.room!) : ""}\nMHD: $numberBill",
                                MessageUtil.getMessageByCode(extraguest.type),
                                NumberUtil.numberFormat
                                    .format(extraguest.price),
                                NumberUtil.numberFormat
                                    .format(extraguest.number),
                                NumberUtil.numberFormat.format(extraguest
                                    .outDate!
                                    .difference(extraguest.start!)
                                    .inDays),
                                NumberUtil.numberFormat.format(
                                    extraguest.price! *
                                        extraguest.outDate!
                                            .difference(extraguest.start!)
                                            .inDays *
                                        extraguest.number!)
                              ];
                            }).toList(),
                            [
                              "",
                              "",
                              "",
                              "",
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE_TOTAL),
                              NumberUtil.numberFormat.format(totalextraguest)
                            ]
                          ]),
                    ],

                    //laudry
                    if (laundryData.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      //title Laundry
                      Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ITEM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE)} giặt",
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_IRON_AMOUNT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE)} ủi",
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TOTAL_PAYMENT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center))
                          ],
                        ),
                      ),
                      //content Laundry
                      ...laundryData.map((laundry) {
                        String numberBill = laundry.id!.substring(
                            laundry.id!.length == 15 ? 9 : 10,
                            laundry.id!.length);
                        return Column(children: [
                          Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          "${DateUtil.dateToDayMonthHourMinuteString(laundry.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(laundry.room!) : ""}\nMHD: $numberBill",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                ],
                              )),
                          ...laundry.getItems()!.map((item) {
                            totalaudry += (laundry.getAmount(item, 'laundry') *
                                    laundry.getPrice(item, 'laundry')) +
                                laundry.getAmount(item, 'iron') *
                                    laundry.getPrice(item, 'iron');
                            return Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            LaundryManager()
                                                .getItemNameByID(item),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                laundry.getAmount(
                                                    item, 'laundry')),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                laundry.getPrice(
                                                    item, 'laundry')),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                laundry.getAmount(
                                                    item, 'iron')),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                laundry.getPrice(item, 'iron')),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                (laundry.getAmount(
                                                            item, 'laundry') *
                                                        laundry.getPrice(
                                                            item, 'laundry')) +
                                                    laundry.getAmount(
                                                            item, 'iron') *
                                                        laundry.getPrice(
                                                            item, 'iron')),
                                            textAlign: TextAlign.center)),
                                  ],
                                ));
                          }).toList(),
                        ]);
                      }).toList(),
                      //total Laundry
                      Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      NumberUtil.numberFormat
                                          .format(totalaudry),
                                      textAlign: TextAlign.center)),
                            ],
                          )),
                    ],

                    //bikerental
                    if (bikeRentalData.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      SizedBox(height: 4),
                      Table.fromTextArray(
                          context: context,
                          border: TableBorder(
                              top: BorderSide(color: mainColor, width: 2)),
                          cellAlignments: <int, Alignment>{
                            0: Alignment.centerLeft,
                            1: Alignment.centerRight,
                            2: Alignment.centerRight,
                            3: Alignment.centerRight,
                            4: Alignment.centerRight,
                            5: Alignment.centerRight,
                          },
                          cellStyle: NeutronTextStyle.pdfContent,
                          rowDecoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('#d3d8dc'),
                                    width: 0.1)),
                          ),
                          cellHeight: 30,
                          headerStyle: TextStyle(
                              color: mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          headers: [
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATED_TIME),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_BIKE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TYPE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PROGRESS),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE_TOTAL),
                          ],
                          data: [
                            ...bikeRentalData.map((bikerental) {
                              String numberBill = bikerental.id!.substring(
                                  bikerental.id!.length == 15 ? 9 : 10,
                                  bikerental.id!.length);
                              totaBikeRental += bikerental.getTotal()!;
                              return [
                                "${DateUtil.dateToDayMonthHourMinuteString(bikerental.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(bikerental.room!) : ""}\nMHD: $numberBill",
                                bikerental.bike,
                                MessageUtil.getMessageByCode(bikerental.type),
                                NumberUtil.numberFormat
                                    .format(bikerental.price),
                                BikeRentalProgress.getStatusString(
                                    bikerental.progress!),
                                NumberUtil.numberFormat
                                    .format(bikerental.getTotal())
                              ];
                            }).toList(),
                            [
                              "",
                              "",
                              "",
                              "",
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE_TOTAL),
                              NumberUtil.numberFormat.format(totaBikeRental)
                            ]
                          ]),
                    ],

                    //other
                    if (otherData.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_OTHER),
                          style: NeutronTextStyle.pdfTableHeader),
                      SizedBox(height: 4),
                      Table.fromTextArray(
                          context: context,
                          border: TableBorder(
                              top: BorderSide(color: mainColor, width: 2)),
                          cellAlignments: <int, Alignment>{
                            0: Alignment.centerLeft,
                            1: Alignment.centerRight,
                            2: Alignment.centerRight,
                          },
                          cellStyle: NeutronTextStyle.pdfContent,
                          rowDecoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('#d3d8dc'),
                                    width: 0.1)),
                          ),
                          cellHeight: 30,
                          headerStyle: TextStyle(
                              color: mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                          headers: [
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATED_TIME),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TYPE),
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_PRICE),
                          ],
                          data: [
                            ...otherData.map((other) {
                              String numberBill = other.id!.substring(
                                  other.id!.length == 15 ? 9 : 10,
                                  other.id!.length);
                              totaOther += other.total!;
                              return [
                                "${DateUtil.dateToDayMonthHourMinuteString(other.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(other.room!) : ""}\nMHD: $numberBill",
                                OtherManager().getServiceNameByID(other.type!),
                                NumberUtil.numberFormat.format(other.total),
                              ];
                            }).toList(),
                            [
                              "",
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_PRICE_TOTAL),
                              NumberUtil.numberFormat.format(totaOther)
                            ]
                          ]),
                    ],

                    //Outside Restaurant
                    if (outsideRestaurantServiceData.isNotEmpty) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_OUTSIDE_HOTEL),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      //title
                      Container(
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ITEM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_AMOUNT),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      //content Outside Restaurant
                      ...outsideRestaurantServiceData.map((outside) {
                        String numberBill = outside.id!.substring(
                            outside.id!.length == 15 ? 9 : 10,
                            outside.id!.length);
                        return Column(children: [
                          Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('cccccc'),
                                          width: 0.2))),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          "${DateUtil.dateToDayMonthHourMinuteString(outside.created!.toDate())}-${booking.group! ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_ROOM) : ""}:${booking.group! ? RoomManager().getNameRoomById(outside.room!) : ""}\nMHD: $numberBill",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 2,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 1,
                                      child: Text("",
                                          textAlign: TextAlign.center)),
                                ],
                              )),
                          ...outside.items!.map((item) {
                            totaOutRes += (item.price * item.quantity);
                            return Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text("",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(item.name,
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat
                                                .format(item.price),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(item.quantity.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            NumberUtil.numberFormat.format(
                                                item.price * item.quantity),
                                            textAlign: TextAlign.center)),
                                  ],
                                ));
                          }).toList(),
                        ]);
                      }).toList(),
                      //total Outside Restaurant
                      Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 2,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text("", textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PRICE_TOTAL),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      NumberUtil.numberFormat
                                          .format(totaOutRes),
                                      textAlign: TextAlign.center)),
                            ],
                          )),
                    ],
                    //Booking group -extrahour
                    if (booking.group! &&
                        booking.subBookings != null &&
                        booking.extraHour!.earlyPrice == 0 &&
                        booking.extraHour!.latePrice == 0) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      //nhan phong som
                      Container(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ROOM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_HOUR),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_EARLY_CHECKIN),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text("", textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text("", textAlign: TextAlign.center)),
                          ],
                        ),
                      ),

                      ...booking.subBookings!.keys.map(
                        (e) {
                          if (booking.subBookings![e]["extra_hours"] == null) {
                            return SizedBox();
                          }
                          if (booking.subBookings![e]["extra_hours"]
                                  ['early_price'] ==
                              0) return SizedBox();
                          return Container(
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: PdfColor.fromHex('cccccc'),
                                        width: 0.2))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        RoomManager().getNameRoomById(
                                            booking.subBookings![e]["room"]),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        booking.subBookings![e]["extra_hours"]
                                                ['early_price']
                                            .toString(),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        booking.subBookings![e]["extra_hours"]
                                                ['early_hours']
                                            .toString(),
                                        textAlign: TextAlign.center)),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      //nhan phong tre
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_LATE_CHECKOUT),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text("", textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text("", textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      ...booking.subBookings!.keys.map(
                        (e) {
                          if (booking.subBookings![e]["extra_hours"] == null) {
                            return SizedBox();
                          }
                          if (booking.subBookings![e]["extra_hours"]
                                  ['late_price'] ==
                              0) return SizedBox();
                          return Container(
                            height: 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: PdfColor.fromHex('cccccc'),
                                        width: 0.2))),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        RoomManager().getNameRoomById(
                                            booking.subBookings![e]["room"]),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        booking.subBookings![e]["extra_hours"]
                                                ['late_price']
                                            .toString(),
                                        textAlign: TextAlign.center)),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        booking.subBookings![e]["extra_hours"]
                                                ['late_hours']
                                            .toString(),
                                        textAlign: TextAlign.center)),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ],

                    //Booking -extrahour
                    if (booking.extraHour!.earlyPrice != 0 ||
                        booking.extraHour!.latePrice != 0) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      Container(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ITEM),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_HOUR),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      if (booking.extraHour!.earlyPrice != 0)
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_EARLY_CHECKIN),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      booking.extraHour!.earlyPrice.toString(),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      booking.extraHour!.earlyHours.toString(),
                                      textAlign: TextAlign.center)),
                            ],
                          ),
                        ),
                      if (booking.extraHour!.latePrice != 0)
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('cccccc'),
                                      width: 0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_LATE_CHECKOUT),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      booking.extraHour!.latePrice.toString(),
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                      booking.extraHour!.lateHours.toString(),
                                      textAlign: TextAlign.center)),
                            ],
                          ),
                        ),
                    ],

                    //Booking group -electricityWater
                    if (booking.electricity != 0 || booking.water != 0) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ELECTRICITY_WATER),
                          style: NeutronTextStyle.pdfTableHeader),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                      Container(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_INITIAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_FINAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      //ĐIỆN
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_ELECTRICITY),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 5,
                                child: Text("", textAlign: TextAlign.center))
                          ],
                        ),
                      ),
                      ...electricity
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            RoomManager()
                                                .getNameRoomById(e.room!),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthYearString(e.initialTime)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthYearString(e.finalTime)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            e.priceElectricity.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList(),
                      //Nươc
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: PdfColor.fromHex('cccccc'),
                                    width: 0.2))),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_WATER),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 5,
                                child: Text("", textAlign: TextAlign.center))
                          ],
                        ),
                      ),
                      ...waterData
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            RoomManager()
                                                .getNameRoomById(e.room!),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthYearString(e.initialTime)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthYearString(e.finalTime)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.priceWater.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList()
                    ],

//                     Booking - electricityWater
//                     if (booking.electricityWater!.total != 0 &&
//                         (booking.electricityWater!.lastElectricityNumber != 0 ||
//                             booking.electricityWater!.lastWaterNumber !=
//                                 0)) ...[
//                       SizedBox(height: PADDING_BELOW_TABLE),
//                       Text(
//                           UITitleUtil.getTitleByCode(
//                               UITitleCode.TABLEHEADER_ELECTRICITY_WATER),
//                           style: NeutronTextStyle.pdfTableHeader),
//                       Divider(height: 8, thickness: 0.5, color: mainColor),
//                       Container(
//                         height: 40,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(flex: 1, child: SizedBox()),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     UITitleUtil.getTitleByCode(
//                                         UITitleCode.TABLEHEADER_INITIAL),
//                                     style: NeutronTextStyle.pdfTableHeader,
//                                     textAlign: TextAlign.center)),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     UITitleUtil.getTitleByCode(
//                                         UITitleCode.TABLEHEADER_FINAL),
//                                     style: NeutronTextStyle.pdfTableHeader,
//                                     textAlign: TextAlign.center)),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     UITitleUtil.getTitleByCode(
//                                         UITitleCode.TABLEHEADER_PRICE),
//                                     style: NeutronTextStyle.pdfTableHeader,
//                                     textAlign: TextAlign.center)),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     UITitleUtil.getTitleByCode(
//                                         UITitleCode.TABLEHEADER_TOTAL),
//                                     style: NeutronTextStyle.pdfTableHeader,
//                                     textAlign: TextAlign.center)),
//                           ],
//                         ),
//                       ),
//                       if (booking.electricityWater!.lastElectricityNumber != 0)
//                         Container(
//                           height: 35,
//                           decoration: BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(
//                                       color: PdfColor.fromHex('cccccc'),
//                                       width: 0.2))),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       UITitleUtil.getTitleByCode(
//                                           UITitleCode.TABLEHEADER_ELECTRICITY),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!
//                                           .firstElectricityNumber
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!
//                                           .lastElectricityNumber
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!.electricityPrice
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       ((booking.electricityWater!
//                                                       .lastElectricityNumber! -
//                                                   booking.electricityWater!
//                                                       .firstElectricityNumber!) *
//                                               booking.electricityWater!
//                                                   .electricityPrice!)
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                             ],
//                           ),
//                         ),
//                       if (booking.electricityWater!.lastWaterNumber != 0)
//                         Container(
//                           height: 35,
//                           decoration: BoxDecoration(
//                               border: Border(
//                                   bottom: BorderSide(
//                                       color: PdfColor.fromHex('cccccc'),
//                                       width: 0.2))),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       UITitleUtil.getTitleByCode(
//                                           UITitleCode.TABLEHEADER_WATER),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!.firstWaterNumber
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!.lastWaterNumber
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       booking.electricityWater!.waterPrice
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                               Expanded(
//                                   flex: 1,
//                                   child: Text(
//                                       ((booking.electricityWater!
//                                                       .lastWaterNumber! -
//                                                   booking.electricityWater!
//                                                       .firstWaterNumber!) *
//                                               booking.electricityWater!
//                                                   .waterPrice!)
//                                           .toString(),
//                                       textAlign: TextAlign.center)),
//                             ],
//                           ),
//                         ),
//                       Container(
//                         height: 35,
//                         decoration: BoxDecoration(
//                             border: Border(
//                                 bottom: BorderSide(
//                                     color: PdfColor.fromHex('cccccc'),
//                                     width: 0.2))),
//                         child: Row(
//                           children: [
//                             Expanded(flex: 3, child: SizedBox()),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     UITitleUtil.getTitleByCode(
//                                         UITitleCode.TABLEHEADER_TOTAL),
//                                     textAlign: TextAlign.center)),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                     // booking.electricityWater!.total.toString(),
//                                     ""
// ,                                    textAlign: TextAlign.center)),
//                           ],
//                         ),
//                       ),
//                     ],

                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildMinibarPDFDoc(
      Booking booking, Minibar service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_MINIBAR_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outTime ??
                                                              booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 20)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_UNIT_PRICE),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: service
                            .getItems()!
                            .map((item) => [
                                  ItemManager().getItemNameByID(item),
                                  NumberUtil.numberFormat
                                      .format(service.getPrice(item)),
                                  NumberUtil.numberFormat
                                      .format(service.getAmount(item)),
                                  NumberUtil.numberFormat.format(
                                      service.getAmount(item) *
                                          service.getPrice(item))
                                ])
                            .toList()),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildLaudryPDFDoc(
      Booking booking, Laundry service) async {
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          Tax tax = ConfigurationManagement().tax;
          double vat = service.total! * tax.vat!;
          double serviceFee = service.total! * tax.serviceFee!;
          String numberBill = service.id!
              .substring(service.id!.length == 15 ? 9 : 10, service.id!.length);
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_LAUNDRY_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 100,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_GUEST_INFOS),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.phone!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              Text(booking.email!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  booking.room != null
                                                      ? RoomManager()
                                                          .getNameRoomById(
                                                              booking.room!)
                                                      : 'Group',
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID!,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.inTime ??
                                                              booking.inDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil
                                                      .dateToDayMonthYearHourMinuteString(
                                                          booking.outDate!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Expanded(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  NumberUtil.numberFormat
                                                      .format(service.total),
                                                  style: TextStyle(
                                                      color: mainColor,
                                                      fontSize: 20)),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_NUMNER_BILL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(numberBill,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      )
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.centerRight,
                          2: Alignment.centerRight,
                          3: Alignment.centerRight,
                          4: Alignment.centerRight,
                          5: Alignment.centerRight,
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ITEM),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_LAUNDRY_AMOUNT),
                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE)} giặt",
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_IRON_AMOUNT),
                          "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PRICE)} ủi",
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_TOTAL_PAYMENT),
                        ],
                        data: service
                            .getItems()!
                            .map((item) => [
                                  LaundryManager().getItemNameByID(item),
                                  NumberUtil.numberFormat.format(
                                      service.getAmount(item, 'laundry')),
                                  NumberUtil.numberFormat.format(
                                      service.getPrice(item, 'laundry')),
                                  NumberUtil.numberFormat
                                      .format(service.getAmount(item, 'iron')),
                                  NumberUtil.numberFormat
                                      .format(service.getPrice(item, 'iron')),
                                  NumberUtil.numberFormat.format((service
                                              .getAmount(item, 'laundry') *
                                          service.getPrice(item, 'laundry')) +
                                      service.getAmount(item, 'iron') *
                                          service.getPrice(item, 'iron'))
                                ])
                            .toList()),
                    SizedBox(height: PADDING_BELOW_TABLE),
                    //service fee
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SERVICE_FEE),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(serviceFee),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    //vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(NumberUtil.numberFormat.format(vat),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    //total
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_TOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(service.total),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColor.fromHex('#424242'))),
                        )
                      ]),
                    ),
                    SizedBox(height: 8),
                  ]),
            ),
            SizedBox(height: 50),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        }));
    return doc;
  }

  static Future<Document> buildReservationFormPDFDoc(
      Booking booking, bool showPrice, bool isShowNotes,
      {Uint8List? pngBytes}) async {
    String? notes = '';
    if (isShowNotes) {
      notes = await booking.getNotes();
    }
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) => [
              _buildHeader(
                  UITitleUtil.getTitleByCode(UITitleCode.PDF_RESERVATION_FORM)),
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  height: 120,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //title
                        Row(children: [
                          Expanded(
                            child: Text(
                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKING_CODE)}:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                              child: Text(booking.sID!,
                                  style: NeutronTextStyle.pdfContent)),
                          Expanded(
                            flex: 2,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  SizedBox(
                                      width: 150,
                                      child: Text(
                                          DateUtil.dateToString(
                                              booking.created!.toDate()),
                                          style: NeutronTextStyle.pdfContent)),
                                ]),
                          ),
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_GUEST_INFOS),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(booking.name!,
                                style: NeutronTextStyle.pdfContent),
                          ),
                          Expanded(flex: 2, child: SizedBox())
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(booking.sourceName!,
                                style: NeutronTextStyle.pdfContent),
                          ),
                          Expanded(flex: 2, child: SizedBox())
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE)}:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(booking.phone!,
                                style: NeutronTextStyle.pdfContent),
                          ),
                        ]),
                        SizedBox(height: 10),
                        Expanded(
                          flex: 2,
                          child: Text(
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.CONTENT_THANKYOU,
                                  [GeneralManager.hotel!.name ?? ""]),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        // content
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //customer
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(booking.name!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.phone!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(booking.email!,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //in + out date
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                booking.inDate),
                                            style: NeutronTextStyle.pdfContent),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_DEPARTURE_DATE),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                booking.outDate),
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                              ]),
                        ),
                      ])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Table.fromTextArray(
                    context: context,
                    border: TableBorder(
                        top: BorderSide(color: mainColor, width: 2),
                        bottom: BorderSide(color: mainColor, width: 2)),
                    cellAlignments: <int, Alignment>{
                      0: Alignment.topRight,
                      1: Alignment.topRight,
                      2: Alignment.topRight,
                      3: Alignment.topRight,
                      4: Alignment.topRight,
                      5: Alignment.topRight,
                      6: Alignment.topRight,
                      7: Alignment.topRight,
                    },
                    cellStyle: NeutronTextStyle.pdfContent,
                    rowDecoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: PdfColor.fromHex('#d3d8dc'), width: 0.1)),
                    ),
                    cellHeight: 20,
                    headerStyle: TextStyle(
                        color: mainColor,
                        fontSize: 12,
                        fontWeight: FontWeight.normal),
                    headers: [
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ROOMTYPE),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_NUMBER),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_IN_DATE),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_OUT_DATE),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TOOLTIP_LENGTH_STAY),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_GUEST_NUMBER),
                      UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_TOTAL_FULL),
                    ],
                    data: <List<String>>[
                      <String>[
                        booking.getRoomTypeName(),
                        "1",
                        DateUtil.dateToDayMonthString(booking.inDate!),
                        DateUtil.dateToDayMonthString(booking.outDate!),
                        booking.lengthStay.toString(),
                        '${booking.adult! + booking.child!}',
                        showPrice
                            ? NumberUtil.numberFormat
                                .format(booking.price!.first)
                            : '',
                        showPrice
                            ? NumberUtil.numberFormat
                                .format(booking.getRoomCharge())
                            : '',
                      ],
                      <String>[
                        UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL),
                        "1",
                        "",
                        "",
                        "",
                        '${booking.adult! + booking.child!}',
                        "",
                        showPrice
                            ? showPrice
                                ? NumberUtil.numberFormat
                                    .format(booking.getRoomCharge())
                                : ''
                            : '',
                      ],
                      <String>[
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_DEPOSIT),
                        showPrice
                            ? NumberUtil.numberFormat.format(booking.deposit)
                            : '',
                      ],
                      <String>[
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_REMAIN),
                        showPrice
                            ? NumberUtil.numberFormat.format(
                                booking.getRoomCharge() - booking.deposit!)
                            : '',
                      ],
                    ]),
              ),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)}:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "- ${booking.breakfast! ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESBREAKFAST) : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOBREAKFAST)}",
                            style: NeutronTextStyle.pdfContent),
                        Text(
                            "- ${booking.lunch! ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESLUNCH) : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOLUNCH)}",
                            style: NeutronTextStyle.pdfContent),
                        Text(
                            "- ${booking.dinner! ? MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESDINNER) : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NODINNER)}",
                            style: NeutronTextStyle.pdfContent),
                        if (isShowNotes)
                          Text("- $notes", style: NeutronTextStyle.pdfContent),
                      ])),
              SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.HEADER_TRANSFER_NOTE),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Text(
                      "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKING_CODE)} - ${booking.sID}"),
                ]),
              ),

              SizedBox(height: 10),
              if (GeneralManager.hotel!.policy!.isNotEmpty && pngBytes != null)
                Image(MemoryImage(pngBytes)),
              SizedBox(height: 10),
              //signature
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_GUEST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_ACCOUNT_SIGNATURE),
                    textAlign: TextAlign.center)
              ]),
              //img policy
              Expanded(child: SizedBox()),
              footer
            ]));
    return doc;
  }

  static Future<Document> buildReservationFormGroupPDFDoc(
      Map<Booking?, int> listGroup,
      Group groups,
      bool showPrice,
      bool isShowNotes,
      String? notes,
      num total,
      Map<String, int> dataMeal,
      {Uint8List? pngBytes}) async {
    final doc = Document();
    num totalGust = 0;
    int totalRoom = 0;
    Map<String, Set<num>> setPrice = {};
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));

    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) => [
              _buildHeader(
                  UITitleUtil.getTitleByCode(UITitleCode.PDF_RESERVATION_FORM)),
              Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  height: 120,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //title
                        Row(children: [
                          Expanded(
                            child: Text(
                                "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKING_CODE)}:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                              child: Text(groups.sID!,
                                  style: NeutronTextStyle.pdfContent)),
                          Expanded(
                            flex: 2,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CREATE)}:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  SizedBox(
                                      width: 150,
                                      child: Text(
                                          DateUtil.dateToDayMonthYearString(
                                              groups.inDate),
                                          style: NeutronTextStyle.pdfContent)),
                                ]),
                          ),
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_GUEST_INFOS),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(groups.name!,
                                style: NeutronTextStyle.pdfContent),
                          ),
                          Expanded(flex: 2, child: SizedBox())
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_SOURCE)}:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: Text(
                                SourceManager()
                                    .getSourceNameByID(groups.sourceID!),
                                style: NeutronTextStyle.pdfContent),
                          ),
                          Expanded(flex: 2, child: SizedBox())
                        ]),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: Text(
                                '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE)}:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(groups.phone!,
                                style: NeutronTextStyle.pdfContent),
                          ),
                        ]),
                        SizedBox(height: 10),
                        Expanded(
                          flex: 2,
                          child: Text(
                              MessageUtil.getMessageByCode(
                                  MessageCodeUtil.CONTENT_THANKYOU,
                                  [GeneralManager.hotel!.name ?? ""]),
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        // content
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //customer
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(groups.name!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(groups.phone!,
                                            style: NeutronTextStyle.pdfContent),
                                        Text(groups.email!,
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                                //in + out date
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                groups.inDate),
                                            style: NeutronTextStyle.pdfContent),
                                        SizedBox(height: 8),
                                        Text(
                                            UITitleUtil.getTitleByCode(
                                                UITitleCode
                                                    .TABLEHEADER_DEPARTURE_DATE),
                                            style: NeutronTextStyle
                                                .pdfLightContent),
                                        Text(
                                            DateUtil.dateToDayMonthYearString(
                                                groups.outDate),
                                            style: NeutronTextStyle.pdfContent),
                                      ]),
                                ),
                              ]),
                        ),
                      ])),
              // body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Table.fromTextArray(
                  context: context,
                  border: TableBorder(
                      top: BorderSide(color: mainColor, width: 2),
                      bottom: BorderSide(color: mainColor, width: 2)),
                  columnWidths: {
                    0: const FlexColumnWidth(35),
                    1: const FlexColumnWidth(15),
                    2: const FlexColumnWidth(15),
                    3: const FlexColumnWidth(15),
                    4: const FlexColumnWidth(15),
                    5: const FlexColumnWidth(15),
                    6: const FlexColumnWidth(45),
                    7: const FlexColumnWidth(25)
                  },
                  cellAlignments: <int, Alignment>{
                    0: Alignment.center,
                    1: Alignment.centerLeft,
                    2: Alignment.centerLeft,
                    3: Alignment.centerLeft,
                    4: Alignment.centerLeft,
                    5: Alignment.centerLeft,
                    6: Alignment.center,
                    7: Alignment.centerLeft,
                  },
                  cellStyle: NeutronTextStyle.pdfSmallContent,
                  rowDecoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: PdfColor.fromHex('#d3d8dc'), width: 0.1)),
                  ),
                  cellHeight: 20,
                  headerStyle: TextStyle(
                      color: mainColor,
                      fontSize: 11,
                      fontWeight: FontWeight.normal),
                  headers: [
                    UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ROOMTYPE),
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_NUMBER),
                    UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_IN_DATE),
                    UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_OUT_DATE),
                    UITitleUtil.getTitleByCode(UITitleCode.TOOLTIP_LENGTH_STAY),
                    UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_GUEST_NUMBER),
                    UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
                    UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_TOTAL_FULL),
                  ],
                  data: <List<String>>[
                    ...listGroup.entries.map(
                      (e) {
                        String chainPrice = '';
                        totalRoom += e.value;
                        totalGust += (e.key!.adult! + e.key!.child!);
                        setPrice[e.key!.id!] = {};
                        for (var price in e.key!.price!) {
                          setPrice[e.key!.id]!.add(price);
                        }
                        for (var element in setPrice[e.key!.id]!) {
                          element == setPrice[e.key!.id]!.last
                              ? chainPrice += element.toString()
                              : chainPrice += '${element.toString()}, ';
                        }
                        return <String>[
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
                                      : e.key!.getRoomCharge() * e.value)
                              : '',
                        ];
                      },
                    ).toList(),
                    <String>[
                      UITitleUtil.getTitleByCode(UITitleCode.HEADER_TOTAL),
                      NumberUtil.numberFormat.format(totalRoom),
                      "",
                      "",
                      "",
                      NumberUtil.numberFormat.format(totalGust),
                      "",
                      showPrice ? NumberUtil.numberFormat.format(total) : '',
                    ],
                    if (groups.service! > 0)
                      <String>[
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        UITitleUtil.getTitleByCode(
                            UITitleCode.TABLEHEADER_SERVICE),
                        showPrice
                            ? NumberUtil.numberFormat.format(groups.service)
                            : '',
                        '',
                      ],
                    <String>[
                      "",
                      "",
                      "",
                      "",
                      "",
                      "",
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_DEPOSIT),
                      showPrice
                          ? NumberUtil.numberFormat.format(groups.deposit)
                          : '',
                      '',
                    ],
                    <String>[
                      "",
                      "",
                      "",
                      "",
                      "",
                      "",
                      UITitleUtil.getTitleByCode(
                          UITitleCode.TABLEHEADER_REMAIN),
                      showPrice
                          ? NumberUtil.numberFormat.format(groups.remaining)
                          : '',
                    ],
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${UITitleUtil.getTitleByCode(UITitleCode.HEADER_NOTES)}:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            "- ${dataMeal["breakfast"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESBREAKFAST)} - ${dataMeal["breakfast"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOBREAKFAST)}",
                            style: NeutronTextStyle.pdfContent),
                        Text(
                            "- ${dataMeal["lunch"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESLUNCH)} - ${dataMeal["lunch"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NOLUNCH)}",
                            style: NeutronTextStyle.pdfContent),
                        Text(
                            "- ${dataMeal["dinner"]! > 0 ? "${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_YESDINNER)} - ${dataMeal["dinner"]}" : MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_NODINNER)}",
                            style: NeutronTextStyle.pdfContent),
                        if (isShowNotes)
                          Text("- $notes", style: NeutronTextStyle.pdfContent),
                      ])),
              SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.HEADER_TRANSFER_NOTE),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Text(
                      "${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_BOOKING_CODE)} - ${groups.sID}"),
                ]),
              ),
              SizedBox(height: 10),
              if (GeneralManager.hotel!.policy!.isNotEmpty && pngBytes != null)
                Image(MemoryImage(pngBytes)),
              SizedBox(height: 10),
              //signature
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_GUEST_SIGNATURE),
                    textAlign: TextAlign.center),
                Paragraph(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    text: UITitleUtil.getTitleByCode(
                        UITitleCode.PDF_ACCOUNT_SIGNATURE),
                    textAlign: TextAlign.center)
              ]),
              //img policy
              Expanded(child: SizedBox()),
              footer
            ]));
    return doc;
  }

  static Future<Document> buildCheckOutGroupPDFDoc(
      Booking booking,
      num deposit,
      GroupController controller,
      bool showPrice,
      bool showService,
      bool showPayment,
      bool showRemaining,
      bool showDailyRate) async {
    print(
        "$showPrice - $showService -$showPayment - $showRemaining -  $showDailyRate");
    List<DateTime> listDate =
        DateUtil.getStaysDay(booking.inDate!, booking.outDate!);
    Map<String, num> dataPrice = {};
    if (controller.selectMonth ==
        UITitleUtil.getTitleByCode(UITitleCode.CUSTOM)) {
      dataPrice = booking.getRoomChargeByDateCostumExprot(
          inDate: controller.startDate, outDate: controller.endDate);
    }
    //chu y 3thang dung no
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        build: (Context context) {
          int lengthStaysMonth =
              booking.getMapDayByMonth()["stays_month"]!.length;
          Tax tax = ConfigurationManagement().tax;
          double serviceFee = tax.serviceFee!;
          double vat = tax.vat!;
          num totalRoom = controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? booking.totalRoomCharge!
              : booking.getRoomCharge();
          num totalChargeRoom = controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL)
              ? booking.getServiceCharge() +
                  (booking.totalRoomCharge ?? 0) -
                  booking.discount!
              : booking.getTotalCharge()!;

          num remain = totalChargeRoom +
              booking.transferred! -
              (controller.isDeposit ||
                      controller.selectMonth ==
                          UITitleUtil.getTitleByCode(UITitleCode.ALL)
                  ? deposit
                  : booking.deposit!) -
              booking.transferring!;

          num totalCharge = showPrice && showService
              ? totalChargeRoom + booking.transferred!
              : showPrice
                  ? totalRoom + booking.transferred! - booking.discount!
                  : totalChargeRoom - totalRoom + booking.transferred!;

          double totalBeforeVAT =
              totalCharge / (1 + vat + serviceFee + vat * serviceFee);

          double serviceFeeMoney =
              (totalBeforeVAT * serviceFee).roundToDouble();

          double vatMoney =
              ((totalBeforeVAT + serviceFeeMoney) * vat).roundToDouble();

          totalBeforeVAT =
              totalCharge - serviceFeeMoney - vatMoney; //to prevent difference

          int dayStart = 0;
          int monthStart = 0;
          int yearStart = 0;
          String selectedNew = "";
          if (controller.selectMonth !=
                  UITitleUtil.getTitleByCode(UITitleCode.ALL) &&
              controller.selectMonth !=
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
          return [
            _buildHeader(
                UITitleUtil.getTitleByCode(UITitleCode.PDF_CHECKOUT_FORM)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        height: 120,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //title
                              Row(children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_NAME),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.SIDEBAR_ROOM),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_ARRIVAL_DATE),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                                Container(
                                  width: 150,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_INVOICE_TOTAL),
                                      style: NeutronTextStyle.pdfLightContent),
                                ),
                              ]),
                              //content
                              Expanded(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      //customer
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(booking.name ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_PHONE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.phone ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_EMAIL),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.email ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //room + source + sid
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  RoomManager().getNameRoomById(
                                                      booking.room!),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SOURCE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sourceName ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 6),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SID),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(booking.sID ?? "",
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //in + out date
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                  DateUtil.dateToDayMonthYearHourMinuteString(
                                                      (booking.bookingType ==
                                                                  BookingType
                                                                      .monthly &&
                                                              BookingInOutByHour
                                                                      .monthly ==
                                                                  GeneralManager
                                                                      .hotel!
                                                                      .hourBookingMonthly)
                                                          ? DateUtil.to0h(
                                                              booking.inTime ??
                                                                  booking
                                                                      .inDate!)
                                                          : DateUtil.to14h(
                                                              booking.inTime ??
                                                                  booking
                                                                      .inDate!)),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_DEPARTURE_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  DateUtil.dateToDayMonthYearHourMinuteString(
                                                      (booking.bookingType ==
                                                                  BookingType
                                                                      .monthly &&
                                                              BookingInOutByHour
                                                                      .monthly ==
                                                                  GeneralManager
                                                                      .hotel!
                                                                      .hourBookingMonthly)
                                                          ? DateUtil.to24h(
                                                              booking.outTime ??
                                                                  booking
                                                                      .outDate!)
                                                          : (booking.outTime ??
                                                              booking
                                                                  .outDate!)),
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                              SizedBox(height: 8),
                                              Text(
                                                  UITitleUtil.getTitleByCode(
                                                      UITitleCode
                                                          .TABLEHEADER_SELECT_DATE),
                                                  style: NeutronTextStyle
                                                      .pdfLightContent),
                                              Text(
                                                  (booking.bookingType ==
                                                              BookingType
                                                                  .monthly &&
                                                          controller
                                                                  .selectMonth !=
                                                              UITitleUtil
                                                                  .getTitleByCode(
                                                                      UITitleCode
                                                                          .ALL) &&
                                                          controller
                                                                  .selectMonth ==
                                                              UITitleUtil
                                                                  .getTitleByCode(
                                                                      UITitleCode
                                                                          .CUSTOM))
                                                      ? "${DateUtil.dateToDayMonthYearString(controller.startDate)} - ${DateUtil.dateToDayMonthYearString(controller.endDate)}"
                                                      : controller.selectMonth,
                                                  style: NeutronTextStyle
                                                      .pdfContent),
                                            ]),
                                      ),
                                      //total
                                      Container(
                                          width: 150,
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              NumberUtil.numberFormat
                                                  .format(totalCharge),
                                              style: TextStyle(
                                                  color: mainColor,
                                                  fontSize: 20))),
                                    ]),
                              ),
                            ])),
                    Table.fromTextArray(
                        context: context,
                        border: TableBorder(
                            top: BorderSide(color: mainColor, width: 2)),
                        cellAlignments: <int, Alignment>{
                          0: Alignment.centerLeft,
                          1: Alignment.center,
                          2: Alignment.centerRight
                        },
                        cellStyle: NeutronTextStyle.pdfContent,
                        rowDecoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: PdfColor.fromHex('#d3d8dc'),
                                  width: 0.1)),
                        ),
                        cellHeight: 30,
                        headerStyle: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                        headers: [
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_CURRENCY),
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_PRICE),
                        ],
                        data: <List<String>>[
                          <String>[
                            UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE),
                            'VND',
                            showPrice
                                ? NumberUtil.numberFormat.format(totalRoom)
                                : '0'
                          ],
                          if (showService) ...[
                            if (booking.extraHour!.total! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_EXTRA_HOUR),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.extraHour!.total)
                              ],
                            if (booking.extraGuest! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TOOLTIP_EXTRA_GUEST),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.extraGuest)
                              ],
                            if (booking.minibar! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_MINIBAR_SERVICE),
                                'VND',
                                NumberUtil.numberFormat.format(booking.minibar)
                              ],
                            if (booking.insideRestaurant! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_INSIDE_RESTAURANT),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.insideRestaurant)
                              ],
                            if (booking.outsideRestaurant! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_INDEPENDEMT_RESTAURANT),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.outsideRestaurant)
                              ],
                            if (booking.laundry > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_LAUNDRY_SERVICE),
                                'VND',
                                NumberUtil.numberFormat.format(booking.laundry)
                              ],
                            if (booking.bikeRental! > 0)
                              <String>[
                                UITitleUtil.getTitleByCode(UITitleCode
                                    .TABLEHEADER_BIKE_RENTAL_SERVICE),
                                'VND',
                                NumberUtil.numberFormat
                                    .format(booking.bikeRental)
                              ],
                            // if (booking.electricity! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_ELECTRICITY_WATER),
                            //     'VND',
                            //     NumberUtil.numberFormat
                            //         .format(booking.electricity ?? 0)
                            //   ],
                            // if (booking.water! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_WATER),
                            //     'VND',
                            //     NumberUtil.numberFormat
                            //         .format(booking.water ?? 0)
                            //   ],
                            // if (booking.other! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_OTHER),
                            //     'VND',
                            //     NumberUtil.numberFormat.format(booking.other)
                            //   ],
                            // if (booking.other! > 0)
                            //   <String>[
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_DETAIL),
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_TYPE),
                            //     UITitleUtil.getTitleByCode(
                            //         UITitleCode.TABLEHEADER_TOTAL)
                            //   ],
                            if (booking.other! > 0)
                              ...controller.servicesOther
                                  .where(
                                      (element) => element.room == booking.room)
                                  .map((e) => <String>[
                                        // DateUtil.dateToDayMonthYearString(
                                        //     e.created!.toDate()),
                                        OtherManager()
                                            .getServiceNameByID(e.type!),
                                        'VND',
                                        NumberUtil.numberFormat.format(e.total)
                                      ])
                                  .toList()
                          ],
                          if (booking.transferred != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.PDF_TRANSFERRED),
                              'VND',
                              NumberUtil.numberFormat
                                  .format(booking.transferred)
                            ],
                          if (booking.discount != 0)
                            <String>[
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_DISCOUNT),
                              'VND',
                              '-${NumberUtil.numberFormat.format(booking.discount)}'
                            ],
                        ]),
                    //Booking  -electricityWater
                    if (booking.electricity != 0 || booking.water != 0) ...[
                      SizedBox(height: PADDING_BELOW_TABLE),
                      Container(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ELECTRICITY_WATER),
                                  style: NeutronTextStyle.pdfTableHeader),
                            ),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_CREATED_TIME),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_INITIAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_FINAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_PRICE),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_TOTAL),
                                    style: NeutronTextStyle.pdfTableHeader,
                                    textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                      Divider(height: 8, thickness: 0.5, color: mainColor),
                    ],
                    //ĐIỆN
                    if (booking.electricity! > 0) ...[
                      ...controller.servicesElectricity
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: controller.servicesElectricity
                                                    .indexOf(e) ==
                                                0
                                            ? Text(
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode
                                                        .TABLEHEADER_ELECTRICITY),
                                                textAlign: TextAlign.center)
                                            : SizedBox()),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthString(e.initialTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthString(e.finalTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            e.priceElectricity.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                    //Nươc
                    if (booking.water! > 0) ...[
                      ...controller.servicesWater
                          .map((e) => Container(
                                height: 35,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('cccccc'),
                                            width: 0.2))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: controller.servicesWater
                                                    .indexOf(e) ==
                                                0
                                            ? Text(
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode
                                                        .TABLEHEADER_WATER),
                                                textAlign: TextAlign.center)
                                            : SizedBox()),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                            DateUtil.dateToDayMonthYearString(
                                                e.createdTime),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.initialNumber.toString()} - ${DateUtil.dateToDayMonthString(e.initialTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            "${e.finalNumber.toString()} - ${DateUtil.dateToDayMonthString(e.finalTime!)}",
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.priceWater.toString(),
                                            textAlign: TextAlign.center)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.total.toString(),
                                            textAlign: TextAlign.center)),
                                  ],
                                ),
                              ))
                          .toList()
                    ],
                    SizedBox(height: PADDING_BELOW_TABLE),
                    if (showDailyRate) ...[
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                                  style: TextStyle(
                                      color: mainColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ROOM_CHARGE_DETAIL))),
                          Expanded(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  UITitleUtil.getTitleByCode(
                                      booking.bookingType == BookingType.monthly
                                          ? UITitleCode.TABLEHEADER_MONTH
                                          : UITitleCode.TABLEHEADER_DATE))),
                          Expanded(
                              child: Text(
                                  textAlign: TextAlign.end,
                                  UITitleUtil.getTitleByCode(UITitleCode
                                      .TABLEHEADER_ROOM_CHARGE_FULL)))
                        ],
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: mainColor, width: 0.2))),
                      ),
                      if (booking.bookingType == BookingType.monthly) ...[
                        if (controller.selectMonth ==
                            UITitleUtil.getTitleByCode(UITitleCode.ALL)) ...[
                          for (var i = 0;
                              i <
                                  booking
                                      .getMapDayByMonth()["stays_month"]!
                                      .length;
                              i++)
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('#d3d8dc'),
                                            width: 0.1))),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("")),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            booking
                                                .getMapDayByMonth()[
                                                    "stays_month"]!
                                                .toList()[i])),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.end,
                                            showPrice
                                                ? NumberUtil.numberFormat
                                                    .format(booking.price![i])
                                                : '0'))
                                  ],
                                )),
                          for (var i = booking
                                  .getMapDayByMonth()["stays_month"]!
                                  .length;
                              i <
                                  (booking
                                          .getMapDayByMonth()["stays_day"]!
                                          .length +
                                      booking
                                          .getMapDayByMonth()["stays_month"]!
                                          .length);
                              i++)
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('#d3d8dc'),
                                            width: 0.1))),
                                child: Row(
                                  children: [
                                    Expanded(child: Text("")),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            booking
                                                    .getMapDayByMonth()[
                                                        "stays_day"]!
                                                    .toList()[
                                                i -
                                                    booking
                                                        .getMapDayByMonth()[
                                                            "stays_month"]!
                                                        .length])),
                                    Expanded(
                                        child: Text(
                                            textAlign: TextAlign.end,
                                            showPrice
                                                ? NumberUtil.numberFormat
                                                    .format(booking.price![i])
                                                : '0'))
                                  ],
                                )),
                        ],
                        if (controller.selectMonth !=
                            UITitleUtil.getTitleByCode(UITitleCode.ALL)) ...[
                          if (controller
                                  .getDayByMonth()[booking.id]!
                                  .toList()
                                  .indexOf(controller.selectMonth) ==
                              (controller
                                      .getDayByMonth()[booking.id]!
                                      .toList()
                                      .length -
                                  1)) ...[
                            if (controller
                                .getDayByMonth()[booking.id]!
                                .toList()
                                .contains(selectedNew))
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.center,
                                              selectedNew)),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? booking.price![controller
                                                          .getDayByMonth()[
                                                              booking.id]!
                                                          .toList()
                                                          .indexOf(selectedNew)]
                                                      .toString()
                                                  : '0'))
                                    ],
                                  )),
                            if (!controller
                                .getDayByMonth()[booking.id]!
                                .toList()
                                .contains(selectedNew))
                              for (var i = lengthStaysMonth -
                                      (lengthStaysMonth <= 1 ? 1 : 2);
                                  i < lengthStaysMonth;
                                  i++)
                                Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color:
                                                    PdfColor.fromHex('#d3d8dc'),
                                                width: 0.1))),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("")),
                                        Expanded(
                                            child: Text(
                                                textAlign: TextAlign.center,
                                                booking
                                                    .getMapDayByMonth()[
                                                        "stays_month"]!
                                                    .toList()[i])),
                                        Expanded(
                                            child: Text(
                                                textAlign: TextAlign.end,
                                                showPrice
                                                    ? NumberUtil.numberFormat
                                                        .format(
                                                            booking.price![i])
                                                    : '0'))
                                      ],
                                    )),
                            for (var i = booking
                                    .getMapDayByMonth()["stays_month"]!
                                    .length;
                                i <
                                    (booking
                                            .getMapDayByMonth()["stays_day"]!
                                            .length +
                                        booking
                                            .getMapDayByMonth()["stays_month"]!
                                            .length);
                                i++)
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.center,
                                              booking
                                                      .getMapDayByMonth()[
                                                          "stays_day"]!
                                                      .toList()[
                                                  i -
                                                      booking
                                                          .getMapDayByMonth()[
                                                              "stays_month"]!
                                                          .length])),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? NumberUtil.numberFormat
                                                      .format(booking.price![i])
                                                  : '0'))
                                    ],
                                  )),
                          ],
                          if (controller
                                  .getDayByMonth()[booking.id]!
                                  .toList()
                                  .indexOf(controller.selectMonth) !=
                              (controller
                                      .getDayByMonth()[booking.id]!
                                      .toList()
                                      .length -
                                  1)) ...[
                            if (controller.selectMonth !=
                                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  PdfColor.fromHex('#d3d8dc'),
                                              width: 0.1))),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text("")),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.center,
                                              controller.selectMonth)),
                                      Expanded(
                                          child: Text(
                                              textAlign: TextAlign.end,
                                              showPrice
                                                  ? booking.price![controller
                                                          .getDayByMonth()[
                                                              booking.id]!
                                                          .toList()
                                                          .indexOf(controller
                                                              .selectMonth)]
                                                      .toString()
                                                  : '0'))
                                    ],
                                  )),
                            if (controller.selectMonth ==
                                UITitleUtil.getTitleByCode(UITitleCode.CUSTOM))
                              ...dataPrice.keys
                                  .map((key) => Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: PdfColor.fromHex(
                                                      '#d3d8dc'),
                                                  width: 0.1))),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text("")),
                                          Expanded(
                                              child: Text(
                                                  textAlign: TextAlign.center,
                                                  key)),
                                          Expanded(
                                              child: Text(
                                                  textAlign: TextAlign.end,
                                                  showPrice
                                                      ? dataPrice[key]
                                                          .toString()
                                                      : '0'))
                                        ],
                                      )))
                                  .toList(),
                          ]
                        ]
                      ],
                      if (booking.bookingType != BookingType.monthly)
                        for (var i = 0; i < listDate.length; i++)
                          Container(
                              padding: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: PdfColor.fromHex('#d3d8dc'),
                                          width: 0.1))),
                              child: Row(
                                children: [
                                  Expanded(child: Text("")),
                                  Expanded(
                                      child: Text(
                                          textAlign: TextAlign.center,
                                          DateUtil.dateToStringDDMMYYY(
                                              listDate[i]))),
                                  Expanded(
                                      child: Text(
                                          textAlign: TextAlign.end,
                                          showPrice
                                              ? NumberUtil.numberFormat
                                                  .format(booking.price![i])
                                              : '0'))
                                ],
                              )),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(color: mainColor, width: 0.2))),
                      ),
                    ],
                    // total before service-fee and vat
                    Row(children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                            UITitleUtil.getTitleByCode(UITitleCode
                                .TABLEHEADER_TOTAL_BEFORE_SERVICEFEE_AND_VAT),
                            style: NeutronTextStyle.pdfContentMainColor),
                      )),
                      Container(
                          alignment: Alignment.centerRight,
                          width: 150,
                          child: Text(
                              NumberUtil.numberFormat.format(totalBeforeVAT),
                              style: NeutronTextStyle.pdfContent)),
                    ]),
                    SizedBox(height: 8),
                    // service fee
                    serviceFeeMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_SERVICE_FEE),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat
                                        .format(serviceFeeMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    SizedBox(height: 8),
                    //vat
                    vatMoney == 0
                        ? SizedBox()
                        : Row(children: [
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  UITitleUtil.getTitleByCode(
                                      UITitleCode.TABLEHEADER_VAT),
                                  style: NeutronTextStyle.pdfContentMainColor),
                            )),
                            Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat.format(vatMoney),
                                    style: NeutronTextStyle.pdfContent)),
                          ]),
                    //subtotal
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_SUBTOTAL),
                              style: NeutronTextStyle.pdfContentMainColor),
                        )),
                        Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(left: 50),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: mainColor, width: 0.1))),
                          width: 100,
                          child: Text(
                              NumberUtil.numberFormat.format(totalCharge),
                              style: NeutronTextStyle.pdfContent),
                        )
                      ]),
                    ),
                    if (showPayment)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          Expanded(
                              child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('Thanh toán (Deposit)',
                                style: NeutronTextStyle.pdfContentMainColor),
                          )),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(left: 50),
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: mainColor, width: 0.1))),
                            width: 100,
                            child: Text(
                                NumberUtil.numberFormat.format(
                                    controller.isDeposit ||
                                            controller.selectMonth ==
                                                UITitleUtil.getTitleByCode(
                                                    UITitleCode.ALL)
                                        ? deposit
                                        : booking.deposit!),
                                style: NeutronTextStyle.pdfContent),
                          )
                        ]),
                      ),
                    SizedBox(height: 8),
                    showRemaining
                        //remaining
                        ? Container(
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: mainColor, width: 0.1))),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    UITitleUtil.getTitleByCode(
                                        UITitleCode.TABLEHEADER_REMAIN),
                                    style:
                                        NeutronTextStyle.pdfContentMainColor),
                              )),
                              Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                child: Text(
                                    NumberUtil.numberFormat.format(remain),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: PdfColor.fromHex('#424242'))),
                              )
                            ]),
                          )
                        : SizedBox(height: 20),
                  ]),
            ),
            //signature
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_GUEST_SIGNATURE),
                  textAlign: TextAlign.center),
              Paragraph(
                  style: NeutronTextStyle.pdfContent,
                  text: UITitleUtil.getTitleByCode(
                      UITitleCode.PDF_RECEPTIONIST_SIGNATURE),
                  textAlign: TextAlign.center)
            ]),
            Expanded(child: Container()),
            footer
          ];
        })); //
    return doc;
  }

  static Future<Document> buildPaymentManagementPDFDoc(
      List<Deposit> deposits, Map<String, dynamic> dataPayment) async {
    //chu y 3thang dung no
    final doc = Document();
    Font font = Font.ttf(await rootBundle.load("assets/fonts/arial.ttf"));
    doc.addPage(MultiPage(
        theme: ThemeData.withFont(
          base: font,
          bold: font,
          italic: font,
          boldItalic: font,
        ),
        pageFormat: const PdfPageFormat(1050, 1000),
        margin: const EdgeInsets.all(0),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        maxPages: 40,
        build: (Context context) {
          num totalMoney = deposits
              .where((element) => element.method != "transfer")
              .fold(
                  0,
                  (previousValue, element) =>
                      (element.amount ?? 0) + previousValue);
          num totalPaymentMethod = dataPayment.entries
              .where((element) => element.key != "de" && element.value != 0)
              .fold(
                  0, (previousValue, element) => previousValue + element.value);
          return [
            _buildHeader(UITitleUtil.getTitleByCode(
                UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_TIME))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ID))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_NAME))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_DESCRIPTION_FULL))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ROOM))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_IN_DATE))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_OUT_DATE))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STATUS))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_PAYMENT_METHOD))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_SOURCE))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_AMOUNT))),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                "Ngày thanh toán thực tế")),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                "Số tiền thực tế")),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center, "Số tham chiếu")),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                "Ngày tham chiếu")),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_NOTES))),
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: mainColor, width: 0.2))),
                    ),
                    for (var deposit in deposits
                        .where((element) => element.method != "transfer"))
                      Container(
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: PdfColor.fromHex('#d3d8dc'),
                                      width: 0.1))),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      DateUtil.dateToDayMonthHourMinuteString(
                                          deposit.created!.toDate()))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.sID ?? "")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.name ?? "")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.desc ?? "")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      RoomManager()
                                          .getNameRoomById(deposit.room!))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      DateUtil.dateToDayMonthString(
                                          deposit.inDate!))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      DateUtil.dateToDayMonthString(
                                          deposit.outDate!))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.status ?? "")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      PaymentMethodManager()
                                          .getPaymentMethodNameById(
                                              deposit.method!))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      SourceManager().getSourceNameByID(
                                          deposit.sourceID!))),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.amount.toString())),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.confirmDate != null
                                          ? DateUtil.dateToDayMonthYearString(
                                              deposit.confirmDate!)
                                          : "#")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.actualAmount.toString())),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.referenceNumber.toString())),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.referencDate != null
                                          ? DateUtil.dateToDayMonthYearString(
                                              deposit.referencDate!)
                                          : "#")),
                              Expanded(
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      deposit.note ?? "")),
                            ],
                          )),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(
                            child:
                                Text(textAlign: TextAlign.center, "Tổng cộng")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(
                            child: Text(
                                textAlign: TextAlign.center,
                                totalMoney.toString())),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                        Expanded(child: Text(textAlign: TextAlign.center, "")),
                      ],
                    ),
                    SizedBox(height: 40),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              textAlign: TextAlign.center,
                              UITitleUtil.getTitleByCode(UITitleCode
                                  .TABLEHEADER_PAYMENT_METHOD_REPORT_DETAIL),
                              style: NeutronTextStyle.pdfContentMainColor),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_METHOD))),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      UITitleUtil.getTitleByCode(UITitleCode
                                          .TABLEHEADER_AMOUNT_MONEY))),
                            ],
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: mainColor, width: 0.2))),
                          ),
                          for (var data in dataPayment.entries.where(
                              (element) =>
                                  element.key != "de" && element.value != 0))
                            Container(
                                padding: const EdgeInsets.only(top: 8),
                                width: 200,
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: PdfColor.fromHex('#d3d8dc'),
                                            width: 0.1))),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 100,
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            PaymentMethodManager()
                                                .getPaymentMethodNameById(
                                                    data.key))),
                                    SizedBox(
                                        width: 100,
                                        child: Text(
                                            textAlign: TextAlign.center,
                                            data.value.toString())),
                                  ],
                                )),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_TOTAL_FULL))),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      totalPaymentMethod.toString())),
                            ],
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center, "Ghi nợ")),
                              SizedBox(
                                  width: 100,
                                  child: Text(textAlign: TextAlign.center, "")),
                            ],
                          ),
                          Container(
                            width: 200,
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: mainColor, width: 0.2))),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      PaymentMethodManager()
                                          .getPaymentMethodNameById("de"))),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                      textAlign: TextAlign.center,
                                      dataPayment.entries
                                          .where(
                                              (element) => element.key == "de")
                                          .first
                                          .value
                                          .toString())),
                            ],
                          ),
                        ])
                  ]),
            ),
            Expanded(child: Container()),
            footer
          ];
        })); //
    return doc;
  }

  static Header _buildHeader(String nameOfForm) {
    return Header(
      padding: const EdgeInsets.only(bottom: 0, top: 8, left: 0, right: 0),
      margin: const EdgeInsets.all(0),
      level: 0,
      child: Container(
          height: 110,
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(nameOfForm,
                    style: TextStyle(
                        fontSize: 20, color: PdfColor.fromHex('#000000'))),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(GeneralManager.hotel!.name!,
                        style: TextStyle(
                            fontSize: 14, color: PdfColor.fromHex('#000000'))),
                    SizedBox(height: 8),
                    Text(GeneralManager.hotel!.street!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: PdfColor.fromHex('#000000'))),
                    SizedBox(height: 2),
                    Text(
                        '${GeneralManager.hotel!.city} - ${GeneralManager.hotel!.country}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: PdfColor.fromHex('#000000'))),
                    SizedBox(height: 8),
                    Text(
                        '${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_EMAIL)}: ${GeneralManager.hotel!.email} - ${UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_PHONE)}: ${GeneralManager.hotel!.phone}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: PdfColor.fromHex('#000000'))),
                  ]),
            ),
            SizedBox(width: 25),
            // Container(
            //   height: 90,
            //   width: 90,
            //   child: Image(
            //     MemoryImage(GeneralManager.hotelImage),
            //     fit: BoxFit.cover,
            //   ),
            // )
          ])),
    );
  }

  static Footer get footer => Footer(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),
      trailing: Container(
        height: 60,
        width: 60,
        alignment: Alignment.bottomRight,
        child:
            Image(MemoryImage(GeneralManager.onepmsLogo!), fit: BoxFit.cover),
      ));
}
