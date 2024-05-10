// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/controller/policycontroller.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../util/materialutil.dart';
import '../../util/messageulti.dart';

class PolicyDialog extends StatefulWidget {
  const PolicyDialog({Key? key}) : super(key: key);

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
  late PolicyController policyController;
  final HtmlEditorController htmlEditorController = HtmlEditorController();

  @override
  void initState() {
    policyController = PolicyController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.mainBackground,
      child: SizedBox(
        width: kWidth,
        height: kHeight,
        child: ChangeNotifierProvider.value(
          value: policyController,
          child: Consumer<PolicyController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: ColorManagement.greenColor),
                );
              }
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                              height: SizeManagement.topHeaderTextSpacing),
                          NeutronTextHeader(
                              message: UITitleUtil.getTitleByCode(
                                  UITitleCode.TABLEHEADER_POLICY)),
                          const SizedBox(
                              height:
                                  SizeManagement.cardOutsideHorizontalPadding),
                          Container(
                            color: ColorManagement.white,
                            margin: const EdgeInsets.only(right: 10),
                            child: HtmlEditor(
                              controller: htmlEditorController, //required
                              htmlEditorOptions: HtmlEditorOptions(
                                initialText: controller.policy,
                                shouldEnsureVisible: true,
                              ),
                              htmlToolbarOptions: const HtmlToolbarOptions(
                                  toolbarType: ToolbarType.nativeGrid,
                                  buttonColor: ColorManagement.mainBackground),
                              otherOptions: const OtherOptions(height: 400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: NeutronButton(
                      icon: Icons.save,
                      onPressed: () async {
                        await htmlEditorController
                            .getText()
                            .then((value) async {
                          await controller
                              .addPolicy(value)
                              .then((result) async {
                            if (result == MessageCodeUtil.SUCCESS) {
                              await GeneralManager.screenshotHtmlToImgPolicy(
                                  context, value);
                              MaterialUtil.showSnackBar(
                                  context,
                                  MessageUtil.getMessageByCode(
                                      MessageCodeUtil.SUCCESS));
                            } else {
                              MaterialUtil.showAlert(context,
                                  MessageUtil.getMessageByCode(result));
                            }
                          });
                        });
                      },
                    ),
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
