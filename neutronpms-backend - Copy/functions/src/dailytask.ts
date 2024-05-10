import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { DateUtil } from "./util/dateutil";
import { UserRole } from './constant/userrole';
import { MessageUtil } from './util/messageutil';
import { BookingStatus } from './constant/status';
import { NeutronUtil } from './util/neutronutil';
import { HLSUtil } from './util/hlsutil';
import firestore = require('@google-cloud/firestore');
import { RestUtil } from './util/restutil';
const fireStore = admin.firestore();
const client = new firestore.v1.FirestoreAdminClient();

exports.dailyUpdateRoomStatus = functions.pubsub.schedule('0 */1 * * *').onRun(async (context) => {
    const nowServer = new Date();
    const hourOfTimezone: number = 6 - nowServer.getHours();
    let timezoneArray: string[];
    if (hourOfTimezone >= -12 && hourOfTimezone <= 6) {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(hourOfTimezone);
    } else {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(24 + hourOfTimezone);
    }

    const hotels = await fireStore.collection('hotels').where('timezone', 'in', timezoneArray).get();
    for (const hotel of hotels.docs) {
        const filterRooms: string[] = [];
        const filterRoomsVacantOvernight: string[] = [];
        const configurationRef = await hotel.ref.collection('management').doc('configurations').get();
        if (configurationRef === undefined) {
            continue;
        }
        const configurationDoc = configurationRef.data();
        const isVacantOvernight: boolean = hotel.get('vacant_overnight') ?? false;
        const rooms: Map<string, any> = new Map(Object.entries(configurationDoc!['data']['rooms']));
        if (rooms === undefined) {
            continue;
        }

        rooms.forEach((room, roomId) => {
            if (room['bid'] !== undefined && room['bid'] !== null) {
                filterRooms.push(roomId);
            }
            if ((room['bid'] === undefined || room['bid'] === null) && room['clean']) {
                filterRoomsVacantOvernight.push(roomId);
            }
        });

        const batch = fireStore.batch();
        filterRooms.forEach(async roomId => {
            batch.update(hotel.ref.collection('management').doc('configurations'), {
                ['data.rooms.' + roomId + '.clean']: false,
                ['data.rooms.' + roomId + '.vacant_overnight']: false,
            });
        });

        if (isVacantOvernight && filterRoomsVacantOvernight.length > 0) {
            filterRoomsVacantOvernight.forEach(async roomId => {
                batch.update(hotel.ref.collection('management').doc('configurations'), {
                    ['data.rooms.' + roomId + '.vacant_overnight']: isVacantOvernight
                });
            });
        }

        await batch.commit();
        console.log("Changed dirty status for rooms " + filterRooms.join() + " of hotel " + hotel.id);
    }
    return;
});

// exports.dailyUpdateRoomStatusTestOne = functions.pubsub.schedule('0 */1 * * *').onRun(async (context) => {
//     const nowServer = new Date();
//     console.log(nowServer.getHours());
//     ///để thây đổi hẹn giờ ta thây đổi thanh 7 h thì 6 thành 7
//     const hourOfTimezone: number = 6 - nowServer.getHours();
//     let timezoneArray: string[];

//     console.log(hourOfTimezone);

//     if (hourOfTimezone >= -12 && hourOfTimezone <= 6) {
//         timezoneArray = NeutronUtil.getTimezoneArrayByHour(hourOfTimezone);
//     } else {
//         timezoneArray = NeutronUtil.getTimezoneArrayByHour(24 + hourOfTimezone);
//     }

//     console.log(timezoneArray);

//     const hotels = await fireStore.collection('hotels').where('timezone', 'in', timezoneArray).where("name", '==', "Treetopia - Neutron TESTING").get();


