import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { BikeRentalProgress, BookingStatus } from './constant/status';
import { HotelPackage, ItemType, ServiceCategory } from './constant/type';
import { DateUtil } from "./util/dateutil";
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';
import { UserRole } from './constant/userrole';
const firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
// deploy here
exports.createService = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/services/{serviceID}')
    .onCreate(async (doc, _) => {
        const res: string = await firestore.runTransaction(async (t) => {
            const hotelRef = doc.ref.parent.parent?.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
            }
            const hotelDoc = await t.get(hotelRef);
            const hotelAutoExportItemStatus = hotelDoc.get('auto_export_items');
            const isAutoExportWhenCreateService = (hotelAutoExportItemStatus == undefined || hotelAutoExportItemStatus == '0')
            
            const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;
            const bookingRef = doc.ref.parent.parent;
            if (bookingRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }

            const service = doc.data();
            const timezone = service.time_zone;
            const isGroup = service.group ?? false;
            const isBookingGroupParent = service.bid === service.sid ? true : false;
            const now = new Date();

            let isCheckBooking: boolean = false;
            if ((await t.get(hotelRef.collection('basic_bookings').doc(service.bid))).exists) {
                isCheckBooking = true;
            }
            const booking = await t.get(bookingRef);
            const deposits = booking.get("deposit") ?? 0;
            const transferring = booking.get("transferring") ?? 0;
            const totalAllDeposits = deposits + transferring;
            const sub_bookings: { [key: string]: any } = isGroup ? booking.get("sub_bookings") : {};
            const totalServiceChargeAndRoomCharge: number =
                NeutronUtil.getServiceChargeAndRoomCharge(booking, false) + service.total;



            //fields of Activities collection
            const createdTime = now;
            const idService = doc.id;
            const bookingName = service.name;
            const type = 'service';

            //id of activity document
            const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
            const idDocument = activityIdMap['idDocument'];
            const isNewDocument = activityIdMap['isNewDocument'];

            //content of activity
            let activityData;

            if (service.cat === ServiceCategory.bikeRentalCat) {
                if (service.progress === BikeRentalProgress.checkin) {
                    if (isGroup) {
                        const dataUpdate: { [key: string]: any } = {};
                        dataUpdate['sub_bookings.' + service.bid + '.renting_bike_num'] = FieldValue.increment(1);
                        dataUpdate['renting_bike_num'] = FieldValue.increment(1);
                        t.update(hotelRef.collection('bookings').doc(service.sid), dataUpdate);
                    } else {
                        t.update(hotelRef.collection('bookings').doc(service.bid), { 'renting_bike_num': FieldValue.increment(1) });
                    }
                }
                activityData = {
                    'email': service.modified_by,
                    'created_time': createdTime,
                    'id': idService,
                    'booking_id': bookingRef.id,
                    'type': type,
                    'desc': bookingName + NeutronUtil.specificChar + service.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar + 'bike_rental' + NeutronUtil.specificChar + service.bike
                };
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
                return MessageUtil.SUCCESS;
            }
            let desc: string = bookingName + NeutronUtil.specificChar + service.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar;
            const usedTimezone = DateUtil.convertUpSetTimezone(service.used.toDate(), timezone);
            const monthId = DateUtil.dateToShortStringYearMonth(usedTimezone);
            const data: { [key: string]: any } = {};
            if (service.cat === ServiceCategory.laundryCat) {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + service.bid + '.laundry'] = FieldValue.increment(service.total);
                    dataUpdate['laundry'] = FieldValue.increment(service.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'laundry': FieldValue.increment(service.total) });
                }
                const dayId = DateUtil.dateToShortStringDay(usedTimezone);
                data['data.' + dayId + '.service.laundry.total'] = FieldValue.increment(service.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), data);
                desc += 'laundry_service' + NeutronUtil.specificChar + service.total;
            } else if (service.cat === ServiceCategory.minibarCat) {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + service.bid + '.minibar'] = FieldValue.increment(service.total);
                    dataUpdate['minibar'] = FieldValue.increment(service.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'minibar': FieldValue.increment(service.total) });
                }
                //total item of minibar when ordered
                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');
                const dataUpdateWarehouse: { [key: string]: any } = {};
                const dayId = DateUtil.dateToShortStringDay(usedTimezone);
                for (const item in service.items) {
                    const amount = service.items[item].amount;
                    const total = amount * service.items[item].price;
                    data['data.' + dayId + '.service.minibar.items.' + item + '.num'] = FieldValue.increment(amount);
                    data['data.' + dayId + '.service.minibar.items.' + item + '.total'] = FieldValue.increment(total);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.minibar && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(-amount);
                    }
                }
                data['data.' + dayId + '.service.minibar.total'] = FieldValue.increment(service.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), data);
                if (isAutoExportWhenCreateService && Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }
                desc += 'minibar_service' + NeutronUtil.specificChar + service.total;
            } else if (service.cat === ServiceCategory.restaurantCat) {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + service.bid + '.restaurant'] = FieldValue.increment(service.total);
                    dataUpdate['restaurant'] = FieldValue.increment(service.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef, { 'restaurant': FieldValue.increment(service.total) });
                }
                const dayId = DateUtil.dateToShortStringDay(usedTimezone);
                t.update(hotelRef.collection('daily_data').doc(monthId), {
                    [`data.${dayId}.service.restaurant.detail.${service.res_id}`]: FieldValue.increment(service.total),
                    [`data.${dayId}.service.restaurant.total`]: FieldValue.increment(service.total)
                });
                desc += 'restaurant_service' + NeutronUtil.specificChar + service.total;
            } else if (service.cat === ServiceCategory.extraGuestCat) {
                // const end = DateUtil.convertUpSetTimezone(service.end.toDate(), timezone);
                // const start = DateUtil.convertUpSetTimezone(service.start.toDate(), timezone);
                // const basicBookingDoc = await hotelRef.collection('basic_bookings').doc(service.bid).get();
                // const breakfast: boolean = basicBookingDoc.get('breakfast');
                // const typeTourists: string = basicBookingDoc.data()?.type_tourists ?? '';
                // const country: string = basicBookingDoc.data()?.country ?? '';

                // const lengthStay = DateUtil.getDateRange(start, end);
                // const basicBookingData: { [key: string]: any } = {};
                // let dailyGuestBreakfastData: { [key: string]: any } = {};
                // const inMonthId = DateUtil.dateToShortStringYearMonth(start);
                // const outMonthId = DateUtil.dateToShortStringYearMonth(end);
                // const dayBooked = DateUtil.dateToShortStringDay(start);
                // dailyGuestBreakfastData['data.' + dayBooked + '.service.extra_guest.total'] = FieldValue.increment(service.total);

                // let isChangeMonth = false;
                // for (let i = 0; i < lengthStay; i++) {
                //     const day = DateUtil.addDate(start, i);
                //     const date = DateUtil.dateToShortString(day);
                //     const dayId = DateUtil.dateToShortStringDay(day);

                //     if (inMonthId !== outMonthId && isChangeMonth === false && DateUtil.dateToShortStringYearMonth(day) === outMonthId) {
                //         batch.update(hotelRef.collection('daily_data').doc(inMonthId), dailyGuestBreakfastData);
                //         dailyGuestBreakfastData = {};
                //         isChangeMonth = true;
                //     }
                //     dailyGuestBreakfastData['data.' + dayId + '.guest.' + service.type] = FieldValue.increment(service.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.breakfast.' + service.type] = FieldValue.increment(breakfast ? service.number : 0);
                //     dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(service.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(service.number);
                //     basicBookingData['extra_' + service.type + '.' + date] =
                //         FieldValue.increment(service.number);
                // }

                // if (isChangeMonth) {
                //     batch.update(hotelRef.collection('daily_data').doc(outMonthId), dailyGuestBreakfastData);
                // } else {
                //     batch.update(hotelRef.collection('daily_data').doc(inMonthId), dailyGuestBreakfastData);
                // }
                // batch.update(hotelRef.collection('basic_bookings').doc(isGroup ? service.bid : bookingRef.id), basicBookingData);

                await NeutronUtil.updateExtraGuestCollectionDailyDataWithBatch(t, hotelRef, service, true, timezone, true);

                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + service.bid + '.extra_guest'] = FieldValue.increment(service.total);
                    dataUpdate['extra_guest'] = FieldValue.increment(service.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'extra_guest': FieldValue.increment(service.total) });
                }

                desc += 'extra_guest_service' + NeutronUtil.specificChar + service.total;
            } else if (service.cat === ServiceCategory.otherCat) {
                const dayId = DateUtil.dateToShortStringDay(usedTimezone);
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    if (!isBookingGroupParent) dataUpdate['sub_bookings.' + service.bid + '.other'] = FieldValue.increment(service.total);
                    dataUpdate['other'] = FieldValue.increment(service.total);
                    if (service.type === 'ota') {
                        dataUpdate['ota_service'] = FieldValue.increment(service.total);
                    }
                    t.update(bookingRef, dataUpdate);
                } else {
                    if (service.type === 'ota') {
                        t.update(bookingRef,
                            { 'other': FieldValue.increment(service.total), 'ota_service': FieldValue.increment(service.total) });
                    } else {
                        t.update(bookingRef,
                            { 'other': FieldValue.increment(service.total) });
                    }
                }
                data['data.' + dayId + '.service.other.' + service.type + '.total'] = FieldValue.increment(service.total);
                data['data.' + dayId + '.service.other.total'] = FieldValue.increment(service.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), data);
                desc += 'other_service' + NeutronUtil.specificChar + service.total;
            } else if (service.cat === ServiceCategory.insideRestaurantCat) {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + service.bid + '.inside_restaurant'] = FieldValue.increment(service.total);
                    dataUpdate['inside_restaurant'] = FieldValue.increment(service.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'inside_restaurant': FieldValue.increment(service.total) });
                }
                //total item of minibar when ordered
                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');

                const dataUpdateWarehouse: { [key: string]: any } = {};
                const dayId = DateUtil.dateToShortStringDay(usedTimezone);
                for (const item in service.items) {
                    const amount = service.items[item].amount;
                    const total = amount * service.items[item].price;
                    data['data.' + dayId + '.service.inside_restaurant.items.' + item + '.num'] = FieldValue.increment(amount);
                    data['data.' + dayId + '.service.inside_restaurant.items.' + item + '.total'] = FieldValue.increment(total);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.restaurant && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(-amount);
                    }
                }
                data['data.' + dayId + '.service.inside_restaurant.total'] = FieldValue.increment(service.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), data);
                if (Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }
                desc += 'inside_restaurant_service' + NeutronUtil.specificChar + service.total;
            }
            if (hotelPackage !== HotelPackage.basic && desc !== bookingName + NeutronUtil.specificChar + service.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar) {
                activityData = {
                    'email': service.modified_by,
                    'created_time': createdTime,
                    'id': idService,
                    'booking_id': bookingRef.id,
                    'type': type,
                    'desc': desc
                };
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
            await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, service.bid, isCheckBooking);
            return MessageUtil.SUCCESS;

        });
        return res;
    });

