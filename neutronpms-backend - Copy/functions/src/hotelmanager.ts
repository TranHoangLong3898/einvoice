import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { firestore } from 'firebase-admin';
import { BookingStatus } from './constant/status';
import { HotelPackage } from './constant/type';
import { UserRole } from './constant/userrole';
import { DateUtil } from './util/dateutil';
import { HLSUtil } from './util/hlsutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';

const fireStore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const FieldPath = admin.firestore.FieldPath;

exports.createHotel = functions.https.onCall(async (data, context) => {
  const now = DateUtil.convertUpSetTimezone(new Date(), data.timezone);
  const userRole: { [key: string]: string[] } = {};
  if (context.auth?.uid === undefined) return false;
  userRole[context.auth?.uid] = [UserRole.owner];
  userRole[NeutronUtil.uidAdmin] = [UserRole.admin];
  userRole[NeutronUtil.uidSupport] = [UserRole.support];
  let idHotelAfterCreate = '';
  await fireStore.collection('hotels').add({
    'name': data.name,
    'email': data.email,
    'phone': data.phone,
    'street': data.street,
    'city': data.city,
    'country': data.country,
    'timezone': data.timezone,
    'currencyCode': data.currencyCode,
    'users': [context.auth?.uid, NeutronUtil.uidAdmin, NeutronUtil.uidSupport],
    'package': HotelPackage.basic,
    'role': userRole,
    'auto_export_items': data.auto_export_items
  }).then((docRef) => idHotelAfterCreate = docRef.id);

  await fireStore.collection('users').doc(context.auth.uid).update({
    'hotels': firestore.FieldValue.arrayUnion(idHotelAfterCreate),
    'hotels_name': firestore.FieldValue.arrayUnion(data.name),
  });

  const dataServiceStatus: any[] = [];
  const roles = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.housekeeping, UserRole.receptionist, UserRole.accountant, UserRole.sale];
  dataServiceStatus.push({
    'done': false,
    'role': roles,
    'status': 'open'
  });
  dataServiceStatus.push({
    'done': true,
    'role': roles,
    'status': 'passed'
  });
  dataServiceStatus.push({
    'done': true,
    'role': roles,
    'status': 'failed'
  });

  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('configurations').create({
    'data': {
      'rooms': {}, 'room_types': {}, 'laundries': {}, 'bikes': {}, 'timezone': data.timezone,
      'rate_plan': {
        'OTA': { 'amount': 0, 'percent': true, 'is_delete': false, 'decs': 'OTA Rate Plan', 'is_default': false },
        'Standard': { 'amount': 0, 'percent': true, 'is_delete': false, 'decs': 'Standard Rate Plan', 'is_default': true }
      },
      'other_services': {
        'bike_rental': { 'active': true, 'name': 'Bike rental' },
        'ota': { 'active': true, 'name': 'OTA Service' },
        'ai': { 'active': true, 'name': 'Airport welcome' },
        'an': { 'active': true, 'name': 'Anniversary' },
        'bi': { 'active': true, 'name': 'Birthday' },
        'br': { 'active': true, 'name': 'Breakfast' },
        'car': { 'active': true, 'name': 'Car rental' },
        'com': { 'active': true, 'name': 'Compensation' },
        'ho': { 'active': true, 'name': 'Honeymoon' },
        'pen': { 'active': true, 'name': 'Penalty' },
        'tour': { 'active': true, 'name': 'Tour' },
        'up': { 'active': true, 'name': 'Upgrade' },
        'others': { 'active': true, 'name': 'Others' }
      },
      'suppliers': {
        'inhouse': {
          'active': true,
          'name': data.name,
          'services': ['bike_rental', 'ota', 'ai', 'an', 'bi', 'br', 'car', 'com', 'ho', 'pen', 'tour', 'up', 'others']
        }
      },
      'tax': {
        'service_fee': 0.05,
        'vat': 0.1
      },
      'service_statuses': {
        'statuses': dataServiceStatus
      },
      'sources': {
        'di': {
          'name': 'Direct',
          'active': true
        },
        'virtual': {
          'name': 'Virtual',
          'active': true
        },
        'ta': {
          'name': 'Travel Agency',
          'active': true,
          'mapping_source': '',
          'ota': false
        },
        'co': {
          'name': 'Cooperate',
          'active': true,
          'mapping_source': '',
          'ota': false
        },
        'to': {
          'name': 'Tour Operator',
          'active': true,
          'mapping_source': '',
          'ota': false
        },
        'ag': {
          'name': 'Agoda',
          'active': true,
          'mapping_source': 'Agoda',
          'ota': true
        },
        'bk': {
          'name': 'Booking.com',
          'active': true,
          'mapping_source': 'Booking.com',
          'ota': true
        },
        'tv': {
          'name': 'Traveloka',
          'active': true,
          'mapping_source': 'Traveloka',
          'ota': true
        },
        'ex': {
          'name': 'Expedia',
          'active': true,
          'mapping_source': 'Expedia',
          'ota': true
        },
        'tr': {
          'name': 'Trip',
          'active': true,
          'mapping_source': 'Ctrip (B2C)',
          'ota': true
        },
        'ab': {
          'name': 'Airbnb',
          'active': true,
          'mapping_source': 'Airbnb',
          'ota': true
        },
        'fb': {
          'name': 'Facebook',
          'active': true,
          'mapping_source': '',
          'ota': false
        },
        'ot': {
          'name': 'Others',
          'active': true,
          'mapping_source': '',
          'ota': false
        }
      }
    }
  });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('items').create({ 'data': {} });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('overdue_bookings').create({ 'overdue_bookings': { 'checkin': {}, 'checkout': {} } });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('reception_cash').create({ 'total': 0 });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('restaurants').create({ 'data': {} });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('warehouses').create({ 'data': {} });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('revenue').create({ 'ca': 0 });
  await fireStore.collection('hotels').doc(idHotelAfterCreate).collection('management').doc('payment_methods').create({
    'data': {
      "BD": {
        'is_delete': false,
        'name': 'Bank Deposit',
        'status': ["open", "passed", "failed"],
      },
      "FOC": {
        'is_delete': false,
        'name': 'FOC',
        'status': ["open", "passed", "failed"],
      },
      "PBA": {
        'is_delete': false,
        'name': 'Private Bank',
        'status': ["open", "passed", "failed"],
      },
      "ba": {
        'is_delete': false,
        'name': 'Bank',
        'status': ["open", "passed", "failed"],
      },
      "ca": {
        'is_delete': false,
        'name': 'Cash',
        'status': ["open", "passed", "failed"],
      },
      "cade": {
        'is_delete': false,
        'name': 'Cash Deposit',
        'status': ["open", "passed", "failed"],
      },
      "cc": {
        'is_delete': false,
        'name': 'Credit card',
        'status': ["open", "passed", "failed"],
      },
      "cd": {
        'is_delete': false,
        'name': 'Credit deposit',
        'status': ["open", "passed", "failed"],
      },
      "de": {
        'is_delete': false,
        'name': 'City Ledger',
        'status': ["open", "passed", "failed"],
      },
      "mo": {
        'is_delete': false,
        'name': 'MoMo',
        'status': ["open", "passed", "failed"],
      },
      "ota": {
        'is_delete': false,
        'name': 'OTA',
        'status': ["open", "charged", "passed", "failed"],
      },
      "transfer": {
        'is_delete': false,
        'name': 'Transfer',
        'status': ["open", "passed", "failed"],
      },
      "vn": {
        'is_delete': false,
        'name': 'VN Pay',
        'status': ["open", "passed", "failed"],
      },
      "zl": {
        'is_delete': false,
        'name': 'Zalo Pay',
        'status': ["open", "passed", "failed"],
      },
    }
  });

  const batch = fireStore.batch();
  for (let i = 0; i < 24; i++) {
    const id = DateUtil.addMonthToStringYearMonth(now, i);
    const lastDayInMonth: number = new Date(parseInt(id.substring(0, 4)), parseInt(id.substring(4, 6)), 0).getDate();
    const dataDay: { [key: string]: any } = {};
    for (let day = 1; day <= lastDayInMonth; day++) {
      dataDay[day] = {};
    };
    batch.set(
      fireStore
        .collection('hotels')
        .doc(idHotelAfterCreate)
        .collection('daily_allotment')
        .doc(id),
      { 'data': dataDay });
  }
  await batch.commit();
  return idHotelAfterCreate;
})