//     for (const hotel of hotels.docs) {
//         const filterRooms: string[] = [];
//         const configurationRef = await hotel.ref.collection('management').doc('configurations').get();
//         if (configurationRef === undefined) {
//             continue;
//         }
//         const configurationDoc = configurationRef.data();
//         const isVacantOvernight: boolean = hotel.get('vacant_overnight') ?? false;
//         const rooms: Map<string, any> = new Map(Object.entries(configurationDoc!['data']['rooms']));
//         if (rooms === undefined) {
//             continue;
//         }

//         rooms.forEach((room, roomId) => {
//             console.log(room['bid']);
//             if ((room['bid'] === undefined || room['bid'] === null) && room['clean']) {
//                 console.log(89);
//                 filterRooms.push(roomId);
//             }
//         });

//         const batch = fireStore.batch();


//         console.log(filterRooms.length);


//         if (isVacantOvernight && filterRooms.length > 0) {
//             filterRooms.forEach(async roomId => {
//                 batch.update(hotel.ref.collection('management').doc('configurations'), {
//                     ['data.rooms.' + roomId + '.vacant_overnight']: isVacantOvernight
//                 });
//             });
//         }

//         await batch.commit();
//         console.log("Changed dirty status for rooms " + filterRooms.join() + " of hotel " + hotel.id);
//     }

//     // for (const hotel of hotels.docs) {
//     //     console.log(hotel.get("name"));
//     // }

//     //     const filterRooms: string[] = [];
//     //     const configurationRef = await hotel.ref.collection('management').doc('configurations').get();
//     //     if (configurationRef === undefined) {
//     //         continue;
//     //     }
//     //     const configurationDoc = configurationRef.data();
//     //     const rooms: Map<string, any> = new Map(Object.entries(configurationDoc!['data']['rooms']));
//     //     if (rooms === undefined) {
//     //         continue;
//     //     }

//     //     rooms.forEach((room, roomId) => {
//     //         if (room['bid'] !== undefined && room['bid'] !== null) {
//     //             filterRooms.push(roomId);
//     //         }
//     //     });

//     //     const batch = fireStore.batch();
//     //     filterRooms.forEach(async roomId => {
//     //         batch.update(hotel.ref.collection('management').doc('configurations'), {
//     //             ['data.rooms.' + roomId + '.clean']: false
//     //         });
//     //     });
//     //     await batch.commit();
//     //     console.log("Changed dirty status for rooms " + filterRooms.join() + " of hotel " + hotel.id);
//     // }
//     // return;
// });

// need to update to hls
async function addNewDailyAllotment() {
    const hotels = await fireStore.collection('hotels').get();
    const nowDate = new Date();
    const dailyAllotmentID = DateUtil.addMonthToStringYearMonth(nowDate, 23);
    const lastDayInMonth = new Date(parseInt(dailyAllotmentID.substring(0, 4)), parseInt(dailyAllotmentID.substring(4, 6)), 0).getDate();
    const batchArray: FirebaseFirestore.WriteBatch[] = [];
    batchArray.push(fireStore.batch());
    let operationCounter = 0;
    let batchIndex = 0;
    for (const hotel of hotels.docs) {
        const configurationRef = await hotel.ref.collection('management').doc('configurations').get();
        const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];
        if (Object.keys(roomTypes).length === 0) continue;
        try {
            await hotel.ref.collection('daily_allotment').doc(dailyAllotmentID).create({});
        } catch (error) {
            continue;
        }
        const dataUpdate: { [key: string]: any } = {};
        Object.keys(roomTypes).map((idRoomType) => {
            for (let day = 1; day <= lastDayInMonth; day++) {
                dataUpdate['data.' + day + '.' + idRoomType + '.num'] = roomTypes[idRoomType]['num'];
            };
            dataUpdate['data.default.' + idRoomType + '.price'] = roomTypes[idRoomType]['price'];
        });
        batchArray[batchIndex].update(hotel.ref.collection('daily_allotment').doc(dailyAllotmentID), dataUpdate);
        operationCounter++;
        if (operationCounter === 499) {
            batchArray.push(fireStore.batch());
            batchIndex++;
            operationCounter = 0;
        }
    }
    for (const batch of batchArray) {
        await batch.commit();
    }
}