// deploy here
exports.deleteService = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/services/{serviceID}')
    .onDelete(async (doc, _) => {
        const res: string = await firestore.runTransaction(async (t) => {
            const hotelRef = doc.ref.parent.parent?.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
            }
            const hotelDoc = await t.get(hotelRef);
            const hotelAutoExportItemStatus = hotelDoc.get('auto_export_items');
            const isAutoExportWhenCreateService = (hotelAutoExportItemStatus == undefined || hotelAutoExportItemStatus == '0')
            
            const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;
            const bookingRef = doc.ref.parent.parent;
            if (bookingRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const service = doc.data();
            const isGroup = service.group ?? false;
            const timezone = service.time_zone;
            const now = new Date();

            let isCheckBooking: boolean = false;
            if ((await t.get(hotelRef.collection('basic_bookings').doc(service.bid))).exists) {
                isCheckBooking = true;
            }
            const booking = await t.get(bookingRef);
            const deposits = booking.get("deposit") ?? 0;
            const transferring = booking.get("transferring") ?? 0;
            const totalAllDeposits = deposits + transferring;
            const sub_bookings: { [key: string]: any } = isGroup ? booking.get("sub_bookings") : {};
            const totalServiceChargeAndRoomCharge: number =
                NeutronUtil.getServiceChargeAndRoomCharge(booking, false) - service.total;

            if (service.cat === ServiceCategory.bikeRentalCat && service.progress === BikeRentalProgress.checkin) {
                if (isGroup) {
                    await hotelRef.collection('bookings').doc(service.sid).update({
                        'renting_bike_num': FieldValue.increment(-1),
                        ['sub_bookings.' + service.bid + '.renting_bike_num']: FieldValue.increment(-1)
                    });
                } else {
                    await hotelRef.collection('bookings').doc(service.bid).update({
                        'renting_bike_num': FieldValue.increment(-1)
                    });
                }
            }

            const used = DateUtil.convertUpSetTimezone(service.used.toDate(), timezone);
            const dayId: string = DateUtil.dateToShortStringDay(used);

            //update daily-data
            const dailyData: { [key: string]: any } = {};
            if (service.cat === ServiceCategory.minibarCat) {
                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');
                const dataUpdateWarehouse: { [key: string]: any } = {};
                for (const item in service.items) {
                    const amount = service.items[item].amount;
                    const total = amount * service.items[item].price;
                    dailyData['data.' + dayId + '.service.minibar.items.' + item + '.num'] = FieldValue.increment(-amount);
                    dailyData['data.' + dayId + '.service.minibar.items.' + item + '.total'] = FieldValue.increment(-total);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.minibar && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(amount);
                    }
                }
                if (Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }
            } else if (service.cat === ServiceCategory.insideRestaurantCat) {
                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');
                const dataUpdateWarehouse: { [key: string]: any } = {};
                for (const item in service.items) {
                    const amount = service.items[item].amount;
                    const total = amount * service.items[item].price;
                    dailyData['data.' + dayId + '.service.inside_restaurant.items.' + item + '.num'] = FieldValue.increment(-amount);
                    dailyData['data.' + dayId + '.service.inside_restaurant.items.' + item + '.total'] = FieldValue.increment(-total);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.restaurant && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(amount);
                    }
                }
                if (isAutoExportWhenCreateService && Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }
            }

            let field = 'data.' + dayId + '.service.' + service.cat;
            if (service.cat === ServiceCategory.otherCat && service.type !== undefined) {
                field += "." + service.type;
            }
            field += ".total";

            if (service.cat !== ServiceCategory.bikeRentalCat ||
                service.progress === BikeRentalProgress.checkout) {
                //Bike rental was checked out
                dailyData[field] = FieldValue.increment(-service.total);
            }
            if (service.cat === ServiceCategory.otherCat) {
                dailyData['data.' + dayId + '.service.other.total'] = FieldValue.increment(-service.total);
            } else if (service.cat === ServiceCategory.restaurantCat) {
                dailyData[`data.${dayId}.service.restaurant.detail.${service.res_id}`] = FieldValue.increment(-service.total);
            }

            if (service.used !== undefined) {
                const monthId = DateUtil.dateToShortStringYearMonth(used);
                t.update(hotelRef.collection('daily_data').doc(monthId), dailyData);
            }

            //update booking-data
            const bookingData: { [key: string]: any } = {};
            if (service.cat === ServiceCategory.extraGuestCat) {
                await NeutronUtil.updateExtraGuestCollectionDailyDataWithBatch(t, hotelRef, service, false, timezone, false);
                // const end = DateUtil.convertUpSetTimezone(service.end.toDate(), timezone);
                // const start = DateUtil.convertUpSetTimezone(service.start.toDate(), timezone);
                // const basicBookingDoc = await hotelRef.collection('basic_bookings').doc(service.bid).get();
                // const typeTourists: string = basicBookingDoc.data()?.type_tourists ?? '';
                // const country: string = basicBookingDoc.data()?.country ?? '';
                // const breakfast: boolean = basicBookingDoc.get('breakfast');
                // const lengthStay = DateUtil.getDateRange(start, end);
                // const basicBookingData: { [key: string]: any } = {};
                // let dailyGuestBreakfastData: { [key: string]: any } = {};
                // const inMonthId = DateUtil.dateToShortStringYearMonth(start);
                // const outMonthId: string = DateUtil.dateToShortStringYearMonth(end);
                // let isChangeMonth = false;
                // for (let i = 0; i < lengthStay; i++) {
                //     const day = DateUtil.addDate(start, i);
                //     const date = DateUtil.dateToShortString(day);
                //     const dayIdExtraGuest = DateUtil.dateToShortStringDay(day);
                //     if (inMonthId !== outMonthId && isChangeMonth === false && DateUtil.dateToShortStringYearMonth(day) === outMonthId) {
                //         batch.update(hotelRef.collection('daily_data').doc(inMonthId), dailyGuestBreakfastData);
                //         dailyGuestBreakfastData = {};
                //         isChangeMonth = true;
                //     }
                //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.guest.' + service.type] = FieldValue.increment(-service.number);
                //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.breakfast.' + service.type] = FieldValue.increment(breakfast ? -service.number : 0);

                //     // if (hotelRef.id === 'GzmJUslMKbfqw25shKLJ' || hotelRef.id === 'c9DNrzYtVxog1kDc5X13') {
                //     //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(-service.number);
                //     //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(-service.number);
                //     // }
                //     // type_tourists
                //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(-service.number);
                //     dailyGuestBreakfastData['data.' + dayIdExtraGuest + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(-service.number);

                //     basicBookingData['extra_' + service.type + '.' + date] =
                //         FieldValue.increment(-service.number);
                // }
                // if (isChangeMonth) {
                //     batch.update(hotelRef.collection('daily_data').doc(outMonthId), dailyGuestBreakfastData);
                // } else {
                //     batch.update(hotelRef.collection('daily_data').doc(inMonthId), dailyGuestBreakfastData);
                // }
                // batch.update(hotelRef.collection('basic_bookings').doc(isGroup ? service.bid : bookingRef.id), basicBookingData);
            }

            if (service.cat !== ServiceCategory.bikeRentalCat || service.progress === BikeRentalProgress.checkout) {
                bookingData[service.cat] = FieldValue.increment(-service.total);
            }

            if (service.cat === ServiceCategory.otherCat && service.type === 'ota') {
                bookingData['ota_service'] = FieldValue.increment(-service.total);
            }

            if (isGroup) {
                bookingData['sub_bookings.' + service.bid + '.' + service.cat] = FieldValue.increment(-service.total);
            }

            if (hotelPackage !== HotelPackage.basic) {
                //id of activity document
                const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
                const idDocument = activityIdMap['idDocument'];
                const isNewDocument = activityIdMap['isNewDocument'];

                const bookingDeleteData = (await doc.ref.parent.parent!.get()).data();
                const activityData = {
                    'email': service.modified_by,
                    'created_time': now,
                    'type': 'service',
                    'desc': bookingDeleteData!.name + NeutronUtil.specificChar + (bookingDeleteData!.room ?? bookingDeleteData!['sub_bookings'][service.bid]['room']) + NeutronUtil.specificChar + 'delete' + NeutronUtil.specificChar + service.cat + '_service'
                };
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

            };
            await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, service.bid, isCheckBooking);
            t.update(bookingRef, bookingData);
            return MessageUtil.SUCCESS;
        });
        return res;
    });

