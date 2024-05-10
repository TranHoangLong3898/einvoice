import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/ui/component/admin/paymentmethod/addpaymentmethoddialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/ui/controls/neutrontexttilte.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';

class PaymentMethodDialog extends StatelessWidget {
  const PaymentMethodDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ColorManagement.mainBackground,
        child: SizedBox(
            width: kWidth,
            height: kHeight,
            child: Scaffold(
              appBar: AppBar(
                title: NeutronTextContent(
                    message: UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT)),
                backgroundColor: ColorManagement.mainBackground,
                actions: const [],
              ),
              backgroundColor: ColorManagement.mainBackground,
              body: ChangeNotifierProvider<PaymentMethodManager>.value(
                  value: PaymentMethodManager(),
                  child: Consumer<PaymentMethodManager>(
                    builder: (_, controller, __) {
                      final children = controller.paymentMethodsActive
                          .map((payment) => Container(
                                height: SizeManagement.cardHeight,
                                margin: const EdgeInsets.symmetric(
                                    vertical: SizeManagement
                                        .cardOutsideVerticalPadding,
                                    horizontal: SizeManagement
                                        .cardOutsideHorizontalPadding),
                                decoration: BoxDecoration(
                                    color: ColorManagement.lightMainBackground,
                                    borderRadius: BorderRadius.circular(
                                        SizeManagement.borderRadius8)),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: SizeManagement
                                              .cardInsideHorizontalPadding),
                                      child: NeutronTextContent(
                                        message: payment.id!,
                                      ),
                                    )),
                                    Expanded(
                                        child: NeutronTextContent(
                                      tooltip: payment.name,
                                      message: payment.name!,
                                    )),
                                    Expanded(
                                        flex: 2,
                                        child: NeutronTextContent(
                                            tooltip: payment.status.toString(),
                                            message:
                                                payment.status.toString())),
                                    SizedBox(
                                      width: 40,
                                      child: InkWell(
                                        child: const Icon(Icons.edit),
                                        onTap: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (ctx) =>
                                                  AddPaymentMethodDialog(
                                                    payment: payment,
                                                  ));
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: InkWell(
                                        child: const Icon(Icons.delete),
                                        onTap: () async {
                                          final result =
                                              await MaterialUtil.showConfirm(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      MessageCodeUtil
                                                          .CONFIRM_DELETE_X,
                                                      [payment.id!]));
                                          if (result != null && result) {
                                            final resultDelete =
                                                await controller
                                                    .deletePayment(payment.id!);
                                            if (resultDelete ==
                                                MessageCodeUtil.SUCCESS) {
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                              // ignore: use_build_context_synchronously
                                              MaterialUtil.showSnackBar(
                                                  context,
                                                  MessageUtil.getMessageByCode(
                                                      resultDelete));
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              MaterialUtil.showResult(
                                                  context, resultDelete!);
                                            }
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          .toList();
                      if (controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorManagement.greenColor,
                          ),
                        );
                      }
                      return Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 65),
                          child: Column(
                            children: [
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: SizeManagement
                                          .cardOutsideHorizontalPadding),
                                  height: SizeManagement.cardHeight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: SizeManagement
                                                  .cardInsideHorizontalPadding),
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_ID),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: NeutronTextTitle(
                                          isPadding: false,
                                          message: UITitleUtil.getTitleByCode(
                                              UITitleCode.TABLEHEADER_NAME),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: NeutronTextTitle(
                                            isPadding: false,
                                            message: UITitleUtil.getTitleByCode(
                                                UITitleCode.TABLEHEADER_STATUS),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 80,
                                      )
                                    ],
                                  )),
                              Expanded(
                                child: ListView(
                                  children: children,
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: NeutronButton(
                            icon1: Icons.add,
                            onPressed1: () async {
                              await showDialog(
                                  context: context,
                                  builder: (ctx) =>
                                      const AddPaymentMethodDialog());
                            },
                          ),
                        )
                      ]);
                    },
                  )),
            )));
  }
}
