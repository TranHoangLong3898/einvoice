import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ihotel/constants.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/modal/electricitywater.dart';
import 'package:ihotel/modal/service/insiderestaurantservice.dart';
import 'package:ihotel/modal/service/outsiderestaurantservice.dart';
import 'package:ihotel/util/messageulti.dart';
import '../handler/firebasehandler.dart';
import '../manager/accountingtypemanager.dart';
import '../manager/generalmanager.dart';
import '../manager/roles.dart';
import '../manager/roomtypemanager.dart';
import '../manager/servicemanager.dart';
import '../manager/sourcemanager.dart';
import '../manager/usermanager.dart';
import '../modal/service/bikerental.dart';
import '../modal/service/deposit.dart';
import '../modal/service/transfer.dart';
import '../util/dateutil.dart';
import '../util/numberutil.dart';
import 'service/extraguest.dart';
import 'service/extrahour.dart';
import 'service/laundry.dart';
import 'service/minibar.dart';
import 'service/other.dart';
import 'service/service.dart';
import 'status.dart';

class Booking {
  String? id;
  String? name;
  String? email;
  String? phone;
  DateTime? inDate;
  DateTime? outDate;
  DateTime? inTime;
  DateTime? outTime;
  DateTime? cancelled;
  Map<String, dynamic>? subBookings;
  int? status;
  int? bookingType;
  String? roomTypeID;
  String? room;
  List<num>? price;
  int? lengthStay;
  int? lengthRender;
  String? bed;
  bool? breakfast = false;
  bool? lunch = false;
  bool? dinner = false;
  bool? payAtHotel = true;
  int? extraBed;
  Timestamp? created;
  List<dynamic>? staydays;
  bool? group;
  String? ratePlanID;
  num? adult;
  num? child;
  String? sourceID;
  String? sID;
  num? discount = 0;
  ExtraHour? extraHour;
  bool? isBasic;
  bool? isEmpty = false;
  bool? isVirtual = false;
  bool? isTaxDeclare = false;
  bool? hasDeclaration = false;
  bool? statusinvoice = false;
  List<dynamic>? declareGuests = [];
  Map<String, dynamic>? declareInfo = {};
  Map<String, dynamic>? paymentDetails = {};
  Map<String, dynamic>? costDetails = {};
  Map<String, dynamic>? discountDetails = {};
  Map<String, dynamic>? depositDetails = {};
  Map<String, dynamic>? electricityDetails = {};
  Map<String, dynamic>? waterDetails = {};
  num? totalDepositPayment;
  num? totalRoomCharge;
  num? deposit;
  num? minibar;
  num? insideRestaurant;
  num? outsideRestaurant;
  num? extraGuest;
  late num laundry;
  num? bikeRental;
  num? other;
  num? transferring;
  num? transferred;
  num? otaDeposit;
  num? electricity;
  num? water;
  String? country;
  String? typeTourists;
  String? notes;
  num? rentingBikes;
  num? totalCost;
  int? statusPayment;
  String? creator;
  String? saler;
  String? externalSaler;

  String? get sourceName => SourceManager().getSourceNameByID(sourceID!);

  Booking({
    this.id,
    this.ratePlanID,
    this.staydays,
    this.name,
    this.email,
    this.phone,
    this.inDate,
    this.outDate,
    this.inTime,
    this.outTime,
    this.cancelled,
    this.status,
    this.bookingType,
    this.roomTypeID,
    this.room,
    this.rentingBikes,
    this.price,
    this.transferring = 0,
    this.transferred = 0,
    this.bed,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
    this.payAtHotel = true,
    this.adult = 0,
    this.child = 0,
    this.sourceID,
    this.sID,
    this.totalRoomCharge = 0,
    this.discount = 0,
    this.extraHour,
    this.extraBed,
    this.created,
    this.deposit = 0,
    this.minibar = 0,
    this.electricity = 0,
    this.water = 0,
    this.insideRestaurant = 0,
    this.outsideRestaurant = 0,
    this.extraGuest = 0,
    this.laundry = 0,
    this.bikeRental = 0,
    this.other = 0,
    this.totalDepositPayment = 0,
    this.group = false,
    this.isBasic = false,
    this.isVirtual = false,
    this.isTaxDeclare = false,
    this.hasDeclaration = false,
    this.statusinvoice = false,
    this.declareGuests,
    this.declareInfo,
    this.paymentDetails,
    this.depositDetails,
    this.costDetails,
    this.discountDetails,
    this.electricityDetails,
    this.waterDetails,
    this.otaDeposit,
    this.notes,
    this.subBookings,
    this.country,
    this.typeTourists,
    this.totalCost,
    this.statusPayment,
    this.creator,
    this.saler,
    this.externalSaler,
  }) {
    lengthStay = outDate!.difference(inDate!).inDays;
    lengthRender = lengthStay;
  }

  Booking.empty(
      {this.name,
      this.room,
      this.roomTypeID,
      this.bookingType,
      this.inDate,
      this.id,
      this.sID,
      this.outDate,
      this.sourceID,
      this.group = false,
      this.ratePlanID,
      this.price}) {
    roomTypeID ??= RoomTypeManager().getFirstRoomType()!.id;
    isEmpty = true;
    status = BookingStatus.booked;
    isTaxDeclare = false;
  }

  Booking.virtual(
      {this.id,
      this.sID,
      this.inDate,
      this.outDate,
      this.name,
      this.status,
      this.phone,
      this.email}) {
    isVirtual = true;
    price = [];
    status ??= BookingStatus.booked;
    sID ??= NumberUtil.getSidByConvertToBase62();
    room = 'virtual';
    isTaxDeclare = false;
  }

  Booking.clone(Booking oldBooking) {
    id = oldBooking.id;
    ratePlanID = oldBooking.ratePlanID;
    staydays = oldBooking.staydays;
    name = oldBooking.name;
    email = oldBooking.email;
    phone = oldBooking.phone;
    inDate = oldBooking.inDate;
    outDate = oldBooking.outDate;
    inTime = oldBooking.inTime;
    outTime = oldBooking.outTime;
    cancelled = oldBooking.cancelled;
    status = oldBooking.status;
    roomTypeID = oldBooking.roomTypeID;
    room = oldBooking.room;
    rentingBikes = oldBooking.rentingBikes;
    price = oldBooking.price;
    transferring = oldBooking.transferring;
    transferred = oldBooking.transferred;
    bed = oldBooking.bed;
    breakfast = oldBooking.breakfast;
    lunch = oldBooking.lunch;
    dinner = oldBooking.dinner;
    payAtHotel = oldBooking.payAtHotel;
    adult = oldBooking.adult;
    child = oldBooking.child;
    sourceID = oldBooking.sourceID;
    sID = oldBooking.sID;
    discount = oldBooking.discount;
    extraHour = oldBooking.extraHour;
    extraBed = oldBooking.extraBed;
    created = oldBooking.created;
    deposit = oldBooking.deposit;
    minibar = oldBooking.minibar;
    electricity = oldBooking.electricity;
    water = oldBooking.water;
    insideRestaurant = oldBooking.insideRestaurant;
    outsideRestaurant = oldBooking.outsideRestaurant;
    extraGuest = oldBooking.extraGuest;
    laundry = oldBooking.laundry;
    bikeRental = oldBooking.bikeRental;
    other = oldBooking.other;
    group = oldBooking.group;
    isBasic = oldBooking.isBasic;
    isVirtual = oldBooking.isVirtual;
    isTaxDeclare = oldBooking.isTaxDeclare;
    hasDeclaration = oldBooking.hasDeclaration;
    declareGuests = oldBooking.declareGuests;
    declareInfo = oldBooking.declareInfo;
    otaDeposit = oldBooking.otaDeposit;
    notes = oldBooking.notes;
    subBookings = oldBooking.subBookings;
    country = oldBooking.country;
    typeTourists = oldBooking.typeTourists;
    lengthStay = outDate!.difference(inDate!).inDays;
    lengthRender = lengthStay;
    bookingType = oldBooking.bookingType;
  }