exports.addDailyDataEveryMonthly = functions.pubsub.schedule('0 0 2 * *')
    .timeZone('Asia/Ho_Chi_Minh')
    .onRun(async (context) => {
        try {
            await addNewDailyAllotment();
        } catch (error) {
            console.log(error);
        }
    });

async function addNewHTLS() {
    const hotels = await fireStore.collection('hotels').get();
    const nowDate = new Date();
    const dailyAllotmentID = DateUtil.addMonthToStringYearMonth(nowDate, 23);
    const lastDayInMonth = new Date(parseInt(dailyAllotmentID.substring(0, 4)), parseInt(dailyAllotmentID.substring(4, 6)), 0).getDate();
    for (const hotel of hotels.docs) {
        const dailyAllotmentDoc = await hotel.ref.collection('daily_allotment').doc(dailyAllotmentID).get();
        const mappingHotelID: string | undefined = hotel.get('mapping_hotel_id');
        const mappingHotelKey: string | undefined = hotel.get('mapping_hotel_key');
        if (dailyAllotmentDoc.exists && mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            console.log(hotel.get("name"), mappingHotelID);
            const timezone: string = hotel.get('timezone');
            const auto_rate: boolean = hotel.get('auto_rate') ?? true;
            const configurationRef = await hotel.ref.collection('management').doc('configurations').get();
            const roomTypes: { [key: string]: any } = configurationRef.get('data')['room_types'];
            if (Object.keys(roomTypes).length === 0) continue;
            const options = {
                hostname: 'us-central1-neutron-pms.cloudfunctions.net',
                path: '/dailytask-UpdatedHTLMonthlyForEachHotel',
                method: 'POST',
                headers: {
                    "Content-Type": "application/json"
                }
            };
            const param: any = JSON.stringify({
                'idhotel': hotel.id,
                'timezone': timezone,
                'auto_rate': auto_rate,
                "dailyAllotmentID": dailyAllotmentID,
                'lastDayInMonth': lastDayInMonth,
                'roomTypes': roomTypes,
                'mappingHotelID': mappingHotelID,
                'mappingHotelKey': mappingHotelKey,

            });
            await RestUtil.postRequest(options, param);
        } else {
            continue;
        }

    }
}

exports.UpdatedHTLMonthlyForEachHotel = functions.runWith({ timeoutSeconds: 400 }).https.onRequest(async (req, res) => {
    const data = JSON.parse(req.rawBody.toString());
    const idHotel: string = data.idhotel;
    const timezone: string = data.timezone;
    const auto_rate: boolean = data.auto_rate;
    const dailyAllotmentID = data.dailyAllotmentID;
    const lastDayInMonth: number = data.lastDayInMonth;
    const roomTypes: { [key: string]: any } = data.roomTypes;
    const mappingHotelID: string = data.mappingHotelID;
    const mappingHotelKey: string = data.mappingHotelKey;
    let roomTypeCM: { [key: string]: any } | undefined;
    const almMap: { [key: string]: any } = {};
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    for (const idRoomType in roomTypes) {
        roomTypeCM = await NeutronUtil.getCmRoomType(idHotel, idRoomType);
        if (roomTypeCM.id != undefined) {
            almMap[roomTypeCM.id] = {};
            for (let day = 1; day <= lastDayInMonth; day++) {
                if (roomTypeCM !== undefined) {
                    const dateHls = dailyAllotmentID.substring(0, 4) + '-' + dailyAllotmentID.substring(4, 6) + '-' + (day < 10 ? '0' + day : day);
                    const hlsDate: Date = DateUtil.getDateFromHLSDateStringNew(dateHls);
                    if (hlsDate.getTime() >= now12hTimezone.getTime()) {
                        almMap[roomTypeCM.id][dateHls] = {};
                        almMap[roomTypeCM.id][dateHls]['num'] = roomTypes[idRoomType]['num'];
                        almMap[roomTypeCM.id][dateHls]['price'] = roomTypes[idRoomType]['price'];
                        almMap[roomTypeCM.id][dateHls]['ratePlanID'] = roomTypeCM.ratePlanID;
                    }
                }
            };
        }
    };
    const result = await HLSUtil.updateMultipleAvaibility(mappingHotelID, mappingHotelKey, almMap, auto_rate);
    if (result === null) {
        console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
    }
    res.status(200).json({
        'result': true,
        'message': 'OK'
    });
});

