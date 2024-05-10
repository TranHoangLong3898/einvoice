import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { BookingStatus } from './constant/status';
import { HotelPackage } from './constant/type';
import { DateUtil } from "./util/dateutil";
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';
import { UserRole } from './constant/userrole';

const firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.createDeposit = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/deposits/{depositID}')
    .onCreate(async (doc, context) => {
        try {
            const res: boolean = await firestore.runTransaction(async (t) => {
                console.log(context.eventId);
                const deposit = doc.data();
                const idDeposit = doc.id;
                const hotelRef = doc.ref.parent.parent?.parent.parent;

                if (hotelRef === undefined || hotelRef === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
                }
                const hotelPackage = (await t.get(hotelRef)).get('package') ?? HotelPackage.basic;
                const bookingDoc = doc.ref.parent.parent;
                if (bookingDoc === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
                }
                let totalAllDepositsTransfer: number = 0;
                let sub_bookingsTransfer: { [key: string]: any } = {};
                let totalServiceChargeAndRoomChargeTransfer: number = 0;
                let isCheckBookingTransfer: boolean = false;
                let isCheckBooking: boolean = false;
                let isGroupTransfer: boolean = false;

                if ((await t.get(hotelRef.collection('basic_bookings').doc(deposit.bid))).exists) {
                    isCheckBooking = true;
                }
                const booking = await t.get(bookingDoc);
                const isGroup = booking.get("group");
                const deposits = booking.get("deposit") ?? 0;
                const transferring = booking.get("transferring") ?? 0;
                const totalAllDeposits = deposits + transferring + deposit.amount;
                const sub_bookings = isGroup ? booking.get("sub_bookings") : {};
                const totalServiceChargeAndRoomCharge =
                    NeutronUtil.getServiceChargeAndRoomCharge(booking, false);


                if (deposit.method === 'transfer') {
                    if ((await t.get(hotelRef.collection('basic_bookings').doc(deposit.transferred_bid))).exists) {
                        isCheckBookingTransfer = true;
                    }
                    const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(deposit.transferred_bid)));
                    const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                    const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                    isGroupTransfer = bookingTranfer.get("group");
                    totalAllDepositsTransfer = depositsTransfer + transferringTransfer;
                    sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                    totalServiceChargeAndRoomChargeTransfer =
                        NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false) + deposit.amount;

                }

                const now = new Date();
                const dateTime = NumberUtil.getRandomID();
                const dataUpdate: { [key: string]: any } = {};
                //id of activity document
                const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
                const idDocument = activityIdMap['idDocument'];
                const isNewDocument = activityIdMap['isNewDocument'];



                const createdServer: Date = deposit.created.toDate();
                const createTimezone = DateUtil.convertUpSetTimezone(createdServer, deposit.time_zone);
                const monthId = DateUtil.dateToShortStringYearMonth(createTimezone);
                const dayId = DateUtil.dateToShortStringDay(createTimezone);
                const documentDailyData = await t.get(hotelRef.collection('daily_data').doc(monthId));

                //content of activity
                const activityData = {
                    'email': deposit.modified_by,
                    'created_time': now,
                    'id': doc.id,
                    'booking_id': deposit.bid,
                    'type': 'deposit',
                    'desc': deposit.name + NeutronUtil.specificChar + deposit.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar +
                        'deposit' + NeutronUtil.specificChar + deposit.amount
                }

                if (hotelPackage !== HotelPackage.basic) {
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
                console.log("ID HOTEL:" + hotelRef.id);

                const dataRevenue: { [key: string]: any } = {};
                dataRevenue[deposit.method] = FieldValue.increment(deposit.amount);
                if (deposit.method === 'transfer') {
                    const transferredBID = deposit.transferred_bid;
                    const transferredID = deposit.transferred_id;

                    if (transferredBID === undefined || transferredID === undefined) {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED);
                    }

                    t.set(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID), {
                        'created': now,
                        'desc': 'Payment from ' + deposit.name + ' (' + deposit.room_name_from + ') ' + deposit.desc,
                        'amount': deposit.amount,
                        'hotel': deposit.hotel
                    });
                    dataUpdate['payment_details.' + idDeposit] = deposit.method + NeutronUtil.specificChar + deposit.amount + NeutronUtil.specificChar + dateTime;
                    dataUpdate['transferring'] = FieldValue.increment(deposit.amount);
                    t.update(hotelRef.collection('bookings').doc(deposit.bid),
                        dataUpdate);
                    t.update(hotelRef.collection('bookings').doc(transferredBID),
                        { 'transferred': FieldValue.increment(deposit.amount) });
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                } else {
                    dataUpdate['payment_details.' + idDeposit] = deposit.method + NeutronUtil.specificChar + deposit.amount + NeutronUtil.specificChar + dateTime;
                    dataUpdate['deposit'] = FieldValue.increment(deposit.amount);
                    dataUpdate['ota_deposit'] = FieldValue.increment(deposit.method === 'ota' ? deposit.amount : 0);
                    t.update(hotelRef.collection('bookings').doc(deposit.bid), dataUpdate);

                    if (!documentDailyData.exists) {
                        t.create(hotelRef.collection('daily_data').doc(monthId), { "data": {} });
                    }
                    const data: { [key: string]: any } = {};
                    data['data.' + dayId + '.deposit.' + deposit.method + '.' + deposit.source] = FieldValue.increment(deposit.amount);
                    t.update(hotelRef.collection('daily_data').doc(monthId), data);
                }
                if (deposit.method === 'ca' || deposit.method === 'cade') {
                    const cashLogId = NumberUtil.getRandomID();
                    t.create(hotelRef.collection('cash_logs_check').doc(cashLogId), {
                        'amount': deposit.amount, 'created': now, 'status': 'open', 'desc': `Add cash from payment ${deposit.name}`
                    });
                    t.update(hotelRef.collection('management').doc('reception_cash'), {
                        'total': FieldValue.increment(deposit.amount)
                    });
                }
                t.update(hotelRef.collection('management').doc('revenue'), dataRevenue);
                await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, deposit.bid, isCheckBooking);

                return true;
            })
            return res;
        } catch (e) {
            console.log(127);
            console.error(e);
            throw new functions.https.HttpsError("failed-precondition", MessageUtil.UNDEFINED_ERROR);
        }
    });

