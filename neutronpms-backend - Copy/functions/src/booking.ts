import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { BookingStatus, PaymentStatus } from './constant/status';
import { BookingType, HotelPackage } from './constant/type';
import { UserRole } from './constant/userrole';
import { DateUtil } from './util/dateutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';
import { RestUtil } from './util/restutil';
const fireStore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.onCreateBasicBooking = functions.firestore
    .document('hotels/{hotelID}/basic_bookings/{bookingID}')
    .onCreate(async (doc, _) => {
        try {
            const booking = doc.data();
            if (booking.status !== BookingStatus.booked && booking.status !== BookingStatus.unconfirmed) {
                return false;
            }
            const hotelRef = doc.ref.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                console.error('Not found hotel collection!');
                return false;
            }
            await NeutronUtil.updateCollectionDailyData(booking, true, hotelRef);
            return true;
        } catch (e) {
            console.error(e);
            return false;
        }
    });

exports.onDeleteBasicBooking = functions.firestore
    .document('hotels/{hotelID}/basic_bookings/{bookingID}')
    .onDelete(async (doc, _) => {
        const booking = doc.data();
        if ([BookingStatus.booked, BookingStatus.checkin, BookingStatus.checkout].includes(booking.status)) {
            const hotelRef = doc.ref.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                console.error('Not found hotel collection!');
                return false;
            }
            await NeutronUtil.updateCollectionDailyData(booking, false, hotelRef);
        }
        return true;
    });
// deploy here - ok  - was deploy
exports.onUpdateBasicBooking = functions.firestore
    .document('hotels/{hotelID}/basic_bookings/{bookingID}')
    .onUpdate(async (change, _) => {
        try {

            console.log("ID:" + change.before.id);

            const oldBookingDoc = change.before;
            // const newBookingDoc = change.after;
            const newBooking = change.after.data();
            const oldBooking = change.before.data();
            if (oldBooking.status === BookingStatus.moved || newBooking.status === BookingStatus.moved) { return true; };
            const hotelRef = oldBookingDoc.ref.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                console.error('Not found hotel collection!');
                return false;
            }
            const timeZone = oldBooking.time_zone;
            const oldRoom = oldBooking.room ?? '';
            const oldTypeTourists = oldBooking.type_tourists ?? '';
            const oldCountry = oldBooking.country ?? '';
            // const oldPrice: number[] = oldBooking.price;
            const oldBreakfast = oldBooking.breakfast;
            const oldLunch = oldBooking.lunch ?? false;
            const oldDinner = oldBooking.dinner ?? false;
            const oldAdult = oldBooking.adult;
            const oldChild = oldBooking.child;
            const oldRoomType = oldBooking.room_type;
            const oldSource = oldBooking.source;
            const oldPayAtHotel = oldBooking.pay_at_hotel;
            const oldInDateServer: Date = oldBooking.in_date.toDate();
            const oldOutDateServer: Date = oldBooking.out_date.toDate();
            // const oldInTimeServer: Date = oldBooking.in_time.toDate();
            const oldOutTimeServer: Date = oldBooking.out_time.toDate();

            const oldInDateTimezone = DateUtil.convertUpSetTimezone(oldInDateServer, timeZone);
            const oldOutDateTimezone = DateUtil.convertUpSetTimezone(oldOutDateServer, timeZone);
            const oldOutTimeTimezone = DateUtil.convertUpSetTimezone(oldOutTimeServer, timeZone);
            // const oldStayDaysServer: Date[] = DateUtil.getStayDates(oldInDateServer, oldOutDateServer);

            const room = newBooking.room ?? '';
            const typeTourists = newBooking.type_tourists ?? '';
            const country = newBooking.country ?? '';
            // const price: number[] = newBooking.price;
            const breakfast = newBooking.breakfast;
            const lunch = newBooking.lunch ?? false;
            const dinner = newBooking.dinner ?? false;
            const adult = newBooking.adult;
            const child = newBooking.child;
            const roomType = newBooking.room_type;
            const source = newBooking.source;
            const payAtHotel = newBooking.pay_at_hotel;

            const inDateServer: Date = newBooking.in_date.toDate();
            const outDateServer: Date = newBooking.out_date.toDate();

            const inTimeServer: Date = newBooking.in_time.toDate();
            const inTimeTimezone: Date = DateUtil.convertUpSetTimezone(inTimeServer, timeZone);
            const outTimeServer: Date = newBooking.out_time.toDate();
            const outTimeTimezone: Date = DateUtil.convertUpSetTimezone(outTimeServer, timeZone);

            // const stayDaysServer: Date[] = DateUtil.getStayDates(inDateServer, outDateServer);
            const inDateTimezone = DateUtil.convertUpSetTimezone(inDateServer, timeZone);
            const outDateTimezone = DateUtil.convertUpSetTimezone(outDateServer, timeZone);

            const nowServer = new Date();
            const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timeZone);
            const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
            const dayAfterIndateTimezone = DateUtil.addDate(inDateTimezone, 1);
            const nextInDate0hTimezone = new Date(dayAfterIndateTimezone.getFullYear(), dayAfterIndateTimezone.getMonth(), dayAfterIndateTimezone.getDate(), 0, 0, 0);

            if (oldRoom === room
                && oldBreakfast === breakfast && oldLunch === lunch && oldDinner === dinner && oldAdult === adult
                && oldChild === child && oldRoomType === roomType
                && oldTypeTourists === typeTourists && oldCountry === country
                && oldSource === source && oldPayAtHotel === payAtHotel
                && DateUtil.equal(oldInDateServer, inDateServer) && DateUtil.equal(oldOutDateServer, outDateServer) && newBooking.status === oldBooking.status && NeutronUtil.getRoomCharge(newBooking) === NeutronUtil.getRoomCharge(oldBooking)) {
                return true;
            }

            //for group booking
            if (oldBooking.group === true || newBooking.group === true) {
                if (newBooking.status !== oldBooking.status) {
                    const batch = fireStore.batch();
                    if (newBooking.status === BookingStatus.noshow) {
                        if (nextInDate0hTimezone.getTime() <= nowTimezone.getTime()) {
                            batch.update(
                                hotelRef.collection('management').doc('overdue_bookings'),
                                { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                            await batch.commit();
                        };
                        await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                    } else if (newBooking.status === BookingStatus.cancel) {
                        //Cancel
                        if (nextInDate0hTimezone.getTime() <= nowTimezone.getTime()) {
                            batch.update(
                                hotelRef.collection('management').doc('overdue_bookings'),
                                { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                            await batch.commit();
                        };
                        await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                    } else if (newBooking.status === BookingStatus.checkin) {
                        if (oldBooking.status === BookingStatus.booked) {
                            // check in
                            if (inTimeTimezone.getTime() >= nextInDate0hTimezone.getTime()) {
                                batch.update(
                                    hotelRef.collection('management').doc('overdue_bookings'),
                                    { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                            };

                            if (outDateTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() >= now12hTimezone.getTime()) {
                                batch.update(
                                    hotelRef.collection('management').doc('overdue_bookings'),
                                    {
                                        ['overdue_bookings.checkout.' + oldBookingDoc.id]: {
                                            'name': newBooking.name,
                                            'type': 'overdue-checkout'
                                        }
                                    });
                            };
                            await batch.commit();
                        } else if (oldBooking.status === BookingStatus.checkout) {
                            //undo checkout
                            if (outTimeTimezone.getTime() <= now12hTimezone.getTime()) {
                                batch.update(hotelRef.collection('management').doc('overdue_bookings'), {
                                    ['overdue_bookings.checkout.' + oldBookingDoc.id]: {
                                        'name': newBooking.name,
                                        'type': 'overdue-checkout'
                                    }
                                });
                            };
                            await batch.commit();
                        }
                    } else if (newBooking.status === BookingStatus.booked) {
                        if (oldBooking.status === BookingStatus.checkin) {
                            //Undo check-in
                            if (nextInDate0hTimezone.getTime() <= nowTimezone.getTime()) {
                                batch.update(
                                    hotelRef.collection('management').doc('overdue_bookings'), {
                                    ['overdue_bookings.checkin.' + oldBookingDoc.id]: {
                                        'name': newBooking.name,
                                        'type': 'overdue-checkin'
                                    }
                                });
                            };
                            await batch.commit();
                        }
                    } else if (newBooking.status === BookingStatus.checkout) {
                        if (oldBooking.status === BookingStatus.checkin) {
                            //Check-out
                            // if (outTimeTimezone.getTime() > now12hTimezone.getTime()) {
                            batch.update(hotelRef.collection('management').doc('overdue_bookings'), {
                                ['overdue_bookings.checkout.' + oldBookingDoc.id]: FieldValue.delete()
                            });
                            // }
                            await batch.commit();
                        }
                    }

                } else {

                    await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                    await NeutronUtil.updateCollectionDailyData(newBooking, true, hotelRef);

                    //update room for service of group booking after change room
                    if (oldRoom !== room || oldSource !== source) {

                        const batch = fireStore.batch();

                        if (oldRoom !== room) {
                            const bookingServiceRef = hotelRef.collection('bookings').doc(newBooking.sid).collection('services');
                            const bookingServiceDocs = await bookingServiceRef.get();
                            if (bookingServiceDocs.size > 0) {
                                for (const service of bookingServiceDocs.docs) {
                                    if (service.get('room') === oldRoom) {
                                        batch.update(service.ref, { 'room': room })
                                    }
                                }
                            }
                        }

                        const bookingDepositDocs = await hotelRef.collection('bookings').doc(newBooking.sid).collection('deposits').get();
                        // const dataUpdateDeposit: { [key: string]: any } = {};
                        if (!bookingDepositDocs.empty) {
                            const dataUpdateDeposit: { [key: string]: any } = {};

                            for (const deposit of bookingDepositDocs.docs) {

                                if (deposit.get('room') === oldRoom && oldRoom !== room) {
                                    dataUpdateDeposit['room'] = room;
                                }

                                if (deposit.get('source') === oldSource && oldSource !== source) {
                                    dataUpdateDeposit['source'] = source;
                                }

                                batch.update(deposit.ref, dataUpdateDeposit)
                            }
                        }

                        await batch.commit();
                    }
                }
                return true;
            }

            //for normal booking
            if (newBooking.status !== oldBooking.status) {
                const batch = fireStore.batch();
                if (newBooking.status === BookingStatus.noshow) {
                    if (nextInDate0hTimezone <= nowTimezone) {
                        batch.update(
                            hotelRef.collection('management').doc('overdue_bookings'),
                            { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                        await batch.commit();
                    };
                    await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                } else if (newBooking.status === BookingStatus.cancel) {
                    //Cancel
                    if (nextInDate0hTimezone <= nowTimezone) {
                        batch.update(
                            hotelRef.collection('management').doc('overdue_bookings'),
                            { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                        await batch.commit();
                    };
                    await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                } else if (newBooking.status === BookingStatus.checkin) {
                    if (oldBooking.status === BookingStatus.booked) {
                        //Check-in
                        const info = DateUtil.dateToDayMonthString(inDateTimezone) + '-' + DateUtil.dateToDayMonthString(outDateTimezone);
                        const roomData: { [key: string]: any } = {};
                        roomData['data.rooms.' + oldRoom + '.bid'] = oldBookingDoc.id;
                        roomData['data.rooms.' + oldRoom + '.binfo'] = info;
                        batch.update(
                            hotelRef.collection('management').doc('configurations'), roomData);
                        // update overdue-checkin here
                        if (inTimeTimezone.getTime() >= nextInDate0hTimezone.getTime()) {
                            batch.update(
                                hotelRef.collection('management').doc('overdue_bookings'),
                                { ['overdue_bookings.checkin.' + oldBookingDoc.id]: FieldValue.delete() });
                        };

                        if (outDateTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() >= now12hTimezone.getTime()) {
                            batch.update(
                                hotelRef.collection('management').doc('overdue_bookings'),
                                {
                                    ['overdue_bookings.checkout.' + oldBookingDoc.id]: {
                                        'name': newBooking.name,
                                        'type': 'overdue-checkout'
                                    }
                                });
                        };
                        await batch.commit();

                    } else if (oldBooking.status === BookingStatus.checkout) {
                        // undo - checkout
                        const fullBooking = (await hotelRef.collection('bookings').doc(oldBookingDoc.id).get()).data();
                        const info = DateUtil.dateToDayMonthString(oldInDateTimezone) + '-' + DateUtil.dateToDayMonthString(oldOutDateTimezone);

                        if (fullBooking !== undefined) {
                            const roomData: { [key: string]: any } = {};
                            roomData['data.rooms.' + oldRoom + '.bid'] = oldBookingDoc.id;
                            roomData['data.rooms.' + oldRoom + '.binfo'] = info;
                            batch.update(
                                hotelRef.collection('management').doc('configurations'), roomData);
                            NeutronUtil.updateRevenueCollectionDailyDataWithBatch(batch, fullBooking, hotelRef, false, oldOutTimeTimezone);
                        }

                        if (nowTimezone.getTime() < oldOutDateTimezone.getTime()) {
                            let breakDate: Date;
                            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                                breakDate = now12hTimezone;
                            } else {
                                breakDate = DateUtil.addDate(now12hTimezone, -1);
                            }

                            if (breakDate.getTime() < oldInDateTimezone.getTime()) {
                                breakDate = oldInDateTimezone;
                            }
                            const newStayDays = DateUtil.getStayDates(breakDate, oldOutDateTimezone);
                            NeutronUtil.updateBreakfastGuestCollectionDailyDataWithBatch(batch, hotelRef, newStayDays, oldBooking, true, now12hTimezone, oldTypeTourists, oldCountry);
                        }

                        // update overdue-checkout here
                        if (oldOutTimeTimezone.getTime() > now12hTimezone.getTime()) {
                            batch.update(hotelRef.collection('management').doc('overdue_bookings'), {
                                ['overdue_bookings.checkout.' + oldBookingDoc.id]: {
                                    'name': newBooking.name,
                                    'type': 'overdue-checkout'
                                }
                            });
                        };

                        await batch.commit();
                    }
                } else if (newBooking.status === BookingStatus.booked) {
                    if (oldBooking.status === BookingStatus.checkin) {
                        //Undo check-in
                        const roomData: { [key: string]: any } = {};
                        roomData['data.rooms.' + oldRoom + '.bid'] = null;
                        roomData['data.rooms.' + oldRoom + '.binfo'] = null;
                        roomData['data.rooms.' + oldRoom + '.clean'] = false;
                        batch.update(
                            hotelRef.collection('management').doc('configurations'), roomData);

                        // update overdue-checkin
                        if (nextInDate0hTimezone.getTime() <= nowTimezone.getTime()) {
                            batch.update(
                                hotelRef.collection('management').doc('overdue_bookings'), {
                                ['overdue_bookings.checkin.' + oldBookingDoc.id]: {
                                    'name': newBooking.name,
                                    'type': 'overdue-checkin'
                                }
                            });
                        };
                        await batch.commit();
                    }

                } else if (newBooking.status === BookingStatus.checkout) {
                    if (oldBooking.status === BookingStatus.checkin) {
                        // toto already update daily allotment and hls
                        //Check-out
                        const roomData: { [key: string]: any } = {};
                        roomData['data.rooms.' + oldRoom + '.bid'] = null;
                        roomData['data.rooms.' + oldRoom + '.binfo'] = null;
                        roomData['data.rooms.' + oldRoom + '.clean'] = false;
                        roomData['data.rooms.' + oldRoom + '.vacant_overnight'] = false;
                        batch.update(
                            hotelRef.collection('management').doc('configurations'), roomData);
                        const fullBooking = (await hotelRef.collection('bookings').doc(oldBookingDoc.id).get()).data();
                        if (fullBooking !== undefined) {
                            const outTime = DateUtil.convertUpSetTimezone(fullBooking.out_time.toDate(), timeZone);
                            NeutronUtil.updateRevenueCollectionDailyDataWithBatch(batch, fullBooking, hotelRef, true, outTime);
                        }

                        if (nowTimezone.getTime() < oldOutDateTimezone.getTime()) {
                            let breakDate: Date;
                            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                                breakDate = now12hTimezone;
                            } else {
                                breakDate = DateUtil.addDate(now12hTimezone, -1);
                            }

                            if (breakDate.getTime() < oldInDateTimezone.getTime()) {
                                breakDate = oldInDateTimezone;
                            }
                            const newStayDays = DateUtil.getStayDates(breakDate, oldOutDateTimezone);
                            NeutronUtil.updateBreakfastGuestCollectionDailyDataWithBatch(batch, hotelRef, newStayDays, oldBooking, false, now12hTimezone, oldTypeTourists, oldCountry);
                        }

                        // update overdue checkout
                        // if (outTimeTimezone.getTime() > now12hTimezone.getTime()) {
                        batch.update(hotelRef.collection('management').doc('overdue_bookings'), {
                            ['overdue_bookings.checkout.' + oldBookingDoc.id]: FieldValue.delete()
                        });
                        // }

                        await batch.commit();
                    }
                }
            } else {
                const batch = fireStore.batch();
                if (newBooking.status === BookingStatus.checkin) {
                    if (roomType !== oldRoomType || room !== oldRoom) {
                        //Change staying room
                        const info = DateUtil.dateToDayMonthString(inDateTimezone) + '-' + DateUtil.dateToDayMonthString(outDateTimezone);
                        const roomData: { [key: string]: any } = {};
                        roomData['data.rooms.' + oldRoom + '.bid'] = null;
                        roomData['data.rooms.' + oldRoom + '.binfo'] = null;
                        roomData['data.rooms.' + oldRoom + '.clean'] = false;
                        roomData['data.rooms.' + room + '.bid'] = oldBookingDoc.id;
                        roomData['data.rooms.' + room + '.binfo'] = info;
                        batch.update(
                            hotelRef.collection('management').doc('configurations'), roomData);
                    } else if (oldOutDateServer.getTime() !== outDateServer.getTime()) {
                        //change out-date
                        const info = DateUtil.dateToDayMonthString(inDateTimezone) + '-' + DateUtil.dateToDayMonthString(outDateTimezone);
                        batch.update(hotelRef.collection('management').doc('configurations'), {
                            ['data.rooms.' + room + '.binfo']: info
                        });
                        // now12hTimezone
                        if (outDateTimezone.getTime() > now12hTimezone.getTime()) {
                            batch.update(hotelRef.collection('management').doc('overdue_bookings'), {
                                [`overdue_bookings.checkout.${oldBookingDoc.id}`]: FieldValue.delete()
                            });
                        }
                    }
                }

                await NeutronUtil.updateCollectionDailyData(oldBooking, false, hotelRef);
                await NeutronUtil.updateCollectionDailyData(newBooking, true, hotelRef);

                //update room for service of group booking after change room
                if (oldRoom !== room || oldSource !== source) {
                    // const batch = fireStore.batch();
                    const dataUpdateDeposit: { [key: string]: any } = {};

                    if (oldSource !== source) {
                        dataUpdateDeposit['source'] = source;
                    }

                    if (oldRoom !== room) {
                        dataUpdateDeposit['room'] = room;
                        const bookingServiceRef = hotelRef.collection('bookings').doc(change.after.id).collection('services');
                        const bookingServiceDocs = await bookingServiceRef.get();
                        if (bookingServiceDocs.size > 0) {
                            for (const service of bookingServiceDocs.docs) {
                                batch.update(service.ref, { 'room': room })
                            }
                        }
                    }

                    const bookingDepositDocs = await hotelRef.collection('bookings').doc(change.after.id).collection('deposits').get();
                    if (!bookingDepositDocs.empty) {
                        for (const deposit of bookingDepositDocs.docs) {
                            batch.update(deposit.ref, dataUpdateDeposit)
                        }
                    }

                }

                await batch.commit();
            }
            return true;
        } catch (e) {
            console.error(e);
            return false;
        }
    });

// deploy here - ok - was deploy
exports.undoCheckout = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();

    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUndoCheckout;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const nowServer = new Date();
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('bookings').doc(data.booking_id));
        const booking = bookingDoc.data();

        if (!bookingDoc.exists || booking === undefined)
            throw new functions.https.HttpsError("cancelled", MessageUtil.BOOKING_NOT_FOUND);
        if (bookingDoc.get('status') !== BookingStatus.checkout)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_WAS_UNDO_CHECKOUT);

        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        const outTimeServer: Date = bookingDoc.data()?.out_time.toDate();
        const outDateServer: Date = bookingDoc.data()?.out_date.toDate();
        const outTimeTimezone = DateUtil.convertUpSetTimezone(outTimeServer, timezone);
        const outDateTimezone = DateUtil.convertUpSetTimezone(outDateServer, timezone);
        const outTime24hTimezone = new Date(outTimeTimezone.getFullYear(), outTimeTimezone.getMonth(), outTimeTimezone.getDate(), 23, 59, 0);
        const roomId = booking.room;
        const roomType = booking.room_type;
        // check time 
        if (nowTimezone.getTime() > outTime24hTimezone.getTime()) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_OVER_TIME_UNDO_CHECKOUT)
        }
        const configurationsRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));
        // Check booking id  in room
        const rooms: { [key: string]: any } = configurationsRef.get('data')['rooms'];

        if (rooms[roomId]['bid'] !== null) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_CAN_NOT_UNDO_CHECKOUT_BECAUSE_CONFLIX_ROOM)
        }

        // update hls and daily allotment
        if (nowTimezone.getTime() < outDateTimezone.getTime()) {
            let breakDate: Date;
            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                breakDate = now12hTimezone;
            } else {
                breakDate = DateUtil.addDate(now12hTimezone, -1);
            }
            const stayDayTimezone: Date[] = DateUtil.getStayDates(breakDate, outDateTimezone);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDayTimezone, t);
            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomType, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, true, almRoomBooked, roomId, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hTimezone);
        }

        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('bookings').doc(data.booking_id), { 'status': BookingStatus.checkin, 'out_time': booking.out_date });
        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('basic_bookings').doc(data.booking_id), { 'status': BookingStatus.checkin, 'out_time': booking.out_date });

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            // fields of Activities collection
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'id': data.booking_id,
                'booking_id': data.booking_id,
                'type': 'booking',
                'desc': booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'undo_checkout'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.checkIn = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId: string = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckIn;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(data.booking_id)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const outDayBookingServer: Date = booking.out_date.toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);

        const inDayBookingServer: Date = booking.in_date.toDate();
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);

        const roomId = booking.room;
        const roomType = booking.room_type;

        if (inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
        }

        if ((nowTimezone.getTime() - outDayBookingTimezone.getTime() >= 0 || inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000)
            && (!roleOfUser.includes(UserRole.admin) && !roleOfUser.includes(UserRole.owner) && !roleOfUser.includes(UserRole.manager))) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
        }

        if (booking.status === BookingStatus.checkin)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_WAS_CHECKEDIN);

        if (booking.status !== BookingStatus.booked)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);

        if (roomId === '') {
            throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_WAS_DELETE);
        }

        const configurationRef = await t.get(hotelRef.collection('management').doc('configurations'));

        if (!configurationRef.exists) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.CONFIGURATION_NOT_FOUND);
        }

        const rooms: { [key: string]: any }[] = configurationRef.get('data')['rooms'];

        if (rooms[roomId] === undefined || rooms[roomId] === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_NOT_FOUND);
        }

        if (rooms[roomId]['bid'] !== null) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_STILL_NOT_CHECKOUT);
        }

        if (rooms[roomId]['clean'] !== true) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_MUST_CLEAN);
        }

        // update daily allotment
        if (inDayBookingTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() < now12hTimezone.getTime()) {
            const yesterday: Date = DateUtil.addDate(now12hTimezone, -1);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, [yesterday], t);
            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomType, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, [yesterday], true, almRoomBooked, roomId, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hTimezone);
        }

        t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), {
            'status': BookingStatus.checkin, 'in_time': nowServer
        });
        t.update(hotelRef.collection('bookings').doc(data.booking_id), {
            'status': BookingStatus.checkin, 'in_time': nowServer
        });

        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'id': data.booking_id,
                'booking_id': data.booking_id,
                'type': 'booking',
                'desc': booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'checkin'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.checkOut = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const mappingHotelId = hotelDoc.get('mapping_hotel_id') ?? '';
    const mappingHotelKey = hotelDoc.get('mapping_hotel_key') ?? '';
    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckOut;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(data.booking_id));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (booking.status === BookingStatus.checkout)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_CHECKOUT_BEFORE);

        if (booking.status !== BookingStatus.checkin)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_CHECKIN);
        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const outDayBookingServer: Date = booking.out_date.toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        //now and out_date convert to miliseconds. minus then compare to 12hours
        if (nowTimezone.getTime() - outDayBookingTimezone.getTime() > 12 * 60 * 60 * 1000
            && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_OVER_TIME_CHECKOUT);
        }

        if (booking.renting_bike_num > 0) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_CHECKOUT_BIKES);
        }

        const transferred = booking.transferred === undefined ? 0 : booking.transferred;
        const deposit = booking.deposit === undefined ? 0 : booking.deposit;
        const transferring = booking.transferring === undefined ? 0 : booking.transferring;
        const serviceCharge = NeutronUtil.getServiceCharge(booking);
        const roomCharge = NeutronUtil.getRoomCharge(booking);
        const discount = NeutronUtil.getDiscount(booking);
        const totalCharge = serviceCharge + roomCharge - discount;
        const remaining = totalCharge + transferred - deposit - transferring;
        const roomTypeBooking: string = booking.room_type;
        const roomBooking: string = booking.room;

        if (remaining < -NeutronUtil.kZero || remaining > NeutronUtil.kZero) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT);
        }

        // check if out date early -> update again dailyallotment
        if (nowTimezone.getTime() < outDayBookingTimezone.getTime()) {
            let breakDate: Date;
            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                breakDate = now12hTimezone;
            } else {
                breakDate = DateUtil.addDate(now12hTimezone, -1);
            }
            const stayDayTimezone = DateUtil.getStayDates(breakDate, outDayBookingTimezone);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDayTimezone, t);
            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, false, almRoomBooked, roomBooking, null, mappingHotelId, mappingHotelKey, dailyAllotments, now12hTimezone);
        }

        t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), {
            'status': BookingStatus.checkout, 'out_time': nowServer
        });
        t.update(hotelRef.collection('bookings').doc(data.booking_id), {
            'status': BookingStatus.checkout, 'out_time': nowServer
        });

        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'id': data.booking_id,
                'booking_id': data.booking_id,
                'type': 'booking',
                'desc': booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'checkout'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.undoCheckIn = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUndoCheckIn;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const bookingId = data.booking_id;

    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        const booking = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (booking.status !== BookingStatus.checkin) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_CHECKIN);
        }

        if (booking.status === BookingStatus.booked) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_WAS_BOOKED);
        }

        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const inDayBookingServer: Date = booking.in_date.toDate();
        const inTimeBookingServer: Date = booking.in_time.toDate();
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);
        const roomId = booking.room;
        const roomType = booking.room_type;

        if ((nowTimezone.getTime() - inDayBookingTimezone.getTime()) / 60 / 60 / 1000 > 12
            && (!roleOfUser.includes(UserRole.admin) && !roleOfUser.includes(UserRole.owner) && !roleOfUser.includes(UserRole.manager)))
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_OVER_TIME_UNDO_CHECKIN);

        // update daily allotment and hls here
        if (inTimeBookingServer.getTime() < inDayBookingServer.getTime()) {
            const preCheckInDay = DateUtil.addDate(inDayBookingTimezone, -1);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, [preCheckInDay], t);
            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomType, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, [preCheckInDay], false, almRoomBooked, roomId, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hTimezone);
        }

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
            'status': BookingStatus.booked, 'in_time': inDayBookingServer
        });
        t.update(hotelRef.collection('bookings').doc(bookingId), {
            'status': BookingStatus.booked, 'in_time': inDayBookingServer
        });

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'id': bookingId,
                'booking_id': bookingId,
                'type': 'booking',
                'desc': booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'undo_checkin'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        return MessageUtil.SUCCESS;
    }).catch((error) => {
        throw new functions.https.HttpsError('permission-denied', error.message);
    });
    return res;
});

