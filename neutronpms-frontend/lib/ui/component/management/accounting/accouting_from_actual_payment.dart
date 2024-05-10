import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../../handler/firebasehandler.dart';
import '../../../../manager/accountingtypemanager.dart';
import '../../../../manager/suppliermanager.dart';
import '../../../../modal/accounting/accounting.dart';
import '../../../../modal/accounting/actualpayment.dart';
import '../../../../util/dateutil.dart';
import '../../../../util/designmanagement.dart';
import '../../../../util/numberutil.dart';
import '../../../../util/uimultilanguageutil.dart';
import '../../../controls/neutrontextcontent.dart';
import '../../../controls/neutrontexttilte.dart';
import 'accountingdialog.dart';

class AccountingFromActualPayment extends StatefulWidget {
  const AccountingFromActualPayment({Key? key, this.actualPayment})
      : super(key: key);
  final ActualPayment? actualPayment;

  @override
  State<AccountingFromActualPayment> createState() =>
      _AccountingFromActualPaymentState();
}

class _AccountingFromActualPaymentState
    extends State<AccountingFromActualPayment> {
  AccountingFromActualPaymentConroller? _accountingFromActualPaymentConroller;

  @override
  void initState() {
    super.initState();
    _accountingFromActualPaymentConroller ??=
        AccountingFromActualPaymentConroller(
            idCost: widget.actualPayment!.accountingId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorManagement.lightMainBackground,
      child: SingleChildScrollView(
        child: Container(
          padding:
              const EdgeInsets.all(SizeManagement.cardOutsideHorizontalPadding),
          width: kMobileWidth,
          child: ChangeNotifierProvider.value(
            value: _accountingFromActualPaymentConroller,
            child: Consumer<AccountingFromActualPaymentConroller>(
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
                          DataTable(
                              columnSpacing: 5,
                              horizontalMargin: 8,
                              headingRowHeight: 0,
                              columns: const <DataColumn>[
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                              ],
                              rows: <DataRow>[
                                // created
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TOOLTIP_CREATED_TIME))),
                                  DataCell(NeutronTextContent(
                                    message: DateUtil
                                        .dateToDayMonthYearHourMinuteString(
                                            controller.accounting.created!),
                                  )),
                                ]),
                                // desc
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_DESCRIPTION_FULL))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                      message: controller.accounting.desc!,
                                      maxLines: 2,
                                    ),
                                  )),
                                ]),
                                // sup
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_SUPPLIER))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                      message: SupplierManager()
                                          .getSupplierNameByID(
                                              controller.accounting.supplier),
                                      maxLines: 2,
                                    ),
                                  )),
                                ]),
                                // type
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_TYPE))),
                                  DataCell(NeutronTextContent(
                                    message: AccountingTypeManager.getNameById(
                                        controller.accounting.type!)!,
                                  )),
                                ]),
                                // creator
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_CREATOR))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                      message: controller.accounting.author!,
                                      maxLines: 2,
                                    ),
                                  )),
                                ]),
                                // money
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode
                                              .TABLEHEADER_AMOUNT_MONEY))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                        textAlign: TextAlign.center,
                                        message: NumberUtil.numberFormat.format(
                                            controller.accounting.amount),
                                        color: ColorManagement.positiveText),
                                  )),
                                ]),
                                // actual payment
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_PAID))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                      textAlign: TextAlign.center,
                                      message: NumberUtil.numberFormat.format(
                                          controller.accounting.actualPayment),
                                      color: ColorManagement.negativeText,
                                    ),
                                  )),
                                ]),
                                // remaining
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_REMAIN))),
                                  DataCell(SizedBox(
                                    width: SizeManagement
                                        .widthOfAccountingFromActualPayment,
                                    child: NeutronTextContent(
                                        textAlign: TextAlign.center,
                                        message: NumberUtil.numberFormat.format(
                                            controller.accounting.amount! -
                                                controller
                                                    .accounting.actualPayment!),
                                        color: ColorManagement.positiveText),
                                  )),
                                ]),
                                // status
                                DataRow(cells: <DataCell>[
                                  DataCell(NeutronTextTitle(
                                      isPadding: false,
                                      message: UITitleUtil.getTitleByCode(
                                          UITitleCode.TABLEHEADER_STATUS))),
                                  DataCell(NeutronTextContent(
                                      message: controller.accounting.status!)),
                                ]),
                              ]),
                          // edit
                          IconButton(
                            constraints: const BoxConstraints(maxWidth: 40),
                            onPressed: () =>
                                updateContent(controller.accounting),
                            icon: Tooltip(
                                message: UITitleUtil.getTitleByCode(
                                    UITitleCode.TABLEHEADER_EDIT_ACOUNTING),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  void updateContent(Accounting accounting) async {
    await showDialog(
            context: context,
            builder: (context) => AddAccountingDialog(accounting: accounting))
        .then((value) {
      if (value != null && value) {
        _accountingFromActualPaymentConroller!
            .getData(widget.actualPayment!.accountingId!);
      }
    });
  }
}

class AccountingFromActualPaymentConroller extends ChangeNotifier {
  late Accounting accounting;
  late bool isLoading;

  AccountingFromActualPaymentConroller({String? idCost}) {
    isLoading = true;
    notifyListeners();
    getData(idCost);
  }

  void getData(String? idCost) async {
    await FirebaseHandler.hotelRef
        .collection(FirebaseHandler.colCostManagement)
        .doc(idCost)
        .get()
        .then((document) {
      accounting = Accounting.fromDocumentSnapshot(document);
      isLoading = false;
      notifyListeners();
    });
  }
}