exports.addHTLEveryMonthly = functions.runWith({ timeoutSeconds: 540 }).pubsub.schedule('0 1 2 * *')
    .timeZone('Asia/Ho_Chi_Minh')
    .onRun(async (context) => {
        try {
            await addNewHTLS();
        } catch (error) {
            console.log(error);
        }
    });

exports.editDailyAllotment = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', 'You have to login first');

    const keyOfRole = 'role.' + context.auth?.uid;
    const dailyAllotMent: { [key: string]: any } = data.list;
    const roomType: string = data.room_type_id;
    const hotelID: string = data.hotel_id;
    const monthID: string = data.daily_allotment_id;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    const timezone: string = hotelDoc.get('timezone');
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const auto_rate: boolean = hotelDoc.get('auto_rate') ?? true;
    //roles allow to change database
    const rolesAllowed: String[] = [UserRole.owner, UserRole.manager, UserRole.admin, UserRole.sale];
    //roles of user who make this request
    const roleOfUser: String[] = hotelDoc.get(keyOfRole);

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const almMap: { [key: string]: any } = {};
    let roomTypeCM: { [key: string]: any } | undefined;
    if (mappingHotelID !== undefined) {
        roomTypeCM = await NeutronUtil.getCmRoomType(hotelID, roomType);
        almMap[roomTypeCM.id] = {};
    }
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);


    const dataUpdate: { [key: string]: any } = {};
    const configurationRef = await hotelRef.collection('management').doc('configurations').get();
    const roomTypes = configurationRef.get('data')['room_types'];
    const maxNumRoomType = roomTypes[roomType]['num'];
    const minPriceRoomType = roomTypes[roomType]['min_price'];
    for (const day in dailyAllotMent) {
        if (dailyAllotMent[day]['num'] !== undefined && dailyAllotMent[day]['num'] > maxNumRoomType) {
            throw new functions.https.HttpsError('not-found', MessageUtil.NUM_MUST_SMALLER_THAN_MAX_ROOMTYPE);
        } else if (dailyAllotMent[day]['num'] !== undefined) {
            dataUpdate['data.' + day + '.' + roomType + '.num'] = dailyAllotMent[day]['num'];
            if (roomTypeCM !== undefined) {
                const dateHls = monthID.substring(0, 4) + '-' + monthID.substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                const hlsDate: Date = DateUtil.getDateFromHLSDateStringNew(dateHls);
                if (hlsDate.getTime() >= now12hTimezone.getTime()) {
                    almMap[roomTypeCM.id][dateHls] = {};
                    almMap[roomTypeCM.id][dateHls]['num'] = dailyAllotMent[day]['num'];
                    almMap[roomTypeCM.id][dateHls]['ratePlanID'] = '';
                }
            }
        }

        if (dailyAllotMent[day]['price'] !== undefined && dailyAllotMent[day]['price'] < minPriceRoomType) {
            throw new functions.https.HttpsError('not-found', MessageUtil.PRICE_MUST_BIGGER_THAN_MIN_PRICE);
        } else if (dailyAllotMent[day]['price'] !== undefined) {
            dataUpdate['data.' + day + '.' + roomType + '.price'] = dailyAllotMent[day]['price'];
            if (roomTypeCM !== undefined) {
                const dateHls = monthID.substring(0, 4) + '-' + monthID.substring(4, 6) + '-' + (Number.parseInt(day) < 10 ? '0' + day : day);
                const hlsDate: Date = DateUtil.getDateFromHLSDateStringNew(dateHls);
                if (hlsDate.getTime() >= now12hTimezone.getTime()) {
                    if (almMap[roomTypeCM.id][dateHls] === undefined) {
                        almMap[roomTypeCM.id][dateHls] = {};
                    }
                    if (almMap[roomTypeCM.id][dateHls]['num'] === undefined) {
                        almMap[roomTypeCM.id][dateHls]['num'] = ''
                    }
                    almMap[roomTypeCM.id][dateHls]['price'] = dailyAllotMent[day]['price'];
                    almMap[roomTypeCM.id][dateHls]['ratePlanID'] = roomTypeCM.ratePlanID;
                }
            }
        }
    }
    try {
        await hotelRef.collection('daily_allotment').doc(monthID).update(dataUpdate);
        if (mappingHotelID !== undefined && mappingHotelKey !== undefined) {
            const result = await HLSUtil.updateMultipleAvaibility(mappingHotelID, mappingHotelKey, almMap, auto_rate);
            if (result === null) {
                console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
            }
        }
    } catch (error) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.UNDEFINED_ERROR);
    }
    return MessageUtil.SUCCESS;
})

