import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../ui/controls/neutronwaiting.dart';

class FileHandler {
  static Future<PlatformFile?> pickSingleImage(BuildContext context) async {
    showDialog(context: context, builder: (context) => const NeutronWaiting());
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowCompression: true,
        withData: true,
        lockParentWindow: true);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    return pickedFile?.files.single;
  }

  // static Future<String> saveFile(List<Object> bytes, String fileName) async {
  //   if (kIsWeb) {
  //     js.context.callMethod("saveAs", <Object>[
  //       html.Blob(<Object>[bytes]),
  //       fileName
  //     ]);
  //     return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  //   } else {
  //     return saveFileInAndroid(bytes, fileName);
  //   }
  // }

  // static Future<String> saveFileInAndroid(
  //     List<Object> bytes, String fileName) async {
  //   if (!(await _requestPermission(Permission.storage))) {
  //     return MessageUtil.getMessageByCode(
  //         MessageCodeUtil.TEXTALERT_NO_PERMISSION);
  //   }
  //   try {
  //     Directory directory = await getExternalStorageDirectory();
  //     String newPath = "";
  //     List<String> paths = directory.path.split("/");
  //     for (int x = 1; x < paths.length; x++) {
  //       String folder = paths[x];
  //       if (folder != "Android") {
  //         newPath += "/$folder";
  //       } else {
  //         break;
  //       }
  //     }
  //     newPath = "$newPath/Pictures/OnePMS";
  //     directory = Directory(newPath);
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //     File saveFile = File("${directory.path}/$fileName");
  //     await saveFile.writeAsBytes(bytes);
  //     return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  //   } catch (e) {
  //     print(e.toString());
  //     return e.toString();
  //   }
  // }

  // static Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   }
  //   PermissionStatus result = await permission.request();
  //   return result == PermissionStatus.granted;
  // }
}
