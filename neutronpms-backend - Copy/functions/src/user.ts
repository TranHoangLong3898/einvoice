import admin = require('firebase-admin');
import functions = require('firebase-functions');
import { UserRole } from './constant/userrole';
import { DateUtil } from './util/dateutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
const fireStore = admin.firestore();
const fieldValue = admin.firestore.FieldValue;

exports.onDeleteSystemUser = functions.firestore
    .document('users/{user}')
    .onDelete(async (doc, context) => {
        const userUid = doc.id;

        const hotels = await fireStore.collection('hotels').where('users', 'array-contains', userUid).get();
        for (const hotel of hotels.docs) {
            await fireStore.collection('hotels').doc(hotel.id).update({
                'users': fieldValue.arrayRemove(userUid),
                ['role.' + userUid]: fieldValue.delete()
            })
        }
    });

exports.addUserInfo = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    if (context.auth!.uid === NeutronUtil.uidAdmin) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.FORBIDDEN);
    }

    // const userWithNationIDInCloud = await fireStore.collection('users').where('national_id', '==', data.national_id).get();
    // if (!userWithNationIDInCloud.empty) {
    //     userWithNationIDInCloud.docs.forEach((doc) => {
    //         if (doc.id !== context.auth!.uid) {
    //             throw new functions.https.HttpsError('already-exists', MessageUtil.NATIONAL_ID_DUPLICATED);
    //         }
    //     });
    // }

    const dataUpdate: { [key: string]: any } = {
        'first_name': data.first_name,
        'last_name': data.last_name,
        'email': context.auth?.token.email,
        'phone': data.phone,
        'gender': data.gender,
        'date_of_birth': DateUtil.shortStringToDate(data.date_of_birth),
        // 'address': data.address,
        // 'job': data.job,
        // 'national_id': data.national_id,
        // 'country': data.country,
        // 'city': data.city
    }
    try {
        await fireStore.collection('users').doc(context.auth!.uid).update(dataUpdate);
    } catch (e) {
        dataUpdate['hotels'] = [];
        await fireStore.collection('users').doc(context.auth!.uid).set(dataUpdate);
    }
    return MessageUtil.SUCCESS;
});

exports.grantRolesForUser = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    const dataUID: string = data.uid;
    if (dataUID === NeutronUtil.uidAdmin) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.FORBIDDEN);
    }

    if (dataUID === context.auth?.uid) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.CAN_NOT_AUTHORIZE_BY_YOURSELF);
    }

    const hotelId = data.hotel_id;

    const res = fireStore.runTransaction(async (t) => {
        const hotelRef = await t.get(fireStore.collection('hotels').doc(hotelId));
        if (!hotelRef.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
        }
        //roles of user who make this request
        const userRole: String[] = hotelRef.get('role')[context.auth!.uid];
        //roles allow to change database
        const rolesAllowed: String[] = NeutronUtil.rolesManageUserOfHotel;
        if (!userRole.some((role) => rolesAllowed.includes(role))) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        //list all users who have been added to hotel
        const usersOfHotel: string[] = hotelRef.get('users');
        if (usersOfHotel === undefined || !usersOfHotel.includes(dataUID)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.NEED_TO_ADD_USER_TO_HOTEL_FIRST);
        }

        const oldRoles: string[] = hotelRef.get('role')[dataUID] ?? [];
        const newRoles: string[] = data.roles;
        //try to grant role admin
        if (oldRoles.includes(UserRole.admin) || newRoles.includes(UserRole.admin)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        //try to grant role owner
        if ((newRoles.includes(UserRole.owner) || oldRoles.includes(UserRole.owner)) && !userRole.includes(UserRole.admin)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        if (newRoles.some((role) => role === UserRole.manager)
            && !userRole.includes(UserRole.admin) && !userRole.includes(UserRole.owner)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        if (newRoles.length === 0) {
            throw new functions.https.HttpsError('invalid-argument', MessageUtil.BAD_REQUEST)
        }

        t.update(fireStore.collection('hotels').doc(hotelId), {
            ['role.' + dataUID]: newRoles
        })
        return MessageUtil.SUCCESS;
    });

    return res;
});