exports.updateDeposit = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/deposits/{depositID}')
    .onUpdate(async (change, context) => {
        try {
            const res = await firestore.runTransaction(async (t) => {
                const paymentAfterChange = change.after.data();
                const paymentBeforeChange = change.before.data();
                const idDeposit = change.after.id;
                const timezone = paymentBeforeChange.time_zone;
                const paymentChange = paymentAfterChange.amount - paymentBeforeChange.amount;
                const hotelRef = firestore.collection('hotels').doc(context.params.hotelID);
                if (hotelRef === undefined || hotelRef === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
                }
                const hotelPackage = (await t.get(hotelRef)).get('package') ?? HotelPackage.basic;
                const bookingRef = change.after.ref.parent.parent;
                const bookingRefBefore = change.before.ref.parent.parent;
                if (bookingRef === null || bookingRefBefore === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
                }
                const booking = await t.get(bookingRefBefore);
                ///khi có transfer
                let totalAllDepositsTransfer: number = 0;
                let sub_bookingsTransfer: { [key: string]: any } = {};
                let totalServiceChargeAndRoomChargeTransfer: number = 0;
                let isCheckBookingTransfer: boolean = false;
                let isGroupTransfer: boolean = false;
                ///khi có transfer cũ
                let totalAllDepositsTransferOld: number = 0;
                let sub_bookingsTransferOld: { [key: string]: any } = {};
                let totalServiceChargeAndRoomChargeTransferOld: number = 0;
                let isCheckBookingTransferOld: boolean = false;
                let isGroupTransferOld: boolean = false;
                let isCheckBooking: boolean = false;
                if ((await t.get(hotelRef.collection('basic_bookings').doc(booking.id))).exists) {
                    isCheckBooking = true;
                }
                const isGroup = booking.get("group");
                const deposits = booking.get("deposit") ?? 0;
                const transferring = booking.get("transferring") ?? 0;
                const totalAllDeposits = deposits + transferring + paymentChange;
                const sub_bookings: { [key: string]: any } = isGroup ? booking.get("sub_bookings") : {};
                const totalServiceChargeAndRoomCharge: number =
                    NeutronUtil.getServiceChargeAndRoomCharge(booking, false);


                ///tinh toán update status_payment of booking
                if (paymentBeforeChange.method === 'transfer' && paymentAfterChange.method === 'transfer') {
                    const transferredBID = paymentAfterChange.transferred_bid;
                    if ((await t.get(hotelRef.collection('basic_bookings').doc(transferredBID))).exists) {
                        isCheckBookingTransfer = true;
                    }
                    if (transferredBID === paymentBeforeChange.transferred_bid) {
                        const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(transferredBID)));
                        const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                        const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                        isGroupTransfer = bookingTranfer.get("group");
                        totalAllDepositsTransfer = depositsTransfer + transferringTransfer;
                        sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                        totalServiceChargeAndRoomChargeTransfer =
                            NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false) + (paymentChange ?? 0)
                    } else {
                        const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(transferredBID)));
                        const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                        const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                        isGroupTransfer = bookingTranfer.get("group");
                        totalAllDepositsTransfer = depositsTransfer + transferringTransfer;
                        sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                        totalServiceChargeAndRoomChargeTransfer =
                            NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false) + paymentAfterChange.amount;

                        if ((await t.get(hotelRef.collection('basic_bookings').doc(paymentBeforeChange.transferred_bid))).exists) {
                            isCheckBookingTransferOld = true;
                        }
                        const bookingTranferOld = (await t.get(hotelRef.collection('bookings').doc(paymentBeforeChange.transferred_bid)));
                        const depositsTransferOld = bookingTranferOld.get("deposit") ?? 0;
                        const transferringTransferOld = bookingTranferOld.get("transferring") ?? 0;
                        isGroupTransferOld = bookingTranferOld.get("group");
                        totalAllDepositsTransferOld = depositsTransferOld + transferringTransferOld;
                        sub_bookingsTransferOld = isGroupTransferOld ? bookingTranferOld.get("sub_bookings") : {};
                        totalServiceChargeAndRoomChargeTransferOld =
                            NeutronUtil.getServiceChargeAndRoomCharge(bookingTranferOld, false) - paymentBeforeChange.amount;
                    }
                } else if (paymentBeforeChange.method === 'transfer' && paymentAfterChange.method !== 'transfer') {
                    const transferredBID = paymentBeforeChange.transferred_bid;
                    if ((await t.get(hotelRef.collection('basic_bookings').doc(transferredBID))).exists) {
                        isCheckBookingTransfer = true;
                    }
                    const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(transferredBID)));
                    const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                    const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                    isGroupTransfer = bookingTranfer.get("group");
                    totalAllDepositsTransfer = depositsTransfer + transferringTransfer;
                    sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                    totalServiceChargeAndRoomChargeTransfer =
                        NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false) - paymentBeforeChange.amount;

                } else if (paymentBeforeChange.method !== 'transfer' && paymentAfterChange.method === 'transfer') {
                    const transferredBID = paymentAfterChange.transferred_bid;
                    if ((await t.get(hotelRef.collection('basic_bookings').doc(transferredBID))).exists) {
                        isCheckBookingTransfer = true;
                    }
                    const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(transferredBID)));
                    const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                    const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                    isGroupTransfer = bookingTranfer.get("group");
                    totalAllDepositsTransfer = depositsTransfer + transferringTransfer;
                    sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                    totalServiceChargeAndRoomChargeTransfer =
                        NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false) + paymentAfterChange.amount;
                }


                const now = new Date();
                const dateTime = NumberUtil.getRandomID();
                const dataPaymentUpdate: { [key: string]: any } = {};
                const dataRevenue: { [key: string]: any } = {};
                console.log("ID HOTEL:" + hotelRef.id);

                //id of activity document
                const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
                const idDocument = activityIdMap['idDocument'];
                const isNewDocument = activityIdMap['isNewDocument'];

                //description of activity
                let desc = paymentAfterChange.name + NeutronUtil.specificChar + (paymentAfterChange.room) + NeutronUtil.specificChar;
                const oldDesc = desc;

                if (paymentAfterChange.method !== paymentBeforeChange.method) {
                    desc += 'update' + NeutronUtil.specificChar + 'deposit_method' + NeutronUtil.specificChar + paymentBeforeChange.method + NeutronUtil.specificChar + paymentAfterChange.method + NeutronUtil.specificChar;
                }
                if (paymentAfterChange.amount !== paymentBeforeChange.amount) {
                    desc += 'update' + NeutronUtil.specificChar + 'deposit_amount' + NeutronUtil.specificChar + paymentBeforeChange.amount + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar;
                }
                if (paymentAfterChange.desc !== paymentBeforeChange.desc) {
                    desc += 'update' + NeutronUtil.specificChar + 'deposit_description';
                }

                if (oldDesc !== desc && hotelPackage !== HotelPackage.basic) {
                    const activityData = {
                        'email': paymentAfterChange.modified_by,
                        'created_time': now,
                        'id': change.before.id,
                        'booking_id': bookingRef.id,
                        'type': 'deposit',
                        'desc': desc
                    }
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

                if (paymentBeforeChange.method === 'transfer' && paymentAfterChange.method === 'transfer') {
                    const transferredBID = paymentAfterChange.transferred_bid;
                    const transferredID = paymentAfterChange.transferred_id;

                    if (transferredBID === undefined || transferredID === undefined) {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED);
                    }

                    if (transferredBID === paymentBeforeChange.transferred_bid) {
                        dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentChange);
                        t.update(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID), {
                            'desc': 'Payment from ' + paymentAfterChange.name + ' (' + paymentAfterChange.room_name_from + ') ' + paymentAfterChange.desc,
                            'amount': paymentAfterChange.amount,
                            'hotel': paymentAfterChange.hotel
                        });
                        if (paymentChange !== 0) {
                            dataPaymentUpdate['payment_details.' + idDeposit] = paymentAfterChange.method + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar + dateTime;
                            dataPaymentUpdate['transferring'] = FieldValue.increment(paymentChange);
                            t.update(hotelRef.collection('bookings').doc(paymentBeforeChange.bid),
                                dataPaymentUpdate);
                            t.update(hotelRef.collection('bookings').doc(transferredBID),
                                { 'transferred': FieldValue.increment(paymentChange) });
                        }
                        await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                    } else {
                        dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentChange);
                        t.delete(hotelRef.collection('bookings')
                            .doc(paymentBeforeChange.transferred_bid)
                            .collection('transfers')
                            .doc(paymentBeforeChange.transferred_id));

                        t.set(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID), {
                            'created': now,
                            'desc': 'Payment from ' + paymentAfterChange.name + ' (' + paymentAfterChange.room_name_from + ') ' + paymentAfterChange.desc,
                            'amount': paymentAfterChange.amount,
                            'hotel': paymentAfterChange.hotel
                        });
                        dataPaymentUpdate['payment_details.' + idDeposit] = paymentAfterChange.method + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar + dateTime;
                        dataPaymentUpdate['transferring'] = FieldValue.increment(paymentChange);
                        t.update(hotelRef.collection('bookings').doc(paymentBeforeChange.bid),
                            dataPaymentUpdate);
                        t.update(hotelRef.collection('bookings').doc(paymentBeforeChange.transferred_bid),
                            { 'transferred': FieldValue.increment(-paymentBeforeChange.amount) });
                        t.update(hotelRef.collection('bookings').doc(paymentAfterChange.transferred_bid),
                            { 'transferred': FieldValue.increment(paymentAfterChange.amount) });
                        await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                        await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransferOld, totalAllDepositsTransferOld, totalServiceChargeAndRoomChargeTransferOld, sub_bookingsTransferOld, paymentBeforeChange.transferred_bid, isCheckBookingTransferOld);
                    }
                } else if (paymentBeforeChange.method === 'transfer' && paymentAfterChange.method !== 'transfer') {
                    const transferredBID = paymentBeforeChange.transferred_bid;
                    const transferredID = paymentBeforeChange.transferred_id;
                    dataRevenue[paymentBeforeChange.method] = FieldValue.increment(-paymentBeforeChange.amount);
                    dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentAfterChange.amount);
                    if (transferredBID === undefined || transferredID === undefined) {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED);
                    }

                    t.delete(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID));
                    dataPaymentUpdate['payment_details.' + idDeposit] = paymentAfterChange.method + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar + dateTime;
                    dataPaymentUpdate['transferring'] = FieldValue.increment(-paymentBeforeChange.amount);
                    dataPaymentUpdate['deposit'] = FieldValue.increment(paymentAfterChange.amount);
                    dataPaymentUpdate['ota_deposit'] = FieldValue.increment(paymentAfterChange.method === 'ota' ? paymentAfterChange.amount : 0);
                    t.update(hotelRef.collection('bookings').doc(paymentBeforeChange.bid), dataPaymentUpdate);
                    t.update(hotelRef.collection('bookings').doc(transferredBID),
                        { 'transferred': FieldValue.increment(-paymentBeforeChange.amount) });

                    const createdServe = paymentBeforeChange.created.toDate();
                    const createdTimezone = DateUtil.convertUpSetTimezone(createdServe, timezone);
                    const monthId = DateUtil.dateToShortStringYearMonth(createdTimezone);
                    const dayId = DateUtil.dateToShortStringDay(createdTimezone);
                    const data: { [key: string]: any } = {};
                    data['data.' + dayId + '.deposit.' + paymentAfterChange.method + '.' + paymentAfterChange.source] = FieldValue.increment(paymentAfterChange.amount);
                    t.update(hotelRef.collection('daily_data').doc(monthId), data);
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                } else if (paymentBeforeChange.method !== 'transfer' && paymentAfterChange.method === 'transfer') {
                    const transferredBID = paymentAfterChange.transferred_bid;
                    const transferredID = paymentAfterChange.transferred_id;
                    dataRevenue[paymentBeforeChange.method] = FieldValue.increment(-paymentBeforeChange.amount);
                    dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentAfterChange.amount);
                    if (transferredBID === undefined || transferredID === undefined) {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED);
                    }

                    t.set(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID), {
                        'created': now,
                        'desc': 'Payment from ' + paymentAfterChange.name + ' (' + paymentAfterChange.room_name_from + ') ' + paymentAfterChange.desc,
                        'amount': paymentAfterChange.amount,
                        'hotel': paymentAfterChange.hotel
                    });
                    dataPaymentUpdate['payment_details.' + idDeposit] = paymentAfterChange.method + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar + dateTime;
                    dataPaymentUpdate['transferring'] = FieldValue.increment(paymentAfterChange.amount);
                    dataPaymentUpdate['deposit'] = FieldValue.increment(-paymentBeforeChange.amount);
                    dataPaymentUpdate['ota_deposit'] = FieldValue.increment(paymentBeforeChange.method === 'ota' ? -paymentBeforeChange.amount : 0);
                    t.update(hotelRef.collection('bookings').doc(paymentAfterChange.bid), dataPaymentUpdate);
                    t.update(hotelRef.collection('bookings').doc(transferredBID),
                        { 'transferred': FieldValue.increment(paymentAfterChange.amount) });

                    const createdServe = paymentBeforeChange.created.toDate();
                    const createTimezone = DateUtil.convertUpSetTimezone(createdServe, timezone);
                    const monthId = DateUtil.dateToShortStringYearMonth(createTimezone);
                    const dayId = DateUtil.dateToShortStringDay(createTimezone);
                    const data: { [key: string]: any } = {};
                    data['data.' + dayId + '.deposit.' + paymentBeforeChange.method + '.' + paymentBeforeChange.source] = FieldValue.increment(-paymentBeforeChange.amount);
                    t.update(hotelRef.collection('daily_data').doc(monthId), data);
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                } else {
                    if (paymentChange !== 0 || paymentAfterChange.method !== paymentBeforeChange.method || paymentBeforeChange.source !== paymentAfterChange.source) {
                        dataPaymentUpdate['payment_details.' + idDeposit] = paymentAfterChange.method + NeutronUtil.specificChar + paymentAfterChange.amount + NeutronUtil.specificChar + dateTime;
                        dataPaymentUpdate['deposit'] = FieldValue.increment(paymentChange);
                        dataPaymentUpdate['method'] = paymentAfterChange.method;
                        dataPaymentUpdate['ota_deposit'] = FieldValue.increment(paymentAfterChange.method === 'ota' ? paymentChange : 0);
                        if (paymentChange !== 0 || paymentAfterChange.method !== paymentBeforeChange.method)
                            t.update(hotelRef.collection('bookings').doc(paymentBeforeChange.bid), dataPaymentUpdate);
                        if (paymentAfterChange.method !== paymentBeforeChange.method) {
                            if (paymentAfterChange.amount == paymentBeforeChange.amount) {
                                dataRevenue[paymentBeforeChange.method] = FieldValue.increment(-paymentAfterChange.amount);
                                dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentAfterChange.amount);
                            } else {
                                dataRevenue[paymentBeforeChange.method] = FieldValue.increment(-paymentBeforeChange.amount);
                                dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentAfterChange.amount);
                            }
                        } else {
                            dataRevenue[paymentAfterChange.method] = FieldValue.increment(paymentChange);
                        }
                        const createdBeforeServe = paymentBeforeChange.created.toDate();
                        const createdBeforeTimezone = DateUtil.convertUpSetTimezone(createdBeforeServe, timezone);
                        const monthIdBefore = DateUtil.dateToShortStringYearMonth(createdBeforeTimezone);
                        const dayIdBefore = DateUtil.dateToShortStringDay(createdBeforeTimezone);

                        const dataUpdate: { [key: string]: any } = {};
                        if (paymentAfterChange.method !== paymentBeforeChange.method || paymentBeforeChange.source !== paymentAfterChange.source) {
                            dataUpdate['data.' + dayIdBefore + '.deposit.' + paymentBeforeChange.method + '.' + paymentBeforeChange.source] = FieldValue.increment(-paymentBeforeChange.amount);
                            dataUpdate['data.' + dayIdBefore + '.deposit.' + paymentAfterChange.method + '.' + paymentAfterChange.source] = FieldValue.increment(paymentAfterChange.amount);
                        } else {
                            dataUpdate['data.' + dayIdBefore + '.deposit.' + paymentAfterChange.method + '.' + paymentAfterChange.source] = FieldValue.increment(paymentChange);
                        }
                        t.update(hotelRef.collection('daily_data').doc(monthIdBefore), dataUpdate);
                    }
                }

                if ((paymentBeforeChange.method === 'ca' && paymentAfterChange.method !== 'ca') || (paymentBeforeChange.method === 'cade' && paymentAfterChange.method !== 'cade')) {
                    const cashLogId = NumberUtil.getRandomID();
                    t.create(hotelRef.collection('cash_logs_check').doc(cashLogId), {
                        'amount': -paymentBeforeChange.amount, 'created': now, 'status': 'open', 'desc': `Delete cash from payment ${paymentBeforeChange.name}`
                    });
                    t.update(hotelRef.collection('management').doc('reception_cash'), {
                        'total': FieldValue.increment(-paymentBeforeChange.amount)
                    });
                } else if ((paymentBeforeChange.method !== 'ca' && paymentAfterChange.method === 'ca') || (paymentBeforeChange.method !== 'cade' && paymentAfterChange.method === 'cade')) {
                    const cashLogId = NumberUtil.getRandomID();
                    t.create(hotelRef.collection('cash_logs_check').doc(cashLogId), {
                        'amount': paymentAfterChange.amount, 'created': now, 'status': 'open', 'desc': `Add cash from payment ${paymentBeforeChange.name}`
                    });
                    t.update(hotelRef.collection('management').doc('reception_cash'), {
                        'total': FieldValue.increment(paymentAfterChange.amount)
                    });
                } else if ((paymentBeforeChange.method === 'ca' && paymentAfterChange.method === 'ca') || (paymentBeforeChange.method === 'cade' && paymentAfterChange.method === 'cade')) {
                    const cashLogId = NumberUtil.getRandomID();
                    t.create(hotelRef.collection('cash_logs_check').doc(cashLogId), {
                        'amount': paymentChange, 'created': now, 'status': 'open', 'desc': `Update cash from payment ${paymentBeforeChange.name}`
                    });
                    t.update(hotelRef.collection('management').doc('reception_cash'), {
                        'total': FieldValue.increment(paymentChange)
                    });
                }
                t.update(hotelRef.collection('management').doc('revenue'), dataRevenue);
                await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, booking.id, isCheckBooking);
            });
            return res;
        } catch (e) {
            console.error(e);
            throw new functions.https.HttpsError("failed-precondition", MessageUtil.UNDEFINED_ERROR);
        }
    });