  //booking which are queried from 'basic_bookings' collection
  factory Booking.basicFromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    return Booking(
        name: data.containsKey('name') ? doc.get('name') : '',
        email: data.containsKey('email') ? doc.get('email') : '',
        phone: data.containsKey('phone') ? doc.get('phone') : '',
        staydays: data.containsKey('stay_days')
            ? (doc.get('stay_days') as List<dynamic>)
                .map((element) => element.toDate())
                .toList()
            : [],
        ratePlanID: data.containsKey('rate_plan') ? doc.get('rate_plan') : '',
        breakfast: data.containsKey('breakfast') ? doc.get('breakfast') : false,
        lunch: data.containsKey('lunch') ? doc.get('lunch') : false,
        dinner: data.containsKey('dinner') ? doc.get('dinner') : false,
        payAtHotel:
            data.containsKey('pay_at_hotel') ? doc.get('pay_at_hotel') : true,
        id: doc.id,
        price:
            data.containsKey('price') ? List<num>.from(doc.get('price')) : [],
        inDate: (doc.get('in_date') as Timestamp).toDate(),
        outDate: (doc.get('out_date') as Timestamp).toDate(),
        outTime: (doc.get('out_time') as Timestamp).toDate(),
        inTime: (doc.get('in_time') as Timestamp).toDate(),
        cancelled: data.containsKey('cancelled')
            ? (doc.get('cancelled') as Timestamp).toDate()
            : DateTime.now(),
        notes: data.containsKey('notes') ? doc.get('notes') : '',
        room: data.containsKey('room') ? doc.get('room') : '',
        bookingType: data.containsKey('booking_type')
            ? doc.get('booking_type')
            : BookingType.dayly,
        roomTypeID: data.containsKey('room_type') ? doc.get('room_type') : '',
        bed: data.containsKey('bed') ? doc.get('bed') : '',
        extraBed: data.containsKey('extra_bed') ? doc.get('extra_bed') : 0,
        status: doc.get('status'),
        sID: data.containsKey('sid') ? doc.get('sid') : '',
        created:
            data.containsKey('created') ? doc.get('created') : Timestamp.now(),
        sourceID: data.containsKey('source')
            ? doc.get('source')
            : SourceManager.noneSourceId,
        adult: data.containsKey('adult') ? doc.get('adult') : 0,
        child: data.containsKey('child') ? doc.get("child") : 0,
        group: data.containsKey('group') ? doc.get('group') : false,
        isBasic: true,
        isTaxDeclare: data.containsKey('tax_declare')
            ? (doc.get('tax_declare') ?? false)
            : false,
        declareGuests: data.containsKey('guest') ? doc.get('guest') : [],
        declareInfo:
            data.containsKey('declare_info') ? doc.get('declare_info') : {},
        paymentDetails: data.containsKey('payment_details')
            ? doc.get('payment_details')
            : {},
        depositDetails: data.containsKey('deposit_details')
            ? doc.get('deposit_details')
            : {},
        electricityDetails: data.containsKey('electricity_details')
            ? doc.get('electricity_details')
            : {},
        waterDetails:
            data.containsKey('water_details') ? doc.get('water_details') : {},
        costDetails:
            data.containsKey('cost_details') ? doc.get('cost_details') : {},
        typeTourists:
            data.containsKey('type_tourists') ? doc.get('type_tourists') : '',
        country: data.containsKey('country') ? doc.get('country') : '',
        totalCost: data.containsKey('total_cost') ? doc.get('total_cost') : 0,
        statusPayment:
            data.containsKey('status_payment') ? doc.get('status_payment') : 2,
        saler: data.containsKey('email_saler') ? doc.get('email_saler') : "",
        externalSaler: data.containsKey('external_saler')
            ? doc.get('external_saler')
            : "");
  }

  factory Booking.basicFromSnapshotByRoom(
      DocumentSnapshot doc, DocumentSnapshot value) {
    final data = (doc.data() as Map<String, dynamic>);
    final dataCollectionBooking = (value.data() as Map<String, dynamic>);
    Map<String, dynamic> subBookings = {};
    if (doc.get("group")) {
      subBookings =
          dataCollectionBooking['sub_bookings'] as Map<String, dynamic>;
    }
    return Booking(
      name: data.containsKey('name') ? doc.get('name') : '',
      email: data.containsKey('email') ? doc.get('email') : '',
      phone: data.containsKey('phone') ? doc.get('phone') : '',
      staydays: data.containsKey('stay_days')
          ? (doc.get('stay_days') as List<dynamic>)
              .map((element) => element.toDate())
              .toList()
          : [],
      ratePlanID: data.containsKey('rate_plan') ? doc.get('rate_plan') : '',
      breakfast: data.containsKey('breakfast') ? doc.get('breakfast') : false,
      lunch: data.containsKey('lunch') ? doc.get('lunch') : false,
      dinner: data.containsKey('dinner') ? doc.get('dinner') : false,
      payAtHotel:
          data.containsKey('pay_at_hotel') ? doc.get('pay_at_hotel') : true,
      id: doc.id,
      price: data.containsKey('price') ? List<num>.from(doc.get('price')) : [],
      inDate: (doc.get('in_date') as Timestamp).toDate(),
      outDate: (doc.get('out_date') as Timestamp).toDate(),
      outTime: (doc.get('out_time') as Timestamp).toDate(),
      inTime: (doc.get('in_time') as Timestamp).toDate(),
      cancelled: data.containsKey('cancelled')
          ? (doc.get('cancelled') as Timestamp).toDate()
          : DateTime.now(),
      notes: data.containsKey('notes') ? doc.get('notes') : '',
      room: data.containsKey('room') ? doc.get('room') : '',
      bookingType: data.containsKey('booking_type')
          ? doc.get('booking_type')
          : BookingType.dayly,
      roomTypeID: data.containsKey('room_type') ? doc.get('room_type') : '',
      bed: data.containsKey('bed') ? doc.get('bed') : '',
      extraBed: data.containsKey('extra_bed') ? doc.get('extra_bed') : 0,
      status: doc.get('status'),
      sID: data.containsKey('sid') ? doc.get('sid') : '',
      created:
          data.containsKey('created') ? doc.get('created') : Timestamp.now(),
      sourceID: data.containsKey('source')
          ? doc.get('source')
          : SourceManager.noneSourceId,
      adult: data.containsKey('adult') ? doc.get('adult') : 0,
      child: data.containsKey('child') ? doc.get("child") : 0,
      group: data.containsKey('group') ? doc.get('group') : false,
      isBasic: true,
      isTaxDeclare: data.containsKey('tax_declare')
          ? (doc.get('tax_declare') ?? false)
          : false,
      declareGuests: data.containsKey('guest') ? doc.get('guest') : [],
      declareInfo:
          data.containsKey('declare_info') ? doc.get('declare_info') : {},
      typeTourists:
          data.containsKey('type_tourists') ? doc.get('type_tourists') : '',
      country: data.containsKey('country') ? doc.get('country') : '',
      statusPayment:
          data.containsKey('status_payment') ? doc.get('status_payment') : 2,
      paymentDetails: dataCollectionBooking.containsKey('payment_details')
          ? value.get('payment_details')
          : {},
      depositDetails: dataCollectionBooking.containsKey('deposit_details')
          ? value.get('deposit_details')
          : {},
      totalDepositPayment: dataCollectionBooking.containsKey('deposit_payemnt')
          ? value.get('deposit_payemnt')
          : 0,
      electricityDetails:
          dataCollectionBooking.containsKey('electricity_details')
              ? value.get('electricity_details')
              : {},
      waterDetails: dataCollectionBooking.containsKey('water_details')
          ? value.get('water_details')
          : {},
      saler: data.containsKey('email_saler') ? doc.get('email_saler') : "",
      externalSaler: dataCollectionBooking.containsKey('external_saler')
          ? value.get('external_saler')
          : "",
      totalCost: data.containsKey('total_cost') ? doc.get('total_cost') : 0,
      costDetails: dataCollectionBooking.containsKey('cost_details')
          ? value.get('cost_details')
          : {},
      discount: dataCollectionBooking.containsKey('discount')
          ? value.get('discount.total')
          : 0,
      discountDetails: dataCollectionBooking.containsKey('discount')
          ? value.get('discount.details')
          : {},
      minibar: 0,
      electricity: 0,
      water: 0,
      insideRestaurant: 0,
      outsideRestaurant: 0,
      extraGuest: 0,
      laundry: 0,
      bikeRental: 0,
      other: 0,
      extraHour: doc.get("group")
          ? subBookings[doc.id].containsKey("extra_hours")
              ? ExtraHour.fromMap(subBookings[doc.id]["extra_hours"])
              : ExtraHour.empty()
          : dataCollectionBooking.containsKey('extra_hours')
              ? ExtraHour.fromMap(value.get('extra_hours'))
              : ExtraHour.empty(),
      rentingBikes: doc.get("group")
          ? subBookings[doc.id].containsKey("renting_bike_num")
              ? subBookings[doc.id]["renting_bike_num"]
              : 0
          : dataCollectionBooking.containsKey('renting_bike_num')
              ? value.get('renting_bike_num')
              : 0,
      creator: dataCollectionBooking.containsKey('creator')
          ? value.get('creator')
          : "",
      transferring: dataCollectionBooking.containsKey('transferring')
          ? value.get('transferring')
          : 0,
      transferred: dataCollectionBooking.containsKey('transferred')
          ? value.get('transferred')
          : 0,
      deposit: dataCollectionBooking.containsKey('deposit')
          ? value.get('deposit')
          : 0,
    );
  }

  //normal-booking which are queried from 'bookings' collection
  factory Booking.fromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    if (data.containsKey('virtual') && doc.get('virtual')) {
      return Booking.virtualFromSnapshot(doc);
    }
    return Booking(
      id: doc.id,
      name: doc.get("name"),
      inDate: (doc.get('in_date') as Timestamp).toDate(),
      email: doc.get("email"),
      outDate: (doc.get('out_date') as Timestamp).toDate(),
      phone: doc.get("phone"),
      roomTypeID: doc.get('room_type'),
      bookingType: data.containsKey('booking_type')
          ? doc.get('booking_type')
          : BookingType.dayly,
      status: doc.get("status"),
      room: doc.get("room"),
      ratePlanID: doc.get('rate_plan'),
      price: List<num>.from(doc.get('price')),
      adult: doc.get("adult"),
      group: data.containsKey('group') ? doc.get('group') : false,
      child: data.containsKey('child') ? doc.get("child") : 0,
      sourceID: data.containsKey('source')
          ? doc.get("source")
          : SourceManager.noneSourceId,
      sID: doc.get("sid"),
      discount: data.containsKey('discount') ? doc.get('discount.total') : 0,
      outTime: (doc.get('out_time') as Timestamp).toDate(),
      inTime: (doc.get('in_time') as Timestamp).toDate(),
      cancelled: data.containsKey('cancelled')
          ? (doc.get('cancelled') as Timestamp).toDate()
          : DateTime.now(),
      bed: data.containsKey('bed') ? doc.get('bed') : '?',
      minibar: data.containsKey('minibar') ? doc.get('minibar') : 0,
      electricity: data.containsKey('electricity') ? doc.get('electricity') : 0,
      water: data.containsKey('water') ? doc.get('water') : 0,
      insideRestaurant: data.containsKey(ServiceManager.INSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.INSIDE_RESTAURANT_CAT)
          : 0,
      outsideRestaurant: data.containsKey(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          : 0,
      extraGuest: data.containsKey('extra_guest') ? doc.get('extra_guest') : 0,
      laundry: data.containsKey('laundry') ? doc.get('laundry') : 0,
      bikeRental: data.containsKey('bike_rental') ? doc.get('bike_rental') : 0,
      other: data.containsKey('other') ? doc.get('other') : 0,
      transferring:
          data.containsKey('transferring') ? doc.get('transferring') : 0,
      transferred: data.containsKey('transferred') ? doc.get('transferred') : 0,
      deposit: data.containsKey('deposit') ? doc.get('deposit') : 0,
      breakfast: data.containsKey('breakfast') ? doc.get('breakfast') : false,
      lunch: data.containsKey('lunch') ? doc.get('lunch') : false,
      dinner: data.containsKey('dinner') ? doc.get('dinner') : false,
      payAtHotel:
          data.containsKey('pay_at_hotel') ? doc.get('pay_at_hotel') : true,
      created: doc.get('created'),
      extraBed: data.containsKey('extra_bed') ? doc.get('extra_bed') : 0,
      extraHour: data.containsKey('extra_hours')
          ? ExtraHour.fromMap(doc.get('extra_hours'))
          : ExtraHour.empty(),
      otaDeposit: data.containsKey('ota_deposit') ? doc.get('ota_deposit') : 0,
      rentingBikes: data.containsKey('renting_bike_num')
          ? doc.get('renting_bike_num')
          : 0,
      isTaxDeclare:
          data.containsKey('tax_declare') ? doc.get('tax_declare') : false,
      hasDeclaration: data.containsKey('has_declaration')
          ? doc.get('has_declaration')
          : false,
      statusinvoice: data.containsKey('status_invoice')
          ? doc.get('status_invoice')
          : false,
      declareGuests: data.containsKey('guest') ? doc.get('guest') : [],
      declareInfo:
          data.containsKey('declare_info') ? doc.get('declare_info') : {},
      paymentDetails:
          data.containsKey('payment_details') ? doc.get('payment_details') : {},
      totalDepositPayment:
          data.containsKey('deposit_payemnt') ? doc.get('deposit_payemnt') : 0,
      depositDetails:
          data.containsKey('deposit_details') ? doc.get('deposit_details') : {},
      electricityDetails: data.containsKey('electricity_details')
          ? doc.get('electricity_details')
          : {},
      waterDetails:
          data.containsKey('water_details') ? doc.get('water_details') : {},
      costDetails:
          data.containsKey('cost_details') ? doc.get('cost_details') : {},
      typeTourists:
          data.containsKey('type_tourists') ? doc.get('type_tourists') : '',
      country: data.containsKey('country') ? doc.get('country') : '',
      totalCost: data.containsKey('total_cost') ? doc.get('total_cost') : 0,
      creator: data.containsKey('creator') ? doc.get('creator') : "",
      saler: data.containsKey('email_saler') ? doc.get('email_saler') : "",
      externalSaler:
          data.containsKey('external_saler') ? doc.get('external_saler') : "",
    );
  }

  //parent-booking of group-booking from 'bookings' collection
  factory Booking.groupFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    num adultParam = 0;
    num childParam = 0;

    final subBookings = data['sub_bookings'] as Map<String, dynamic>;
    String roomGroup = '';
    String roomType = "";
    for (var item in subBookings.entries) {
      adultParam += item.value['adult'] ?? 0;
      childParam += item.value['child'] ?? 0;
      roomGroup += '${RoomManager().getNameRoomById(item.value['room'])}, ';
      roomType += '${item.value['room_type']}, ';
    }
    return Booking(
      id: doc.id,
      name: doc.get("name"),
      inDate: (doc.get('in_date') as Timestamp).toDate(),
      inTime: (doc.get('in_date') as Timestamp).toDate(),
      email: doc.get("email"),
      outDate: (doc.get('out_date') as Timestamp).toDate(),
      outTime: data.containsKey('out_time')
          ? (doc.get('out_time') as Timestamp).toDate()
          : (doc.get('out_date') as Timestamp).toDate(),
      cancelled: data.containsKey('cancelled')
          ? (doc.get('cancelled') as Timestamp).toDate()
          : DateTime.now(),
      phone: doc.get("phone"),
      adult: adultParam,
      child: childParam,
      status: doc.get('status'),
      price: List<num>.from(doc.get('price')),
      subBookings: doc.get("sub_bookings"),
      ratePlanID: doc.get('rate_plan'),
      group: true,
      sourceID: data.containsKey('source')
          ? doc.get("source")
          : SourceManager.noneSourceId,
      sID: doc.get("sid"),
      discount: data.containsKey('discount') ? doc.get('discount.total') : 0,
      discountDetails:
          data.containsKey('discount') ? doc.get('discount.details') : {},
      bed: data.containsKey('bed') ? doc.get('bed') : '?',
      minibar: data.containsKey('minibar') ? doc.get('minibar') : 0,
      electricity: data.containsKey('electricity') ? doc.get('electricity') : 0,
      water: data.containsKey('water') ? doc.get('water') : 0,
      insideRestaurant: data.containsKey(ServiceManager.INSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.INSIDE_RESTAURANT_CAT)
          : 0,
      outsideRestaurant: data.containsKey(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          : 0,
      extraGuest: data.containsKey('extra_guest') ? doc.get('extra_guest') : 0,
      laundry: data.containsKey('laundry') ? doc.get('laundry') : 0,
      bikeRental: data.containsKey('bike_rental') ? doc.get('bike_rental') : 0,
      other: data.containsKey('other') ? doc.get('other') : 0,
      transferring:
          data.containsKey('transferring') ? doc.get('transferring') : 0,
      transferred: data.containsKey('transferred') ? doc.get('transferred') : 0,
      deposit: data.containsKey('deposit') ? doc.get('deposit') : 0,
      payAtHotel:
          data.containsKey('pay_at_hotel') ? doc.get('pay_at_hotel') : true,
      created: doc.get('created'),
      extraBed: data.containsKey('extra_bed') ? doc.get('extra_bed') : 0,
      extraHour: data.containsKey('extra_hour')
          ? ExtraHour.fromGroup(doc.get('extra_hour'))
          : ExtraHour.empty(),
      otaDeposit: data.containsKey('ota_deposit') ? doc.get('ota_deposit') : 0,
      rentingBikes: data.containsKey('renting_bike_num')
          ? doc.get('renting_bike_num')
          : 0,
      room: roomGroup,
      isVirtual: data.containsKey('virtual') ? doc.get('virtual') : false,
      declareInfo:
          data.containsKey('declare_info') ? doc.get('declare_info') : {},
      isTaxDeclare:
          data.containsKey('tax_declare') ? doc.get('tax_declare') : false,
      hasDeclaration: data.containsKey('has_declaration')
          ? doc.get('has_declaration')
          : false,
      paymentDetails:
          data.containsKey('payment_details') ? doc.get('payment_details') : {},
      totalDepositPayment:
          data.containsKey('deposit_payemnt') ? doc.get('deposit_payemnt') : 0,
      depositDetails:
          data.containsKey('deposit_details') ? doc.get('deposit_details') : {},
      electricityDetails: data.containsKey('electricity_details')
          ? doc.get('electricity_details')
          : {},
      waterDetails:
          data.containsKey('water_details') ? doc.get('water_details') : {},
      costDetails:
          data.containsKey('cost_details') ? doc.get('cost_details') : {},
      statusinvoice: data.containsKey('status_invoice')
          ? doc.get('status_invoice')
          : false,
      bookingType: data.containsKey('booking_type')
          ? doc.get('booking_type')
          : BookingType.dayly,
      roomTypeID: roomType,
      creator: data.containsKey('creator') ? doc.get('creator') : "",
      saler: data.containsKey('email_saler') ? doc.get('email_saler') : "",
      externalSaler:
          data.containsKey('external_saler') ? doc.get('external_saler') : "",
    );
  }

  factory Booking.groupFromSnapshotOfBookingToday(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    num adultParam = 0;
    num childParam = 0;
    final subBookings = data['sub_bookings'] as Map<String, dynamic>;
    String roomGroup = '';
    for (var item in subBookings.entries) {
      if (item.value["status"] != BookingStatus.noshow &&
          item.value["status"] != BookingStatus.cancel) {
        adultParam += item.value['adult'] ?? 0;
        childParam += item.value['child'] ?? 0;
        roomGroup += '${RoomManager().getNameRoomById(item.value['room'])}, ';
      }
    }
    return Booking(
        id: doc.id,
        name: doc.get("name"),
        inDate: (doc.get('in_date') as Timestamp).toDate(),
        inTime: (doc.get('in_date') as Timestamp).toDate(),
        email: doc.get("email"),
        outDate: (doc.get('out_date') as Timestamp).toDate(),
        outTime: data.containsKey('out_time')
            ? (doc.get('out_time') as Timestamp).toDate()
            : (doc.get('out_date') as Timestamp).toDate(),
        cancelled: data.containsKey('cancelled')
            ? (doc.get('cancelled') as Timestamp).toDate()
            : DateTime.now(),
        phone: doc.get("phone"),
        adult: adultParam,
        child: childParam,
        status: doc.get('status'),
        price: List<num>.from(doc.get('price')),
        subBookings: doc.get("sub_bookings"),
        ratePlanID: doc.get('rate_plan'),
        bookingType: data.containsKey('booking_type')
            ? doc.get('booking_type')
            : BookingType.dayly,
        group: true,
        sourceID: data.containsKey('source')
            ? doc.get("source")
            : SourceManager.noneSourceId,
        sID: doc.get("sid"),
        discount: data.containsKey('discount') ? doc.get('discount.total') : 0,
        bed: data.containsKey('bed') ? doc.get('bed') : '?',
        minibar: data.containsKey('minibar') ? doc.get('minibar') : 0,
        electricity:
            data.containsKey('electricity') ? doc.get('electricity') : 0,
        water: data.containsKey('water') ? doc.get('water') : 0,
        insideRestaurant: data.containsKey(ServiceManager.INSIDE_RESTAURANT_CAT)
            ? doc.get(ServiceManager.INSIDE_RESTAURANT_CAT)
            : 0,
        outsideRestaurant:
            data.containsKey(ServiceManager.OUTSIDE_RESTAURANT_CAT)
                ? doc.get(ServiceManager.OUTSIDE_RESTAURANT_CAT)
                : 0,
        extraGuest:
            data.containsKey('extra_guest') ? doc.get('extra_guest') : 0,
        laundry: data.containsKey('laundry') ? doc.get('laundry') : 0,
        bikeRental:
            data.containsKey('bike_rental') ? doc.get('bike_rental') : 0,
        other: data.containsKey('other') ? doc.get('other') : 0,
        transferring:
            data.containsKey('transferring') ? doc.get('transferring') : 0,
        transferred:
            data.containsKey('transferred') ? doc.get('transferred') : 0,
        deposit: data.containsKey('deposit') ? doc.get('deposit') : 0,
        payAtHotel:
            data.containsKey('pay_at_hotel') ? doc.get('pay_at_hotel') : true,
        created: doc.get('created'),
        extraBed: data.containsKey('extra_bed') ? doc.get('extra_bed') : 0,
        extraHour: data.containsKey('extra_hour')
            ? ExtraHour.fromGroup(doc.get('extra_hour'))
            : ExtraHour.empty(),
        otaDeposit:
            data.containsKey('ota_deposit') ? doc.get('ota_deposit') : 0,
        rentingBikes: data.containsKey('renting_bike_num')
            ? doc.get('renting_bike_num')
            : 0,
        room: roomGroup,
        isVirtual: data.containsKey('virtual') ? doc.get('virtual') : false,
        declareInfo:
            data.containsKey('declare_info') ? doc.get('declare_info') : {},
        isTaxDeclare:
            data.containsKey('tax_declare') ? doc.get('tax_declare') : false,
        hasDeclaration: data.containsKey('has_declaration')
            ? doc.get('has_declaration')
            : false,
        paymentDetails: data.containsKey('payment_details')
            ? doc.get('payment_details')
            : {},
        electricityDetails: data.containsKey('electricity_details')
            ? doc.get('electricity_details')
            : {},
        waterDetails:
            data.containsKey('water_details') ? doc.get('water_details') : {},
        totalDepositPayment: data.containsKey('deposit_payemnt')
            ? doc.get('deposit_payemnt')
            : 0,
        depositDetails: data.containsKey('deposit_details')
            ? doc.get('deposit_details')
            : {},
        costDetails:
            data.containsKey('cost_details') ? doc.get('cost_details') : {},
        statusinvoice: data.containsKey('status_invoice')
            ? doc.get('status_invoice')
            : false);
  }
  //sub-booking of parent-booking of group from 'bookings' collection
  factory Booking.fromBookingParent(String idBooking, Booking parent) {
    dynamic data = parent.subBookings![idBooking];
    return Booking(
        id: idBooking,
        name: parent.name,
        email: parent.email,
        phone: parent.phone,
        created: parent.created,
        adult: data['adult'],
        child: data['child'],
        roomTypeID: data['room_type'],
        paymentDetails: parent.paymentDetails ?? {},
        discountDetails: parent.discountDetails ?? {},
        totalDepositPayment: parent.totalDepositPayment ?? 0,
        depositDetails: parent.depositDetails ?? {},
        electricityDetails: parent.electricityDetails ?? {},
        waterDetails: parent.waterDetails ?? {},
        bookingType: parent.bookingType ?? BookingType.dayly,
        room: data['room'],
        status: data['status'],
        price: List<num>.from(data['price']),
        inDate: data['in_date'].toDate(),
        outDate: data['out_date'].toDate(),
        breakfast: data['breakfast'],
        lunch: data['lunch'] ?? false,
        dinner: data['dinner'] ?? false,
        bed: data['bed'],
        payAtHotel: parent.payAtHotel,
        sourceID: parent.sourceID,
        sID: parent.sID,
        ratePlanID: parent.ratePlanID,
        group: true,
        minibar: data['minibar'] ?? 0,
        electricity: data['electricity'] ?? 0,
        water: data["water"] ?? 0,
        insideRestaurant: data[ServiceManager.INSIDE_RESTAURANT_CAT] ?? 0,
        outsideRestaurant: data[ServiceManager.OUTSIDE_RESTAURANT_CAT] ?? 0,
        extraGuest: data['extra_guest'] ?? 0,
        laundry: data['laundry'] ?? 0,
        bikeRental: data['bike_rental'] ?? 0,
        other: data['other'] ?? 0,
        deposit: data['deposit'] ?? 0,
        extraBed: data['extra_bed'] ?? 0,
        extraHour: data['extra_hours'] != null
            ? ExtraHour.fromMap(data['extra_hours'])
            : ExtraHour.empty(),
        otaDeposit: data['ota_deposit'] ?? 0,
        rentingBikes: data['renting_bike_num'] ?? 0,
        isTaxDeclare: data['tax_declare'] ?? false,
        declareInfo: parent.declareInfo,
        declareGuests: data['guest'] ?? [],
        hasDeclaration: parent.hasDeclaration,
        typeTourists: data['type_tourists'] ?? '',
        country: data['country'] ?? '',
        saler: parent.saler,
        externalSaler: parent.externalSaler);
  }

  //virtual-booking which are queried from 'bookings' collection
  factory Booking.virtualFromSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>);
    return Booking(
      id: doc.id,
      name: doc.get("name"),
      inDate: (doc.get('in_date') as Timestamp).toDate(),
      email: doc.get("email"),
      outDate: (doc.get('out_date') as Timestamp).toDate(),
      phone: doc.get("phone"),
      status: doc.get("status"),
      price: [],
      room: doc.get('room'),
      sourceID: doc.get('source'),
      sID: doc.get("sid"),
      discount: data.containsKey('discount') ? doc.get('discount.total') : 0,
      outTime: ((data.containsKey('out_time')
              ? doc.get('out_time')
              : doc.get('out_date')) as Timestamp)
          .toDate(),
      cancelled: data.containsKey('cancelled')
          ? (doc.get('cancelled') as Timestamp).toDate()
          : DateTime.now(),
      minibar: data.containsKey('minibar') ? doc.get('minibar') : 0,
      electricity: data.containsKey('electricity') ? doc.get('electricity') : 0,
      water: data.containsKey('water') ? doc.get('water') : 0,
      insideRestaurant: data.containsKey(ServiceManager.INSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.INSIDE_RESTAURANT_CAT)
          : 0,
      outsideRestaurant: data.containsKey(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          ? doc.get(ServiceManager.OUTSIDE_RESTAURANT_CAT)
          : 0,
      extraGuest: data.containsKey('extra_guest') ? doc.get('extra_guest') : 0,
      laundry: data.containsKey('laundry') ? doc.get('laundry') : 0,
      bikeRental: data.containsKey('bike_rental') ? doc.get('bike_rental') : 0,
      other: data.containsKey('other') ? doc.get('other') : 0,
      transferring:
          data.containsKey('transferring') ? doc.get('transferring') : 0,
      transferred: data.containsKey('transferred') ? doc.get('transferred') : 0,
      deposit: data.containsKey('deposit') ? doc.get('deposit') : 0,
      created: doc.get('created'),
      extraHour: data.containsKey('extra_hours')
          ? ExtraHour.fromMap(doc.get('extra_hours'))
          : ExtraHour.empty(),
      otaDeposit: data.containsKey('ota_deposit') ? doc.get('ota_deposit') : 0,
      rentingBikes: data.containsKey('renting_bike_num')
          ? doc.get('renting_bike_num')
          : 0,
      isVirtual: true,
      isTaxDeclare: false,
    );
  }

  String getRoomTypeName() =>
      RoomTypeManager().getRoomTypeNameByID(roomTypeID!);

  Map<String, double> getPaymentDetail() {
    Map<String, double> dataMap = {};
    if (paymentDetails != null) {
      for (var data in paymentDetails!.values) {
        List<String> descArray = data.toString().split(specificCharacter);
        if (descArray[0].isNotEmpty) {
          if (dataMap.containsKey(
              PaymentMethodManager().getPaymentMethodNameById(descArray[0]))) {
            dataMap[PaymentMethodManager()
                .getPaymentMethodNameById(descArray[0])] = dataMap[
                    PaymentMethodManager()
                        .getPaymentMethodNameById(descArray[0])]! +
                double.parse(descArray[1]);
          } else {
            dataMap[PaymentMethodManager()
                    .getPaymentMethodNameById(descArray[0])] =
                double.parse(descArray[1]);
          }
        }
      }
    }
    return dataMap;
  }

  num getTotalAmountCost() {
    num totalCost = 0;
    if (costDetails != null) {
      for (var data in costDetails!.values) {
        List<String> descArray = data.toString().split(specificCharacter);
        if (descArray[0].isNotEmpty) {
          totalCost += num.parse(descArray[1]);
        }
      }
    }
    return totalCost;
  }

  Map<String, String> getDetailCost() {
    Map<String, String> mapCost = {};
    if (costDetails != null) {
      for (var data in costDetails!.values) {
        List<String> descArray = data.toString().split(specificCharacter);
        if (descArray[0].isNotEmpty) {
          if (mapCost
              .containsKey(AccountingTypeManager.getNameById(descArray[0]))) {
            mapCost[AccountingTypeManager.getNameById(descArray[0])!] =
                "${mapCost[AccountingTypeManager.getNameById(descArray[0])]}, ${RoomManager().getNameRoomById(descArray[2])}: ${double.parse(descArray[1])} - ";
          } else {
            mapCost[AccountingTypeManager.getNameById(descArray[0])!] =
                "${RoomManager().getNameRoomById(descArray[2])}: ${double.parse(descArray[1])} - ";
          }
        }
      }
    }
    return mapCost;
  }

  Map<String, Map<String, dynamic>> getDetailCostByRoom(
      DateTime startDate, DateTime endDate) {
    Map<String, Map<String, dynamic>> mapCost = {};
    if (costDetails != null) {
      for (var data in costDetails!.values) {
        List<String> descArray = data.toString().split(specificCharacter);
        DateTime timeCreate =
            DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[3]));
        if (descArray[0].isNotEmpty &&
            ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
                (timeCreate.isBefore(inDate!) &&
                    startDate.month == inDate!.month) ||
                (timeCreate.isAfter(outDate!) &&
                    startDate.month == outDate!.month))) {
          String typeCost = AccountingTypeManager.getNameById(descArray[0])!;
          if (mapCost.containsKey(typeCost)) {
            if (mapCost[typeCost]!.containsKey(descArray[2])) {
              mapCost[typeCost]![descArray[2]] += double.parse(descArray[1]);
            } else {
              mapCost[typeCost]![descArray[2]] = double.parse(descArray[1]);
            }
          } else {
            mapCost[typeCost] = {descArray[2]: double.parse(descArray[1])};
          }
        }
      }
    }
    return mapCost;
  }

  List<dynamic> getDetailPayments(DateTime startDate, DateTime endDate) {
    List<dynamic> mapData = [];
    for (var data in paymentDetails!.values) {
      List<String> descArray = data.toString().split(specificCharacter);
      DateTime timeCreate =
          DateTime.fromMicrosecondsSinceEpoch(int.parse(descArray[2]));
      if ((timeCreate.isAfter(startDate) && timeCreate.isBefore(endDate)) ||
          (timeCreate.isBefore(inDate!) && startDate.month == inDate!.month) ||
          (timeCreate.isAfter(outDate!) && startDate.month == outDate!.month)) {
        mapData.add(data);
      }
    }
    return mapData;
  }

  Map<String, num> getTotalCostByTypeCost() {
    Map<String, num> mapCost = {};
    if (costDetails != null) {
      for (var data in costDetails!.values) {
        List<String> descArray = data.toString().split(specificCharacter);
        if (descArray[0].isNotEmpty) {
          if (mapCost
              .containsKey(AccountingTypeManager.getNameById(descArray[0]))) {
            mapCost[AccountingTypeManager.getNameById(descArray[0])!] =
                mapCost[AccountingTypeManager.getNameById(descArray[0])!]! +
                    double.parse(descArray[1]);
          } else {
            mapCost[AccountingTypeManager.getNameById(descArray[0])!] =
                double.parse(descArray[1]);
          }
        }
      }
    }
    return mapCost;
  }

  num getRoomCharge({bool isGroup = false}) =>
      bookingType == BookingType.monthly
          ? getRoomChargeByMonth(isGroup: isGroup)
          : price!.fold(0, (previousValue, element) => previousValue + element);

  num getRoomChargeByMonth({bool isGroup = false}) {
    num totalPriceToMonth = 0;
    // num priceToMonth = 0;
    // int index = 0;
    // bool checkUpdatePricer = true;
    // List<DateTime> staysDayLast = [];
    // List<DateTime> staysDaysByMonth = getBookingByTypeMonth();
    // List<DateTime> staydaysBookingMonth = [];
    // DateTime lastDay;

    if (isGroup) {
      if (subBookings == null) return 0;
      for (var key in subBookings!.keys) {
        DateTime inDates = (subBookings![key]["in_date"] as Timestamp).toDate();
        DateTime outDates =
            (subBookings![key]["out_date"] as Timestamp).toDate();
        List<dynamic>? prices = [];
        prices = subBookings![key]["price"];
        if (subBookings![key]["status"] != BookingStatus.noshow &&
            subBookings![key]["status"] != BookingStatus.cancel) {
          totalPriceToMonth += getPrieDayByMonthly(inDates, outDates, prices!);
          // index = 0;
          // staydaysBookingMonth = DateUtil.getStaysDay(inDates, outDates);
          // lastDay = outDates;

          // for (var i = 1; i < staysDaysByMonth.length; i++) {
          //   lastDay = DateTime(
          //       (inDates.year == outDates.year ? outDates.year : inDates.year),
          //       inDates.month + i,
          //       inDates.day - 1,
          //       inDates.hour);
          //   if (staydaysBookingMonth.contains(lastDay)) {
          //     List<DateTime> staysDayFirst = DateUtil.getStaysDay(
          //         DateTime(inDates.year, (inDates.month + index), inDates.day),
          //         lastDay);
          //     int length = staysDayFirst.length + 1;
          //     priceToMonth = (prices![index] / length).round();
          //     totalPriceToMonth += (priceToMonth * length);
          //     checkUpdatePricer = false;
          //     index++;
          //   }
          // }
          // DateTime lastOutDate = DateTime(
          //     lastDay.year, lastDay.month, (lastDay.day + 1), outDates.hour);
          // if (lastOutDate.isAfter(outDates) || lastOutDate.isBefore(outDates)) {
          //   DateTime firstDay =
          //       DateTime(inDates.year, inDates.month + index, inDates.day, 12);
          //   index = checkUpdatePricer ? 1 : (index + 1);
          //   staysDayLast = DateUtil.getStaysDay(firstDay, outDates);
          //   for (var i = 0; i < staysDayLast.length; i++) {
          //     totalPriceToMonth += prices![index];
          //     index++;
          //   }
          // }
        }
      }
    } else {
      // Map<String, Set<String>> data = ;
      // int length = data["stays_month"]!.length;
      // Set<String> listStayDay = data["stays_day"]!;
      // for (var i = 0; i < (length - (listStayDay.isEmpty ? 0 : 1)); i++) {
      //   totalPriceToMonth += price![i];
      // }
      // if (listStayDay.isNotEmpty) {
      //   int lengthStayDay = listStayDay.length;
      //   for (var i = length; i < (lengthStayDay + length); i++) {
      //     totalPriceToMonth += price![i];
      //   }
      // }
      totalPriceToMonth = getPrieDayByMonthly(inDate!, outDate!, price!);
      // staydaysBookingMonth = DateUtil.getStaysDay(inDate!, outDate!);
      // lastDay = outDate!;
      // for (var i = 1; i < staysDaysByMonth.length; i++) {
      //   lastDay = DateTime(
      //       (inDate!.year == outDate!.year ? outDate!.year : inDate!.year),
      //       inDate!.month + i,
      //       inDate!.day - 1,
      //       inDate!.hour);
      //   if (staydaysBookingMonth.contains(lastDay)) {
      //     List<DateTime> staysDayFirst = DateUtil.getStaysDay(
      //         DateTime(inDate!.year, (inDate!.month + index), inDate!.day),
      //         lastDay);
      //     int length = staysDayFirst.length + 1;
      //     priceToMonth = (price![index] / length).round();
      //     totalPriceToMonth += (priceToMonth * length);
      //     checkUpdatePricer = false;
      //     index++;
      //   }
      // }
      // DateTime lastOutDate = DateTime(
      //     lastDay.year, lastDay.month, (lastDay.day + 1), outDate!.hour);
      // if (lastOutDate.isAfter(outDate!) || lastOutDate.isBefore(outDate!)) {
      //   DateTime firstDay =
      //       DateTime(inDate!.year, inDate!.month + index, inDate!.day, 12);
      //   index = checkUpdatePricer ? 1 : (index + 1);
      //   staysDayLast = DateUtil.getStaysDay(firstDay, outDate!);
      //   for (var i = 0; i < staysDayLast.length; i++) {
      //     totalPriceToMonth += price![index];
      //     index++;
      //   }
      // }
    }

    return totalPriceToMonth.round();
  }

  num getRoomChargeByDate({DateTime? inDate, DateTime? outDate}) {
    num totalPriceToMonth = 0;
    num priceToMonth = 0;
    int index = 0;
    bool checkUpdatePricer = true;
    List<DateTime> staysDaysByMonth = getBookingByTypeMonth();
    List<DateTime> staydaysBookingMonth =
        DateUtil.getStaysDay(inDate!, outDate!);
    DateTime lastDay = outDate;
    List<DateTime> staysDayLast = [];
    for (var i = 1; i < staysDaysByMonth.length; i++) {
      lastDay = DateTime(
          (inDate.year == outDate.year ? outDate.year : inDate.year),
          inDate.month + i,
          inDate.day - 1,
          inDate.hour);
      if (staydaysBookingMonth.contains(lastDay)) {
        List<DateTime> staysDayFirst = DateUtil.getStaysDay(
            DateTime(inDate.year, (inDate.month + index), inDate.day), lastDay);
        priceToMonth = (price![index] / staysDayFirst.length);
        totalPriceToMonth += (priceToMonth * staysDayFirst.length);
        checkUpdatePricer = false;
        index++;
      }
    }
    DateTime lastOutDate =
        DateTime(lastDay.year, lastDay.month, (lastDay.day + 1), outDate.hour);
    if (lastOutDate.isAfter(outDate) || lastOutDate.isBefore(outDate)) {
      DateTime firstDay =
          DateTime(inDate.year, inDate.month + index, inDate.day, 12);
      index = checkUpdatePricer ? 1 : (index + 1);
      staysDayLast = DateUtil.getStaysDay(
          firstDay, DateTime(outDate.year, outDate.month, outDate.day + 1));
      for (var i = 0; i < staysDayLast.length; i++) {
        totalPriceToMonth += price![index];
        index++;
      }
    }
    return totalPriceToMonth.round();
  }

  num getRoomChargeByDateCostum({DateTime? inDate, DateTime? outDate}) {
    List<DateTime> staydaysBookingMonth =
        DateUtil.getStaysDay(this.inDate!, this.outDate!);
    num totalPriceToMonth = 0;
    num priceToMonth = 0;
    int index = 0;
    bool checkUpdatePricer = true;
    List<DateTime> staysDaysByMonth = getBookingByTypeMonth();
    List<DateTime> staydaysBookingMonthCustom =
        DateUtil.getStaysDay(inDate!, outDate!);
    DateTime lastDay = this.outDate!;
    List<DateTime> staysDayLast = [];
    for (var i = 1; i < staysDaysByMonth.length; i++) {
      lastDay = DateTime(
          (this.inDate!.year == this.outDate!.year
              ? this.outDate!.year
              : this.inDate!.year),
          this.inDate!.month + i,
          this.inDate!.day - 1,
          this.inDate!.hour);
      if (staydaysBookingMonth.contains(lastDay)) {
        List<DateTime> staysDayFirst = DateUtil.getStaysDay(
            DateTime(this.inDate!.year, (this.inDate!.month + index),
                this.inDate!.day),
            DateTime(lastDay.year, lastDay.month, lastDay.day + 1));
        priceToMonth = (price![index] / staysDayFirst.length);
        for (var element in staysDayFirst) {
          if (staydaysBookingMonthCustom.contains(element)) {
            totalPriceToMonth += priceToMonth;
          }
        }
        checkUpdatePricer = false;
        index++;
      }
    }
    DateTime lastOutDate = DateTime(
        lastDay.year, lastDay.month, (lastDay.day + 1), this.outDate!.hour);
    if (lastOutDate.isAfter(this.outDate!) ||
        lastOutDate.isBefore(this.outDate!)) {
      DateTime firstDay = DateTime(
          this.inDate!.year, this.inDate!.month + index, this.inDate!.day);
      index = checkUpdatePricer ? 1 : (index + 1);
      staysDayLast = DateUtil.getStaysDay(
          firstDay,
          DateTime(
              this.outDate!.year, this.outDate!.month, this.outDate!.day + 1));
      for (var i = 0; i < staysDayLast.length; i++) {
        if (staydaysBookingMonthCustom.contains(staysDayLast[i])) {
          totalPriceToMonth += price![index];
        }
        index++;
      }
    }
    return totalPriceToMonth.round();
  }

  num? getTotalCharge({bool isGroup = false}) =>
      getRoomCharge(isGroup: isGroup) + getServiceCharge() - discount!;

  num getRevenue({bool isGroup = false}) =>
      getRoomCharge(isGroup: isGroup) + getServiceCharge() - discount!;

  num getRevenueNotDiscout({bool isGroup = false}) =>
      getRoomCharge(isGroup: isGroup) + getServiceCharge();

  num getServiceCharge() =>
      minibar! +
      insideRestaurant! +
      outsideRestaurant! +
      extraGuest! +
      (extraHour?.total ?? 0) +
      electricity! +
      water! +
      laundry +
      bikeRental! +
      other!;

  num? getRemaining({bool isGroup = false}) =>
      getTotalCharge(isGroup: isGroup)! +
      transferred! -
      deposit! -
      transferring!;

  Future<List<Deposit>?> getDeposits() async {
    try {
      List<Deposit> deposits = [];
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colDeposits)
          .orderBy('created')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          deposits.add(Deposit.fromSnapshot(doc));
        }
      });
      return deposits;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> deleteDeposit(Deposit deposit) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('deposit-deleteBookingPayment')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'booking_id': id,
        'sid': sID,
        'payment_id': deposit.id,
        'payment_group': group
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
      }
    } on FirebaseFunctionsException catch (error) {
      return MessageUtil.getMessageByCode(error.message);
    }
    return MessageUtil.getMessageByCode(MessageCodeUtil.SUCCESS);
  }

  Future<String> updateDeposit(Deposit deposit, String nameRoomTransferTo,
      String nameRoomTransferFrom) async {
    if (deposit.desc == null || deposit.desc!.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('deposit-updateBookingPayment')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'booking_id': id,
        'sid': sID,
        'payment_id': deposit.id,
        'payment_group': group,
        'payment_amount': deposit.amount,
        'payment_method': deposit.method,
        'payment_transfer_bid': deposit.transferredBID,
        'payment_desc': deposit.desc,
        'room_name_to': nameRoomTransferTo,
        'room_name_from': nameRoomTransferFrom,
        'payment_actual_amount': deposit.actualAmount,
        'payment_note': deposit.note,
        'payment_reference_number': deposit.referenceNumber,
        if (deposit.referencDate != null)
          'payment_referenc_date': deposit.referencDate.toString(),
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (error) {
      return error.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> addDeposit(Deposit deposit, String nameRoomTransferTo,
      String nameRoomTransferFrom) async {
    if (deposit.desc == null || deposit.desc!.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('deposit-addBookingPayment')
          .call({
        'hotel_id': GeneralManager.hotelID,
        'booking_id': id,
        'sid': sID,
        'payment_amount': deposit.amount,
        'payment_method': deposit.method,
        'payment_transfer_bid': deposit.transferredBID,
        'payment_status': deposit.status,
        'payment_group': group,
        'payment_source_id': sourceID,
        'payment_desc': deposit.desc,
        'room_name_to': nameRoomTransferTo,
        'room_name_from': nameRoomTransferFrom,
        'payment_actual_amount': deposit.actualAmount,
        'payment_note': deposit.note,
        'payment_reference_number': deposit.referenceNumber,
        if (deposit.referencDate != null)
          'payment_referenc_date': deposit.referencDate.toString(),
      });
      if (result.data == MessageCodeUtil.SUCCESS) {
        return MessageCodeUtil.SUCCESS;
      }
    } on FirebaseFunctionsException catch (error) {
      return error.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<List<Minibar>> getMinibars() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('cat', isEqualTo: ServiceManager.MINIBAR_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where('cat', isEqualTo: ServiceManager.MINIBAR_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where('cat', isEqualTo: ServiceManager.MINIBAR_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<Minibar> minibars = [];
      for (var doc in querySnapshot.docs) {
        minibars.add(Minibar.fromSnapshot(doc));
      }
      return minibars;
    }).catchError((e) {
      print(e.toString());
      // ignore: invalid_return_type_for_catch_error
      return null;
    });
  }

  Future<List<Electricity>> getElectricity() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('cat', isEqualTo: ServiceManager.ELECTRICITY_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where('cat', isEqualTo: ServiceManager.ELECTRICITY_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where('cat', isEqualTo: ServiceManager.ELECTRICITY_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<Electricity> minibars = [];
      for (var doc in querySnapshot.docs) {
        minibars.add(Electricity.fromSnapshot(doc));
      }
      return minibars;
    }).catchError((e) {
      print(e.toString());
      // ignore: invalid_return_type_for_catch_error
      return null;
    });
  }

  Future<List<Water>> getWater() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('cat', isEqualTo: ServiceManager.WATER_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where('cat', isEqualTo: ServiceManager.WATER_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where('cat', isEqualTo: ServiceManager.WATER_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<Water> minibars = [];
      for (var doc in querySnapshot.docs) {
        minibars.add(Water.fromSnapshot(doc));
      }
      return minibars;
    }).catchError((e) {
      print(e.toString());
      // ignore: invalid_return_type_for_catch_error
      return null;
    });
  }

  Future<String> addService(Service service) async {
    dynamic dataService;
    if (service is Minibar) {
      dataService = {
        'items': service.items,
        'total': service.total,
        'cat': ServiceManager.MINIBAR_CAT,
        'status': service.status,
        'desc': service.desc
      };
    } else if (service is Laundry) {
      dataService = {
        'items': service.items,
        'total': service.total,
        'cat': ServiceManager.LAUNDRY_CAT,
        'status': service.status,
        'desc': service.desc,
      };
    } else if (service is ExtraGuest) {
      dataService = {
        'total': service.total,
        'cat': ServiceManager.EXTRA_GUEST_CAT,
        'status': service.status,
        'start': service.start.toString(),
        'end': service.end.toString(),
        'used': service.start.toString(),
        'type': service.type,
        'number': service.number,
        'price': service.price
      };
    } else if (service is BikeRental) {
      dataService = {
        'supplier': service.supplierID,
        'total': service.total,
        'type': service.type,
        'start': service.start!.toDate().toString(),
        'bike': service.bike,
        'price': service.price,
        'progress': service.progress,
        'cat': ServiceManager.BIKE_RENTAL_CAT,
        'status': service.status
      };
    } else if (service is Other) {
      dataService = {
        'desc': service.desc,
        'supplier': service.supplierID,
        'total': service.total,
        'status': service.status,
        'type': service.type,
        'cat': ServiceManager.OTHER_CAT,
        'used': service.date!.toDate().toString()
      };
    } else if (service is InsideRestaurantService) {
      dataService = {
        'items': service.items,
        'total': service.total,
        'cat': ServiceManager.INSIDE_RESTAURANT_CAT,
        'status': service.status
      };
    } else if (service is Electricity) {
      dataService = {
        'final_number': service.finalNumber,
        'final_time': service.finalTime.toString(),
        'initial_number': service.initialNumber,
        'initial_time': service.initialTime.toString(),
        'create_time': service.createdTime.toString(),
        'price_electricity': service.priceElectricity,
        'desc': service.desc,
        'total': service.total,
        'cat': ServiceManager.ELECTRICITY_CAT,
      };
    } else if (service is Water) {
      dataService = {
        'final_number': service.finalNumber,
        'final_time': service.finalTime.toString(),
        'initial_number': service.initialNumber,
        'initial_time': service.initialTime.toString(),
        'create_time': service.createdTime.toString(),
        'price_water': service.priceWater,
        'desc': service.desc,
        'total': service.total,
        'cat': ServiceManager.WATER_CAT,
      };
    }
    String result = await FirebaseFunctions.instance
        .httpsCallable('service-addBookingService')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      'sid': sID,
      'group': group,
      'data_service': dataService,
      'saler': service.saler,
    }).then((value) => value.data);
    return result;
  }

  Future<String> updateService(Service service) async {
    dynamic dataService;
    if (service is Minibar) {
      dataService = {
        'cat': ServiceManager.MINIBAR_CAT,
        'items': service.items,
        'total': service.getTotal(),
        'desc': service.desc
      };
    } else if (service is Laundry) {
      dataService = {
        'items': service.items,
        'total': service.getTotal(),
        'cat': ServiceManager.LAUNDRY_CAT,
        'desc': service.desc,
      };
    } else if (service is ExtraGuest) {
      dataService = {
        'cat': ServiceManager.EXTRA_GUEST_CAT,
        'start': service.start.toString(),
        'end': service.end.toString(),
        'total': service.total,
        'type': service.type,
        'number': service.number,
        'price': service.price,
      };
    } else if (service is Other) {
      dataService = {
        'cat': ServiceManager.OTHER_CAT,
        'total': service.total,
        'used': service.date!.toDate().toString(),
        'type': service.type,
        'desc': service.desc,
        'supplier': service.supplierID,
      };
    } else if (service is InsideRestaurantService) {
      dataService = {
        'cat': ServiceManager.INSIDE_RESTAURANT_CAT,
        'items': service.items,
        'total': service.getTotal(),
      };
    } else if (service is Electricity) {
      dataService = {
        'final_number': service.finalNumber,
        'final_time': service.finalTime.toString(),
        'initial_number': service.initialNumber,
        'initial_time': service.initialTime.toString(),
        'create_time': service.createdTime.toString(),
        'price_electricity': service.priceElectricity,
        'desc': service.desc,
        'total': service.total,
        'cat': ServiceManager.ELECTRICITY_CAT,
      };
    } else if (service is Water) {
      dataService = {
        'final_number': service.finalNumber,
        'final_time': service.finalTime.toString(),
        'initial_number': service.initialNumber,
        'initial_time': service.initialTime.toString(),
        'create_time': service.createdTime.toString(),
        'price_water': service.priceWater,
        'desc': service.desc,
        'total': service.total,
        'cat': ServiceManager.WATER_CAT,
      };
    }
    String result = await FirebaseFunctions.instance
        .httpsCallable('service-updateBookingService')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      if (group ?? false) 'booking_sid': sID,
      'service_id': service.id,
      'data_service': dataService,
      'saler': service.saler,
    }).then((value) => value.data);
    return result;
  }

  Future<List<Laundry>> getLaundries() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.LAUNDRY_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where("cat", isEqualTo: ServiceManager.LAUNDRY_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where("cat", isEqualTo: ServiceManager.LAUNDRY_CAT);
    }
    return query.get().then((QuerySnapshot querySnapshot) {
      List<Laundry> laundries = [];
      for (var doc in querySnapshot.docs) {
        laundries.add(Laundry.fromSnapShot(doc));
      }
      return laundries;
    }).catchError((e) {
      print(e.toString());

      return e;
    });
  }

  Future<List<ExtraGuest>> getExtraGuests() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.EXTRA_GUEST_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where("cat", isEqualTo: ServiceManager.EXTRA_GUEST_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where("cat", isEqualTo: ServiceManager.EXTRA_GUEST_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<ExtraGuest> extraguests = [];
      for (var doc in querySnapshot.docs) {
        extraguests.add(ExtraGuest.fromSnapshot(doc));
      }
      return extraguests;
    }).catchError((e) {
      print(e.toString());
      // ignore: invalid_return_type_for_catch_error
      return null;
    });
  }

  Future<List<BikeRental>> getBikeRentals() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.BIKE_RENTAL_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where("cat", isEqualTo: ServiceManager.BIKE_RENTAL_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where("cat", isEqualTo: ServiceManager.BIKE_RENTAL_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<BikeRental> bikeRentals = [];
      for (var doc in querySnapshot.docs) {
        BikeRental bikeRental = BikeRental.fromSnapshot(doc);
        bikeRental.isGroup = group;
        bikeRentals.add(bikeRental);
      }
      return bikeRentals;
    }).catchError((e) {
      print(e.toString());
      return e;
    });
  }

  Future<String> updateExtraHours(ExtraHour extraHours) async {
    if (extraHours.earlyHours! < 0 ||
        extraHours.lateHours! < 0 ||
        extraHours.earlyPrice! < 0 ||
        extraHours.latePrice! < 0) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('service-updateExtraHour')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      if (group ?? false) 'booking_sid': sID,
      'extra_hours': {
        'early_hours': extraHours.earlyHours,
        'late_hours': extraHours.lateHours,
        'early_price': extraHours.earlyPrice,
        'late_price': extraHours.latePrice,
        'total': extraHours.total,
      }
    }).then((value) => value.data);
  }

  Future<String> updateExtraBed(int extraBed) async {
    return FirebaseFunctions.instance
        .httpsCallable('service-updateExtraBed')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      if (group ?? false) 'sid': sID,
      'extra_bed': extraBed
    }).then((value) => value.data);
  }

  Future<List<Other>> getOthers() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.OTHER_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where("cat", isEqualTo: ServiceManager.OTHER_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where("cat", isEqualTo: ServiceManager.OTHER_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<Other> others = [];
      for (var doc in querySnapshot.docs) {
        others.add(Other.fromSnapshot(doc));
      }
      return others;
    }).catchError((e) {
      print(e.toString());
      return e;
    });
  }

  Future<List<OutsideRestaurantService>> getRestaurantServices() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where("cat", isEqualTo: ServiceManager.OUTSIDE_RESTAURANT_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where("cat", isEqualTo: ServiceManager.OUTSIDE_RESTAURANT_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where("cat", isEqualTo: ServiceManager.OUTSIDE_RESTAURANT_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<OutsideRestaurantService> resServices = [];
      for (var doc in querySnapshot.docs) {
        resServices.add(OutsideRestaurantService.fromSnapshot(doc));
      }
      return resServices;
    }).onError((error, stackTrace) {
      print(error.toString());
      return <OutsideRestaurantService>[];
    });
  }

  Future<List<InsideRestaurantService>> getInsideRestaurantServices() async {
    Query query;
    if (group ?? false) {
      if (id == sID) {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('cat', isEqualTo: ServiceManager.INSIDE_RESTAURANT_CAT);
      } else {
        query = FirebaseHandler.hotelRef
            .collection(FirebaseHandler.colBookings)
            .doc(sID)
            .collection(FirebaseHandler.colServices)
            .where('bid', isEqualTo: id)
            .where('cat', isEqualTo: ServiceManager.INSIDE_RESTAURANT_CAT);
      }
    } else {
      query = FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection(FirebaseHandler.colServices)
          .where('cat', isEqualTo: ServiceManager.INSIDE_RESTAURANT_CAT);
    }
    return await query.get().then((QuerySnapshot querySnapshot) {
      List<InsideRestaurantService> insideRestaurants = [];
      for (var doc in querySnapshot.docs) {
        insideRestaurants.add(InsideRestaurantService.fromSnapshot(doc));
      }
      return insideRestaurants;
    }).catchError((e) {
      print(e.toString());
      return e;
    });
  }

  Future<String> deleteService(Service service) async {
    return FirebaseFunctions.instance
        .httpsCallable('service-deleteBookingService')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      'service_id': service.id,
      'group': group,
      'sid': sID,
      'service_cat': service.cat,
      'service_deletable': service.deletable
    }).then((value) => value.data);
  }

  Future<String> add() async {
    if (lengthStay! > GeneralManager.maxLengthStay &&
        bookingType == BookingType.dayly) {
      return MessageCodeUtil.OVER_MAX_LENGTHDAY_31;
    }
    if (lengthStay! > 365 && bookingType == BookingType.monthly) {
      return MessageCodeUtil.OVER_MAX_LENGTHDAY_31;
    }
    if (outDate!.compareTo(inDate!) <= 0) {
      return MessageCodeUtil.OUTDATE_MUST_LARGER_THAN_INDATE;
    }
    final now = Timestamp.now();
    final now12h = DateUtil.to12h(now.toDate());
    final yesterday = now12h.subtract(const Duration(days: 1));
    if (inDate!.compareTo(yesterday) < 0 ||
        (inDate!.compareTo(yesterday) == 0 &&
            now.toDate().compareTo(now12h) >= 0)) {
      return MessageCodeUtil.INDATE_MUST_NOT_IN_PAST;
    }
    final bookingAdd = {
      'hotel_id': GeneralManager.hotelID,
      'rate_plan_id': ratePlanID,
      'name': name,
      'bed': bed,
      'in_date': inDate.toString(),
      'out_date': outDate.toString(),
      'in_time': inTime.toString(),
      'out_time': outTime.toString(),
      'room_id': room,
      'room_type_id': roomTypeID,
      'source': sourceID,
      'sid': sID,
      'phone': phone,
      'email': email,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'pay_at_hotel': payAtHotel,
      'adult': adult,
      'child': child,
      'status': status,
      'group': group,
      'price': price,
      'tax_declare': isTaxDeclare,
      'list_guest_declaration': declareGuests,
      'declaration_invoice_detail': declareInfo,
      'type_tourists': typeTourists,
      'country': country,
      'notes': notes,
      'saler': saler,
      'external_saler': externalSaler,
      'booking_type': bookingType,
    };
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('booking-addBooking');
      await callable(bookingAdd);
      return MessageCodeUtil.SUCCESS;
    } on FirebaseFunctionsException catch (error) {
      return error.message!;
    }
  }

  Future<String> updateStatus(Booking booking) async {
    final bookingAdd = {
      'hotel_id': GeneralManager.hotelID,
      'sid': booking.sID,
      'booking_id': booking.id,
      'group': booking.group,
      'status': BookingStatus.booked
    };
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('booking-updateStatus');
      await callable(bookingAdd);
      return MessageCodeUtil.SUCCESS;
    } on FirebaseFunctionsException catch (error) {
      return error.message!;
    }
  }

  Future<String> checkOut() async {
    if (group ?? false) {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-checkOutGroup')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'booking_id': id,
            'sid': sID
          })
          .then((value) => value.data)
          .catchError((onError) => onError.message);
    } else {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-checkOut')
          .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id})
          .then((value) => value.data)
          .catchError((onError) => onError.message);
    }
  }

  Future<String> checkIn() async {
    if (group ?? false) {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-checkInGroup')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'booking_id': id,
            'sid': sID
          })
          .then((value) => value.data)
          .catchError((onError) => onError.message);
    } else {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-checkIn')
          .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id})
          .then((value) => value.data)
          .catchError((onError) => onError.message);
    }
  }

  Future<String> cancel() async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-cancel')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': id,
          'group': group,
          'sid': sID
        })
        .then((value) => value.data)
        .catchError((onError) {
          return onError.message;
        });
  }

  Future<String> noShow() async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-noShow')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': id,
          'group': group,
          'sid': sID
        })
        .then((value) => value.data)
        .catchError((onError) {
          return onError.message;
        });
  }

  Future<String> update(
      {String? name,
      String? phone,
      String? email,
      DateTime? inDateParam,
      DateTime? outDateParam,
      DateTime? inTimeParam,
      DateTime? outTimeParam,
      String? roomTypeID,
      String? room,
      List<num>? priceParam,
      String? ratePlanID,
      String? bed,
      bool? breakfast,
      bool? lunch,
      bool? dinner,
      bool? payAtHotel,
      int? adult,
      int? child,
      String? sourceID,
      bool? customerRequest,
      String? sID,
      bool? isTaxDeclare,
      Map<String, dynamic>? declarationInvoiceDetail,
      List<dynamic>? listGuestDeclaration,
      String? typeTouristsParam,
      String? countryParam,
      String? notes,
      String? saler,
      String? externalSaler,
      int? bookingType}) async {
    try {
      if (group ?? false) {
        final result = await FirebaseFunctions.instance
            .httpsCallable('booking-updateBookingGroup')
            .call({
          'booking_id': id,
          'hotel_id': GeneralManager.hotelID,
          'rate_plan_id': ratePlanID ?? this.ratePlanID,
          'name': name ?? this.name,
          'bed': bed ?? this.bed ?? '?',
          'in_date':
              inDateParam != null ? inDateParam.toString() : inDate.toString(),
          'out_date': outDateParam != null
              ? outDateParam.toString()
              : outDate.toString(),
          'room_id': room ?? this.room,
          'room_type_id': roomTypeID ?? this.roomTypeID,
          'source': sourceID ?? this.sourceID,
          'sid': sID ?? this.sID,
          'phone': phone ?? this.phone,
          'email': email ?? this.email,
          'breakfast': breakfast ?? this.breakfast,
          'lunch': lunch ?? this.lunch,
          'dinner': dinner ?? this.dinner,
          'pay_at_hotel': payAtHotel ?? this.payAtHotel,
          'adult': adult ?? this.adult,
          'child': child ?? this.child,
          'group': group ?? group,
          'price': priceParam ?? price,
          'tax_declare': isTaxDeclare,
          'declaration_invoice_detail': declarationInvoiceDetail,
          'list_guest_declaration': listGuestDeclaration,
          'type_tourists': typeTouristsParam ?? typeTourists,
          'country': countryParam ?? country,
          'notes': notes ?? await getNotes(),
          'saler': saler,
          'external_saler': externalSaler,
          'booking_type': bookingType ?? this.bookingType,
        });

        if (result.data == MessageCodeUtil.SUCCESS) {
          return MessageCodeUtil.SUCCESS;
        }
      } else {
        final result = await FirebaseFunctions.instance
            .httpsCallable('booking-updateBooking')
            .call({
          'booking_id': id,
          'hotel_id': GeneralManager.hotelID,
          'rate_plan_id': ratePlanID ?? this.ratePlanID,
          'name': name ?? this.name,
          'bed': bed ?? this.bed,
          'in_date':
              inDateParam != null ? inDateParam.toString() : inDate.toString(),
          'out_date': outDateParam != null
              ? outDateParam.toString()
              : outDate.toString(),
          'in_time':
              inTimeParam != null ? inTimeParam.toString() : inTime.toString(),
          'out_time': outTimeParam != null
              ? outTimeParam.toString()
              : outTime.toString(),
          'room_id': room ?? this.room,
          'room_type_id': roomTypeID ?? this.roomTypeID,
          'source': sourceID ?? this.sourceID,
          'sid': sID ?? this.sID,
          'phone': phone ?? this.phone,
          'email': email ?? this.email,
          'breakfast': breakfast ?? this.breakfast,
          'lunch': lunch ?? this.lunch,
          'dinner': dinner ?? this.dinner,
          'pay_at_hotel': payAtHotel ?? this.payAtHotel,
          'adult': adult ?? this.adult,
          'child': child ?? this.child,
          'group': group ?? group,
          'price': priceParam ?? price,
          'tax_declare': isTaxDeclare,
          'declaration_invoice_detail': declarationInvoiceDetail,
          'list_guest_declaration': listGuestDeclaration,
          'type_tourists': typeTouristsParam ?? typeTourists,
          'country': countryParam ?? country,
          'notes': notes ?? await getNotes(),
          'saler': saler,
          'external_saler': externalSaler,
          'booking_type': bookingType ?? this.bookingType,
        });

        if (result.data == MessageCodeUtil.SUCCESS) {
          return MessageCodeUtil.SUCCESS;
        }
      }
    } on FirebaseFunctionsException catch (error) {
      return error.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> undoCheckIn() async {
    if (group ?? false) {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-undoCheckInGroup')
          .call({
            'hotel_id': GeneralManager.hotelID,
            'booking_id': id,
            'sid': sID
          })
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    } else {
      return await FirebaseFunctions.instance
          .httpsCallable('booking-undoCheckIn')
          .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id})
          .then((value) => value.data)
          .onError((error, stackTrace) =>
              (error as FirebaseFunctionsException).message);
    }
  }

  Future<String> undoCheckout() async {
    try {
      if (group ?? false) {
        final result = await FirebaseFunctions.instance
            .httpsCallable('booking-undoCheckOutGroup')
            .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': id,
          'sid': sID,
        });
        if (result.data == MessageCodeUtil.SUCCESS) {
          return MessageCodeUtil.SUCCESS;
        }
      } else {
        final result = await FirebaseFunctions.instance
            .httpsCallable('booking-undoCheckout')
            .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id});
        if (result.data == MessageCodeUtil.SUCCESS) {
          return MessageCodeUtil.SUCCESS;
        }
      }
    } on FirebaseFunctionsException catch (error) {
      print(error);
      return error.message!;
    }
    return MessageCodeUtil.SUCCESS;
  }

  Future<String> setNonRoom() async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('booking-setNonRoom');
    return await callable({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      'group': group,
      'sid': sID
    }).then((value) => value.data);
  }

  Future<List<Transfer>?> getTransfers() async {
    try {
      List<Transfer> transfers = [];
      await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(id)
          .collection('transfers')
          .orderBy('created')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          transfers.add(Transfer(
              amount: doc.get('amount'),
              desc: doc.get('desc'),
              hotel: doc.get('hotel'),
              time: doc.get('created')));
        }
      });
      return transfers;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> deleteRepair() async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-deleteRepair')
        .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id}).then(
            (value) => value.data);
  }

  Future<String?> getNotes() async {
    try {
      final doc = await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBasicBookings)
          .doc(id)
          .get();
      if (doc.exists) return doc.get('notes');
      return "";
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String?> getNotesBySid() async {
    try {
      final doc = await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBookings)
          .doc(sID)
          .get();
      return doc.get('notes');
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<String>?> getStayDayById(String id) async {
    try {
      final doc = await FirebaseHandler.hotelRef
          .collection(FirebaseHandler.colBasicBookings)
          .doc(id)
          .get();
      return doc.data()!.containsKey('stay_days')
          ? (doc.get('stay_days') as List<dynamic>)
              .map((element) => element.toDate().toString())
              .toList()
          : [];
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> saveNotes(String notes) async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-saveNotes')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': (group ?? false) ? sID : id,
      'sid': sID,
      'group': group,
      'notes': notes
    }).then((value) => value.data);
  }

  Future<String> addDiscount(num amount, String desc) async {
    if (amount < 0) {
      return MessageCodeUtil.INPUT_POSITIVE_AMOUNT;
    }

    if (desc.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }

    return await FirebaseFunctions.instance
        .httpsCallable('booking-addDiscount')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': id,
          'sid': sID,
          'group': group,
          'discount_amount': amount,
          'discount_desc': desc
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> updateDiscount(
      num newAmount, String newDesc, String discountId) async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-updateDiscount')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'booking_id': id,
          'sid': sID,
          'group': group,
          'discount_amount': newAmount,
          'discount_desc': newDesc,
          'discount_id': discountId
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> deleteDiscount(String discountId) async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-deleteDiscount')
        .call({
          'hotel_id': GeneralManager.hotelID,
          'sid': sID,
          'group': group,
          'booking_id': id,
          'discount_id': discountId,
        })
        .then((value) => value.data)
        .onError((error, stackTrace) =>
            (error as FirebaseFunctionsException).message);
  }

  Future<String> addVirtual() async {
    final now = Timestamp.now();
    final now12h = DateUtil.to12h(now.toDate());

    if (outDate!.compareTo(now12h) < 0) {
      return MessageCodeUtil.OUTDATE_CAN_NOT_IN_PAST;
    }

    if (name!.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }

    inDate ??= now12h;
    id = NumberUtil.getSidByConvertToBase62();
    created = now;
    sID ??= id;

    return await FirebaseFunctions.instance
        .httpsCallable('booking-addVirtualBooking')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      'virtual_sid': sID,
      'virtual_indate': inDate.toString(),
      'virtual_outdate': outDate.toString(),
      'virtual_name': name,
      'virtual_phone': phone,
      'virtual_email': email,
      'virtual_created': created!.toDate().toString()
    }).then((value) => value.data);
  }

  Future<String> updateVirtual(
      {DateTime? outDate, String? name, String? phone, String? email}) async {
    if (!isVirtualBookingEditable()) {
      return MessageCodeUtil.FORBIDDEN;
    }

    final now = Timestamp.now();
    final now12h = DateUtil.to12h(now.toDate());

    if (outDate!.compareTo(now12h) < 0) {
      return MessageCodeUtil.OUTDATE_CAN_NOT_IN_PAST;
    }

    if (name!.isEmpty) {
      return MessageCodeUtil.CAN_NOT_BE_EMPTY;
    }
    return await FirebaseFunctions.instance
        .httpsCallable('booking-updateVirtualBooking')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
      'virtual_outdate': outDate.toString(),
      'virtual_name': name,
      'virtual_phone': phone,
      'virtual_email': email
    }).then((value) => value.data);
  }

  Future<String> checkOutVirtual() async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-checkoutVirtualBooking')
        .call({
      'hotel_id': GeneralManager.hotelID,
      'booking_id': id,
    }).then((value) => value.data);
  }

  Future<String> cancelVirtual() async {
    return await FirebaseFunctions.instance
        .httpsCallable('booking-cancelVirtualBooking')
        .call({'hotel_id': GeneralManager.hotelID, 'booking_id': id}).then(
            (value) => value.data);
  }

  bool isServiceUpdatable(Service service) {
    bool updatable = false;
    if (service.cat == ServiceManager.MINIBAR_CAT ||
        service.cat == ServiceManager.INSIDE_RESTAURANT_CAT) {
      updatable = isMinibarEditable();
    } else if (service.cat == ServiceManager.LAUNDRY_CAT) {
      updatable = isLaundryEditable();
    } else if (service.cat == ServiceManager.BIKE_RENTAL_CAT) {
      updatable = isBikeRentalEditable();
    } else if (service.cat == ServiceManager.EXTRA_GUEST_CAT) {
      updatable = isExtraGuestEditable();
    } else if (service.cat == ServiceManager.OTHER_CAT) {
      updatable = isOtherEditable();
    } else if (service.cat == ServiceManager.OUTSIDE_RESTAURANT_CAT) {
      updatable = isRestaurantServiceEditable();
    }

    if (updatable && service.deletable!) {
      return true;
    }

    return false;
  }

  bool isNameEditable() {
    if (status == BookingStatus.booked ||
        status == BookingStatus.repair ||
        status == BookingStatus.unconfirmed) {
      return true;
    }
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isPhoneEmailEditable() {
    if (status == BookingStatus.booked ||
        status == BookingStatus.checkin ||
        status == BookingStatus.unconfirmed) {
      return true;
    }

    return false;
  }

  bool isBreakfastEditable() {
    if (status == BookingStatus.booked || status == BookingStatus.unconfirmed) {
      return true;
    }
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isPayAtHotelEditable() {
    if (status == BookingStatus.booked || status == BookingStatus.unconfirmed) {
      return true;
    }
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isInDateEditable() {
    if (status == BookingStatus.booked ||
        status == BookingStatus.unconfirmed ||
        status == BookingStatus.repair) {
      return true;
    }

    return false;
  }

  bool isOutDateEditable() {
    if (status == BookingStatus.booked ||
        status == BookingStatus.checkin ||
        status == BookingStatus.repair ||
        status == BookingStatus.unconfirmed) return true;

    return false;
  }

  bool isRoomTypeEditable() {
    if (status == BookingStatus.booked || status == BookingStatus.checkin) {
      return true;
    }

    return false;
  }

  bool isRoomEditable() {
    if (status == BookingStatus.booked || status == BookingStatus.checkin) {
      return true;
    }

    return false;
  }

  bool isPriceEditable() {
    if (status == BookingStatus.booked) return true;
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isBedEditable() {
    if (status == BookingStatus.booked || status == BookingStatus.checkin) {
      return true;
    }

    return false;
  }

  bool isEditRatePlan() {
    if (status == BookingStatus.booked) {
      return true;
    }

    return false;
  }

  bool isAdultChildEditable() {
    if (status == BookingStatus.booked) return true;
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isSourceEditable() {
    if (status == BookingStatus.booked) return true;
    if (status == BookingStatus.checkin &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin))) return true;

    return false;
  }

  bool isSIDEditable() {
    if (status == BookingStatus.booked) return true;
    if (UserManager.role!.contains(Roles.manager) ||
        UserManager.role!.contains(Roles.owner) ||
        UserManager.role!.contains(Roles.admin)) return true;

    return false;
  }

  bool isMinibarEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isInsideRestaurantEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isLaundryEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isBikeRentalEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isOtherEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isRestaurantServiceEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isExtraGuestEditable() {
    if ((group ?? false) && id == sID) {
      return false;
    }
    if ((status == BookingStatus.booked ||
            status == BookingStatus.checkin ||
            status == BookingStatus.unconfirmed) &&
        (UserManager.role!.contains(Roles.manager) ||
            UserManager.role!.contains(Roles.owner) ||
            UserManager.role!.contains(Roles.receptionist) ||
            UserManager.role!.contains(Roles.sale) ||
            UserManager.role!.contains(Roles.housekeeping) ||
            UserManager.role!.contains(Roles.admin) ||
            UserManager.role!.contains(Roles.internalPartner))) return true;
    return false;
  }

  bool isDiscountEditable() {
    if ([BookingStatus.booked, BookingStatus.checkin].contains(status)) {
      return true;
    }

    return false;
  }

  bool isUpdatable() {
    if ([BookingStatus.booked, BookingStatus.checkin, BookingStatus.repair]
        .contains(status)) return true;

    return false;
  }

  bool canTransferDeposit() {
    if (status == BookingStatus.checkin) return true;

    return false;
  }

  bool canChangeRoom() {
    if ([BookingStatus.booked, BookingStatus.checkin].contains(status)) {
      return true;
    }

    return false;
  }

  bool isLiveBooking() {
    if ([BookingStatus.booked, BookingStatus.checkin, BookingStatus.checkout]
        .contains(status)) return true;

    return false;
  }

  bool canUpdateDeposit() {
    if ([BookingStatus.booked, BookingStatus.checkin, BookingStatus.unconfirmed]
        .contains(status)) {
      return true;
    }

    return false;
  }

  bool isVirtualBookingEditable() {
    if ([BookingStatus.booked].contains(status)) return true;

    return false;
  }

  String? decodeName() {
    try {
      if (status == BookingStatus.moved) {
        List<String> nameDividedToArray = name!.split(specificCharacter);
        return '${MessageUtil.getMessageByCode(MessageCodeUtil.TEXTALERT_MOVED_TO)} ${RoomManager().getNameRoomById(nameDividedToArray[1])} ${nameDividedToArray[2]}';
      }
      return GeneralManager.hotel!.showNameSource == TypeNameSource.nameSource
          ? "$name - ${SourceManager().getSourceNameByID(sourceID!)}"
          : GeneralManager.hotel!.showNameSource == TypeNameSource.name
              ? name
              : "${SourceManager().getSourceNameByID(sourceID!)} - $name";
    } catch (e) {
      return name;
    }
  }

  List<DateTime> getBookingByTypeMonth() {
    List<DateTime> staysDays = [];
    if (inDate!.month == outDate!.month) {
      staysDays = [DateTime(inDate!.year, inDate!.month)];
    } else {
      int startMonth = inDate!.month;
      int endMonth = outDate!.month;
      int startYear = inDate!.year;
      int endYear = outDate!.year;
      if (startYear == endYear) {
        for (var i = startMonth; i <= endMonth; i++) {
          staysDays.add(DateTime(endYear, i));
        }
      } else {
        for (var i = startMonth; i <= 12; i++) {
          staysDays.add(DateTime(startYear, i));
        }
        for (var i = 1; i <= endMonth; i++) {
          staysDays.add(DateTime(endYear, i));
        }
      }
    }
    return staysDays;
  }

  Map<String, Set<String>> getMapDayByMonth() {
    Map<String, Set<String>> dataMap = {};
    dataMap["stays_month"] = {};
    dataMap["stays_day"] = {};
    List<DateTime> data = DateUtil.getStaysDay(inDate!, outDate!);
    List<DateTime> staysDayMonth = getBookingByTypeMonth();
    int index = 0;
    if (staysDayMonth.length > 1) {
      DateTime lastDay = outDate!;
      for (var i = 1; i < staysDayMonth.length; i++) {
        lastDay = DateTime(
            (inDate!.year == outDate!.year ? outDate!.year : inDate!.year),
            inDate!.month + i,
            inDate!.day - 1,
            12);
        if (data.contains(lastDay)) {
          dataMap["stays_month"]!.add(
              "${DateUtil.dateToDayMonthString(DateTime(inDate!.year, inDate!.month + index, inDate!.day))}-${DateUtil.dateToDayMonthString(lastDay)}");
          index++;
        }
      }
      bool checkOtherYear =
          !(inDate!.year != outDate!.year && inDate!.day == outDate!.day);
      DateTime lastOutDate =
          DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
      if ((lastOutDate.isBefore(outDate!) || lastOutDate.isAfter(outDate!)) &&
          checkOtherYear) {
        DateTime firstDay =
            DateTime(inDate!.year, inDate!.month + index, inDate!.day, 12);
        dataMap["stays_month"]!.add(
            "${DateUtil.dateToDayMonthString(firstDay)}-${DateUtil.dateToDayMonthString(DateTime(outDate!.year, outDate!.month, outDate!.day - 1))}");
        for (var element in DateUtil.getStaysDay(firstDay, outDate!)) {
          dataMap["stays_day"]!.add(DateUtil.dateToDayMonthString(element));
        }
      }
    } else {
      dataMap["stays_month"]!.add(
          "${DateUtil.dateToDayMonthString(inDate!)}-${DateUtil.dateToDayMonthString(DateTime(outDate!.year, outDate!.month, outDate!.day - 1))}");
      for (var element in DateUtil.getStaysDay(inDate!, outDate!)) {
        dataMap["stays_day"]!.add(DateUtil.dateToDayMonthString(element));
      }
    }
    return dataMap;
  }

  Set<String> getDayByMonth() {
    Set<String> dataMonth = {};
    List<DateTime> data = DateUtil.getStaysDay(inDate!, outDate!);
    List<DateTime> staysDayMonth = getBookingByTypeMonth();
    int index = 0;
    DateTime lastDay = outDate!;
    bool check = false;
    for (var i = 1; i < staysDayMonth.length; i++) {
      lastDay = DateTime(
          (inDate!.year == outDate!.year ? outDate!.year : inDate!.year),
          inDate!.month + i,
          inDate!.day - 1,
          inDate!.hour);
      if (data.contains(lastDay)) {
        dataMonth.add(
            "${DateUtil.dateToDayMonthYearString(DateTime(inDate!.year, inDate!.month + index, inDate!.day))} - ${DateUtil.dateToDayMonthYearString(lastDay)}");
        check = true;
        index++;
      }
    }
    DateTime lastOutDate =
        DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
    if (lastOutDate.isBefore(outDate!) || lastOutDate.isAfter(outDate!)) {
      if (check) {
        dataMonth.remove(
            "${DateUtil.dateToDayMonthYearString(DateTime(inDate!.year, inDate!.month + index - 1, inDate!.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(lastDay.year, lastDay.month, lastDay.day, 12))}");
      }
      dataMonth.add(
          "${DateUtil.dateToDayMonthYearString(DateTime(inDate!.year, inDate!.month + index - (check ? 1 : 0), inDate!.day))} - ${DateUtil.dateToDayMonthYearString(DateTime(outDate!.year, outDate!.month, outDate!.day - 1))}");
    }
    return dataMonth;
  }

  num getPrieDayByMonthly(
      DateTime inDate, DateTime outDate, List<dynamic> prices) {
    num priceRoomByDay = 0;
    List<DateTime> data = DateUtil.getStaysDay(inDate, outDate);
    List<DateTime> staysDayMonth = getBookingByTypeMonth();
    int index = 0;
    DateTime lastDay = outDate;
    bool checkUpdatePricer = true;
    for (var i = 1; i < staysDayMonth.length; i++) {
      lastDay = DateTime(
          (inDate.year == outDate.year ? outDate.year : inDate.year),
          inDate.month + i,
          inDate.day - 1,
          12);
      if (data.contains(lastDay)) {
        priceRoomByDay += prices[index];
        checkUpdatePricer = false;
        index++;
      }
    }
    DateTime lastOutDate =
        DateTime(lastDay.year, lastDay.month, lastDay.day + 1, 12);
    if (lastOutDate.isBefore(outDate) || lastOutDate.isAfter(outDate)) {
      DateTime firstDay =
          DateTime(inDate.year, inDate.month + index, inDate.day, 12);
      index = checkUpdatePricer ? 1 : (index + 1);
      List<DateTime> staysDayLast = DateUtil.getStaysDay(firstDay, outDate);
      for (var i = index; i < (staysDayLast.length + index); i++) {
        priceRoomByDay += prices[i];
      }
    }
    return priceRoomByDay;
  }

  Map<String, num> getRoomChargeByDateCostumExprot(
      {DateTime? inDate, DateTime? outDate}) {
    List<DateTime> staydaysBookingMonth =
        DateUtil.getStaysDay(this.inDate!, this.outDate!);
    Map<String, num> totalPriceToMonth = {};
    num priceToMonth = 0;
    int index = 0;
    bool checkUpdatePricer = true;
    List<DateTime> staysDaysByMonth = getBookingByTypeMonth();
    List<DateTime> staydaysBookingMonthCustom = DateUtil.getStaysDay(
        inDate!, DateTime(outDate!.year, outDate.month, outDate.day + 1));
    DateTime lastDay = this.outDate!;
    List<DateTime> staysDayLast = [];
    for (var i = 1; i < staysDaysByMonth.length; i++) {
      lastDay = DateTime(
          (this.inDate!.year == this.outDate!.year
              ? this.outDate!.year
              : this.inDate!.year),
          this.inDate!.month + i,
          this.inDate!.day - 1,
          this.inDate!.hour);
      if (staydaysBookingMonth.contains(lastDay)) {
        List<DateTime> staysDayFirst = DateUtil.getStaysDay(
            DateTime(this.inDate!.year, (this.inDate!.month + index),
                this.inDate!.day),
            DateTime(lastDay.year, lastDay.month, lastDay.day + 1));
        priceToMonth = (price![index] / staysDayFirst.length).round();
        for (var element in staysDayFirst) {
          if (staydaysBookingMonthCustom.contains(element)) {
            totalPriceToMonth[DateUtil.dateToDayMonthYearString(element)] =
                priceToMonth;
          }
        }
        checkUpdatePricer = false;
        index++;
      }
    }
    DateTime lastOutDate = DateTime(
        lastDay.year, lastDay.month, (lastDay.day + 1), this.outDate!.hour);
    if (lastOutDate.isAfter(this.outDate!) ||
        lastOutDate.isBefore(this.outDate!)) {
      DateTime firstDay = DateTime(
          this.inDate!.year, this.inDate!.month + index, this.inDate!.day);
      index = checkUpdatePricer ? 1 : (index + 1);
      staysDayLast = DateUtil.getStaysDay(
          firstDay,
          DateTime(
              this.outDate!.year, this.outDate!.month, this.outDate!.day + 1));
      for (var i = 0; i < staysDayLast.length; i++) {
        if (staydaysBookingMonthCustom.contains(staysDayLast[i])) {
          totalPriceToMonth[
                  DateUtil.dateToDayMonthYearString(staysDayLast[i])] =
              price![index];
        }
        index++;
      }
    }
    return totalPriceToMonth;
  }
}
