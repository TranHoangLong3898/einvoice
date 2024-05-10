import 'package:flutter/material.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../manager/generalmanager.dart';
import '../util/designmanagement.dart';

class BookingStatus {
  static const checkin = 1;
  static const checkout = 2;
  static const booked = 0;
  static const cancel = -1;
  static const noshow = -2;
  static const repair = 3;
  static const moved = 4;
  static const unconfirmed = 5;

  final statusColors = {
    booked: GeneralManager.hotel!.colors!.isEmpty
        ? ColorManagement.bookedBooking
        : Color(GeneralManager.hotel!.colors!['book']['main']),
    checkin: GeneralManager.hotel!.colors!.isEmpty
        ? ColorManagement.checkinBooking
        : Color(GeneralManager.hotel!.colors!['in']['main']),
    checkout: GeneralManager.hotel!.colors!.isEmpty
        ? ColorManagement.checkoutBooking
        : Color(GeneralManager.hotel!.colors!['out']['main']),
    unconfirmed: GeneralManager.hotel!.colors?['unconfirmed'] == null
        ? ColorManagement.bookingUnconfirmed
        : Color(GeneralManager.hotel!.colors!['unconfirmed']['main']),
    cancel: Colors.black,
    noshow: Colors.black,
    repair: ColorManagement.repairedBooking,
    moved: ColorManagement.movedBooking
  };

  static const statusNames = {
    booked: "booked",
    checkin: "in",
    checkout: "out",
    cancel: "cancelled",
    repair: 'repair',
    noshow: 'noshow',
    unconfirmed: "unconfirmed",
    moved: 'moved',
  };

  Color? getColorByStatus(int status) {
    try {
      return statusColors[status];
    } catch (e) {
      return Colors.black;
    }
  }

  static Color getBedNameColorByStatus(int? status) {
    switch (status) {
      case 2:
        return Colors.green;
      case 1:
        return const Color.fromARGB(255, 184, 187, 43);
    }
    return ColorManagement.redColor;
  }

  static Color getBookingDialogIndicatorColor(int status) {
    switch (status) {
      case checkin:
        return ColorManagement.greenColor;
      case checkout:
        return ColorManagement.orangeColor;
    }
    return ColorManagement.blueColor;
  }

  static Color getBookingNameColorByStatus(int status) {
    switch (status) {
      case checkin:
        return GeneralManager.hotel!.colors!.isEmpty
            ? ColorManagement.bookingNameOfCheckinBooking
            : Color(GeneralManager.hotel!.colors!['in']['text']);
      case checkout:
        return GeneralManager.hotel!.colors!.isEmpty
            ? ColorManagement.bookingNameOfCheckoutBooking
            : Color(GeneralManager.hotel!.colors!['out']['text']);
      case booked:
        return GeneralManager.hotel!.colors!.isEmpty
            ? ColorManagement.bookingNameOfBookedBooking
            : Color(GeneralManager.hotel!.colors!['book']['text']);
      case moved:
        return ColorManagement.bookingNameOfMovedBooking;
      case repair:
        return ColorManagement.bookingNameOfRepairedBooking;
    }
    return Colors.black87;
  }

  static String? getStatusString(int status) {
    return statusNames[status];
  }

  static List<String> getStatusNames() => statusNames.values.toList();

  static int getStatusIDByName(String name) => statusNames.keys.firstWhere(
      (id) => UITitleUtil.getTitleByCode(statusNames[id]!) == name,
      orElse: () => 0);

  static String? getStatusNameByID(int id) => statusNames[id];
}

class BikeRentalProgress {
  static const checkin = 1;
  static const checkout = 2;
  static const booked = 0;

  static final statusColors = {
    booked: ColorManagement.blueColor,
    checkin: ColorManagement.greenColor,
    checkout: ColorManagement.orangeColor,
  };

  static final statusStrings = {
    booked: MessageUtil.getMessageByCode(MessageCodeUtil.BIKE_PROGRESS_BOOKED),
    checkin: MessageUtil.getMessageByCode(MessageCodeUtil.BIKE_PROGRESS_IN),
    checkout: MessageUtil.getMessageByCode(MessageCodeUtil.BIKE_PROGRESS_OUT),
  };

  static Color? getColorByStatus(int status) {
    try {
      return statusColors[status];
    } catch (e) {
      return Colors.black;
    }
  }

  static Color? getColorByStatusString(String status) {
    try {
      return statusColors[getProgressByString(status)];
    } catch (e) {
      return Colors.black;
    }
  }

  static int getProgressByString(String status) => statusStrings.keys
      .firstWhere((element) => statusStrings[element] == status);

  static String? getStatusString(int status) => statusStrings[status];

  List<String?> getNextProgressString(int currentStatus) {
    if (currentStatus == booked) {
      return [statusStrings[booked], statusStrings[checkin]];
    } else if (currentStatus == checkin) {
      return [statusStrings[checkin], statusStrings[checkout]];
    } else {
      return [statusStrings[checkout]];
    }
  }
}

class HotelPackage {
  static const String BASIC = "basic";
  static const String ADVANCED = "adv";
  static const String PRO = "pro";
}

class ItemType {
  static const String minibar = "minibar";
  static const String restaurant = "restaurant";
  static const String other = "other";
}

class RoomSortType {
  static const int name = 0;
  static const int status = 1;
  static const int roomType = 2;
}

class TypeTourists {
  static const String domestic = 'domestic';
  static const String foreign = 'foreign';
  static const String unknown = '';
}

class TypeNameSource {
  static const String name = '0';
  static const String nameSource = '1';
  static const String sourceName = '2';
}

class CostType {
  static const int accounting = 0;
  static const int booked = 1;
  static const int room = 2;
}

class SizeOfFrontDesk {
  static const String seven = "7";
  static const String fifteen = "15";
  static const String thirty = "30";
}

class PackageVersio {
  static const int free = 0;
  static const int almostExpired = 1;
  static const int expired = 2;
  static const int almostExpiredFree = 3;
  static const int expiredFree = 4;
}

class BookingType {
  static const int dayly = 0;
  static const int monthly = 1;
  static const int hourly = 2;
}


class BookingInOutByHour {
  static const int defaul = 0;
  static const int monthly = 1;
}