///update
// deploy here - ok - was deploy
exports.addBooking = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();

    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesAddOrUpdateBooking;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const hotelPackage = hotelDoc.get('package');
    const timeZone = hotelDoc.get('timezone');
    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const price: number[] = data.price;
    const bookingType: number = data.booking_type;
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
    const now12hOfTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    const inDayTimezone: Date = new Date(data.in_date);
    const outDayTimezone: Date = new Date(data.out_date);
    const stayDaysTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
    const isGroup: boolean = data.group;
    const inDayBookingServer: Date = DateUtil.convertOffSetTimezone(inDayTimezone, timeZone);
    const outDayBookingServer: Date = DateUtil.convertOffSetTimezone(outDayTimezone, timeZone);
    const lengthStay: number = DateUtil.getDateRange(inDayTimezone, outDayTimezone);
    const yesterday12hTimezone = DateUtil.addDate(now12hOfTimezone, -1);
    const stayDays = DateUtil.getStayDates(inDayBookingServer, outDayBookingServer);
    const idDoc = NumberUtil.getSidByConvertToBase62();
    const declarationInvoiceDetail: any = data.declaration_invoice_detail !== null ? new Map(Object.entries(data.declaration_invoice_detail)) : undefined;
    const listGuestDeclaration: Array<any> = data.list_guest_declaration;
    const isTaxDeclare: boolean = data.tax_declare ?? false;
    const isDeclareInfoEmpty: boolean = declarationInvoiceDetail === undefined ? true : NeutronUtil.isMapFieldEmpty(declarationInvoiceDetail);
    const isDeclareGuestEmpty: boolean = listGuestDeclaration === null || listGuestDeclaration.length === 0;
    const typeTourists: string = data.type_tourists ?? '';
    const country: string = data.country ?? '';
    const roomId = data.room_id;
    const roomTypeId = data.room_type_id;
    const emailSaler = data.saler;
    const lunch: boolean = data.lunch ?? false;
    const dinner: boolean = data.dinner ?? false;

    if (lengthStay > 31 && bookingType == BookingType.dayly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_31);
    }

    if (lengthStay > 365 && bookingType == BookingType.monthly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_365);
    }

    if (inDayTimezone.getTime() < yesterday12hTimezone.getTime() || (inDayTimezone.getTime() === yesterday12hTimezone.getTime() && nowTimezone.getTime() > now12hOfTimezone.getTime()))
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INDATE_MUST_NOT_IN_PAST);

    // if (NeutronUtil.regExpName(data.name) === false)
    //     throw new functions.https.HttpsError('permission-denied', MessageUtil.INPUT_NAME);

    const configurationRef = await hotelRef.collection('management').doc('configurations').get();
    const rooms: { [key: string]: any } = configurationRef.get('data')['rooms'];
    const roomsOfRoomType: string[] = [];
    Object.keys(rooms).map((idRoom) => {
        if (rooms[idRoom]['room_type'] === roomTypeId) {
            roomsOfRoomType.push(idRoom);
        }
    });

    if (data.status === BookingStatus.repair) {
        const res = await fireStore.runTransaction(async (t) => {

            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezone, t);

            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDaysTimezone, dailyAllotments, roomTypeId);
            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
            }

            const availableRooms: string[] = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDaysTimezone, dailyAllotments, roomsOfRoomType);
            if (availableRooms.indexOf(roomId) === -1) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
            }

            t.set(hotelRef.collection('basic_bookings').doc(idDoc), {
                'name': data.name,
                'room': roomId,
                'room_type': roomTypeId,
                'in_date': inDayBookingServer,
                'in_time': inDayBookingServer,
                'out_date': outDayBookingServer,
                'out_time': outDayBookingServer,
                'stay_days': stayDays,
                'status': BookingStatus.repair,
                'time_zone': timeZone,
                'creator': context.auth?.token.email,
            });

            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeId);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeId, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDaysTimezone, true, almRoomBooked, roomId, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hOfTimezone);

            return MessageUtil.SUCCESS;
        });
        return res;

    }
    if (data.phone !== '') {
        const token = context.rawRequest.headers.authorization;
        const options = {
            hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
            path: '/addBooking',
            method: 'POST',
            headers: {
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        };
        const postData = JSON.stringify({
            'name': data.name,
            'phone': data.phone,
            'inDate': data.in_date,
            'outDate': data.out_date,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        });
        RestUtil.postRequest(options, postData).catch(console.error);
    }

    if (price === undefined || price === null) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INPUT_PRICE);
    }
    if (lengthStay !== price.length && bookingType == BookingType.dayly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.NOT_SAME_LENGTH_PRICE_STAYSDAY);
    }

    if (data.rate_plan_id === 'OTA') {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
    }

    if ((data.adult === undefined || data.adult === null || (data.adult as number) < 0 || data.child === undefined || data.child === null || (data.child as number) < 0))
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INPUT_PRICE);

    const res = await fireStore.runTransaction(async (t) => {
        const hotelRefGet = await t.get(fireStore.collection('hotels').doc(data.hotel_id));
        const mapBooking: { [key: string]: any } = await NumberUtil.getSidBookingBySidHotel(hotelRefGet, hotelRef, t, data.sid);

        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezone, t);
        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDaysTimezone, dailyAllotments, roomTypeId);
        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
        }
        // check available room here
        if (roomId !== '') {
            const availableRooms: string[] = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDaysTimezone, dailyAllotments, roomsOfRoomType);
            if (availableRooms.indexOf(roomId) === -1) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
            }
        }

        const declareInfo: { [key: string]: any } = {};
        if (declarationInvoiceDetail !== undefined) {
            (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                declareInfo[k] = v;
            });
        }

        if (isGroup) {
            const bookingDoc = await t.get(hotelRef.collection('bookings').doc(data.sid));

            // if (typeTourists !== bookingDoc.get('type_tourists') || country !== bookingDoc.get('country')) {
            //     throw new functions.https.HttpsError('cancelled', MessageUtil.PLEASE_CHOOSE_RIGHT_COUNTRY);
            // }
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.UNDEFINED_ERROR);
            }
            if (bookingDoc.get('rate_plan') !== data.rate_plan_id) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_GROUP_CANNOT_CHANGE_RATE_PLAN);
            }
            const inDayBookingGroupServer: Date = bookingDoc.get('in_date').toDate();
            const outDayBookingGroupServer: Date = bookingDoc.get('out_date').toDate();
            const priceBookingGroup: number[] = bookingDoc.get('price');
            const dataUpdate: { [key: string]: any } = {};
            for (let index = 0; index < price.length; index++) {
                if (priceBookingGroup[index] === undefined) {
                    priceBookingGroup[index] = price[index];
                } else {
                    priceBookingGroup[index] = priceBookingGroup[index] + price[index];
                }
            }
            dataUpdate['sub_bookings.' + idDoc + '.in_date'] = inDayBookingServer;
            dataUpdate['sub_bookings.' + idDoc + '.out_date'] = outDayBookingServer;
            dataUpdate['sub_bookings.' + idDoc + '.room_type'] = data.room_type_id;
            dataUpdate['sub_bookings.' + idDoc + '.room'] = data.room_id;
            dataUpdate['sub_bookings.' + idDoc + '.status'] = data.status;
            dataUpdate['sub_bookings.' + idDoc + '.price'] = price;
            dataUpdate['sub_bookings.' + idDoc + '.adult'] = data.adult;
            dataUpdate['sub_bookings.' + idDoc + '.child'] = data.child;
            dataUpdate['sub_bookings.' + idDoc + '.bed'] = data.bed;
            dataUpdate['sub_bookings.' + idDoc + '.breakfast'] = data.breakfast;
            dataUpdate['sub_bookings.' + idDoc + '.lunch'] = lunch
            dataUpdate['sub_bookings.' + idDoc + '.dinner'] = dinner;
            dataUpdate['sub_bookings.' + idDoc + '.tax_declare'] = isTaxDeclare;
            dataUpdate['sub_bookings.' + idDoc + '.type_tourists'] = typeTourists;
            dataUpdate['sub_bookings.' + idDoc + '.country'] = country;
            dataUpdate['sub_bookings.' + idDoc + '.creator'] = context.auth?.token.email;
            dataUpdate['email_saler'] = emailSaler == "" ? context.auth?.token.email : emailSaler;

            if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                listGuestDeclaration.forEach((e) => {
                    e['date_of_birth'] = new Date(e['date_of_birth']);
                });
                dataUpdate['sub_bookings.' + idDoc + '.guest'] = listGuestDeclaration;
                dataUpdate['has_declaration'] = true;
            }
            if (declarationInvoiceDetail !== undefined && !isDeclareInfoEmpty) {
                dataUpdate['declare_info'] = {};
                (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                    dataUpdate['declare_info'][k] = v;
                });
            }
            //if other subBooking has tax_declare = true, and this subBooking is false 
            //  => use IF-ELSE to prevent ...
            if (isTaxDeclare) {
                dataUpdate['tax_declare'] = isTaxDeclare;
            }
            dataUpdate['price'] = priceBookingGroup;
            if (inDayBookingGroupServer.getTime() > inDayBookingGroupServer.getTime()) {
                dataUpdate['in_date'] = inDayBookingServer;
            }
            if (outDayBookingGroupServer.getTime() < outDayBookingServer.getTime()) {
                dataUpdate['out_date'] = outDayBookingServer;
            }
            t.update(hotelRef.collection('bookings').doc(data.sid), dataUpdate);
        } else {
            const dataCreate: { [key: string]: any } = {
                'name': data.name,
                'bed': data.bed,
                'in_date': inDayBookingServer,
                'in_time': inDayBookingServer,
                'out_date': outDayBookingServer,
                'out_time': outDayBookingServer,
                'room': roomId,
                'room_type': roomTypeId,
                'rate_plan': data.rate_plan_id,
                'status': data.status,
                'source': data.source,
                'sid': mapBooking["sid"],
                'phone': data.phone,
                'email': data.email,
                'price': price,
                'breakfast': data.breakfast,
                'lunch': lunch,
                'dinner': dinner,
                'pay_at_hotel': data.pay_at_hotel,
                'adult': data.adult,
                'child': data.child,
                'group': data.group,
                'created': nowServer,
                'virtual': false,
                'time_zone': timeZone,
                'tax_declare': isTaxDeclare,
                'type_tourists': typeTourists,
                'country': country,
                'creator': context.auth?.token.email,
                'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                'booking_type': bookingType,
            };
            if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                listGuestDeclaration.forEach((e) => {
                    e['date_of_birth'] = new Date(e['date_of_birth']);
                });
                dataCreate['guest'] = listGuestDeclaration;
                dataCreate['has_declaration'] = true;
            } else {
                dataCreate['has_declaration'] = false;
            }
            if (declarationInvoiceDetail !== undefined && !isDeclareInfoEmpty) {
                dataCreate['declare_info'] = {};
                (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                    dataCreate['declare_info'][k] = v;
                });
            }
            t.create(hotelRef.collection('bookings').doc(idDoc), dataCreate);
        };

        const dataAdded: { [key: string]: any } = {
            'name': data.name,
            'bed': data.bed,
            'in_date': inDayBookingServer,
            'in_time': inDayBookingServer,
            'out_date': outDayBookingServer,
            'out_time': outDayBookingServer,
            'room': data.room_id,
            'room_type': data.room_type_id,
            'rate_plan': data.rate_plan_id,
            'status': data.status,
            'source': data.source,
            'sid': isGroup ? data.sid : mapBooking["sid"],
            'stay_days': stayDays,
            'phone': data.phone,
            'email': data.email,
            'notes': data.notes,
            'price': price,
            'breakfast': data.breakfast,
            'lunch': lunch,
            'dinner': dinner,
            'pay_at_hotel': data.pay_at_hotel,
            'adult': data.adult,
            'child': data.child,
            'group': isGroup,
            'created': nowServer,
            'time_zone': timeZone,
            'tax_declare': isTaxDeclare,
            'type_tourists': typeTourists,
            'country': country,
            'creator': context.auth?.token.email,
            'status_payment': PaymentStatus.unpaid,
            'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
            'booking_type': bookingType,
        }
        t.create(hotelRef.collection('basic_bookings').doc(idDoc), dataAdded);

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData: { [key: string]: any } = {
                'email': context.auth?.token.email,
                'id': idDoc,
                'booking_id': idDoc,
                'type': 'booking',
                'desc': data.name + NeutronUtil.specificChar + 'book_room' + NeutronUtil.specificChar + data.room_id,
                'created_time': new Date()
            };
            if (isGroup) {
                activityData['sid'] = data.sid;
            }
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        // await NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotment(t, hotelRef, stayDaysTimezone, true, data.room_type_id, data.room_id, hotelMappingId, hotelMappingKey, dailyAllotmentInMonthID, dailyAllotmentOutMonthID, now12hOfTimezone)

        const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeId);
        const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeId, cmId: mappingRoomType['id'] };
        NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDaysTimezone, true, almRoomBooked, roomId, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hOfTimezone);
        t.update(hotelRef, { "sid_booking": mapBooking["code"] });
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        throw new functions.https.HttpsError('cancelled', error.message);
    });
    return res
});

