import 'package:flutter/material.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../manager/generalmanager.dart';
import '../manager/usermanager.dart';

class ContextMenuUtil {
  static PopupMenuItem<String> popupMenuItem(
      {String? value, IconData? iconData, String? displayText}) {
    return PopupMenuItem<String>(
      height: 35,
      textStyle: const TextStyle(color: Colors.white),
      value: value,
      child: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
          ),
          Text(' ${UITitleUtil.getTitleByCode(displayText!)}'),
        ],
      ),
    );
  }

  final menuCheckIn = popupMenuItem(
      value: "Check in",
      iconData: Icons.flight_land,
      displayText: UITitleCode.POPUPMENU_CHECKIN);
  final menuOpen = popupMenuItem(
      value: "Open",
      iconData: Icons.visibility,
      displayText: UITitleCode.POPUPMENU_OPEN);
  final menuDeposit = popupMenuItem(
      value: "Deposit",
      iconData: Icons.attach_money,
      displayText: UITitleCode.POPUPMENU_PAYMENT);
  final menuService = popupMenuItem(
      value: "Service",
      iconData: Icons.fact_check,
      displayText: UITitleCode.POPUPMENU_SERVICE);
  final menuCost = popupMenuItem(
      value: "Cost",
      iconData: Icons.account_balance_wallet_rounded,
      displayText: UITitleCode.POPUPMENU_COST);
  final menuSummary = popupMenuItem(
      value: "Check out",
      iconData: Icons.view_list,
      displayText: UITitleCode.POPUPMENU_SUMMARY);
  final menuCheckOut = popupMenuItem(
      value: "Check out",
      iconData: Icons.flight_takeoff,
      displayText: UITitleCode.POPUPMENU_CHECKOUT);
  final menuGroup = popupMenuItem(
      value: "Group",
      iconData: Icons.group,
      displayText: UITitleCode.POPUPMENU_GROUP);
  final menuCancel = popupMenuItem(
      value: "Cancel",
      iconData: Icons.cancel,
      displayText: UITitleCode.POPUPMENU_CANCEL);

  final menuNoShow = popupMenuItem(
      value: "No show",
      iconData: Icons.no_accounts_rounded,
      displayText: UITitleCode.POPUPMENU_NO_SHOW);

  final menuAdd = popupMenuItem(
      value: "Add booking",
      iconData: Icons.add,
      displayText: UITitleCode.POPUPMENU_ADD_BOOKING);
  final menuRepair = popupMenuItem(
      value: "Add repair",
      iconData: Icons.home_repair_service,
      displayText: UITitleCode.POPUPMENU_ADD_REPAIR);
  final menuBookingReport = popupMenuItem(
      value: "Booking",
      iconData: Icons.library_books,
      displayText: UITitleCode.POPUPMENU_BOOKING_REPORT);
  final menuCancelBookingReport = popupMenuItem(
      value: "Cancel Booking",
      iconData: Icons.cancel,
      displayText: UITitleCode.POPUPMENU_CANCEL_BOOKING_REPORT);

  final menuNoShowBookingReport = popupMenuItem(
      value: "No Show Booking",
      iconData: Icons.no_accounts_rounded,
      displayText: UITitleCode.POPUPMENU_NO_SHOW_BOOKING_REPORT);

  final menuRevenueReport = popupMenuItem(
      value: "Revenue",
      iconData: Icons.payments,
      displayText: UITitleCode.POPUPMENU_REVENUE_REPORT);
  final menuGuestReport = popupMenuItem(
      value: "Guest",
      iconData: Icons.people_alt_outlined,
      displayText: UITitleCode.POPUPMENU_GUEST_REPORT);
  final menuRevenueByDateReport = popupMenuItem(
      value: "Revenue by date",
      iconData: Icons.remove_red_eye_outlined,
      displayText: UITitleCode.POPUPMENU_REVENUE_BY_DATE_REPORT);

  final menuServiceReport = popupMenuItem(
      value: "Service",
      iconData: Icons.fact_check,
      displayText: UITitleCode.POPUPMENU_SERVICE_REPORT);

  final menuMinibar = popupMenuItem(
      value: "Minibar",
      iconData: Icons.emoji_food_beverage,
      displayText: UITitleCode.POPUPMENU_MINIBAR);
  final menuChangeRoom = popupMenuItem(
      value: "Change room",
      iconData: Icons.arrow_forward,
      displayText: UITitleCode.POPUPMENU_CHANGE_ROOM);
  final menuExTraBed = popupMenuItem(
      value: "Extra bed",
      iconData: Icons.single_bed,
      displayText: UITitleCode.POPUPMENU_EXTRA_BED);
  final menuUndoCheckIn = popupMenuItem(
      value: "Undo check-in",
      iconData: Icons.undo,
      displayText: UITitleCode.POPUPMENU_UNDO_CHECKIN);

  final menuDiscount = popupMenuItem(
      value: "Discount",
      iconData: Icons.money_off,
      displayText: UITitleCode.POPUPMENU_DISCOUNT);

  final menuSetNonRoom = popupMenuItem(
      value: "Set non room",
      iconData: Icons.cancel_presentation,
      displayText: UITitleCode.POPUPMENU_SET_NON_ROOM);

  final menuNotes = popupMenuItem(
      value: "Notes",
      iconData: Icons.note,
      displayText: UITitleCode.POPUPMENU_NOTES);

  final menuDeleteRepair = popupMenuItem(
      value: "Delete repair",
      iconData: Icons.delete,
      displayText: UITitleCode.POPUPMENU_DELETE_REPAIR);

  final editDeposit = popupMenuItem(
      value: "Edit",
      iconData: Icons.edit,
      displayText: UITitleCode.POPUPMENU_EDIT);

  final deleteDeposit = popupMenuItem(
      value: "Delete",
      iconData: Icons.delete,
      displayText: UITitleCode.POPUPMENU_DELETE);

  final menuPrint = popupMenuItem(
      value: "Print",
      iconData: Icons.print,
      displayText: UITitleCode.POPUPMENU_PRINT);

  final menuPrintBooking = popupMenuItem(
      value: "Print booking",
      iconData: Icons.playlist_add_check_circle,
      displayText: UITitleCode.POPUPMENU_PRINT_BOOKING);

  final menuPrintCheckIn = popupMenuItem(
      value: "Print checkin",
      iconData: Icons.local_print_shop_rounded,
      displayText: UITitleCode.POPUPMENU_PRINT_CHECKIN);

  final menuPrintCheckOut = popupMenuItem(
      value: "Print checkout",
      iconData: Icons.local_printshop_outlined,
      displayText: UITitleCode.POPUPMENU_PRINT_CHECKOUT);

  final declare = popupMenuItem(
      value: "Declare",
      iconData: Icons.info_outline,
      displayText: UITitleCode.POPUPMENU_DECLARE);

  final logActivities = popupMenuItem(
      value: "Log activities",
      iconData: Icons.receipt_long_rounded,
      displayText: UITitleCode.POPUPMENU_LOG_BOOKING);

  final confirmBooking = popupMenuItem(
      value: "Confirm booking",
      iconData: Icons.app_registration_sharp,
      displayText: UITitleCode.POPUPMENU_CONFIRM_BOOKING);

  kBookedPartnerContextMenu(bool isGroupParent) =>
      <PopupMenuEntry<String>>[menuOpen, if (isGroupParent) menuGroup];

  kBookedApproverContextMenu(bool isGroupParent) => <PopupMenuEntry<String>>[
        menuOpen,
        confirmBooking,
        if (isGroupParent) menuGroup
      ];

  kRepairContextMenu() => <PopupMenuEntry<String>>[menuOpen, menuDeleteRepair];

  kBookedContextMenu(bool isGroupParent, bool isGroup, bool isStatusPartner) =>
      <PopupMenuEntry<String>>[
        if (!isGroupParent) menuOpen,
        if (!isGroupParent) menuCheckIn,
        menuDeposit,
        menuService,
        if (isStatusPartner) confirmBooking,
        if (!isGroupParent && UserManager.canSeeAccounting()) menuCost,
        if (!isGroup) menuSummary,
        if (!isGroupParent) menuCancel,
        if (!isGroupParent) menuNoShow,
        if (isGroupParent) menuGroup,
        if (!isGroupParent) menuChangeRoom,
        if (!isGroupParent) menuExTraBed,
        if (!isGroup) menuDiscount,
        if (!isGroupParent) menuNotes,
        if (!isGroupParent) menuSetNonRoom,
        if (!isGroupParent) declare,
      ];

  kCheckinContextMenu(bool isGroupParent, bool isGroup) =>
      <PopupMenuEntry<String>>[
        if (!isGroupParent) menuOpen,
        menuDeposit,
        menuService,
        if (!isGroupParent && UserManager.canSeeAccounting()) menuCost,
        if (!isGroup) menuSummary,
        if (!isGroupParent) menuCheckOut,
        if (isGroupParent) menuGroup,
        if (!isGroupParent) menuChangeRoom,
        if (!isGroupParent) menuExTraBed,
        if (!isGroupParent) menuUndoCheckIn,
        if (!isGroup) menuDiscount,
        if (!isGroupParent) menuNotes,
        if (!isGroupParent) declare
      ];

  kCheckoutContextMenu(bool isGroupParent, bool isGroup) =>
      <PopupMenuEntry<String>>[
        if (isGroup) menuOpen,
        menuDeposit,
        menuService,
        if (isGroup && UserManager.canSeeAccounting()) menuCost,
        if (isGroupParent) menuGroup,
        if (!isGroupParent) menuSummary,
        if (!isGroupParent) declare,
        logActivities
      ];

  kSimpleContextMenu(bool isGroup) => <PopupMenuEntry<String>>[
        if (!isGroup) menuOpen,
        if (!isGroup) menuDeposit,
        if (!isGroup) menuService,
        if (isGroup) menuGroup,
        if (!isGroup) menuSummary
      ];

  kBookedVirtualContextMenu() => <PopupMenuEntry<String>>[
        menuOpen,
        menuDeposit,
        menuService,
        menuCheckOut,
        menuDiscount,
        menuCancel
      ];

  kCheckOutVirtualContextMenu() => <PopupMenuEntry<String>>[
        menuOpen,
        menuDeposit,
        menuService,
        menuDiscount,
        menuSummary
      ];

  kCancelContextMenu(bool isGroupParent, bool isGroup) =>
      <PopupMenuEntry<String>>[
        if (!isGroupParent) menuOpen,
        if (isGroupParent && isGroup) menuGroup,
        if (!isGroupParent && UserManager.canSeeAccounting()) menuCost,
        logActivities
      ];

  kEmptyContextMenu() => <PopupMenuEntry<String>>[
        menuAdd,
        if (!UserManager.isPartnerAddBookingShowBooking()) menuRepair
      ];

  kReportContextMenu() => <PopupMenuEntry<String>>[
        menuBookingReport,
        if (GeneralManager.hotel!.isProPackage()) ...[
          menuCancelBookingReport,
          menuNoShowBookingReport,
        ],
        menuRevenueReport,
        menuServiceReport,
        menuGuestReport,
        menuRevenueByDateReport
      ];

  List<PopupMenuEntry<String>> printContextMenu() => <PopupMenuEntry<String>>[
        menuPrintBooking,
        menuPrintCheckIn,
        menuPrintCheckOut
      ];
}