exports.deleteDeposit = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/deposits/{depositID}')
    .onDelete(async (doc, context) => {
        try {
            const res = await firestore.runTransaction(async (t) => {
                const deposit = doc.data();
                const idDeposit = doc.id;
                const hotelRef = doc.ref.parent.parent?.parent.parent;
                if (hotelRef === undefined || hotelRef === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
                }
                const bookingRef = doc.ref.parent.parent;
                if (bookingRef === null) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
                }

                let totalAllDepositsTransfer: number = 0;
                let sub_bookingsTransfer: { [key: string]: any } = {};
                let totalServiceChargeAndRoomChargeTransfer: number = 0;
                let isCheckBookingTransfer: boolean = false;
                let isGroupTransfer: boolean = false;
                let isCheckBooking: boolean = false;

                if ((await t.get(hotelRef.collection('basic_bookings').doc(deposit.bid))).exists) {
                    isCheckBooking = true;
                }
                const booking = await t.get(bookingRef);
                const isGroup = booking.get("group");
                const deposits = booking.get("deposit") ?? 0;
                const transferring = booking.get("transferring") ?? 0;
                const totalAllDeposits = deposits + transferring - (deposit.amount ?? 0);
                const sub_bookings: { [key: string]: any } = isGroup ? booking.get("sub_bookings") : {};
                const totalServiceChargeAndRoomCharge: number =
                    NeutronUtil.getServiceChargeAndRoomCharge(booking, false);

                if (deposit.method === 'transfer') {
                    if ((await t.get(hotelRef.collection('basic_bookings').doc(deposit.transferred_bid))).exists) {
                        isCheckBookingTransfer = true;
                    }
                    const bookingTranfer = (await t.get(hotelRef.collection('bookings').doc(deposit.transferred_bid)));
                    const depositsTransfer = bookingTranfer.get("deposit") ?? 0;
                    const transferringTransfer = bookingTranfer.get("transferring") ?? 0;
                    isGroupTransfer = bookingTranfer.get("group");
                    totalAllDepositsTransfer = depositsTransfer + transferringTransfer + deposit.amount;
                    sub_bookingsTransfer = isGroupTransfer ? bookingTranfer.get("sub_bookings") : {};
                    totalServiceChargeAndRoomChargeTransfer =
                        NeutronUtil.getServiceChargeAndRoomCharge(bookingTranfer, false);
                }

                const hotelPackage = (await t.get(hotelRef)).get('package') ?? HotelPackage.basic;
                const now = new Date();
                const dataUpdate: { [key: string]: any } = {};
                const dataRevenue: { [key: string]: any } = {};

                //id of activity document
                const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
                const idDocument = activityIdMap['idDocument'];
                const isNewDocument = activityIdMap['isNewDocument'];

                const activityData = {
                    'email': deposit.modified_by,
                    'created_time': now,
                    'type': 'deposit',
                    'desc': deposit.name + NeutronUtil.specificChar + deposit.room + NeutronUtil.specificChar + 'delete' + NeutronUtil.specificChar + 'deposit'
                }
                if (hotelPackage !== HotelPackage.basic) {
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

                console.log("ID HOTEL:" + hotelRef.id);
                dataRevenue[deposit.method] = FieldValue.increment(-deposit.amount);
                if (deposit.method === 'transfer') {
                    const transferredBID = deposit.transferred_bid;
                    const transferredID = deposit.transferred_id;
                    if (transferredBID === undefined || transferredID === undefined) {
                        throw new functions.https.HttpsError("invalid-argument", MessageUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED);
                    }
                    dataUpdate['payment_details.' + idDeposit] = FieldValue.delete();
                    dataUpdate['transferring'] = FieldValue.increment(-deposit.amount);
                    t.update(hotelRef.collection('bookings').doc(deposit.bid),
                        dataUpdate);

                    t.update(hotelRef.collection('bookings').doc(transferredBID), {
                        'transferred': FieldValue.increment(-deposit.amount)
                    });
                    t.delete(hotelRef.collection('bookings').doc(transferredBID).collection('transfers').doc(transferredID));
                    await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroupTransfer, totalAllDepositsTransfer, totalServiceChargeAndRoomChargeTransfer, sub_bookingsTransfer, transferredBID, isCheckBookingTransfer);
                } else {

                    dataUpdate['payment_details.' + idDeposit] = FieldValue.delete();
                    dataUpdate['deposit'] = FieldValue.increment(-deposit.amount);
                    dataUpdate['ota_deposit'] = FieldValue.increment(deposit.method === 'ota' ? -deposit.amount : 0);
                    t.update(hotelRef.collection('bookings').doc(deposit.bid), dataUpdate);
                    // if (hotelRef.id === 'GzmJUslMKbfqw25shKLJ') {
                    //     console.log('delete directly here');
                    //     batch.update(hotelRef.collection('bookings').doc(deposit.bid), {
                    //         'deposit': FieldValue.increment(-deposit.amount),
                    //         'ota_deposit': FieldValue.increment(deposit.method === 'ota' ? -deposit.amount : 0)
                    //     });
                    // } else {
                    //     if (deposit.method === 'ota') {
                    //         const isAllowDeleted: boolean = deposit.allow_deleted ?? true;

                    //         if (isAllowDeleted) {
                    //             batch.update(hotelRef.collection('bookings').doc(deposit.bid), {
                    //                 'deposit': FieldValue.increment(-deposit.amount),
                    //                 'ota_deposit': FieldValue.increment(deposit.method === 'ota' ? -deposit.amount : 0)
                    //             });
                    //         }
                    //     } else {
                    //         batch.update(hotelRef.collection('bookings').doc(deposit.bid), {
                    //             'deposit': FieldValue.increment(-deposit.amount)
                    //         });
                    //     }
                    // }

                    const createdServe = deposit.created.toDate();
                    const createTimezone = DateUtil.convertUpSetTimezone(createdServe, deposit.time_zone);
                    const monthId = DateUtil.dateToShortStringYearMonth(createTimezone);
                    const dayId = DateUtil.dateToShortStringDay(createTimezone);
                    const data: { [key: string]: any } = {};
                    data['data.' + dayId + '.deposit.' + deposit.method + '.' + deposit.source] = FieldValue.increment(-deposit.amount);
                    t.update(hotelRef.collection('daily_data').doc(monthId), data);
                }

                if (deposit.method === 'ca' || deposit.method === 'cade') {
                    const cashLogId = NumberUtil.getRandomID();
                    t.create(hotelRef.collection('cash_logs_check').doc(cashLogId), {
                        'amount': -deposit.amount, 'created': now, 'status': 'open', 'desc': `Delete cash from payment ${deposit.name}`
                    });
                    t.update(hotelRef.collection('management').doc('reception_cash'), {
                        'total': FieldValue.increment(-deposit.amount)
                    });
                }
                t.update(hotelRef.collection('management').doc('revenue'), dataRevenue);
                await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, deposit.bid, isCheckBooking);
                return true;
            });
            return res;
        } catch {
            console.log("Booking was be deleted");
        }
        return true;
    });

