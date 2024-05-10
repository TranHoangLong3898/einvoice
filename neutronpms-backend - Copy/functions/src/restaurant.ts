import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { BookingStatus } from './constant/status';
import { BookingApi } from './model/booking_api';
import { NumberUtil } from './util/numberutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { RestUtil } from './util/restutil';
import { ServiceCategory } from './constant/type';
const firestore = admin.firestore();

// public api to one res query => id hotel
exports.apiReceiveRequestConnectRestaurant = functions.https.onRequest(async (req, res) => {
    const body = JSON.parse(req.rawBody.toString());
    const resID: string = body.res_id;
    const resName: string = body.res_name;
    const emailCreated: string = body.email;
    const nowServer: Date = new Date();
    const hotelsDoc = await firestore.collection('hotels').where('name', '==', body.name).get();
    if (hotelsDoc.empty || hotelsDoc.size !== 1) {
        res.status(404).json({
            'result': false,
            'message': MessageUtil.HAVE_MANY_HOTEL_HAVE_THIS_NAME
        });
    } else {
        const restaurantDoc = await hotelsDoc.docs[0].ref.collection('management').doc('restaurants').get();
        if (!restaurantDoc.exists && restaurantDoc.get(`data.${resID}`) !== undefined) {
            res.status(404).json({
                'result': false,
                'message': MessageUtil.PLEASE_WAIT_TO_HOTEL_ACCEPT_CONNECT
            });
        }
        const dataUpdateRes: { [key: string]: any } = {};
        dataUpdateRes[`data.${resID}.created`] = nowServer;
        dataUpdateRes[`data.${resID}.email`] = emailCreated;
        dataUpdateRes[`data.${resID}.res_name`] = resName;
        dataUpdateRes[`data.${resID}.is_linked`] = false;

        try {
            await firestore.collection('hotels').doc(hotelsDoc.docs[0].id).collection('management').doc('restaurants').update(dataUpdateRes);
        } catch (error) {
            await firestore.collection('hotels').doc(hotelsDoc.docs[0].id).collection('management').doc('restaurants').create(dataUpdateRes);
        }
        res.status(200).json({
            'result': true,
            'message': MessageUtil.PLEASE_LOGIN_HOTEL_TO_ACCEPT_REQUEST
        });
    }
});

exports.apiReceiveRequestDisableConnectRestaurant = functions.https.onRequest(async (req, res) => {
    const body = JSON.parse(req.rawBody.toString());
    const resID: string = body.res_id;
    const hotelID: string = body.hotel_id;

    const hotelDoc = await firestore.collection('hotels').doc(hotelID).get();
    if (!hotelDoc.exists) {
        res.status(404).json({
            'result': false,
            'message': 'not-found-hotel'
        });
    } else {
        const restaurantDoc = await hotelDoc.ref.collection('management').doc('restaurants').get();
        if (!restaurantDoc.exists || (restaurantDoc.get(`data.${resID}`) === undefined)) {
            res.status(404).json({
                'result': false,
                'message': 'not-found-restaurant'
            });
        }

        const FieldValue = admin.firestore.FieldValue;
        const dataUpdateRes: { [key: string]: any } = {};

        dataUpdateRes['data.' + resID] = FieldValue.delete();
        await restaurantDoc.ref.update(dataUpdateRes);

        res.status(200).json({
            'result': true,
            'message': 'OK'
        });
    }
});

exports.acceptConnectRestaurant = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelID: string = data.hotel_id;
    const resID: string = data.res_id;
    const hotelDoc = await firestore.collection('hotels').doc(hotelID).get();

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    }
    const dataUpdateRes: { [key: string]: any } = {};
    const restaurantDoc = await hotelDoc.ref.collection('management').doc('restaurants').get();
    if (!restaurantDoc.exists || restaurantDoc.get(`data.${resID}`) === undefined) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.RESTAURANT_NOT_FOUND);
    }
    if (restaurantDoc.get(`data.${resID}.is_linked`)) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.WAS_ACCEPT_LINKED);
    }
    // call to one res to accept this linked
    const options = {
        hostname: 'us-central1-onepms-beta.cloudfunctions.net',
        path: '/restaurantmanager-apiAcceptLinkedHotel',
        method: 'POST',
        headers: {
            "Content-Type": "application/json"
        }
    };
    const param: any = JSON.stringify({
        'hotel_id': hotelDoc.id,
        'hotel_name': hotelDoc.get('name'),
        'res_id': resID
    });

    const response = await RestUtil.postRequest(options, param);
    if (response.result) {
        dataUpdateRes['data.' + resID + '.is_linked'] = true;
        await hotelDoc.ref.collection('management').doc('restaurants').update(dataUpdateRes);
        return MessageUtil.SUCCESS;
    } else {
        console.log(response.message);
        throw new functions.https.HttpsError('cancelled', response.message);
    }
});

