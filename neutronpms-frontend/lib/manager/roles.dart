import 'package:ihotel/manager/usermanager.dart';

import '../util/messageulti.dart';

class Roles {
  static const admin = 'admin';
  static const none = 'none';
  static const support = 'support';
  static const owner = 'owner';
  static const manager = 'manager';
  static const receptionist = 'receptionist';
  static const housekeeping = 'housekeeping';
  static const sale = 'sale';
  static const accountant = 'accountant';
  static const guard = 'guard';
  static const maintainer = 'maintainer';
  static const partner = 'partner';
  static const approver = 'approver';
  static const internalPartner = 'internal partner';
  static const warehouseManager = 'warehouse manager';
  static const eInvoiceManager = 'e invoice manager';

  static final rolesForAuthorizeInCloud = [
    MessageCodeUtil.JOB_MANAGER,
    MessageCodeUtil.JOB_RECEPTIONIST,
    MessageCodeUtil.JOB_HOUSEKEEPING,
    MessageCodeUtil.JOB_SALE,
    MessageCodeUtil.JOB_ACCOUNTANT,
    MessageCodeUtil.JOB_GUARD,
    MessageCodeUtil.JOB_MAINTAINER,
    MessageCodeUtil.JOB_PARTNER,
    MessageCodeUtil.JOB_APPROVER,
    MessageCodeUtil.JOB_INTERNAL_PARTNER,
    MessageCodeUtil.JOB_WAREHOUSE_MANAGER,
    MessageCodeUtil.JOB_E_INVOICE_MANAGER,
  ];

  static List<String> getRolesForAuthorize() {
    return rolesForAuthorizeInCloud
        .map((e) => MessageUtil.getMessageByCode(e))
        .toList();
  }

  static void updateRolesForAuthorize() {
    if (UserManager.role!.contains(admin) ||
        UserManager.role!.contains(owner) ||
        UserManager.role!.contains(support)) {
      rolesForAuthorizeInCloud.add(MessageCodeUtil.JOB_OWNER);
    }
    if (UserManager.role!.contains(admin)) {
      rolesForAuthorizeInCloud.add(MessageCodeUtil.JOB_ADMIN);
    }
  }
}