exports.checkOverdueCheckInBookings = functions.pubsub.schedule('0 */1 * * *').onRun(async (context) => {
    const nowServer: Date = new Date();
    const hourOfTimezone: number = nowServer.getHours();
    let timezoneArray: string[];
    if (hourOfTimezone > 12) {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(24 - hourOfTimezone);
    } else if (hourOfTimezone === 12) {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(hourOfTimezone);
        timezoneArray.push(...NeutronUtil.getTimezoneArrayByHour(- hourOfTimezone));
    } else {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(-hourOfTimezone);
    }
    const hotels = await fireStore.collection('hotels').where('timezone', 'in', timezoneArray).get();
    if (hotels.empty) {
        console.log('Dont have hotel in this timezone :' + timezoneArray);
        return;
    }
    const batchArray: FirebaseFirestore.WriteBatch[] = [];
    batchArray.push(fireStore.batch());
    let operationCounter = 0;
    let batchIndex = 0;
    for (const hotel of hotels.docs) {
        const timezone = hotel.get('timezone');
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now0hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 0, 0, 0);
        const now0hTimezoneOffset: Date = DateUtil.convertOffSetTimezone(now0hTimezone, timezone);

        const overdueCheckinBookingDocs = await hotel.ref.collection('basic_bookings')
            .where('status', '==', BookingStatus.booked)
            .where('in_date', '<=', now0hTimezoneOffset).get();
        const dataUpdate: { [key: string]: any; } = {};
        //name of all overdue-booking 
        let result: string = '';
        if (overdueCheckinBookingDocs.empty) continue;
        for (const booking of overdueCheckinBookingDocs.docs) {
            const bookingName = booking.get('name');
            if (booking.get('group')) {
                dataUpdate[booking.id] = {
                    'type': 'overdue-checkin',
                    'name': bookingName,
                    'sid': booking.get('sid')
                };
                result += bookingName + ', ';
            } else {
                dataUpdate[booking.id] = {
                    'type': 'overdue-checkin',
                    'name': bookingName
                };
                result += bookingName + ', ';
            }
        };
        batchArray[batchIndex].update(hotel.ref.collection('management').doc('overdue_bookings'), {
            ['overdue_bookings.checkin']: dataUpdate
        });
        operationCounter++;
        if (operationCounter === 499) {
            batchArray.push(fireStore.batch());
            batchIndex++;
            operationCounter = 0;
        }
        console.log('Done! Result = ' + result);
    }
    for (const batch of batchArray) {
        await batch.commit();
    }
});

