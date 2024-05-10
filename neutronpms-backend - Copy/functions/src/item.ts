import functions = require('firebase-functions');
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import admin = require('firebase-admin');

const fireStore = admin.firestore();
// const fieldValue = admin.firestore.FieldValue;
// const fieldPath = admin.firestore.FieldPath;

exports.createItem = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const itemId = data.item_id ?? null;
    const itemName = data.item_name ?? null;
    const itemCostPrice = data.item_cost_price ?? null;
    const itemUnit = data.item_unit ?? null;
    const itemDefaultWarehouse = data.item_default_warehouse ?? null;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDItem;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const itemInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('items'))).data();

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(itemInCloud!['data']));
        sourcesDataInCloud.forEach((value, key) => {
            if (key === itemId) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
            }
            if (value['name'] === itemName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        })

        t.update(hotelRef.collection('management').doc('items'), {
            ['data.' + itemId]: {
                'name': itemName,
                'cost_price': itemCostPrice,
                'active': true,
                'unit': itemUnit,
                'warehouse': itemDefaultWarehouse
            }
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.createsMultipleItem = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const dataItems: { [key: string]: any } = data.data_items;
    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDItem;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const batch = fireStore.batch();
    const itemInCloud: { [key: string]: any } | undefined = (await hotelRef.collection('management').doc('items').get()).data();
    const sourcesDataInCloud: Map<string, any> = new Map(Object.entries(itemInCloud!['data']));
    sourcesDataInCloud.forEach((value, key) => {
        for (const id in dataItems) {
            if (value['name'] === dataItems[id]["name"]) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        }
        if (dataItems[key] != undefined) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
        }
    })
    for (const key in dataItems) {
        batch.update(hotelRef.collection('management').doc('items'), {
            ['data.' + key]: dataItems[key],
        });
    }
    await batch.commit();
    return MessageUtil.SUCCESS;
});

exports.updateItem = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const itemId = data.item_id ?? null;
    const itemName = data.item_name ?? null;
    const itemCostPrice = data.item_cost_price ?? null;
    const itemSellPrice = data.item_sell_price ?? null;
    const itemUnit = data.item_unit ?? null;
    const itemDefaultWarehouse: string = data.item_default_warehouse?.length === 0 ? null : data.item_default_warehouse;
    const itemType = data.item_type;
    const itemAutoExport = data.item_auto_export;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDItem;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const itemInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('items'))).data();

        if (itemInCloud!['data'][itemId] === undefined) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.ITEM_NOT_FOUND)
        }

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(itemInCloud!['data']));
        sourcesDataInCloud.forEach((value, key) => {
            if (key !== itemId && value['name'] === itemName && value['unit'] === itemUnit) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATE_NAME_AND_UNIT)
            }
        })

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['data.' + itemId + '.name'] = itemName;
        dataUpdate['data.' + itemId + '.cost_price'] = itemCostPrice;
        dataUpdate['data.' + itemId + '.sell_price'] = itemSellPrice;
        dataUpdate['data.' + itemId + '.unit'] = itemUnit;
        dataUpdate['data.' + itemId + '.warehouse'] = itemDefaultWarehouse;
        dataUpdate['data.' + itemId + '.type'] = itemType;
        dataUpdate['data.' + itemId + '.auto_export'] = itemAutoExport;

        t.update(hotelRef.collection('management').doc('items'), dataUpdate);
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.toggleItemActivation = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const itemId = data.item_id ?? null;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDItem;

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const itemInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('items'))).data();

        if (itemInCloud!['data'][itemId] === undefined) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.ITEM_NOT_FOUND)
        }

        const currentStatus: boolean = itemInCloud!['data'][itemId]['active'];

        t.update(hotelRef.collection('management').doc('items'), {
            ['data.' + itemId + '.active']: !currentStatus
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});