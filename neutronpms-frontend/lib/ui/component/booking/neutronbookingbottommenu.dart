import 'package:flutter/material.dart';
import 'package:ihotel/manager/generalmanager.dart';
import 'package:ihotel/modal/booking.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/ui/controls/bookingbottommenu.dart';
import 'package:ihotel/util/designmanagement.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';

import '../../../manager/usermanager.dart';

class NeutronBookingBottomMenu extends StatelessWidget {
  final Booking? booking;
  final BuildContext? scaffoldContext;

  const NeutronBookingBottomMenu({Key? key, this.booking, this.scaffoldContext})
      : super(key: key);

  @override
  Container build(BuildContext context) {
    BookingBottomMenu bookingMenu =
        BookingBottomMenu(booking: booking, context: scaffoldContext);
    return Container(
      color: ColorManagement.mainBackground,
      child: GridView.count(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        crossAxisCount: bookingMenu.getCrossAxisCountGridView(),
        childAspectRatio: bookingMenu.getChildAspectRatio(),
        children: <Widget>[
          if (bookingMenu.isAvailableOpen())
            IconButton(
              onPressed: () async => {
                Navigator.pop(context),
                bookingMenu.open(),
              },
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_OPEN),
              icon: Icon(
                Icons.visibility,
                color: ColorManagement.iconMenuEnableColor,
                size: GeneralManager.iconMenuSize,
              ),
            ),
          if (bookingMenu.isAvailabApprover())
            IconButton(
              onPressed: () async => {
                Navigator.pop(context),
                bookingMenu.confirmBooking(),
              },
              tooltip: UITitleUtil.getTitleByCode(
                  UITitleCode.POPUPMENU_CONFIRM_BOOKING),
              icon: Icon(
                Icons.app_registration_sharp,
                color: ColorManagement.iconMenuEnableColor,
                size: GeneralManager.iconMenuSize,
              ),
            ),
          if (UserManager.canSeeStatusPageNotPartnerAndApprover() &&
              (booking!.status != BookingStatus.unconfirmed ||
                  (booking!.status == BookingStatus.unconfirmed &&
                      UserManager.isInternalPartner()))) ...[
            if (bookingMenu.isAvailableCheckin())
              IconButton(
                onPressed: () async =>
                    {Navigator.pop(context), bookingMenu.checkIn()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_CHECKIN),
                icon: Icon(
                  Icons.flight_land,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableCheckout())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.checkOut(booking!)},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_CHECKOUT),
                icon: Icon(
                  Icons.flight_takeoff,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailablePayment())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.payment()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_PAYMENT),
                icon: Icon(
                  Icons.attach_money,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableService())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.service()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_SERVICE),
                icon: Icon(
                  Icons.fact_check,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableCostBooking())
              IconButton(
                onPressed: () => {Navigator.pop(context), bookingMenu.cost()},
                tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_COST),
                icon: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableSummary())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.summary(booking!)},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_SUMMARY),
                icon: Icon(
                  Icons.view_list,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableGroup())
              IconButton(
                onPressed: () => {Navigator.pop(context), bookingMenu.group()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_GROUP),
                icon: Icon(
                  Icons.group,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
          ],
          if (bookingMenu.isAvailableCancel())
            IconButton(
              onPressed: () => {Navigator.pop(context), bookingMenu.cancel()},
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_CANCEL),
              icon: Icon(
                Icons.cancel,
                color: ColorManagement.iconMenuEnableColor,
                size: GeneralManager.iconMenuSize,
              ),
            ),
          if (UserManager.canSeeStatusPageNotPartnerAndApprover()) ...[
            if (bookingMenu.isAvailableNoShow())
              IconButton(
                onPressed: () => {Navigator.pop(context), bookingMenu.noShow()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_NO_SHOW),
                icon: Icon(
                  Icons.no_accounts_rounded,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableChangeRoom())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.changeRoom()},
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.POPUPMENU_CHANGE_ROOM),
                icon: Icon(
                  Icons.arrow_forward,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableExtraBed())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.extraBed()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_EXTRA_BED),
                icon: Icon(
                  Icons.single_bed,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableUndoCheckin())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.undoCheckIn()},
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.POPUPMENU_UNDO_CHECKIN),
                icon: Icon(
                  Icons.undo,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableDiscount())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.discount()},
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_DISCOUNT),
                icon: Icon(
                  Icons.money_off,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableSetNonroom())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.setNonRoom()},
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.POPUPMENU_SET_NON_ROOM),
                icon: Icon(
                  Icons.cancel_presentation,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
          ],
          if (bookingMenu.isAvailableNote())
            IconButton(
              onPressed: () => {Navigator.pop(context), bookingMenu.note()},
              tooltip: UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_NOTES),
              icon: Icon(
                Icons.note,
                color: ColorManagement.iconMenuEnableColor,
                size: GeneralManager.iconMenuSize,
              ),
            ),
          if (UserManager.canSeeStatusPageNotPartnerAndApprover()) ...[
            if (bookingMenu.isAvailableUndoCheckout())
              IconButton(
                onPressed: () =>
                    {Navigator.pop(context), bookingMenu.undoCheckOut()},
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.POPUPMENU_UNDO_CHECKOUT),
                icon: Icon(
                  Icons.undo_outlined,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableDeclareTax())
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  bookingMenu.updateTaxDeclare();
                },
                tooltip:
                    UITitleUtil.getTitleByCode(UITitleCode.POPUPMENU_DECLARE),
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
            if (bookingMenu.isAvailableLogBooking())
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  bookingMenu.getLogBooking();
                },
                tooltip: UITitleUtil.getTitleByCode(
                    UITitleCode.POPUPMENU_LOG_BOOKING),
                icon: Icon(
                  Icons.receipt_long_rounded,
                  color: ColorManagement.iconMenuEnableColor,
                  size: GeneralManager.iconMenuSize,
                ),
              ),
          ]
        ],
      ),
    );
  }
}
