import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../util/designmanagement.dart';

class NeutronAlertDialog extends StatelessWidget {
  final List<String> messages;
  const NeutronAlertDialog({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManagement.mainBackground,
      title: NeutronTextTitle(
        color: ColorManagement.redColor,
        message:
            UITitleUtil.getTitleByCode(UITitleCode.MATERIALUTIL_TITLE_ALERT),
        isPadding: false,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: messages
              .map((message) => Text(
                    message,
                    style:
                        const TextStyle(color: ColorManagement.mainColorText),
                  ))
              .toList(),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          // color: ColorManagement.greenPastel,
          child: Text(UITitleUtil.getTitleByCode(
              UITitleCode.MATERIALUTIL_BUTTON_CLOSE)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class NeutronConfirmDialog extends StatelessWidget {
  final List<String> messages;
  final String? nolButtonText;
  final String? yesButtonText;
  const NeutronConfirmDialog({
    Key? key,
    required this.messages,
    this.nolButtonText,
    this.yesButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManagement.mainBackground,
      title: NeutronTextTitle(
        color: ColorManagement.yellowColor,
        message:
            UITitleUtil.getTitleByCode(UITitleCode.MATERIALUTIL_TITLE_CONFIRM),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: messages
              .map((message) => Text(
                    message,
                    style:
                        const TextStyle(color: ColorManagement.mainColorText),
                  ))
              .toList(),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    ColorManagement.positiveText)),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: yesButtonText != null
                ? Text(yesButtonText!)
                : const Icon(Icons.check)),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    ColorManagement.positiveText)),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: nolButtonText != null
                ? Text(nolButtonText!)
                : const Icon(Icons.cancel))
      ],
    );
  }
}

class NeutronSimpleDialog extends StatelessWidget {
  final List<String> messages;
  final String firstString, secondString;
  final dynamic firstResult, secondResult;

  const NeutronSimpleDialog({
    Key? key,
    required this.messages,
    required this.firstString,
    required this.secondString,
    @required this.firstResult,
    @required this.secondResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: ColorManagement.mainBackground,
      elevation: 10,
      title: NeutronTextTitle(
          fontSize: 16,
          color: ColorManagement.yellowColor,
          message: UITitleUtil.getTitleByCode(
              UITitleCode.MATERIALUTIL_TITLE_CONFIRM),
          isPadding: false),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, firstResult);
          },
          child: ListTile(
            minVerticalPadding: 0,
            horizontalTitleGap: 0,
            title: NeutronTextContent(message: firstString),
            leading: const Icon(Icons.download_outlined,
                size: 14, color: ColorManagement.trailingIconColor),
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, secondResult);
          },
          child: ListTile(
            horizontalTitleGap: 0,
            title: NeutronTextContent(message: secondString),
            leading: const Icon(Icons.download_outlined,
                size: 14, color: ColorManagement.trailingIconColor),
          ),
        ),
      ],
    );
  }
}