exports.disableConnectRestaurant = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelID: string = data.hotel_id;
    const resID: string = data.res_id;
    const hotelDoc = await firestore.collection('hotels').doc(hotelID).get();

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUpdateHotelOrCrudRoomTypeOrCrudRoom;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    }
    const dataUpdateRes: { [key: string]: any } = {};
    const restaurantDoc = await hotelDoc.ref.collection('management').doc('restaurants').get();
    if (!restaurantDoc.exists || restaurantDoc.get(`data.${resID}`) === undefined) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.RESTAURANT_NOT_FOUND);
    }

    // call to one res to disable this linked
    const options = {
        hostname: 'us-central1-onepms-beta.cloudfunctions.net',
        path: '/restaurantmanager-apiDisableLinkedHotel',
        method: 'POST',
        headers: {
            "Content-Type": "application/json"
        }
    };
    const param: any = JSON.stringify({
        'res_id': resID
    });

    const response = await RestUtil.postRequest(options, param);
    if (response.result) {
        const FieldValue = admin.firestore.FieldValue;
        dataUpdateRes['data.' + resID] = FieldValue.delete();
        await hotelDoc.ref.collection('management').doc('restaurants').update(dataUpdateRes);
        return MessageUtil.SUCCESS;
    } else {
        console.log(response.message);
        throw new functions.https.HttpsError('cancelled', response.message);
    }
});

exports.getBookings = functions.https.onRequest(async (req, res) => {
    const body = JSON.parse(req.rawBody.toString());
    const hotelID: string = body.hotel_id;
    const type: string = body.type;
    const sID: string = body.sID;

    try {
        const roomsConfiguration: { [key: string]: any } = (await firestore.collection('hotels').doc(hotelID).collection('management').doc('configurations').get()).get('data')['rooms'];
        const sourcesConfiguration: { [key: string]: any } = (await firestore.collection('hotels').doc(hotelID).collection('management').doc('configurations').get()).get('data')['sources'];
        let bookingsDoc;
        const bookings: BookingApi[] = [];
        let bookingTepm: BookingApi;

        if (type === 'sid') {
            bookingsDoc = await firestore.collection('hotels').doc(hotelID).collection('bookings').where('sid', '==', sID).where('virtual', '==', false).get()
        } else if (type === 'staying') {
            bookingsDoc = await firestore.collection('hotels').doc(hotelID).collection('bookings').where('status', '==', BookingStatus.checkin).get()
        }

        if (bookingsDoc === undefined || bookingsDoc.empty) {
            res.status(404).json({
                'result': false,
                'message': 'not-found-bookings'
            });
        } else {
            for (const booking of bookingsDoc.docs) {
                if (booking.get('group')) {
                    const subBookings = booking.get('sub_bookings');
                    for (const idBooking in subBookings) {
                        if (subBookings[idBooking]['status'] == BookingStatus.checkin) {
                            bookingTepm = new BookingApi(idBooking, booking.get('name'), booking.get('sid'), '', booking.get('group'), subBookings[idBooking]['in_date'].toDate(), subBookings[idBooking]['out_date'].toDate(), '');
                            bookingTepm.name_room = subBookings[idBooking]['room'] !== "" ? roomsConfiguration[subBookings[idBooking]['room']]['name'] : "none";
                            bookingTepm.source = booking.get('source') !== "" ? sourcesConfiguration[booking.get('source')]['name'] : "none";
                            bookings.push(bookingTepm);
                        }
                    }
                } else {
                    bookingTepm = new BookingApi(booking.id, booking.get('name'), booking.get('sid'), '', booking.get('group'), booking.get('in_date').toDate(), booking.get('out_date').toDate(), '');
                    bookingTepm.name_room = roomsConfiguration[booking.get('room')]['name'];
                    bookingTepm.source = booking.get('source') !== "" ? sourcesConfiguration[booking.get('source')]['name'] : 'none';
                    bookings.push(bookingTepm);
                }
            }
            res.status(200).json({
                'result': true,
                'bookings': bookings
            });
        }
    } catch (error) {
        console.log(error);
        res.status(404).json({
            'result': false,
            'message': 'undefined errors'
        });
    }
});

