import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihotel/controller/currentbookingcontroller.dart';
import 'package:ihotel/enum.dart';
import 'package:ihotel/ui/component/admin/bookingsource/sourcemanagementdialog.dart';
import 'package:ihotel/ui/component/admin/paymentmethod/paymentmethoddialog.dart';
import 'package:ihotel/ui/component/admin/packagevesion/packagevesiondialog.dart';
import 'package:ihotel/ui/component/admin/paymentpackage/paymentpackagedialog.dart';
import 'package:ihotel/ui/component/autoratepricedialog.dart';
import 'package:ihotel/ui/component/dashboard/dashboard_page.dart';
import 'package:ihotel/ui/component/einvoice/einvoicemanagementdialog.dart';
import 'package:ihotel/ui/component/hotel/addhoteldialog.dart';
import 'package:ihotel/ui/component/hotel/linked_restaurant_dialog.dart';
import 'package:ihotel/ui/component/hotel/rateplandialog.dart';
import 'package:ihotel/ui/component/hotel/roomtypedialog.dart';
import 'package:ihotel/ui/component/hotel/taxdialog.dart';
import 'package:ihotel/ui/component/hourinoutboookingdialog.dart';
import 'package:ihotel/ui/component/management/accounting/accountingmanagementdialog.dart';
import 'package:ihotel/ui/component/management/accounting/actualexpensesmanagementdialog.dart';
import 'package:ihotel/ui/component/management/deposit/depositmanagementdialog.dart';
import 'package:ihotel/ui/component/management/membermanagement/listusersdialog.dart';
import 'package:ihotel/ui/component/management/membermanagement/updateuserdialog.dart';
import 'package:ihotel/ui/component/management/revenue_management/revenue_management_dialog.dart';
import 'package:ihotel/ui/component/management/statistic/statistic_dialog.dart';
import 'package:ihotel/ui/component/policydialog.dart';
import 'package:ihotel/ui/component/report/revenuebyroomreport.dart';
import 'package:ihotel/ui/component/service/hotelservice/hotelservicedialog.dart';
import 'package:ihotel/ui/component/size_config_dialog.dart';
import 'package:ihotel/ui/component/staydeclaration/listguestdeclarationdialog.dart';
import 'package:ihotel/ui/controls/neutrontextcontent.dart';
import 'package:ihotel/util/uimultilanguageutil.dart';
import '../../controller/report/bookinglistcontroller.dart';
import '../../manager/generalmanager.dart';
import '../../manager/usermanager.dart';
import '../../ui/component/channelmanagerdialog.dart';
import '../../ui/component/extraservice/virtualbookingmanagementdialog.dart';
import '../../ui/component/management/servicemanagementdialog.dart';
import '../../ui/component/management/suppliermanagementdialog.dart';
import '../../ui/component/report/bookinglistdialog.dart';
import '../../util/designmanagement.dart';
import '../component/admin/hotelstatistics/hotelstatisticdialog.dart';
import '../component/autoroomassignmentdialog.dart';
import '../component/displaynamsourcebookingdialog.dart';
import '../component/hotel/colorconfigdialog.dart';
import '../component/item/listitemdialog.dart';
import '../component/management/accounting/financialdatedialog.dart';
import '../component/management/bikemanagerment/bikerentaldialog.dart';
import '../component/management/paymentmanagementdialog.dart';
import '../component/management/receptioncashmanagementdialog.dart';
import '../component/management/report/bookingreportmanager.dart';
import '../component/management/report/bookingtodayreportmanager.dart';
import '../component/management/report/breakfastreportmanagement.dart';
import '../component/management/report/minibareportmanagerment.dart';
import '../component/management/report/revenuebysalermanager.dart';
import '../component/management/report/servicebysalermanager.dart';
import '../component/report/bookingcanapprooverdialog.dart';
import '../component/report/bookingofcreatordialog.dart';
import '../component/service/hotelservice/listsupplierdialog.dart';
import '../component/unconfirmdialog.dart';
import '../component/warehouse/warehouseconfigdialog.dart';
import 'housekeepingpage.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorManagement.mainBackground,
      child: ListView(
        controller: ScrollController(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          //Avatar
          DrawerHeader(
            child: Center(
              child: CircleAvatar(
                backgroundColor: ColorManagement.lightMainBackground,
                radius: SizeManagement.avatarCircle,
                backgroundImage: GeneralManager.hotelImage == null
                    ? null
                    : MemoryImage(GeneralManager.hotelImage!),
              ),
            ),
          ),
          //multi-language
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  if (GeneralManager.locale!.toLanguageTag() == 'en') return;
                  Navigator.pop(context);
                  GeneralManager().setLocale('en');
                },
                child: const NeutronTextContent(
                  message: 'EN',
                ),
              ),
              const SizedBox(
                width: 5,
                child: NeutronTextContent(message: '|'),
              ),
              TextButton(
                onPressed: () {
                  if (GeneralManager.locale!.toLanguageTag() == 'vi') return;
                  Navigator.pop(context);
                  GeneralManager().setLocale('vi');
                },
                child: const NeutronTextContent(
                  message: 'VI',
                ),
              ),
            ],
          ),
          //Version
          ListTile(
              leading: const Icon(Icons.book, color: Colors.white),
              title: Text(
                '${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_VERSION)} ${GeneralManager.version}',
              )),
          _buildDivider(),
          //Danh sách các options của Sidebar

          //dashboard
          if (UserManager.canSeeBoard())
            ExpansionTile(
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_BOARD),
                style: const TextStyle(color: ColorManagement.white),
              ),
              backgroundColor: ColorManagement.lightMainBackground,
              children: [
                if (UserManager.canSeeDashboard())
                  ListTile(
                    textColor: ColorManagement.lightColorText,
                    leading: const Icon(Icons.dashboard, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_DASHBOARD),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => const DashboardPage(),
                      );
                    },
                  ),
                ListTile(
                  textColor: ColorManagement.lightColorText,
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_FRONT_DESK),
                  ),
                  onTap: () async {
                    Navigator.popUntil(context, ModalRoute.withName('main'));
                  },
                ),
                if (UserManager.canSeeHouseKeepingPage())
                  ListTile(
                    textColor: ColorManagement.lightColorText,
                    leading: const Icon(FontAwesomeIcons.broom,
                        color: Colors.white, size: 20.0),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_HOUSEKEEPING),
                    ),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HousekeepingPage()));
                    },
                  ),
              ],
            ),
          _buildDivider(),

          //todayBookings
          if (UserManager.canSeeStatusPage())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_TODAY_BOOKINGS),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                if (UserManager.canSeeBookingList())
                  ListTile(
                    leading: const Icon(Icons.flight_land, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_CHECKING_IN_TODAY),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => const BookingListDialog(
                            type: BookingListType.inToday),
                      );
                    },
                  ),
                if (UserManager.canSeeBookingList())
                  ListTile(
                    leading:
                        const Icon(Icons.flight_takeoff, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_CHECKING_OUT_TODAY),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => const BookingListDialog(
                            type: BookingListType.outToday),
                      );
                    },
                  ),
                if (UserManager.canSeeBookingList())
                  ListTile(
                    leading: const Icon(
                      Icons.hotel,
                      color: Colors.white,
                    ),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_STAYING_TODAY),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => const BookingListDialog(
                            type: BookingListType.stayToday),
                      );
                    },
                  ),
                if (UserManager.canSeeBookingList())
                  ListTile(
                    leading: const Icon(Icons.domain_verification_sharp,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_BOOKING_BY_DATE),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const BookingToDayReportManagerment());
                    },
                  ),
                if (UserManager.canSeeBookingConfirm())
                  ListTile(
                    leading: const Icon(Icons.app_registration_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.DASHBOARD_BOOKING_PENDING_APPROVAL),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const BookingCanApproverDialog());
                    },
                  ),
                ListTile(
                  leading:
                      const Icon(Icons.list_alt_rounded, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.DASHBOARD_MY_BOOKING),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => BookingOfCreatorDialog());
                  },
                ),
              ],
            ),
          _buildDivider(),

          // inCompletedBookings
          if (UserManager.canSeeStatusPageNotPartnerAndApprover())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(
                    UITitleCode.SIDEBAR_UNCOMPLETED_BOOKINGS),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                if (UserManager.canSeeNonRoomBookings())
                  ListTile(
                    leading: const Icon(Icons.cancel_presentation,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_NON_ROOM_BOOKINGS),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const BookingListDialog(
                              type: BookingListType.nonRoom));
                    },
                  ),
                if (UserManager.canSeeNonSourceBookings())
                  ListTile(
                    leading:
                        const Icon(Icons.gps_off_outlined, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_NON_SOURCE_BOOKINGS),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const BookingListDialog(
                              type: BookingListType.nonSource));
                    },
                  ),
              ],
            ),
          _buildDivider(),

          //virtualBooking
          if (UserManager.canSeeStatusPageNotPartnerAndApprover())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(
                    UITitleCode.SIDEBAR_VIRTUAL_BOOKINGS),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                if (UserManager.canManageExtraServices())
                  ListTile(
                    leading: const Icon(Icons.miscellaneous_services,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_VIRTUAL_BOOKINGS),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const VirtualBookingManagementDialog());
                    },
                  ),
              ],
            ),
          _buildDivider(),

          //management
          if (UserManager.canSeeSidebarManagement())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MANAGEMENT),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                if (UserManager.canSeeStaffManagement())
                  ListTile(
                    leading: const Icon(Icons.group, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_LIST_MEMBER),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => const ListUsersDialog(),
                      );
                    },
                  ),
                if (UserManager.canSeeCashFlow())
                  ListTile(
                    leading:
                        const Icon(Icons.attach_money, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const PaymentManagementDialog());
                    },
                  ),
                if (UserManager.canSeeDeposit())
                  ListTile(
                    leading: const Icon(Icons.currency_exchange,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_DEPOSIT_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const DepositManagementDialog());
                    },
                  ),
                if (UserManager.canReviewServices())
                  ListTile(
                    leading: const Icon(Icons.fact_check, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SERVICE_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const ServiceManagementDialog());
                    },
                  ),
                if (UserManager.canSeeBikeRentalReport())
                  ListTile(
                    leading: const Icon(Icons.motorcycle, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_BIKE_RENTAL_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const BikeRentalDialog());
                    },
                  ),
                if (UserManager.canSeeSupplierReport())
                  ListTile(
                    leading: const Icon(Icons.house, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SUPPLIER_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const SupplierManagementDialog());
                    },
                  ),
                if (UserManager.canSeeSupplierReport())
                  ListTile(
                    leading: const Icon(Icons.contact_phone_sharp,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SUPPLIER_SERVICE_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const ListSupplierDialog());
                    },
                  ),
                if (UserManager.canSeeCashLogs())
                  ListTile(
                    leading: const Icon(Icons.money, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_RECEPTION_CASH_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const ReceptionCashManagementDialog());
                    },
                  ),
                if (UserManager.canSeeStatistic())
                  ListTile(
                    leading: const Icon(Icons.bar_chart, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_STATISTIC),
                    ),
                    onTap: () async {
                      Navigator.popUntil(context, ModalRoute.withName('main'));
                      showDialog(
                          context: context,
                          builder: (context) => const StatisticDialog());
                    },
                  ),
                //channel manager
                if (UserManager.canManageChannels())
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_CHANNEL_MANAGER),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const ChannelManagerDialog());
                    },
                  ),
                //guest
                if (UserManager.canManageGuest())
                  ListTile(
                    leading: const Icon(Icons.person_pin_circle_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_GUEST),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const ListGuestDeclarationDialog());
                    },
                  ),
                //Ware house
                if (GeneralManager.hotel!.isAdvPackage() &
                    UserManager.canSeeWareHouseManagement())
                  ListTile(
                    leading: const Icon(Icons.warehouse, color: Colors.white),
                    title: Text(UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_WAREHOUSE_MANAGEMENT)),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const WarehouseConfigDialog());
                    },
                  ),
              ],
            ),
          _buildDivider(),

          //report
          if (UserManager.canSeeReportManagement())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_REPORT),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                if (UserManager.canSeeMeals())
                  ListTile(
                    leading:
                        const Icon(Icons.breakfast_dining, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_MEALS),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const ReportBreakfastManagementDialog(),
                      );
                    },
                  ),
                if (UserManager.canSeeMinibarReporManagert())
                  ListTile(
                    leading:
                        const Icon(Icons.microwave_sharp, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_MINIBAR_SERVICE),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const MinibarReporManagertDialog());
                    },
                  ),
                if (UserManager.canSeeRevenueBySalerManager())
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_REVENUE_BY_SALER),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const RevenueBySalerManagerDialog());
                    },
                  ),
                if (UserManager.canSeeServiceBySalerManager())
                  ListTile(
                    leading: const Icon(Icons.chrome_reader_mode_sharp,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SERVICE_BY_SALER),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const ServiceBySalerManagerDialog());
                    },
                  ),
                if (UserManager.canSeeBookingReport())
                  ListTile(
                    leading: const Icon(Icons.view_list, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_DETAILS_BOOKING),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const BookingReportDialog());
                    },
                  ),
                if (UserManager.canSeeBookingReport())
                  ListTile(
                    leading: const Icon(Icons.meeting_room_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.POPUPMENU_REVENUE_BY_ROOM_REPORT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext ctx) {
                          return const RevenueByRoomReportDialog();
                        },
                      );
                    },
                  ),
              ],
            ),

          _buildDivider(),
          // accounting
          if (UserManager.canSeeAccounting() &&
              GeneralManager.hotel!.isProPackage())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNTING),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.TABLEHEADER_ACCOUNTING),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) =>
                            const AccountingManagementDialog());
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.payment_rounded, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_PAYMENT),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) =>
                            const ActualExpenseManagementDialog());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.balance_sharp, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNT),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => const RevenueManagementDialog());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range_outlined,
                      color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_FINANCIAL_DATE),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => const FinancialDateDialog());
                  },
                ),
              ],
            ),
          _buildDivider(),

          //configuration
          if (UserManager.canSeeConfiguration())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_CONFIGURATION),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                //on-off
                if (GeneralManager.hotel!.isProPackage() &
                    UserManager.canFilterBookingByTaxDeclare())
                  ListTile(
                    leading: Icon(
                        GeneralManager.isFilterTaxDeclare
                            ? Icons.toggle_on
                            : Icons.toggle_off_outlined,
                        color: Colors.white),
                    title: Text(
                      '${UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_FILTER)}: ${UITitleUtil.getTitleByCode(GeneralManager.isFilterTaxDeclare ? UITitleCode.TOOLTIP_ON : UITitleCode.TOOLTIP_OFF)}',
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      CurrentBookingsController().toggleFilterBooking();
                    },
                  ),
                if (UserManager.canSeeRoomTypeInConfiguration())
                  //roomtype
                  ListTile(
                    leading:
                        const Icon(Icons.bedroom_parent, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_ROOMTYPE_ROOM),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => RoomTypeDialog());
                    },
                  ),
                if (UserManager.canSeeRestautantInConfiguration())
                  //restautant
                  ListTile(
                    leading: const Icon(Icons.add_link_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_RESTAURANT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const LinkedRestaurantDialog());
                    },
                  ),
                if (UserManager.canSeeRatePlanInConfiguration())
                  //rate plan
                  ListTile(
                    leading:
                        const Icon(Icons.price_change, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_RATE_PLAN),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => RatePlanDialog());
                    },
                  ),
                if (UserManager.canSeeItemInConfiguration())
                  //item
                  ListTile(
                    leading: const Icon(Icons.emoji_food_beverage_outlined,
                        color: Colors.white),
                    title: Text(
                        UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ITEM)),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const ListItemDialog());
                    },
                  ),
                if (UserManager.canSeeServiceInConfiguration())
                  //service
                  ListTile(
                    leading: const Icon(Icons.fact_check, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SERVICE),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const HotelServiceDialog());
                    },
                  ),
                if (UserManager.canSeeTaxInConfiguration())
                  //tax
                  ListTile(
                    leading: const Icon(Icons.title, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_TAX),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const TaxDialog());
                    },
                  ),
                //source
                if (UserManager.canSeeSourceInConfiguration())
                  ListTile(
                    leading: const Icon(Icons.device_hub, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SOURCE_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const SourceManagementDialog());
                    },
                  ),
                if (UserManager.canSeePaymentInConfiguration())
                  ListTile(
                    leading: const Icon(Icons.monetization_on_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_PAYMENT_MANAGEMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const PaymentMethodDialog());
                    },
                  ),
                if (UserManager.canSeeHotelInConfiguration())
                  //hotel
                  ListTile(
                    leading:
                        const Icon(Icons.location_city, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_HOTEL),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => AddHotelDialog(
                                hotel: GeneralManager.hotel!,
                              ));
                    },
                  ),
                if (UserManager.canSeeColorInConInfiguration())
                  //color
                  ListTile(
                    leading: const Icon(Icons.color_lens_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_COLOR),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const ColorConfigDialog());
                    },
                  ),
                if (UserManager.canSeeSizeInConInfiguration())
                  //size
                  ListTile(
                    leading: const Icon(Icons.photo_size_select_small_rounded,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SIZE),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const SizeConfigDialog());
                    },
                  ),
                if (UserManager.canSeeDisplaynBookingInConInfiguration())
                  //size
                  ListTile(
                    leading:
                        const Icon(Icons.display_settings, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_BOOKING_NAME),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const DisplayNameSourceBookingDialog());
                    },
                  ),
                if (UserManager.canSeePolicyInConInfiguration())
                  //polyci
                  ListTile(
                    leading: const Icon(Icons.policy, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_POLICY),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const PolicyDialog());
                    },
                  ),
                if (UserManager.canSeeAutoRoomAssignment())
                  //Auto Room Assignment
                  ListTile(
                    leading: const Icon(Icons.auto_stories_outlined,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_AUTO_ROOM_ASSIGNMENT),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const AutoRoomAssignmentDialog());
                    },
                  ),
                if (UserManager.canSeeUnconfirmed())
                  //Auto Room Assignment
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_motion,
                        color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_STATUS_UNCONFIRM),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const UnconfiromDialog());
                    },
                  ),

                if (UserManager.canSeeAutoRate())
                  //Auto Room Assignment
                  ListTile(
                    leading:
                        const Icon(Icons.auto_awesome, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_SYNC_RATE_TO_CMS),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) => const AutoRatePriceDialog());
                    },
                  ),
                if (UserManager.canSeeHourInOutBookingMonth())
                  //HourIn-Out OF Booking
                  ListTile(
                    leading:
                        const Icon(Icons.hourglass_bottom, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_HOUR_IN_OUT_BOOKING_MONTHLY),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const HourInOutBookingMonthlyDialog());
                    },
                  ),
                //Electronic invoice
                if (UserManager.canSeeEectronicInvoice())
                  ListTile(
                    leading:
                        const Icon(Icons.receipt_rounded, color: Colors.white),
                    title: Text(
                      UITitleUtil.getTitleByCode(
                          UITitleCode.SIDEBAR_ELECTRONIC_INVOICE),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const ElectronicInvoiceManagementDialog());
                    },
                  ),
              ],
            ),
          _buildDivider(),

          //admin
          if (UserManager.canEditPaymentMethod())
            ExpansionTile(
              backgroundColor: ColorManagement.lightMainBackground,
              collapsedIconColor: ColorManagement.trailingIconColor,
              iconColor: ColorManagement.trailingIconColor,
              title: Text(
                UITitleUtil.getTitleByCode(
                    UITitleCode.SIDEBAR_ADMIN_MANAGEMENT),
                style: const TextStyle(color: ColorManagement.white),
              ),
              children: [
                // ListTile(
                //   leading: const Icon(Icons.directions_railway_filled_rounded,
                //       color: Colors.white),
                //   title: Text(
                //     UITitleUtil.getTitleByCode(
                //         UITitleCode.SIDEBAR_ASYNC_DAILYDATA),
                //   ),
                //   onTap: () async {
                //     Navigator.pop(context);
                //     showDialog(
                //         context: context,
                //         builder: (context) => const DailyStayDatesDialog());
                //   },
                // ),
                ListTile(
                  leading:
                      const Icon(Icons.stacked_line_chart, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_HOTEL_STATISTICS),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => HotelStatisticDialog());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_list, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_PACKAGES),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => const PackageVersionDialog());
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.payment_rounded, color: Colors.white),
                  title: Text(
                    UITitleUtil.getTitleByCode(
                        UITitleCode.SIDEBAR_PAYMENT_PACKAGES),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => const PaymentPackageDialog());
                  },
                ),
              ],
            ),
          _buildDivider(),

          //account
          ExpansionTile(
            backgroundColor: ColorManagement.lightMainBackground,
            collapsedIconColor: ColorManagement.trailingIconColor,
            iconColor: ColorManagement.trailingIconColor,
            title: Text(
              UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_ACCOUNT),
              style: const TextStyle(color: ColorManagement.white),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: Text(
                  UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_USER_PROFILE),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => UpdateUserDialog(
                      userHotel: UserManager.user!,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_city, color: Colors.white),
                title: Text(
                  UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SWITCH_HOTEL),
                ),
                onTap: () {
                  GeneralManager.policyHotel = null;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: Text(
                  UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_SIGNOUT),
                ),
                onTap: () async {
                  await GeneralManager.signOut(context);
                },
              ),
            ],
          ),
          _buildDivider(),

          //customer support
          ExpansionTile(
            backgroundColor: ColorManagement.lightMainBackground,
            collapsedIconColor: ColorManagement.trailingIconColor,
            iconColor: ColorManagement.trailingIconColor,
            title: Text(
              UITitleUtil.getTitleByCode(UITitleCode.SIDEBAR_CUSTOMMER_SUPPORT),
              style: const TextStyle(color: ColorManagement.white),
            ),
            children: [
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.facebook,
                  color: Colors.blue.shade400,
                  size: 25,
                ),
                title: const Text('Facebook'),
                onTap: () =>
                    GeneralManager.openSupportGroup(SupportGroupType.facebook),
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.telegram,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text('Telegram'),
                onTap: () =>
                    GeneralManager.openSupportGroup(SupportGroupType.telegram),
              ),
              ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  height: 23.5,
                  width: 25,
                  padding: const EdgeInsets.all(0),
                  margin: const EdgeInsets.all(0),
                  child: Image.asset(
                    'assets/icon/zalo.png',
                    color: Colors.blue.shade400,
                  ),
                ),
                title: const Text('Zalo'),
                onTap: () =>
                    GeneralManager.openSupportGroup(SupportGroupType.zalo),
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.youtube,
                  color: ColorManagement.redColor,
                  size: 25,
                ),
                title: const Text('YouTube'),
                onTap: () =>
                    GeneralManager.openSupportGroup(SupportGroupType.youtube),
              ),
            ],
          ),
          //exit
          if (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)
            ListTile(
              trailing: const Icon(
                Icons.exit_to_app_rounded,
                color: Colors.white,
                size: 25,
              ),
              title: const Text('Exit'),
              onTap: () {
                exit(0);
              },
            ),
        ],
      ),
    );
  }

  Divider _buildDivider() {
    return const Divider(
      color: Color.fromARGB(255, 75, 77, 82),
      height: 0.5,
      thickness: 0.1,
    );
  }
}