///update
// deploy here - ok - deploy again - deploy again with check in booking change out date
exports.updateBooking = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();
    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesAddOrUpdateBooking;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get(keyOfRole);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const hotelPackage = hotelDoc.get('package');
    const timezone: string = hotelDoc.get('timezone');
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const inDayNewTimezone: Date = new Date(data.in_date);
    const inDayNewServer: Date = DateUtil.convertOffSetTimezone(inDayNewTimezone, timezone);
    const outDayNewTimezone: Date = new Date(data.out_date);
    const outDayNewServer: Date = DateUtil.convertOffSetTimezone(outDayNewTimezone, timezone);
    const lengthStay: number = DateUtil.getDateRange(inDayNewTimezone, outDayNewTimezone);
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    const roomNewBooking: string = data.room_id;
    const roomTypeNewBooking: string = data.room_type_id;
    const priceNewBooking: number[] = data.price;
    const declarationInvoiceDetail: any = data.declaration_invoice_detail !== null ? new Map(Object.entries(data.declaration_invoice_detail)) : undefined;
    const listGuestDeclaration: Array<any> = data.list_guest_declaration;
    const isTaxDeclare: boolean = data.tax_declare;
    const phoneNew: string = data.phone;
    let phoneOld: string = '';
    const isDeclareInfoEmpty = declarationInvoiceDetail === undefined ? true : NeutronUtil.isMapFieldEmpty(declarationInvoiceDetail);
    const isDeclareGuestEmpty = listGuestDeclaration === null || listGuestDeclaration.length === 0;
    const typeTourists: string = data.type_tourists ?? '';
    const country: string = data.country ?? '';
    let checkOverdueBooking: boolean = false;
    const emailSaler = data.saler;
    const lunchNew: boolean = data.lunch ?? false;
    const dinnerNew: boolean = data.dinner ?? false;
    const bookingType: number = data.booking_type;


    if (data.adult === undefined || (data.adult as number) < 0 || data.child === undefined || (data.child as number) < 0)
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INPUT_ADULT_AND_CHILD);

    const res = fireStore.runTransaction(async (t) => {
        const basicBookingDoc = await t.get(hotelRef.collection('basic_bookings').doc(data.booking_id));
        if (!basicBookingDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }
        const basicBooking = basicBookingDoc.data()!;
        if (basicBooking?.booking_type !== bookingType && basicBooking?.booking_type != undefined) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.CAM_NOT_CHAGE_BOOKING_TYPE);
        }
        const roomTypeOldBooking = basicBooking.room_type;
        const inDayBookingServer: Date = basicBooking.in_date.toDate();
        const outDayBookingServer: Date = basicBooking.out_date.toDate();
        const lunchOld: boolean = basicBooking.lunch ?? false;
        const dinnerOld: boolean = basicBooking.dinner ?? false;
        const foundDay: Date[] = [];
        const stayDaysBooking: Date[] = [];
        for (const date of basicBooking.stay_days) {
            stayDaysBooking.push(date.toDate());
        }
        const stayDaysBookingNew: Date[] = DateUtil.getStayDates(inDayNewServer, outDayNewServer);
        for (const date of stayDaysBooking) {
            if (stayDaysBookingNew.find((e) => e.getTime() === date.getTime()) !== undefined) {
                foundDay.push(date);
            };
        };
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const roomOldBooking: string = basicBooking.room;

        const dataAdded: { [key: string]: any } = {};

        const configurationRef = await hotelRef.collection('management').doc('configurations').get();
        const rooms: { [key: string]: any } = configurationRef.get('data')['rooms'];
        const roomsOfRoomType: string[] = [];
        Object.keys(rooms).map((idRoom) => {
            if (rooms[idRoom]['room_type'] === roomTypeNewBooking) {
                roomsOfRoomType.push(idRoom);
            }
        });

        const inDateMin: Date = inDayNewTimezone.getTime() > inDayBookingTimezone.getTime() ? inDayBookingTimezone : inDayNewTimezone;
        const outDateMax: Date = outDayNewTimezone.getTime() > outDayBookingTimezone.getTime() ? outDayNewTimezone : outDayBookingTimezone;
        const stayDateMinMax: Date[] = DateUtil.getStayDates(inDateMin, outDateMax);
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateMinMax, t);

        if (basicBooking.status === BookingStatus.repair) {
            if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime()) {
                const availableRooms: string[] = [];

                if (foundDay.length === 0) {
                    const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);

                    const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDateTepm, dailyAllotments, roomTypeNewBooking);
                    if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                        throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                    }

                    const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                    availableRooms.push(...availableFoundDayNew);
                } else {
                    if (inDayBookingServer.getTime() <= inDayNewServer.getTime() && outDayNewServer.getTime() <= outDayBookingServer.getTime()) {
                        availableRooms.push(basicBooking.room);
                    }

                    if (inDayBookingServer.getTime() > inDayNewServer.getTime()) {
                        const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, inDayBookingTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDateTepm, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                        const availableRoomInDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                        availableRooms.push(...availableRoomInDate);
                    }

                    if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                        const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDateTepm, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                        const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                        availableRooms.push(...availableRoomOutDate);
                    }
                }

                if (availableRooms.indexOf(roomNewBooking) === -1) {
                    throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                }

                dataAdded['in_time'] = inDayNewServer;
                dataAdded['in_date'] = inDayNewServer;
                dataAdded['out_date'] = outDayNewServer;
                dataAdded['out_time'] = outDayNewServer;
                dataAdded['stay_days'] = stayDaysBookingNew;

                const alm: { [key: string]: { [key: string]: number } } = {};

                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeOldBooking, roomOldBooking, false, false);
                NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeOldBooking, false, dailyAllotments, alm);

                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBookingNew, roomTypeNewBooking, roomNewBooking, true, false);
                NeutronUtil.updateHlsToAlm(stayDaysBookingNew, roomTypeNewBooking, true, dailyAllotments, alm);


                if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
                    await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                    // await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, almDate, mappingHotelID, mappingHotelKey, now12hTimezone);
                }
            }
            dataAdded['name'] = data.name;
            t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), dataAdded);
            return MessageUtil.SUCCESS;
        }

        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(data.booking_id));
        const booking = bookingDoc.data();

        if (booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        const priceOldBooking: number[] = basicBooking.price;
        const priceRoomNew: number = priceNewBooking.reduce((previousValue, element) => previousValue + element);
        const priceRoomOld: number = priceOldBooking.reduce((previousValue, element) => previousValue + element);
        const deposits = booking.deposit ?? 0;
        const transferring = booking.transferring ?? 0;
        const totalAllDeposits = deposits + transferring;
        const totalServiceChargeAndRoomCharge: number =
            NeutronUtil.getServiceChargeAndRoomCharge(bookingDoc, true) + priceRoomNew;

        const inTimeBookingServer: Date = basicBooking.in_time.toDate();
        phoneOld = basicBooking.phone;
        const isHaveExtraHour: boolean = (booking.extra_hours !== undefined && (booking.extra_hours?.total ?? 0) !== 0) ? true : false;

        if (basicBooking.rate_plan === 'OTA') {
            if ((inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime() || data.pay_at_hotel !== booking.pay_at_hotel) && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.BOOKING_FROM_OTA_CAN_NOT_EDIT);
            }

            if (data.rate_plan_id !== 'OTA') {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
            }

        } else {
            if (data.rate_plan_id === 'OTA') {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
            }

            if (lengthStay > 31 && bookingType == BookingType.dayly) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_31);
            }

            if (lengthStay > 365 && bookingType == BookingType.monthly) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_365);
            }
        }
        if (roomOldBooking !== '' && roomNewBooking === '') {
            if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime()
                || NeutronUtil.getRoomCharge(priceNewBooking) !== NeutronUtil.getRoomCharge(priceOldBooking)
                || data.pay_at_hotel !== basicBooking.pay_at_hotel || data.breakfast !== basicBooking.breakfast || lunchNew !== lunchOld || dinnerNew !== dinnerOld
                || data.adult !== basicBooking.adult || data.child !== basicBooking.child || data.source !== basicBooking.source) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.SET_NONE_ROOM_CAN_NOT_EDIT_INFORMATION);
            }
        }

        let desc: string = basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar;
        if (basicBooking.name !== data.name) {
            desc += 'change_name' + NeutronUtil.specificChar + data.name + NeutronUtil.specificChar;
        }
        if (totalAllDeposits == 0 && totalAllDeposits < totalServiceChargeAndRoomCharge) {
            dataAdded['status_payment'] = PaymentStatus.unpaid
        }
        if (totalAllDeposits == totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
            dataAdded['status_payment'] = PaymentStatus.done;
        }
        if (0 < totalAllDeposits && totalAllDeposits < totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
            dataAdded['status_payment'] = PaymentStatus.partial;
        }
        if (totalServiceChargeAndRoomCharge < totalAllDeposits && priceRoomNew !== priceRoomOld) {
            dataAdded['status_payment'] = PaymentStatus.done;
        }
        switch (basicBooking.status) {
            case BookingStatus.unconfirmed:
                {
                    const alm: { [key: string]: any } = {};
                    let isUpdateHls: boolean = false;
                    // check room to update
                    if (foundDay.length === 0) {
                        const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    } else {
                        if (inDayBookingServer.getTime() > inDayNewServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewTimezone, inDayBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        } else {
                            checkOverdueBooking = true;
                        }
                        if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    if (roomNewBooking !== '') {
                        if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime() || roomOldBooking !== roomNewBooking) {
                            const availableRooms: string[] = [];
                            if (roomOldBooking === roomNewBooking) {
                                if (foundDay.length === 0) {
                                    const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                                    const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                    availableRooms.push(...availableFoundDayNew);
                                } else {
                                    desc += 'change_date';
                                    if (inDayBookingServer.getTime() <= inDayNewServer.getTime() && outDayNewServer.getTime() <= outDayBookingServer.getTime()) {
                                        availableRooms.push(booking.room);
                                    }

                                    if (inDayBookingServer.getTime() > inDayNewServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, inDayBookingTimezone);
                                        const availableRoomInDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomInDate);
                                    }

                                    if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                                        const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomOutDate);
                                    }
                                }
                            } else {
                                const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                                const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                availableRooms.push(...availableFoundDayNew);
                                desc += 'change_room' + NeutronUtil.specificChar + data.room_id + NeutronUtil.specificChar;
                            }

                            if (availableRooms.indexOf(roomNewBooking) === -1) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    // update daily allotment here
                    if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime() || roomTypeNewBooking !== roomTypeOldBooking) {
                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeOldBooking, roomOldBooking, false, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeOldBooking, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBookingNew, roomTypeNewBooking, roomNewBooking, true, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBookingNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        isUpdateHls = true;
                    } else {
                        // case update room in room type
                        if (roomNewBooking !== roomOldBooking) {
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeOldBooking, roomOldBooking, false, true);
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBookingNew, roomTypeNewBooking, roomNewBooking, true, true);
                        }
                    }

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'booking_id': data.booking_id,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
                        const idDocument = activityIdMap['idDocument'];
                        const isNewDocument = activityIdMap['isNewDocument'];
                        if (isNewDocument) {
                            t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            })
                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                            }
                        } else {
                            t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': FieldValue.arrayUnion(activityData)
                            })
                        }
                    }

                    // update extra hour
                    if (isHaveExtraHour && outDayBookingTimezone.getTime() !== outDayNewTimezone.getTime()) {
                        const outMonthIDOld = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                        const outMonthIDNew = DateUtil.dateToShortStringYearMonth(outDayNewTimezone);

                        if (outMonthIDOld !== outMonthIDNew) {
                            const dataUpdateOldMonth: { [key: string]: any } = {};
                            const dataUpdateNewMonth: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                            dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                            dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdateOldMonth);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDNew), dataUpdateNewMonth);
                        } else {
                            const dataUpdate: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                            dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                            dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdate);
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['rate_plan'] = data.rate_plan_id;
                    dataAdded['stay_days'] = stayDaysBookingNew;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['in_date'] = inDayNewServer;
                    dataAdded['in_time'] = inDayNewServer;
                    dataAdded['out_date'] = outDayNewServer;
                    dataAdded['out_time'] = outDayNewServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    dataAdded['sid'] = data.sid;
                    dataAdded['phone'] = phoneNew;
                    dataAdded['email'] = data.email;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    dataAdded['modified'] = nowServer;
                    dataAdded['tax_declare'] = isTaxDeclare ?? false;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;

                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewServer, booking.extra_hours.late_hours);
                        dataAdded['in_time'] = DateUtil.addHours(inDayNewServer, - booking.extra_hours.early_hours);
                    }
                    t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), dataAdded);
                    delete dataAdded['stay_days'];
                    delete dataAdded['notes'];
                    delete dataAdded['status_payment'];

                    if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataAdded['guest'] = listGuestDeclaration;
                        dataAdded['has_declaration'] = true;
                    } else {
                        dataAdded['guest'] = [];
                        dataAdded['has_declaration'] = false;
                    }

                    if (declarationInvoiceDetail !== undefined && !isDeclareInfoEmpty) {
                        dataAdded['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataAdded['declare_info'][k] = v;
                        });
                    }

                    if (checkOverdueBooking) {
                        t.update(hotelRef.collection('management').doc('overdue_bookings'), {
                            ['overdue_bookings.checkin.' + data.booking_id]: FieldValue.delete()
                        });
                    }

                    t.update(hotelRef.collection('bookings').doc(data.booking_id), dataAdded);

                    if (mappingHotelID !== undefined && mappingHotelKey !== undefined && isUpdateHls) {
                        if (stayDaysBooking.length > 90 || stayDaysBookingNew.length > 90) {
                            // eslint-disable-next-line @typescript-eslint/no-floating-promises
                            NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        } else {
                            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        }
                    }

                    return MessageUtil.SUCCESS;
                }
            case BookingStatus.booked:
                {
                    const alm: { [key: string]: any } = {};
                    let isUpdateHls: boolean = false;
                    // check room to update
                    if (foundDay.length === 0) {
                        const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    } else {
                        if (inDayBookingServer.getTime() > inDayNewServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewTimezone, inDayBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        } else {
                            checkOverdueBooking = true;
                        }
                        if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    if (roomNewBooking !== '') {
                        if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime() || roomOldBooking !== roomNewBooking) {
                            const availableRooms: string[] = [];
                            if (roomOldBooking === roomNewBooking) {
                                if (foundDay.length === 0) {
                                    const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                                    const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                    availableRooms.push(...availableFoundDayNew);
                                } else {
                                    desc += 'change_date';
                                    if (inDayBookingServer.getTime() <= inDayNewServer.getTime() && outDayNewServer.getTime() <= outDayBookingServer.getTime()) {
                                        availableRooms.push(booking.room);
                                    }

                                    if (inDayBookingServer.getTime() > inDayNewServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, inDayBookingTimezone);
                                        const availableRoomInDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomInDate);
                                    }

                                    if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                                        const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomOutDate);
                                    }
                                }
                            } else {
                                const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewTimezone, outDayNewTimezone);
                                const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                availableRooms.push(...availableFoundDayNew);
                                desc += 'change_room' + NeutronUtil.specificChar + data.room_id + NeutronUtil.specificChar;
                            }

                            if (availableRooms.indexOf(roomNewBooking) === -1) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    // update daily allotment here
                    if (inDayBookingServer.getTime() !== inDayNewServer.getTime() || outDayBookingServer.getTime() !== outDayNewServer.getTime() || roomTypeNewBooking !== roomTypeOldBooking) {
                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeOldBooking, roomOldBooking, false, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeOldBooking, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBookingNew, roomTypeNewBooking, roomNewBooking, true, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBookingNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        isUpdateHls = true;
                    } else {
                        // case update room in room type
                        if (roomNewBooking !== roomOldBooking) {
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeOldBooking, roomOldBooking, false, true);
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBookingNew, roomTypeNewBooking, roomNewBooking, true, true);
                        }
                    }

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'booking_id': data.booking_id,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
                        const idDocument = activityIdMap['idDocument'];
                        const isNewDocument = activityIdMap['isNewDocument'];
                        if (isNewDocument) {
                            t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            })
                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                            }
                        } else {
                            t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': FieldValue.arrayUnion(activityData)
                            })
                        }
                    }

                    // update extra hour
                    if (isHaveExtraHour && outDayBookingTimezone.getTime() !== outDayNewTimezone.getTime()) {
                        const outMonthIDOld = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                        const outMonthIDNew = DateUtil.dateToShortStringYearMonth(outDayNewTimezone);

                        if (outMonthIDOld !== outMonthIDNew) {
                            const dataUpdateOldMonth: { [key: string]: any } = {};
                            const dataUpdateNewMonth: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                            dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                            dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdateOldMonth);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDNew), dataUpdateNewMonth);
                        } else {
                            const dataUpdate: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                            dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                            dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdate);
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['rate_plan'] = data.rate_plan_id;
                    dataAdded['stay_days'] = stayDaysBookingNew;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['in_date'] = inDayNewServer;
                    dataAdded['in_time'] = inDayNewServer;
                    dataAdded['out_date'] = outDayNewServer;
                    dataAdded['out_time'] = outDayNewServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    dataAdded['sid'] = data.sid;
                    dataAdded['phone'] = phoneNew;
                    dataAdded['email'] = data.email;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    dataAdded['modified'] = nowServer;
                    dataAdded['tax_declare'] = isTaxDeclare ?? false;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;

                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewServer, booking.extra_hours.late_hours);
                        dataAdded['in_time'] = DateUtil.addHours(inDayNewServer, - booking.extra_hours.early_hours);
                    }
                    t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), dataAdded);
                    delete dataAdded['stay_days'];
                    delete dataAdded['notes'];
                    delete dataAdded['status_payment'];

                    if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataAdded['guest'] = listGuestDeclaration;
                        dataAdded['has_declaration'] = true;
                    } else {
                        dataAdded['guest'] = [];
                        dataAdded['has_declaration'] = false;
                    }

                    if (declarationInvoiceDetail !== undefined && !isDeclareInfoEmpty) {
                        dataAdded['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataAdded['declare_info'][k] = v;
                        });
                    }

                    if (checkOverdueBooking) {
                        t.update(hotelRef.collection('management').doc('overdue_bookings'), {
                            ['overdue_bookings.checkin.' + data.booking_id]: FieldValue.delete()
                        });
                    }

                    t.update(hotelRef.collection('bookings').doc(data.booking_id), dataAdded);

                    if (mappingHotelID !== undefined && mappingHotelKey !== undefined && isUpdateHls) {
                        if (stayDaysBooking.length > 90 || stayDaysBookingNew.length > 90) {
                            // eslint-disable-next-line @typescript-eslint/no-floating-promises
                            NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        } else {
                            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        }
                    }

                    return MessageUtil.SUCCESS;
                }
            case BookingStatus.checkin:
                {
                    if (inDayNewServer.getTime() !== inDayBookingServer.getTime()) {
                        throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_CHECKIN_CAN_NOT_MODIFY_INDAY);
                    }
                    if (data.rate_plan_id !== basicBooking.rate_plan) {
                        throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_CAN_NOT_EDIT_RATE_PLAN);
                    }
                    if (roomNewBooking === '') {
                        throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CHECKIN_CANNOT_SET_NONE_ROOM);
                    }

                    // just check for new out day have available quantity room
                    if (outDayNewTimezone.getTime() > outDayBookingTimezone.getTime()) {
                        const stayOutDates: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayOutDates, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    }

                    // case just change room
                    if (roomOldBooking !== roomNewBooking) {
                        desc += 'change_room' + NeutronUtil.specificChar + roomNewBooking + NeutronUtil.specificChar;

                        const availableRooms: string[] = [];
                        let breakDate: Date;
                        if (nowTimezone.getTime() > now12hTimezone.getTime()) {
                            breakDate = now12hTimezone;
                        } else {
                            breakDate = DateUtil.addDate(now12hTimezone, -1);
                        }

                        // if change room and have different out date, need to check. 
                        if (breakDate.getTime() === outDayNewTimezone.getTime()) {
                            const availableRoomBreakDate = NeutronUtil.getAvailableRoomsWithDailyAllotments([breakDate], dailyAllotments, roomsOfRoomType);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments([breakDate], dailyAllotments, roomTypeNewBooking);

                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }

                            availableRooms.push(...availableRoomBreakDate);
                        } else {
                            const stayDateTepm: Date[] = DateUtil.getStayDates(breakDate, outDayNewTimezone);
                            const availableRoomBreakDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                            availableRooms.push(...availableRoomBreakDate);
                        }
                        if (outDayNewServer.getTime() !== outDayBookingServer.getTime()) {
                            desc += 'change_date';
                        }

                        if (availableRooms.indexOf(roomNewBooking) === -1) {
                            throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }

                        if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                            const activityData: { [key: string]: any } = {
                                'email': context.auth?.token.email,
                                'id': data.booking_id,
                                'booking_id': data.booking_id,
                                'type': 'booking',
                                'desc': desc,
                                'created_time': nowServer
                            };
                            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
                            const idDocument = activityIdMap['idDocument'];
                            const isNewDocument = activityIdMap['isNewDocument'];
                            if (isNewDocument) {
                                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                })
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                    'activities': FieldValue.arrayUnion(activityData)
                                })
                            }
                        }

                        const inTimeBookingTimezone: Date = DateUtil.convertOffSetTimezone(inTimeBookingServer, timezone);
                        const inTimeBookingTimezone12h: Date = new Date(inTimeBookingTimezone.getFullYear(), inTimeBookingTimezone.getMonth(), inTimeBookingServer.getDate(), 12, 0, 0);
                        const inDateOfMoveBooking: Date = DateUtil.convertOffSetTimezone(inTimeBookingTimezone12h, timezone);
                        const outDateOfMoveBooking: Date = DateUtil.convertOffSetTimezone(DateUtil.addDate(now12hTimezone, 1), timezone);
                        const lengthStayOfMoveBooking = DateUtil.getStayDates(inDateOfMoveBooking, outDateOfMoveBooking);
                        const nameRoom: string = rooms[data.room_id]['name'];
                        t.set(hotelRef.collection('basic_bookings').doc(), {
                            'name': '( moved_to ' + nameRoom + ' ) ' + basicBooking.name,
                            'in_date': inDateOfMoveBooking,
                            'in_time': inTimeBookingServer,
                            'out_time': nowServer,
                            'bed': basicBooking.bed,
                            'out_date': outDateOfMoveBooking,
                            'room': basicBooking.room,
                            'room_type': basicBooking.room_type,
                            'status': BookingStatus.moved,
                            'sid': basicBooking.sid,
                            'source': basicBooking.source,
                            'stay_days': lengthStayOfMoveBooking,
                            'type_tourists': typeTourists,
                            'country': country
                        });

                        const dataUpdateBasicBooking: { [key: string]: any } = {
                            'in_time': nowServer,
                            'room': roomNewBooking,
                            'room_type': roomTypeNewBooking,
                            'modified': nowServer,
                            'price': priceNewBooking,
                            'out_time': outDayNewServer,
                            'out_date': outDayNewServer,
                            'type_tourists': typeTourists,
                            'country': country
                        };

                        if (breakDate.getTime() === outDayNewTimezone.getTime()) {
                            dataUpdateBasicBooking['out_time'] = DateUtil.addDate(nowServer, 1 / (24 * 60));
                        }

                        t.update(hotelRef.collection('basic_bookings').doc(data.booking_id), dataUpdateBasicBooking);

                        const updateBookingCollection: { [key: string]: any } = {
                            'room': roomNewBooking,
                            'room_type': roomTypeNewBooking,
                            'modified': nowServer,
                            'price': priceNewBooking,
                            'type_tourists': typeTourists,
                            'country': country
                        };

                        if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                            listGuestDeclaration.forEach((e) => {
                                e['date_of_birth'] = new Date(e['date_of_birth']);
                            });
                            updateBookingCollection['guest'] = listGuestDeclaration;
                            updateBookingCollection['has_declaration'] = true;
                        } else {
                            updateBookingCollection['guest'] = [];
                            updateBookingCollection['has_declaration'] = false;
                        }

                        if (declarationInvoiceDetail !== undefined) {
                            updateBookingCollection['declare_info'] = {};
                            (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                                updateBookingCollection['declare_info'][k] = v;
                            });
                        }

                        t.update(hotelRef.collection('bookings').doc(data.booking_id), updateBookingCollection);

                        if (roomTypeNewBooking !== roomTypeOldBooking || outDayBookingTimezone.getTime() !== outDayNewTimezone.getTime()) {
                            // update hls here
                            const alm: { [key: string]: any } = {};
                            const stayDatesOld: Date[] = [];
                            if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                                stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, false);
                                NeutronUtil.updateHlsToAlm(stayDatesOld, roomTypeOldBooking, false, dailyAllotments, alm);
                            }

                            const stayDatesNew: Date[] = [];
                            if (breakDate.getTime() !== outDayNewTimezone.getTime()) {
                                stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, false);
                                NeutronUtil.updateHlsToAlm(stayDatesNew, roomTypeNewBooking, true, dailyAllotments, alm);
                            }

                            if (mappingHotelID !== undefined && mappingHotelKey !== undefined && Object.keys(alm).length !== 0) {
                                if (stayDatesOld.length > 90 || stayDatesNew.length > 90) {
                                    // eslint-disable-next-line @typescript-eslint/no-floating-promises
                                    NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                                } else {
                                    await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                                }
                            }
                        } else {
                            const stayDatesOld: Date[] = [];
                            if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                                stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, true);
                            }

                            const stayDatesNew: Date[] = [];
                            if (breakDate.getTime() !== outDayNewTimezone.getTime()) {
                                stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, true);
                            }
                        }
                        return MessageUtil.SUCCESS;
                    }

                    // case change out date
                    if (outDayBookingServer.getTime() !== outDayNewServer.getTime()) {
                        desc += 'change_date';

                        const availableRooms: string[] = [];
                        if (outDayNewServer.getTime() > outDayBookingServer.getTime()) {
                            const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewTimezone);
                            const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                            availableRooms.push(...availableRoomOutDate);
                        } else {
                            availableRooms.push(basicBooking.room);
                        }

                        if (availableRooms.indexOf(roomNewBooking) === -1) {
                            throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }

                        let breakDate: Date;

                        if (nowTimezone.getTime() > now12hTimezone.getTime()) {
                            breakDate = now12hTimezone;
                        } else {
                            breakDate = DateUtil.addDate(now12hTimezone, -1);
                        }

                        if (isHaveExtraHour) {
                            const outMonthIDBookingOld: string = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                            const outMonthIDBookingNew: string = DateUtil.dateToShortStringYearMonth(outDayNewTimezone);

                            if (outMonthIDBookingOld !== outMonthIDBookingNew) {
                                const dataUpdateOldMonth: { [key: string]: any } = {};
                                const dataUpdateNewMonth: { [key: string]: any } = {};
                                const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                                const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                                dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                                dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingOld), dataUpdateOldMonth);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingNew), dataUpdateNewMonth);
                            } else {
                                const dataUpdate: { [key: string]: any } = {};
                                const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                                const dayNewId = DateUtil.dateToShortStringDay(outDayNewTimezone);
                                dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- booking.extra_hours.total);
                                dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(booking.extra_hours.total);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingOld), dataUpdate);
                            }
                        }

                        // update hls here
                        const alm: { [key: string]: any } = {};
                        const stayDatesOld: Date[] = [];
                        if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                            stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, false);
                            NeutronUtil.updateHlsToAlm(stayDatesOld, roomTypeOldBooking, false, dailyAllotments, alm);
                        }

                        const stayDatesNew: Date[] = [];
                        if (breakDate.getTime() !== outDayNewTimezone.getTime()) {
                            stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewTimezone));
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, false);
                            NeutronUtil.updateHlsToAlm(stayDatesNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        }

                        if (mappingHotelID !== undefined && mappingHotelKey !== undefined && Object.keys(alm).length !== 0) {
                            if (stayDatesNew.length > 90 || stayDatesOld.length > 90) {
                                // eslint-disable-next-line @typescript-eslint/no-floating-promises
                                NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                            } else {
                                await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                            }
                        }
                    }

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'booking_id': data.booking_id,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
                        const idDocument = activityIdMap['idDocument'];
                        const isNewDocument = activityIdMap['isNewDocument'];
                        if (isNewDocument) {
                            t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            })
                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                            }
                        } else {
                            t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': FieldValue.arrayUnion(activityData)
                            })
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['out_date'] = outDayNewServer;
                    dataAdded['out_time'] = outDayNewServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    // dataAdded['sid'] = data.sid;
                    dataAdded['email'] = data.email;
                    dataAdded['phone'] = phoneNew;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    // dataAdded['group'] = data.group
                    dataAdded['stay_days'] = stayDaysBookingNew;
                    dataAdded['modified'] = nowServer;
                    dataAdded['tax_declare'] = isTaxDeclare ?? false;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;

                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewServer, booking.extra_hours.late_hours);
                    }

                    t.update(hotelRef.collection('basic_bookings').doc(basicBookingDoc.id), dataAdded);
                    delete dataAdded['stay_days'];
                    delete dataAdded['notes'];
                    delete dataAdded['status_payment'];

                    if (listGuestDeclaration !== null && !isDeclareGuestEmpty) {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataAdded['guest'] = listGuestDeclaration;
                        dataAdded['has_declaration'] = true;
                    } else {
                        dataAdded['guest'] = [];
                        dataAdded['has_declaration'] = false;
                    }

                    if (declarationInvoiceDetail !== undefined) {
                        dataAdded['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataAdded['declare_info'][k] = v;
                        });
                    }
                    t.update(hotelRef.collection('bookings').doc(basicBookingDoc.id), dataAdded);

                    return MessageUtil.SUCCESS;
                }
            default:
                throw new functions.https.HttpsError('permission-denied', MessageUtil.JUST_FOR_CHECKIN_OR_REPAIR_BOOKING);
        }
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError('permission-denied', error.message);
    });

    if (phoneNew !== '' && phoneOld !== phoneNew) {
        const token = context.rawRequest.headers.authorization;
        const options = {
            hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
            path: '/addBooking',
            method: 'POST',
            headers: {
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        };
        const postData = JSON.stringify({
            'name': data.name,
            'phone': data.phone,
            'inDate': data.in_date,
            'outDate': data.out_date,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        });
        RestUtil.postRequest(options, postData).catch(console.error);

    }
    return res;
});
// deploy here - ok - was deploy
exports.noShow = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timeZone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesCancelBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId: string = data.booking_id;
    const isGroup: boolean = data.group;
    const bookingSID: string = data.sid;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSID : bookingId));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingDocData = bookingDoc.data();
        if (bookingDocData === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['status'] : bookingDocData.status;
        const bookingDeposit = bookingDocData.deposit ?? 0;
        // const bookingOtaDeposit = bookingDocData.ota_deposit ?? 0;
        const bookingRentingBike = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['renting_bike_num'] : bookingDocData.renting_bike_num ?? 0;
        const bookingServiceCharge: number = isGroup ? NeutronUtil.getServiceCharge(bookingDoc.get('sub_bookings')[bookingId]) : NeutronUtil.getServiceCharge(bookingDocData);
        // const bookingServiceOtaCharge: number = bookingDocData.ota_service ?? 0;

        // if (bookingStatus < BookingStatus.booked) {
        //     throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
        // }

        if (bookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }

        if (bookingRentingBike > 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_RENTING_BIKES);
        }

        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const inDayServer: Date = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['in_date'].toDate() : bookingDocData.in_date.toDate();
        const outDayServer: Date = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['out_date'].toDate() : bookingDocData.out_date.toDate();
        const inDayTimezone: Date = DateUtil.convertUpSetTimezone(inDayServer, timeZone);
        const outDayTimezone: Date = DateUtil.convertUpSetTimezone(outDayServer, timeZone);
        const stayDaysTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
        const roomBooking: string = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['room'] : bookingDocData.room;
        const roomTypeBooking: string = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['room_type'] : bookingDocData.room_type;

        // get daily allotment here
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezone, t);
        const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
        const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappedRoomType['id'] };

        if (isGroup) {
            if ((bookingServiceCharge > 0)) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
            }
            const priceGroupBooking: number[] = bookingDoc.get('price');
            const subBookings = bookingDoc.get('sub_bookings');
            let isHaveBookingOut: boolean = false;
            let countBookingBooked: number = 0;
            let countBookingNoShow: number = 0;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.booked) {
                    countBookingBooked++;
                    continue;
                }
                if (subBookings[idBooking]['status'] === BookingStatus.checkout) {
                    isHaveBookingOut = true;
                    continue;
                }
                if (subBookings[idBooking]['status'] === BookingStatus.noshow) {
                    countBookingNoShow++;
                }
            }

            if (countBookingBooked === 1 && isHaveBookingOut) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.CAN_NOT_NO_SHOW_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT);
            }
            const priceBooking: number[] = bookingDoc.get('sub_bookings')[bookingId]['price'];
            const dataUpdate: { [key: string]: any } = {};
            for (let index = 0; index < priceBooking.length; index++) {
                priceGroupBooking[index] = priceGroupBooking[index] - priceBooking[index];
            }
            dataUpdate['price'] = priceGroupBooking;
            dataUpdate['sub_bookings.' + bookingId + '.status'] = BookingStatus.noshow;
            dataUpdate['sub_bookings.' + bookingId + '.cancelled'] = nowServer;

            if (countBookingNoShow === (Object.keys(subBookings).length - 1)) {
                dataUpdate['status'] = BookingStatus.noshow;
                if (bookingDeposit !== 0) {
                    throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
                }
            }
            t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);
        } else {

            if ((bookingDeposit !== 0) || (bookingServiceCharge > 0)) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
            }

            t.update(hotelRef.collection('bookings').doc(bookingId), {
                'status': BookingStatus.noshow, 'cancelled': nowServer
            });
        }

        // change update hls of hotel link here
        NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDaysTimezone, false, almRoomBooked, roomBooking, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hTimezone);

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
            'status': BookingStatus.noshow, 'cancelled': nowServer
        });

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData: { [key: string]: any } = {
                'email': context.auth?.token.email,
                'id': bookingId,
                'booking_id': bookingId,
                'type': 'booking',
                'desc': bookingDocData.name + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'noshow',
                'created_time': nowServer
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy - waiting
exports.noShowBookingGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timeZone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesCancelBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingSID: string = data.booking_id;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingDocData = bookingDoc.data();
        if (bookingDocData === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = bookingDocData.status;
        const bookingDeposit = bookingDocData.deposit ?? 0;
        const bookingRentingBike = bookingDocData.renting_bike_num ?? 0;
        const bookingServiceCharge: number = NeutronUtil.getServiceCharge(bookingDocData);

        // if (bookingStatus < BookingStatus.booked) {
        //     throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
        // }

        if (bookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }
        if ((bookingDeposit !== 0) || (bookingServiceCharge > 0)) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
        }
        if (bookingRentingBike > 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_RENTING_BIKES);
        }

        const inDayGroupServer: Date = bookingDocData.in_date.toDate();
        const outDayGroupServer: Date = bookingDocData.out_date.toDate();
        const inDayGroupTimezone: Date = DateUtil.convertUpSetTimezone(inDayGroupServer, timeZone);
        const outDayGroupTimezone: Date = DateUtil.convertUpSetTimezone(outDayGroupServer, timeZone);
        const stayDateGroupTimezone: Date[] = DateUtil.getStayDates(inDayGroupTimezone, outDayGroupTimezone);

        // get daily allotment here
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateGroupTimezone, t);

        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const almMap: { [key: string]: { [key: string]: number } } = {};
        const subBookings = bookingDoc.get('sub_bookings');
        const dataUpdate: { [key: string]: any } = {};
        for (const idBooking in subBookings) {
            if (bookingDoc.get('sub_bookings')[idBooking]['status'] === BookingStatus.noshow || bookingDoc.get('sub_bookings')[idBooking]['status'] === BookingStatus.cancel) {
                continue;
            }
            dataUpdate['sub_bookings.' + idBooking + '.status'] = BookingStatus.noshow;
            dataUpdate['sub_bookings.' + idBooking + '.cancelled'] = nowServer;
            const roomType = bookingDocData.sub_bookings[idBooking]['room_type'];
            const room = bookingDocData.sub_bookings[idBooking]['room'];
            const inDayBookingServer: Date = bookingDocData.sub_bookings[idBooking]['in_date'].toDate();
            const outDayBookingServer: Date = bookingDocData.sub_bookings[idBooking]['out_date'].toDate();
            const inDayTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timeZone);
            const outDayTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timeZone);
            const stayDateTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDateTimezone, roomType, room, false, false);
            t.update(hotelRef.collection('basic_bookings').doc(idBooking), { 'status': BookingStatus.noshow, 'cancelled': nowServer });

            if (hotelMappingId !== undefined) {
                NeutronUtil.updateHlsToAlm(stayDateTimezone, roomType, false, dailyAllotments, almMap);
            }
        }

        dataUpdate['status'] = BookingStatus.noshow;
        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);

        if (hotelMappingId !== undefined && hotelMappingKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, almMap, hotelMappingId, hotelMappingKey, now12hTimezone);
        }

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData: { [key: string]: any } = {
                'email': context.auth?.token.email,
                'id': bookingSID,
                'sid': bookingSID,
                'booking_id': bookingSID,
                'type': 'booking',
                'desc': bookingDocData.name + NeutronUtil.specificChar + 'group' + NeutronUtil.specificChar + 'noshow',
                'created_time': nowServer
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        return MessageUtil.SUCCESS;
    });
    return res;
});

