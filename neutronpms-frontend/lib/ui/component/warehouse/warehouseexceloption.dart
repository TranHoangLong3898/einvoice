import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/ui/component/warehouse/transfer/transferdialog.dart';
import 'package:ihotel/util/warehouseutil.dart';
import '../../../manager/roles.dart';
import '../../../manager/usermanager.dart';
import '../../../manager/warehousenotesmanager.dart';
import '../../../util/designmanagement.dart';
import '../../../util/excelulti.dart';
import '../../../util/materialutil.dart';
import '../../../util/messageulti.dart';
import '../../../util/uimultilanguageutil.dart';
import '../management/accounting/accountingdialog.dart';
import 'export/exportdialog.dart';
import 'import/importdialog.dart';
import 'liquidation/liquidationdialog.dart';
import 'lost/lostdialog.dart';

class ExcelOptionDialog extends StatelessWidget {
  const ExcelOptionDialog({
    Key? key,
    this.controller,
    this.noteType,
  }) : super(key: key);
  final WarehouseNotesManager? controller;
  final String? noteType;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManagement.mainBackground,
      title: Center(
          child: Text(UITitleUtil.getTitleByCode(UITitleCode.TITLE_EXCEL))),
      content: SizedBox(
          height: 170,
          child: Padding(
            padding:
                const EdgeInsets.all(SizeManagement.cardInsideVerticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          ColorManagement.redColor)),
                              onPressed: () {
                                Navigator.pop(context);

                                ExcelUlti.dowloadWarehouseNoteFile(noteType!);
                              },
                              child: const Icon(
                                Icons.download,
                                size: 40,
                              ))),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_DOWNLOAD_TEMPLATE_FILE),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          ColorManagement.redColor)),
                              onPressed: () async {
                                FilePickerResult? pickedFile =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['xlsx'],
                                  allowMultiple: false,
                                );

                                if (pickedFile != null) {
                                  Map<String, dynamic>? readExcelFileResult =
                                      await controller!
                                          .readExcelFile(noteType!, pickedFile);

                                  if (readExcelFileResult == null) {
                                    // ignore: use_build_context_synchronously
                                    MaterialUtil.showResult(
                                        context,
                                        MessageUtil.getMessageByCode(
                                            MessageCodeUtil
                                                .INVALID_DATA_WRONG_FILE));
                                  }
                                  if ((readExcelFileResult!['errors']
                                          as List<int>)
                                      .isNotEmpty) {
                                    // ignore: use_build_context_synchronously
                                    bool isDownloadErrorFile = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ConfirmDownloadErrorFileDialog(),
                                    );
                                    if (isDownloadErrorFile) {
                                      Excel excel =
                                          readExcelFileResult['excel'];
                                      excel.save(
                                          fileName:
                                              "OneRes_${noteType}_excel_fixed_file.xlsx");
                                    }
                                  } else {
                                    controller!.changeShowOption(false);
                                    switch (noteType) {
                                      case WarehouseNotesType.import:
                                        final Map<String, dynamic>? result =
                                            // ignore: use_build_context_synchronously
                                            await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ImportDialog(
                                                      warehouseNotesManager:
                                                          controller,
                                                      isImportExcelFile: true,
                                                      import:
                                                          readExcelFileResult[
                                                              'noteData'],
                                                    ));

                                        if (result == null) {
                                          return;
                                        }

                                        if (UserManager.role!
                                                .contains(Roles.accountant) ||
                                            UserManager
                                                .canCRUDWarehouseNote()) {
                                          final bool? confirmResult =
                                              // ignore: use_build_context_synchronously
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_CREATE_COST_MANAGEMENT_AFTER_IMPORT));

                                          if (confirmResult == null ||
                                              !confirmResult) {
                                            return;
                                          }
                                          // ignore: use_build_context_synchronously
                                          await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AddAccountingDialog(
                                                    inputData: result,
                                                  ));
                                        }
                                        break;
                                      case WarehouseNotesType.export:
                                        // ignore: use_build_context_synchronously
                                        await showDialog(
                                            context: context,
                                            builder: (context) => ExportDialog(
                                                  warehouseNotesManager:
                                                      controller,
                                                  export: readExcelFileResult[
                                                      'noteData'],
                                                  isImportExcelFile: true,
                                                ));
                                        break;
                                      case WarehouseNotesType.liquidation:
                                        // ignore: use_build_context_synchronously
                                        await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                LiquidationDialog(
                                                  warehouseNotesManager:
                                                      controller,
                                                  liquidation:
                                                      readExcelFileResult[
                                                          'noteData'],
                                                  isImportExcelFile: true,
                                                ));
                                        break;
                                      case WarehouseNotesType.lost:
                                        // ignore: use_build_context_synchronously
                                        await showDialog(
                                            context: context,
                                            builder: (context) => LostDialog(
                                                  warehouseNotesManager:
                                                      controller,
                                                  lost: readExcelFileResult[
                                                      'noteData'],
                                                  isImportExcelFile: true,
                                                ));
                                        break;
                                      case WarehouseNotesType.transfer:
                                        // ignore: use_build_context_synchronously
                                        await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                TransferDialog(
                                                  warehouseNotesManager:
                                                      controller,
                                                  transfer: readExcelFileResult[
                                                      'noteData'],
                                                  isImportExcelFile: true,
                                                ));
                                        break;
                                    }
                                  }
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                }
                              },
                              child: const Icon(
                                Icons.upload,
                                size: 40,
                              ))),
                      SizedBox(
                        width: 100,
                        height: 40,
                        child: Text(
                          UITitleUtil.getTitleByCode(
                              UITitleCode.TOOLTIP_UPLOAD_EXCEL_FILE),
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class ConfirmDownloadErrorFileDialog extends StatelessWidget {
  const ConfirmDownloadErrorFileDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManagement.mainBackground,
      title: Center(
          child:
              Text(MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_DATA))),
      content: SizedBox(
        height: 80,
        child: Column(children: [
          Text(
            MessageUtil.getMessageByCode(
                MessageCodeUtil.INVALID_DATA_DOWNLOAD_TO_FIX),
            style: const TextStyle(color: Colors.white),
          ),
          Padding(
            padding:
                const EdgeInsets.all(SizeManagement.cardInsideVerticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 50,
                    height: 30,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 40, 131, 43))),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Icon(
                          Icons.download,
                          size: 20,
                        ))),
                // SizedBox(
                //     width: 100,
                //     height: 100,
                //     child: ElevatedButton(
                //         style: ButtonStyle(
                //             backgroundColor: MaterialStateProperty.all<Color>(
                //                 const Color.fromARGB(255, 223, 46, 34))),
                //         onPressed: () => Navigator.pop(context, false),
                //         child: const Icon(
                //           Icons.cancel,
                //           size: 40,
                //         ))),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