// deploy here
exports.updateService = functions.firestore
    .document('hotels/{hotelID}/bookings/{bookingID}/services/{serviceID}')
    .onUpdate(async (change, _) => {
        const res: string = await firestore.runTransaction(async (t) => {
            const beforeService = change.before.data();
            const afterService = change.after.data();
            const isGroup = beforeService.group;

            const timezone = beforeService.time_zone;
            const hotelRef = change.before.ref.parent.parent?.parent.parent;
            if (hotelRef === undefined || hotelRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
            }
            const hotelDoc = await t.get(hotelRef);
            const hotelAutoExportItemStatus = hotelDoc.get('auto_export_items');
            const isAutoExportWhenCreateService = (hotelAutoExportItemStatus == undefined || hotelAutoExportItemStatus == '0')
            
            const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;
            const bookingRef = change.before.ref.parent.parent;
            if (bookingRef === null) {
                throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
            }
            const booking = await t.get(bookingRef);
            let isCheckBooking: boolean = false;
            if ((await t.get(hotelRef.collection('basic_bookings').doc(booking.id))).exists) {
                isCheckBooking = true;
            }
            const deposits = booking.get("deposit") ?? 0;
            const transferring = booking.get("transferring") ?? 0;
            const totalAllDeposits = deposits + transferring;
            const sub_bookings: { [key: string]: any } = isGroup ? booking.get("sub_bookings") : {};
            const totalServiceChargeAndRoomCharge: number =
                NeutronUtil.getServiceChargeAndRoomCharge(booking, false) + (afterService.total - beforeService.total);

            const bookingData = (await change.after.ref.parent.parent!.get()).data();
            const nowInUs = new Date();
            //fields of Activities collection
            const bookingName = bookingData!.name;
            let desc;


            if (beforeService.cat === 'minibar') {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + beforeService.bid + '.minibar'] = FieldValue.increment(afterService.total - beforeService.total);
                    dataUpdate['minibar'] = FieldValue.increment(afterService.total - beforeService.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'minibar': FieldValue.increment(afterService.total - beforeService.total) });
                }
                const used = DateUtil.convertUpSetTimezone(beforeService.used.toDate(), timezone);
                const monthId = DateUtil.dateToShortStringYearMonth(used);
                const dayId = DateUtil.dateToShortStringDay(used);

                const minibarData: { [key: string]: any } = {};

                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');
                const dataUpdateWarehouse: { [key: string]: any } = {};

                for (const item in afterService.items) {
                    const beforeAmount = beforeService.items[item].amount;
                    const beforeTotal = beforeAmount * beforeService.items[item].price;
                    const afterAmount = afterService.items[item].amount;
                    const afterTotal = afterAmount * afterService.items[item].price;
                    minibarData['data.' + dayId + '.service.minibar.items.' + item + '.num'] = FieldValue.increment(afterAmount - beforeAmount);
                    minibarData['data.' + dayId + '.service.minibar.items.' + item + '.total'] = FieldValue.increment(afterTotal - beforeTotal);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.minibar && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(beforeAmount - afterAmount);
                    }
                }
                minibarData['data.' + dayId + '.service.minibar.total'] = FieldValue.increment(afterService.total - beforeService.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), minibarData);
                if (isAutoExportWhenCreateService && Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }

                if (beforeService.total !== afterService.total) {
                    desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'minibar_service' + NeutronUtil.specificChar + beforeService.total + NeutronUtil.specificChar + afterService.total;
                }
            } else if (beforeService.cat === 'laundry') {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + beforeService.bid + '.laundry'] = FieldValue.increment(afterService.total - beforeService.total);
                    dataUpdate['laundry'] = FieldValue.increment(afterService.total - beforeService.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'laundry': FieldValue.increment(afterService.total - beforeService.total) });
                }

                const used = DateUtil.convertUpSetTimezone(beforeService.used.toDate(), timezone);
                const monthId = DateUtil.dateToShortStringYearMonth(used);
                const dayId = DateUtil.dateToShortStringDay(used);
                const laundryData: { [key: string]: any } = {};
                laundryData['data.' + dayId + '.service.laundry.total'] = FieldValue.increment(afterService.total - beforeService.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), laundryData);
                if (beforeService.total !== afterService.total) {
                    desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'laundry_service' + NeutronUtil.specificChar + beforeService.total + NeutronUtil.specificChar + afterService.total;
                }
            } else if (beforeService.cat === 'bike_rental') {
                const beforeProgress = beforeService.progress;
                const afterProgress = afterService.progress;

                if (afterProgress !== beforeProgress) {
                    if (afterProgress === BikeRentalProgress.checkin && beforeProgress === BikeRentalProgress.booked) {
                        desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'checked_in_bike' + NeutronUtil.specificChar + afterService.bike;
                        //increase number of rent-bike in collection 'bookings' by 1
                        if (isGroup) {
                            const dataUpdate: { [key: string]: any } = {};
                            dataUpdate['sub_bookings.' + beforeService.bid + '.renting_bike_num'] = FieldValue.increment(1);
                            dataUpdate['renting_bike_num'] = FieldValue.increment(1);
                            t.update(bookingRef,
                                dataUpdate);
                        } else {
                            t.update(bookingRef,
                                { 'renting_bike_num': FieldValue.increment(1) });

                        }
                    } else if (afterProgress === BikeRentalProgress.checkout && beforeProgress === BikeRentalProgress.checkin) {
                        //Check-out bike -> update total money service and decrease number of rent-bike by 1
                        if (isGroup) {
                            const dataUpdate: { [key: string]: any } = {};
                            dataUpdate['sub_bookings.' + beforeService.bid + '.renting_bike_num'] = FieldValue.increment(-1);
                            dataUpdate['sub_bookings.' + beforeService.bid + '.bike_rental'] = FieldValue.increment(afterService.total);
                            dataUpdate['renting_bike_num'] = FieldValue.increment(-1);
                            dataUpdate['bike_rental'] = FieldValue.increment(afterService.total);
                            t.update(bookingRef,
                                dataUpdate);
                        } else {
                            t.update(bookingRef,
                                {
                                    'renting_bike_num': FieldValue.increment(-1),
                                    'bike_rental': FieldValue.increment(afterService.total)
                                });
                        }

                        desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'checked_out_bike' + NeutronUtil.specificChar + afterService.bike;

                        const bikeRentalData: { [key: string]: any } = {};
                        let monthId: string = ''
                        if (afterService.used !== undefined) {
                            const used = DateUtil.convertUpSetTimezone(afterService.used.toDate(), timezone);
                            const dayId = DateUtil.dateToShortStringDay(used);
                            monthId = DateUtil.dateToShortStringYearMonth(used);
                            bikeRentalData['data.' + dayId + '.service.bike_rental.total'] = FieldValue.increment(afterService.total);
                        } else {
                            const now = DateUtil.convertUpSetTimezone(nowInUs, timezone);
                            const dayId = DateUtil.dateToShortStringDay(now);
                            monthId = DateUtil.dateToShortStringYearMonth(now);
                            bikeRentalData['data.' + dayId + '.service.bike_rental.total'] = FieldValue.increment(afterService.total);
                        }
                        t.update(hotelRef.collection('daily_data').doc(monthId), bikeRentalData);
                    }
                } else {
                    if (afterProgress === BikeRentalProgress.checkin && afterService.bike !== beforeService.bike) {
                        // //Change bike
                        desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'change_bike' + NeutronUtil.specificChar + beforeService.bike + NeutronUtil.specificChar + afterService.bike;
                    }
                }
            } else if (beforeService.cat === 'extra_guest') {

                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + beforeService.bid + '.extra_guest'] = FieldValue.increment(afterService.total - beforeService.total);
                    dataUpdate['extra_guest'] = FieldValue.increment(afterService.total - beforeService.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'extra_guest': FieldValue.increment(afterService.total - beforeService.total) });
                }

                await NeutronUtil.updateExtraGuestCollectionDailyDataWithBatch(t, hotelRef, beforeService, false, timezone, true);
                await NeutronUtil.updateExtraGuestCollectionDailyDataWithBatch(t, hotelRef, afterService, true, timezone, true);

                // const endBefore = DateUtil.convertUpSetTimezone(beforeService.end.toDate(), timezone);
                // const startBefore = DateUtil.convertUpSetTimezone(beforeService.start.toDate(), timezone);
                // const basicBookingDoc = await hotelRef.collection('basic_bookings').doc(beforeService.bid).get();
                // const breakfast: boolean = basicBookingDoc.get('breakfast');
                // const typeTourists: string = basicBookingDoc.data()?.type_tourists ?? '';
                // const country: string = basicBookingDoc.data()?.country ?? '';

                // const inMonthIdBefore = DateUtil.dateToShortStringYearMonth(startBefore);
                // const outMonthIdBefore = DateUtil.dateToShortStringYearMonth(endBefore);
                // let dailyGuestBreakfastData: { [key: string]: any } = {};
                // let isChangeMonth = false;
                // const basicBookingDataBefore: { [key: string]: any } = {};
                // const lengthStayBefore = DateUtil.getDateRange(startBefore, endBefore);
                // for (let i = 0; i < lengthStayBefore; i++) {
                //     const day = DateUtil.addDate(startBefore, i);
                //     const date = DateUtil.dateToShortString(day);
                //     const dayId = DateUtil.dateToShortStringDay(day);

                //     if (inMonthIdBefore !== outMonthIdBefore && DateUtil.dateToShortStringYearMonth(day) === outMonthIdBefore && isChangeMonth === false) {
                //         batch.update(hotelRef.collection('daily_data').doc(inMonthIdBefore), dailyGuestBreakfastData);
                //         dailyGuestBreakfastData = {};
                //         isChangeMonth = true;
                //     }
                //     dailyGuestBreakfastData['data.' + dayId + '.guest.' + beforeService.type] = FieldValue.increment(-beforeService.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.breakfast.' + beforeService.type] = FieldValue.increment(breakfast ? - beforeService.number : 0);
                //     // if (hotelRef.id === 'GzmJUslMKbfqw25shKLJ' || hotelRef.id === 'c9DNrzYtVxog1kDc5X13') {
                //     //     dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(-beforeService.number);
                //     //     dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(-beforeService.number);
                //     // }

                //     // type_tourists
                //     dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(-beforeService.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(-beforeService.number);
                //     basicBookingDataBefore['extra_' + beforeService.type + '.' + date] =
                //         FieldValue.increment(-beforeService.number);
                // }
                // if (isChangeMonth) {
                //     batch.update(hotelRef.collection('daily_data').doc(outMonthIdBefore), dailyGuestBreakfastData);
                // } else {
                //     batch.update(hotelRef.collection('daily_data').doc(inMonthIdBefore), dailyGuestBreakfastData);
                // }

                // batch.update(hotelRef.collection('basic_bookings').doc(isGroup ? beforeService.bid : bookingRef.id), basicBookingDataBefore);
                // const endAfter = DateUtil.convertUpSetTimezone(afterService.end.toDate(), timezone);
                // const startAfter = DateUtil.convertUpSetTimezone(afterService.start.toDate(), timezone);
                // const inMonthIdAfter = DateUtil.dateToShortStringYearMonth(startAfter);
                // const outMonthIdAfter = DateUtil.dateToShortStringYearMonth(endAfter);
                // dailyGuestBreakfastData = {};
                // isChangeMonth = false;
                // const basicBookingDataAfter: { [key: string]: any } = {};
                // const lengthStayAfter = DateUtil.getDateRange(startAfter, endAfter);
                // for (let i = 0; i < lengthStayAfter; i++) {
                //     const day = DateUtil.addDate(startAfter, i);
                //     const date = DateUtil.dateToShortString(day);
                //     const dayId = DateUtil.dateToShortStringDay(day);

                //     if (inMonthIdAfter !== outMonthIdAfter && DateUtil.dateToShortStringYearMonth(day) === outMonthIdAfter && isChangeMonth === false) {
                //         batch.update(hotelRef.collection('daily_data').doc(inMonthIdAfter), dailyGuestBreakfastData);
                //         dailyGuestBreakfastData = {};
                //         isChangeMonth = true;
                //     }

                //     dailyGuestBreakfastData['data.' + dayId + '.guest.' + afterService.type] = FieldValue.increment(afterService.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.breakfast.' + afterService.type] = FieldValue.increment(breakfast ? afterService.number : 0);

                //     // if (hotelRef.id === 'GzmJUslMKbfqw25shKLJ' || hotelRef.id === 'c9DNrzYtVxog1kDc5X13') {
                //     //     dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(afterService.number);
                //     //     dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(afterService.number);
                //     // }
                //     // type_tourist
                //     dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(afterService.number);
                //     dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(afterService.number);

                //     basicBookingDataAfter['extra_' + afterService.type + '.' + date] =
                //         FieldValue.increment(afterService.number);
                // }
                // if (isChangeMonth) {
                //     batch.update(hotelRef.collection('daily_data').doc(outMonthIdAfter), dailyGuestBreakfastData);
                // } else {
                //     batch.update(hotelRef.collection('daily_data').doc(inMonthIdAfter), dailyGuestBreakfastData);
                // }
                // batch.update(hotelRef.collection('basic_bookings').doc(isGroup ? afterService.bid : bookingRef.id), basicBookingDataAfter);
                // const used = DateUtil.convertUpSetTimezone(afterService.used.toDate(), timezone);
                // const monthId = DateUtil.dateToShortStringYearMonth(used);
                // const dayId = DateUtil.dateToShortStringDay(used);
                // const extraGuestData: { [key: string]: any } = {};
                // extraGuestData['data.' + dayId + '.service.extra_guest.total'] = FieldValue.increment(afterService.total - beforeService.total);
                // batch.update(hotelRef.collection('daily_data').doc(monthId), extraGuestData);

                if (beforeService.total !== afterService.total) {
                    desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'extra_guest_service' + NeutronUtil.specificChar + beforeService.total + NeutronUtil.specificChar + afterService.total;
                }
            } else if (beforeService.cat === 'other') {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + beforeService.bid + '.other'] = FieldValue.increment(afterService.total - beforeService.total);
                    dataUpdate['other'] = FieldValue.increment(afterService.total - beforeService.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'other': FieldValue.increment(afterService.total - beforeService.total) });
                }

                const used = DateUtil.convertUpSetTimezone(beforeService.used.toDate(), timezone);
                const monthId = DateUtil.dateToShortStringYearMonth(used);
                const dayId = DateUtil.dateToShortStringDay(used);
                const otherData: { [key: string]: any } = {};
                otherData['data.' + dayId + '.service.other.total'] = FieldValue.increment(afterService.total - beforeService.total);
                if (beforeService.type === afterService.type) {
                    otherData['data.' + dayId + '.service.other.' + beforeService.type + '.total'] = FieldValue.increment(afterService.total - beforeService.total);
                    otherData['data.' + dayId + '.service.other.' + afterService.type + '.total'] = FieldValue.increment(afterService.total - beforeService.total);
                } else {
                    otherData['data.' + dayId + '.service.other.' + beforeService.type + '.total'] = FieldValue.increment(-beforeService.total);
                    otherData['data.' + dayId + '.service.other.' + afterService.type + '.total'] = FieldValue.increment(afterService.total);
                }
                t.update(hotelRef.collection('daily_data').doc(monthId), otherData);
                if (beforeService.total !== afterService.total) {
                    desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'other_service' + NeutronUtil.specificChar + beforeService.total + NeutronUtil.specificChar + afterService.total;
                }
            } else if (beforeService.cat === ServiceCategory.insideRestaurantCat) {
                if (isGroup) {
                    const dataUpdate: { [key: string]: any } = {};
                    dataUpdate['sub_bookings.' + beforeService.bid + '.inside_restaurant'] = FieldValue.increment(afterService.total - beforeService.total);
                    dataUpdate['inside_restaurant'] = FieldValue.increment(afterService.total - beforeService.total);
                    t.update(bookingRef, dataUpdate);
                } else {
                    t.update(bookingRef,
                        { 'inside_restaurant': FieldValue.increment(afterService.total - beforeService.total) });
                }
                const used = DateUtil.convertUpSetTimezone(beforeService.used.toDate(), timezone);
                const monthId = DateUtil.dateToShortStringYearMonth(used);
                const dayId = DateUtil.dateToShortStringDay(used);

                const insideRestaurantData: { [key: string]: any } = {};

                const itemsOfHotel = (await hotelRef.collection('management').doc('items').get()).get('data');
                const dataUpdateWarehouse: { [key: string]: any } = {};

                for (const item in afterService.items) {
                    const beforeAmount = beforeService.items[item].amount;
                    const beforeTotal = beforeAmount * beforeService.items[item].price;
                    const afterAmount = afterService.items[item].amount;
                    const afterTotal = afterAmount * afterService.items[item].price;
                    insideRestaurantData['data.' + dayId + '.service.inside_restaurant.items.' + item + '.num'] = FieldValue.increment(afterAmount - beforeAmount);
                    insideRestaurantData['data.' + dayId + '.service.inside_restaurant.items.' + item + '.total'] = FieldValue.increment(afterTotal - beforeTotal);

                    //update remain of item in warehouse
                    if (itemsOfHotel[item]['type'] === ItemType.restaurant && itemsOfHotel[item]['warehouse'] !== null && itemsOfHotel[item]['warehouse'] !== '') {
                        dataUpdateWarehouse[`data.${itemsOfHotel[item]['warehouse']}.items.${item}`] = FieldValue.increment(beforeAmount - afterAmount);
                    }
                }
                insideRestaurantData['data.' + dayId + '.service.inside_restaurant.total'] = FieldValue.increment(afterService.total - beforeService.total);
                t.update(hotelRef.collection('daily_data').doc(monthId), insideRestaurantData);
                if (isAutoExportWhenCreateService && Object.keys(dataUpdateWarehouse).length > 0) {
                    t.update(hotelRef.collection('management').doc('warehouses'), dataUpdateWarehouse);
                }

                if (beforeService.total !== afterService.total) {
                    desc = bookingName + NeutronUtil.specificChar + (bookingData!.room ?? bookingData!['sub_bookings'][afterService.bid]['room']) + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'inside_restaurant_service' + NeutronUtil.specificChar + beforeService.total + NeutronUtil.specificChar + afterService.total;
                }
            } else {
                return MessageUtil.FAIL;
            }

            if (desc !== undefined) {
                const activityData = {
                    'email': afterService.modified_by,
                    'created_time': nowInUs,
                    'id': change.before.id,
                    'booking_id': bookingRef.id,
                    'type': 'service',
                    'desc': desc
                };
                //id of activity document
                const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
                const idDocument = activityIdMap['idDocument'];
                const isNewDocument = activityIdMap['isNewDocument'];

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
            }
            await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, booking.id, isCheckBooking);
            return MessageUtil.SUCCESS;
        });
        return res;
    });

