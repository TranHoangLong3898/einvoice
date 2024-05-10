import 'dart:ui';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/accountingtypemanager.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/manager/suppliermanager.dart';
import 'package:ihotel/modal/accounting/accounting.dart';
import 'package:ihotel/ui/component/management/accounting/accountingtypedialog.dart';
import 'package:ihotel/ui/component/service/hotelservice/supplierdialog.dart';
import 'package:ihotel/ui/controls/neutronbutton.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/ui/controls/neutrontextheader.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/materialutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import 'package:provider/provider.dart';
import '../../../../manager/roommanager.dart';
import '../../../../manager/usermanager.dart';
import '../../../../modal/booking.dart';
import '../../../controls/neutrondatetimepicker.dart';
import '../../../controls/neutrondropdowsearch.dart';

class AddAccountingDialog extends StatelessWidget {
  final Booking? booking;
  final String? idRoom;
  final Accounting? accounting;
  final Map<String, dynamic>? inputData;

  const AddAccountingDialog(
      {Key? key, this.accounting, this.inputData, this.booking, this.idRoom})
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
          create: (context) => AddAcountingController(accounting,
              inputData: inputData, booking: booking, idRoom: idRoom),
          child: Consumer<AddAcountingController>(
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
                            message: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_ACCOUNTING),
                          ),
                        ),
                        // date picked for manager
                        if (UserManager.canSeeAccounting() &&
                            accounting == null) ...[
                          NeutronDateTimePickerBorder(
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CREATE),
                            onPressed: (DateTime? picked) {
                              if (picked != null) {
                                controller.setCreatedDate(picked);
                              }
                            },
                            initialDate: controller.created ?? controller.now,
                            firstDate: controller.now
                                .subtract(const Duration(days: 31)),
                            lastDate: controller.now,
                            isEditDateTime: true,
                          ),
                          const SizedBox(height: SizeManagement.rowSpacing)
                        ],

                        NeutronTextFormField(
                          isDecor: true,
                          controller: controller.teDesc,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_DESCRIPTION_FULL),
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronSearchDropDown(
                            backgroundColor: ColorManagement.mainBackground,
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_TYPE),
                            value: controller.accountingType,
                            valueFirst: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CHOOSE),
                            items: controller.listTypes,
                            onChange: (value) =>
                                selectType(value, controller, context)),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronSearchDropDown(
                            backgroundColor: ColorManagement.mainBackground,
                            label: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_SUPPLIER),
                            value: controller.supplierName,
                            valueFirst: UITitleUtil.getTitleByCode(
                                UITitleCode.TABLEHEADER_CHOOSE),
                            items: controller.listSuppliers,
                            onChange: (newSupplier) => selectSupplier(
                                newSupplier, controller, context)),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        controller.teAmount.buildWidget(
                          isNegative: true,
                          label: UITitleUtil.getTitleByCode(
                              UITitleCode.TABLEHEADER_AMOUNT_MONEY),
                          isDouble: true,
                          isDecor: true,
                        ),
                        const SizedBox(height: SizeManagement.rowSpacing),
                        NeutronButton(
                          margin: const EdgeInsets.all(0),
                          icon: Icons.save,
                          onPressed: () async {
                            await controller.updateToCloud().then((result) {
                              if (result == MessageCodeUtil.SUCCESS) {
                                Navigator.pop(context, true);
                              }
                              MaterialUtil.showResult(context,
                                  MessageUtil.getMessageByCode(result));
                            });
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

  void selectType(String newType, AddAcountingController controller,
      BuildContext context) async {
    if ((controller.listTypes!.where((element) => element == newType).isNotEmpty
            ? controller.listTypes?.firstWhere((element) => element == newType)
            : null) ==
        null) {
      newType = UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE);
    }
    if (newType ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.TEXTALERT_CREATE_NEW_ACCOUNTING_TYPE)) {
      final result = await showDialog(
          context: context,
          builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const AddAccountingTypeDialog()));
      if (result == null || !result) {
        return;
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.rebuild();
      });
      return;
    }
    controller.setType(newType);
  }

  void selectSupplier(String newSupplier, AddAcountingController controller,
      BuildContext context) async {
    if (newSupplier ==
        MessageUtil.getMessageByCode(
            MessageCodeUtil.TEXTALERT_CREATE_NEW_SUPPLIER)) {
      final result = await showDialog(
          context: context,
          builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const SupplierDialog()));
      if (result == null || !result) {
        return;
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        controller.rebuild();
      });
      return;
    }
    controller.setSupplier(newSupplier);
  }
}

class AddAcountingController extends ChangeNotifier {
  Accounting? oldAccounting;
  late bool isLoading;
  DateTime? created;
  late DateTime now;
  String? invoiceNum;
  late TextEditingController teDesc;
  late String _supplierId, _accountingTypeId;
  late NeutronInputNumberController teAmount;
  Map<String, String> mapData = {};

