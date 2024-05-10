import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:provider/provider.dart';

import '../../../../controller/management/financialdatecontroller.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/messageulti.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutronblurbutton.dart';
import '../../../controls/neutrondatepicker.dart';
import '../../../controls/neutrontextheader.dart';

class FinancialDateDialog extends StatelessWidget {
  const FinancialDateDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
          width: kMobileWidth,
          height: 110,
          child: ChangeNotifierProvider(
            create: (context) => FinancialDateController(),
            child: Consumer<FinancialDateController>(
              builder: (_, controller, __) => Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        top: SizeManagement.topHeaderTextSpacing),
                    child: NeutronTextHeader(
                      message: UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_FINANCIAL_DATE),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: ColorManagement.greenColor),
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: NeutronDatePicker(
                                  tooltip: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_DATE),
                                  initialDate: controller.date,
                                  firstDate: controller.now!
                                      .subtract(const Duration(days: 365)),
                                  lastDate: controller.now!
                                      .add(const Duration(days: 365)),
                                  onChange: controller.setDate,
                                ),
                              ),
                              Expanded(
                                child: NeutronBlurButton(
                                  tooltip: UITitleUtil.getTitleByCode(
                                      UITitleCode.TOOLTIP_SAVE),
                                  icon: Icons.save,
                                  onPressed: () async {
                                    await controller
                                        .updateFinancialDate()
                                        .then((result) {
                                      if (result == MessageCodeUtil.SUCCESS) {
                                        Navigator.pop(context, true);
                                      }
                                      MaterialUtil.showResult(context,
                                          MessageUtil.getMessageByCode(result));
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
