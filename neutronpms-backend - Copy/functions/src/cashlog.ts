import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { MessageUtil } from './util/messageutil';
import { NumberUtil } from './util/numberutil';
import { NeutronUtil } from './util/neutronutil';


exports.createCashLog = functions.firestore
    .document('hotels/{hotelID}/cash_logs/{cashlogID}')
    .onCreate(async (doc, context) => {
        try {
            const cashLog = doc.data();
            const hotelRef = doc.ref.parent.parent;
            if (hotelRef === null) {
                console.error('Not found hotel collection!');
                return false;
            }

            const FieldValue = admin.firestore.FieldValue;

            await hotelRef.collection('management').doc('reception_cash').update(
                { 'total': FieldValue.increment(cashLog.amount) });

            return true;
        } catch (e) {
            console.error(e);
            return false;
        }
    });

exports.deleteCashLog = functions.firestore
    .document('hotels/{hotelID}/cash_logs/{cashlogID}')
    .onDelete(async (doc, context) => {
        try {
            const cashLog = doc.data();
            const hotelRef = doc.ref.parent.parent;
            if (hotelRef === null) {
                console.error('Not found hotel collection!');
                return false;
            }

            const FieldValue = admin.firestore.FieldValue;

            await hotelRef.collection('management').doc('reception_cash').update(
                { 'total': FieldValue.increment(-cashLog.amount) });


            return true;
        } catch (e) {
            console.error(e);
            return false;
        }
    });

exports.addCashLogToCloud = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const now = new Date();
    const hotelId = data.hotel_id;
    const cashLogId = NumberUtil.getRandomID();
    const cashLogAmount = data.cashlog_amount;
    const cashLogDesc = data.cashlog_desc;
    const cashLogOldTotal = data.total_cash;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesAddCashLog;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    await hotelRef.collection('cash_logs').doc(cashLogId).set(
        { 'amount': cashLogAmount, 'desc': cashLogDesc, 'created': now, 'old_total_cash': cashLogOldTotal, 'status': 'open' });
    return MessageUtil.SUCCESS;
});

exports.updateStatusCashLog = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const cashLogId = data.cashLog_id;
    const newStatus = data.status;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateStatusCashLog;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    await hotelRef.collection('cash_logs').doc(cashLogId).update(
        { 'status': newStatus });

    return MessageUtil.SUCCESS;
});