exports.editHotel = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.id_hotel).get();

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.HOTEL_CAN_NOT_EDIT_INFO);
  }
  // tool async data daily
  // const dataDaily = await fireStore.collection('hotels').doc(data.id_hotel).collection('daily_allotment').doc('202205').get();
  // if (dataDaily !== undefined) {
  //   await fireStore.collection('hotels').doc(data.id_hotel).collection('daily_allotment').doc('202203').set({ 'data': dataDaily.get('data') });
  //   await fireStore.collection('hotels').doc(data.id_hotel).collection('daily_allotment').doc('202204').set({ 'data': dataDaily.get('data') });
  // }
  await fireStore.collection('hotels').doc(data.id_hotel).update({
    'name': data.name,
    'email': data.email,
    'phone': data.phone,
    'street': data.street,
    'city': data.city,
    'country': data.country,
    'timezone': data.timezone,
    'currencyCode': data.currencyCode,
    'auto_export_items': data.auto_export_items
  });
  if (data.name !== hotelRef.get("name")) {
    for (const uid of hotelRef.get("users")) {
      const userRer = await fireStore.collection('users').doc(uid).get();
      if (userRer?.get("hotels_name") !== undefined) {
        const index = userRer.get("hotels_name").indexOf(hotelRef.get("name"));
        const dataUpdate = userRer.get("hotels_name");
        dataUpdate[index] = data.name;
        await fireStore.collection('users').doc(uid).update({
          "hotels_name": dataUpdate
        });
      }
    }
  }
  return MessageUtil.SUCCESS;;
});

exports.createRoomType = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
  const hotelDoc = await hotelRef.get();

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  if (data.room_type_min_price > data.room_type_price) {
    throw new functions.https.HttpsError('not-found', MessageUtil.MIN_PRICE_MUST_SMALLER_THAN_PRICE);
  }

  const bedsChoose: string[] = data.room_type_beds;

  if (bedsChoose.length > 1) {
    bedsChoose.push('?');
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    // get daily allotment if have mapping key or id
    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
    }
    const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];

    if (roomTypes[data.room_type_id] !== undefined) {
      throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_ID_DUPICATED)
    }


    Object.keys(roomTypes).map((key) => {
      if (roomTypes[key]['name'] === data.room_type_name && roomTypes[key]['is_delete'] === false) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_NAME_DUPICATED)
      }
    })
    const dataUpdate: { [key: string]: any } = {};
    dataUpdate['data.room_types.' + data.room_type_id + '.name'] = data.room_type_name;
    dataUpdate['data.room_types.' + data.room_type_id + '.guest'] = data.room_type_guest;
    dataUpdate['data.room_types.' + data.room_type_id + '.num'] = 0;
    dataUpdate['data.room_types.' + data.room_type_id + '.price'] = data.room_type_price;
    dataUpdate['data.room_types.' + data.room_type_id + '.min_price'] = data.room_type_min_price;
    dataUpdate['data.room_types.' + data.room_type_id + '.beds'] = bedsChoose;
    dataUpdate['data.room_types.' + data.room_type_id + '.is_delete'] = false;

    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;

})

exports.editRoomType = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  }

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelID: string = data.hotel_id;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const timezone: string = hotelDoc.get('timezone');
  const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
  const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');

  const roomTypeID: string = data.room_type_id;
  const roomTypeName: string = data.room_type_name;
  const roomTypePriceNew: number = data.room_type_price;
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateRoomType;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  if (data.room_type_min_price > roomTypePriceNew) {
    throw new functions.https.HttpsError('not-found', MessageUtil.ROOMTYPE_MIN_PRICE);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
    }

    const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];
    if (roomTypes[roomTypeID]['is_delete'] === true) {
      throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_NOT_FOUND)
    }

    Object.keys(roomTypes).map((key) => {
      if (roomTypes[key]['name'] === roomTypeName && key !== roomTypeID && roomTypes[key]['is_delete'] === false) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_NAME_DUPICATED)
      }
    })

    const bedsChoose: string[] = data.room_type_beds;
    const indexOfNone = bedsChoose.indexOf('?');
    if (bedsChoose.length === 1 && indexOfNone !== -1) {
      throw new functions.https.HttpsError('invalid-argument', MessageUtil.INPUT_TYPE_OF_BED)
    };

    if (bedsChoose.length === 2 && indexOfNone !== -1) {
      bedsChoose.splice(indexOfNone, 1);
    } else if (bedsChoose.length >= 2 && indexOfNone === -1) {
      bedsChoose.push('?');
    };

    const dataUpdate: { [key: string]: any } = {};
    dataUpdate['data.room_types.' + roomTypeID + '.name'] = roomTypeName;
    dataUpdate['data.room_types.' + roomTypeID + '.guest'] = data.room_type_guest;
    dataUpdate['data.room_types.' + roomTypeID + '.price'] = roomTypePriceNew;
    dataUpdate['data.room_types.' + roomTypeID + '.min_price'] = data.room_type_min_price;
    dataUpdate['data.room_types.' + roomTypeID + '.beds'] = bedsChoose;

    const rooms: Map<string, any> = new Map(Object.entries(configurationRef.get('data')['rooms']));
    rooms.forEach((value, key) => {
      if (value['room_type'] !== roomTypeID) return;
      const bedOfRoom: string = value['bed'];
      if (bedsChoose.includes(bedOfRoom)) return;
      dataUpdate['data.rooms.' + key + '.bed'] = bedsChoose[0];
    })

    if (roomTypes[roomTypeID]['price'] !== roomTypePriceNew && mappingHotelID !== undefined && mappingHotelKey !== undefined) {
      // update to daily allotment price here
      const roomTypeCM = await NeutronUtil.getCmRoomType(hotelID, roomTypeID);
      const nowServer: Date = new Date();
      const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
      const startMonthID = DateUtil.dateToShortStringYearMonth(nowTimezone);
      const from: string = startMonthID.substring(0, 4) + '-' + startMonthID.substring(4, 6) + '-' + (nowTimezone.getDate() < 10 ? '0' + nowTimezone.getDate() : nowTimezone.getDate());
      const endMonthID = DateUtil.addMonthToStringYearMonth(nowTimezone, 22);
      const lastDayInMonth: number = new Date(parseInt(endMonthID.substring(0, 4)), parseInt(endMonthID.substring(4, 6)), 0).getDate();
      const to: string = endMonthID.substring(0, 4) + '-' + endMonthID.substring(4, 6) + '-' + lastDayInMonth;
      const result = await HLSUtil.updateInventory(mappingHotelID, mappingHotelKey, roomTypeCM.id, from, to, roomTypeCM.ratePlanID, 'Rate', roomTypePriceNew);
      if (result === null) {
        console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
      }
    }

    t.update(hotelRef.collection('management').doc('configurations'), dataUpdate)
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    console.log(error.message);
    ; throw new functions.https.HttpsError('permission-denied', error.message)
  })
  return res;
})

