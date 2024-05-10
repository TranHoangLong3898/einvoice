import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/ui/controls/neutrontextformfield.dart';
import 'package:ihotel/util/einvoiceutil.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

class GenerateElectronicInvoiceController extends ChangeNotifier {
  TextEditingController? cusCodeTeController,
      buyerTeController,
      cusNameTeController,
      emailTeController,
      custAddressTeController,
      cusBankNameTeController,
      cusBankNoTeController,
      cusPhoneTeController,
      otherPaymentMethodTeController,
      amountInWordsTeController,
      cusTaxCodeTeController;
  String paymentMethod = ElectronicInvoicePaymentMethod.cashOrBanking;
  int vatRate = 0;
  String currentcyUnit = CurrencyUnit.VND;
  NeutronInputNumberController exchangeRate =
      NeutronInputNumberController(TextEditingController(text: ''));
  NeutronInputNumberController otherVat =
      NeutronInputNumberController(TextEditingController(text: ''));
  bool isContainService;
  Booking booking;

  GenerateElectronicInvoiceController(this.booking, this.isContainService) {
    cusCodeTeController = TextEditingController(text: '');
    buyerTeController = TextEditingController(text: booking.name);
    cusNameTeController = TextEditingController(text: booking.name);
    emailTeController = TextEditingController(text: booking.email);
    custAddressTeController = TextEditingController(text: '');
    cusBankNameTeController = TextEditingController(text: '');
    cusBankNoTeController = TextEditingController(text: '');
    cusPhoneTeController = TextEditingController(text: booking.phone);
    cusTaxCodeTeController = TextEditingController(text: '');
    otherPaymentMethodTeController = TextEditingController(text: '');
    amountInWordsTeController = TextEditingController(text: '');
  }