exports.addBookingPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const dataHotelId = data.hotel_id;
    const dataBookingId = data.booking_id;
    const dataPaymentAmount = data.payment_amount;
    const dataPaymentMethod = data.payment_method;
    let dataPaymentDesc: string = data.payment_desc;
    const dataPaymentTransferBid = data.payment_transfer_bid;
    const dataPaymentStatus = data.payment_status;
    const dataPaymentGroup: boolean = data.payment_group;
    const dataBookingSID = data.sid;
    const dataNameRoomTransferTo: string = data.room_name_to;
    const dataNameRoomTransferFrom: string = data.room_name_from;
    const actualAmount = data.payment_actual_amount;
    const note: string = data.payment_note;
    const referenceNumber: string = data.payment_reference_number;

    let dataPaymentCreatedTime = new Date();
    const uidOfUser = context.auth.uid;

    const rolesAllowed = NeutronUtil.rolesAddOrUpdatePayment;
    const hotelRef = firestore.collection('hotels').doc(dataHotelId);
    const hotelDoc = await hotelRef.get();
    const timezone = hotelDoc.get('timezone');
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = firestore.runTransaction(async (t) => {
        let bookingRef;
        if (dataPaymentGroup) {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingSID);
        } else {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingId);
        }
        const bookingDoc = await t.get(bookingRef);
        const booking = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        const bookingOtaDeposit = booking.ota_deposit;
        const inDayBookingServer: Date = booking.in_date.toDate();
        const outDayBookingServer: Date = booking.out_date.toDate();
        const bookingSourceID = booking.source;
        const bookingSid = booking.sid;
        const bookingName = booking.name;

        if (dataPaymentGroup) {
            const subBookings = booking.sub_bookings;
            let isAllBookingIsCheckOut = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.checkout || subBookings[idBooking]['status'] === BookingStatus.noshow) continue;
                if ([BookingStatus.checkin, BookingStatus.booked, BookingStatus.unconfirmed].includes(subBookings[idBooking]['status'])) {
                    isAllBookingIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingIsCheckOut) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        } else {
            const bookingStatus = booking.status;
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin && bookingStatus !== BookingStatus.unconfirmed) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        }

        if (dataPaymentMethod === 'ota' && bookingOtaDeposit > 0) {
            throw MessageUtil.BOOKING_ALREADY_EXIST_OTA;
        }
        if (dataPaymentMethod === 'transfer') {
            if (dataPaymentTransferBid === undefined || dataPaymentTransferBid === null) {
                throw MessageUtil.BOOKING_WRONG_TRANSFERRED;
            }

            const transferredDoc = await t.get(hotelRef.collection('bookings').doc(dataPaymentTransferBid));
            const isTransferredDocGroup: boolean = transferredDoc.get('group');
            if (isTransferredDocGroup) {
                const subBookingsTransferred: { [key: string]: any } = transferredDoc.get('sub_bookings');
                let isTransferredCheckout = true;
                for (const idBooking in subBookingsTransferred) {
                    if (subBookingsTransferred[idBooking]['status'] === BookingStatus.cancel || subBookingsTransferred[idBooking]['status'] === BookingStatus.checkout || subBookingsTransferred[idBooking]['status'] === BookingStatus.noshow) continue;
                    if ([BookingStatus.checkin, BookingStatus.booked, BookingStatus.unconfirmed].includes(subBookingsTransferred[idBooking]['status'])) {
                        isTransferredCheckout = false;
                        break;
                    }
                }
                if (isTransferredCheckout) {
                    throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
                }
                dataPaymentDesc = 'transferred to ' + transferredDoc.get('name') + ' (group): ' + dataPaymentDesc;
            } else {
                const statusOfTransferredDoc = transferredDoc.get('status');
                if (statusOfTransferredDoc === undefined || (transferredDoc.get('status') !== BookingStatus.booked && transferredDoc.get('status') !== BookingStatus.checkin) && transferredDoc.get('status') !== BookingStatus.unconfirmed) {
                    throw MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT;
                }
                dataPaymentDesc = 'transferred to ' + transferredDoc.get('name') + ' (' + dataNameRoomTransferTo + '): ' + dataPaymentDesc;
            }
        }

        if (dataPaymentMethod === 'ota') {
            dataPaymentCreatedTime = outDayBookingServer;
        }
        const dataPaymentSourceID = data.payment_source_id ?? bookingSourceID;

        const dataUpdate: { [key: string]: any } = {
            'hotel': dataHotelId,
            'modified_by': context.auth?.token.email,
            'created': dataPaymentCreatedTime,
            'desc': dataPaymentDesc,
            'amount': dataPaymentAmount,
            'method': dataPaymentMethod,
            'source': dataPaymentSourceID,
            'status': dataPaymentStatus,
            'bid': dataPaymentGroup ? bookingSid : dataBookingId,
            'sid': bookingSid,
            'name': bookingName,
            'in': inDayBookingServer,
            'room': dataPaymentGroup ? 'group' : booking.room,
            'out': outDayBookingServer,
            'actual_amount': actualAmount ?? 0,
            'note': note ?? "",
            'reference_number': referenceNumber ?? "",
            'time_zone': timezone
        };

        if (data.payment_referenc_date != undefined) {
            dataUpdate['reference_date'] = new Date(data.payment_referenc_date);
        }
        if (dataPaymentMethod === 'transfer') {
            dataUpdate['transferred_bid'] = dataPaymentTransferBid;
            dataUpdate['transferred_id'] = NumberUtil.getRandomID();
            dataUpdate['room_name_from'] = dataNameRoomTransferFrom;
        }

        t.set(bookingRef.collection('deposits').doc(NumberUtil.getRandomID()), dataUpdate);
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError('not-found', error);
    })
    return res;
})

