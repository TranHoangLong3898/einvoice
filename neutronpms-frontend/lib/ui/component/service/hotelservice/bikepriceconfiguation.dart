// ignore_for_file: use_build_context_synchronously

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/manager/configurationmanagement.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrontextformfield.dart';
import '../../../controls/neutrontextheader.dart';

// ignore: must_be_immutable
class BikePriceConfigurationDialog extends StatelessWidget {
  late final BikePriceConfiguratonController controller =
      BikePriceConfiguratonController();
  late NeutronInputNumberController autoPriceController, manualPriceController;

  BikePriceConfigurationDialog({Key? key}) : super(key: key) {
    autoPriceController = NeutronInputNumberController(controller.teAutoPrice!);
    manualPriceController =
        NeutronInputNumberController(controller.teManualPrice!);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SizedBox(
        width: kMobileWidth,
        child: ChangeNotifierProvider<BikePriceConfiguratonController>.value(
          value: controller,
          child: Consumer<BikePriceConfiguratonController>(
            builder: (_, controller, __) => controller.inProgress
                ? Container(
                    height: kMobileWidth,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                        color: ColorManagement.greenColor),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //title
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: SizeManagement.topHeaderTextSpacing),
                        child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.HEADER_BIKE_PRICE)),
                      ),
                      //input
                      Row(
                        children: [
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          Expanded(
                            child: autoPriceController.buildWidget(
                              isDouble: true,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE_TYPE_AUTO),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          Expanded(
                            child: manualPriceController.buildWidget(
                              isDouble: true,
                              label: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_BIKE_TYPE_MANUAL),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  SizeManagement.cardOutsideHorizontalPadding),
                        ],
                      ),
                      const SizedBox(height: SizeManagement.rowSpacing),
                      //save
                      NeutronButton(
                        icon: Icons.save,
                        onPressed: () async {
                          String result = await controller.saveBikeConfig();
                          if (result != MessageCodeUtil.SUCCESS) {
                            MaterialUtil.showAlert(
                                context, MessageUtil.getMessageByCode(result));
                            return;
                          }
                          Navigator.pop(context, true);
                        },
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class BikePriceConfiguratonController extends ChangeNotifier {
  ConfigurationManagement configurationManagement = ConfigurationManagement();
  TextEditingController? teAutoPrice;
  TextEditingController? teManualPrice;

  bool inProgress = false;

  BikePriceConfiguratonController() {
    teAutoPrice = TextEditingController(
        text: configurationManagement.bikeConfigs['auto']?.toString() ?? '');
    teManualPrice = TextEditingController(
        text: configurationManagement.bikeConfigs['manual']?.toString() ?? '');
  }

  Future<String> saveBikeConfig() async {
    if (teAutoPrice!.text.isEmpty || teManualPrice!.text.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    num? auto = num.tryParse(teAutoPrice!.text.replaceAll(',', ''));
    num? manual = num.tryParse(teManualPrice!.text.replaceAll(',', ''));

    if (auto == null || manual == null || auto <= 0 || manual <= 0) {
      return MessageCodeUtil.INPUT_POSITIVE_PRICE;
    }

    if (auto == configurationManagement.bikeConfigs['auto'] &&
        manual == configurationManagement.bikeConfigs['manual']) {
      return MessageCodeUtil.STILL_NOT_CHANGE_VALUE;
    }

    inProgress = true;
    notifyListeners();

    String result = await FirebaseFunctions.instance
        .httpsCallable('hotelmanager-updateBikeConfig')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'auto_price': auto,
          'manual_price': manual
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);

    inProgress = false;
    notifyListeners();
    return result;
  }
}
