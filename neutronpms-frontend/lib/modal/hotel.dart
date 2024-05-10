import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/modal/status.dart';
import 'package:ihotel/util/autoexportitemsstatus.dart';
import 'package:ihotel/util/cmsutil.dart';

class Hotel {
  bool? isConnectChannel;
  String? id;
  String? name;
  String? phone;
  String? email;
  String? street;
  String? city;
  String? country;
  String? timezone;
  String? currencyCode;
  String? policy;
  Map<String, dynamic>? roles;
  List<dynamic>? users;
  Map<String, dynamic>? colors;
  String? package;
  bool? vacantOvernight;
  String? showNameSource;
  bool? autoRoomAssignment;
  bool? unconfirmed;
  DateTime? financialDate;
  bool? autoRate;
  int? hourBookingMonthly;
  Map<String, dynamic>? packageVersion;
  String? autoExportItems;
  String? propertyid;
  String? cms;
  Map<String, String>? hotelLinkMap;
  Map<String, dynamic>? eInvoiceOptions;
  Hotel(
      {this.id,
      this.name,
      this.phone,
      this.email,
      this.street,
      this.city,
      this.country,
      this.timezone,
      this.currencyCode,
      this.policy,
      this.roles,
      this.users,
      this.colors,
      this.isConnectChannel,
      this.package,
      this.vacantOvernight,
      this.showNameSource,
      this.autoRoomAssignment,
      this.financialDate,
      this.unconfirmed,
      this.autoRate,
      this.hourBookingMonthly,
      this.packageVersion,
      this.cms,
      this.hotelLinkMap,
      this.propertyid,
      this.autoExportItems,
      this.eInvoiceOptions});

  factory Hotel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hotel(
      id: doc.id,
      name: data.containsKey('name') ? doc.get('name') : '',
      phone: data.containsKey('phone') ? doc.get('phone') : '',
      email: data.containsKey('email') ? doc.get('email') : '',
      street: data.containsKey('street') ? doc.get('street') : '',
      city: data.containsKey('city') ? doc.get('city') : '',
      country: data.containsKey('country') ? doc.get('country') : '',
      timezone: data.containsKey('timezone') ? doc.get('timezone') : '',
      currencyCode:
          data.containsKey('currencyCode') ? doc.get('currencyCode') : '',
      policy: data.containsKey('policy') ? doc.get('policy') : '',
      roles: data.containsKey('role') ? doc.get('role') : {},
      users: data.containsKey('users') ? doc.get('users') : [],
      colors: data.containsKey('colors') ? doc.get('colors') : {},
      isConnectChannel: (data.containsKey('mapping_hotel_id') ||
              data.containsKey('property_id'))
          ? true
          : false,
      package:
          data.containsKey('package') ? doc.get('package') : HotelPackage.BASIC,
      vacantOvernight: data.containsKey('vacant_overnight')
          ? doc.get('vacant_overnight')
          : false,
      showNameSource: data.containsKey('name_source')
          ? doc.get('name_source')
          : TypeNameSource.name,
      autoRoomAssignment: data.containsKey('room_assignment')
          ? doc.get('room_assignment')
          : true,
      unconfirmed:
          data.containsKey('unconfirmed') ? doc.get('unconfirmed') : false,
      financialDate: data.containsKey('financial_date')
          ? (doc.get('financial_date') as Timestamp).toDate()
          : DateTime.now(),
      autoRate: data.containsKey('auto_rate') ? doc.get('auto_rate') : true,
      hourBookingMonthly: data.containsKey('hour_booking')
          ? doc.get('hour_booking')
          : BookingInOutByHour.defaul,
      packageVersion:
          data.containsKey('package_version') ? doc.get('package_version') : {},
      autoExportItems: data.containsKey('auto_export_items')
          ? doc.get('auto_export_items')
          : HotelAutoExportItemsStatus.NO,
      propertyid: data.containsKey('property_id') ? doc.get('property_id') : '',
      cms: data.containsKey('cms') ? doc.get('cms') : CmsType.hotelLink,
      hotelLinkMap: data.containsKey('mapping_hotel_id') &&
              data.containsKey('mapping_hotel_key')
          ? {
              'id': doc.get('mapping_hotel_id'),
              'key': doc.get('mapping_hotel_key')
            }
          : {'id': '', 'key': ''},
      eInvoiceOptions:
          data.containsKey('e_invoice') ? doc.get('e_invoice') : {},
    );
  }

  bool isAdvPackage() =>
      package == HotelPackage.ADVANCED || package == HotelPackage.PRO;

  bool isProPackage() => package == HotelPackage.PRO;

  bool isConnectToEInvoiceSoftware() => eInvoiceOptions!.isNotEmpty;

  String get eInvoiceGenerateOption => eInvoiceOptions!['generate_option'];

  String get eInvoiceServiceOption => eInvoiceOptions!['service_option'];
}