exports.deleteRoomType = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
    }

    const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];

    if (roomTypes[data.room_type_id]['is_delete'] === true) {
      throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_NOT_FOUND)
    }

    const rooms: { [key: string]: any } = configurationRef.get('data')['rooms'];
    Object.keys(rooms).map(id => {
      if (rooms[id]['room_type'] === data.room_type_id && rooms[id]['is_delete'] === false) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_MUST_DELETE_ALL_ROOM)
      }
    })
    const dataUpdate: { [key: string]: any } = {};
    dataUpdate['data.room_types.' + data.room_type_id + '.is_delete'] = true;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message);
  })
  return res;
})

exports.createRoom = functions.https.onCall(async (data, context) => {

  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
  const hotelDoc = await hotelRef.get();
  const timezone: string = hotelDoc.get('timezone');
  const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
  const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
  const timeZone = DateUtil.convertUpSetTimezone(new Date(), timezone);
  const roomTypeId: string = data.room_type_id;
  const roomName: string = data.room_name;
  const roomID: string = data.room_id;
  const auto_rate: boolean = hotelDoc.get('auto_rate') ?? true;
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationDoc = await t.get(hotelRef.collection('management').doc('configurations'));

    if (!configurationDoc.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }
    const rooms: { [key: string]: any } = configurationDoc.get('data')['rooms'];

    const quantityRoomOfRoomType = configurationDoc.get(`data.room_types.${roomTypeId}.num`);


    const roomTypes: { [key: string]: any } = configurationDoc.get('data')['room_types'];

    if (roomTypes[roomTypeId]['is_delete'] === true) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOMTYPE_NOT_FOUND)
    }


    if (rooms[roomID] !== undefined) {
      throw new functions.https.HttpsError('already-exists', MessageUtil.ROOM_ID_DUPLICATED)
    }

    Object.keys(rooms).map((key) => {
      if (rooms[key]['name'] === data.room_name && rooms[key]['is_delete'] === false) {
        throw new functions.https.HttpsError('already-exists', MessageUtil.ROOM_NAME_DUPLICATED)
      }
    })
    const dataUpdate: { [key: string]: any } = {};

    const bedOfRoomType: string[] = roomTypes[roomTypeId]['beds'];
    bedOfRoomType.filter(bed => bed !== '?');

    const listDoc: string[] = [];
    for (let i = 0; i < 24; i++) {
      const monthId = DateUtil.addMonthToStringYearMonth(timeZone, i);
      const dailyAllotmentDoc = await t.get(hotelRef.collection('daily_allotment')
        .doc(monthId));
      if (!dailyAllotmentDoc.exists) {
        listDoc.push(monthId)
      }
    }

    if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
      const nowServer: Date = new Date();
      const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
      const inMonthID = DateUtil.dateToShortStringYearMonth(nowTimezone);
      const almMap: { [key: string]: any } = {};
      const roomTypeCM = await NeutronUtil.getCmRoomType(hotelDoc.id, roomTypeId);
      almMap[roomTypeCM.id] = null;
      const dailyAllotments = await t.get(hotelRef.collection('daily_allotment').where(FieldPath.documentId(), '>=', inMonthID));
      for (const dailyMonth of dailyAllotments.docs) {
        if (dailyMonth.id === inMonthID) {
          Object.keys(dailyMonth.get('data')).map((day) => {
            if (dailyMonth.get('data')[day][roomTypeId] === undefined) {
              if (Number.parseInt(day) >= nowTimezone.getDate()) {
                const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                if (almMap[roomTypeCM.id] === null) {
                  almMap[roomTypeCM.id] = {};
                }
                almMap[roomTypeCM.id][dateHls] = {};
                almMap[roomTypeCM.id][dateHls]['num'] = quantityRoomOfRoomType + 1;
                almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
              }
            } else {
              if (Number.parseInt(day) >= nowTimezone.getDate() && dailyMonth.get('data')[day][roomTypeId]['num'] !== quantityRoomOfRoomType) {
                const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                if (almMap[roomTypeCM.id] === null) {
                  almMap[roomTypeCM.id] = {};
                }
                almMap[roomTypeCM.id][dateHls] = {};
                almMap[roomTypeCM.id][dateHls]['num'] = dailyMonth.get('data')[day][roomTypeId]['num'] + 1;
                almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
              }
            }
          })
        } else {
          Object.keys(dailyMonth.get('data')).map((day) => {
            if (dailyMonth.get('data')[day][roomTypeId] === undefined) {
              if (day !== 'default') {
                const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                if (almMap[roomTypeCM.id] === null) {
                  almMap[roomTypeCM.id] = {};
                }
                almMap[roomTypeCM.id][dateHls] = {};
                almMap[roomTypeCM.id][dateHls]['num'] = quantityRoomOfRoomType + 1;
                almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
              }
            } else {
              if (day !== 'default' && dailyMonth.get('data')[day][roomTypeId]['num'] !== quantityRoomOfRoomType) {
                const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                if (almMap[roomTypeCM.id] === null) {
                  almMap[roomTypeCM.id] = {};
                }
                almMap[roomTypeCM.id][dateHls] = {};
                almMap[roomTypeCM.id][dateHls]['num'] = dailyMonth.get('data')[day][roomTypeId]['num'] + 1;
                almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
              }

            }
          })
        }
      }

      const almMapNew: { [key: string]: any } = {};
      almMapNew[roomTypeCM.id] = {};
      const dateFrom = inMonthID.toString().substring(0, 4) + '-' + inMonthID.toString().substring(4, 6) + '-' + (nowTimezone.getDate() < 10 ? '0' + nowTimezone.getDate() : nowTimezone.getDate());

      const outMonth = dailyAllotments.docs[dailyAllotments.size - 2].id;
      const lastDayInOutMonth: number = new Date(parseInt(outMonth.substring(0, 4)), parseInt(outMonth.substring(4, 6)), 0).getDate();
      const dateTo = outMonth.toString().substring(0, 4) + '-' + outMonth.toString().substring(4, 6) + '-' + lastDayInOutMonth;
      almMapNew[roomTypeCM.id]['num'] = quantityRoomOfRoomType + 1;
      almMapNew[roomTypeCM.id]['ratePlanID'] = '';
      const resultFromToEndHls = await HLSUtil.updateAvaibilityWithNewMonthToCM(mappingHotelID, mappingHotelKey, almMapNew, dateFrom, dateTo, auto_rate);

      ///sửa
      // if (resultFromToEndHls === null) {
      //   throw new functions.https.HttpsError('cancelled', MessageUtil.CM_UPDATE_AVAIBILITY_FAIL)
      // }

      if (almMap[roomTypeCM.id] !== null && resultFromToEndHls !== null) {
        const result = HLSUtil.updateMultipleAvaibility(mappingHotelID, mappingHotelKey, almMap, auto_rate);
        if (result === null) {
          throw new functions.https.HttpsError('cancelled', MessageUtil.CM_UPDATE_AVAIBILITY_FAIL)
        }
      }
    }

    dataUpdate['data.rooms.' + roomID + '.name'] = roomName;
    dataUpdate['data.rooms.' + roomID + '.bid'] = null;
    dataUpdate['data.rooms.' + roomID + '.binfo'] = null;
    dataUpdate['data.rooms.' + roomID + '.clean'] = true;
    dataUpdate['data.rooms.' + roomID + '.room_type'] = roomTypeId;
    dataUpdate['data.rooms.' + roomID + '.bed'] = bedOfRoomType[0];
    dataUpdate['data.rooms.' + roomID + '.is_delete'] = false;
    t.update(hotelRef.collection('management').doc('configurations'), dataUpdate)
    if (listDoc.length > 0) {
      for (const moth of listDoc) {
        t.create(hotelRef.collection('daily_allotment')
          .doc(moth), { "data": {} })
      }
    }
    return MessageUtil.SUCCESS
  }).catch((error) => {
    throw new functions.https.HttpsError('already-exists', error.message);
  })
  return res;
})