  AddAcountingController(this.oldAccounting,
      {Map<String, dynamic>? inputData, Booking? booking, String? idRoom}) {
    isLoading = false;
    now = DateTime.now();
    if (inputData != null) {
      teDesc = TextEditingController(text: inputData['desc']);
      teAmount = NeutronInputNumberController(
          TextEditingController(text: inputData['amount']?.toString()));
      invoiceNum = inputData['invoice_num'];
    } else {
      teDesc = TextEditingController(text: oldAccounting?.desc ?? '');
      teAmount = NeutronInputNumberController(
          TextEditingController(text: oldAccounting?.amount?.toString() ?? ''));
      invoiceNum = oldAccounting?.invoiceNum ?? '';
    }
    if (booking != null) {
      mapData["id"] = booking.id!;
      mapData["sid"] = booking.sID!;
    }
    if (idRoom != null) {
      mapData["room"] = idRoom;
      mapData["roomtype"] = RoomManager().getRoomTypeById(idRoom);
    }
    _supplierId = oldAccounting?.supplier ?? '';
    _accountingTypeId = oldAccounting?.type ?? '';
  }

  String get accountingType => _accountingTypeId.isEmpty
      ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)
      : AccountingTypeManager.getNameById(_accountingTypeId)!;

  String get supplierName => _supplierId.isEmpty
      ? UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)
      : SupplierManager().getSupplierNameByID(_supplierId);

  List<String>? get listTypes => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.TEXTALERT_CREATE_NEW_ACCOUNTING_TYPE),
        ...AccountingTypeManager.listNamesActive,
      ];

  List<String> get listSuppliers => [
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE),
        MessageUtil.getMessageByCode(
            MessageCodeUtil.TEXTALERT_CREATE_NEW_SUPPLIER),
        ...SupplierManager().getSupplierNames(),
      ];

  void setSupplier(String newSupplier) {
    if (supplierName == newSupplier ||
        newSupplier ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_CREATE_NEW_SUPPLIER)) {
      return;
    }
    if (newSupplier ==
        UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      _supplierId = '';
    } else {
      _supplierId = SupplierManager().getSupplierIDByName(newSupplier)!;
    }
    notifyListeners();
  }

  void setCreatedDate(DateTime datePicked) {
    created = datePicked;
    notifyListeners();
  }

  void setType(String newType) {
    if (accountingType == newType ||
        newType ==
            MessageUtil.getMessageByCode(
                MessageCodeUtil.TEXTALERT_CREATE_NEW_ACCOUNTING_TYPE)) {
      return;
    }
    if (newType == UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_CHOOSE)) {
      _accountingTypeId = '';
    } else {
      _accountingTypeId = AccountingTypeManager.getIdByName(newType)!;
    }
    notifyListeners();
  }

  Future<String> updateToCloud() async {
    if (teDesc.text.isEmpty) {
      return MessageCodeUtil.INPUT_DESCRIPTION;
    }
    if (_accountingTypeId.isEmpty) {
      return MessageCodeUtil.TEXTALERT_TYPE_CAN_NOT_BE_EMPTY;
    }
    if (_supplierId.isEmpty) {
      return MessageCodeUtil.TEXTALERT_SUPPLIER_CAN_NOT_BE_EMPTY;
    }
    if (num.tryParse(teAmount.getRawString()) == null) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }
    String result;
    if (oldAccounting == null) {
      result = await createNewAccounting();
    } else {
      result = await updateAccounting();
    }
    return result;
  }

  Future<String> createNewAccounting() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-createCostManagement')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'desc': teDesc.text.trim(),
          'supplier_id': _supplierId,
          'type_cost_id': _accountingTypeId,
          'amount': num.parse(teAmount.getRawString()),
          'created': created != null ? created.toString() : '',
          'map_data': mapData,
          if (invoiceNum != null) 'invoice_num': invoiceNum
        })
        .then((value) => value.data)
        .onError((error, stackTrace) {
          print(error);
          return (error as FirebaseFunctionsException).message;
        })
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  Future<String> updateAccounting() async {
    isLoading = true;
    notifyListeners();
    return await FirebaseFunctions.instance
        .httpsCallable('costmanagement-updateCostManagement')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'cost_management_id': oldAccounting!.id,
          'desc': teDesc.text.trim(),
          'supplier_id': _supplierId,
          'type_cost_id': _accountingTypeId,
          'amount': num.parse(teAmount.getRawString()),
          if (invoiceNum != null && invoiceNum != '') 'invoice_num': invoiceNum
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message)
        .whenComplete(() {
          isLoading = false;
          notifyListeners();
        });
  }

  void rebuild() => notifyListeners();
}