// deploy here - ok - was deploy
exports.cancel = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timeZone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesCancelBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId: string = data.booking_id;
    const isGroup: boolean = data.group;
    const bookingSID: string = data.sid;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSID : bookingId));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingDocData = bookingDoc.data();
        if (bookingDocData === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['status'] : bookingDocData.status;
        const bookingDeposit = bookingDocData.deposit ?? 0;
        // const bookingOtaDeposit = bookingDocData.ota_deposit ?? 0;
        const bookingRentingBike = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['renting_bike_num'] : bookingDocData.renting_bike_num ?? 0;
        const bookingServiceCharge: number = isGroup ? NeutronUtil.getServiceCharge(bookingDoc.get('sub_bookings')[bookingId]) : NeutronUtil.getServiceCharge(bookingDocData);
        // const bookingServiceOtaCharge: number = bookingDocData.ota_service ?? 0;

        if (bookingStatus < BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
        }
        if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.unconfirmed) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }

        if (bookingRentingBike > 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_RENTING_BIKES);
        }

        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const inDayServer: Date = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['in_date'].toDate() : bookingDocData.in_date.toDate();
        const outDayServer: Date = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['out_date'].toDate() : bookingDocData.out_date.toDate();
        const inDayTimezone: Date = DateUtil.convertUpSetTimezone(inDayServer, timeZone);
        const outDayTimezone: Date = DateUtil.convertUpSetTimezone(outDayServer, timeZone);
        const stayDaysTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
        const roomBooking: string = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['room'] : bookingDocData.room;
        const roomTypeBooking: string = isGroup ? bookingDoc.get('sub_bookings')[bookingId]['room_type'] : bookingDocData.room_type;

        // get daily allotment here
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezone, t);
        const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
        const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappedRoomType['id'] };

        if (isGroup) {
            if ((bookingServiceCharge > 0)) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
            }
            const priceGroupBooking: number[] = bookingDoc.get('price');
            const subBookings = bookingDoc.get('sub_bookings');
            let isHaveBookingOut: boolean = false;
            let countBookingBooked: number = 0;
            let countBookingCancel: number = 0;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.booked) {
                    countBookingBooked++;
                    continue;
                }
                if (subBookings[idBooking]['status'] === BookingStatus.checkout) {
                    isHaveBookingOut = true;
                    continue;
                }
                if (subBookings[idBooking]['status'] === BookingStatus.cancel) {
                    countBookingCancel++;
                }
            }

            if (countBookingBooked === 1 && isHaveBookingOut) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.CAN_NOT_CANCEL_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT);
            }
            const priceBooking: number[] = bookingDoc.get('sub_bookings')[bookingId]['price'];
            const dataUpdate: { [key: string]: any } = {};
            for (let index = 0; index < priceBooking.length; index++) {
                priceGroupBooking[index] = priceGroupBooking[index] - priceBooking[index];
            }
            dataUpdate['price'] = priceGroupBooking;
            dataUpdate['sub_bookings.' + bookingId + '.status'] = BookingStatus.cancel;
            dataUpdate['sub_bookings.' + bookingId + '.cancelled'] = nowServer;

            if (countBookingCancel === (Object.keys(subBookings).length - 1)) {
                dataUpdate['status'] = BookingStatus.cancel;
                if (bookingDeposit !== 0) {
                    throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
                }
            }
            t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);
        } else {

            if ((bookingDeposit !== 0) || (bookingServiceCharge > 0)) {
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
            }

            t.update(hotelRef.collection('bookings').doc(bookingId), {
                'status': BookingStatus.cancel, 'cancelled': nowServer
            });
        }

        // change update hls of hotel link here
        NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDaysTimezone, false, almRoomBooked, roomBooking, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hTimezone);

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
            'status': BookingStatus.cancel, 'cancelled': nowServer
        });

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData: { [key: string]: any } = {
                'email': context.auth?.token.email,
                'id': bookingId,
                'booking_id': bookingId,
                'type': 'booking',
                'desc': bookingDocData.name + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'cancel',
                'created_time': nowServer
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy - waiting
exports.cancelBookingGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timeZone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesCancelBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingSID: string = data.booking_id;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingDocData = bookingDoc.data();
        if (bookingDocData === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = bookingDocData.status;
        const bookingDeposit = bookingDocData.deposit ?? 0;
        const bookingRentingBike = bookingDocData.renting_bike_num ?? 0;
        const bookingServiceCharge: number = NeutronUtil.getServiceCharge(bookingDocData);

        if (bookingStatus < BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
        }
        if (bookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }
        if ((bookingDeposit !== 0) || (bookingServiceCharge > 0)) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
        }
        if (bookingRentingBike > 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_RENTING_BIKES);
        }

        const inDayGroupServer: Date = bookingDocData.in_date.toDate();
        const outDayGroupServer: Date = bookingDocData.out_date.toDate();
        const inDayGroupTimezone: Date = DateUtil.convertUpSetTimezone(inDayGroupServer, timeZone);
        const outDayGroupTimezone: Date = DateUtil.convertUpSetTimezone(outDayGroupServer, timeZone);
        const stayDateGroupTimezone: Date[] = DateUtil.getStayDates(inDayGroupTimezone, outDayGroupTimezone);

        // get daily allotment here
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateGroupTimezone, t);

        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const almMap: { [key: string]: { [key: string]: number } } = {};
        const subBookings = bookingDoc.get('sub_bookings');
        const dataUpdate: { [key: string]: any } = {};
        for (const idBooking in subBookings) {
            if (bookingDoc.get('sub_bookings')[idBooking]['status'] === BookingStatus.cancel || bookingDoc.get('sub_bookings')[idBooking]['status'] === BookingStatus.noshow) {
                continue;
            }
            dataUpdate['sub_bookings.' + idBooking + '.status'] = BookingStatus.cancel;
            dataUpdate['sub_bookings.' + idBooking + '.cancelled'] = nowServer;
            const roomType = bookingDocData.sub_bookings[idBooking]['room_type'];
            const room = bookingDocData.sub_bookings[idBooking]['room'];
            const inDayBookingServer: Date = bookingDocData.sub_bookings[idBooking]['in_date'].toDate();
            const outDayBookingServer: Date = bookingDocData.sub_bookings[idBooking]['out_date'].toDate();
            const inDayTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timeZone);
            const outDayTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timeZone);
            const stayDateTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDateTimezone, roomType, room, false, false);
            t.update(hotelRef.collection('basic_bookings').doc(idBooking), { 'status': BookingStatus.cancel, 'cancelled': nowServer });

            if (hotelMappingId !== undefined) {
                NeutronUtil.updateHlsToAlm(stayDateTimezone, roomType, false, dailyAllotments, almMap);
            }
        }

        dataUpdate['status'] = BookingStatus.cancel;
        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);

        if (hotelMappingId !== undefined && hotelMappingKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, almMap, hotelMappingId, hotelMappingKey, now12hTimezone);
        }

        //activity
        if (hotelPackage !== HotelPackage.basic) {
            const activityData: { [key: string]: any } = {
                'email': context.auth?.token.email,
                'id': bookingSID,
                'sid': bookingSID,
                'booking_id': bookingSID,
                'type': 'booking',
                'desc': bookingDocData.name + NeutronUtil.specificChar + 'group' + NeutronUtil.specificChar + 'cancel',
                'created_time': nowServer
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        return MessageUtil.SUCCESS;
    });
    return res;
});
// deloy here - ok - was deploy
exports.setNonRoom = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const timezone = hotelDoc.get('timezone');

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesSetNoneRoom;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId = data.booking_id;
    const isGroup = data.group;
    const bookingSID = data.sid;

    const res = await fireStore.runTransaction(async (t) => {
        let bookingDoc;
        if (isGroup) {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        } else {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingId));
        }
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = isGroup ? bookingDoc.get('sub_bookings.' + bookingId + '.status') : bookingDoc.get('status');

        if (bookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }
        const bookingRoom = isGroup ? bookingDoc.get('sub_bookings.' + bookingId + '.room') : bookingDoc.get('room');
        const bookingRoomType = isGroup ? bookingDoc.get('sub_bookings.' + bookingId + '.room_type') : bookingDoc.get('room_type');

        if (bookingRoom === '') {
            throw new functions.https.HttpsError("cancelled", MessageUtil.BOOKING_ALREADY_SET_NONE_ROOM);
        }
        const inDateServer: Date = isGroup ? bookingDoc.get('sub_bookings.' + bookingId + '.in_date').toDate() : bookingDoc.get('in_date').toDate();
        const inDateTimezone: Date = DateUtil.convertUpSetTimezone(inDateServer, timezone);
        const outDateServer: Date = isGroup ? bookingDoc.get('sub_bookings.' + bookingId + '.out_date').toDate() : bookingDoc.get('out_date').toDate();
        const outDateTimezone: Date = DateUtil.convertUpSetTimezone(outDateServer, timezone);
        const staysDayTimezone: Date[] = DateUtil.getStayDates(inDateTimezone, outDateTimezone);

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), { 'room': '' });
        if (isGroup) {
            const dataUpdate: { [key: string]: any } = {};
            dataUpdate['sub_bookings.' + bookingId + '.room'] = '';
            t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);
        } else {
            t.update(hotelRef.collection('bookings').doc(bookingId), { 'room': '' });
        }
        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, staysDayTimezone, bookingRoomType, bookingRoom, false, true);
        // await NeutronUtil.updateDailyAllotmentSetNoneRoom(hotelRef, t, staysDayTimezone, bookingRoom);
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.deleteRepair = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();
    const timezone: string = hotelDoc.get('timezone');
    const mapping_hotel_id: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mapping_hotel_key: string | undefined = hotelDoc.get('mapping_hotel_key');

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesDeleteRepair;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId = data.booking_id;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('basic_bookings').doc(bookingId)));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        const bookingStatus = bookingDoc.get('status');
        if (bookingStatus === undefined || bookingStatus !== BookingStatus.repair) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_REPAIR);
        }

        const booking = bookingDoc.data();

        if (booking === undefined) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_REPAIR);
        }

        const inDate: Date = DateUtil.convertUpSetTimezone(booking.in_date.toDate(), timezone);
        const outDate: Date = DateUtil.convertUpSetTimezone(booking.out_date.toDate(), timezone);
        const nowServer: Date = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        const roomType: string = booking.room_type;
        const room: string = booking.room ?? '';
        const stayDays = DateUtil.getStayDates(inDate, outDate);

        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDays, t);
        const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);
        const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomType, cmId: mappedRoomType['id'] };

        NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDays, false, almRoomBooked, room, null, mapping_hotel_id, mapping_hotel_key, dailyAllotments, now12hTimezone);
        // await NeutronUtil.updateDailyAllotmentAndHls(t, hotelRef, stayDays, false, roomType, room, mapping_hotel_id, mapping_hotel_key, now12hTimezone);

        t.delete(hotelRef.collection('basic_bookings').doc(bookingId));
        return MessageUtil.SUCCESS;
    });
    return res;
});


///update
exports.saveNotes = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesSaveNotesBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const dataNotes = data.notes;
    const bookingId = data.booking_id;
    const sidBooking = data.sid;
    const group = data.group;

    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        };

        if (group) {
            const basicBookingsDoc = await t.get(hotelRef.collection("basic_bookings").where('sid', '==', sidBooking));

            if (basicBookingsDoc.empty) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.BOOKING_NOT_FOUND);
            }
            for (const key in basicBookingsDoc.docs) {
                t.update(hotelRef.collection('basic_bookings').doc(basicBookingsDoc.docs[key].id), {
                    'notes': dataNotes
                });
            }
            t.update(hotelRef.collection('bookings').doc(sidBooking), {
                'notes': dataNotes
            });
        } else {
            t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
                'notes': dataNotes
            });
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.addDiscount = functions.https.onCall(async (data, context) => {
    if (context.auth === undefined || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateOrDeleteDiscountBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const bookingId = data.booking_id;
    const discountAmount: number = data.discount_amount;
    const discountDesc: string = data.discount_desc;
    const isGroup: boolean = data.group;
    const bookingSID: string = data.sid;

    const res = await fireStore.runTransaction(async (t) => {
        if (isGroup) {
            const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const subBookings: { [key: string]: any } = bookingDoc.get('sub_bookings');
            let isAllBookingGroupStatusIsCheckOut: boolean = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.booked || subBookings[idBooking]['status'] === BookingStatus.checkin) {
                    isAllBookingGroupStatusIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingGroupStatusIsCheckOut) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }
        } else {
            const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingId));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const bookingStatus = bookingDoc.get('status');
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }
        }
        const now = new Date();
        const idDoc = NumberUtil.getRandomID();
        t.update(hotelRef.collection('bookings').doc(isGroup ? bookingSID : bookingId), {
            ['discount.details.' + idDoc]: {
                'desc': discountDesc,
                'amount': discountAmount,
                'modified_by': context.auth?.token.email,
                'modified_time': now
            },
            'discount.total': FieldValue.increment(discountAmount)
        });
        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.updateDiscount = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateOrDeleteDiscountBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const bookingId = data.booking_id;
    const discountId: number = data.discount_id;
    const discountAmount: number = data.discount_amount;
    const discountDesc: string = data.discount_desc;
    const isGroup: boolean = data.group;
    const bookingSID: string = data.sid;

    const res = await fireStore.runTransaction(async (t) => {
        let bookingDoc;
        if (isGroup) {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const subBookings: { [key: string]: any } = bookingDoc.get('sub_bookings');
            let isAllBookingGroupStatusIsCheckOut: boolean = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.booked || subBookings[idBooking]['status'] === BookingStatus.checkin) {
                    isAllBookingGroupStatusIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingGroupStatusIsCheckOut) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }

        } else {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingId));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const bookingStatus = bookingDoc.get('status');
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }
        }

        const discountFromCloudById = bookingDoc.get('discount.details.' + discountId);
        if (discountFromCloudById === undefined) {
            throw new functions.https.HttpsError("already-exists", MessageUtil.DISCOUNT_NOT_FOUND);
        }

        const oldAmount = discountFromCloudById['amount']
        if (oldAmount === discountAmount && discountFromCloudById['desc'] === discountDesc) {
            throw new functions.https.HttpsError("already-exists", MessageUtil.STILL_NOT_CHANGE_VALUE);
        }

        const now = new Date();
        t.update(hotelRef.collection('bookings').doc(isGroup ? bookingSID : bookingId), {
            ['discount.details.' + discountId]: {
                'desc': discountDesc,
                'amount': discountAmount,
                'modified_by': context.auth?.token.email,
                'modified_time': now
            },
            'discount.total': FieldValue.increment(discountAmount - oldAmount)
        });

        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.deleteDiscount = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateOrDeleteDiscountBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId = data.booking_id;
    const discountId = data.discount_id;
    const isGroup: boolean = data.group;
    const bookingSID: string = data.sid;
    const res = await fireStore.runTransaction(async (t) => {
        let bookingDoc;
        if (isGroup) {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const subBookings: { [key: string]: any } = bookingDoc.get('sub_bookings');
            let isAllBookingGroupStatusIsCheckOut: boolean = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.booked || subBookings[idBooking]['status'] === BookingStatus.checkin) {
                    isAllBookingGroupStatusIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingGroupStatusIsCheckOut) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }

        } else {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingId));
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const bookingStatus = bookingDoc.get('status');
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin) {
                throw new functions.https.HttpsError("not-found", MessageUtil.FORBIDDEN);
            }
        }

        const bookingDiscountInCloud = bookingDoc.get('discount.details.' + discountId);
        if (bookingDiscountInCloud === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.DISCOUNT_NOT_FOUND);
        }

        t.update(hotelRef.collection('bookings').doc(bookingId), {
            ['discount.details.' + discountId]: FieldValue.delete(),
            'discount.total': FieldValue.increment(-bookingDiscountInCloud['amount'])
        });
        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.addVirtualBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const timezone = hotelDoc.get('timezone');
    const nowServer = new Date();
    const bookingId = data.booking_id;
    const virtualSid = data.virtual_sid;
    const virtualIndateTimezone = new Date(data.virtual_indate);
    const virtualOutdateTimezone = new Date(data.virtual_outdate);
    const inDateServer = DateUtil.convertOffSetTimezone(virtualIndateTimezone, timezone);
    const outDateServer = DateUtil.convertOffSetTimezone(virtualOutdateTimezone, timezone);

    const virtualName = data.virtual_name;
    const virtualPhone = data.virtual_phone;
    const virtualEmail = data.virtual_email;

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateVirtualBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = await fireStore.runTransaction(async (t) => {
        const hotelRefGet = await t.get(fireStore.collection('hotels').doc(data.hotel_id));
        const mapBooking: { [key: string]: any } = await NumberUtil.getSidBookingBySidHotel(hotelRefGet, hotelRef, t, virtualSid);

        t.create(hotelRef
            .collection('bookings')
            .doc(bookingId), {
            'sid': mapBooking["sid"],
            'created': nowServer,
            'in_date': inDateServer,
            'out_date': outDateServer,
            'name': virtualName,
            'source': 'virtual',
            'room': 'virtual',
            'phone': virtualPhone,
            'email': virtualEmail,
            'status': BookingStatus.booked,
            'virtual': true,
            'creator': context.auth?.token.email,
        });
        t.update(hotelRef, { "sid_booking": mapBooking["code"] });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.updateVirtualBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const timezone = hotelDoc.get('timezone');
    const bookingId = data.booking_id;
    const virtualOutDateTimezone = new Date(data.virtual_outdate);
    const virtualOutDateServer = DateUtil.convertOffSetTimezone(virtualOutDateTimezone, timezone)
    const virtualName = data.virtual_name;
    const virtualPhone = data.virtual_phone;
    const virtualEmail = data.virtual_email;

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateVirtualBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        t.update(hotelRef.collection('bookings').doc(bookingId), {
            'out_date': virtualOutDateServer,
            'name': virtualName,
            'phone': virtualPhone,
            'email': virtualEmail
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.checkoutVirtualBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const timezone = hotelDoc.get('timezone');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateVirtualBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const nowServer = new Date();
    const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

    const res = fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingDocData = bookingDoc.data();
        if (bookingDocData === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        if (bookingDocData.status === BookingStatus.checkout) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_CHECKOUT_BEFORE);
        }
        if (bookingDocData.status !== BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }
        const outDateServer: Date = bookingDocData.out_date.toDate();
        const outDateTimezone: Date = DateUtil.convertUpSetTimezone(outDateServer, timezone);
        const roomCharge = NeutronUtil.getRoomCharge(bookingDocData);
        const serviceCharge = NeutronUtil.getServiceCharge(bookingDocData);
        const discount = NeutronUtil.getDiscount(bookingDocData);
        const totalCharge = roomCharge + serviceCharge - discount;
        const transferred = bookingDocData.transferred ?? 0;
        const deposit = bookingDocData.deposit ?? 0;
        const transferring = bookingDocData.transferring ?? 0;
        const remaining = totalCharge + transferred - deposit - transferring;
        const rentingBikes = bookingDocData.renting_bike_num ?? 0;
        const revenue = NeutronUtil.getRevenue(bookingDocData);
        const extraHourTotal = bookingDocData.extraHour?.total ?? 0;

        if (remaining < -NeutronUtil.kZero || remaining > NeutronUtil.kZero) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT);
        }

        if (rentingBikes > 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_MUST_CHECKOUT_BIKES);
        }

        if (outDateTimezone.getTime() < now12hTimezone.getTime() || (outDateTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() > now12hTimezone.getTime())) {
            t.update(hotelRef.collection('management').doc('overdue_bookings'), {
                ['overdue_bookings.checkout.' + bookingId]: FieldValue.delete()
            });
        }

        //update status of virtual booking to Bookings collection
        t.update(
            hotelRef.collection('bookings').doc(bookingId),
            { 'status': BookingStatus.checkout, 'out_time': nowServer });

        //daily data
        const monthId = DateUtil.dateToShortStringYearMonth(nowTimezone);
        const dayId = DateUtil.dateToShortStringDay(nowTimezone);
        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['data.' + dayId + '.revenue.total'] = FieldValue.increment(revenue);
        dataUpdate['data.' + dayId + '.revenue.service_charge'] = FieldValue.increment(serviceCharge);
        dataUpdate['data.' + dayId + '.revenue.discount'] = FieldValue.increment(discount);
        dataUpdate['data.' + dayId + '.service.extra_hours.total'] = FieldValue.increment(extraHourTotal);
        t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);

        return MessageUtil.SUCCESS;
    });

    return res;
});

exports.cancelVirtualBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const bookingId = data.booking_id;

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesAddOrUpdateVirtualBooking;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const bookingStatus = bookingDoc.get('status');
        const bookingDeposit = bookingDoc.get('deposit') ?? 0;
        const bookingRentingBike = bookingDoc.get('renting_bike_num') ?? 0;

        if (bookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }
        if (bookingDeposit !== 0 || NeutronUtil.getServiceCharge(bookingDoc.data()!) > 0) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE);
        }
        if (bookingRentingBike > 0) throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_RENTING_BIKES);

        t.update(hotelRef.collection('bookings').doc(bookingId), { 'status': BookingStatus.cancel, 'cancelled': new Date() });
        return MessageUtil.SUCCESS;
    });
    return res;
});