exports.editRoom = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelID = data.hotel_id;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const roomTypeIDNew: string = data.room_type_id;
  const roomId: string = data.room_id;
  const roomName: string = data.room_name;

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];

    if (roomTypes[roomTypeIDNew]['is_delete'] === true) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOMTYPE_NOT_FOUND)
    }

    const rooms: { [key: string]: any } = configurationRef.get('data')['rooms'];

    if (rooms[roomId]['is_delete'] === true) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOM_NOT_FOUND)
    }

    if (rooms[roomId]['room_type'] !== roomTypeIDNew) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOM_TYPE_OF_ROOM_CANNOT_EDIT)
    }

    Object.keys(rooms).map((key) => {
      if ((rooms[key]['name'] === roomName) && (key !== roomId) && rooms[key]['is_delete'] === false) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.ROOM_NAME_DUPICATED)
      }
    })

    const dataUpdate: { [key: string]: any } = {};
    if (roomTypeIDNew !== rooms[roomId]['room_type']) {
      dataUpdate['data.room_types.' + roomTypeIDNew + '.num'] = FieldValue.increment(1);
      dataUpdate['data.room_types.' + rooms[roomId]['room_type'] + '.num'] = FieldValue.increment(-1);
      const bedOfRoomType: string[] = roomTypes[roomTypeIDNew]['beds'];
      bedOfRoomType.filter(bed => bed !== '?');
      dataUpdate['data.rooms.' + roomId + '.bed'] = bedOfRoomType[0];
      dataUpdate['data.rooms.' + roomId + '.room_type'] = roomTypeIDNew;
    }
    dataUpdate['data.rooms.' + roomId + '.name'] = roomName;


    t.update(hotelRef.collection('management').doc('configurations'), dataUpdate)
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    console.log(error.message);
    throw new functions.https.HttpsError('invalid-argument', error.message)
  });
  return res;
})

exports.deleteRoom = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  const hotelID: string = data.hotel_id;
  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const timezone: string = hotelDoc.get('timezone');
  const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
  const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
  const roomID: string = data.room_id;

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationDoc = await t.get(hotelRef.collection('management').doc('configurations'));
    const rooms: { [key: string]: any } = configurationDoc.get('data')['rooms'];
    const quantityRoomOfRoomType = configurationDoc.get(`data.room_types.${rooms[roomID]['room_type']}.num`);

    if (!configurationDoc.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }


    if (rooms[roomID]['bid'] !== null) {
      throw new functions.https.HttpsError('failed-precondition', MessageUtil.ROOM_HAS_BOOKING_CHECKIN)
    }

    if (rooms[roomID]['is_delete'] === true) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOM_NOT_FOUND)
    }


    // validate booking 
    const basicBookingDocs = await t.get(hotelRef.collection('basic_bookings').where('room', '==', roomID).where('status', '==', BookingStatus.booked).limit(1));

    if (!basicBookingDocs.empty) {
      throw new functions.https.HttpsError('failed-precondition', MessageUtil.ROOM_HAVE_BOOKING_PLEASE_MOVE_BOOKING_BEFORE_DELETE_ROOM)
    }


    const dataUpdate: { [key: string]: any } = {};
    if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {

      const nowServer: Date = new Date();
      const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
      const inMonthID = DateUtil.dateToShortStringYearMonth(nowTimezone);
      const almMap: { [key: string]: any } = {};
      const roomTypeID: string = rooms[roomID]['room_type'];
      const roomTypeCM = await NeutronUtil.getCmRoomType(hotelDoc.id, roomTypeID);
      almMap[roomTypeCM.id] = null;

      const dailyAllotments = await t.get(hotelRef.collection('daily_allotment').where(FieldPath.documentId(), '>=', inMonthID));
      // just check day different with daily allotment
      for (const dailyMonth of dailyAllotments.docs) {
        if (dailyMonth.id === inMonthID) {
          Object.keys(dailyMonth.get('data')).map((day) => {
            if (day !== 'default' && Number.parseInt(day) >= nowTimezone.getDate() && dailyMonth.get('data')[day][roomTypeID]['num'] !== quantityRoomOfRoomType) {
              const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
              if (almMap[roomTypeCM.id] === null) {
                almMap[roomTypeCM.id] = {};
              }
              almMap[roomTypeCM.id][dateHls] = {};
              almMap[roomTypeCM.id][dateHls]['num'] = dailyMonth.get('data')[day][roomTypeID]['num'] - 1 > 0 ? dailyMonth.get('data')[day][roomTypeID]['num'] - 1 : 0;
              almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
            }
          })
        } else {
          Object.keys(dailyMonth.get('data')).map((day) => {
            if (day !== 'default' && dailyMonth.get('data')[day][roomTypeID]['num'] !== quantityRoomOfRoomType) {
              const dateHls = dailyMonth.id.toString().substring(0, 4) + '-' + dailyMonth.id.toString().substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
              if (almMap[roomTypeCM.id] === null) {
                almMap[roomTypeCM.id] = {};
              }
              almMap[roomTypeCM.id][dateHls] = {};
              almMap[roomTypeCM.id][dateHls]['num'] = dailyMonth.get('data')[day][roomTypeID]['num'] - 1 > 0 ? dailyMonth.get('data')[day][roomTypeID]['num'] - 1 : 0;
              almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
            };
          })
        }
      }

      const almMapNew: { [key: string]: any } = {};
      almMapNew[roomTypeCM.id] = {};
      const dateFrom = inMonthID.toString().substring(0, 4) + '-' + inMonthID.toString().substring(4, 6) + '-' + (nowTimezone.getDate() < 10 ? '0' + nowTimezone.getDate() : nowTimezone.getDate());

      const outMonth = dailyAllotments.docs[dailyAllotments.size - 2].id;
      const lastDayInOutMonth: number = new Date(parseInt(outMonth.substring(0, 4)), parseInt(outMonth.substring(4, 6)), 0).getDate();
      const dateTo = outMonth.toString().substring(0, 4) + '-' + outMonth.toString().substring(4, 6) + '-' + lastDayInOutMonth;
      almMapNew[roomTypeCM.id]['num'] = quantityRoomOfRoomType - 1;
      almMapNew[roomTypeCM.id]['ratePlanID'] = '';
      const resultFromToEndHls = await HLSUtil.updateAvaibilityWithNewMonthToCM(mappingHotelID, mappingHotelKey, almMapNew, dateFrom, dateTo, true);
      if (resultFromToEndHls === null) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.CM_UPDATE_AVAIBILITY_FAIL)
      }

      if (almMap[roomTypeCM.id] !== null) {
        const result = HLSUtil.updateMultipleAvaibility(mappingHotelID, mappingHotelKey, almMap, true);
        if (result === null) {
          throw new functions.https.HttpsError('cancelled', MessageUtil.CM_UPDATE_AVAIBILITY_FAIL)
        }
      }
    }
    dataUpdate['data.rooms.' + roomID + '.is_delete'] = true;
    t.update(hotelRef.collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    console.log(error.message);
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.createRatePlan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesCrudRatePlan;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const ratePlans: { [key: string]: any } = configurationRef.get('data')['rate_plan'];
    if (ratePlans[data.rate_plan_id] !== undefined) {
      throw new functions.https.HttpsError('failed-precondition', MessageUtil.RATE_PLAN_DUPLICATED)
    }

    const dataUpdate: { [key: string]: any } = {};

    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.amount'] = Number.parseFloat(data.rate_plan_amount);
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.decs'] = data.rate_plan_decs;
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.percent'] = data.is_percent;
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.is_delete'] = false;
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.is_default'] = false;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.updateCleanRoom = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === null || context.auth?.uid === undefined) {
    throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;
  const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
  const hotelDoc = (await hotelRef.get());
  const roomId = data.room_id;
  const roomClean: boolean = data.room_clean;
  const roomVacantOvernight: boolean = data.vacantvernight;

  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateCleanRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  const dataRoomUpdate: { [key: string]: any } = {
    ['data.rooms.' + roomId + '.clean']: roomClean
  }
  if (roomClean) {
    dataRoomUpdate['data.rooms.' + roomId + '.last_clean'] = new Date();
  }

  if (!roomClean && roomVacantOvernight) {
    dataRoomUpdate['data.rooms.' + roomId + '.vacant_overnight'] = !roomVacantOvernight
  }

  await hotelRef.collection('management').doc('configurations').update(dataRoomUpdate);
  return MessageUtil.SUCCESS;
});