exports.updateBookingPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const dataHotelID = data.hotel_id;
    const dataBookingID = data.booking_id;
    const dataBookingSID = data.sid;
    const dataPaymentID = data.payment_id;
    const dataPaymentAmount = data.payment_amount;
    const dataPaymentMethod = data.payment_method;
    const dataPaymentTransferBID = data.payment_transfer_bid;
    let dataPaymentDesc: string = data.payment_desc;
    const dataNameRoomTransferTo: string = data.room_name_to;
    const dataNameRoomTransferFrom: string = data.room_name_from;
    const dataPaymentGroup: boolean = data.payment_group;
    const actualAmount = data.payment_actual_amount;
    const note: string = data.payment_note;
    const referenceNumber: string = data.payment_reference_number;
    const uidOfUser = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesAddOrUpdatePayment;
    const hotelRef = firestore.collection('hotels').doc(dataHotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = firestore.runTransaction(async (t) => {
        let bookingRef;
        if (dataPaymentGroup) {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingSID);
        } else {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingID);
        }
        const bookingDoc = await t.get(bookingRef);
        const booking = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        if (dataPaymentGroup) {
            const subBookings = booking.sub_bookings;
            let isAllBookingIsCheckOut = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.checkout || subBookings[idBooking]['status'] === BookingStatus.noshow) continue;
                if ([BookingStatus.checkin, BookingStatus.booked, BookingStatus.unconfirmed].includes(subBookings[idBooking]['status'])) {
                    isAllBookingIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingIsCheckOut) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        } else {
            const bookingStatus = booking.status;
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin && bookingStatus !== BookingStatus.unconfirmed) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        }

        const paymentDoc = await t.get(bookingRef.collection('deposits').doc(dataPaymentID));

        if (!paymentDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.PAYMENT_NOT_FOUND);
        }

        if (paymentDoc.get('modified_by') != context.auth?.token.email &&
            roleOfUser.includes(UserRole.internalPartner)) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.YOU_DO_NOT_UPDATE_OTHER_PEOPLE_PAYMENT);
        }

        if (paymentDoc.get('status') === "passed" && roleOfUser.some((role) => role == UserRole.accountant)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED);
        }


        const bookingOtaDeposit = booking.ota_deposit;

        if (dataPaymentMethod === 'ota' && paymentDoc.get('method') !== 'ota' && bookingOtaDeposit > 0) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_ALREADY_EXIST_OTA);
        }

        const dataUpdate: { [key: string]: any } = {
            'amount': dataPaymentAmount,
            'modified_by': context.auth?.token.email,
            'method': dataPaymentMethod,
            'actual_amount': actualAmount ?? 0,
            'note': note ?? "",
            'reference_number': referenceNumber ?? "",
        };

        if (data.payment_referenc_date != undefined) {
            dataUpdate['reference_date'] = new Date(data.payment_referenc_date);
        }

        if (dataPaymentMethod === 'transfer') {
            if (dataPaymentTransferBID === undefined) {
                throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_WRONG_TRANSFERRED);
            }
            dataUpdate['transferred_bid'] = dataPaymentTransferBID;
            dataUpdate['room_name_from'] = dataNameRoomTransferFrom;
            const transferredDoc = await t.get(hotelRef.collection('bookings').doc(dataPaymentTransferBID));
            const statusOfTransferredDoc = transferredDoc.get('status');
            if (statusOfTransferredDoc === undefined || (transferredDoc.get('status') !== BookingStatus.booked && transferredDoc.get('status') !== BookingStatus.checkin) && transferredDoc.get('status') !== BookingStatus.unconfirmed) {
                throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
            if (paymentDoc.get('transferred_bid') !== dataPaymentTransferBID) {
                dataPaymentDesc = 'transferred to ' + transferredDoc.get('name') + ' (' + dataNameRoomTransferTo + '): ' + dataPaymentAmount;
            } else {
                if (dataPaymentDesc.startsWith('transferred to')) {
                    dataPaymentDesc = 'transferred to ' + transferredDoc.get('name') + ' (' + dataNameRoomTransferTo + '): ' + dataPaymentAmount;
                } else {
                    dataPaymentDesc = 'transferred to ' + transferredDoc.get('name') + ' (' + dataNameRoomTransferTo + '): ' + dataPaymentDesc;
                }
            }
            if (paymentDoc.get('transferred_id') === undefined) {
                dataUpdate['transferred_id'] = NumberUtil.getRandomID();
            }
        }

        dataUpdate['desc'] = dataPaymentDesc;

        if (dataPaymentMethod === 'ota') {
            const outDayBookingServer: Date = booking.out_date.toDate();
            dataUpdate['created'] = outDayBookingServer;
        }

        t.update(bookingRef.collection('deposits').doc(dataPaymentID), dataUpdate);
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError('cancelled', error.message);
    })
    return res;
});

