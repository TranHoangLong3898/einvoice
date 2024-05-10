import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/modal/hoteluser.dart';

import '../manager/roles.dart';

class UserManager {
  UserManager._();

  static List<String>? role;
  static HotelUser? user;

  static void reset() {
    user = null;
    role = null;
  }

  static Future<HotelUser> getSystemUserById(String uid) async {
    HotelUser user = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return HotelUser.fromSnapshot(value.docs.first);
      } else {
        return HotelUser.empty(uid);
      }
    }).catchError((error, stackTrace) {
      return HotelUser.empty(uid);
    });
    return user;
  }

  static bool canGrantRoleForOtherUser(List<String>? otherUserRole) {
    otherUserRole ??= [];
    //otherUserRole is current role of other user
    //role is current role of current user, who is logging in software
    if (role!.contains(Roles.admin) && otherUserRole.contains(Roles.admin)) {
      return false;
    }
    if (role!.contains(Roles.owner) &&
        (otherUserRole.contains(Roles.admin) ||
            otherUserRole.contains(Roles.owner))) {
      return false;
    }
    if (role!.contains(Roles.manager) &&
        (otherUserRole.contains(Roles.admin) ||
            otherUserRole.contains(Roles.owner) ||
            otherUserRole.contains(Roles.manager))) {
      return false;
    }
    return true;
  }

  static bool canSeeConfiguration() =>
      canSeeRoomTypeInConfiguration() ||
      canSeeRestautantInConfiguration() ||
      canSeeRatePlanInConfiguration() ||
      canSeeItemInConfiguration() ||
      canSeeServiceInConfiguration() ||
      canSeeTaxInConfiguration() ||
      canSeeHotelInConfiguration() ||
      canSeeColorInConInfiguration() ||
      canSeeSizeInConInfiguration() ||
      canSeeSourceInConfiguration() ||
      canSeePaymentInConfiguration();

  static bool isManagementRole() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner);

  static bool canSeeRoomTypeInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.internalPartner);

  static bool canSeeRestautantInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeRatePlanInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeItemInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant);

  static bool canSeeServiceInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant);

  static bool canSeeTaxInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeHotelInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeColorInConInfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeSizeInConInfiguration() => true;

  static bool canSeePolicyInConInfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.receptionist);

  static bool canSeeDisplaynBookingInConInfiguration() => true;

  static bool canSeeAutoRoomAssignment() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeUnconfirmed() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeAutoRate() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeHourInOutBookingMonth() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeEectronicInvoice() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.eInvoiceManager) ||
      role!.contains(Roles.owner);

  static bool canSeeStaffManagement() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeBookingList() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canReviewServices() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.housekeeping);

  static bool canSeeCashFlow() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canSeeDeposit() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale);

  static bool canSeeDashboard() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.owner);

  static bool canSeeBoard() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.housekeeping) ||
      role!.contains(Roles.maintainer) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.guard) ||
      role!.contains(Roles.partner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.approver);

  static bool canSeeAccounting() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant);

  static bool canSeeStatistic() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.housekeeping);

  static bool canSeeStatisticForHousekeeping() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canSeeSupplierReport() =>
      role!.contains(Roles.owner) ||
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant);

  static bool canSeeBikeRentalReport() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canSeeNonSourceBookings() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canSeeNonRoomBookings() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canManageChannels() =>
      role!.contains(Roles.owner) ||
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.sale);

  static bool canManageGuest() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale);

  static bool canSeeStatusPage() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.partner) ||
      role!.contains(Roles.approver) ||
      role!.contains(Roles.internalPartner);

  static bool canSeeCashLogs() =>
      role!.contains(Roles.owner) ||
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist);

  static bool canSeeHouseKeepingPage() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.housekeeping) ||
      role!.contains(Roles.maintainer) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.guard);

  static bool canManageExtraServices() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant);

  static bool canSeeSourceInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.sale);

  static bool canSeePaymentInConfiguration() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner);

  static bool canSeeSidebarManagement() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.warehouseManager) ||
      role!.contains(Roles.housekeeping);

  static bool canEditPaymentMethod() => role!.contains(Roles.admin);

  static bool canFilterBookingByTaxDeclare() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist);

  static bool canSeeWareHouseManagement() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.warehouseManager) ||
      role!.contains(Roles.accountant);

  static bool canCRUDWarehouseNote() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner);

  static bool canSeeReportManagement() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.housekeeping);

  static bool canSeeMeals() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner);

  static bool canSeeMinibarReporManagert() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.housekeeping);

  static bool canSeeRevenueBySalerManager() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner);

  static bool canSeeServiceBySalerManager() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner);

  static bool canSeeBookingReport() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.owner);

  static bool canSeeBookingConfirm() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.approver) ||
      role!.contains(Roles.owner);

  static bool canSeeStatusPageNotPartnerAndApprover() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale) ||
      role!.contains(Roles.internalPartner);

  static bool canSeeStatusPageNotPartnerAndApproverWithinternalPartner() =>
      role!.contains(Roles.admin) ||
      role!.contains(Roles.manager) ||
      role!.contains(Roles.support) ||
      role!.contains(Roles.owner) ||
      role!.contains(Roles.accountant) ||
      role!.contains(Roles.receptionist) ||
      role!.contains(Roles.sale);

  static bool isInternalPartner() => role!.contains(Roles.internalPartner);

  static bool isPartnerAddBookingShowBooking() =>
      (role!.contains(Roles.partner) ||
          role!.contains(Roles.internalPartner)) &&
      !(role!.contains(Roles.admin) ||
          role!.contains(Roles.manager) ||
          role!.contains(Roles.support) ||
          role!.contains(Roles.owner) ||
          role!.contains(Roles.receptionist) ||
          role!.contains(Roles.sale));

  static bool isApprover() => role!.contains(Roles.approver);

  static bool isPartnerAndApprover() =>
      role!.contains(Roles.partner) || role!.contains(Roles.approver);

  static bool isAdmin() => user!.id == uidAdmin;

  static get isAdminSystem => user!.isAdminSystem ?? false;

  static bool isBelongSystem() =>
      role!.contains(Roles.admin) || role!.contains(Roles.support);
}