function isServiceEditable(serviceType: string, status: number, isUserCanUpdateDatabase: boolean): boolean {
    switch (serviceType) {
        case ServiceCategory.minibarCat:
        case ServiceCategory.laundryCat:
        case ServiceCategory.insideRestaurantCat:
            return status === BookingStatus.checkin || (status === BookingStatus.booked && isUserCanUpdateDatabase)
        case ServiceCategory.extraGuestCat:
            return status === BookingStatus.booked || status === BookingStatus.checkin;
        case ServiceCategory.otherCat:
            return status === BookingStatus.booked || status === BookingStatus.checkin;
        case ServiceCategory.extraHourCat:
            return status === BookingStatus.booked || status === BookingStatus.checkin;
        case ServiceCategory.electricityWaterCat:
            return status === BookingStatus.booked || status === BookingStatus.checkin;
        case ServiceCategory.extraBedCat:
            return status === BookingStatus.booked;
        case ServiceCategory.bikeRentalCat:
            return status === BookingStatus.booked || status === BookingStatus.checkin;
        case ServiceCategory.restaurantCat:
            return isUserCanUpdateDatabase && (status === BookingStatus.booked || status === BookingStatus.checkin);
        default:
            return false;
    }
}

//Booking add service such as minibar, laundry, extra_guest, bikerental, other
exports.addBookingService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId: string = data.booking_id;
    const bookingSID: string = data.sid;
    const isGroup: boolean = data.group;
    const serviceCat = data.data_service.cat;
    const serviceItems = data.data_service.items;
    const serviceTotal = data.data_service.total;
    const serviceStatus = data.data_service.status;
    const serviceUsedTimezone: Date = new Date(data.data_service.used);
    const serviceStartTimezone: Date = new Date(data.data_service.start);
    const serviceEndTimezone: Date = new Date(data.data_service.end);
    const serviceType = data.data_service.type;
    const serviceNumber = data.data_service.number;
    const servicePrice = data.data_service.price;
    const serviceSupplier = data.data_service.supplier;
    const serviceBike = data.data_service.bike;
    const serviceProgress = data.data_service.progress;
    const serviceDesc = data.data_service.desc;
    const emailSaler = data.saler;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const timezone = hotelDoc.get('timezone');
    const serviceUsedServer: Date = DateUtil.convertOffSetTimezone(serviceUsedTimezone, timezone);
    const serviceStartServer: Date = DateUtil.convertOffSetTimezone(serviceStartTimezone, timezone);
    const serviceEndServer: Date = DateUtil.convertOffSetTimezone(serviceEndTimezone, timezone);
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesAddServiceForBooking;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));
    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = await admin.firestore().runTransaction(async (t) => {
        let bookingDoc;
        if (isGroup) {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingSID));
        } else {
            bookingDoc = await t.get(hotelRef.collection('bookings').doc(bookingId));
        }
        const booking = bookingDoc.data();
        if (!bookingDoc.exists || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const roomBooking = isGroup ? booking['sub_bookings'][bookingId]['room'] : booking.room;
        const inDayBookingServer: Date = isGroup ? booking['sub_bookings'][bookingId]['in_date'] : booking.in_date;
        const outDayBookingServer: Date = isGroup ? booking['sub_bookings'][bookingId]['out_date'] : booking.out_date;
        const now = new Date();
        if (!isServiceEditable(serviceCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }

        let service;
        switch (serviceCat) {
            case ServiceCategory.minibarCat:
            case ServiceCategory.insideRestaurantCat:
            case ServiceCategory.laundryCat:
                service = {
                    'created': now,
                    'modified_by': context.auth?.token.email,
                    'used': now,
                    'items': serviceItems,
                    'total': serviceTotal,
                    'cat': serviceCat,
                    'status': serviceStatus,
                    'name': booking.name,
                    'bid': bookingId,
                    'in': inDayBookingServer,
                    'out': outDayBookingServer,
                    'room': roomBooking,
                    'sid': booking.sid,
                    'hotel': hotelId,
                    'time_zone': timezone,
                    'group': isGroup,
                    'desc': serviceDesc === undefined ? "" : serviceDesc,
                    'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                };
                break;
            case ServiceCategory.extraGuestCat:
                service = {
                    'created': now,
                    'modified_by': context.auth?.token.email,
                    'used': serviceUsedServer,
                    'total': serviceTotal,
                    'cat': serviceCat,
                    'status': serviceStatus,
                    'start': serviceStartServer,
                    'end': serviceEndServer,
                    'type': serviceType,
                    'number': serviceNumber,
                    'price': servicePrice,
                    'bid': bookingId,
                    'name': booking.name,
                    'in': inDayBookingServer,
                    'out': outDayBookingServer,
                    'room': roomBooking,
                    'group': isGroup,
                    'sid': booking.sid,
                    'hotel': hotelId,
                    'time_zone': timezone,
                    'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                };
                break;
            case ServiceCategory.bikeRentalCat:
                service = {
                    'created': now,
                    'modified_by': context.auth?.token.email,
                    'supplier': serviceSupplier,
                    'total': serviceTotal,
                    'type': serviceType,
                    'start': serviceStartServer,
                    'bike': serviceBike,
                    'status': serviceStatus,
                    'price': servicePrice,
                    'progress': serviceProgress,
                    'cat': serviceCat,
                    'bid': bookingId,
                    'name': booking.name,
                    'in': inDayBookingServer,
                    'out': outDayBookingServer,
                    'room': roomBooking,
                    'sid': booking.sid,
                    'hotel': hotelId,
                    'time_zone': timezone,
                    'group': isGroup,
                    'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                };
                break;
            case ServiceCategory.otherCat:
                service = {
                    'created': now,
                    'modified_by': context.auth?.token.email,
                    'desc': serviceDesc,
                    'supplier': serviceSupplier,
                    'total': serviceTotal,
                    'status': serviceStatus,
                    'type': serviceType,
                    'used': serviceUsedServer,
                    'cat': serviceCat,
                    'bid': bookingId,
                    'name': booking.name,
                    'in': inDayBookingServer,
                    'out': outDayBookingServer,
                    'room': roomBooking,
                    'sid': booking.sid,
                    'hotel': hotelId,
                    'time_zone': timezone,
                    'group': isGroup,
                    'email_saler': emailSaler == "" ? context.auth?.token.email : emailSaler,
                };
                break;
            default:
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BAD_REQUEST);
        }
        if (isGroup) {
            t.set(hotelRef.collection('bookings').doc(bookingSID).collection('services').doc(NumberUtil.getRandomID()), service);
        } else {
            t.set(hotelRef.collection('bookings').doc(bookingId).collection('services').doc(NumberUtil.getRandomID()), service);
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

//Booking update service such as minibar, laundry, extra_guest, bikerental, other
exports.updateBookingService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const serviceId = data.service_id;
    const serviceCat = data.data_service.cat;
    const serviceItems = data.data_service.items;
    const serviceTotal = data.data_service.total;
    const serviceUsedTimezone: Date = new Date(data.data_service.used);
    const serviceStartTimezone: Date = new Date(data.data_service.start);
    const serviceEndTimezone: Date = new Date(data.data_service.end);
    const serviceType = data.data_service.type;
    const serviceNumber = data.data_service.number;
    const servicePrice = data.data_service.price;
    const serviceDesc = data.data_service.desc;
    const serviceSupplier = data.data_service.supplier;
    const bookingSid = data.booking_sid; //id of parent-booking: undefine if booking is not group
    const isGroup = bookingSid === undefined ? false : true;
    const emailSaler = data.saler;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const timezone = hotelDoc.get('timezone');
    const serviceUsedServer: Date = DateUtil.convertOffSetTimezone(serviceUsedTimezone, timezone);
    const serviceStartServer: Date = DateUtil.convertOffSetTimezone(serviceStartTimezone, timezone);
    const serviceEndServer: Date = DateUtil.convertOffSetTimezone(serviceEndTimezone, timezone);
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateServiceForBooking;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));
    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (isGroup && booking['sub_bookings'][bookingId] === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (!isServiceEditable(serviceCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }

        let service;
        switch (serviceCat) {
            case ServiceCategory.minibarCat:
            case ServiceCategory.insideRestaurantCat:
            case ServiceCategory.laundryCat:
                service = {
                    'modified_by': context.auth?.token.email,
                    'items': serviceItems,
                    'total': serviceTotal,
                    'desc': serviceDesc === undefined ? "" : serviceDesc,
                    'email_saler': emailSaler,
                };
                break;
            case ServiceCategory.extraGuestCat:
                service = {
                    'modified_by': context.auth?.token.email,
                    'start': serviceStartServer,
                    'end': serviceEndServer,
                    'total': serviceTotal,
                    'type': serviceType,
                    'number': serviceNumber,
                    'price': servicePrice,
                    'email_saler': emailSaler,
                };
                break;
            case ServiceCategory.otherCat:
                service = {
                    'modified_by': context.auth?.token.email,
                    'total': serviceTotal,
                    'used': serviceUsedServer,
                    'type': serviceType,
                    'desc': serviceDesc,
                    'supplier': serviceSupplier,
                    'email_saler': emailSaler,
                };
                break;
            default:
                throw new functions.https.HttpsError('invalid-argument', MessageUtil.BAD_REQUEST);
        }

        t.update(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId).collection('services').doc(serviceId), service);
        return MessageUtil.SUCCESS;
    });
    return res;
});