exports.deleteBookingPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const dataHotelID = data.hotel_id;
    const dataBookingID = data.booking_id;
    const dataPaymentID = data.payment_id;
    const dataPaymentGroup: boolean = data.payment_group;
    const dataBookingSID = data.sid;

    const uidOfUser = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesDeleteOrPayment;
    const hotelRef = firestore.collection('hotels').doc(dataHotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = firestore.runTransaction(async (t) => {
        let bookingRef;
        if (dataPaymentGroup) {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingSID);
        } else {
            bookingRef = hotelRef.collection('bookings').doc(dataBookingID);
        }
        const paymentDoc = await t.get(bookingRef.collection('deposits').doc(dataPaymentID));
        const bookingDoc = await t.get(bookingRef);
        const booking = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }

        if (paymentDoc.get('modified_by') != context.auth?.token.email &&
            roleOfUser.includes(UserRole.internalPartner)) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.YOU_DO_NOT_DELETE_OTHER_PEOPLE_PAYMENT);
        }

        if (paymentDoc.get('status') === "passed" && roleOfUser.some((role) => role == UserRole.accountant)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED);
        }

        if (dataPaymentGroup) {
            const subBookings = booking.sub_bookings;
            let isAllBookingIsCheckOut = true;
            for (const idBooking in subBookings) {
                if (subBookings[idBooking]['status'] === BookingStatus.cancel || subBookings[idBooking]['status'] === BookingStatus.checkout || subBookings[idBooking]['status'] === BookingStatus.noshow) continue;
                if ([BookingStatus.checkin, BookingStatus.booked, BookingStatus.unconfirmed].includes(subBookings[idBooking]['status'])) {
                    isAllBookingIsCheckOut = false;
                    break;
                }
            }
            if (isAllBookingIsCheckOut) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        } else {
            const bookingStatus = booking.status;
            if (bookingStatus !== BookingStatus.booked && bookingStatus !== BookingStatus.checkin && bookingStatus !== BookingStatus.unconfirmed) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT);
            }
        }

        t.delete(bookingRef.collection('deposits').doc(dataPaymentID));
        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError('not-found', error.message);
    })
    return res;
});