///update
// deploy here - ok - was deploy
exports.addBookingGroup = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();

    const hotelPackage = hotelDoc.get('package');
    const timeZone = hotelDoc.get('timezone');
    const mappingHotelID: string = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string = hotelDoc.get('mapping_hotel_key');

    const rolesAllowed: string[] = NeutronUtil.rolesAddOrUpdateBooking;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const mapRoomTypes: { [key: string]: string[] } = data.map_room_types;
    const pricePerNight: { [key: string]: number[] } = data.price_per_night;
    const bookingType: number = data.booking_type;
    const inDayTimezone: Date = new Date(data.in_date);
    const outDayTimezone = new Date(data.out_date);
    const inDayServer = DateUtil.convertOffSetTimezone(inDayTimezone, timeZone);
    const outDayServer = DateUtil.convertOffSetTimezone(outDayTimezone, timeZone);
    const payAtHotel: boolean = data.pay_at_hotel;
    const breakfast: boolean = data.breakfast;
    const lunch: boolean = data.lunch ?? false;
    const dinner: boolean = data.dinner ?? false;
    const sourceID = data.source_id;
    const ratePlanID = data.rate_plan_id;
    const sID = data.sID;
    const name = data.name;
    const email = data.email;
    const phone = data.phone;
    const notes = data.notes;
    const emailSaler = data.saler;
    const isPartner: boolean = data.partner;
    const lengthStay: number = DateUtil.getDateRange(inDayTimezone, outDayTimezone);
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
    const now12hOfTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    const yesterday12h = DateUtil.addDate(now12hOfTimezone, -1);
    const stayDaysTimezone = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
    const stayDayServer = DateUtil.getStayDates(inDayServer, outDayServer);
    const typeTourists: string = data.type_tourists ?? '';
    const country: string = data.country ?? '';

    if (phone !== '') {
        const token = context.rawRequest.headers.authorization;
        const options = {
            hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
            path: '/addBooking',
            method: 'POST',
            headers: {
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        };
        const postData = JSON.stringify({
            'name': data.name,
            'phone': data.phone,
            'inDate': data.in_date,
            'outDate': data.out_date,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        });
        RestUtil.postRequest(options, postData).catch(console.error);
    }

    if (lengthStay > 31 && bookingType == BookingType.dayly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_31);
    }

    if (lengthStay > 365 && bookingType == BookingType.monthly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_365);
    }

    if (inDayTimezone.getTime() < yesterday12h.getTime() || (inDayTimezone.getTime() === yesterday12h.getTime() && nowTimezone.getTime() > now12hOfTimezone.getTime())) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INDATE_MUST_NOT_IN_PAST);
    }

    if (data.rate_plan_id === 'OTA') {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const hotelRefGet = await t.get(fireStore.collection('hotels').doc(data.hotel_id));
        const mapBooking: { [key: string]: any } = await NumberUtil.getSidBookingBySidHotel(hotelRefGet, hotelRef, t, sID);
        const configurationRef = await t.get(hotelRef.collection('management').doc('configurations'));
        const lastDocumentActivity = (await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];

        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezone, t);
        const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];
        const roomsBooked: string[] = NeutronUtil.getBookedRoomsWithDailyAllotments(stayDaysTimezone, dailyAllotments);

        const dataUpdateBooking: { [key: string]: any } = {};
        dataUpdateBooking['price'] = new Array(lengthStay).fill(0);
        dataUpdateBooking['dataBooking'] = {};
        let idDocument;
        let lengthOfActivity;

        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            idDocument = -1;
            lengthOfActivity = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            lengthOfActivity = lastDocumentActivity.data()['activities'].length;
        }

        const alm: { [key: string]: { [key: string]: number } } = {};

        for (const roomTypeID in mapRoomTypes) {
            if (mapRoomTypes[roomTypeID].length === 0) {
                continue;
            }
            if (mapRoomTypes[roomTypeID].length > roomTypes[roomTypeID]['num']) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_DONT_HAVE_ENOUGH_QUATITY);
            }

            if (roomsBooked.length !== 0 && mapRoomTypes[roomTypeID].some((room) => roomsBooked.indexOf(room) !== -1)) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.ROOM_ALREADY_HAVE_BOOKING_PLEASE_CHOOSE_ANOTHER_ROOM);
            }

            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayDaysTimezone, dailyAllotments, roomTypeID);

            if (quantityDailyAllotmentNew.some((e) => e < mapRoomTypes[roomTypeID].length)) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
            }

            const beds = (roomTypes[roomTypeID]['beds'] as string[]);
            const adult = roomTypes[roomTypeID]['guest'];
            for (const room of mapRoomTypes[roomTypeID]) {
                let index = 0;
                for (const price of pricePerNight[roomTypeID]) {
                    dataUpdateBooking['price'][index] += price;
                    index++;
                };

                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysTimezone, roomTypeID, room, true, false);
                NeutronUtil.updateHlsToAlm(stayDaysTimezone, roomTypeID, true, dailyAllotments, alm);

                const idDoc = NumberUtil.getRandomID();
                const bed = beds.filter(e => e !== '?')[0];
                dataUpdateBooking['dataBooking'][idDoc] = {};
                dataUpdateBooking['dataBooking'][idDoc]['status'] = isPartner ? BookingStatus.unconfirmed : BookingStatus.booked;
                dataUpdateBooking['dataBooking'][idDoc]['room'] = room;
                dataUpdateBooking['dataBooking'][idDoc]['room_type'] = roomTypeID;
                dataUpdateBooking['dataBooking'][idDoc]['in_date'] = inDayServer;
                dataUpdateBooking['dataBooking'][idDoc]['out_date'] = outDayServer;
                dataUpdateBooking['dataBooking'][idDoc]['price'] = pricePerNight[roomTypeID];
                dataUpdateBooking['dataBooking'][idDoc]['adult'] = adult;
                dataUpdateBooking['dataBooking'][idDoc]['child'] = 0;
                dataUpdateBooking['dataBooking'][idDoc]['bed'] = bed;
                dataUpdateBooking['dataBooking'][idDoc]['breakfast'] = breakfast;
                dataUpdateBooking['dataBooking'][idDoc]['lunch'] = lunch;
                dataUpdateBooking['dataBooking'][idDoc]['dinner'] = dinner;
                dataUpdateBooking['dataBooking'][idDoc]['tax_declare'] = false;
                dataUpdateBooking['dataBooking'][idDoc]['type_tourists'] = typeTourists;
                dataUpdateBooking['dataBooking'][idDoc]['country'] = country;

                t.create(hotelRef.collection('basic_bookings').doc(idDoc), {
                    'name': name,
                    'bed': bed,
                    'in_date': inDayServer,
                    'in_time': inDayServer,
                    'out_date': outDayServer,
                    'out_time': outDayServer,
                    'room': room,
                    'room_type': roomTypeID,
                    'rate_plan': ratePlanID,
                    'status': isPartner ? BookingStatus.unconfirmed : BookingStatus.booked,
                    'source': sourceID,
                    'sid': mapBooking['sid'],
                    'stay_days': stayDayServer,
                    'phone': phone,
                    'email': email,
                    'price': pricePerNight[roomTypeID],
                    'breakfast': breakfast,
                    'lunch': lunch,
                    'dinner': dinner,
                    'pay_at_hotel': payAtHotel,
                    'adult': adult,
                    'child': 0,
                    'group': true,
                    'created': nowServer,
                    'time_zone': timeZone,
                    'tax_declare': false,
                    'type_tourists': typeTourists,
                    'country': country,
                    'creator': context.auth?.token.email,
                    'notes': notes,
                    'status_payment': PaymentStatus.unpaid,
                    'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                    'booking_type': bookingType,
                });
                if (hotelPackage !== HotelPackage.basic) {
                    const activityData: { [key: string]: any } = {
                        'email': context.auth?.token.email,
                        'id': idDoc,
                        'sid': mapBooking['sid'],
                        'booking_id': idDoc,
                        'type': 'booking',
                        'desc': name + NeutronUtil.specificChar + 'book_room' + NeutronUtil.specificChar + room,
                        'created_time': nowServer
                    };
                    if (idDocument === -1) {
                        idDocument = 0;
                        t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': [activityData],
                            'id': idDocument
                        });
                        lengthOfActivity++;
                    } else {
                        if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                            idDocument++;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                            lengthOfActivity = 0;
                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                            }
                        } else {
                            t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                            });
                            lengthOfActivity++;
                        }
                    }
                }
            };
        }

        t.create(hotelRef.collection('bookings').doc(mapBooking['sid']), {
            'name': name,
            'phone': phone,
            'email': email,
            'in_date': inDayServer,
            'out_date': outDayServer,
            'sub_bookings': dataUpdateBooking['dataBooking'],
            'rate_plan': ratePlanID,
            'source': sourceID,
            'sid': mapBooking['sid'],
            'price': dataUpdateBooking['price'],
            'pay_at_hotel': payAtHotel,
            'status': isPartner ? BookingStatus.unconfirmed : BookingStatus.booked,
            'group': true,
            'created': nowServer,
            'virtual': false,
            'time_zone': timeZone,
            'tax_declare': false,
            'creator': context.auth?.token.email,
            'notes': notes,
            'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
            'booking_type': bookingType,
        });

        if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hOfTimezone);
        }
        t.update(hotelRef, { "sid_booking": mapBooking["code"] });
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error.message);
        throw new functions.https.HttpsError('cancelled', error.message);
    })
    return res;
});
// deploy here - ok - was deploy
exports.checkInGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const hotelPackage = hotelDoc.get('package');
    const timezone: string = hotelDoc.get('timezone');
    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');

    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckIn;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingSID = data.sid;
    const bookingID = data.booking_id;
    const res: string = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const configurationRef = await t.get(hotelRef.collection('management').doc('configurations'));
        if (!configurationRef.exists) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.CONFIGURATION_NOT_FOUND);
        }
        const rooms: { [key: string]: any }[] = configurationRef.get('data')['rooms'];
        const roomTypeBooking: string = bookingDoc.get('sub_bookings')[bookingID]['room_type'];
        const roomBooking = bookingDoc.get('sub_bookings')[bookingID]['room'];
        const statusBooking: number = bookingDoc.get('sub_bookings')[bookingID]['status'];
        const inDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingID]['in_date'].toDate();
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);
        const outDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingID]['out_date'].toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);

        if (roomBooking === '') {
            throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_WAS_DELETE);
        }

        if (rooms[roomBooking] === undefined || rooms[roomBooking] === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_NOT_FOUND);
        }

        if (rooms[roomBooking]['bid'] !== null) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_STILL_NOT_CHECKOUT);
        }

        if (rooms[roomBooking]['clean'] !== true) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_MUST_CLEAN);
        }

        if (statusBooking === BookingStatus.checkin) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_WAS_CHECKEDIN);
        }

        if (statusBooking !== BookingStatus.booked) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
        }

        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);

        if (inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
        }
        ///đk cũ
        if ((nowTimezone.getTime() - outDayBookingTimezone.getTime() >= 0 || inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000)
            && (!roleOfUser.includes(UserRole.admin) && !roleOfUser.includes(UserRole.owner) && !roleOfUser.includes(UserRole.manager))) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
        }
        const info = DateUtil.dateToDayMonthString(inDayBookingTimezone) + '-' + DateUtil.dateToDayMonthString(outDayBookingTimezone);
        const roomData: { [key: string]: any } = {};
        roomData['data.rooms.' + roomBooking + '.bid'] = bookingID;
        roomData['data.rooms.' + roomBooking + '.binfo'] = info;

        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        if (inDayBookingTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() < now12hTimezone.getTime()) {
            const yesterday = DateUtil.addDate(now12hTimezone, -1);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, [yesterday], t);
            const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappedRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, [yesterday], true, almRoomBooked, roomBooking, null, hotelMappingId, hotelMappingKey, dailyAllotments, now12hTimezone);
            // await NeutronUtil.updateDailyAllotmentAndHls(t, hotelRef, [yesterday], true, roomTypeBooking, roomBooking, hotelMappingId, hotelMappingKey, now12hTimezone);
        }
        t.update(hotelRef.collection('management').doc('configurations'), roomData);

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['sub_bookings.' + bookingID + '.status'] = BookingStatus.checkin;
        dataUpdate['status'] = BookingStatus.checkin;
        t.update(hotelRef.collection('basic_bookings').doc(bookingID), {
            'status': BookingStatus.checkin, 'in_time': nowServer
        });
        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);

        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'sid': bookingSID,
                'id': bookingID,
                'booking_id': bookingID,
                'type': 'booking',
                'desc': booking.name + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'checkin'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.checkOutGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const hotelPackage = hotelDoc.get('package');
    const timezone = hotelDoc.get('timezone');
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');

    const bookingSID = data.sid;
    const bookingID = data.booking_id;
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckOut;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        const basicBookingDoc = await t.get(hotelRef.collection('basic_bookings').doc(bookingID));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        const basicBooking = basicBookingDoc.data();
        if (booking === undefined || basicBooking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const roomTypeBooking: string = bookingDoc.get('sub_bookings')[bookingID]['room_type'];
        const roomBooking = bookingDoc.get('sub_bookings')[bookingID]['room'];
        const statusBooking: number = bookingDoc.get('sub_bookings')[bookingID]['status'];
        const outDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingID]['out_date'].toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const bookingsChild: { [key: string]: any } = bookingDoc.get('sub_bookings');
        const basicBookingRentingBike: number = bookingDoc.get('sub_bookings')[bookingID]['renting_bike_num'] ?? 0;
        const typeTourists: string = bookingDoc.get('sub_bookings')[bookingID]['type_tourists'] ?? '';
        const country: string = bookingDoc.get('sub_bookings')[bookingID]['country'] ?? '';
        // const country: string = booking.country ?? '';

        if (basicBookingRentingBike > 0) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_CHECKOUT_BIKES);
        }

        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);

        if (statusBooking === BookingStatus.checkout) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_CHECKOUT_BEFORE);
        }

        if (statusBooking !== BookingStatus.checkin) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_CHECKIN);
        }

        if (nowTimezone.getTime() - outDayBookingTimezone.getTime() > 12 * 60 * 60 * 1000
            && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_OVER_TIME_CHECKOUT);
        }

        let countStatusBookingCheckInOrBooked: number = 0;
        for (const idBooking in bookingsChild) {
            if ([BookingStatus.booked, BookingStatus.checkin].includes(bookingsChild[idBooking]['status'])) {
                countStatusBookingCheckInOrBooked++;
            }
        }

        let isOutBeforeOutDayBooking: boolean = false;
        let dailyAllotments: admin.firestore.DocumentSnapshot[] = [];
        let newStayDatesTimezone: Date[] = [];

        const now12hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        if (nowTimezone.getTime() < outDayBookingTimezone.getTime()) {
            isOutBeforeOutDayBooking = true;
            let breakDate: Date;

            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                breakDate = now12hTimezone;
            } else {
                breakDate = DateUtil.addDate(now12hTimezone, -1);
            }

            newStayDatesTimezone = DateUtil.getStayDates(breakDate, outDayBookingTimezone);
            dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, newStayDatesTimezone, t);

            NeutronUtil.updateBreakfastGuestCollectionDailyData(t, hotelRef, newStayDatesTimezone, basicBooking, false, now12hTimezone, typeTourists, country);
        }

        const dataUpdateBooking: { [key: string]: any } = {};
        // When the last booking of booking group checkout
        if (countStatusBookingCheckInOrBooked === 1) {
            if (booking.renting_bike_num > 0) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_CHECKOUT_BIKES);
            }
            const transferred = booking.transferred === undefined ? 0 : booking.transferred;
            const deposit = booking.deposit === undefined ? 0 : booking.deposit;
            const transferring = booking.transferring === undefined ? 0 : booking.transferring;
            const serviceCharge = NeutronUtil.getServiceCharge(booking);
            const roomCharge = NeutronUtil.getRoomCharge(booking);
            const discount = NeutronUtil.getDiscount(booking);
            const totalCharge = serviceCharge + roomCharge - discount;
            const remaining = totalCharge + transferred - deposit - transferring;
            if (remaining < -NeutronUtil.kZero || remaining > NeutronUtil.kZero) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT);
            }

            NeutronUtil.updateRevenueCollectionDailyData(t, booking, hotelRef, true, nowTimezone);
            t.update(hotelRef.collection('bookings').doc(bookingSID), { 'out_time': nowServer, 'status': BookingStatus.checkout });
            dataUpdateBooking['status'] = BookingStatus.checkout;
        }

        const roomData: { [key: string]: any } = {};
        roomData['data.rooms.' + roomBooking + '.bid'] = null;
        roomData['data.rooms.' + roomBooking + '.binfo'] = null;
        roomData['data.rooms.' + roomBooking + '.clean'] = false;
        roomData['data.rooms.' + roomBooking + '.vacant_overnight'] = false;
        t.update(hotelRef.collection('management').doc('configurations'), roomData);
        t.update(hotelRef.collection('basic_bookings').doc(bookingID), {
            'status': BookingStatus.checkout, 'out_time': nowServer
        });
        dataUpdateBooking['sub_bookings.' + bookingID + '.status'] = BookingStatus.checkout;
        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdateBooking);

        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'id': data.booking_id,
                'sid': bookingSID,
                'booking_id': bookingID,
                'type': 'booking',
                'desc': booking.name + ' (Group)' + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'checkout'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }

        // update hls here
        if (isOutBeforeOutDayBooking) {
            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, newStayDatesTimezone, false, almRoomBooked, roomBooking, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hTimezone);
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
// deploy here - ok - was deploy
exports.checkInAllGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingSID = data.booking_sid;
    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const hotelPackage = hotelDoc.get('package');
    const timezone = hotelDoc.get('timezone');
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckIn;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction: string = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        const configurationRef = await t.get(hotelRef.collection('management').doc('configurations'));
        if (!configurationRef.exists) {
            throw new functions.https.HttpsError("cancelled", MessageUtil.CONFIGURATION_NOT_FOUND);
        }

        const rooms: { [key: string]: any }[] = configurationRef.get('data')['rooms'];
        const subBookings: { [key: string]: any } = bookingDoc.get('sub_bookings');
        const inDateServerBookingGroup: Date = bookingDoc.get('in_date').toDate();
        const outDateServerBookingGroup: Date = bookingDoc.get('out_date').toDate();
        const inDateBookingGroupTimezone: Date = DateUtil.convertUpSetTimezone(inDateServerBookingGroup, timezone);
        const outDateBookingGroupTimezone: Date = DateUtil.convertUpSetTimezone(outDateServerBookingGroup, timezone);
        const stayDateGroupTimezone = DateUtil.getStayDates(inDateBookingGroupTimezone, outDateBookingGroupTimezone);

        const dataUpdateRooms: { [key: string]: any } = {};
        const dataUpdateBookings: { [key: string]: any } = {};
        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateGroupTimezone, t);
        const almMap: { [key: string]: { [key: string]: number } } = {};

        // activity
        let lastDocumentActivity;
        if (hotelPackage !== HotelPackage.basic) {
            lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
        }
        let idDocument;
        let lengthOfActivity;
        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            idDocument = -1;
            lengthOfActivity = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            lengthOfActivity = lastDocumentActivity.data()['activities'].length;
        }

        for (const idBooking in subBookings) {
            const statusBooking: number = subBookings[idBooking]['status'];
            if (statusBooking === BookingStatus.cancel || statusBooking === BookingStatus.noshow || statusBooking === BookingStatus.checkin) continue;

            if (statusBooking !== BookingStatus.booked) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
            }

            const roomBooking = subBookings[idBooking]['room'];
            const roomTypeBooking = subBookings[idBooking]['room_type'];

            const inDayBookingServer: Date = subBookings[idBooking]['in_date'].toDate();
            const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);
            const outDayBookingServer: Date = subBookings[idBooking]['out_date'].toDate();
            const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
            if (roomBooking === '') {
                throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_WAS_DELETE);
            }

            if (rooms[roomBooking] === undefined || rooms[roomBooking] === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.ROOM_NOT_FOUND);
            }

            if (rooms[roomBooking]['bid'] !== null) {
                throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_STILL_NOT_CHECKOUT);
            }

            if (rooms[roomBooking]['clean'] !== true) {
                throw new functions.https.HttpsError("cancelled", MessageUtil.ROOM_MUST_CLEAN);
            }

            if (inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
            }
            ///đk cũ
            if ((nowTimezone.getTime() - outDayBookingTimezone.getTime() >= 0 || inDayBookingTimezone.getTime() - nowTimezone.getTime() > 12 * 60 * 60 * 1000)
                && (!roleOfUser.includes(UserRole.admin) && !roleOfUser.includes(UserRole.owner) && !roleOfUser.includes(UserRole.manager))) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_TODAY_BOOKING);
            }
            const info = DateUtil.dateToDayMonthString(inDayBookingTimezone) + '-' + DateUtil.dateToDayMonthString(outDayBookingTimezone);
            dataUpdateRooms['data.rooms.' + roomBooking + '.bid'] = idBooking;
            dataUpdateRooms['data.rooms.' + roomBooking + '.binfo'] = info;
            dataUpdateBookings['sub_bookings.' + idBooking + '.status'] = BookingStatus.checkin;
            dataUpdateBookings['status'] = BookingStatus.checkin;
            if (hotelPackage !== HotelPackage.basic) {
                const activityData = {
                    'email': context.auth?.token.email,
                    'created_time': nowServer,
                    'sid': bookingSID,
                    'id': idBooking,
                    'booking_id': idBooking,
                    'type': 'booking',
                    'desc': bookingDoc.get('name') + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'checkin'
                };
                if (idDocument === -1) {
                    idDocument = 0;
                    t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                        'activities': [activityData],
                        'id': idDocument
                    });
                    lengthOfActivity++;
                } else {
                    if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                        idDocument++;
                        t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': [activityData],
                            'id': idDocument
                        });
                        lengthOfActivity = 0;
                        if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                            t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                        }
                    } else {
                        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                        });
                        lengthOfActivity++;
                    }
                }
            }

            // hotel link here
            if (inDayBookingTimezone.getTime() === now12hTimezone.getTime() && nowTimezone.getTime() < now12hTimezone.getTime()) {
                const yesterday = DateUtil.addDate(now12hTimezone, -1);
                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, [yesterday], roomTypeBooking, roomBooking, true, false);
                if (mappingHotelID !== undefined) {
                    NeutronUtil.updateHlsToAlm([yesterday], roomTypeBooking, true, dailyAllotments, almMap);
                }
            }

            t.update(hotelRef.collection('basic_bookings').doc(idBooking), {
                'status': BookingStatus.checkin, 'in_time': nowServer
            });
        }

        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdateBookings);
        t.update(hotelRef.collection('management').doc('configurations'), dataUpdateRooms);

        if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, almMap, mappingHotelID, mappingHotelKey, now12hTimezone);
        }

        return MessageUtil.SUCCESS;
    });
    return resultTransaction;

});
// deploy here - ok - was deploy
exports.checkOutAllGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const hotelPackage = hotelDoc.get('package');
    const timezone = hotelDoc.get('timezone');
    const mappingHotelID: string = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string = hotelDoc.get('mapping_hotel_key');
    const bookingID = data.booking_id;
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesCheckOut;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingID));
        const basicBookingDocs = await t.get(hotelRef.collection('basic_bookings').where('sid', '==', bookingID));

        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const typeTourists: string = booking.type_tourists ?? '';
        const country: string = booking.country ?? '';

        const outDayBookingServer: Date = bookingDoc.get('out_date').toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const nowServer = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
        // check time for check out
        if (nowTimezone.getTime() - outDayBookingTimezone.getTime() > 12 * 60 * 60 * 1000
            && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_OVER_TIME_CHECKOUT);
        }

        // check all booking have status is checkin
        const subBookings: { [key: string]: any } = booking.sub_bookings;
        const roomData: { [key: string]: any } = {};
        const dataUpdateBooking: { [key: string]: any } = {};
        const now12hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        if (booking.renting_bike_num > 0) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_CHECKOUT_BIKES);
        }
        // check remaining
        const transferred = booking.transferred === undefined ? 0 : booking.transferred;
        const deposit = booking.deposit === undefined ? 0 : booking.deposit;
        const transferring = booking.transferring === undefined ? 0 : booking.transferring;
        const serviceCharge = NeutronUtil.getServiceCharge(booking);
        const roomCharge = NeutronUtil.getRoomCharge(booking);
        const discount = NeutronUtil.getDiscount(booking);
        const totalCharge = serviceCharge + roomCharge - discount;
        const remaining = totalCharge + transferred - deposit - transferring;

        if (remaining < -NeutronUtil.kZero || remaining > NeutronUtil.kZero) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT);
        }

        // get activity doc
        const lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
        let isOutBeforeOutDayBooking: boolean = false;
        const almMap: { [key: string]: { [key: string]: number } } = {};
        // update breakfast and adult or child if booking group  out before out_date
        if (nowTimezone.getTime() < outDayBookingTimezone.getTime()) {
            let breakDate: Date;
            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                breakDate = now12hTimezone;
            } else {
                breakDate = DateUtil.addDate(now12hTimezone, -1);
            }
            isOutBeforeOutDayBooking = true;

            const stayDateGroupTimezone = DateUtil.getStayDates(breakDate, outDayBookingTimezone);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateGroupTimezone, t);

            for (const basicBookingDoc of basicBookingDocs.docs) {
                const basicBooking = basicBookingDoc.data();
                if (basicBooking.status === BookingStatus.checkout || basicBooking.status === BookingStatus.cancel || basicBooking.status === BookingStatus.moved || basicBooking.status === BookingStatus.noshow) continue;

                const outDayBasicBookingTimezone = DateUtil.convertUpSetTimezone(basicBooking.out_date.toDate(), timezone);
                if (outDayBasicBookingTimezone.getTime() <= breakDate.getTime()) {
                    continue;
                }
                const newStayDateTimezone: Date[] = DateUtil.getStayDates(breakDate, outDayBasicBookingTimezone);
                const basicBookingRoom = basicBooking.room;
                const basicBookingRoomType = basicBooking.room_type;
                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, newStayDateTimezone, basicBookingRoomType, basicBookingRoom, false, false);
                if (mappingHotelID !== undefined) {
                    NeutronUtil.updateHlsToAlm(newStayDateTimezone, basicBookingRoomType, false, dailyAllotments, almMap);
                }
                NeutronUtil.updateBreakfastGuestCollectionDailyData(t, hotelRef, newStayDateTimezone, basicBooking, false, now12hTimezone, typeTourists, country);
            }
        }

        let idDocument;
        let lengthOfActivity;
        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            idDocument = -1;
            lengthOfActivity = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            lengthOfActivity = lastDocumentActivity.data()['activities'].length;
        }

        for (const idBooking in subBookings) {
            if (subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.checkout || subBookings[idBooking]['status'] === BookingStatus.noshow) continue;
            if (subBookings[idBooking]['status'] !== BookingStatus.checkin) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_CHECKIN);
            }
            roomData['data.rooms.' + subBookings[idBooking]['room'] + '.bid'] = null;
            roomData['data.rooms.' + subBookings[idBooking]['room'] + '.binfo'] = null;
            roomData['data.rooms.' + subBookings[idBooking]['room'] + '.clean'] = false;
            roomData['data.rooms.' + subBookings[idBooking]['room'] + '.vacant_overnight'] = false;

            if (hotelPackage !== HotelPackage.basic) {
                const activityData: { [key: string]: any } = {
                    'email': context.auth?.token.email,
                    'id': idBooking,
                    'sid': bookingID,
                    'booking_id': idBooking,
                    'type': 'booking',
                    'desc': booking.name + NeutronUtil.specificChar + subBookings[idBooking]['room'] + NeutronUtil.specificChar + 'checkout',
                    'created_time': nowServer
                };
                if (idDocument === -1) {
                    idDocument = 0;
                    t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                        'activities': [activityData],
                        'id': idDocument
                    });
                    lengthOfActivity++;
                } else {
                    if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                        idDocument++;
                        t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': [activityData],
                            'id': idDocument
                        });
                        lengthOfActivity = 0;
                        if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                            t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                        }
                    } else {
                        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                        });
                        lengthOfActivity++;
                    }
                }
            }

            t.update(hotelRef.collection('basic_bookings').doc(idBooking), {
                'status': BookingStatus.checkout, 'out_time': nowServer
            });
            dataUpdateBooking['sub_bookings.' + idBooking + '.status'] = BookingStatus.checkout;
        }

        t.update(hotelRef.collection('management').doc('configurations'), roomData);
        NeutronUtil.updateRevenueCollectionDailyData(t, booking, hotelRef, true, nowTimezone);


        //update booking parent group
        dataUpdateBooking['out_time'] = nowServer;
        dataUpdateBooking['status'] = BookingStatus.checkout;

        t.update(hotelRef.collection('bookings').doc(bookingID), dataUpdateBooking);

        if (isOutBeforeOutDayBooking && mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, almMap, mappingHotelID, mappingHotelKey, now12hTimezone);
        }
        return MessageUtil.SUCCESS
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError("invalid-argument", error.message);
    });
    return res;
});
// deploy here - ok - was deploy
exports.undoCheckInGroup = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUndoCheckIn;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const bookingId = data.booking_id;
    const bookingSID = data.sid;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingSID)));
        const booking = bookingDoc.data();

        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        const inDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingId]['in_date'].toDate();
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);
        const statusBooking = bookingDoc.get('sub_bookings')[bookingId]['status'];
        const roomBooking = bookingDoc.get('sub_bookings')[bookingId]['room'];
        const roomTypeBooking = bookingDoc.get('sub_bookings')[bookingId]['room_type'];
        const subBookings = bookingDoc.get('sub_bookings');
        if (statusBooking !== BookingStatus.checkin) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_NOT_CHECKIN);
        }

        if (statusBooking === BookingStatus.booked) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_WAS_BOOKED);
        }

        if ((nowTimezone.getTime() - inDayBookingTimezone.getTime()) / 60 / 60 / 1000 > 12
            && (!roleOfUser.includes(UserRole.admin) && !roleOfUser.includes(UserRole.owner) && !roleOfUser.includes(UserRole.manager))) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_OVER_TIME_UNDO_CHECKIN);
        }

        if (nowTimezone.getTime() < inDayBookingTimezone.getTime()) {
            const preCheckInDay = DateUtil.addDate(inDayBookingTimezone, -1);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, [preCheckInDay], t);
            const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappedRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, [preCheckInDay], false, almRoomBooked, roomBooking, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hTimezone);
        }

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
            'status': BookingStatus.booked, 'in_time': inDayBookingServer
        });

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['sub_bookings.' + bookingId + '.status'] = BookingStatus.booked;
        let isAllBookingHaveStatusBooked = true;
        for (const idBooking in subBookings) {
            if (idBooking === bookingId || subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.noshow) {
                continue;
            }
            if (subBookings[idBooking]['status'] !== BookingStatus.booked) {
                isAllBookingHaveStatusBooked = false;
                break;
            }
        }

        if (isAllBookingHaveStatusBooked) {
            dataUpdate['status'] = BookingStatus.booked;
        }
        t.update(hotelRef.collection('bookings').doc(bookingSID), dataUpdate);
        const roomData: { [key: string]: any } = {};
        roomData['data.rooms.' + roomBooking + '.bid'] = null;
        roomData['data.rooms.' + roomBooking + '.binfo'] = null;
        roomData['data.rooms.' + roomBooking + '.clean'] = false;
        t.update(hotelRef.collection('management').doc('configurations'), roomData);
        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'sid': bookingSID,
                'id': bookingId,
                'booking_id': bookingId,
                'type': 'booking',
                'desc': booking.name + ' (Group)' + NeutronUtil.specificChar + roomBooking + NeutronUtil.specificChar + 'undo_checkin'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        throw new functions.https.HttpsError('permission-denied', error.message);
    });
    return res;
});
// deploy here - ok - was deploy 
exports.undoCheckOutGroup = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUndoCheckout;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const timezone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package');
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');

    const nowServer = new Date();
    const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const bookingID: string = data.booking_id;
    const bookingSID: string = data.sid;
    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        const booking = bookingDoc.data();
        const basicBookingDoc = await t.get(hotelRef.collection('basic_bookings').doc(bookingID))
        const basicBooking = basicBookingDoc.data();

        if (!bookingDoc.exists || booking === undefined)
            throw new functions.https.HttpsError("cancelled", MessageUtil.BOOKING_NOT_FOUND);
        if (!basicBookingDoc.exists || basicBooking === undefined)
            throw new functions.https.HttpsError("cancelled", MessageUtil.BOOKING_NOT_FOUND);

        const typeTourists: string = bookingDoc.get('sub_bookings')[bookingID]['type_tourists'] ?? '';
        const country: string = bookingDoc.get('sub_bookings')[bookingID]['country'] ?? '';

        const statusBooking: number = bookingDoc.get('sub_bookings')[bookingID]['status'];
        const roomBooking: string = bookingDoc.get('sub_bookings')[bookingID]['room'];
        const roomTypeBooking: string = bookingDoc.get('sub_bookings')[bookingID]['room_type'];

        const outDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingID]['out_date'].toDate();
        const inDayBookingServer: Date = bookingDoc.get('sub_bookings')[bookingID]['in_date'].toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timezone);

        const outTime24hTimezone = new Date(outDayBookingTimezone.getFullYear(), outDayBookingTimezone.getMonth(), outDayBookingTimezone.getDate(), 23, 59, 0);
        const subBookings = bookingDoc.get('sub_bookings');

        if (statusBooking !== BookingStatus.checkout)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_CHECKOUT);

        if (statusBooking === BookingStatus.checkin)
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_WAS_UNDO_CHECKOUT);

        // check time 
        if (nowTimezone.getTime() > outTime24hTimezone.getTime()) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BOOKING_OVER_TIME_UNDO_CHECKOUT)
        }

        const configurationsRef = await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('management').doc('configurations'));
        const rooms: { [key: string]: any } = configurationsRef.get('data')['rooms'];
        if (rooms[roomBooking]['bid'] !== null) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_CAN_NOT_UNDO_CHECKOUT_BECAUSE_CONFLIX_ROOM)
        }
        let countBookingNotCheckout: number = 0;

        for (const idBooking in subBookings) {
            if (subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.noshow) continue;
            if ([BookingStatus.booked, BookingStatus.checkin].includes(subBookings[idBooking]['status'])) {
                countBookingNotCheckout++;
            }
        }

        let newStayDatesTimezone: Date[] = [];
        const now12hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

        if (nowTimezone.getTime() < outDayBookingTimezone.getTime()) {
            let breakDate: Date;
            if (nowTimezone.getTime() >= now12hTimezone.getTime()) {
                breakDate = now12hTimezone;
            } else {
                breakDate = DateUtil.addDate(now12hTimezone, -1);
            }
            // isOutBeforeOutDayBooking = true;
            newStayDatesTimezone = DateUtil.getStayDates(breakDate, outDayBookingTimezone);
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, newStayDatesTimezone, t);

            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeBooking);
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeBooking, cmId: mappingRoomType['id'] };
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, newStayDatesTimezone, true, almRoomBooked, roomBooking, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hTimezone);
            NeutronUtil.updateBreakfastGuestCollectionDailyData(t, hotelRef, newStayDatesTimezone, basicBooking, true, now12hTimezone, typeTourists, country);
        }

        // all booking was out, back revenue of daily data
        const dataUpdate: { [key: string]: any } = {};

        if (countBookingNotCheckout === 0) {
            const outTimeBookingGroupServer: Date = bookingDoc.get('out_time').toDate();
            const outTimeBookingGroupTimezone: Date = DateUtil.convertUpSetTimezone(outTimeBookingGroupServer, timezone);
            NeutronUtil.updateRevenueCollectionDailyData(t, booking, hotelRef, false, outTimeBookingGroupTimezone);
            t.update(hotelRef.collection('bookings').doc(bookingSID), { 'status': BookingStatus.checkin });
            dataUpdate['status'] = BookingStatus.checkin;
        }

        const info = DateUtil.dateToDayMonthString(inDayBookingTimezone) + '-' + DateUtil.dateToDayMonthString(outDayBookingTimezone);
        const roomData: { [key: string]: any } = {};
        roomData['data.rooms.' + roomBooking + '.bid'] = bookingID;
        roomData['data.rooms.' + roomBooking + '.binfo'] = info;
        t.update(hotelRef.collection('management').doc('configurations'), roomData);

        dataUpdate['sub_bookings.' + bookingID + '.status'] = BookingStatus.checkin;
        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('bookings').doc(bookingSID), dataUpdate);
        t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('basic_bookings').doc(bookingID), { 'status': BookingStatus.checkin, 'out_time': outDayBookingServer });

        if (hotelPackage !== HotelPackage.basic) {
            const activityData = {
                'email': context.auth?.token.email,
                'created_time': nowServer,
                'sid': bookingSID,
                'id': bookingID,
                'booking_id': bookingID,
                'type': 'booking',
                'desc': basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar + 'undo_checkout'
            };
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

///update
// deploy here - ok - was deploy
exports.updateBookingGroup = functions.runWith({ timeoutSeconds: 150 }).https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const keyOfRole = 'role.' + context.auth?.uid;
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    //roles allow to change database
    const rolesAllowed: string[] = NeutronUtil.rolesAddOrUpdateBooking;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get(keyOfRole);
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const hotelPackage = hotelDoc.get('package');
    const timeZone: string = hotelDoc.get('timezone');
    const bookingType: number = data.booking_type;
    const inDayNewBookingTimezone: Date = new Date(data.in_date);
    const inDayNewBookingServer: Date = DateUtil.convertOffSetTimezone(inDayNewBookingTimezone, timeZone);
    const outDayNewBookingTimezone: Date = new Date(data.out_date);
    const outDayNewBookingServer: Date = DateUtil.convertOffSetTimezone(outDayNewBookingTimezone, timeZone);
    const lengthStay: number = DateUtil.getDateRange(inDayNewBookingTimezone, outDayNewBookingTimezone);
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
    const now12hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    const basicBookingID = data.booking_id;
    const roomNewBooking: string = data.room_id;
    const roomTypeNewBooking: string = data.room_type_id;
    const ratePlanNewBooking: string = data.rate_plan_id;
    const priceNewBooking: number[] = data.price;
    const declarationInvoiceDetail: any = data.declaration_invoice_detail !== null ? new Map(Object.entries(data.declaration_invoice_detail)) : undefined;
    const listGuestDeclaration: Array<any> = data.list_guest_declaration;
    const isTaxDeclare: boolean = data.tax_declare ?? false;
    const phoneNew: string = data.phone;
    let phoneOld: string = '';
    const isDeclareInfoEmpty = declarationInvoiceDetail === undefined ? true : NeutronUtil.isMapFieldEmpty(declarationInvoiceDetail);
    const isDeclareGuestEmpty = listGuestDeclaration === null || listGuestDeclaration.length === 0;
    const typeTourists: string = data.type_tourists ?? '';
    const country: string = data.country ?? '';
    const emailSaler = data.saler;
    const lunchNew: boolean = data.lunch ?? false;
    const dinnerNew: boolean = data.dinner ?? false;



    if (data.adult === undefined || (data.adult as number) < 0 || data.child === undefined || (data.child as number) < 0) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INPUT_ADULT_AND_CHILD);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const basicBookingDoc = await t.get(hotelDoc.ref.collection('basic_bookings').doc(basicBookingID));
        const basicBooking = basicBookingDoc.data();
        if (!basicBookingDoc.exists || basicBooking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }
        if (basicBooking?.booking_type !== bookingType && basicBooking?.booking_type != undefined) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.CAM_NOT_CHAGE_BOOKING_TYPE);
        }
        const bookingDoc = await t.get(hotelDoc.ref.collection('bookings').doc(basicBooking.sid));
        const booking: { [key: string]: any } | undefined = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }
        const lunchOld: boolean = basicBooking.lunch ?? false;
        const dinnerOld: boolean = basicBooking.dinner ?? false;
        const inDayBookingServer: Date = basicBooking.in_date.toDate();
        const inDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(inDayBookingServer, timeZone);
        const outDayBookingServer: Date = basicBooking.out_date.toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timeZone);
        const priceTotalBookingGroup: number[] = booking.price;
        const inDayBookingGroupServer: Date = booking.in_date.toDate();
        const outDayBookingGroupServer: Date = booking.out_date.toDate();
        const subBookings: { [key: string]: any } = booking.sub_bookings;
        const stayDaysBookingServer: Date[] = [];
        const roomOldBooking: string = basicBooking.room;
        const roomTypeOldBooking: string = basicBooking.room_type;
        phoneOld = basicBooking.phone;
        const isHaveExtraHour: boolean = (subBookings[basicBookingID].extra_hours !== undefined && (subBookings[basicBookingID].extra_hours?.total ?? 0) !== 0) ? true : false;

        if (booking.rate_plan !== ratePlanNewBooking && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.CAN_NOT_UPDATE_RATE_PLAN_BOOKING_GROUP);
        }

        if (booking.rate_plan === 'OTA') {
            if ((inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime() || data.pay_at_hotel !== booking.pay_at_hotel) && !roleOfUser.some((role) => [UserRole.admin, UserRole.owner, UserRole.manager].includes(role))) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.CAN_NOT_UPDATE_DATE_IN_OUT_WITH_BOOKING_FROM_OTA);
            }
            if (data.rate_plan_id !== 'OTA') {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
            }
        } else {
            if (data.rate_plan_id === 'OTA') {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
            }

            if (lengthStay > 31 && bookingType == BookingType.dayly) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_31);
            }

            if (lengthStay > 365 && bookingType == BookingType.monthly) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_365);
            }
        }

        if (roomOldBooking !== '' && roomNewBooking === '') {
            if (inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime()
                || NeutronUtil.getRoomCharge(priceNewBooking) !== NeutronUtil.getRoomCharge(basicBooking.price)
                || data.pay_at_hotel !== basicBooking.pay_at_hotel || data.breakfast !== basicBooking.breakfast || lunchNew !== lunchOld || dinnerNew !== dinnerOld
                || data.adult !== basicBooking.adult || data.child !== basicBooking.child || data.source !== basicBooking.source) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.SET_NONE_ROOM_CAN_NOT_EDIT_INFORMATION);
            }
        }

        for (const date of basicBooking.stay_days) {
            stayDaysBookingServer.push(date.toDate());
        }

        const stayDaysNewBookingServer: Date[] = DateUtil.getStayDates(inDayNewBookingServer, outDayNewBookingServer);

        const foundDay: Date[] = [];
        for (const date of stayDaysBookingServer) {
            if (stayDaysNewBookingServer.find((e) => e.getTime() === date.getTime()) !== undefined) {
                foundDay.push(date);
            };
        };
        const configurationRef = await hotelDoc.ref.collection('management').doc('configurations').get();
        const rooms: { [key: string]: any } = configurationRef.get('data')['rooms'];
        const roomsOfRoomType: string[] = [];
        Object.keys(rooms).map((idRoom) => {
            if (rooms[idRoom]['room_type'] === roomTypeNewBooking && rooms[idRoom]['is_delete'] === false) {
                roomsOfRoomType.push(idRoom);
            };
        });
        let desc: string = basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar;
        if (basicBooking.name !== data.name) {
            desc += 'change_name' + NeutronUtil.specificChar + data.name + NeutronUtil.specificChar;
        }
        const priceOldBooking: number[] = basicBooking.price;
        const totalOldPrice: number = priceOldBooking.reduce((previousValue, element) => previousValue + element);
        const totalNewPrice: number = priceNewBooking.reduce((previousValue, element) => previousValue + element);
        if (priceOldBooking.length !== priceNewBooking.length || totalOldPrice !== totalNewPrice) {
            if (priceNewBooking.length > priceOldBooking.length) {
                for (let index = 0; index < priceNewBooking.length; index++) {
                    if (priceOldBooking[index] !== undefined) {
                        priceTotalBookingGroup[index] = priceTotalBookingGroup[index] - priceOldBooking[index] + priceNewBooking[index];
                    } else {
                        priceTotalBookingGroup[index] = priceTotalBookingGroup[index] !== undefined ? priceTotalBookingGroup[index] + priceNewBooking[index] : priceNewBooking[index];
                    }
                }
            } else {
                for (let index = 0; index < priceOldBooking.length; index++) {
                    if (priceNewBooking[index] !== undefined) {
                        priceTotalBookingGroup[index] = priceTotalBookingGroup[index] - priceOldBooking[index] + priceNewBooking[index];
                    } else {
                        priceTotalBookingGroup[index] = priceTotalBookingGroup[index] - priceOldBooking[index];
                    }
                }
            }
        };
        const deposits = booking.deposit ?? 0;
        const transferring = booking.transferring ?? 0;
        const totalAllDeposits = deposits + transferring;
        const sub_bookings: { [key: string]: any } = booking.sub_bookings ?? {};
        const totalServiceChargeAndRoomCharge: number =
            (NeutronUtil.getServiceChargeAndRoomCharge(bookingDoc, false) + totalNewPrice) - totalOldPrice;

        const dataAdded: { [key: string]: any } = {}; //for update basicbooking
        dataAdded['tax_declare'] = isTaxDeclare;

        // get staydate max here
        const inDateMin: Date = inDayNewBookingTimezone.getTime() > inDayBookingTimezone.getTime() ? inDayBookingTimezone : inDayNewBookingTimezone;
        const outDateMax: Date = outDayNewBookingTimezone.getTime() > outDayBookingTimezone.getTime() ? outDayNewBookingTimezone : outDayBookingTimezone;
        const stayDateMinMax: Date[] = DateUtil.getStayDates(inDateMin, outDateMax);
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDateMinMax, t);

        switch (basicBooking.status) {
            case BookingStatus.unconfirmed:
                {
                    if (foundDay.length === 0) {
                        const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    } else {
                        if (inDayBookingServer.getTime() > inDayNewBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, inDayBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                        if (outDayNewBookingServer.getTime() > outDayBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    if (roomNewBooking !== '') {
                        if (inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime() || roomOldBooking !== roomNewBooking) {
                            const availableRooms: string[] = [];

                            if (roomOldBooking === roomNewBooking) {
                                if (foundDay.length === 0) {
                                    const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                                    const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                    availableRooms.push(...availableFoundDayNew);
                                } else {

                                    desc += 'change_date';
                                    if (inDayBookingServer.getTime() <= inDayNewBookingServer.getTime() && outDayNewBookingServer.getTime() <= outDayBookingServer.getTime()) {
                                        availableRooms.push(basicBooking.room);
                                    }

                                    if (inDayBookingServer.getTime() > inDayNewBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, inDayBookingTimezone);
                                        const availableRoomInDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomInDate);
                                    }

                                    if (outDayNewBookingServer.getTime() > outDayBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                                        const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomOutDate);
                                    }
                                }
                            } else {
                                const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                                const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                availableRooms.push(...availableFoundDayNew);
                                desc += 'change_room' + NeutronUtil.specificChar + roomNewBooking + NeutronUtil.specificChar;
                            }
                            if (availableRooms.indexOf(roomNewBooking) === -1) {
                                throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    let lastDocumentActivity;
                    if (hotelPackage !== HotelPackage.basic) {
                        lastDocumentActivity = (await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
                    }

                    const alm: { [key: string]: any } = {};
                    let isUpdateHls: boolean = false;

                    // update daily allotment before update
                    const stayDayTimezone: Date[] = DateUtil.getStayDates(inDayBookingTimezone, outDayBookingTimezone);
                    const stayDayTimezoneNew: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                    // update daily allotment here
                    if (inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime() || roomTypeNewBooking !== roomTypeOldBooking) {
                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezone, roomTypeOldBooking, roomOldBooking, false, false);
                        NeutronUtil.updateHlsToAlm(stayDayTimezone, roomTypeOldBooking, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezoneNew, roomTypeNewBooking, roomNewBooking, true, false);
                        NeutronUtil.updateHlsToAlm(stayDayTimezoneNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        isUpdateHls = true;
                    } else {
                        // case update room in room type
                        if (roomNewBooking !== roomOldBooking) {
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezone, roomTypeOldBooking, roomOldBooking, false, true);
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezoneNew, roomTypeNewBooking, roomNewBooking, true, true);
                        }
                    }

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'sid': basicBooking.sid,
                            'booking_id': basicBookingID,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        //get list activities
                        let idDocument;
                        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                            idDocument = 0;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                        } else {
                            idDocument = lastDocumentActivity.data().id;
                            if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                });
                            }
                        }
                    }

                    // update extra hour
                    if (isHaveExtraHour && outDayBookingTimezone.getTime() !== outDayNewBookingTimezone.getTime()) {
                        const outMonthIDOld = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                        const outMonthIDNew = DateUtil.dateToShortStringYearMonth(outDayNewBookingTimezone);

                        if (outMonthIDOld !== outMonthIDNew) {
                            const dataUpdateOldMonth: { [key: string]: any } = {};
                            const dataUpdateNewMonth: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                            dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                            dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdateOldMonth);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDNew), dataUpdateNewMonth);
                        } else {
                            const dataUpdate: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                            dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                            dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdate);
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['rate_plan'] = ratePlanNewBooking;
                    dataAdded['stay_days'] = stayDaysNewBookingServer;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['in_date'] = inDayNewBookingServer;
                    dataAdded['in_time'] = inDayNewBookingServer;
                    dataAdded['out_date'] = outDayNewBookingServer;
                    dataAdded['out_time'] = outDayNewBookingServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    dataAdded['phone'] = data.phone;
                    dataAdded['email'] = data.email;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    dataAdded['modified'] = nowServer;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;

                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewBookingServer, subBookings[basicBookingID].extra_hours.late_hours);
                        dataAdded['in_time'] = DateUtil.addHours(inDayNewBookingServer, - subBookings[basicBookingID].extra_hours.early_hours);
                    }
                    // update basic booking
                    t.update(hotelDoc.ref.collection('basic_bookings').doc(basicBookingID), dataAdded);
                    const dataUpdateBookingGroup: { [key: string]: any } = {};
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.in_date'] = inDayNewBookingServer;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.out_date'] = outDayNewBookingServer;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room'] = roomNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room_type'] = roomTypeNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.price'] = priceNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.adult'] = data.adult;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.child'] = data.child;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.tax_declare'] = isTaxDeclare;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.type_tourists'] = typeTourists;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.country'] = country;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.breakfast'] = data.breakfast;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.lunch'] = lunchNew;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.dinner'] = dinnerNew;

                    dataUpdateBookingGroup['phone'] = data.phone;
                    dataUpdateBookingGroup['rate_plan'] = ratePlanNewBooking;
                    dataUpdateBookingGroup['email_saler'] = emailSaler;

                    if (isDeclareGuestEmpty) {
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.guest'] = FieldValue.delete();
                        let parentBookingHasDeclaration: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].guest !== undefined && subBookings[idBooking].guest.length > 0) {
                                parentBookingHasDeclaration = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroup['has_declaration'] = parentBookingHasDeclaration;
                    } else {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.guest'] = listGuestDeclaration;
                        dataUpdateBookingGroup['has_declaration'] = true;
                    }

                    if (isDeclareInfoEmpty) {
                        dataUpdateBookingGroup['declare_info'] = FieldValue.delete();
                    } else {
                        dataUpdateBookingGroup['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataUpdateBookingGroup['declare_info'][k] = v;
                        });
                    }

                    if (dataAdded['tax_declare']) {
                        //sub booking has tax_declare == true => parent must be true
                        dataUpdateBookingGroup['tax_declare'] = true;
                    } else {
                        let parentBookingTaxDeclare: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].tax_declare === true) {
                                parentBookingTaxDeclare = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroup['tax_declare'] = parentBookingTaxDeclare;
                    }
                    dataUpdateBookingGroup['price'] = priceTotalBookingGroup;

                    if (inDayBookingGroupServer.getTime() > inDayNewBookingServer.getTime()) {
                        dataUpdateBookingGroup['in_date'] = inDayNewBookingServer;
                    }

                    if (outDayBookingGroupServer.getTime() < outDayNewBookingServer.getTime()) {
                        dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                    }

                    if (inDayBookingGroupServer.getTime() < inDayNewBookingServer.getTime() || outDayBookingGroupServer.getTime() > outDayNewBookingServer.getTime()) {
                        let checkInDateAllBooking: boolean = true;
                        let checkOutDateAllBooking: boolean = true;
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].in_date.toDate().getTime() < inDayNewBookingServer.getTime() && checkInDateAllBooking) {
                                checkInDateAllBooking = false;
                            }
                            if (subBookings[idBooking].out_date.toDate().getTime() > outDayNewBookingServer.getTime() && checkOutDateAllBooking) {
                                checkOutDateAllBooking = false;
                            }
                        }
                        if (checkInDateAllBooking) {
                            dataUpdateBookingGroup['in_date'] = inDayNewBookingServer;
                        }
                        if (checkOutDateAllBooking) {
                            dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                        }
                    }

                    if (basicBooking.rate_plan !== ratePlanNewBooking) {
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            t.update(hotelDoc.ref.collection('basic_bookings').doc(idBooking), { 'rate_plan': ratePlanNewBooking });
                        }
                    }

                    t.update(hotelDoc.ref.collection('bookings').doc(basicBooking.sid), dataUpdateBookingGroup);
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, true, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, "", true);
                    if (mappingHotelID !== undefined && mappingHotelKey !== undefined && isUpdateHls) {
                        if (stayDayTimezoneNew.length > 90 || stayDayTimezone.length > 90) {
                            // eslint-disable-next-line @typescript-eslint/no-floating-promises
                            NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        } else {
                            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        }
                    }
                    return MessageUtil.SUCCESS;
                }
            case BookingStatus.booked:
                {

                    if (foundDay.length === 0) {
                        const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    } else {
                        if (inDayBookingServer.getTime() > inDayNewBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, inDayBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                        if (outDayNewBookingServer.getTime() > outDayBookingServer.getTime()) {
                            const staysDayTimezone: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(staysDayTimezone, dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    if (roomNewBooking !== '') {
                        if (inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime() || roomOldBooking !== roomNewBooking) {
                            const availableRooms: string[] = [];

                            if (roomOldBooking === roomNewBooking) {
                                if (foundDay.length === 0) {
                                    const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                                    const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                    availableRooms.push(...availableFoundDayNew);
                                } else {

                                    desc += 'change_date';
                                    if (inDayBookingServer.getTime() <= inDayNewBookingServer.getTime() && outDayNewBookingServer.getTime() <= outDayBookingServer.getTime()) {
                                        availableRooms.push(basicBooking.room);
                                    }

                                    if (inDayBookingServer.getTime() > inDayNewBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, inDayBookingTimezone);
                                        const availableRoomInDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomInDate);
                                    }

                                    if (outDayNewBookingServer.getTime() > outDayBookingServer.getTime()) {
                                        const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                                        const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                        availableRooms.push(...availableRoomOutDate);
                                    }
                                }
                            } else {
                                const stayDateTepm: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                                const availableFoundDayNew = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                                availableRooms.push(...availableFoundDayNew);
                                desc += 'change_room' + NeutronUtil.specificChar + roomNewBooking + NeutronUtil.specificChar;
                            }
                            if (availableRooms.indexOf(roomNewBooking) === -1) {
                                throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                        }
                    }

                    let lastDocumentActivity;
                    if (hotelPackage !== HotelPackage.basic) {
                        lastDocumentActivity = (await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
                    }

                    const alm: { [key: string]: any } = {};
                    let isUpdateHls: boolean = false;

                    // update daily allotment before update
                    const stayDayTimezone: Date[] = DateUtil.getStayDates(inDayBookingTimezone, outDayBookingTimezone);
                    const stayDayTimezoneNew: Date[] = DateUtil.getStayDates(inDayNewBookingTimezone, outDayNewBookingTimezone);
                    // update daily allotment here
                    if (inDayBookingServer.getTime() !== inDayNewBookingServer.getTime() || outDayBookingServer.getTime() !== outDayNewBookingServer.getTime() || roomTypeNewBooking !== roomTypeOldBooking) {
                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezone, roomTypeOldBooking, roomOldBooking, false, false);
                        NeutronUtil.updateHlsToAlm(stayDayTimezone, roomTypeOldBooking, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezoneNew, roomTypeNewBooking, roomNewBooking, true, false);
                        NeutronUtil.updateHlsToAlm(stayDayTimezoneNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        isUpdateHls = true;
                    } else {
                        // case update room in room type
                        if (roomNewBooking !== roomOldBooking) {
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezone, roomTypeOldBooking, roomOldBooking, false, true);
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDayTimezoneNew, roomTypeNewBooking, roomNewBooking, true, true);
                        }
                    }

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'sid': basicBooking.sid,
                            'booking_id': basicBookingID,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        //get list activities
                        let idDocument;
                        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                            idDocument = 0;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                        } else {
                            idDocument = lastDocumentActivity.data().id;
                            if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                });
                            }
                        }
                    }

                    // update extra hour
                    if (isHaveExtraHour && outDayBookingTimezone.getTime() !== outDayNewBookingTimezone.getTime()) {
                        const outMonthIDOld = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                        const outMonthIDNew = DateUtil.dateToShortStringYearMonth(outDayNewBookingTimezone);

                        if (outMonthIDOld !== outMonthIDNew) {
                            const dataUpdateOldMonth: { [key: string]: any } = {};
                            const dataUpdateNewMonth: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                            dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                            dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdateOldMonth);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDNew), dataUpdateNewMonth);
                        } else {
                            const dataUpdate: { [key: string]: any } = {};
                            const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                            const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                            dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                            dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                            t.update(hotelRef.collection('daily_data').doc(outMonthIDOld), dataUpdate);
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['rate_plan'] = ratePlanNewBooking;
                    dataAdded['stay_days'] = stayDaysNewBookingServer;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['in_date'] = inDayNewBookingServer;
                    dataAdded['in_time'] = inDayNewBookingServer;
                    dataAdded['out_date'] = outDayNewBookingServer;
                    dataAdded['out_time'] = outDayNewBookingServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    dataAdded['phone'] = data.phone;
                    dataAdded['email'] = data.email;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    dataAdded['modified'] = nowServer;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;

                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewBookingServer, subBookings[basicBookingID].extra_hours.late_hours);
                        dataAdded['in_time'] = DateUtil.addHours(inDayNewBookingServer, - subBookings[basicBookingID].extra_hours.early_hours);
                    }
                    // update basic booking
                    t.update(hotelDoc.ref.collection('basic_bookings').doc(basicBookingID), dataAdded);
                    const dataUpdateBookingGroup: { [key: string]: any } = {};
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.in_date'] = inDayNewBookingServer;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.out_date'] = outDayNewBookingServer;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room'] = roomNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room_type'] = roomTypeNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.price'] = priceNewBooking;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.adult'] = data.adult;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.child'] = data.child;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.tax_declare'] = isTaxDeclare;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.type_tourists'] = typeTourists;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.country'] = country;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.breakfast'] = data.breakfast;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.lunch'] = lunchNew;
                    dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.dinner'] = dinnerNew;

                    dataUpdateBookingGroup['phone'] = data.phone;
                    dataUpdateBookingGroup['rate_plan'] = ratePlanNewBooking;
                    dataUpdateBookingGroup['email_saler'] = emailSaler;

                    if (isDeclareGuestEmpty) {
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.guest'] = FieldValue.delete();
                        let parentBookingHasDeclaration: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].guest !== undefined && subBookings[idBooking].guest.length > 0) {
                                parentBookingHasDeclaration = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroup['has_declaration'] = parentBookingHasDeclaration;
                    } else {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.guest'] = listGuestDeclaration;
                        dataUpdateBookingGroup['has_declaration'] = true;
                    }

                    if (isDeclareInfoEmpty) {
                        dataUpdateBookingGroup['declare_info'] = FieldValue.delete();
                    } else {
                        dataUpdateBookingGroup['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataUpdateBookingGroup['declare_info'][k] = v;
                        });
                    }

                    if (dataAdded['tax_declare']) {
                        //sub booking has tax_declare == true => parent must be true
                        dataUpdateBookingGroup['tax_declare'] = true;
                    } else {
                        let parentBookingTaxDeclare: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].tax_declare === true) {
                                parentBookingTaxDeclare = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroup['tax_declare'] = parentBookingTaxDeclare;
                    }
                    dataUpdateBookingGroup['price'] = priceTotalBookingGroup;

                    if (inDayBookingGroupServer.getTime() > inDayNewBookingServer.getTime()) {
                        dataUpdateBookingGroup['in_date'] = inDayNewBookingServer;
                    }

                    if (outDayBookingGroupServer.getTime() < outDayNewBookingServer.getTime()) {
                        dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                    }

                    if (inDayBookingGroupServer.getTime() < inDayNewBookingServer.getTime() || outDayBookingGroupServer.getTime() > outDayNewBookingServer.getTime()) {
                        let checkInDateAllBooking: boolean = true;
                        let checkOutDateAllBooking: boolean = true;
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].in_date.toDate().getTime() < inDayNewBookingServer.getTime() && checkInDateAllBooking) {
                                checkInDateAllBooking = false;
                            }
                            if (subBookings[idBooking].out_date.toDate().getTime() > outDayNewBookingServer.getTime() && checkOutDateAllBooking) {
                                checkOutDateAllBooking = false;
                            }
                        }
                        if (checkInDateAllBooking) {
                            dataUpdateBookingGroup['in_date'] = inDayNewBookingServer;
                        }
                        if (checkOutDateAllBooking) {
                            dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                        }
                    }

                    if (basicBooking.rate_plan !== ratePlanNewBooking) {
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            t.update(hotelDoc.ref.collection('basic_bookings').doc(idBooking), { 'rate_plan': ratePlanNewBooking });
                        }
                    }

                    t.update(hotelDoc.ref.collection('bookings').doc(basicBooking.sid), dataUpdateBookingGroup);
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, true, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, "", true);
                    if (mappingHotelID !== undefined && mappingHotelKey !== undefined && isUpdateHls) {
                        if (stayDayTimezoneNew.length > 90 || stayDayTimezone.length > 90) {
                            // eslint-disable-next-line @typescript-eslint/no-floating-promises
                            NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        } else {
                            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                        }
                    }
                    return MessageUtil.SUCCESS;
                }
            case BookingStatus.checkin:
                {
                    if (roomNewBooking === '') {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.BOOKING_NOT_IN_BOOKED_STATUS);
                    }
                    if (inDayNewBookingServer.getTime() !== inDayBookingServer.getTime()) {
                        throw new functions.https.HttpsError('permission-denied', MessageUtil.BOOKING_CHECKIN_CAN_NOT_MODIFY_INDAY);
                    }

                    if (ratePlanNewBooking !== basicBooking.rate_plan) {
                        throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_GROUP_CANNOT_CHANGE_RATE_PLAN);
                    }

                    if (outDayNewBookingTimezone.getTime() > outDayBookingTimezone.getTime()) {
                        const stayOutDates: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                        const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments(stayOutDates, dailyAllotments, roomTypeNewBooking);
                        if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    }

                    // case just change room
                    if (roomOldBooking !== roomNewBooking) {
                        desc += 'change_room' + NeutronUtil.specificChar + roomNewBooking + NeutronUtil.specificChar;
                        const availableRooms: string[] = [];
                        let breakDate: Date;
                        if (nowTimezone.getTime() > now12hTimezone.getTime()) {
                            breakDate = now12hTimezone;
                        } else {
                            breakDate = DateUtil.addDate(now12hTimezone, -1);
                        }

                        if (breakDate.getTime() === outDayNewBookingTimezone.getTime()) {
                            const availableRoomBreakDate = NeutronUtil.getAvailableRoomsWithDailyAllotments([breakDate], dailyAllotments, roomsOfRoomType);
                            const quantityDailyAllotmentNew: number[] = NeutronUtil.getQuantityRoomOfRoomTypeWithDailyAllotments([breakDate], dailyAllotments, roomTypeNewBooking);
                            if (!quantityDailyAllotmentNew.every((e) => e > 0)) {
                                throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                            }
                            availableRooms.push(...availableRoomBreakDate);
                        } else {
                            const stayDateTepm: Date[] = DateUtil.getStayDates(breakDate, outDayNewBookingTimezone);
                            const availableRoomBreakDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                            availableRooms.push(...availableRoomBreakDate);
                        }

                        if (outDayBookingServer.getTime() !== outDayNewBookingServer.getTime()) {
                            desc += 'change_date';
                        }

                        if (availableRooms.indexOf(roomNewBooking) === -1) {
                            throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }

                        let lastDocumentActivity;
                        if (hotelPackage !== HotelPackage.basic) {
                            lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
                        }

                        if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                            const activityData: { [key: string]: any } = {
                                'email': context.auth?.token.email,
                                'id': data.booking_id,
                                'booking_id': data.booking_id,
                                'type': 'booking',
                                'desc': desc,
                                'created_time': nowServer
                            };
                            //get list activities
                            let idDocument;
                            if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                                idDocument = 0;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                            } else {
                                idDocument = lastDocumentActivity.data().id;
                                if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                                    idDocument++;
                                    t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': [activityData],
                                        'id': idDocument
                                    });
                                    if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                        t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                    }
                                } else {
                                    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                    });
                                }
                            }
                        }

                        const inTimeBookingServer = basicBooking.in_time.toDate();
                        const inDateOfMoveBooking: Date = DateUtil.convertOffSetTimezone(new Date(inTimeBookingServer.getFullYear(), inTimeBookingServer.getMonth(), inTimeBookingServer.getDate(), 12), timeZone);
                        const outDateOfMoveBooking: Date = DateUtil.convertOffSetTimezone(DateUtil.addDate(now12hTimezone, 1), timeZone);
                        const lengthStayOfMoveBooking = DateUtil.getStayDates(inDateOfMoveBooking, outDateOfMoveBooking);
                        const nameRoom: string = rooms[roomNewBooking]['name']

                        t.set(hotelDoc.ref.collection('basic_bookings').doc(), {
                            'name': '(moved_to ' + nameRoom + ' ) ' + basicBooking.name,
                            'in_date': inDateOfMoveBooking,
                            'in_time': basicBooking.in_time,
                            'out_time': nowServer,
                            'bed': basicBooking.bed,
                            'out_date': outDateOfMoveBooking,
                            'room': basicBooking.room,
                            'room_type': basicBooking.room_type,
                            'status': BookingStatus.moved,
                            'sid': basicBooking.sid,
                            'source': basicBooking.source,
                            'stay_days': lengthStayOfMoveBooking,
                            'type_tourists': typeTourists,
                            'country': country
                        });
                        const dataUpdateBasicBooking: { [key: string]: any } = {
                            'in_time': nowServer,
                            'room': roomNewBooking,
                            'room_type': roomTypeNewBooking,
                            'modified': nowServer,
                            'price': priceNewBooking,
                            'out_time': outDayNewBookingServer,
                            'out_date': outDayNewBookingServer,
                            'type_tourists': typeTourists,
                            'country': country
                        };
                        if (breakDate.getTime() === outDayNewBookingTimezone.getTime()) {
                            dataUpdateBasicBooking['out_time'] = DateUtil.addDate(nowServer, 1 / (24 * 60));
                        }
                        t.update(hotelDoc.ref.collection('basic_bookings').doc(basicBookingID), dataUpdateBasicBooking);

                        // update configurations change room
                        const info = DateUtil.dateToDayMonthString(inDayBookingTimezone) + '-' + DateUtil.dateToDayMonthString(outDayNewBookingTimezone);
                        const roomData: { [key: string]: any } = {};
                        roomData['data.rooms.' + roomOldBooking + '.bid'] = null;
                        roomData['data.rooms.' + roomOldBooking + '.binfo'] = null;
                        roomData['data.rooms.' + roomNewBooking + '.bid'] = basicBookingID;
                        roomData['data.rooms.' + roomNewBooking + '.binfo'] = info;
                        t.update(
                            hotelDoc.ref.collection('management').doc('configurations'), roomData);

                        // update booking 
                        const dataUpdateBookingGroup: { [key: string]: any } = {};
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.out_date'] = outDayNewBookingServer;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room'] = roomNewBooking;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.room_type'] = roomTypeNewBooking;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.price'] = priceNewBooking;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.adult'] = data.adult;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.child'] = data.child;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.type_tourists'] = typeTourists;
                        dataUpdateBookingGroup['sub_bookings.' + basicBookingID + '.country'] = country;

                        if (outDayBookingGroupServer.getTime() < outDayNewBookingServer.getTime()) {
                            dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                        }
                        if (outDayBookingGroupServer.getTime() > outDayNewBookingServer.getTime()) {
                            let checkOutDateAllBooking: boolean = true;
                            for (const idBooking in subBookings) {
                                if (idBooking === basicBookingID) continue;
                                if (subBookings[idBooking].out_date.toDate().getTime() > outDayNewBookingServer.getTime()) {
                                    checkOutDateAllBooking = false;
                                    break;
                                }
                            }
                            if (checkOutDateAllBooking) {
                                dataUpdateBookingGroup['out_date'] = outDayNewBookingServer;
                            }
                        }

                        dataUpdateBookingGroup['price'] = priceTotalBookingGroup;
                        t.update(hotelDoc.ref.collection('bookings').doc(basicBooking.sid), dataUpdateBookingGroup);

                        if (roomTypeNewBooking !== roomTypeOldBooking || outDayBookingTimezone.getTime() !== outDayNewBookingTimezone.getTime()) {
                            // update hls here
                            const alm: { [key: string]: any } = {};
                            // need to check break date here
                            const stayDatesOld: Date[] = [];
                            if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                                stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, false);
                                NeutronUtil.updateHlsToAlm(stayDatesOld, roomTypeOldBooking, false, dailyAllotments, alm);
                            }


                            const stayDatesNew: Date[] = [];
                            if (breakDate.getTime() !== outDayNewBookingTimezone.getTime()) {
                                stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewBookingTimezone));
                                NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, false);
                                NeutronUtil.updateHlsToAlm(stayDatesNew, roomTypeNewBooking, true, dailyAllotments, alm);
                            }



                            if (mappingHotelID !== undefined && mappingHotelKey !== undefined && Object.keys(alm).length !== 0) {
                                if (stayDatesNew.length > 90 || stayDatesOld.length > 90) {
                                    // eslint-disable-next-line @typescript-eslint/no-floating-promises
                                    NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                                } else {
                                    await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                                }
                            }
                        } else {
                            if (roomOldBooking !== roomNewBooking) {
                                const stayDatesOld: Date[] = [];
                                if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                                    stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                                    NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, true);
                                }

                                const stayDatesNew: Date[] = [];
                                if (breakDate.getTime() !== outDayNewBookingTimezone.getTime()) {
                                    stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewBookingTimezone));
                                    NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, true);
                                }
                            }
                        }


                        return MessageUtil.SUCCESS;
                    };

                    let lastDocumentActivity;
                    if (hotelPackage !== HotelPackage.basic) {
                        lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
                    }

                    // case change out date
                    if (outDayBookingServer.getTime() !== outDayNewBookingServer.getTime()) {
                        desc += 'change_date';

                        const availableRooms: string[] = [];
                        if (outDayNewBookingServer.getTime() > outDayBookingServer.getTime()) {
                            const stayDateTepm: Date[] = DateUtil.getStayDates(outDayBookingTimezone, outDayNewBookingTimezone);
                            const availableRoomOutDate = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDateTepm, dailyAllotments, roomsOfRoomType);
                            availableRooms.push(...availableRoomOutDate);
                            // availableRooms.push(...await NeutronUtil.getAvailableRoomsNew(hotelDoc.ref, outDayBookingTimezone, outDayNewBookingTimezone, roomsOfRoomType));
                        } else {
                            availableRooms.push(basicBooking.room);
                        }
                        if (availableRooms.indexOf(roomNewBooking) === -1) {
                            throw new functions.https.HttpsError('permission-denied', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }

                        let breakDate: Date;
                        if (nowTimezone.getTime() > now12hTimezone.getTime()) {
                            breakDate = now12hTimezone;
                        } else {
                            breakDate = DateUtil.addDate(now12hTimezone, -1);
                        }

                        if (isHaveExtraHour) {
                            const outMonthIDBookingOld: string = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
                            const outMonthIDBookingNew: string = DateUtil.dateToShortStringYearMonth(outDayNewBookingTimezone);

                            if (outMonthIDBookingOld !== outMonthIDBookingNew) {
                                const dataUpdateOldMonth: { [key: string]: any } = {};
                                const dataUpdateNewMonth: { [key: string]: any } = {};
                                const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                                const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                                dataUpdateOldMonth['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                                dataUpdateNewMonth['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingOld), dataUpdateOldMonth);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingNew), dataUpdateNewMonth);
                            } else {
                                const dataUpdate: { [key: string]: any } = {};
                                const dayOldId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
                                const dayNewId = DateUtil.dateToShortStringDay(outDayNewBookingTimezone);
                                dataUpdate['data.' + dayOldId + '.service.extra_hours.total'] = FieldValue.increment(- subBookings[basicBookingID].extra_hours.total);
                                dataUpdate['data.' + dayNewId + '.service.extra_hours.total'] = FieldValue.increment(subBookings[basicBookingID].extra_hours.total);
                                t.update(hotelRef.collection('daily_data').doc(outMonthIDBookingOld), dataUpdate);
                            }
                        }

                        // update hls here
                        const alm: { [key: string]: any } = {};

                        const stayDatesOld: Date[] = [];
                        if (breakDate.getTime() !== outDayBookingTimezone.getTime()) {
                            stayDatesOld.push(...DateUtil.getStayDates(breakDate, outDayBookingTimezone));
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesOld, roomTypeOldBooking, roomOldBooking, false, false);
                            NeutronUtil.updateHlsToAlm(stayDatesOld, roomTypeOldBooking, false, dailyAllotments, alm);
                        }


                        const stayDatesNew: Date[] = [];
                        if (breakDate.getTime() !== outDayNewBookingTimezone.getTime()) {
                            stayDatesNew.push(...DateUtil.getStayDates(breakDate, outDayNewBookingTimezone));
                            NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDatesNew, roomTypeNewBooking, roomNewBooking, true, false);
                            NeutronUtil.updateHlsToAlm(stayDatesNew, roomTypeNewBooking, true, dailyAllotments, alm);
                        }

                        if (mappingHotelID !== undefined && mappingHotelKey !== undefined && Object.keys(alm).length !== 0) {
                            if (stayDatesOld.length > 90 || stayDatesNew.length > 90) {
                                // eslint-disable-next-line @typescript-eslint/no-floating-promises
                                NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                            } else {
                                await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hTimezone);
                            }
                        }
                    };

                    if (hotelPackage !== HotelPackage.basic && desc !== (basicBooking.name + NeutronUtil.specificChar + basicBooking.room + NeutronUtil.specificChar)) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': data.booking_id,
                            'booking_id': data.booking_id,
                            'type': 'booking',
                            'desc': desc,
                            'created_time': nowServer
                        };
                        //get list activities
                        let idDocument;
                        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                            idDocument = 0;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                        } else {
                            idDocument = lastDocumentActivity.data().id;
                            if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                });
                            }
                        }
                    }

                    dataAdded['price'] = priceNewBooking;
                    dataAdded['name'] = data.name;
                    dataAdded['bed'] = data.bed;
                    dataAdded['out_date'] = outDayNewBookingServer;
                    dataAdded['out_time'] = outDayNewBookingServer;
                    dataAdded['room'] = roomNewBooking;
                    dataAdded['room_type'] = roomTypeNewBooking;
                    dataAdded['source'] = data.source;
                    dataAdded['phone'] = data.phone;
                    dataAdded['email'] = data.email;
                    dataAdded['breakfast'] = data.breakfast;
                    dataAdded['lunch'] = lunchNew;
                    dataAdded['dinner'] = dinnerNew;
                    dataAdded['pay_at_hotel'] = data.pay_at_hotel;
                    dataAdded['adult'] = data.adult;
                    dataAdded['child'] = data.child;
                    dataAdded['stay_days'] = stayDaysNewBookingServer;
                    dataAdded['modified'] = nowServer;
                    dataAdded['type_tourists'] = typeTourists;
                    dataAdded['country'] = country;
                    dataAdded['notes'] = data.notes;
                    dataAdded['email_saler'] = emailSaler;
                    if (isHaveExtraHour) {
                        dataAdded['out_time'] = DateUtil.addHours(outDayNewBookingServer, subBookings[basicBookingID].extra_hours.late_hours);
                    }
                    t.update(hotelDoc.ref.collection('basic_bookings').doc(basicBookingID), dataAdded);
                    const dataUpdateBookingGroupCheckIn: { [key: string]: any } = {};
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.out_date'] = outDayNewBookingServer;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.room'] = roomNewBooking;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.room_type'] = roomTypeNewBooking;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.price'] = priceNewBooking;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.adult'] = data.adult;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.child'] = data.child;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.tax_declare'] = dataAdded['tax_declare'];
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.type_tourists'] = typeTourists;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.country'] = country;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.breakfast'] = data.breakfast;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.lunch'] = lunchNew;
                    dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.dinner'] = dinnerNew;

                    dataUpdateBookingGroupCheckIn['price'] = priceTotalBookingGroup;
                    dataUpdateBookingGroupCheckIn['email_saler'] = emailSaler;
                    if (dataAdded['tax_declare']) {
                        //sub booking has tax_declare == true => parent must be true
                        dataUpdateBookingGroupCheckIn['tax_declare'] = true;
                    } else {
                        let parentBookingTaxDeclare: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].tax_declare === true) {
                                parentBookingTaxDeclare = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroupCheckIn['tax_declare'] = parentBookingTaxDeclare;
                    }
                    if (isDeclareGuestEmpty) {
                        dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.guest'] = FieldValue.delete();
                        let parentBookingHasDeclaration: boolean = false;
                        //check tax_declare of all sub_bookings => if all are false -> make tax_declare of ParentBooking false
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].guest !== undefined && subBookings[idBooking].guest.length > 0) {
                                parentBookingHasDeclaration = true;
                                break;
                            }
                        }
                        dataUpdateBookingGroupCheckIn['has_declaration'] = parentBookingHasDeclaration;
                    } else {
                        listGuestDeclaration.forEach((e) => {
                            e['date_of_birth'] = new Date(e['date_of_birth']);
                        });
                        dataUpdateBookingGroupCheckIn['sub_bookings.' + basicBookingID + '.guest'] = listGuestDeclaration;
                        dataUpdateBookingGroupCheckIn['has_declaration'] = true;
                    }
                    if (isDeclareInfoEmpty) {
                        dataUpdateBookingGroupCheckIn['declare_info'] = FieldValue.delete();
                    } else {
                        dataUpdateBookingGroupCheckIn['declare_info'] = {};
                        (declarationInvoiceDetail as Map<string, any>).forEach((v, k) => {
                            dataUpdateBookingGroupCheckIn['declare_info'][k] = v;
                        });
                    }
                    if (outDayBookingGroupServer.getTime() < outDayNewBookingServer.getTime()) {
                        dataUpdateBookingGroupCheckIn['out_date'] = outDayNewBookingServer;
                    }
                    if (outDayBookingGroupServer.getTime() > outDayNewBookingServer.getTime()) {
                        let checkOutDateAllBooking: boolean = true;
                        for (const idBooking in subBookings) {
                            if (idBooking === basicBookingID) continue;
                            if (subBookings[idBooking].out_date.toDate().getTime() > outDayNewBookingServer.getTime()) {
                                checkOutDateAllBooking = false;
                                break;
                            }
                        }
                        if (checkOutDateAllBooking) {
                            dataUpdateBookingGroupCheckIn['out_date'] = outDayNewBookingServer;
                        }
                    }
                    t.update(hotelDoc.ref.collection('bookings').doc(basicBooking.sid), dataUpdateBookingGroupCheckIn);
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, true, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, "", true);
                    return MessageUtil.SUCCESS;
                }
            default:
                throw new functions.https.HttpsError('cancelled', MessageUtil.JUST_FOR_CHECKIN_OR_REPAIR_BOOKING);
        }
    }).catch((error) => {
        console.log(error.message);
        throw new functions.https.HttpsError('cancelled', error.message);
    });
    if (phoneNew !== '' && phoneOld !== phoneNew) {
        const token = context.rawRequest.headers.authorization;
        const options = {
            hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
            path: '/addBooking',
            method: 'POST',
            headers: {
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        };
        const postData = JSON.stringify({
            'name': data.name,
            'phone': data.phone,
            'inDate': data.in_date,
            'outDate': data.out_date,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        });
        RestUtil.postRequest(options, postData).catch(console.error);

    }
    return res;
});