exports.updateBedOfRoom = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === null || context.auth?.uid === undefined) {
    throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;
  const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
  const hotelDoc = (await hotelRef.get());
  const roomId = data.room_id;
  const roomBed = data.room_bed;

  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateExtraBed;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = admin.firestore().runTransaction(async (t) => {
    const configurationsDoc = await t.get(hotelRef.collection('management').doc('configurations'));
    if (!configurationsDoc.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const roomData = configurationsDoc.get('data')['rooms'];
    if (roomData === undefined) {
      throw new functions.https.HttpsError('not-found', MessageUtil.ROOM_NOT_FOUND)
    }

    t.update(hotelRef.collection('management').doc('configurations'), {
      ['data.rooms.' + roomId + '.bed']: roomBed
    })

    return MessageUtil.SUCCESS;
  })
  return res;
});

exports.editRatePlan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

  if (data.rate_plan_id === "OTA" || data.rate_plan_id === "Standard") {
    throw new functions.https.HttpsError('failed-precondition', MessageUtil.THIS_RATE_PLAN_CANNOT_BE_EDITED)
  }

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesCrudRatePlan;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const ratePlans: { [key: string]: any } = configurationRef.get('data')['rate_plan'];
    if (ratePlans[data.rate_plan_id]['is_delete'] === true) {
      throw new functions.https.HttpsError('failed-precondition', MessageUtil.RATE_PLAN_NOT_FOUND)
    }

    const dataUpdate: { [key: string]: any } = {};

    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.amount'] = Number.parseFloat(data.rate_plan_amount);
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.decs'] = data.rate_plan_decs;
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.percent'] = data.is_percent;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.deactiveRatePlan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesCrudRatePlan;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const ratePlans: { [key: string]: any } = configurationRef.get('data')['rate_plan'];
    if (ratePlans[data.rate_plan_id]['is_default'] === true) {
      return MessageUtil.CAN_NOT_DEACTIVE_DEFAULT_RATE_PLAN;
    }

    if (ratePlans[data.rate_plan_id]['is_delete'] === true) {
      return MessageUtil.SUCCESS;
    }

    const dataUpdate: { [key: string]: any } = {};
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.is_delete'] = true;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.setdefaultrateplan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesCrudRatePlan;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  const ratePlanNewId: string = data.rate_plan_id;

  if (ratePlanNewId === 'OTA') {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.OTA_RATE_PLAN_CANNOT_BE_SET_DEFAULT);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const ratePlans: { [key: string]: any } = configurationRef.get('data')['rate_plan'];
    if (ratePlans[ratePlanNewId]['is_delete'] === true) {
      return MessageUtil.RATE_PLAN_WAS_DELETED;
    }

    if (ratePlans[ratePlanNewId]['is_default'] === true) {
      return MessageUtil.SUCCESS;
    }

    const dataUpdate: { [key: string]: any } = {};
    for (const idRatePlan in ratePlans) {
      if (idRatePlan !== ratePlanNewId) {
        dataUpdate['data.rate_plan.' + idRatePlan + '.is_default'] = false;
      }
    }

    dataUpdate['data.rate_plan.' + ratePlanNewId + '.is_default'] = true;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.activeRatePlan = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesCrudRatePlan;
  //roles of user who make this request
  const roleOfUser: String[] = hotelRef.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {

    const configurationRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));

    if (!configurationRef.exists) {
      throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
    }

    const ratePlans: { [key: string]: any } = configurationRef.get('data')['rate_plan'];
    if (ratePlans[data.rate_plan_id]['is_delete'] === false) {
      return MessageUtil.SUCCESS;
    }

    const dataUpdate: { [key: string]: any } = {};
    dataUpdate['data.rate_plan.' + data.rate_plan_id + '.is_delete'] = false;
    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'), dataUpdate);
    return MessageUtil.SUCCESS;
  }).catch((error) => {
    throw new functions.https.HttpsError('invalid-argument', error.message)
  })
  return res;
})

