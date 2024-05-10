import admin = require('firebase-admin');
import functions = require('firebase-functions');
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
const fireStore = admin.firestore();

exports.toggleSupplierActivation = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const supplierId = data.supplier_id;
    const supplierActive = data.supplier_active;

    if (supplierId === 'inhouse') {
        throw new functions.https.HttpsError("permission-denied", MessageUtil.CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER);
    }

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDSupplier;

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    await hotelRef.collection('management').doc('configurations').update({
        ['data.suppliers.' + supplierId + '.active']: supplierActive
    })
    return MessageUtil.SUCCESS;
});

exports.updateSupplier = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const supplierId: string = data.supplier_id;
    const supplierName: string = data.supplier_name;
    const supplierServices: string[] = data.supplier_services;
    const isAddFeature: boolean = data.is_add_feature;

    if (supplierServices.length === 0) {
        throw new functions.https.HttpsError("not-found", MessageUtil.NEED_TO_CHOOSE_ATLEAST_ONE_SERVICE);
    }

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDSupplier;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const serviceInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();

        if (isAddFeature && serviceInCloud !== undefined && serviceInCloud.data['suppliers'][supplierId] !== undefined) {
            throw new functions.https.HttpsError("already-exists", MessageUtil.DUPLICATED_ID);
        }
        const suppliersDataInCloud: Map<String, any> = new Map(Object.entries(serviceInCloud!['data']['suppliers']));

        suppliersDataInCloud.forEach((value, key) => {
            if (isAddFeature && key === supplierId) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
            }
            if (key !== supplierId && value['name'] === supplierName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        })

        t.update(hotelRef.collection('management').doc('configurations'), {
            ['data.suppliers.' + supplierId]: {
                'active': true,
                'name': supplierName,
                'services': supplierServices
            }
        });

        return MessageUtil.SUCCESS;
    });
    return res;
});