exports.updateStatusPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const bookingID: string = data.booking_id;
    const dataPaymentID: string = data.payment_id;
    const status: string = data.status;
    const uidOfUser = context.auth.uid;

    const rolesAllowed = NeutronUtil.rolesUpdateStatusPayment;
    const hotelRef = firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();

    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const paymentDoc = await hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(dataPaymentID).get();
    if (paymentDoc.get('status') === "passed" && roleOfUser.some((role) => role == UserRole.accountant)) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED);
    }
    try {
        await hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(dataPaymentID).update({ 'status': status });
        return MessageUtil.SUCCESS
    } catch (error) {
        console.log(error);
        throw new functions.https.HttpsError('permission-denied', MessageUtil.UNDEFINED_ERROR);
    }
});


exports.updateConfirmMoneyPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const bookingID: string = data.booking_id;
    const dataPaymentID: string = data.payment_id;
    const confirmDate: Date = new Date(data.confirm_date);
    const uidOfUser = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesUpdateStatusPayment;
    const hotelRef = firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();

    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    try {
        await hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(dataPaymentID).update({ 'confirm_date': confirmDate });
        return MessageUtil.SUCCESS
    } catch (error) {
        console.log(error);
        throw new functions.https.HttpsError('permission-denied', MessageUtil.UNDEFINED_ERROR);
    }
});


exports.updatePaymentManager = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const bookingID: string = data.booking_id;
    const dataPaymentID: string = data.payment_id;
    const dataPaymentAmount = data.payment_amount;
    const dataPaymentMethod = data.payment_method;
    let dataPaymentDesc: string = data.payment_desc;
    const actualAmount = data.payment_actual_amount;
    const note: string = data.payment_note;
    const referenceNumber: string = data.payment_reference_number;
    const uidOfUser = context.auth.uid;

    const rolesAllowed = NeutronUtil.rolesUpdateStatusPayment;
    const hotelRef = firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();

    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = firestore.runTransaction(async (t) => {
        const paymentDoc = await t.get(hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(dataPaymentID));
        const dataUpdate: { [key: string]: any } = {
            'actual_amount': actualAmount,
            'note': note,
            'reference_number': referenceNumber,
        }
        if (paymentDoc.get('method') == "de") {
            dataUpdate['desc'] = dataPaymentDesc;
            dataUpdate['amount'] = dataPaymentAmount;
            dataUpdate['method'] = dataPaymentMethod;
            dataUpdate['created'] = new Date();
        }
        if (data.payment_referenc_date != undefined) {
            dataUpdate['reference_date'] = new Date(data.payment_referenc_date);
        }
        try {
            t.update(hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(dataPaymentID), dataUpdate);
            return MessageUtil.SUCCESS
        } catch (error) {
            console.log(error);
            throw new functions.https.HttpsError('permission-denied', MessageUtil.UNDEFINED_ERROR);
        }
    });
    return res;
});

// exports.asyncPayment = functions.https.onCall(async (data, context) => {
//     const hotelID = data.hotel_id;
//     const startDayTimezone: Date = new Date(data.start_date);
//     const endDayTimezone: Date = new Date(data.end_date);
//     console.log(startDayTimezone);
//     console.log(endDayTimezone);
//     const hotelDoc = await firestore.collection('hotels').doc(hotelID).get();
//     const timezone = hotelDoc.get('timezone');
//     // const startDayServer: Date = DateUtil.convertOffSetTimezone(startDayTimezone, timezone);
//     // const endDayServer: Date = DateUtil.convertOffSetTimezone(endDayTimezone, timezone);
//     // const bookingDocs = await admin.firestore().collection('hotels').doc(hotelID).collection('bookings').where('in_date', '>=', startDayServer).where('in_date', '<=', endDayServer).get();
//     const bookingDocs = await admin.firestore().collection('hotels').doc(hotelID).collection('bookings').where('in_date', '>=', startDayTimezone).where('in_date', '<=', endDayTimezone).get();
//     console.log(bookingDocs.size);
//     const batchArray: FirebaseFirestore.WriteBatch[] = [];
//     let batchIndex: number = 0;
//     let operationCounter: number = 0;
//     batchArray.push(firestore.batch());

