import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
const fireStore = admin.firestore();

exports.createPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }
    const dataPaymentId: string = data.payment_method_id;
    const dataPaymentName: string = data.payment_method_name;
    const dataPaymentStatus: string[] = data.payment_method_status;
    const hotelID: string = data.hotel_id;

    const uidOfUser: string = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesCRUDPaymetMethod;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const configurationDoc = await t.get(hotelRef.collection('management').doc('payment_methods'));
        if (!configurationDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }
        const paymentMethods = configurationDoc.get('data');
        for (const idPaymentMethod in paymentMethods) {
            if (idPaymentMethod === dataPaymentId) {
                throw new functions.https.HttpsError('not-found', MessageUtil.ID_PAYMENT_DUPLICATED)
            }
            if (paymentMethods[idPaymentMethod]['name'] === dataPaymentName) {
                throw new functions.https.HttpsError('not-found', MessageUtil.NAME_PAYMENT_DUPLICATED)
            }
        }
        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['data.' + dataPaymentId + '.name'] = dataPaymentName;
        dataUpdate['data.' + dataPaymentId + '.status'] = dataPaymentStatus;
        dataUpdate['data.' + dataPaymentId + '.is_delete'] = false;
        t.update(hotelRef.collection('management').doc('payment_methods'), dataUpdate)
        return MessageUtil.SUCCESS;
    })
    return res;
})

exports.editPayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }
    const dataPaymentId: string = data.payment_method_id;
    const dataPaymentName: string = data.payment_method_name;
    const dataPaymentStatus: string[] = data.payment_method_status;

    const hotelID: string = data.hotel_id;

    const uidOfUser: string = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesCRUDPaymetMethod;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }


    const res = await fireStore.runTransaction(async (t) => {
        const configurationDoc = await t.get(hotelRef.collection('management').doc('payment_methods'));
        if (!configurationDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }

        const paymentMethods: { [key: string]: any } = configurationDoc.get('data');
        if (paymentMethods[dataPaymentId]['is_delete']) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.PAYMENT_WAS_DELETE);
        }

        for (const idPaymentMethod in paymentMethods) {
            if (paymentMethods[idPaymentMethod]['name'] === dataPaymentName && idPaymentMethod !== dataPaymentId) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.NAME_PAYMENT_DUPLICATED)
            }
        }

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['data.' + dataPaymentId + '.name'] = dataPaymentName;
        dataUpdate['data.' + dataPaymentId + '.status'] = dataPaymentStatus;
        t.update(hotelRef.collection('management').doc('payment_methods'), dataUpdate)
        return MessageUtil.SUCCESS;
    })
    return res;
})

// update flag true in payment
exports.deletePayment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const dataPaymentId: string = data.payment_method_id;


    const hotelID: string = data.hotel_id;

    const uidOfUser: string = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesCRUDPaymetMethod;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles of user who make this request
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const configurationDoc = await t.get(hotelRef.collection('management').doc('payment_methods'));
        if (!configurationDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }
        const paymentMethods: { [key: string]: any } = configurationDoc.get('data');
        if (paymentMethods[dataPaymentId]['is_delete']) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.PAYMENT_WAS_DELETE);
        }
        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['data.' + dataPaymentId + '.is_delete'] = true;
        t.update(hotelRef.collection('management').doc('payment_methods'), dataUpdate)
        return MessageUtil.SUCCESS;
    })
    return res;
})