exports.createService = functions.https.onRequest(async (req, res) => {
    const body = JSON.parse(req.rawBody.toString());
    const bookingID: string = body.booking_id;
    const hotelID: string = body.hotel_id;
    const resName: string = body.res_name;
    const items: {}[] = body.items;
    const total: number = body.total;
    const discount: number = body.discount;
    const surcharge: number = body.surcharge;
    const resID: string = body.res_id;
    const orderId: string = body.order_id;

    const transaction = await firestore.runTransaction(async (t) => {
        const bookingDoc = await t.get(firestore.collection('hotels').doc(hotelID).collection('basic_bookings').doc(bookingID));
        const restaurantsDoc = await t.get(firestore.collection('hotels').doc(hotelID).collection('management').doc('restaurants'));

        // check linked is connect
        if (!restaurantsDoc.exists || (restaurantsDoc.get(`data.${resID}`) === undefined) || restaurantsDoc.get(`data.${resID}.is_linked`) === false) {
            throw new functions.https.HttpsError('cancelled', 'restaurant-still-not-connect-hotel')
        }
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError('cancelled', 'booking-dont-exists')
        }
        if (bookingDoc.get('status') !== BookingStatus.checkin) {
            throw new functions.https.HttpsError('cancelled', 'booking-not-checkin-please-check-status-booking')
        }
        const nowServer = new Date();
        const dataServiceUpdate: { [key: string]: any } = {
            'created': nowServer,
            'modified_by': 'Auto Added By OnePms',
            'used': nowServer,
            'items': items,
            'total': total,
            'surcharge': surcharge,
            'discount': discount,
            'cat': ServiceCategory.restaurantCat,
            'status': 'open',
            'name': bookingDoc.get('name'),
            'bid': bookingDoc.id,
            'in': bookingDoc.get('in_date'),
            'out': bookingDoc.get('out_date'),
            'room': bookingDoc.get('room'),
            'sid': bookingDoc.get('sid'),
            'hotel': hotelID,
            'time_zone': bookingDoc.get('time_zone'),
            'group': bookingDoc.get('group'),
            'res_name': resName,
            'res_id': resID,
            'order_id': orderId
        };

        if (bookingDoc.get('group')) {
            t.set(firestore.collection('hotels').doc(hotelID).collection('bookings').doc(bookingDoc.get('sid')).collection('services').doc(NumberUtil.getRandomID()), dataServiceUpdate)
        } else {
            t.set(firestore.collection('hotels').doc(hotelID).collection('bookings').doc(bookingID).collection('services').doc(NumberUtil.getRandomID()), dataServiceUpdate)
        }
        return { 'result': true, 'message': 'OK' };
    }).catch((e) => {
        res.json({ 'result': false, 'message': e.message });
    });
    res.json(transaction);

});

exports.deleteService = functions.https.onRequest(async (req, res) => {
    const body = JSON.parse(req.rawBody.toString());

    const bookingID: string = body.booking_id;
    const hotelID: string = body.hotel_id;
    const orderId: string = body.order_id;
    const resID: string = body.res_id;

    const transaction = await firestore.runTransaction(async (t) => {
        const bookingDoc = await t.get(firestore.collection('hotels').doc(hotelID).collection('basic_bookings').doc(bookingID));
        const restaurantsDoc = await t.get(firestore.collection('hotels').doc(hotelID).collection('management').doc('restaurants'));

        // check linked is connect
        if (!restaurantsDoc.exists || (restaurantsDoc.get(`data.${resID}`) === undefined) || restaurantsDoc.get(`data.${resID}.is_linked`) === false) {
            throw new functions.https.HttpsError('cancelled', 'restaurant-still-not-connect-hotel')
        }
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError('cancelled', 'booking-not-exist')
        }
        if (bookingDoc.get('status') === BookingStatus.checkout) {
            throw new functions.https.HttpsError('cancelled', 'can-not-cancel-service-because-of-booking-checked-out')
        }

        let bookingService;
        if (bookingDoc.get('group')) {
            bookingService = (await t.get(firestore.collection('hotels').doc(hotelID).collection('bookings').doc(bookingDoc.get('sid')).collection('services').where('order_id', '==', orderId))).docs[0];
        } else {
            bookingService = (await t.get(firestore.collection('hotels').doc(hotelID).collection('bookings').doc(bookingID).collection('services').where('order_id', '==', orderId))).docs[0];
        }

        if (bookingService === undefined) {
            throw new functions.https.HttpsError('cancelled', 'can-not-find-restaurant-service-with-order-id')
        }

        t.delete(bookingService.ref);
        return { 'result': true, 'message': 'OK' };
    }).catch((e) => {
        res.json({ 'result': false, 'message': e.message });
    });
    res.json(transaction);

});