exports.onUpdateConfigurationHotel = functions.firestore.document('hotels/{hotelID}/management/configurations').onUpdate(async (data, context) => {
  const roomsBeforeChange: { [key: string]: any } = data.before.get('data')['rooms'];
  const roomsAfterChange: { [key: string]: any } = data.after.get('data')['rooms'];
  const roomTypesBeforeChange: { [key: string]: any } = data.before.get('data')['room_types'];
  const roomTypesAfterChange: { [key: string]: any } = data.after.get('data')['room_types'];
  const timezone: string = data.after.get('data')['timezone'];
  const nowTimezone = DateUtil.convertUpSetTimezone(new Date(), timezone);
  const typeUpdate: { [key: string]: string } = {};
  typeUpdate['type'] = '';
  Object.keys(roomTypesAfterChange).map(async id => {

    // Create room type
    if (roomTypesBeforeChange[id] === undefined || roomTypesBeforeChange[id] === null) {
      typeUpdate['type'] = 'create_room_type';
      typeUpdate['id'] = id;
      return;
    }

    // eidt room type relationship price
    if (roomTypesBeforeChange[id]['price'] !== roomTypesAfterChange[id]['price']) {
      typeUpdate['type'] = 'edit_room_type';
      typeUpdate['id'] = id;
      return;
    }
  });
  // CRUD rooms
  Object.keys(roomsAfterChange).map(id => {
    // create room
    if (roomsBeforeChange[id] === undefined || roomsBeforeChange[id] === null) {
      typeUpdate['type'] = 'create_room';
      typeUpdate['id'] = id;
      return;
    }
    // edit room
    if (roomsBeforeChange[id]['room_type'] !== roomsAfterChange[id]['room_type']) {
      typeUpdate['type'] = 'edit_room';
      typeUpdate['id'] = id;
      return;
    };
    // delete room
    if (roomsBeforeChange[id]['is_delete'] === false && roomsAfterChange[id]['is_delete'] === true) {
      typeUpdate['type'] = 'delete_room';
      typeUpdate['id'] = id;
    }
  });

  if (typeUpdate.type !== '') {
    const batch = fireStore.batch();
    const dataUpdate: { [key: string]: any } = {};
    switch (typeUpdate.type) {
      case 'create_room_type':
        dataUpdate['data.default.' + typeUpdate.id + '.price'] = roomTypesAfterChange[typeUpdate.id]['price'];
        for (let i = 0; i < 24; i++) {
          const monthId = DateUtil.addMonthToStringYearMonth(nowTimezone, i);
          batch.update(
            fireStore
              .collection('hotels')
              .doc(context.params.hotelID)
              .collection('daily_allotment')
              .doc(monthId),
            dataUpdate);
        }
        await batch.commit();
        break;
      case 'edit_room_type':
        dataUpdate['data.default.' + typeUpdate.id + '.price'] = roomTypesAfterChange[typeUpdate.id]['price'];
        for (let i = 0; i < 24; i++) {
          const monthId = DateUtil.addMonthToStringYearMonth(nowTimezone, i);
          batch.update(
            fireStore
              .collection('hotels')
              .doc(context.params.hotelID)
              .collection('daily_allotment')
              .doc(monthId),
            dataUpdate);
        }
        await batch.commit();
        break;
      case 'create_room':
        for (let i = 0; i < 24; i++) {
          const monthId = DateUtil.addMonthToStringYearMonth(nowTimezone, i);
          const lastDayInMonth: number = new Date(parseInt(monthId.substring(0, 4)), parseInt(monthId.substring(4, 6)), 0).getDate();
          const dataRooms: { [key: string]: any } = {}
          for (let day = 1; day <= lastDayInMonth; day++) {
            dataRooms['data.' + day + '.' + roomsAfterChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(1);
          };

          batch.update(
            fireStore
              .collection('hotels')
              .doc(context.params.hotelID)
              .collection('daily_allotment')
              .doc(monthId),
            dataRooms);
        }
        const dataRoomTypes: { [key: string]: any } = {};
        dataRoomTypes['data.room_types.' + roomsAfterChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(1);
        batch.update(fireStore.collection('hotels').doc(context.params.hotelID).collection('management').doc('configurations'), dataRoomTypes);
        await batch.commit();
        break;
      case 'edit_room':
        for (let i = 0; i < 24; i++) {
          const monthId = DateUtil.addMonthToStringYearMonth(nowTimezone, i);
          const lastDayInMonth: number = new Date(parseInt(monthId.substring(0, 4)), parseInt(monthId.substring(4, 6)), 0).getDate();
          const dataRooms: { [key: string]: any } = {}
          // update number of roomtype
          for (let day = 1; day <= lastDayInMonth; day++) {
            dataRooms['data.' + day + '.' + roomsBeforeChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(-1);
            dataRooms['data.' + day + '.' + roomsAfterChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(1);
            batch.update(
              fireStore
                .collection('hotels')
                .doc(context.params.hotelID)
                .collection('daily_allotment')
                .doc(monthId),
              dataRooms);
          }
        }
        await batch.commit();

        // update booking of roomType
        await fireStore.runTransaction(async (t) => {
          const bookingsRef = await t.get(fireStore.collection('hotels')
            .doc(context.params.hotelID)
            .collection('basic_bookings').where('room', '==', typeUpdate.id).where('status', 'in', [BookingStatus.booked, BookingStatus.checkin]));
          for (const booking of bookingsRef.docs) {
            t.update(fireStore.collection('hotels').doc(context.params.hotelID).collection('basic_bookings').doc(booking.id), { 'room_type': roomsAfterChange[typeUpdate.id]['room_type'] })
          }
        })

        await fireStore.runTransaction(async (t) => {
          const bookingsRef = await t.get(fireStore.collection('hotels')
            .doc(context.params.hotelID)
            .collection('bookings').where('room', '==', typeUpdate.id).where('status', 'in', [BookingStatus.booked, BookingStatus.checkin]));
          for (const booking of bookingsRef.docs) {
            t.update(fireStore.collection('hotels').doc(context.params.hotelID).collection('bookings').doc(booking.id), { 'room_type': roomsAfterChange[typeUpdate.id]['room_type'] })
          }
        })
        break;
      case 'delete_room':
        // update Daily allotment 
        for (let i = 0; i < 24; i++) {
          const monthId = DateUtil.addMonthToStringYearMonth(nowTimezone, i);
          const lastDayInMonth: number = new Date(parseInt(monthId.substring(0, 4)), parseInt(monthId.substring(4, 6)), 0).getDate();
          const dataBooked: { [key: string]: any } = {};
          for (let day = 1; day <= lastDayInMonth; day++) {
            dataBooked['data.' + day + '.' + roomsAfterChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(-1);
            dataBooked['data.' + day + '.booked'] = FieldValue.arrayRemove(typeUpdate.id);
          };
          batch.update(
            fireStore
              .collection('hotels')
              .doc(context.params.hotelID)
              .collection('daily_allotment')
              .doc(monthId),
            dataBooked);
        }

        const dataRoomTypesDelete: { [key: string]: any } = {};
        dataRoomTypesDelete['data.room_types.' + roomsAfterChange[typeUpdate.id]['room_type'] + '.num'] = FieldValue.increment(-1);
        batch.update(fireStore.collection('hotels').doc(context.params.hotelID).collection('management').doc('configurations'), dataRoomTypesDelete);
        await batch.commit();

        break;
    }
  }

});

exports.onCreateHotel = functions.firestore.document('hotels/{hotelID}').onCreate(async (doc, context) => {
  const hotel = doc.data();
  const timezone = hotel.timezone;
  const dataUpdate: { [key: string]: any } = {};
  const nowServer: Date = new Date();
  const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
  const inMonthID: string = DateUtil.dateToShortStringYearMonth(nowTimezone);
  dataUpdate['data.' + inMonthID + '.hotels.' + hotel.city] = FieldValue.increment(1);
  dataUpdate['data.' + inMonthID + '.hotels.total'] = FieldValue.increment(1);
  await fireStore.collection('system').doc('statistic').update(dataUpdate);
});

exports.onCreateUser = functions.firestore.document('users/{usersID}').onCreate(async (doc, context) => {
  const dataUpdate: { [key: string]: any } = {};
  const nowServer: Date = new Date();
  const inMonthID: string = DateUtil.dateToShortStringYearMonth(nowServer);
  dataUpdate['data.' + inMonthID + '.users.total'] = FieldValue.increment(1);
  await fireStore.collection('system').doc('statistic').update(dataUpdate);
});

exports.updateTax = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelDoc = await fireStore.collection('hotels').doc(data.hotel_id).get();
    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesConfigTax;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
      throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const serviceFee: number = data.service_fee;
    const vat: number = data.vat;
    if (serviceFee === undefined || vat === undefined || serviceFee < 0 || vat < 0) {
      throw new functions.https.HttpsError('invalid-argument', MessageUtil.BAD_REQUEST);
    }

    await fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations').update({
      ['data.tax.service_fee']: serviceFee,
      ['data.tax.vat']: vat
    });
    return MessageUtil.SUCCESS;
  } catch (e: any) {
    console.log(e);
    return e.message;
  }
})

exports.updateBikeConfig = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    }

    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelDoc = await fireStore.collection('hotels').doc(data.hotel_id).get();
    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesConfigBikePrice;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
      throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const autoPrice: number = data.auto_price;
    const manualPrice: number = data.manual_price;

    if (autoPrice === undefined || manualPrice === undefined || autoPrice <= 0 || manualPrice <= 0) {
      throw new functions.https.HttpsError('invalid-argument', MessageUtil.INPUT_POSITIVE_PRICE);
    }

    await fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations').update({
      ['data.bike_rental.auto']: autoPrice,
      ['data.bike_rental.manual']: manualPrice
    });
    return MessageUtil.SUCCESS;
  } catch (e: any) {
    return e.message;
  }
});

exports.configureColor = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;

  const keyOfRole = 'role.' + context.auth?.uid;
  const hotelRef = fireStore.collection('hotels').doc(hotelId);
  const hotelDoc = await hotelRef.get();

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesConfigColor;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get(keyOfRole);
  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const dataColor = data.colors;
  await hotelRef.update({ ['colors']: dataColor });

  return MessageUtil.SUCCESS;
});


exports.updateVersion = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === undefined) {
    throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  }
  const userDoc = (await fireStore.collection('users').doc(context.auth.uid).get());
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  }

  const isAdmin: boolean = userDoc.get('admin');

  if (isAdmin === undefined || !isAdmin) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const version: string = data.version;
  await fireStore.collection('system').doc('configuration').update({ ['version']: version });
  return MessageUtil.SUCCESS;
});