exports.checkOverdueCheckOutBookings = functions.pubsub.schedule('0 */1 * * *').onRun(async (context) => {
    const nowServer: Date = new Date();
    let hourOfTimezone: number;

    if (nowServer.getHours() > 12) {
        hourOfTimezone = - (nowServer.getHours() - 12);
    } else {
        hourOfTimezone = 12 - nowServer.getHours();
    }

    let timezoneArray: string[];
    if (hourOfTimezone === 12) {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(hourOfTimezone);
        timezoneArray.push(...NeutronUtil.getTimezoneArrayByHour(-hourOfTimezone));
    } else {
        timezoneArray = NeutronUtil.getTimezoneArrayByHour(hourOfTimezone);
    }

    const hotels = await fireStore.collection('hotels').where('timezone', 'in', timezoneArray).get();
    if (hotels.empty) {
        console.log('Dont have hotel in this timezone :' + hourOfTimezone);
        return
    }
    const batchArray: FirebaseFirestore.WriteBatch[] = [];
    batchArray.push(fireStore.batch());
    let operationCounter = 0;
    let batchIndex = 0;
    for (const hotel of hotels.docs) {
        const timezone = hotel.get('timezone');
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone: Date = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        const now12hTimezoneOffset: Date = DateUtil.convertOffSetTimezone(now12hTimezone, timezone);

        console.log('Start scanning hotel: ' + hotel.get('name') + ' - Now in server:' + nowServer.toString());
        const overdueCheckoutBookingDocs = await hotel.ref.collection('basic_bookings')
            .where('status', '==', BookingStatus.checkin)
            .where('out_date', '<=', now12hTimezoneOffset).get();

        const overdueCheckoutBookingVirtualDocs = await hotel.ref.collection('bookings')
            .where('status', '==', BookingStatus.booked)
            .where('virtual', '==', true)
            .where('out_date', '<=', now12hTimezoneOffset).get();
        //name of all overdue-booking for log

        let result: string = '';
        const dataUpdate: { [key: string]: any; } = {};
        if (!overdueCheckoutBookingDocs.empty) {
            for (const booking of overdueCheckoutBookingDocs.docs) {
                const bookingName = booking.get('name');
                if (booking.get('group')) {
                    dataUpdate[booking.id] = {
                        'type': 'overdue-checkout',
                        'name': bookingName,
                        'sid': booking.get('sid')
                    };
                } else {
                    dataUpdate[booking.id] = {
                        'type': 'overdue-checkout',
                        'name': bookingName
                    };
                }
                result += bookingName + ', ';
            };
        };

        if (!overdueCheckoutBookingVirtualDocs.empty) {
            for (const booking of overdueCheckoutBookingVirtualDocs.docs) {
                const bookingName = booking.get('name');
                dataUpdate[booking.id] = {
                    'type': 'overdue-checkout',
                    'name': bookingName
                };
                result += bookingName + ', ';
            };
        }

        batchArray[batchIndex].update(hotel.ref.collection('management').doc('overdue_bookings'), {
            ['overdue_bookings.checkout']: dataUpdate
        });
        operationCounter++;
        if (operationCounter === 499) {
            batchArray.push(fireStore.batch());
            batchIndex++;
            operationCounter = 0;
        }
        console.log('Done! Result = ' + result);
    }
    for (const batch of batchArray) {
        await batch.commit();
    }
});

const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

// exports.cronTabSchedule = functions.pubsub.schedule('12 15 * * *').timeZone('Asia/Ho_Chi_Minh').onRun(async (context) => {
//     const nowServer: Date = new Date();
//     const idVersionBackup: string = DateUtil.dateToShortString(nowServer);
//     const databaseName =
//         client.databasePath('neutron-pms', '(default)');
//     return client.exportDocuments({
//         name: databaseName,
//         outputUriPrefix: 'gs://onepms_backup/' + idVersionBackup,
//         collectionIds: []
//     })
//         .then(responses => {
//             const response = responses[0];
//             console.log(`Operation Name: ${response['name']}`);
//         })
//         .catch(err => {
//             console.log('Error in line 367');
//             console.error(err);
//             throw new Error('Export operation failed');
//         });
// });

