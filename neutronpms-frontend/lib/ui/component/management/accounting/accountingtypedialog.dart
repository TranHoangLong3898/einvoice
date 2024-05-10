import 'package:flutter/material.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants.dart';
import '../../../../controller/management/accountingtypecontroller.dart';
import '../../../../manager/accountingtypemanager.dart';
import '../../../../manager/configurationmanagement.dart';
import '../../../../modal/accounting/accounting.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/materialutil.dart';
import '../../../../util/messageulti.dart';
import '../../../controls/neutronbutton.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontextformfield.dart';
import '../../../controls/neutrontexttilte.dart';

class AccountingTypeDialog extends StatefulWidget {
  const AccountingTypeDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountingTypeDialog> createState() => _AccountingTypeDialogState();
}

class _AccountingTypeDialogState extends State<AccountingTypeDialog> {
  late ConfigurationManagement configurationManagement;
  @override
  void initState() {
    configurationManagement = ConfigurationManagement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: Container(
        padding:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        width: kMobileWidth,
        child: ChangeNotifierProvider<ConfigurationManagement>.value(
          value: configurationManagement,
          child: Consumer<ConfigurationManagement>(
            child: const SizedBox(
                height: kMobileWidth,
                child: Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                )),
            builder: (_, controller, child) {
              return controller.isInProgress
                  ? child!
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.SIDEBAR_ACCOUNTING_TYPE),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: NeutronTextTitle(
                                isPadding: true,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_ID),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: NeutronTextTitle(
                                textAlign: TextAlign.start,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_NAME),
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: NeutronTextTitle(
                                textAlign: TextAlign.center,
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_STATUS_COMPACT),
                              ),
                            ),
                            const SizedBox(width: 40)
                          ],
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        Expanded(
                            child: ListView(
                          children: AccountingTypeManager.accountingTypes
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.only(
                                      top: SizeManagement.rowSpacing),
                                  height: SizeManagement.cardHeight,
                                  decoration: BoxDecoration(
                                      color:
                                          ColorManagement.lightMainBackground,
                                      borderRadius: BorderRadius.circular(
                                          SizeManagement.borderRadius8)),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                          width: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      Expanded(
                                          child: NeutronTextContent(
                                              message: e!.id!, tooltip: e.id)),
                                      Expanded(
                                        flex: 2,
                                        child: NeutronTextContent(
                                          textAlign: TextAlign.start,
                                          tooltip: e.name,
                                          message: e.name!,
                                        ),
                                      ),
                                      Expanded(
                                        child: Switch(
                                          value: e.isActive,
                                          activeColor:
                                              ColorManagement.greenColor,
                                          inactiveTrackColor:
                                              ColorManagement.mainBackground,
                                          onChanged: (value) => toggleStatus(e),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                            maxWidth: 40, minWidth: 40),
                                        tooltip: UITitleUtil.getTitleByCode(
                                            UITitleCode.TOOLTIP_EDIT),
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  AddAccountingTypeDialog(
                                                    accountingType: e,
                                                  ));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        )),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronButton(
                          margin: const EdgeInsets.all(0),
                          icon: Icons.add,
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (ctx) =>
                                    const AddAccountingTypeDialog());
                          },
                        )
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  void toggleStatus(AccountingType e) async {
    bool? confirm;
    String result = '';
    if (e.isActive == false) {
      confirm = await MaterialUtil.showConfirm(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.CONFIRM_ACTIVE, [e.name!]));
      if (confirm == null || confirm == false) return;
      result = await configurationManagement.deleteAccountingType(e.id!);
    } else {
      confirm = await MaterialUtil.showConfirm(
          context,
          MessageUtil.getMessageByCode(
              MessageCodeUtil.CONFIRM_STOP_WORKING, [e.name!]));
      if (confirm == null || confirm == false) return;
      result = await configurationManagement.deleteAccountingType(e.id!);
    }

    if (mounted) {
      MaterialUtil.showResult(context, MessageUtil.getMessageByCode(result));
    }
  }
}

class AddAccountingTypeDialog extends StatelessWidget {
  final AccountingType? accountingType;

  const AddAccountingTypeDialog({Key? key, this.accountingType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: Container(
        padding:
            const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
        width: kMobileWidth,
        child: ChangeNotifierProvider(
          create: (context) => AccountingTypeController(accountingType),
          child: Consumer<AccountingTypeController>(
            child: const SizedBox(
                height: kMobileWidth,
                child: Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                )),
            builder: (_, controller, child) {
              return controller.isLoading
                  ? child!
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              vertical: SizeManagement.topHeaderTextSpacing),
                          child: NeutronTextHeader(
                            message: controller.isAdd
                                ? UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_ADD_ACCOUNTING_TYPE)
                                : UITitleUtil.getTitleByCode(
                                    UITitleCode.HEADER_UPDATE_ACCOUNTING_TYPE),
                          ),
                        ),
                        NeutronTextFormField(
                          readOnly: controller.isAdd ? false : true,
                          isDecor: true,
                          controller: controller.teIdController,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_ID),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronTextFormField(
                          isDecor: true,
                          controller: controller.teNameController,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_NAME),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronButton(
                          margin: const EdgeInsets.all(0),
                          icon: Icons.save,
                          onPressed: () async {
                            String result = await controller.createAndUpdate();
                            if (result == MessageCodeUtil.SUCCESS) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                            }
                            // ignore: use_build_context_synchronously
                            MaterialUtil.showResult(
                                context, MessageUtil.getMessageByCode(result));
                          },
                        )
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