//     if (!bookingDocs.empty) {
//         for (const booking of bookingDocs.docs) {
//             if (booking.get('room') === 'virtual') continue;
//             if (![BookingStatus.checkin, BookingStatus.checkout, BookingStatus.booked].includes(booking.get('status'))) {
//                 continue;
//             }
//             if (booking.get('group')) {
//                 const paymentDocs = await hotelDoc.ref.collection('bookings').doc(booking.id).collection('deposits').get();
//                 if (!paymentDocs.empty && booking.get('deposit') === undefined) {
//                     console.log('Have booking group lose payment: ' + booking.get('name') + ' - ' + booking.id);
//                     for (const deposit of paymentDocs.docs) {

//                         const dataPayment: { [key: string]: any } = {
//                             'deposit': FieldValue.increment(deposit.get('amount')),
//                         }
//                         dataPayment['ota_deposit'] = FieldValue.increment(deposit.get('method') === 'ota' ? deposit.get('amount') : 0)
//                         batchArray[batchIndex].update(hotelDoc.ref.collection('bookings').doc(booking.id), dataPayment)
//                         operationCounter++;
//                         if (operationCounter === 499) {
//                             batchArray.push(firestore.batch());
//                             batchIndex++;
//                             operationCounter = 0;
//                         }

//                         const createdServer: Date = deposit.get('created').toDate();
//                         const createTimezone = DateUtil.convertUpSetTimezone(createdServer, timezone);
//                         const monthId = DateUtil.dateToShortStringYearMonth(createTimezone);
//                         const dayId = DateUtil.dateToShortStringDay(createTimezone);
//                         const data: { [key: string]: any } = {};
//                         data['data.' + dayId + '.deposit.' + deposit.get('method') + '.' + deposit.get('source')] = FieldValue.increment(deposit.get('amount'));
//                         batchArray[batchIndex].update(hotelDoc.ref.collection('daily_data').doc(monthId), data);
//                         operationCounter++;
//                         if (operationCounter === 499) {
//                             batchArray.push(firestore.batch());
//                             batchIndex++;
//                             operationCounter = 0;
//                         }

//                     }
//                 };
//                 // }
//                 //     batchArray[batchIndex].set(hotelDoc.ref.collection('groups_data').doc(booking.id), booking.data());
//                 //     operationCounter++;
//                 //     if (operationCounter === 499) {
//                 //         batchArray.push(firestore.batch());
//                 //         batchIndex++;
//                 //         operationCounter = 0;
//                 //     }
//             } else {
//                 const paymentDocs = await hotelDoc.ref.collection('bookings').doc(booking.id).collection('deposits').get();
//                 if (!paymentDocs.empty && booking.get('deposit') === undefined) {
//                     console.log('Have booking single lose payment: ' + booking.get('name') + ' - ' + booking.id);
//                     for (const deposit of paymentDocs.docs) {

//                         const dataPayment: { [key: string]: any } = {
//                             'deposit': FieldValue.increment(deposit.get('amount')),
//                         }
//                         dataPayment['ota_deposit'] = FieldValue.increment(deposit.get('method') === 'ota' ? deposit.get('amount') : 0)
//                         batchArray[batchIndex].update(hotelDoc.ref.collection('bookings').doc(booking.id), dataPayment)
//                         operationCounter++;
//                         if (operationCounter === 499) {
//                             batchArray.push(firestore.batch());
//                             batchIndex++;
//                             operationCounter = 0;
//                         }

//                         const createdServer: Date = deposit.get('created').toDate();
//                         const createTimezone = DateUtil.convertUpSetTimezone(createdServer, timezone);
//                         const monthId = DateUtil.dateToShortStringYearMonth(createTimezone);
//                         const dayId = DateUtil.dateToShortStringDay(createTimezone);
//                         const data: { [key: string]: any } = {};
//                         data['data.' + dayId + '.deposit.' + deposit.get('method') + '.' + deposit.get('source')] = FieldValue.increment(deposit.get('amount'));
//                         batchArray[batchIndex].update(hotelDoc.ref.collection('daily_data').doc(monthId), data);
//                         operationCounter++;
//                         if (operationCounter === 499) {
//                             batchArray.push(firestore.batch());
//                             batchIndex++;
//                             operationCounter = 0;
//                         }

//                     }
//                 };
//             }

//         }

//         for (const batch of batchArray) {
//             await batch.commit();
//         }
//         return 'Async done';
//     } else {
//         return 'No booking';
//     }
// })

// exports.asyncDataGroup = functions.https.onCall(async (data, context) => {
//     const hotelID = data.hotel_id;
//     const startDayTimezone: Date = new Date(data.start_date);
//     const endDayTimezone: Date = new Date(data.end_date);
//     console.log(startDayTimezone);
//     console.log(endDayTimezone);
//     const hotelDoc = await firestore.collection('hotels').doc(hotelID).get();
//     // const timezone = hotelDoc.get('timezone');
//     // const startDayServer: Date = DateUtil.convertOffSetTimezone(startDayTimezone, timezone);
//     // const endDayServer: Date = DateUtil.convertOffSetTimezone(endDayTimezone, timezone);
//     // const bookingDocs = await admin.firestore().collection('hotels').doc(hotelID).collection('bookings').where('in_date', '>=', startDayServer).where('in_date', '<=', endDayServer).get();
//     const bookingDocs = await hotelDoc.ref.collection('bookings').where('in_date', '>=', startDayTimezone).where('in_date', '<=', endDayTimezone).get();
//     console.log(bookingDocs.size);
//     const batchArray: FirebaseFirestore.WriteBatch[] = [];
//     let batchIndex: number = 0;
//     let operationCounter: number = 0;
//     batchArray.push(firestore.batch());

//     if (!bookingDocs.empty) {
//         for (const booking of bookingDocs.docs) {
//             if (booking.get('room') === 'virtual') continue;
//             if (![BookingStatus.checkin, BookingStatus.checkout, BookingStatus.booked].includes(booking.get('status'))) {
//                 continue;
//             }
//             if (booking.get('group')) {
//                 console.log('Group: ' + booking.get('name') + ' ' + booking.id);
//                 const subBookings: { [key: string]: any } = booking.get('sub_bookings');
//                 const dataUpdate: { [key: string]: any } = {};

//                 for (const idBasicBooking in subBookings) {
//                     const basicBookingDoc = await hotelDoc.ref.collection('basic_bookings').doc(idBasicBooking).get();
//                     dataUpdate['pay_at_hotel'] = basicBookingDoc.get('pay_at_hotel');
//                     dataUpdate['sub_bookings.' + idBasicBooking + '.breakfast'] = basicBookingDoc.get('breakfast')
//                 }
//                 console.log(dataUpdate);
//                 batchArray[batchIndex].update(hotelDoc.ref.collection('bookings').doc(booking.id), dataUpdate);
//                 operationCounter++;
//                 if (operationCounter === 499) {
//                     batchArray.push(firestore.batch());
//                     batchIndex++;
//                     operationCounter = 0;
//                 }
//             }
//         }

//         for (const batch of batchArray) {
//             await batch.commit();
//         }
//         return 'Async done';
//     } else {
//         return 'No booking';
//     }

// })