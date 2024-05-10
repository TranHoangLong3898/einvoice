import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { HotelPackage, RevenueLogType } from './constant/type';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';

const Firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.createRevenue = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const methodID: string = data.method_id;
    const isAdd: boolean = data.is_add;
    const desc: string = data.desc;
    const amount: number = data.amount;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();

    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }

    const uidOfUser: string = context.auth.uid;
    const author: string = context.auth.token.email ?? 'unknown email';
    const nowServer: Date = new Date();


    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction: string = await Firestore.runTransaction(async (t) => {
        const revenueDoc = await t.get(hotelDoc.ref.collection('management').doc('revenue'));
        if (!revenueDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.REVENUE_MANAGEMENT_NOT_FOUND);
        }

        t.create(hotelDoc.ref.collection('revenue_logs').doc(NumberUtil.getRandomID()), {
            'amount': amount,
            'method': methodID,
            'desc': desc,
            'type': isAdd ? RevenueLogType.typeAdd : RevenueLogType.typeMinus,
            'created': nowServer,
            'email': author,
            'data': revenueDoc.data()
        });
        const dataRevenue: { [key: string]: any } = {};
        dataRevenue[methodID] = FieldValue.increment((isAdd ? 1 : -1) * amount);
        t.update(hotelDoc.ref.collection('management').doc('revenue'), dataRevenue);

        return MessageUtil.SUCCESS;
    }).catch((error) => {
        throw new functions.https.HttpsError('cancelled', error.message);
    });
    return resultTransaction;
});

exports.createTransferRevenue = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const methodIDFrom: string = data.method_id_from;
    const methodIDTo: string = data.method_id_to;
    const desc: string = data.desc;
    const amount: number = data.amount;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const uidOfUser: string = context.auth.uid;
    const author: string = context.auth.token.email ?? 'unknown email';
    const nowServer: Date = new Date();


    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction: string = await Firestore.runTransaction(async (t) => {
        const revenueDoc = await t.get(hotelDoc.ref.collection('management').doc('revenue'));
        if (!revenueDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.REVENUE_DOC_NOT_FOUND);
        }

        t.create(hotelDoc.ref.collection('revenue_logs').doc(NumberUtil.getRandomID()), {
            'amount': amount,
            'method_from': methodIDFrom,
            'method_to': methodIDTo,
            'desc': desc,
            'type': RevenueLogType.typeTransfer,
            'created': nowServer,
            'email': author,
            'data': revenueDoc.data()
        });
        const dataRevenue: { [key: string]: any } = {};
        dataRevenue[methodIDFrom] = FieldValue.increment(-amount);
        dataRevenue[methodIDTo] = FieldValue.increment(amount);
        t.update(hotelDoc.ref.collection('management').doc('revenue'), dataRevenue);

        return MessageUtil.SUCCESS;
    }).catch((error) => {
        throw new functions.https.HttpsError('cancelled', error.message);
    });
    return resultTransaction;

});