exports.getInfoHotel = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === undefined) {
    throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  }
  const userDoc = (await fireStore.collection('users').doc(context.auth.uid).get());
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  }

  const isAdmin: boolean = userDoc.get('admin');
  const isSuport: boolean = userDoc.get('support');

  if ((isAdmin === undefined || !isAdmin) && (isSuport === undefined || !isSuport)) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const hotelID: string = data.hotel_id;
  const hotelDoc = await fireStore.collection('hotels').doc(hotelID).get();
  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.HOTEL_NOT_FOUND);
  }

  const result: { [key: string]: any } = {};
  result['hotel'] = hotelDoc.data();

  const rolesHotel: { [key: string]: string[] } = hotelDoc.get('role');
  const uidOwner: string[] = [];
  for (const uid in rolesHotel) {
    if (rolesHotel[uid].includes(UserRole.owner)) {
      uidOwner.push(uid);
    }
  }

  result['users'] = [];
  if (uidOwner.length !== 0) {
    for (const uid of uidOwner) {
      const userOwner = (await fireStore.collection('users').doc(uid).get()).data();
      result['users'].push(userOwner);
    }
  }
  result['result'] = MessageUtil.SUCCESS;
  return result;
});


exports.addPolicyHotel = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const linkImg: string = data.img;

  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  await hotelRef.update({ "policy": linkImg });

  return MessageUtil.SUCCESS;
});


exports.updateVacantOvernight = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const vacantOvernight: string = data.vacantvernight;

  const rolesAllowed = NeutronUtil.rolesVacantCleanOvernight;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  await hotelRef.update({ "vacant_overnight": vacantOvernight });

  return MessageUtil.SUCCESS;
});

exports.updateVacantOvernightRoom = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === null || context.auth?.uid === undefined) {
    throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;
  const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
  const hotelDoc = (await hotelRef.get());
  const roomId = data.room_id;
  const roomVacantOvernight: boolean = data.vacantvernight;

  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateCleanRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  const res: string = await fireStore.runTransaction(async (t) => {
    t.update(hotelRef.collection('management').doc('configurations'), { ['data.rooms.' + roomId + '.vacant_overnight']: roomVacantOvernight })

    return MessageUtil.SUCCESS;
  })
  return res;
});

exports.updateAllVacantOvernight = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === null || context.auth?.uid === undefined) {
    throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;
  const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
  const hotelDoc = (await hotelRef.get());
  const listRoomVacantOvernight: string[] = data.vacantvernight;

  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateCleanRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }


  const batch = fireStore.batch();
  listRoomVacantOvernight.forEach(async roomId => {
    batch.update(hotelRef.collection('management').doc('configurations'), {
      ['data.rooms.' + roomId + '.vacant_overnight']: false
    });
  });

  await batch.commit();
  return MessageUtil.SUCCESS;

});

exports.updateshownamesource = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const show_namesource: string = data.show_namesource;

  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  await hotelRef.update({ "name_source": show_namesource });

  return MessageUtil.SUCCESS;
});



exports.updateautoroonassignment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const auto_roon_assignment: boolean = data.auto_roon_assignment;

  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  console.log(auto_roon_assignment);

  await hotelRef.update({ "room_assignment": auto_roon_assignment });

  return MessageUtil.SUCCESS;
});


exports.updateFinancialDate = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const nowServer: Date = new Date();
  const timezone: string = hotelDoc.get('timezone');
  const createdTimezone: Date = (data.date !== '' && data.date !== null) ? new Date(data.date) : DateUtil.convertUpSetTimezone(nowServer, timezone);
  const dateServer: Date = DateUtil.convertOffSetTimezone(createdTimezone, timezone);

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  await hotelRef.update({ "financial_date": dateServer });

  return MessageUtil.SUCCESS;
});


exports.addNoteRoom = functions.https.onCall(async (data, context) => {
  if (context.auth?.uid === null || context.auth?.uid === undefined) {
    throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
  }

  const hotelId = data.hotel_id;
  const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
  const hotelDoc = (await hotelRef.get());
  const roomId = data.room_id;
  const roomNote = data.notes;

  if (!hotelDoc.exists) {
    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
  }

  //roles allow to change database
  const rolesAllowed: String[] = NeutronUtil.rolesUpdateCleanRoom;
  //roles of user who make this request
  const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

  if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }
  const dataRoomUpdate: { [key: string]: any } = {
    ['data.rooms.' + roomId + '.note']: roomNote
  }

  await hotelRef.collection('management').doc('configurations').update(dataRoomUpdate);
  return MessageUtil.SUCCESS;
});


exports.updateunconfirm = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const unconfirmed: boolean = data.unconfirmed;

  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  await hotelRef.update({ "unconfirmed": unconfirmed });

  return MessageUtil.SUCCESS;
});


exports.updateautorate = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const auto_rate: boolean = data.auto_rate;

  const rolesAllowed = NeutronUtil.rolesPolicy;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  await hotelRef.update({ "auto_rate": auto_rate });

  return MessageUtil.SUCCESS;
});


exports.addPackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const rolesAllowed = NeutronUtil.rolesPackageVersion;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const nowServer: Date = new Date();
  const idPackage = data.id_package;
  const desc = data.desc;
  const price = data.price;
  const packageVersion = data.package;

  const timezone: string = hotelDoc.get('timezone');
  const startTimezone: Date = (data.start_date !== '' && data.start_date !== null) ? new Date(data.start_date) : DateUtil.convertUpSetTimezone(nowServer, timezone);
  const startDateServer: Date = DateUtil.convertOffSetTimezone(startTimezone, timezone);
  const endTimezone: Date = (data.end_date !== '' && data.end_date !== null) ? new Date(data.end_date) : DateUtil.convertUpSetTimezone(nowServer, timezone);
  const endDateServer: Date = DateUtil.convertOffSetTimezone(endTimezone, timezone);

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const packageVersions = (await t.get(hotelRef)).get("package_version");
    if (packageVersions !== undefined && (await t.get(hotelRef)).get("package_version")[idPackage] !== undefined) {
      throw new functions.https.HttpsError('already-exists', MessageUtil.NATIONAL_ID_DUPLICATED);
    }
    let newExpirationDate: Date = endDateServer;

    if (new Date(Date.UTC(startTimezone.getFullYear(), startTimezone.getMonth() + 1, startTimezone.getDate())).getTime() == new Date(Date.UTC(endTimezone.getFullYear(), endTimezone.getMonth() + 1, endTimezone.getDate())).getTime()) {
      if (packageVersion == 0) {
        newExpirationDate = new Date(Date.UTC(endDateServer.getFullYear(), endDateServer.getMonth() + 1, endDateServer.getDate(), endDateServer.getHours(), endDateServer.getMinutes()));
      } else if (packageVersion == 1) {
        newExpirationDate = new Date(Date.UTC(endDateServer.getFullYear(), endDateServer.getMonth() + 12, endDateServer.getDate(), endDateServer.getHours(), endDateServer.getMinutes()));
      }
    }
    const dataUpdateHotel: { [key: string]: any } = {};

    if (packageVersions == undefined) {
      dataUpdateHotel['package_version.default'] = idPackage;
    }
    dataUpdateHotel['package_version.' + idPackage + '.activate'] = true;
    dataUpdateHotel['package_version.' + idPackage + '.desc'] = desc;
    dataUpdateHotel['package_version.' + idPackage + '.package'] = packageVersion;
    dataUpdateHotel['package_version.' + idPackage + '.price'] = price;
    dataUpdateHotel['package_version.' + idPackage + '.start_date'] = startDateServer;
    dataUpdateHotel['package_version.' + idPackage + '.end_date'] = newExpirationDate;

    t.update(hotelRef, dataUpdateHotel);
    return MessageUtil.SUCCESS;

  });
  return res;
});