//Booking delete service such as minibar, laundry, extra_guest, other
exports.deleteBookingService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSID = data.sid;
    const isGroup = data.group;
    const serviceId = data.service_id;
    const serviceCat = data.service_cat;
    const serviceDeletable: boolean = data.service_deletable;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = serviceCat === ServiceCategory.restaurantCat ? NeutronUtil.rolesDeleteRestaurantService : NeutronUtil.rolesDeleteServiceForBooking;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSID : bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (isGroup && booking['sub_bookings'][bookingId] === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }


        if (!(isServiceEditable(serviceCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase) && serviceDeletable)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }
        if (isGroup) {
            t.delete(hotelRef.collection('bookings').doc(bookingSID).collection('services').doc(serviceId));
        } else {
            t.delete(hotelRef.collection('bookings').doc(bookingId).collection('services').doc(serviceId));
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

//Hotel create new service
exports.createHotelService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const serviceType = data.service_type ?? null;
    const serviceId = data.service_id ?? null;
    const serviceName = data.service_name ?? null;
    const servicePrice = data.service_price ?? null;
    const servicePiron = data.service_piron ?? null;
    const servicePlaundry = data.service_plaundry ?? null;
    const serviceBikeType = data.service_bike_type ?? null;
    // const serviceUnit = data.service_unit ?? null;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCreateOrUpdateHotelService;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        //laundry, bike, other,... => write to management/configurations
        const serviceInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();

        if (serviceInCloud !== undefined && serviceInCloud.data[serviceType][serviceId] !== undefined) {
            throw new functions.https.HttpsError("already-exists", MessageUtil.DUPLICATED_ID);
        }

        let dataServiceHotel;
        switch (serviceType) {
            case 'laundries':
                {
                    const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(serviceInCloud!['data']['laundries']));
                    sourcesDataInCloud.forEach((value, _) => {
                        if (value['name'] === serviceName) {
                            throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
                        }
                    })
                    dataServiceHotel = {
                        'name': serviceName,
                        'plaundry': servicePlaundry,
                        'piron': servicePiron,
                        'active': true
                    }
                }
                break;
            case 'bikes':
                dataServiceHotel = {
                    'price': servicePrice,
                    'type': serviceBikeType,
                    'active': true,
                    'rented': false,
                    'supplier': data.bike_supplier_id
                }
                break;
            case 'other_services':
                {
                    const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(serviceInCloud!['data']['other_services']));
                    sourcesDataInCloud.forEach((value, key) => {
                        if (value['name'] === serviceName) {
                            throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
                        }
                    })
                    dataServiceHotel = {
                        'name': serviceName,
                        'active': true
                    }
                }
                break;
            default:
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
        }

        t.update(hotelRef.collection('management').doc('configurations'), {
            ['data.' + serviceType + '.' + serviceId]: dataServiceHotel
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

//hotel activate or deactivate service
exports.toggleHotelServiceActivation = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const serviceIsActive = data.service_is_active;
    const serviceId = data.service_id;
    const serviceType = data.service_type;

    if (serviceType === 'other_services' && serviceId === 'bike_rental') {
        throw new functions.https.HttpsError("permission-denied", MessageUtil.BIKE_RENTAL_CAN_NOT_DEACTIVE);
    }

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCreateOrUpdateHotelService;

    if (serviceType === 'other_services') {
        rolesAllowed.push(UserRole.accountant);
    }

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    // if (serviceType === 'items') {
    //     await hotelRef.collection('management').doc('items').update({
    //         ['data.' + serviceId + '.active']: serviceIsActive
    //     })
    // } else {
    await hotelRef.collection('management').doc('configurations').update({
        ['data.' + serviceType + '.' + serviceId + '.active']: serviceIsActive
    })
    // }
    return MessageUtil.SUCCESS;
});