// 
exports.scheduledFirestoreExport = functions.pubsub
    .schedule('0 13 * * *').timeZone('Asia/Ho_Chi_Minh')
    .onRun(async (context) => {
        const nowServer: Date = new Date();
        const idVersionBackup: string = DateUtil.dateToShortString(nowServer);
        const idVersionBackupOldSevenDay: string = DateUtil.dateToShortString(DateUtil.addDate(nowServer, -7));

        // delete bucket seven old day before
        const bucketName = 'onepms_backup/';
        const prefix = `${idVersionBackupOldSevenDay}/`;
        const options = {
            prefix: prefix
        };
        const [files] = await storage.bucket(bucketName).getFiles(options);

        if ((files as []).length === 0) {
            console.log('cancel delete here');
        } else {
            for (const file of files) {
                console.log(`Files  ${file.name}`);
                await storage.bucket(bucketName).file(file.name).delete();
            }
        }

        // export firestore to cloud storage
        const databaseName =
            client.databasePath('neutron-pms', '(default)');
        return client.exportDocuments({
            name: databaseName,
            outputUriPrefix: 'gs://onepms_backup/' + idVersionBackup,
            collectionIds: []
        })
            .then(responses => {
                const response = responses[0];
                console.log(`Operation Name: ${response['name']}`);
            })
            .catch(err => {
                console.error(err);
                throw new Error('Export operation failed');
            });
    });

exports.asyncDailyData = functions.https.onCall(async (data, context) => {
    // async for name hotel, or async for all hotel
    const nameHotel: string = data.name_hotel;
    if (context.auth?.uid !== NeutronUtil.uidAdmin) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    let hotelDocs: firestore.QuerySnapshot;
    console.log(nameHotel);

    if (nameHotel !== '') {
        hotelDocs = await fireStore.collection('hotels').where('name', '==', nameHotel).limit(1).get();
    } else {
        hotelDocs = await fireStore.collection('hotels').get();
    }
    const result: string = await fireStore.runTransaction(async (t) => {

        const dailyDataFlowHotel: { [key: string]: any } = {};
        for (const hotelDoc of hotelDocs.docs) {
            const dailyDataDocs: firestore.QuerySnapshot = await t.get(hotelDoc.ref.collection('daily_data'));
            if (dailyDataDocs.empty) continue;
            for (const dailyDoc of dailyDataDocs.docs) {
                const dailyDataTepm: { [key: string]: any } = {};
                for (const key in dailyDoc.get('data')) {
                    if (dailyDoc.get('data')[key]['guest'] !== undefined) {
                        dailyDataTepm[key] = dailyDoc.get('data')[key]['guest']['adult'] + dailyDoc.get('data')[key]['guest']['child'];
                    }
                }

                if (Object.keys(dailyDataTepm).length !== 0) {
                    if (dailyDataFlowHotel[hotelDoc.id] === undefined) {
                        dailyDataFlowHotel[hotelDoc.id] = {};
                    }
                    dailyDataFlowHotel[hotelDoc.id][dailyDoc.id] = [];
                    (dailyDataFlowHotel[hotelDoc.id][dailyDoc.id] as { [key: string]: number }[]).push(dailyDataTepm);
                }
            }
        }

        for (const hotelID in dailyDataFlowHotel) {
            for (const monthID in dailyDataFlowHotel[hotelID]) {
                const dataFlowDay: { [key: string]: number }[] = dailyDataFlowHotel[hotelID][monthID];
                const dailyDataUpdate: { [key: string]: any } = {};
                for (const dataEntries of dataFlowDay) {
                    Object.keys(dataEntries).map((e) => {
                        dailyDataUpdate[`data.${e}.type_tourists.unknown`] = dataEntries[e];
                        dailyDataUpdate[`data.${e}.country.unknown`] = dataEntries[e];
                    })
                };
                t.update(fireStore.collection('hotels').doc(hotelID).collection('daily_data').doc(monthID), dailyDataUpdate);
            }
        }

        return MessageUtil.SUCCESS;
    }).catch((err) => {
        console.log(err.message);
        throw new functions.https.HttpsError('cancelled', err.message);
    });

    return result;

});