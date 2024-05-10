import 'package:flutter/cupertino.dart';

class GuestReport {
  DateTime? id;
  num? inhouseCountUnknown;
  num? newGuestCountUnknown;
  num? inhouseCountDomestic;
  num? newGuestCountDomestic;
  num? inhouseCountForeign;
  num? newGuestCountForeign;
  GuestReport({
    @required this.id,
  }) {
    inhouseCountUnknown = 0;
    newGuestCountUnknown = 0;
    inhouseCountDomestic = 0;
    newGuestCountDomestic = 0;
    inhouseCountForeign = 0;
    newGuestCountForeign = 0;
  }

  num getTotalGuestUnknown() => inhouseCountUnknown! + newGuestCountUnknown!;
  num getTotalGuestDomestic() => inhouseCountDomestic! + newGuestCountDomestic!;
  num getTotalGuestForeign() => inhouseCountForeign! + newGuestCountForeign!;
  num getTotalGuest() =>
      getTotalGuestUnknown() + getTotalGuestDomestic() + getTotalGuestForeign();
}