exports.updatePackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const rolesAllowed = NeutronUtil.rolesPackageVersion;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const nowServer: Date = new Date();
  const idPackage = data.id_package;
  const desc = data.desc;
  const price = data.price;
  const packageVersion = data.package;

  const timezone: string = hotelDoc.get('timezone');
  const startTimezone: Date = (data.start_date !== '' && data.start_date !== null) ? new Date(data.start_date) : DateUtil.convertUpSetTimezone(nowServer, timezone);
  const startDateServer: Date = DateUtil.convertOffSetTimezone(startTimezone, timezone);
  const endTimezone: Date = (data.end_date !== '' && data.end_date !== null) ? new Date(data.end_date) : DateUtil.convertUpSetTimezone(nowServer, timezone);
  const endDateServer: Date = DateUtil.convertOffSetTimezone(endTimezone, timezone);

  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const dataUpdateHotel: { [key: string]: any } = {};

    dataUpdateHotel['package_version.' + idPackage + '.activate'] = true;
    dataUpdateHotel['package_version.' + idPackage + '.desc'] = desc;
    dataUpdateHotel['package_version.' + idPackage + '.package'] = packageVersion;
    dataUpdateHotel['package_version.' + idPackage + '.price'] = price;
    dataUpdateHotel['package_version.' + idPackage + '.start_date'] = startDateServer;
    dataUpdateHotel['package_version.' + idPackage + '.end_date'] = endDateServer;

    t.update(hotelRef, dataUpdateHotel);
    return MessageUtil.SUCCESS;

  });
  return res;
});


exports.deletePackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const rolesAllowed = NeutronUtil.rolesPackageVersion;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const idPackage = data.id_package;
  const uidOfUser: string = context.auth.uid;

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const dataPackageVersion = (await t.get(hotelRef)).get("package_version");
    const dataUpdateHotel: { [key: string]: any } = {};

    if (dataPackageVersion["default"] == idPackage) {
      throw new functions.https.HttpsError('already-exists', MessageUtil.HOTELS_USING_THIS_THIS_PACKAGE_CANNOT_BE_DELETED);
    }

    dataUpdateHotel['package_version.' + idPackage + '.activate'] = false;

    t.update(hotelRef, dataUpdateHotel);
    return MessageUtil.SUCCESS;

  });
  return res;
});


exports.updateDefaultPackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const hotelID: string = data.hotel_id;
  const rolesAllowed = NeutronUtil.rolesPackageVersion;
  const hotelRef = fireStore.collection('hotels').doc(hotelID);
  const hotelDoc = await hotelRef.get();
  const idPackage = data.id_package;
  const uidOfUser: string = context.auth.uid;
  const nowServer = new Date();

  if (hotelDoc === undefined) {
    throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
  }

  const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
  if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
    throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
  }

  const res = await fireStore.runTransaction(async (t) => {
    const dataPackageVersion = (await t.get(hotelRef)).get("package_version");
    const endDayServer: Date = dataPackageVersion[dataPackageVersion["default"]]['end_date'].toDate();
    const dataUpdateHotel: { [key: string]: any } = {};

    if (dataPackageVersion["default"] == idPackage) {
      return MessageUtil.SUCCESS;
    }

    if (nowServer.getTime() < endDayServer.getTime()) {
      throw new functions.https.HttpsError('already-exists', MessageUtil.THE_PACKAGE_IS_STILL_EXPIRED);
    }

    dataUpdateHotel['package_version.default'] = idPackage;

    t.update(hotelRef, dataUpdateHotel);
    return MessageUtil.SUCCESS;

  });
  return res;
});


exports.addPaymentPackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const res = await fireStore.runTransaction(async (t) => {
    const hotelID: string = data.hotel_id;
    const rolesAllowed = NeutronUtil.rolesPackageVersion;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await t.get(hotelRef);
    const method = data.method;
    const teDesc = data.desc;
    const stillInDebt = data.still_indebt;
    const isTillInDebt: boolean = data.isstill_indebt;
    const uidOfUser: string = context.auth!.uid;
    const nowServer = new Date();

    if (hotelDoc === undefined) {
      throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
      throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const timezone = hotelDoc.get('timezone');
    const dataUpdateHotel: { [key: string]: any } = {};
    const endDayServer: Date = hotelDoc.get("package_version")[hotelDoc.get("package_version")["default"]]['end_date'].toDate();
    const amount: number = hotelDoc.get("package_version")[hotelDoc.get("package_version")["default"]]['price'];
    let newExpirationDate: Date;

    if (hotelDoc.get("package_version")[hotelDoc.get("package_version")["default"]]["package"] == 0) {
      newExpirationDate = new Date(Date.UTC(endDayServer.getFullYear(), endDayServer.getMonth() + 1, endDayServer.getDate(), endDayServer.getHours(), endDayServer.getMinutes()));
      dataUpdateHotel['package_version.' + hotelDoc.get("package_version")["default"] + '.end_date'] = newExpirationDate;

    } else if (hotelDoc.get("package_version")[hotelDoc.get("package_version")["default"]]["package"] == 1) {
      newExpirationDate = new Date(Date.UTC(endDayServer.getFullYear(), endDayServer.getMonth() + 12, endDayServer.getDate(), endDayServer.getHours(), endDayServer.getMinutes()));
      dataUpdateHotel['package_version.' + hotelDoc.get("package_version")["default"] + '.end_date'] = newExpirationDate;
    }

    const dataUpdate: { [key: string]: any } = {
      'amount': amount,
      'method': method,
      'desc': teDesc,
      'nameBank': "Accounting",
      'created': nowServer,
      'creater': context.auth?.token.email,
      'hotel': hotelID,
      'name_hotel': hotelDoc.get('name'),
      'package': hotelDoc.get("package_version")["default"],
      "code_bank": NumberUtil.getSidByConvertToBase62(),
      'status': "open",
      'expired_date': endDayServer,
      'time_zone': timezone,
      'stillIn_debt': isTillInDebt ? stillInDebt : amount,
    };

    t.update(hotelRef, dataUpdateHotel);
    t.create(hotelRef.collection("package_payments").doc(NumberUtil.getRandomID()), dataUpdate);
    return MessageUtil.SUCCESS;
  })
  return res;
});


exports.updatePaymentPackageVersion = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

  const res = await fireStore.runTransaction(async (t) => {
    const hotelID: string = data.hotel_id;
    const rolesAllowed = NeutronUtil.rolesPackageVersion;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await t.get(hotelRef);
    const idPaymentPackage = data.id_payment;
    const method = data.method;
    const teDesc = data.desc;
    const stillInDebt = data.still_indebt;
    const uidOfUser: string = context.auth!.uid;

    if (hotelDoc === undefined) {
      throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
      throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }


    const dataUpdate: { [key: string]: any } = {
      'method': method,
      'desc': teDesc,
      'stillIn_debt': stillInDebt,
    };

    t.update(hotelRef.collection("package_payments").doc(idPaymentPackage), dataUpdate);
    return MessageUtil.SUCCESS;
  })
  return res;
});


exports.getDailyDataByHotels = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
  const listIDHotels: string[] = [];
  const YearMonth: string = data.year_moth;
  const dataUpdate: { [key: string]: any[] } = {}
  const res = await fireStore.runTransaction(async (t) => {
    const hotelRef = await fireStore.collection("hotels").where('role.' + context.auth?.uid, "array-contains-any", [UserRole.owner, UserRole.manager]).get();
    for (const docHotel of hotelRef.docs) {
      listIDHotels.push(docHotel.id)
      dataUpdate[docHotel.id] = [];
      dataUpdate["configurations~" + docHotel.id] = [];

    }
    const dailyRef = await fireStore.collectionGroup("daily_data").get();
    for (const doc of dailyRef.docs) {
      if (listIDHotels.includes(doc.ref.parent.parent?.id!) && doc.id == YearMonth) {
        dataUpdate[doc.ref.parent.parent?.id!].push(doc.get('data'))
      }
    }
    const managementRef = await fireStore.collectionGroup("management").get();
    for (const doc of managementRef.docs) {
      if (listIDHotels.includes(doc.ref.parent.parent?.id!) && doc.id == "configurations") {
        dataUpdate["configurations~" + doc.ref.parent.parent?.id].push(doc.get('data'))
      }
    }
    return dataUpdate;
  })
  return res;
});