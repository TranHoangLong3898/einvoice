import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/versionmanager.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:universal_html/html.dart' as html;
import '../../util/designmanagement.dart';
import 'neutrontexttilte.dart';

class NeutronUpdateVersion extends StatelessWidget {
  const NeutronUpdateVersion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManagement.mainBackground,
      title: NeutronTextTitle(
          color: ColorManagement.yellowColor,
          message: UITitleUtil.getTitleByCode(UITitleCode.NEW_VERSON),
          isPadding: false),
      content: NeutronTextContent(
          textOverflow: TextOverflow.clip,
          message:
              '${UITitleUtil.getTitleByCode(UITitleCode.PLEASE_RESTART_TO_UPDATE)} ${VersionManager.versionInCloud}',
          color: ColorManagement.mainColorText),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            if (kIsWeb) {
              Navigator.popUntil(context, ModalRoute.withName('landing'));
              Future.delayed(const Duration(milliseconds: 300), () {
                html.window.location.reload();
              });
            }
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
            shadowColor:
                MaterialStateProperty.all(ColorManagement.lightMainBackground),
            backgroundColor:
                MaterialStateProperty.all(ColorManagement.lightMainBackground),
          ),
          child: Text(UITitleUtil.getTitleByCode(UITitleCode.UPDATE)),
        ),
      ],
    );
  }
}