//hotel update service
exports.updateHotelService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const serviceType = data.service_type ?? null;
    const serviceId = data.service_id ?? null;
    const serviceName = data.service_name ?? null;
    const servicePrice = data.service_price ?? null;
    const servicePiron = data.service_piron ?? null;
    const servicePlaundry = data.service_plaundry ?? null;
    const serviceBikeType = data.service_bike_type ?? null;
    const serviceWater = data.service_water ?? null;
    const serviceElectricity = data.service_electricity ?? null;
    const serviceAdult = data.service_adult;
    const serviceChild = data.service_child;
    const serviceEarlyCheckin = data.service_early_check_in;
    const serviceLateCheckout = data.service_late_check_out;
    // const serviceUnit = data.service_unit ?? null;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCreateOrUpdateHotelService;

    if (serviceType === 'other_services') {
        rolesAllowed.push(UserRole.accountant);
    }
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = firestore.runTransaction(async (t) => {
        switch (serviceType) {
            case 'laundries':
                {
                    const serviceInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();
                    const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(serviceInCloud!['data']['laundries']));
                    sourcesDataInCloud.forEach((value, key) => {
                        if (key !== serviceId && value['name'] === serviceName) {
                            throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
                        }
                    })
                    t.update(hotelRef.collection('management').doc('configurations'), {
                        ['data.laundries.' + serviceId + '.name']: serviceName,
                        ['data.laundries.' + serviceId + '.piron']: servicePiron,
                        ['data.laundries.' + serviceId + '.plaundry']: servicePlaundry
                    });
                }
                break;
            case 'bikes':
                t.update(hotelRef.collection('management').doc('configurations'), {
                    ['data.bikes.' + serviceId + '.type']: serviceBikeType,
                    ['data.bikes.' + serviceId + '.price']: servicePrice,
                    ['data.bikes.' + serviceId + '.supplier']: data.bike_supplier_id
                });
                break;
            case 'other_services':
                {
                    const serviceInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();
                    const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(serviceInCloud!['data']['other_services']));
                    sourcesDataInCloud.forEach((value, key) => {
                        if (key !== serviceId && value['name'] === serviceName) {
                            throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
                        }
                    })
                    t.update(hotelRef.collection('management').doc('configurations'), {
                        ['data.other_services.' + serviceId + '.name']: serviceName
                    });
                }
                break;
            case 'room_extra':
                const dataUpdate: { [key: string]: any } = {};
                if (serviceAdult !== undefined) {
                    dataUpdate['data.room_extra.adult'] = serviceAdult
                }
                if (serviceChild !== undefined) {
                    dataUpdate['data.room_extra.child'] = serviceChild
                }
                if (serviceEarlyCheckin !== undefined) {
                    dataUpdate['data.room_extra.early_check_in'] = serviceEarlyCheckin
                }
                if (serviceLateCheckout !== undefined) {
                    dataUpdate['data.room_extra.late_check_out'] = serviceLateCheckout
                }

                t.update(hotelRef.collection('management').doc('configurations'), dataUpdate);
                break;
            case 'electricitywater_services':
                {
                    const dataUpdateElectricityWater: { [key: string]: any } = {};
                    dataUpdateElectricityWater['data.electricity_water.electricity'] = serviceElectricity
                    dataUpdateElectricityWater['data.electricity_water.water'] = serviceWater
                    t.update(hotelRef.collection('management').doc('configurations'), dataUpdateElectricityWater);
                }
                break;
            default:
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
        }
        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.updateExtraHour = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const isGroup = bookingSid !== undefined;
    const dataCat = ServiceCategory.extraHourCat;
    const dataEarlyHours = data.extra_hours.early_hours;
    const dataLateHours = data.extra_hours.late_hours;
    const dataEarlyPrice = data.extra_hours.early_price;
    const dataLatePrice = data.extra_hours.late_price;
    const dataTotal = data.extra_hours.total;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const timezone = hotelDoc.get('timezone');
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateExtraBedOrExtraHour;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        if (isGroup && booking['sub_bookings'][bookingId] === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }


        if (!isServiceEditable(dataCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }
        const virtual: boolean = bookingDoc.get('virtual') ?? false;
        let totalExtraHours: number = 0;
        if (isGroup) {
            if (booking['sub_bookings'][bookingId]['extra_hours'] !== undefined) {
                totalExtraHours = (- booking['sub_bookings'][bookingId]['extra_hours']['total'] + dataTotal);
            } else {
                totalExtraHours = dataTotal;
            }
        } else {
            if (booking.extra_hours !== undefined) {
                totalExtraHours = (-booking.extra_hours.total + dataTotal);
            } else {
                totalExtraHours = dataTotal;
            }
        }
        const totalServiceChargeAndRoomCharge: number =
            NeutronUtil.getServiceChargeAndRoomCharge(bookingDoc, false) + totalExtraHours;
        const sub_bookings: { [key: string]: any } = isGroup ? bookingDoc.get("sub_bookings") : {};
        const deposits = booking.deposit ?? 0;
        const transferring = booking.transferring ?? 0;
        const totalAllDeposits = deposits + transferring;

        // update extra_hour for service
        const outDayBookingServer: Date = isGroup ? booking['sub_bookings'][bookingId]['out_date'].toDate() : booking.out_date.toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const monthId = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
        const dayId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
        const dataUpdate: { [key: string]: any } = {};


        const now = new Date();
        const activityData: { [key: string]: any } = {
            'email': context.auth?.token.email,
            'created_time': now,
            'id': bookingId,
            'booking_id': bookingId,
            'type': 'extra_hour'
        };

        if (isGroup) {
            activityData['sid'] = bookingSid;
            if (booking['sub_bookings'][bookingId]['extra_hours'] !== undefined) {
                t.update(hotelRef.collection('bookings').doc(bookingSid), {
                    'extra_hour': FieldValue.increment(- booking['sub_bookings'][bookingId]['extra_hours']['total'] + dataTotal),
                    ['sub_bookings.' + bookingId + '.extra_hours']: {
                        'early_hours': dataEarlyHours,
                        'late_hours': dataLateHours,
                        'early_price': dataEarlyPrice,
                        'late_price': dataLatePrice,
                        'total': dataTotal
                    }
                });
                dataUpdate['data.' + dayId + '.service.extra_hours.total'] = FieldValue.increment(- booking['sub_bookings'][bookingId]['extra_hours']['total'] + dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            } else {
                t.update(hotelRef.collection('bookings').doc(bookingSid), {
                    'extra_hour': FieldValue.increment(dataTotal),
                    ['sub_bookings.' + bookingId + '.extra_hours']: {
                        'early_hours': dataEarlyHours,
                        'late_hours': dataLateHours,
                        'early_price': dataEarlyPrice,
                        'late_price': dataLatePrice,
                        'total': dataTotal
                    }
                });
                dataUpdate['data.' + dayId + '.service.extra_hours.total'] = FieldValue.increment(dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            }

            const subBooking = booking['sub_bookings'][bookingId];
            // const bookingOutDate: Date = new Date(subBooking.out_date['_seconds'] * 1000);
            const bookingExtraHour = subBooking.extra_hours;

            //this mean: updating extraHour
            if (bookingExtraHour !== undefined) {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + subBooking.room + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'extra_hour_service' + NeutronUtil.specificChar + bookingExtraHour.total + NeutronUtil.specificChar + dataTotal;
                //update basic booking for re-draw on status board
                if (dataLateHours !== bookingExtraHour.late_hours) {
                    const newBookingOutDate = DateUtil.addHours(outDayBookingServer, dataLateHours);
                    t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
                        'out_time': newBookingOutDate
                    });
                }
            } else {
                //this mean: creating extraHour
                activityData['desc'] = booking.name + NeutronUtil.specificChar + subBooking.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar + 'extra_hour_service' + NeutronUtil.specificChar + dataTotal;
                const newBookingOutDate = DateUtil.addHours(outDayBookingServer, dataLateHours);
                t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
                    'out_time': newBookingOutDate
                })
            }
        } else {
            t.update(hotelRef.collection('bookings').doc(bookingId),
                {
                    'extra_hours': {
                        'early_hours': dataEarlyHours,
                        'late_hours': dataLateHours,
                        'early_price': dataEarlyPrice,
                        'late_price': dataLatePrice,
                        'total': dataTotal,
                        'modified_by': context.auth?.token.email
                    }
                });

            // const bookingOutDate: Date = new Date(booking.out_date['_seconds'] * 1000);
            const bookingExtraHour = booking.extra_hours;

            //this mean: updating extraHour
            if (bookingExtraHour !== undefined) {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'extra_hour_service' + NeutronUtil.specificChar + bookingExtraHour.total + NeutronUtil.specificChar + dataTotal;
                if (dataLateHours !== bookingExtraHour.late_hours) {
                    const newBookingOutDate = DateUtil.addHours(outDayBookingServer, dataLateHours);
                    t.update(hotelRef.collection('basic_bookings').doc(bookingId),
                        {
                            'out_time': newBookingOutDate
                        })
                };
                dataUpdate['data.' + dayId + '.service.extra_hours.total'] = FieldValue.increment(-booking.extra_hours.total + dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            } else {
                //this mean: creating extraHour
                activityData['desc'] = booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar + 'extra_hour_service' + NeutronUtil.specificChar + dataTotal;
                const newBookingOutDate = DateUtil.addHours(outDayBookingServer, dataLateHours);
                t.update(hotelRef.collection('basic_bookings').doc(bookingId),
                    {
                        'out_time': newBookingOutDate
                    });
                dataUpdate['data.' + dayId + '.service.extra_hours.total'] = FieldValue.increment(dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            }
        }
        await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, bookingId, !virtual);
        //id of activity document
        const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
        const idDocument = activityIdMap['idDocument'];
        const isNewDocument = activityIdMap['isNewDocument'];

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
                });
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.updateExtraBed = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const dataCat = ServiceCategory.extraBedCat;
    const dataExtraBed = data.extra_bed;
    const sid = data.sid;
    const isGroup = sid !== undefined;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateExtraBedOrExtraHour;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? sid : bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        if (!isServiceEditable(dataCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }

        if (isGroup) {
            t.update(bookingDoc.ref, {
                ['sub_bookings.' + bookingId + '.extra_bed']: dataExtraBed,
                'modified_by': context.auth?.token.email
            })
        } else {
            t.update(bookingDoc.ref, {
                'extra_bed': dataExtraBed,
                'modified_by': context.auth?.token.email
            })
        }
        //save to basic_booking for housekeeping use this field
        t.update(hotelRef.collection('basic_bookings').doc(bookingId), {
            ['extra_bed']: dataExtraBed
        })
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.updateStatusService = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const sid = data.booking_sid;
    const serviceId = data.service_id;
    const serviceStatus = data.service_status;
    const isGroup = sid !== undefined;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateStaticService;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const res = admin.firestore().runTransaction(async (t) => {
        const serviceDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? sid : bookingId).collection('services').doc(serviceId)));
        if (!serviceDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.SERVICE_NOT_FOUND);
        }

        t.update(serviceDoc.ref, { 'status': serviceStatus });

        return MessageUtil.SUCCESS;
    })
    return res;
});