exports.addUserToHotel = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;

    const res = fireStore.runTransaction(async (t) => {
        const hotelRef = await t.get(fireStore.collection('hotels').doc(hotelId));
        if (!hotelRef.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
        }

        //roles of user who make this request
        const roleOfUser: String[] = hotelRef.get('role')[context.auth!.uid];
        //roles allow to change database
        const rolesAllowed: String[] = NeutronUtil.rolesManageUserOfHotel;
        if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const dataEmail: string = data.email;

        const dataUID = await admin.auth().getUserByEmail(dataEmail).then((v) => { return v.uid },
            (e) => {
                throw new functions.https.HttpsError('unauthenticated', MessageUtil.EMAIL_NOT_FOUND);
            });

        if (hotelRef.get('users').includes(dataUID)) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.EMAIL_DUPLICATED);
        }

        const userExist = await t.get(fireStore.collection('users').doc(dataUID));

        if (!userExist.exists) {
            throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHENTICATED_USER);
        }

        t.update(fireStore.collection('hotels').doc(hotelId), {
            'users': fieldValue.arrayUnion(dataUID)
        })

        t.update(fireStore.collection('users').doc(dataUID), {
            'hotels': fieldValue.arrayUnion(hotelId),
            'hotels_name': fieldValue.arrayUnion(hotelRef.get("name"))
        })

        return MessageUtil.SUCCESS;
    });

    return res;
});

exports.removeUserFromHotel = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    const uidRemove = data.uid;
    if (uidRemove === NeutronUtil.uidAdmin) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.FORBIDDEN);
    }

    const hotelId = data.hotel_id;

    const res = fireStore.runTransaction(async (t) => {
        const hotelRef = await t.get(fireStore.collection('hotels').doc(hotelId));
        if (!hotelRef.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
        }

        //roles of user who make this request
        const roleOfUser: String[] = hotelRef.get('role')[context.auth!.uid];
        //roles allow to change database
        const rolesAllowed: String[] = NeutronUtil.rolesManageUserOfHotel;
        if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        if (uidRemove === context.auth?.uid) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const usersOfHotel: string[] = hotelRef.get('users');
        const roleOfUserInHotel = hotelRef.get('role');
        const roleOfUserRemove: string[] = roleOfUserInHotel[uidRemove];
        if (roleOfUserRemove !== undefined) {
            if (roleOfUserRemove.includes(UserRole.admin)) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
            }

            if (roleOfUserRemove.includes(UserRole.owner) && !roleOfUser.includes(UserRole.admin)) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
            }

            if (roleOfUserRemove.includes(UserRole.manager) && !roleOfUser.includes(UserRole.admin)
                && !roleOfUser.includes(UserRole.owner)) {
                throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
            }
        }

        if (usersOfHotel === undefined || !usersOfHotel.includes(uidRemove)) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.EMAIL_NOT_FOUND);
        }

        t.update(fireStore.collection('hotels').doc(hotelId), {
            'users': fieldValue.arrayRemove(uidRemove),
            ['role.' + uidRemove]: fieldValue.delete()
        })
        t.update(fireStore.collection('users').doc(uidRemove), {
            'hotels': fieldValue.arrayRemove(hotelId),
            'hotels_name': fieldValue.arrayRemove(hotelRef.get("name"))
        })

        return MessageUtil.SUCCESS;
    });

    return res;
});

exports.register = functions.https.onCall(async (data, context) => {
    const existUID = await admin.auth().getUserByEmail(data.email).then((user) => user.uid, (_fail) => undefined);
    if (existUID !== undefined) {
        throw new functions.https.HttpsError('already-exists', MessageUtil.EMAIL_REGISTED);
    }

    // const userWithNationIDInCloud = await fireStore.collection('users').where('national_id', '==', data.national_id).get();
    // if (!userWithNationIDInCloud.empty) {
    //     throw new functions.https.HttpsError('already-exists', MessageUtil.NATIONAL_ID_DUPLICATED);
    // }

    const uid = await admin.auth().createUser({
        email: data.email,
        password: data.password
    }).then((v) => { return v.uid });
    const dataUpdate: { [key: string]: any } = {
        'first_name': data.first_name,
        'last_name': data.last_name,
        'email': data.email,
        'phone': data.phone,
        'gender': data.gender,
        'date_of_birth': DateUtil.shortStringToDate(data.date_of_birth),
        // 'country': data.country,
        // 'city': data.city,
        // 'job': data.job,
        // 'address': data.address,
        // 'national_id': data.national_id,
        'hotels': []
    }
    await fireStore.collection('users').doc(uid).set(dataUpdate);
    return MessageUtil.SUCCESS;
});

exports.getUsersInHotel = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);

    const rolesAllowed = NeutronUtil.rolesManageUserOfHotel;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const docs = (await fireStore.collection('users').where('hotels', 'array-contains', hotelId).get()).docs;
    if (docs === undefined || docs.length === 0) {
        return [];
    }
    const result: any[] = [];
    docs.forEach((item) => {
        if (item.id === NeutronUtil.uidAdmin) {
            return;
        }
        const user: { [key: string]: any } = item.data();
        user['id'] = item.id;
        result.push(user);
    });
    return result;
});