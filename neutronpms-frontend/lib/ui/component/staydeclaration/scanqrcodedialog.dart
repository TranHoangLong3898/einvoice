import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRCode extends StatelessWidget {
  final MobileScannerController scannerController = MobileScannerController();

  ScanQRCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        height: kMobileWidth,
        child: MobileScanner(
          // allowDuplicates: false,
          controller: scannerController,
          onDetect: (BarcodeCapture? barcodes) {
            if (barcodes != null) {
              Navigator.pop(context, barcodes);
            }
          },
        ),
      ),
    );
  }
}