exports.updateBikeRentalProgress = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const bikeRentalId = data.bike_rental_id;
    const dataUpdate = data.data_update;
    const isGroup = bookingSid === undefined ? false : true;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateBikeRentalProgress;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const rs = firestore.runTransaction(async (t) => {
        const bikeRentalDoc = await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId).collection('services').doc(bikeRentalId));
        if (!bikeRentalDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_RENTAL_NOT_FOUND);
        }

        const afterProgress = dataUpdate['progress'];
        const beforeProgress = bikeRentalDoc.get('progress');

        if (beforeProgress === afterProgress) {
            if (beforeProgress === BikeRentalProgress.checkin) {
                throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_WAS_CHECKED_IN);
            }
            if (beforeProgress === BikeRentalProgress.checkout) {
                throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_WAS_CHECKED_OUT);
            }
        }

        const configurationDoc = await t.get(hotelRef.collection('management').doc('configurations'));
        if (!configurationDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
        }

        const listBikesInCloud = configurationDoc.get('data')['bikes'];

        const serviceBike = bikeRentalDoc.get('bike');
        const nowServer = new Date();
        if (dataUpdate['progress'] === BikeRentalProgress.checkin) {
            if (listBikesInCloud[serviceBike] !== undefined && listBikesInCloud[serviceBike]['rented']) {
                throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_WAS_RENTED);
            }
            dataUpdate['start'] = nowServer;
        } else if (dataUpdate['progress'] === BikeRentalProgress.checkout) {
            dataUpdate['end'] = nowServer;
            dataUpdate['used'] = nowServer;
        }

        t.update(bikeRentalDoc.ref, dataUpdate);
        if (afterProgress === BikeRentalProgress.checkin && beforeProgress === BikeRentalProgress.booked) {
            //Check-in bike -> update rent-status of bike in collection 'Bikes'
            if (listBikesInCloud[serviceBike] !== undefined) {
                t.update(configurationDoc.ref, { ['data.bikes.' + serviceBike + '.rented']: true });
            }
        } else if (afterProgress === BikeRentalProgress.checkout && beforeProgress === BikeRentalProgress.checkin) {
            if (listBikesInCloud[serviceBike] !== undefined) {
                t.update(configurationDoc.ref, { ['data.bikes.' + serviceBike + '.rented']: false });
            }
        }
        return MessageUtil.SUCCESS;
    });

    return rs;
});

exports.changeBike = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const bikeRentalId = data.bike_rental_id;
    const newBike = data.new_bike;
    const isGroup = bookingSid !== undefined;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesChangeBike;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const rs = firestore.runTransaction(async (t) => {
        const bikeRentalDoc = await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId).collection('services').doc(bikeRentalId));
        if (!bikeRentalDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_RENTAL_NOT_FOUND);
        }

        const oldBike = bikeRentalDoc.get('bike');

        if (oldBike === newBike) {
            return MessageUtil.SUCCESS;
        }

        const configurationDoc = await t.get(hotelRef.collection('management').doc('configurations'));
        if (!configurationDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
        }

        const listBikesInCloud = configurationDoc.get('data')['bikes'];
        if (listBikesInCloud === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.CONFIGURATION_NOT_FOUND);
        }

        t.update(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId).collection('services').doc(bikeRentalId), {
            'bike': newBike
        });

        if (bikeRentalDoc.get('progress') === BikeRentalProgress.checkin) {
            if (listBikesInCloud[oldBike] !== undefined) {
                t.update(configurationDoc.ref, { ['data.bikes.' + oldBike + '.rented']: false });
            }
            if (listBikesInCloud[newBike] !== undefined) {
                t.update(configurationDoc.ref, { ['data.bikes.' + newBike + '.rented']: true });
            }
        }
        return MessageUtil.SUCCESS;
    });

    return rs;
});

exports.moveBikeToOtherBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    //transfer from this_booking to destination_booking
    const thisBookingId = data.this_booking_id;
    const thisBookingSid = data.this_booking_sid;
    const destinationBookingId = data.destination_booking_id;
    const destinationBookingSid = data.destination_booking_sid;
    const bikeRentalServiceId = data.service_id;
    const isThisBookingGroup = thisBookingSid !== undefined;
    const isDestinationBookingGroup = destinationBookingSid !== undefined;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesChangeBike;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const rs = firestore.runTransaction(async (t) => {
        const bikeRentalDoc = await t.get(hotelRef.collection('bookings').doc(isThisBookingGroup ? thisBookingSid : thisBookingId).collection('services').doc(bikeRentalServiceId));
        if (!bikeRentalDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_RENTAL_NOT_FOUND);
        }

        const bikeRentalDocData = bikeRentalDoc.data();
        const bikeRentalProgress = bikeRentalDocData?.progress;

        if (bikeRentalProgress !== BikeRentalProgress.checkin) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const destinationBookingDoc = await t.get(hotelRef.collection('bookings').doc(isDestinationBookingGroup ? destinationBookingSid : destinationBookingId));
        if (!destinationBookingDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BOOKING_NOT_FOUND);
        }
        const destinationBookingData = destinationBookingDoc.data();
        const destinationBookingStatus = destinationBookingData!.status;
        if (destinationBookingStatus === undefined || destinationBookingStatus !== BookingStatus.checkin && destinationBookingStatus !== BookingStatus.booked) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.BIKE_RENTAL_CAN_NOT_EDIT);
        }
        if (isThisBookingGroup) {
            t.update(hotelRef.collection('bookings').doc(thisBookingSid), {
                "renting_bike_num": FieldValue.increment(-1),
                ['sub_bookings.' + thisBookingId + '.renting_bike_num']: FieldValue.increment(-1),
            });
        } else {
            t.update(hotelRef.collection('bookings').doc(thisBookingId), { "renting_bike_num": FieldValue.increment(-1) });
        }
        t.delete(bikeRentalDoc.ref);

        const updatedBikeRentalData: { [key: string]: any } = bikeRentalDocData as { [key: string]: any };
        updatedBikeRentalData['bid'] = destinationBookingId;
        updatedBikeRentalData['name'] = destinationBookingData!.name;
        updatedBikeRentalData['in'] = destinationBookingData!.in_date;
        updatedBikeRentalData['out'] = destinationBookingData!.out_date;
        updatedBikeRentalData['room'] = destinationBookingData!.room ?? destinationBookingData!['sub_bookings'][destinationBookingId]['room'];
        updatedBikeRentalData['sid'] = destinationBookingData!.sid;
        updatedBikeRentalData['group'] = destinationBookingData!.group ?? false;

        t.set(destinationBookingDoc.ref.collection('services').doc(bikeRentalServiceId), updatedBikeRentalData);
        return MessageUtil.SUCCESS;
    });
    return rs;
});

