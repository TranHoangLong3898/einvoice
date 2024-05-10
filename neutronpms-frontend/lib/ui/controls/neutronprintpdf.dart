import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutronwaiting.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrintPDFToDevice {
  PrintPDFToDevice._();

  static printPdfAccordingToDevice(
      BuildContext context, dynamic filePDF, String nameFile) async {
    showDialog(
        context: context,
        builder: (context) => WillPopScope(
            onWillPop: () => Future.value(false),
            child: const NeutronWaiting()));
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      await Future.delayed(const Duration(seconds: 2), () async {
        await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
          return (await filePDF).save();
        }).whenComplete(() {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      });
    } else {
      return (await filePDF).save().then((value) {
        Printing.sharePdf(
          filename: "$nameFile.pdf",
          bytes: value,
        ).whenComplete(() {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      });
    }
  }
}