exports.updateTaxDeclare = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const newTaxDeclare = data.tax_declare;
    const isGroup = data.is_group;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    const rolesAllowed: string[] = NeutronUtil.rolesUpdateTaxDeclare;
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth?.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = fireStore.runTransaction(async (t) => {
        const basicBookingDoc = await t.get(fireStore.collection('hotels').doc(hotelId).collection('basic_bookings').doc(bookingId));
        const bookingDoc = await t.get(fireStore.collection('hotels').doc(hotelId).collection('bookings').doc(isGroup ? bookingSid : bookingId));
        if (!basicBookingDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }
        const basicBooking = basicBookingDoc.data();
        const booking = bookingDoc.data();
        if (basicBooking === undefined || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        if (basicBooking['tax_declare'] === newTaxDeclare && booking['tax_declare'] === newTaxDeclare) {
            return MessageUtil.SUCCESS;
        }

        const dataUpdate: { [key: string]: any } = { 'tax_declare': newTaxDeclare };

        t.update(hotelRef.collection('basic_bookings').doc(bookingId), dataUpdate);

        if (isGroup) {
            dataUpdate[`sub_bookings.${bookingId}.tax_declare`] = newTaxDeclare
            t.update(hotelRef.collection('bookings').doc(bookingSid), dataUpdate);
        } else {
            t.update(hotelRef.collection('bookings').doc(bookingId), dataUpdate);
        }
        return MessageUtil.SUCCESS;
    });

    return res;
});

