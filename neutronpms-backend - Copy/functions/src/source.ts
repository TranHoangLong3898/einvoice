import admin = require('firebase-admin');
import functions = require('firebase-functions');
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
const fireStore = admin.firestore();

exports.addSource = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const sourceId: string = data.source_id;
    const sourceName: string = data.source_name;
    const sourceMapping: string = data.source_mapping_source;
    const sourceOTA: boolean = data.source_ota;
    const sourceActive: boolean = data.source_active;
    const hotelId: string = data.hotel_id;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    const rolesAllowed = NeutronUtil.rolesCRUDSourceOfHotel;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = await fireStore.runTransaction(async (t) => {
        const configurationRef = hotelRef.collection('management').doc('configurations');
        const configuraionDoc = await t.get(configurationRef);

        if (!configuraionDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }
        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(configuraionDoc.get('data.sources')));
        sourcesDataInCloud.forEach((value, key) => {
            if (key === sourceId) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
            }
            if (value['name'] === sourceName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
            if (sourceMapping !== '' && value['mapping_source'] === sourceMapping) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_MAPPING_SOURCE)
            }
        })

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['name'] = sourceName;
        dataUpdate['active'] = sourceActive;
        if (sourceMapping !== undefined && sourceMapping.length > 0) {
            dataUpdate['mapping_source'] = sourceMapping;
        }
        if (sourceOTA !== undefined) {
            dataUpdate['ota'] = sourceOTA;
        }

        t.update(configurationRef, {
            ['data.sources.' + sourceId]: dataUpdate
        });
        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.updateSource = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const sourceId: string = data.source_id;
    const sourceName: string = data.source_name;
    const sourceMapping: string = data.source_mapping_source;
    const sourceOTA: boolean = data.source_ota;
    const sourceActive: boolean = data.source_active;
    const hotelId: string = data.hotel_id;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    const rolesAllowed = NeutronUtil.rolesCRUDSourceOfHotel;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const configurationRef = hotelRef.collection('management').doc('configurations');
        const configuraion = await t.get(configurationRef);

        if (!configuraion.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(configuraion.get('data.sources')));
        sourcesDataInCloud.forEach((value, key) => {
            if (key !== sourceId && value['name'] === sourceName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
            if (sourceMapping !== '' && key !== sourceId && value['mapping_source'] === sourceMapping) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_MAPPING_SOURCE)
            }
        })

        const dataUpdate: { [key: string]: any } = {};
        dataUpdate['name'] = sourceName;
        dataUpdate['active'] = sourceActive;
        if (sourceMapping !== undefined && sourceMapping.length > 0) {
            dataUpdate['mapping_source'] = sourceMapping;
        }
        if (sourceOTA !== undefined) {
            dataUpdate['ota'] = sourceOTA;
        }

        if (sourceId === 'ex') {
            dataUpdate['sub_mapping_source'] = ['Hotels.com'];
        }

        t.update(configurationRef, {
            ['data.sources.' + sourceId]: dataUpdate
        });
        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.toggleActiveSource = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const sourceId: string = data.source_id;
    const hotelId: string = data.hotel_id;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    const rolesAllowed = NeutronUtil.rolesCRUDSourceOfHotel;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const configurationRef = hotelRef.collection('management').doc('configurations');
        const configuraion = await t.get(configurationRef);

        if (!configuraion.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND)
        }

        const sourceActive: boolean = configuraion?.get('data.sources.' + sourceId + '.active') ?? true;

        t.update(configurationRef, {
            ['data.sources.' + sourceId + '.active']: !sourceActive
        });

        return MessageUtil.SUCCESS;
    })
    return res;
})