  setPaymentMethod(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  setVat(String value) {
    String temp = VatRate.vateRate()
        .firstWhere((element) => UITitleUtil.getTitleByCode(element) == value);
    switch (temp) {
      case VatRate.zeroPercent:
        vatRate = 0;
        break;
      case VatRate.fivePercent:
        vatRate = 5;
        break;
      case VatRate.eightPercent:
        vatRate = 8;
        break;
      case VatRate.tenPercent:
        vatRate = 10;
        break;
      case VatRate.notSubject:
        vatRate = -1;
        break;
      case VatRate.notDeclare:
        vatRate = -2;
        break;
      case VatRate.other:
        vatRate = -3;
        break;
    }
    notifyListeners();
  }

  setCurrentcyUnit(String value) {
    currentcyUnit = value;
    notifyListeners();
  }

  String checkData() {
    if (paymentMethod == ElectronicInvoicePaymentMethod.other &&
        otherPaymentMethodTeController!.text.trim() == '') {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OTHER_PAYMENT_METHOD_CAN_NOT_BE_EMPTY);
    }
    if (vatRate == -3) {
      if (otherVat.controller.text.trim() == '') {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.OTHER_VAT_CAN_NOT_BE_EMPTY);
      }
      if ((double.tryParse(otherVat.controller.text.trim()) ?? 0) >= 100) {
        return MessageUtil.getMessageByCode(
            MessageCodeUtil.OTHER_VAT_CAN_NOT_GREATER_THAN_100);
      }
    }
    if (amountInWordsTeController!.text.trim() == '') {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.AMOUNT_IN_WORD_CAN_NOT_BE_EMPTY);
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> generateEInvoice() async {
    int countProduct = 1;
    double vat = vatRate == -3
        ? otherVat.getNumber()!.toDouble()
        : vatRate < 0
            ? 0
            : (vatRate / 100);
    List<Map<String, dynamic>> productsData = [
      {
        'Product': [
          {'No': countProduct},
          {'Feature': 1},
          {'ProdName': UITitleUtil.getTitleByCode(UITitleCode.ROOM_CHARGE)},
          {'Total': booking.getRoomCharge() / (1 + vat)},
          {'VATRate': vatRate},
          {
            'VATRateOther': otherVat.controller.text.trim() == ''
                ? ''
                : otherVat.getNumber()
          },
          {'Amount': booking.getRoomCharge()}
        ]
      }
    ];

    if (isContainService) {
      if (booking.minibar != null && booking.minibar != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_MINIBAR_SERVICE)
            },
            {'Total': booking.minibar! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber(),
            },
            {'Amount': booking.minibar}
          ]
        });
      }
      if (booking.insideRestaurant != null && booking.insideRestaurant != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_INSIDE_RESTAURANT)
            },
            {'Total': booking.insideRestaurant! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.insideRestaurant}
          ]
        });
      }
      if (booking.outsideRestaurant != null && booking.outsideRestaurant != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName':
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_RESTAURANT)
            },
            {'Total': booking.outsideRestaurant! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.outsideRestaurant}
          ]
        });
      }
      if (booking.extraGuest != null && booking.extraGuest != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_EXTRA_GUEST_SERVICE)
            },
            {'Total': booking.extraGuest! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.extraGuest}
          ]
        });
      }
      if (booking.extraHour != null && booking.extraHour!.total != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_EXTRA_HOUR_SERVICE)
            },
            {'Total': booking.extraHour!.total! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.extraHour!.total}
          ]
        });
      }
      if (booking.electricity != null && booking.electricity != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_ELECTRICITY)
            },
            {'Total': booking.electricity! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.electricity}
          ]
        });
      }
      if (booking.water != null && booking.water != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName':
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_WATER)
            },
            {'Total': booking.water! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.water}
          ]
        });
      }
      if (booking.laundry != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_LAUNDRY_SERVICE)
            },
            {'Total': booking.laundry / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.laundry}
          ]
        });
      }
      if (booking.bikeRental != null && booking.bikeRental != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName': UITitleUtil.getTitleByCode(
                  UITitleCode.TABLEHEADER_BIKE_RENTAL_SERVICE)
            },
            {'Total': booking.bikeRental! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.bikeRental}
          ]
        });
      }
      if (booking.other != null && booking.other != 0) {
        countProduct++;
        productsData.add({
          'Product': [
            {'No': countProduct},
            {'Feature': 1},
            {
              'ProdName':
                  UITitleUtil.getTitleByCode(UITitleCode.TABLEHEADER_OTHER)
            },
            {'Total': booking.other! / (1 + vat)},
            {'VATRate': vatRate},
            {
              'VATRateOther': otherVat.controller.text.trim() == ''
                  ? ''
                  : otherVat.getNumber()
            },
            {'Amount': booking.other}
          ]
        });
      }
    }

    final data = {
      'hotel_id': GeneralManager.hotelID,
      'booking_id': booking.id,
      'CusCode': cusCodeTeController!.text.trim(),
      'Buyer': buyerTeController!.text.trim(),
      'CusName': cusNameTeController!.text.trim(),
      'Email': emailTeController!.text.trim(),
      'CusAddress': custAddressTeController!.text.trim(),
      'CusBankName': cusBankNameTeController!.text.trim(),
      'CusBankNo': cusBankNoTeController!.text.trim(),
      'CusPhone': cusPhoneTeController!.text.trim(),
      'CusTaxCode': cusTaxCodeTeController!.text.trim(),
      'PaymentMethod': paymentMethod == ElectronicInvoicePaymentMethod.other
          ? otherPaymentMethodTeController!.text.trim()
          : paymentMethod,
      'ExchangeRate': exchangeRate.getNumber(),
      'CurrencyUnit': currentcyUnit,
      'roomCharge': booking.getRoomCharge(),
      'Products': productsData,
      'Total': booking.getTotalCharge()! * (1 - vat),
      'VATAmount': booking.getTotalCharge()! * vat,
      'VATRate': vatRate,
      'VATRateOther': otherVat.getNumber() ?? '',
      'Amount': booking.getTotalCharge(),
      'AmountInWords': amountInWordsTeController!.text.trim()
    };
    final result = await FirebaseFunctions.instance
        .httpsCallable('einvoice-generateElectronicInvoice')
        .call(data);
    return result.data;
  }
}
