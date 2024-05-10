class ElectronicInvoiceSoftWare {
  static const String easyInvoice = 'Easy Invoice';

  static List<String> listSoftWares() => [easyInvoice];
}

class ElectronicInvoiceGenerateOption {
  static const String all = 'generate-all';
  static const String bySelection = 'generate-selection';

  static List<String> options() => [all, bySelection];
}

class ElectronicInvoiceServiceOption {
  static const String all = 'generate-all';
  static const String bySelection = 'generate-selection';

  static List<String> options() => [all, bySelection];
}

class ElectronicInvoicePaymentMethod {
  static const String cash = 'Tiền mặt';
  static const String banking = 'Chuyển khoản';
  static const String cashOrBanking = 'Tiền mặt/Chuyển khoản';
  static const String liability = 'Đối trừ công nợ';
  static const String none = 'Không thu tiền';
  static const String other = 'Khác';
  static List<String> paymentMethod() =>
      [cash, banking, cashOrBanking, liability, none, other];
}

class CurrencyUnit {
  static const String VND = 'VND';
  static const String USD = 'USD';
  static const String EUR = 'EUR';
  static const String JPY = 'JPY';
  static const String GBP = 'GBP';
  static const String CHF = 'CHF';
  static const String AUD = 'AUD';
  static const String CAD = 'CAD';
  static List<String> currencyUnit() =>
      [VND, USD, EUR, JPY, GBP, CHF, AUD, CAD];
}

class VatRate {
  static const String zeroPercent = 'vat-one-percent';
  static const String fivePercent = 'vat-fice-percent';
  static const String eightPercent = 'vat-eight-percent';
  static const String tenPercent = 'vat-ten-percent';
  static const String notSubject = 'not-subject-to-value-added-tax';
  static const String notDeclare = 'not-declaring-calculating-value-addedtax';
  static const String other = 'vat-other';
  static List<String> vateRate() => [
        zeroPercent,
        fivePercent,
        eightPercent,
        tenPercent,
        notSubject,
        notDeclare,
        other
      ];

  static String getStringVat(int vat) {
    switch (vat) {
      case 0:
        return zeroPercent;
      case 5:
        return fivePercent;
      case 8:
        return eightPercent;
      case 10:
        return tenPercent;
      case -1:
        return notSubject;
      case -2:
        return notDeclare;
    }
    return other;
  }
}
