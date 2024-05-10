import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/controller/adminmanager/geturlpaymentvnpay.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShowAlertCheckCheckPackageVersionDialog extends StatelessWidget {
  const ShowAlertCheckCheckPackageVersionDialog({super.key});

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
          children: [
            "Bạn đang sử dụng gói: ${GeneralManager.dataPackage["packageName"]} - Gía: ${GeneralManager.dataPackage["price"]}",
            (GeneralManager.dataPackage["isDuration"] !=
                        PackageVersio.expired &&
                    GeneralManager.dataPackage["isDuration"] !=
                        PackageVersio.expiredFree)
                ? "Bạn chỉ còn ${GeneralManager.dataPackage["expirationDate"]} ngày để sử dụng dịch vụ.Có thể gia hạn ngay để tiếp tục trải nghiệm!"
                : GeneralManager.dataPackage["isDuration"] !=
                        PackageVersio.expired
                    ? "Bạn đã hết hạn sử dụng phần mềm. Vui lòng liên hệ bên phần mềm để được giải quyết!"
                    : "Bạn đã hết hạn sử dụng phần mềm. Vui lòng thanh toán để tiếp tục sử dụng phần mềm!",
          ]
              .map((message) => Text(
                    message,
                    style:
                        const TextStyle(color: ColorManagement.mainColorText),
                  ))
              .toList(),
        ),
      ),
      actions: <Widget>[
        ChangeNotifierProvider(
          create: (context) => GetUrlPaymentVNpay(),
          child: Consumer<GetUrlPaymentVNpay>(
            builder: (_, controller, __) => controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: ColorManagement.greenColor))
                : GeneralManager.dataPackage["isDuration"] ==
                            PackageVersio.expiredFree ||
                        GeneralManager.dataPackage["isDuration"] ==
                            PackageVersio.almostExpiredFree
                    ? const SizedBox()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (controller.textLinkIOS.isEmpty)
                            ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      ColorManagement.greenColor)),
                              child: Text(UITitleUtil.getTitleByCode(
                                  UITitleCode.SIDEBAR_PAYMENT)),
                              onPressed: () async {
                                await controller
                                    .getUrlPaymentVNPay()
                                    .then((result) {
                                  if (!result.startsWith('https://')) {
                                    MaterialUtil.showAlert(context,
                                        MessageUtil.getMessageByCode(result));
                                    return;
                                  }
                                  defaultTargetPlatform == TargetPlatform.iOS
                                      ? controller.setLinksIOS(result)
                                      : launchUrlString(result,
                                          mode: LaunchMode.externalApplication);
                                });
                              },
                            ),
                          if (defaultTargetPlatform == TargetPlatform.iOS &&
                              controller.textLinkIOS.isNotEmpty)
                            ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      ColorManagement.greenColor)),
                              child: Text(UITitleUtil.getTitleByCode(
                                  UITitleCode.POPUPMENU_OPEN)),
                              onPressed: () async {
                                launchUrlString(controller.textLinkIOS,
                                    mode: LaunchMode.externalApplication);
                              },
                            ),
                          const SizedBox(width: 8),
                          // if (GeneralManager.isDuration != PackageVersio.expired &&
                          //     GeneralManager.isDuration != PackageVersio.expiredFree)
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    ColorManagement.redColor)),
                            child: Text(UITitleUtil.getTitleByCode(
                                UITitleCode.MATERIALUTIL_BUTTON_CLOSE)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
