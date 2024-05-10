import 'package:flutter/material.dart';
import 'package:ihotel/controller/booking/updatetaxdeclarecontroller.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../util/designmanagement.dart';
import '../../../util/uimultilanguageutil.dart';
import '../../controls/neutron_selector.dart';
import '../../controls/neutronbutton.dart';
import '../../controls/neutrontextcontent.dart';

class UpdateTaxDeclareDialog extends StatefulWidget {
  final Booking? booking;
  const UpdateTaxDeclareDialog({Key? key, this.booking}) : super(key: key);

  @override
  State<UpdateTaxDeclareDialog> createState() => _UpdateTaxDeclareDialogState();
}

class _UpdateTaxDeclareDialogState extends State<UpdateTaxDeclareDialog> {
  late UpdateTaxDeclareController controller;

  @override
  void initState() {
    controller = UpdateTaxDeclareController(widget.booking!);
    super.initState();
  }

  @override
  Widget build(context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<UpdateTaxDeclareController>(
          child: const SizedBox(
            height: kMobileWidth,
            width: kMobileWidth,
            child: Center(
                child: CircularProgressIndicator(
                    color: ColorManagement.greenColor)),
          ),
          builder: (_, controller, child) => controller.isLoading
              ? child!
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(
                          SizeManagement.cardOutsideHorizontalPadding),
                      child: NeutronSelector(
                        initIndex: controller.selectedStatus ? 0 : 1,
                        onChanged: (index) =>
                            controller.setNewStatus(index == 0),
                        itemAlign: Alignment.center,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 8),
                        items: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_circle_outlined),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardInsideHorizontalPadding),
                              NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.POPUPMENU_DECLARE)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.no_accounts_outlined),
                              const SizedBox(
                                  width: SizeManagement
                                      .cardInsideHorizontalPadding),
                              NeutronTextContent(
                                  message: UITitleUtil.getTitleByCode(
                                      UITitleCode.POPUPMENU_NON_DECLARE)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: kMobileWidth,
                      child: NeutronButton(
                        margin: const EdgeInsets.all(
                            SizeManagement.cardOutsideHorizontalPadding),
                        icon: Icons.save,
                        onPressed: () async {
                          await controller.update().then((result) {
                            if (result == MessageCodeUtil.SUCCESS) {
                              Navigator.pop(context);
                            }
                            MaterialUtil.showResult(
                                context, MessageUtil.getMessageByCode(result));
                          });
                        },
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
