class Tax {
  double? serviceFee;
  double? vat;

  Tax.empty() {
    serviceFee = 0;
    vat = 0;
  }

  Tax(this.serviceFee, this.vat);

  getFromJsonDocument(dynamic doc) {
    serviceFee = doc['service_fee'] ?? 0;
    vat = doc['vat'] ?? 0;
  }
}