exports.updateStatusInvoice = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const statusInvoice = data.statusinvoice;
    const isGroup = data.is_group;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    const rolesAllowed: string[] = NeutronUtil.rolesUpdateStatusInvoice;
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth?.uid);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = fireStore.runTransaction(async (t) => {
        // if (!isGroup) {
        //     basicBookingDoc = await t.get(fireStore.collection('hotels').doc(hotelId).collection('basic_bookings').doc(bookingId));
        // }
        const bookingDoc = await t.get(fireStore.collection('hotels').doc(hotelId).collection('bookings').doc(isGroup ? bookingSid : bookingId));
        // if (!basicBookingDoc.exists) {
        //     throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        // }
        // const basicBooking = basicBookingDoc.data();
        const booking = bookingDoc.data();
        // basicBooking === undefined ||
        if (booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        // basicBooking['status_invoice'] === statusInvoice && 
        // if (booking['status_invoice'] !== undefined) {
        //     if (booking['status_invoice'] === statusInvoice) {
        //         return MessageUtil.SUCCESS;
        //     }
        // }
        const dataUpdate: { [key: string]: any } = { 'status_invoice': !statusInvoice };

        // t.update(hotelRef.collection('basic_bookings').doc(bookingId), dataUpdate);

        if (isGroup) {
            t.update(hotelRef.collection('bookings').doc(bookingSid), dataUpdate);
        } else {
            t.update(hotelRef.collection('bookings').doc(bookingId), dataUpdate);
        }
        return MessageUtil.SUCCESS;
    });

    return res;

});