exports.moveBikeInTheSameGroupBooking = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const thisBookingId = data.this_booking_id;
    const destinationBookingId = data.destination_booking_id;
    const parentId = data.sid;
    const bikeRentalServiceId = data.service_id;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);

    const hotelDoc = (await hotelRef.get());
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesChangeBike;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    const rs = firestore.runTransaction(async (t) => {
        const bikeRentalDoc = await t.get(hotelRef.collection('bookings').doc(parentId).collection('services').doc(bikeRentalServiceId));
        if (!bikeRentalDoc.exists) {
            throw new functions.https.HttpsError('not-found', MessageUtil.BIKE_RENTAL_NOT_FOUND);
        }
        const bikeRentalDocData = bikeRentalDoc.data();
        const bikeRentalProgress = bikeRentalDocData?.progress;

        if (bikeRentalProgress !== BikeRentalProgress.checkin) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const parentBooking = await t.get(hotelRef.collection('bookings').doc(parentId));
        const thisBooking = parentBooking.get('sub_bookings')[thisBookingId];
        const destinationBooking = parentBooking.get('sub_bookings')[destinationBookingId];

        if (thisBooking === undefined || destinationBooking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }

        t.update(parentBooking.ref, {
            ['sub_bookings.' + thisBookingId + '.renting_bike_num']: FieldValue.increment(-1),
            ['sub_bookings.' + destinationBookingId + '.renting_bike_num']: FieldValue.increment(1)
        });
        t.update(bikeRentalDoc.ref, {
            ['bid']: destinationBookingId,
            ['in']: destinationBooking.in_date,
            ['out']: destinationBooking.out_date,
            ['room']: destinationBooking.room
        });
        return MessageUtil.SUCCESS;
    });
    return rs;
});


exports.updateElectricityWater = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const hotelId = data.hotel_id;
    const bookingId = data.booking_id;
    const bookingSid = data.booking_sid;
    const isGroup = bookingSid !== undefined;
    const dataCat = ServiceCategory.electricityWaterCat;
    const dataFirstWater = data.electricity_water.first_water;
    const dataFirstElectricity = data.electricity_water.first_electricity;
    const dataLastWater = data.electricity_water.last_water;
    const dataLastElectricity = data.electricity_water.last_electricity;
    const dataWaterPricer = data.electricity_water.water_price;
    const dataElectricityPrice = data.electricity_water.electricity_price;
    const dataTotal = data.electricity_water.total;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());
    const timezone = hotelDoc.get('timezone');
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesUpdateExtraBedOrExtraHour;
    const isUserCanUpdateDatabase = roleOfUser.some((role) => rolesAllowed.includes(role));

    if (!isUserCanUpdateDatabase) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await admin.firestore().runTransaction(async (t) => {
        const bookingDoc = (await t.get(hotelRef.collection('bookings').doc(isGroup ? bookingSid : bookingId)));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        if (isGroup && booking['sub_bookings'][bookingId] === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const virtual: boolean = bookingDoc.get('virtual') ?? false;
        let totalElectricityWater: number = 0;
        if (isGroup) {
            if (booking['sub_bookings'][bookingId]['electricity_water'] !== undefined) {
                totalElectricityWater = (- booking['sub_bookings'][bookingId]['electricity_water']['total'] + dataTotal);
            } else {
                totalElectricityWater = dataTotal;
            }
        } else {
            if (booking.electricity_water !== undefined) {
                totalElectricityWater = (-booking.electricity_water.total + dataTotal);
            } else {
                totalElectricityWater = dataTotal;
            }
        }
        const totalServiceChargeAndRoomCharge: number =
            NeutronUtil.getServiceChargeAndRoomCharge(bookingDoc, false) + totalElectricityWater;
        const sub_bookings: { [key: string]: any } = isGroup ? bookingDoc.get("sub_bookings") : {};
        const deposits = booking.deposit ?? 0;
        const transferring = booking.transferring ?? 0;
        const totalAllDeposits = deposits + transferring;


        if (!isServiceEditable(dataCat, isGroup ? booking['sub_bookings'][bookingId]['status'] : booking.status, isUserCanUpdateDatabase)) {
            throw new functions.https.HttpsError("permission-denied", MessageUtil.FORBIDDEN);
        }

        // update electricity_water for service
        const outDayBookingServer: Date = isGroup ? booking['sub_bookings'][bookingId]['out_date'].toDate() : booking.out_date.toDate();
        const outDayBookingTimezone: Date = DateUtil.convertUpSetTimezone(outDayBookingServer, timezone);
        const monthId = DateUtil.dateToShortStringYearMonth(outDayBookingTimezone);
        const dayId = DateUtil.dateToShortStringDay(outDayBookingTimezone);
        const dataUpdate: { [key: string]: any } = {};

        const now = new Date();
        const activityData: { [key: string]: any } = {
            'email': context.auth?.token.email,
            'created_time': now,
            'id': bookingId,
            'booking_id': bookingId,
            'type': 'electricity_water'
        };

        if (isGroup) {
            activityData['sid'] = bookingSid;
            if (booking['sub_bookings'][bookingId]['electricity_water'] !== undefined) {
                t.update(hotelRef.collection('bookings').doc(bookingSid), {
                    'electricity_water': FieldValue.increment(- booking['sub_bookings'][bookingId]['electricity_water']['total'] + dataTotal),
                    ['sub_bookings.' + bookingId + '.electricity_water']: {
                        'first_water': dataFirstWater,
                        'first_electricity': dataFirstElectricity,
                        'last_water': dataLastWater,
                        'last_electricity': dataLastElectricity,
                        'water_price': dataWaterPricer,
                        'electricity_price': dataElectricityPrice,
                        'total': dataTotal,
                        'modified_by': context.auth?.token.email
                    }
                });
                dataUpdate['data.' + dayId + '.service.electricity_water.total'] = FieldValue.increment(- booking['sub_bookings'][bookingId]['electricity_water']['total'] + dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            } else {
                t.update(hotelRef.collection('bookings').doc(bookingSid), {
                    'electricity_water': FieldValue.increment(dataTotal),
                    ['sub_bookings.' + bookingId + '.electricity_water']: {
                        'first_water': dataFirstWater,
                        'first_electricity': dataFirstElectricity,
                        'last_water': dataLastWater,
                        'last_electricity': dataLastElectricity,
                        'water_price': dataWaterPricer,
                        'electricity_price': dataElectricityPrice,
                        'total': dataTotal,
                        'modified_by': context.auth?.token.email
                    }
                });
                dataUpdate['data.' + dayId + '.service.electricity_water.total'] = FieldValue.increment(dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            }
            const subBooking = booking['sub_bookings'][bookingId];
            const bookingElectricityWater = subBooking.electricity_water;

            if (bookingElectricityWater !== undefined) {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + subBooking.room + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'electricity_water_service' + NeutronUtil.specificChar + bookingElectricityWater.total + NeutronUtil.specificChar + dataTotal;
            } else {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + subBooking.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar + 'electricity_water_service' + NeutronUtil.specificChar + dataTotal;
            }
        } else {
            t.update(hotelRef.collection('bookings').doc(bookingId),
                {
                    'electricity_water': {
                        'first_water': dataFirstWater,
                        'first_electricity': dataFirstElectricity,
                        'last_water': dataLastWater,
                        'last_electricity': dataLastElectricity,
                        'water_price': dataWaterPricer,
                        'electricity_price': dataElectricityPrice,
                        'total': dataTotal,
                        'modified_by': context.auth?.token.email
                    }
                });

            const bookingElectricityWater = booking.electricity_water;
            if (bookingElectricityWater !== undefined) {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'update' + NeutronUtil.specificChar + 'electricity_water_service' + NeutronUtil.specificChar + bookingElectricityWater.total + NeutronUtil.specificChar + dataTotal;
                dataUpdate['data.' + dayId + '.service.electricity_water.total'] = FieldValue.increment(-booking.electricity_water.total + dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            } else {
                activityData['desc'] = booking.name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'create' + NeutronUtil.specificChar + 'electricity_water_service' + NeutronUtil.specificChar + dataTotal;
                dataUpdate['data.' + dayId + '.service.electricity_water.total'] = FieldValue.increment(dataTotal);
                t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);
            }
        }
        await NeutronUtil.updateStatusPaymentOfBasicBooking(t, hotelRef, isGroup, totalAllDeposits, totalServiceChargeAndRoomCharge, sub_bookings, bookingId, !virtual);
        //id of activity document
        const activityIdMap = await NeutronUtil.getIdActivityDocument(hotelRef.id);
        const idDocument = activityIdMap['idDocument'];
        const isNewDocument = activityIdMap['isNewDocument'];

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
                });
            }
        }
        return MessageUtil.SUCCESS;
    });
    return res;
});