// deploy here - ok - was deploy
exports.updateAllBookingGroup = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);
    const hotelRef = fireStore.collection('hotels').doc(data.hotel_id);
    const hotelDoc = await hotelRef.get();

    const hotelPackage = hotelDoc.get('package');
    const timeZone = hotelDoc.get('timezone');
    const mappingHotelID: string = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string = hotelDoc.get('mapping_hotel_key');

    const rolesAllowed: string[] = NeutronUtil.rolesAddOrUpdateBooking;
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const mapRoomTypes: { [key: string]: string[] } = data.map_room_types;
    const pricePerNight: { [key: string]: { [key: string]: number[] } } = data.price_per_night;
    const bookingType: number = data.booking_type;
    const priceGroupBookingAll: number[] = data.price;
    const inDayTimezone: Date = new Date(data.in_date);
    const outDayTimezone = new Date(data.out_date);
    const inDayTimezoneOld: Date = new Date(data.in_date_old);
    const outDayTimezoneOld: Date = new Date(data.out_date_old);
    const inDayServer = DateUtil.convertOffSetTimezone(inDayTimezone, timeZone);
    const outDayServer = DateUtil.convertOffSetTimezone(outDayTimezone, timeZone);
    const inDayServerOld = DateUtil.convertOffSetTimezone(inDayTimezoneOld, timeZone);
    const outDayServerOld = DateUtil.convertOffSetTimezone(outDayTimezoneOld, timeZone);
    const payAtHotel: boolean = data.pay_at_hotel;
    const breakfast: boolean = data.breakfast;
    const lunch: boolean = data.lunch ?? false;
    const dinner: boolean = data.dinner ?? false;
    const sourceID = data.source_id;
    const ratePlanID = data.rate_plan_id;
    const sID = data.sID;
    const name = data.name;
    const email = data.email;
    const phone = data.phone;
    const notes = data.notes;
    const lengthStay: number = DateUtil.getDateRange(inDayTimezone, outDayTimezone);
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
    const now12hOfTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    // const yesterday12h = DateUtil.addDate(now12hOfTimezone, -1);
    // const stayDaysTimezone = DateUtil.getStayDates(inDayServerOld, outDayServerOld);
    const stayDaysTimezoneOld = DateUtil.getStayDates(inDayTimezoneOld, outDayTimezoneOld);
    const stayDaysTimezoneNew = DateUtil.getStayDates(inDayServer, outDayServer);
    const stayInDaysOld = DateUtil.getStayDates(inDayServer, inDayServerOld);
    const stayOutDaysOld = DateUtil.getStayDates(outDayServerOld, outDayServer);
    const typeTourists: string = data.type_tourists ?? '';
    const country: string = data.country ?? '';
    const idBooking: { [key: string]: { [key: string]: any } } = data.id_booking;
    const listStayDay: { [key: string]: string[] } = data.stay_day;
    const isCheckChangeBooking: boolean = data.check_booking;
    const listID: string[] = data.list_id;
    const emailSaler = data.saler;


    console.log(priceGroupBookingAll);


    if (phone !== '') {
        const token = context.rawRequest.headers.authorization;
        const options = {
            hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
            path: '/addBooking',
            method: 'POST',
            headers: {
                'Authorization': token,
                'Content-Type': 'application/json'
            }
        };
        const postData = JSON.stringify({
            'name': data.name,
            'phone': data.phone,
            'inDate': data.in_date,
            'outDate': data.out_date,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        });
        RestUtil.postRequest(options, postData).catch(console.error);
    }
    if (lengthStay > 31 && bookingType == BookingType.dayly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_31);
    }

    if (lengthStay > 365 && bookingType == BookingType.monthly) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.OVER_MAX_LENGTHDAY_365);
    }

    // if (inDayTimezone.getTime() < yesterday12h.getTime() || (inDayTimezone.getTime() === yesterday12h.getTime() && nowTimezone.getTime() > now12hOfTimezone.getTime())) {
    //     throw new functions.https.HttpsError('permission-denied', MessageUtil.INDATE_MUST_NOT_IN_PAST);
    // }
    if (data.rate_plan_id === 'OTA') {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN);
    }
    const res = await fireStore.runTransaction(async (t) => {
        const configurationRef = await t.get(hotelRef.collection('management').doc('configurations'));
        const lastDocumentActivity = (await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDaysTimezoneNew, t);
        const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];
        const bookingDoc = await t.get(hotelDoc.ref.collection('bookings').doc(sID));
        const booking: { [key: string]: any } | undefined = bookingDoc.data();
        if (stayDaysTimezoneOld.length < stayDaysTimezoneNew.length) {
            for (const roomTypeID in mapRoomTypes) {
                for (const room of mapRoomTypes[roomTypeID]) {
                    if (outDayServerOld.getDay() < outDayServer.getDay()) {
                        if (NeutronUtil.getBookedRoomOfRoomTypeWithDailyAllotments(stayOutDaysOld, dailyAllotments, room)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    }
                    if (inDayServer.getDay() < inDayServerOld.getDay()) {
                        if (NeutronUtil.getBookedRoomOfRoomTypeWithDailyAllotments(stayInDaysOld, dailyAllotments, room)) {
                            throw new functions.https.HttpsError('cancelled', MessageUtil.THIS_ROOM_NOT_AVAILABLE);
                        }
                    }

                }
            }
        }
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        if (booking?.booking_type !== bookingType && booking?.booking_type != undefined) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.CAM_NOT_CHAGE_BOOKING_TYPE);
        }

        const dataUpdateBooking: { [key: string]: any } = {};
        let idDocument;
        let lengthOfActivity;

        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            idDocument = -1;
            lengthOfActivity = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            lengthOfActivity = lastDocumentActivity.data()['activities'].length;
        }
        const alm: { [key: string]: { [key: string]: number } } = {};
        let status_payment: number = 0;
        const priceOldBooking: number[] = booking.price;
        let priceRoomNew: number = 0;
        let priceRoomOld: number = 0
        if (priceGroupBookingAll.length > 0 && priceOldBooking.length > 0) {
            priceRoomNew = priceGroupBookingAll.reduce((previousValue, element) => previousValue + element);
            priceRoomOld = priceOldBooking.reduce((previousValue, element) => previousValue + element);
        }
        const deposits = booking.deposit ?? 0;
        const transferring = booking.transferring ?? 0;
        const totalAllDeposits = deposits + transferring;
        const totalServiceChargeAndRoomCharge: number =
            (NeutronUtil.getServiceChargeAndRoomCharge(bookingDoc, false) + priceRoomNew) - priceRoomOld;

        for (const roomTypeID in mapRoomTypes) {

            if (mapRoomTypes[roomTypeID].length === 0) {
                continue;
            }
            if (mapRoomTypes[roomTypeID].length > roomTypes[roomTypeID]['num']) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.ROOMTYPE_DONT_HAVE_ENOUGH_QUATITY);
            }

            for (const room of mapRoomTypes[roomTypeID]) {
                console.log("updateDataHaveIn-Out");
                if (idBooking[room]["status"] === BookingStatus.booked.toString()) {
                    const stayDaysBooking: Date[] = [];
                    for (const date of listStayDay[idBooking[room]["id"]]) {
                        stayDaysBooking.push(new Date(date));
                    }

                    NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeID, room, false, false);
                    NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeID, false, dailyAllotments, alm);

                    NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysTimezoneNew, roomTypeID, room, true, false);
                    NeutronUtil.updateHlsToAlm(stayDaysTimezoneNew, roomTypeID, true, dailyAllotments, alm);
                    if (totalAllDeposits == 0 && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                        status_payment = PaymentStatus.unpaid
                    }
                    if (totalAllDeposits == totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.done;
                    };
                    if (0 < totalAllDeposits && totalAllDeposits < totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.partial;
                    };
                    if (totalServiceChargeAndRoomCharge < totalAllDeposits && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.done;
                    };

                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room'] = room;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room_type'] = roomTypeID;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.out_date'] = outDayServer;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.in_date'] = inDayServer;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.price'] = pricePerNight[room][roomTypeID];
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.breakfast'] = breakfast;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.lunch'] = lunch;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.dinner'] = dinner;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.type_tourists'] = typeTourists;
                    dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.country'] = country;

                    t.update(hotelRef.collection('basic_bookings').doc(idBooking[room]["id"]), {
                        'name': name,
                        'out_date': outDayServer,
                        'out_time': outDayServer,
                        'in_date': inDayServer,
                        'in_time': inDayServer,
                        'room': room,
                        'room_type': roomTypeID,
                        'rate_plan': ratePlanID,
                        'source': sourceID,
                        'sid': sID,
                        'stay_days': stayDaysTimezoneNew,
                        'phone': phone,
                        'email': email,
                        'price': pricePerNight[room][roomTypeID],
                        'breakfast': breakfast,
                        'lunch': lunch,
                        'dinner': dinner,
                        'pay_at_hotel': payAtHotel,
                        'type_tourists': typeTourists,
                        'country': country,
                        'notes': notes,
                        'status_payment': status_payment,
                        'email_saler': emailSaler,
                    });

                    if (hotelPackage !== HotelPackage.basic) {
                        const activityData: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'id': idBooking[room]["id"],
                            'sid': sID,
                            'booking_id': idBooking[room]["id"],
                            'type': 'booking',
                            'desc': name + NeutronUtil.specificChar + 'update_group' + NeutronUtil.specificChar + room,
                            'created_time': nowServer
                        };
                        if (idDocument === -1) {
                            idDocument = 0;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                            lengthOfActivity++;
                        } else {
                            if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                lengthOfActivity = 0;
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                });
                                lengthOfActivity++;
                            }
                        }
                    }

                } else if (idBooking[room]["status"] === BookingStatus.checkin.toString()) {
                    const inDayBooking: Date = new Date(idBooking[room]["inDate"]);
                    const stayDaysBooking: Date[] = [];
                    for (const date of listStayDay[idBooking[room]["id"]]) {
                        stayDaysBooking.push(new Date(date));
                    }

                    if (totalAllDeposits == 0 && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                        status_payment = PaymentStatus.unpaid
                    }
                    if (totalAllDeposits == totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.done;
                    };
                    if (0 < totalAllDeposits && totalAllDeposits < totalServiceChargeAndRoomCharge && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.partial;
                    };
                    if (totalServiceChargeAndRoomCharge < totalAllDeposits && priceRoomNew !== priceRoomOld) {
                        status_payment = PaymentStatus.done;
                    };

                    if (inDayBooking.getTime() != inDayTimezone.getTime()) {
                        const inDayServers = DateUtil.convertOffSetTimezone(inDayBooking, timeZone);
                        const stayDaysTimezoneNewCheckIn = DateUtil.getStayDates(inDayServers, outDayServer);


                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeID, room, false, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeID, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysTimezoneNewCheckIn, roomTypeID, room, true, false);
                        NeutronUtil.updateHlsToAlm(stayDaysTimezoneNewCheckIn, roomTypeID, true, dailyAllotments, alm);

                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room'] = room;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room_type'] = roomTypeID;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.out_date'] = outDayServer;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.price'] = pricePerNight[room][roomTypeID];
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.breakfast'] = breakfast;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.lunch'] = lunch;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.dinner'] = dinner;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.type_tourists'] = typeTourists;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.country'] = country;

                        t.update(hotelRef.collection('basic_bookings').doc(idBooking[room]["id"]), {
                            'name': name,
                            'out_date': outDayServer,
                            'out_time': outDayServer,
                            'room': room,
                            'room_type': roomTypeID,
                            'rate_plan': ratePlanID,
                            'source': sourceID,
                            'sid': sID,
                            'stay_days': stayDaysTimezoneNewCheckIn,
                            'phone': phone,
                            'email': email,
                            'price': pricePerNight[room][roomTypeID],
                            'breakfast': breakfast,
                            'lunch': lunch,
                            'dinner': dinner,
                            'pay_at_hotel': payAtHotel,
                            'type_tourists': typeTourists,
                            'country': country,
                            'notes': notes,
                            'status_payment': status_payment,
                            'email_saler': emailSaler,
                        });
                        if (hotelPackage !== HotelPackage.basic) {
                            const activityData: { [key: string]: any } = {
                                'email': context.auth?.token.email,
                                'id': idBooking[room]["id"],
                                'sid': sID,
                                'booking_id': idBooking[room]["id"],
                                'type': 'booking',
                                'desc': name + NeutronUtil.specificChar + 'update_group' + NeutronUtil.specificChar + room,
                                'created_time': nowServer
                            };
                            if (idDocument === -1) {
                                idDocument = 0;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                lengthOfActivity++;
                            } else {
                                if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                    idDocument++;
                                    t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': [activityData],
                                        'id': idDocument
                                    });
                                    lengthOfActivity = 0;
                                    if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                        t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                    }
                                } else {
                                    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                    });
                                    lengthOfActivity++;
                                }
                            }
                        }


                    } else {
                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysBooking, roomTypeID, room, false, false);
                        NeutronUtil.updateHlsToAlm(stayDaysBooking, roomTypeID, false, dailyAllotments, alm);

                        NeutronUtil.updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(t, hotelRef, stayDaysTimezoneNew, roomTypeID, room, true, false);
                        NeutronUtil.updateHlsToAlm(stayDaysTimezoneNew, roomTypeID, true, dailyAllotments, alm);

                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room'] = room;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.room_type'] = roomTypeID;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.out_date'] = outDayServer;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.price'] = pricePerNight[room][roomTypeID];
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.breakfast'] = breakfast;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.lunch'] = lunch;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.dinner'] = dinner;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.type_tourists'] = typeTourists;
                        dataUpdateBooking['sub_bookings.' + idBooking[room]["id"] + '.country'] = country;

                        t.update(hotelRef.collection('basic_bookings').doc(idBooking[room]["id"]), {
                            'name': name,
                            'out_date': outDayServer,
                            'out_time': outDayServer,
                            'room': room,
                            'room_type': roomTypeID,
                            'rate_plan': ratePlanID,
                            'source': sourceID,
                            'sid': sID,
                            'stay_days': stayDaysTimezoneNew,
                            'phone': phone,
                            'email': email,
                            'price': pricePerNight[room][roomTypeID],
                            'breakfast': breakfast,
                            'lunch': lunch,
                            'dinner': dinner,
                            'pay_at_hotel': payAtHotel,
                            'type_tourists': typeTourists,
                            'country': country,
                            'notes': notes,
                            'status_payment': status_payment,
                            'email_saler': emailSaler,
                        });
                        if (hotelPackage !== HotelPackage.basic) {
                            const activityData: { [key: string]: any } = {
                                'email': context.auth?.token.email,
                                'id': idBooking[room]["id"],
                                'sid': sID,
                                'booking_id': idBooking[room]["id"],
                                'type': 'booking',
                                'desc': name + NeutronUtil.specificChar + 'update_group' + NeutronUtil.specificChar + room,
                                'created_time': nowServer
                            };
                            if (idDocument === -1) {
                                idDocument = 0;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                lengthOfActivity++;
                            } else {
                                if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                    idDocument++;
                                    t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': [activityData],
                                        'id': idDocument
                                    });
                                    lengthOfActivity = 0;
                                    if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                        t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                    }
                                } else {
                                    t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                        'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                    });
                                    lengthOfActivity++;
                                }
                            }
                        }
                    }

                }
            };

        }

        for (const id of listID) {
            if (inDayTimezone.getTime() == inDayTimezoneOld.getTime() && outDayTimezone.getTime() == outDayTimezoneOld.getTime()) {
                console.log("updateDataNotIn-Out");
                dataUpdateBooking['sub_bookings.' + id + '.breakfast'] = breakfast;
                dataUpdateBooking['sub_bookings.' + id + '.lunch'] = lunch;
                dataUpdateBooking['sub_bookings.' + id + '.dinner'] = dinner;
                dataUpdateBooking['sub_bookings.' + id + '.type_tourists'] = typeTourists;
                dataUpdateBooking['sub_bookings.' + id + '.country'] = country;

                t.update(hotelRef.collection('basic_bookings').doc(id), {
                    'name': name,
                    'rate_plan': ratePlanID,
                    'source': sourceID,
                    'sid': sID,
                    'phone': phone,
                    'email': email,
                    'breakfast': breakfast,
                    'lunch': lunch,
                    'dinner': dinner,
                    'pay_at_hotel': payAtHotel,
                    'type_tourists': typeTourists,
                    'country': country,
                    'notes': notes,
                    'email_saler': emailSaler,
                });
                if (hotelPackage !== HotelPackage.basic) {
                    const activityData: { [key: string]: any } = {
                        'email': context.auth?.token.email,
                        'id': id,
                        'sid': sID,
                        'booking_id': id,
                        'type': 'booking',
                        'desc': name + NeutronUtil.specificChar + 'update_group',
                        'created_time': nowServer
                    };
                    if (idDocument === -1) {
                        idDocument = 0;
                        t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                            'activities': [activityData],
                            'id': idDocument
                        });
                        lengthOfActivity++;
                    } else {
                        if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                            idDocument++;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                            lengthOfActivity = 0;
                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                            }
                        } else {
                            t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                            });
                            lengthOfActivity++;
                        }
                    }
                }
            }
        }

        dataUpdateBooking['name'] = name;
        dataUpdateBooking['phone'] = phone;
        dataUpdateBooking['email'] = email;
        dataUpdateBooking['out_date'] = outDayServer;
        dataUpdateBooking['in_date'] = isCheckChangeBooking ? inDayServer : inDayServerOld;
        dataUpdateBooking['rate_plan'] = ratePlanID;
        dataUpdateBooking['source'] = sourceID;
        dataUpdateBooking['sid'] = sID;
        dataUpdateBooking['pay_at_hotel'] = payAtHotel;
        dataUpdateBooking['notes'] = notes;
        dataUpdateBooking['modified'] = nowServer;
        dataUpdateBooking['email_saler'] = emailSaler;
        if (priceGroupBookingAll.length !== 0) {
            dataUpdateBooking['price'] = priceGroupBookingAll;
        }
        t.update(hotelRef.collection('bookings').doc(sID), dataUpdateBooking);
        console.log(alm);

        if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            await NeutronUtil.updateHlsWithDateAndRoomType(hotelRef, alm, mappingHotelID, mappingHotelKey, now12hOfTimezone);
        }
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error.message);
        throw new functions.https.HttpsError('cancelled', error.message);
    })
    return res;
});

exports.updateStatus = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    //roles allow to change database
    const rolesAllowed: String[] = NeutronUtil.rolesUpdateStatus;
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get('role.' + context.auth.uid);
    const hotelPackage = hotelDoc.get('package');
    const nowServer = new Date();

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const dataStatus = data.status;
    const bookingId = data.booking_id;
    const sidBooking = data.sid;
    const group = data.group;

    const res = await fireStore.runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(bookingId)));
        const lastDocumentActivity = (await t.get(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
        const nameBooking = bookingDoc.get('name');
        const dateCreator = bookingDoc.get('creator');
        const activityData: { [key: string]: any } = {
            'email': context.auth?.token.email,
            'created_time': nowServer,
            'type': 'booking',
        };
        if (group) {
            let idDocument;
            let lengthOfActivity;

            if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                idDocument = -1;
                lengthOfActivity = 0;
            } else {
                idDocument = lastDocumentActivity.data().id;
                lengthOfActivity = lastDocumentActivity.data()['activities'].length;
            }
            if (!bookingDoc.exists) {
                const bookingDocs = (await t.get(hotelRef.collection('bookings').doc(sidBooking)));
                t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
                    'status': dataStatus
                });
                t.update(hotelRef.collection('bookings').doc(sidBooking), {
                    'status': dataStatus,
                    ['sub_bookings.' + bookingId + '.status']: dataStatus,
                });

                activityData["id"] = bookingId;
                activityData["sid"] = sidBooking;
                activityData["booking_id"] = bookingId;
                activityData['desc'] = bookingDocs.get('name') + NeutronUtil.specificChar + bookingDocs.get('creator') + NeutronUtil.specificChar + 'confirm';

            } else {
                const basicBookingsDoc = await t.get(hotelRef.collection("basic_bookings").where('sid', '==', sidBooking));

                if (basicBookingsDoc.empty) {
                    throw new functions.https.HttpsError('permission-denied', MessageUtil.BOOKING_NOT_FOUND);
                }
                for (const key in basicBookingsDoc.docs) {
                    t.update(hotelRef.collection('basic_bookings').doc(basicBookingsDoc.docs[key].id), {
                        'status': dataStatus
                    });
                    t.update(hotelRef.collection('bookings').doc(sidBooking), {
                        'status': dataStatus,
                        ['sub_bookings.' + basicBookingsDoc.docs[key].id + '.status']: dataStatus,
                    });

                    if (hotelPackage !== HotelPackage.basic) {
                        const activityDatas: { [key: string]: any } = {
                            'email': context.auth?.token.email,
                            'created_time': nowServer,
                            'id': basicBookingsDoc.docs[key].id,
                            'sid': sidBooking,
                            'booking_id': basicBookingsDoc.docs[key].id,
                            'type': 'booking',
                            'desc': nameBooking + NeutronUtil.specificChar + dateCreator + NeutronUtil.specificChar + 'confirm'
                        };

                        if (idDocument === -1) {
                            idDocument = 0;
                            t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                'activities': [activityDatas],
                                'id': idDocument
                            });
                            lengthOfActivity++;
                        } else {
                            if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;
                                t.set(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityDatas],
                                    'id': idDocument
                                });
                                lengthOfActivity = 0;
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(fireStore.collection('hotels').doc(data.hotel_id).collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityDatas)
                                });
                                lengthOfActivity++;
                            }
                        }
                    }
                }
                return MessageUtil.SUCCESS;
            }
        } else {
            if (!bookingDoc.exists) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            };

            t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
                'status': dataStatus
            });
            t.update(hotelRef.collection('bookings').doc(bookingId), {
                'status': dataStatus
            });
            activityData["id"] = bookingId;
            activityData["booking_id"] = bookingId;
            activityData['desc'] = bookingDoc.get('name') + NeutronUtil.specificChar + bookingDoc.get('creator') + NeutronUtil.specificChar + 'confirm';
        }

        if (hotelPackage !== HotelPackage.basic) {
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelDoc.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];
            if (isNewDocument) {
                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': [activityData],
                    'id': idDocument
                })
                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                }
            } else {
                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                    'activities': FieldValue.arrayUnion(activityData)
                })
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.getUsersInHotel = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const email = data.email;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);

    const rolesAllowed = NeutronUtil.rolesUserOfHotel;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const docs = (await fireStore.collection('users').where('email', "==", email).where('hotels', 'array-contains', hotelId).get()).docs;
    const result = !(docs === undefined || docs.length === 0);
    return result;
});