import functions = require('firebase-functions');
import admin = require('firebase-admin');
import { BookingStatus } from './constant/status';
import { HotelPackage } from './constant/type';
import { UserRole } from './constant/userrole';
import { DateUtil } from "./util/dateutil";
import { HLSUtil } from './util/hlsutil';
import { LogUtil } from "./util/logutil";
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from "./util/numberutil";
import { RestUtil } from './util/restutil';
import { ChannexMealTypes, CmsType } from './constant/cms';

const fireStore = admin.firestore();

async function getHotel(cmID: string): Promise<string> {
    try {
        const snapshot = await fireStore.collection('hotels').where('mapping_hotel_id', '==', cmID).get();
        if (snapshot.size === 0) return '';
        const doc = snapshot.docs[0];
        return doc.id;
    } catch (e) {
        console.log('Get hotel ID: ' + e);
        return '';
    }
}

async function getBreakfast(hotel: string, roomTypeID: string, ratePlanID: string, meal: string): Promise<boolean> {
    try {
        const hotelRef = fireStore.collection('hotels').doc(hotel);
        const snapshot = await hotelRef.collection('cm_room_types').doc(roomTypeID).collection('cm_rate_plans').doc(ratePlanID).get();
        const result = snapshot.get(meal);
        if (result === undefined) {
            return false;
        }
        else {
            return result;
        }
    } catch (e) {
        console.log('Get breakfast: ' + e);
        return false;
    }
}

async function getRoomType(hotelID: string, roomTypeID: string): Promise<string> {
    try {
        const hotelRef = fireStore.collection('hotels').doc(hotelID);
        const snapshot = await hotelRef.collection('cm_room_types').doc(roomTypeID).get();
        const result = snapshot.get('mapping_room_type');
        if (result === undefined) {
            return '';
        } else {
            return result;
        }
    } catch (e) {
        console.log('Get room type error: ' + e);
        return '';
    }
}

async function getCmRoomType(hotelID: string, roomTypeID: any): Promise<{ [key: string]: string }> {
    try {
        const hotelRef = fireStore.collection('hotels').doc(hotelID);
        const snapshot = await hotelRef.collection('cm_room_types').where('mapping_room_type', '==', roomTypeID).get();
        const data: { [key: string]: string } = {};
        if (snapshot.empty) {
            return {};
        } else {
            data['id'] = snapshot.docs[0].id;
            data['ratePlanID'] = snapshot.docs[0].get('mapping_rate_plan');
            return data;
        }
    } catch (e) {
        console.log('Get room type error: ' + e);
        return {};
    }
}

async function getSource(hotelID: string, cmSource: string): Promise<string> {
    try {
        const configurationDoc = await fireStore.collection('hotels').doc(hotelID).collection('management').doc('configurations').get();
        const sourcesList: { [key: string]: any } = configurationDoc.get('data')['sources'];
        let idSourcePMS = '';
        for (const idSource in sourcesList) {
            if (sourcesList[idSource]['mapping_source'] === undefined) {
                continue;
            }

            if (sourcesList[idSource]['mapping_source'] === cmSource) {
                idSourcePMS = idSource;
                break;
            }

            if (sourcesList[idSource]['sub_mapping_source'] !== undefined) {
                const subSources: string[] = sourcesList[idSource]['sub_mapping_source'];
                if (subSources.includes(cmSource)) {
                    idSourcePMS = idSource;
                    break;
                }
            }
        }
        if (idSourcePMS === '') return 'none';
        return idSourcePMS;
    } catch (e) {
        console.error('Get source error: ' + e);
        return 'none';
    }
};

async function addReservation(hotel: string, reservation: any): Promise<string> {
    const hotelRef = fireStore.collection('hotels').doc(hotel);
    const hotelDoc = await hotelRef.get();
    const mappingHotelID: string | undefined = hotelDoc.get('mapping_hotel_id');
    const mappingHotelKey: string | undefined = hotelDoc.get('mapping_hotel_key');
    const timezone: string = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;

    const configurationRef = await hotelRef.collection('management').doc('configurations').get();
    const roomsHotel: { [key: string]: any } = configurationRef.get('data')['rooms'];
    const roomTypesHotel: { [key: string]: any } = configurationRef.get('data')['room_types'];

    let result = '';
    const inDayTimezone: Date = DateUtil.getDateFromHLSDateStringNew(reservation.CheckIn);
    const outDayTimezone: Date = DateUtil.getDateFromHLSDateStringNew(reservation.CheckOut);
    const inDayServer: Date = DateUtil.convertOffSetTimezone(inDayTimezone, timezone);
    const outDayServer: Date = DateUtil.convertOffSetTimezone(outDayTimezone, timezone);
    const rooms = reservation.Rooms;
    const dataNotes = reservation.AdditionalComments ?? '';
    let index = 0;
    const name = reservation.Guests.FirstName + " " + reservation.Guests.LastName;
    const cmSource = reservation.BookingSource.Name;
    const source = await getSource(hotel, cmSource);
    const stayDayServer = DateUtil.getStayDates(inDayServer, outDayServer);
    const stayDayTimezone = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
    let sID = reservation.ExtBookingRef;
    ///test;
    let autoRoomAssignment: boolean = hotelDoc.get('room_assignment') ?? true;
    let statusUnconfirm: boolean = hotelDoc.get('unconfirmed') ?? false;
    console.log(rooms);

    //TODO: Fix when having real HLS account
    if (sID === undefined || sID === '') {
        sID = NumberUtil.getSidByConvertToBase62();
    }
    const hasSlashSid = /\/.*/.test(sID);
    if (hasSlashSid && cmSource == "Mytour.vn") {
        sID = sID.split("/")[0];
    }
    console.log(sID + "146");

    const bookingExtras = reservation.BookingExtras ?? [];
    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
    const now12hOfTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

    const payments: { [key: string]: any }[] = reservation.Payments ?? [];
    let totalPayment = 0;
    console.log(reservation.PayAtHotel);
    if (source != "bk") {
        if (!reservation.PayAtHotel) {
            for (const payment of payments) {
                console.log(payment);
                totalPayment += payment.Amount;
            }
        }
    } else {
        reservation.PayAtHotel = true;
    }
    const paymentFee = reservation.PaymentFee ?? 0;
    const availableRooms: { [key: string]: string[] } = {};
    let isGroup = false;
    if (rooms.length > 1) {
        isGroup = true;
    }

    if (isGroup) {
        await fireStore.runTransaction(async (t) => {
            const lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDayTimezone, t);
            const roomWasBooked: string[] = NeutronUtil.getBookedRoomsWithDailyAllotments(stayDayTimezone, dailyAllotments);

            const dataBookings: { [key: string]: any } = {};
            dataBookings['price'] = new Array(stayDayServer.length).fill(0);
            dataBookings['dataSubBooking'] = {};

            let idDocument;
            let lengthOfActivity;
            if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                idDocument = -1;
                lengthOfActivity = 0;
            } else {
                idDocument = lastDocumentActivity.data().id;
                lengthOfActivity = lastDocumentActivity.data()['activities'].length;
            };

            // const almDate: { [key: string]: { [key: string]: number } } = {};
            console.log(`add booking Group with SID:  ${sID} - cmSource: ${cmSource} - pms Source: ${source} - hotel: ${hotelDoc.get("name")} - total money: ${totalPayment}`);
            // result += `Initilization Payment: ${totalPayment} -`
            const roomAlm: Map<string, { cmID: string, num: number }> = new Map();
            const roomTypeHls: Map<string, { pmsID: string, breakfast: boolean, lunch: boolean, dinner: boolean }> = new Map();
            const roomBookedForThisBooking: string[] = [];
            for (const room of rooms) {
                if (room.BookingItemStatus.includes('Cancelled') || room.BookingItemStatus.includes('No Show')) {
                    continue;
                }
                const roomTypeIdCM = room.RoomId;
                const ratePlanIdCM = room.RatePlanId;

                if (!roomTypeHls.has(roomTypeIdCM)) {
                    const roomTypeIdPMS = await getRoomType(hotel, roomTypeIdCM);
                    const breakfast = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'breakfast');
                    const lunch = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'lunch');
                    const dinner = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'dinner');
                    roomTypeHls.set(roomTypeIdCM, { pmsID: roomTypeIdPMS, breakfast: breakfast, dinner: dinner, lunch: lunch });
                }

                const bookingInfo = '(sid: ' + sID + ', source: ' + source + ',name: ' + name + ', in: ' + reservation.CheckIn + ', out: ' + reservation.CheckOut + ', cm room id: ' + roomTypeIdCM + ', cm rate plan id: ' + ratePlanIdCM + ')';

                try {
                    const roomTypeID = roomTypeHls.get(roomTypeIdCM)?.pmsID;
                    const breakfastRoomType = roomTypeHls.get(roomTypeIdCM)?.breakfast;
                    const lunchRoomType = roomTypeHls.get(roomTypeIdCM)?.lunch;
                    const dinnerRoomType = roomTypeHls.get(roomTypeIdCM)?.dinner;

                    if (roomTypeID === '' || roomTypeID === undefined) {
                        result += 'Failed to add booking ' + bookingInfo + ' with error: Room type ' + roomTypeIdCM + ' is not mapped in PMS!\\n';
                        continue;
                    }

                    const roomsOfRoomType: string[] = [];

                    Object.keys(roomsHotel).map((id) => {
                        if (roomsHotel[id]['room_type'] === roomTypeID && roomsHotel[id]['is_delete'] === false) {
                            roomsOfRoomType.push(id);
                        }
                    });

                    if (roomWasBooked.length > 0) {
                        availableRooms[roomTypeID] = roomsOfRoomType.filter((e) => roomWasBooked.indexOf(e) === -1);
                    } else {
                        availableRooms[roomTypeID] = roomsOfRoomType;
                    }
                    const availableRoom = availableRooms[roomTypeID].length > 0 && autoRoomAssignment ? availableRooms[roomTypeID][0] : '';
                    const bed = availableRoom !== '' ? roomTypesHotel[roomsHotel[availableRoom]['room_type']]['beds'].length > 1 ? '?' : roomsHotel[availableRoom]['bed'] : '?';
                    if (availableRoom !== '') {
                        roomWasBooked.push(availableRoom);
                    }
                    const adult = room.ExtraAdults + room.Adults;
                    const child = room.ExtraChildren + room.Children;
                    const prices: number[] = [];
                    let indexPrice = 0;
                    for (const rate of room.RoomRate.RatePerNights) {
                        let rateRoomChargeAndService = rate.Rate;
                        if (rate.Extras !== undefined) {
                            for (const service of rate.Extras) {
                                rateRoomChargeAndService += service.Amount;
                            }
                        }
                        prices.push(rateRoomChargeAndService);
                        dataBookings['price'][indexPrice] = dataBookings['price'][indexPrice] + rateRoomChargeAndService;
                        indexPrice++;
                    }

                    const bookingID = NumberUtil.getSidByConvertToBase62() + index;
                    dataBookings['dataSubBooking'][bookingID] = {};
                    dataBookings['dataSubBooking'][bookingID]['status'] = statusUnconfirm ? BookingStatus.unconfirmed : BookingStatus.booked;
                    dataBookings['dataSubBooking'][bookingID]['adult'] = adult;
                    dataBookings['dataSubBooking'][bookingID]['child'] = child;
                    dataBookings['dataSubBooking'][bookingID]['in_date'] = inDayServer;
                    dataBookings['dataSubBooking'][bookingID]['out_date'] = outDayServer;
                    dataBookings['dataSubBooking'][bookingID]['price'] = prices;
                    dataBookings['dataSubBooking'][bookingID]['room'] = availableRoom;
                    dataBookings['dataSubBooking'][bookingID]['room_type'] = roomTypeID;
                    dataBookings['dataSubBooking'][bookingID]['breakfast'] = breakfastRoomType;
                    dataBookings['dataSubBooking'][bookingID]['lunch'] = lunchRoomType;
                    dataBookings['dataSubBooking'][bookingID]['dinner'] = dinnerRoomType;
                    dataBookings['dataSubBooking'][bookingID]['bed'] = bed;
                    dataBookings['dataSubBooking'][bookingID]['hls_room_type_id'] = roomTypeID;

                    const dataSubBooking: { [key: string]: any } = {
                        'rate_plan': 'OTA',
                        'name': name,
                        'bed': bed,
                        'in_date': inDayServer,
                        'in_time': inDayServer,
                        'out_date': outDayServer,
                        'out_time': outDayServer,
                        'room': availableRoom,
                        'room_type': roomTypeID,
                        'status': statusUnconfirm ? BookingStatus.unconfirmed : BookingStatus.booked,
                        'sid': sID,
                        'source': source,
                        'phone': reservation.Guests.Phone,
                        'email': reservation.Guests.Email,
                        'price': prices,
                        'breakfast': breakfastRoomType,
                        'lunch': lunchRoomType,
                        'dinner': dinnerRoomType,
                        'pay_at_hotel': reservation.PayAtHotel,
                        'adult': adult,
                        'child': child,
                        'group': true,
                        'created': nowServer,
                        'currency': reservation.CurrencyISO,
                        'stay_days': stayDayServer,
                        'cm_id': reservation.BookingId,
                        'time_zone': timezone,
                        'type_tourists': '',
                        'country': '',
                        'creator': "Onepms",
                    };
                    if (dataNotes !== '') {
                        dataSubBooking['notes'] = dataNotes;
                    }
                    t.set(hotelRef.collection('basic_bookings').doc(bookingID), dataSubBooking);

                    if (roomAlm.has(roomTypeID)) {
                        const num: number = roomAlm.get(roomTypeID)?.num ?? 0;
                        roomAlm.set(roomTypeID, {
                            cmID: roomTypeIdCM,
                            num: num + 1
                        });
                    } else {
                        roomAlm.set(roomTypeID, {
                            cmID: roomTypeIdCM,
                            num: 1
                        });
                    }

                    roomBookedForThisBooking.push(availableRoom);

                    if (hotelPackage !== HotelPackage.basic) {
                        const activityData: { [key: string]: any } = {
                            'email': 'Booking From HotelLink - Added By OnePMS',
                            'id': bookingID,
                            'sid': sID,
                            'booking_id': bookingID,
                            'type': 'booking',
                            'desc': name + NeutronUtil.specificChar + 'book_room' + NeutronUtil.specificChar + availableRoom,
                            'created_time': nowServer
                        };

                        if (idDocument === -1) {
                            idDocument = 0;
                            t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                'activities': [activityData],
                                'id': idDocument
                            });
                            lengthOfActivity++;
                        } else {
                            if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                idDocument++;

                                t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                    'activities': [activityData],
                                    'id': idDocument
                                });
                                lengthOfActivity = 0;
                                if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                    t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                }
                            } else {
                                t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                    'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                });
                                lengthOfActivity++;
                            }
                        }
                    }
                    index += 1;
                    result += 'Added sub booking ' + bookingInfo + ' at room ' + availableRoom + ' - ';
                } catch (e) {
                    result += 'Failed to add booking ' + bookingInfo + ' with error: ' + e + ' - ';
                }
            };

            const dataUpdate: { [key: string]: any } = {
                'name': name,
                'phone': reservation.Guests.Phone,
                'email': reservation.Guests.Email,
                'in_date': inDayServer,
                'out_date': outDayServer,
                'sub_bookings': dataBookings['dataSubBooking'],
                'status': statusUnconfirm ? BookingStatus.unconfirmed : BookingStatus.booked,
                'rate_plan': 'OTA',
                'source': source,
                'sid': sID,
                'price': dataBookings['price'],
                'group': true,
                'created': nowServer,
                'time_zone': timezone,
                'pay_at_hotel': reservation.PayAtHotel,
                'virtual': false,
                'deposit': 0,
                'ota_deposit': 0,
                'type_tourists': '',
                'country': '',
                'creator': "Onepms",
            };
            t.set(hotelRef.collection('bookings').doc(sID), dataUpdate);
            // update hls new here
            NeutronUtil.updateDailyAllotmentAndHlsBookingGroupWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, true, dailyAllotments, roomAlm, null, roomBookedForThisBooking, mappingHotelID, mappingHotelKey);
            // add ota deposit
            if (totalPayment !== 0) {
                try {
                    t.set(hotelRef.collection('bookings').doc(sID).collection('deposits').doc(), {
                        'amount': totalPayment,
                        'method': 'ota',
                        'group': true,
                        'source': source,
                        'created': outDayServer,
                        'desc': 'OTA payment. Auto added by OnePMS!',
                        'status': 'open',
                        'name': name,
                        'room': 'group',
                        'bid': sID,
                        'in': inDayServer,
                        'out': outDayServer,
                        'sid': sID,
                        'hotel': hotel,
                        'time_zone': timezone,
                        'modified_by': 'Add By OnePMS'
                    });
                    result += "Added ota deposit for booking group with sid" + sID;
                } catch (e) {
                    result += "Failed to add ota deposit for " + sID;
                }
            };

            // add service charge 
            if (bookingExtras.length > 0) {
                for (const bookingExtra of bookingExtras) {
                    t.set(hotelRef.collection('bookings').doc(sID).collection('services').doc(), {
                        'created': nowServer,
                        'desc': 'Name: ' + bookingExtra.ServiceName + ' .Quantity: ' + bookingExtra.Quantity + ' .Extra children: ' + bookingExtra.ExtraChildren + '.',
                        'supplier': 'none',
                        'total': bookingExtra.Amount,
                        'status': 'open',
                        'type': 'ota',
                        'cat': 'other',
                        'used': inDayServer,
                        'name': name,
                        'in': inDayServer,
                        'out': outDayServer,
                        'sid': sID,
                        'bid': sID,
                        'hotel': hotel,
                        'time_zone': timezone,
                        'modified_by': 'From CMS',
                        'room': 'group',
                        'group': true
                    });
                }
            };

            // add payment fee
            if (paymentFee !== 0) {
                try {
                    t.set(hotelRef.collection('bookings').doc(sID).collection('services').doc(), {
                        'created': nowServer,
                        'desc': 'Payment fee.',
                        'supplier': 'none',
                        'total': paymentFee,
                        'status': 'open',
                        'type': 'ota',
                        'cat': 'other',
                        'used': inDayServer,
                        'name': name,
                        'in': inDayServer,
                        'out': outDayServer,
                        'sid': sID,
                        'bid': sID,
                        'room': 'group',
                        'hotel': hotel,
                        'time_zone': timezone,
                        'modified_by': 'From CMS',
                        'group': true
                    });
                    result += "Added service PaymentFee for booking group with SID" + sID;
                } catch (e) {
                    result += "Failed to add service PaymentFee for booking group with SID " + sID;
                }
            };
        });
    } else {
        await fireStore.runTransaction(async (t) => {
            if (rooms[0].BookingItemStatus.includes('Cancelled') || rooms[0].BookingItemStatus.includes('No Show')) {
                result += 'BookingItemStatus includes Cancelled or No Show';
                return;
            }

            console.log(`add booking with SID:  ${sID} - cmSource: ${cmSource} - pms Source: ${source} - hotel: ${hotelDoc.get("name")}`);

            const lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];
            const roomTypeIdCM = rooms[0].RoomId;
            const ratePlanIdCM = rooms[0].RatePlanId;
            const bookingInfo = '(sid: ' + sID + ', source: ' + source + ',name: ' + name + ', in: ' + reservation.CheckIn + ', out: ' + reservation.CheckOut + ', cm room id: ' + roomTypeIdCM + ', cm rate plan id: ' + ratePlanIdCM + ')';
            const roomTypeIdPMS = await getRoomType(hotel, roomTypeIdCM);
            if (roomTypeIdPMS === '') {
                result += 'Failed to add booking ' + bookingInfo + ' with error: Room type ' + roomTypeIdCM + ' is not mapped in PMS!\\n';
            }
            const breakfast = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'breakfast');
            const lunch = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'lunch');
            const dinner = await getBreakfast(hotel, roomTypeIdCM, ratePlanIdCM, 'dinner');
            const roomsOfRoomType: string[] = [];
            Object.keys(roomsHotel).map((id) => {
                if (roomsHotel[id]['room_type'] === roomTypeIdPMS && roomsHotel[id]['is_delete'] === false) {
                    roomsOfRoomType.push(id);
                }
            });
            const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDayTimezone, t);
            availableRooms[roomTypeIdPMS] = NeutronUtil.getAvailableRoomsWithDailyAllotments(stayDayTimezone, dailyAllotments, roomsOfRoomType);

            const availableRoom: string = availableRooms[roomTypeIdPMS].length > 0 && autoRoomAssignment ? availableRooms[roomTypeIdPMS][0] : '';

            const bed: string = availableRoom !== '' ? roomTypesHotel[roomsHotel[availableRoom]['room_type']]['beds'].length > 1 ? '?' : roomsHotel[availableRoom]['bed'] : '?';
            const adult = rooms[0].ExtraAdults + rooms[0].Adults;
            const child = rooms[0].ExtraChildren + rooms[0].Children;
            const price: number[] = [];
            for (const rate of rooms[0].RoomRate.RatePerNights) {
                let rateRoomChargeAndService = rate.Rate;
                console.log(rate.Rate);
                if (rate.Extras !== undefined) {
                    for (const service of rate.Extras) {
                        console.log(service.Amount);
                        rateRoomChargeAndService += service.Amount;
                    }
                }
                price.push(rateRoomChargeAndService);
            }

            const bookingID = NumberUtil.getSidByConvertToBase62();
            const dataBooking: { [key: string]: any } = {
                'rate_plan': 'OTA',
                'name': name,
                'bed': bed,
                'in_date': inDayServer,
                'in_time': inDayServer,
                'out_date': outDayServer,
                'out_time': outDayServer,
                'room': availableRoom,
                'room_type': roomTypeIdPMS,
                'status': statusUnconfirm ? BookingStatus.unconfirmed : BookingStatus.booked,
                'sid': sID,
                'source': source,
                'phone': reservation.Guests.Phone,
                'email': reservation.Guests.Email,
                'price': price,
                'breakfast': breakfast,
                'lunch': lunch,
                'dinner': dinner,
                'pay_at_hotel': reservation.PayAtHotel,
                'adult': adult,
                'child': child,
                'group': isGroup,
                'created': nowServer,
                'currency': reservation.CurrencyISO,
                'stay_days': stayDayServer,
                'cm_id': reservation.BookingId,
                'time_zone': timezone,
                'type_tourists': '',
                'country': '',
                'creator': "Onepms",
            }

            if (dataNotes !== '') {
                dataBooking['notes'] = dataNotes;
            }
            // create basic bookings
            t.set(hotelRef.collection('basic_bookings').doc(bookingID), dataBooking);
            // create bookings
            t.set(hotelRef.collection('bookings').doc(bookingID), {
                'rate_plan': 'OTA',
                'name': name,
                'in_date': inDayServer,
                'out_date': outDayServer,
                'in_time': inDayServer,
                'out_time': outDayServer,
                'status': statusUnconfirm ? BookingStatus.unconfirmed : BookingStatus.booked,
                'room_type': roomTypeIdPMS,
                'phone': reservation.Guests.Phone,
                'email': reservation.Guests.Email,
                'room': availableRoom,
                'price': price,
                'bed': bed,
                'breakfast': breakfast,
                'lunch': lunch,
                'dinner': dinner,
                'pay_at_hotel': reservation.PayAtHotel,
                'adult': adult,
                'child': child,
                'source': source,
                'sid': sID,
                'group': isGroup,
                'created': nowServer,
                'currency': reservation.CurrencyISO,
                'time_zone': timezone,
                'hls_room_type_id': roomTypeIdPMS,
                'virtual': false,
                'deposit': 0,
                'ota_deposit': 0,
                'type_tourists': '',
                'country': '',
                'creator': "Onepms",
            });

            result += 'Add booking ' + bookingInfo + ' at room ' + availableRoom + '\\n';

            // create deposit
            if (totalPayment !== 0) {
                try {
                    t.set(hotelRef.collection('bookings').doc(bookingID).collection('deposits').doc(), {
                        'amount': totalPayment,
                        'method': 'ota',
                        'source': source,
                        'created': outDayServer,
                        'desc': 'OTA payment. Auto added by OnePMS!',
                        'status': 'open',
                        'bid': bookingID,
                        'name': name,
                        'group': false,
                        'in': inDayServer,
                        'out': outDayServer,
                        'room': availableRoom,
                        'sid': sID,
                        'hotel': hotel,
                        'time_zone': timezone,
                        'modified_by': 'Add By OnePMS'
                    });
                    result += "Added ota deposit for " + bookingInfo + ' at room ' + availableRoom + '\\n';
                } catch (e) {
                    result += "Failed to add ota deposit for " + bookingInfo + ' at room ' + availableRoom + '\\n';
                }
            };
            // create service
            if (bookingExtras.length > 0) {
                try {
                    for (const bookingExtra of bookingExtras) {
                        t.set(hotelRef.collection('bookings').doc(bookingID).collection('services').doc(), {
                            'created': nowServer,
                            'desc': 'Name: ' + bookingExtra.ServiceName + ' .Quantity: ' + bookingExtra.Quantity + ' .Extra children: ' + bookingExtra.ExtraChildren + '.',
                            'supplier': 'none',
                            'total': bookingExtra.Amount,
                            'status': 'open',
                            'type': 'ota',
                            'cat': 'other',
                            'used': inDayServer,
                            'bid': bookingID,
                            'name': name,
                            'in': inDayServer,
                            'out': outDayServer,
                            'room': availableRoom,
                            'sid': sID,
                            'hotel': hotel,
                            'time_zone': timezone,
                            'group': false,
                            'modified_by': 'From CMS'
                        });
                    }
                    result += "Added extra services for " + bookingInfo + ' at room ' + availableRoom + '\\n';
                } catch (e) {
                    result += "Failed to add extra services for " + bookingInfo + ' at room ' + availableRoom + '\\n';
                }
            };
            // create payment fee in service
            if (paymentFee !== 0) {
                try {
                    t.set(hotelRef.collection('bookings').doc(bookingID).collection('services').doc(), {
                        'created': nowServer,
                        'desc': 'Payment fee.',
                        'supplier': 'none',
                        'total': paymentFee,
                        'status': 'open',
                        'type': 'ota',
                        'cat': 'other',
                        'used': inDayServer,
                        'bid': bookingID,
                        'name': name,
                        'in': inDayServer,
                        'out': outDayServer,
                        'room': availableRoom,
                        'sid': sID,
                        'hotel': hotel,
                        'time_zone': timezone,
                        'modified_by': 'From CMS',
                        'group': false
                    });
                    result += "Added service PaymentFee for booking group with SID" + sID;
                } catch (e) {
                    result += "Failed to add service PaymentFee for booking group with SID " + sID;
                }
            };

            if (hotelPackage !== HotelPackage.basic) {
                // update activity
                const activityData: { [key: string]: any } = {
                    'email': 'Booking From HotelLink - Added By OnePMS',
                    'id': bookingID,
                    'booking_id': bookingID,
                    'type': 'booking',
                    'desc': name + NeutronUtil.specificChar + 'book_room' + NeutronUtil.specificChar + availableRoom,
                    'created_time': nowServer
                };

                let idDocument;
                if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
                    idDocument = 0;
                    t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                        'activities': [activityData],
                        'id': idDocument
                    });
                } else {
                    idDocument = lastDocumentActivity.data().id;
                    if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                        idDocument++;
                        t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                            'activities': [activityData],
                            'id': idDocument
                        });
                        if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                            t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                        }
                    } else {
                        t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                            'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                        });
                    }
                }
            }
            const almRoomBooked: { pmsID: string, cmId: string } = { pmsID: roomTypeIdPMS, cmId: roomTypeIdCM };
            // update allotment and hls new here
            NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, true, almRoomBooked, availableRoom, null, mappingHotelID, mappingHotelKey, dailyAllotments, now12hOfTimezone);
        });
    }

    // send to one data hub information here
    const optionsGetToken = {
        hostname: 'identitytoolkit.googleapis.com',
        path: '/v1/accounts:signInWithPassword?key=AIzaSyDXHztF9Hldv_KDXYV7ffedcoyDLjy46l8',
        method: 'POST',
        headers: {
            "Content-Type": "application/json"
        }
    };
    const postDataGetToken = JSON.stringify({
        email: 'hotellink@gmail.com',
        password: 'hotellink!@#123',
        returnSecureToken: true
    });
    const respond = await RestUtil.postRequest(optionsGetToken, postDataGetToken);
    // token here
    const token = respond.idToken;

    const options = {
        hostname: 'one-neutron-cloud-run-atocmpjqwa-uc.a.run.app',
        path: '/addBooking',
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        }
    };
    const postData = JSON.stringify(
        {
            'name': name,
            'phone': reservation.Guests.Phone,
            'inDate': inDayTimezone,
            'outDate': outDayTimezone,
            'nameHotel': hotelDoc.get('name'),
            'cityHotel': hotelDoc.get('city'),
            'countryHotel': hotelDoc.get('country')
        }
    );
    RestUtil.postRequest(options, postData).catch(console.error);
    return result;
}

function isCancellable(booking: FirebaseFirestore.DocumentData): boolean {
    let status;
    if (booking.group) {
        status = BookingStatus.booked;
        const sub_bookings: { [key: string]: any } = booking.sub_bookings;
        for (const idBooking in sub_bookings) {
            if (sub_bookings[idBooking]['status'] === BookingStatus.cancel || sub_bookings[idBooking]['status'] === BookingStatus.noshow) continue;
            if (sub_bookings[idBooking]['status'] !== BookingStatus.booked) {
                status = BookingStatus.checkin;
                break;
            }
        }
    } else {
        status = booking.status;
    }

    const service = NeutronUtil.getServiceCharge(booking);
    const deposit = booking.deposit ?? 0;
    const otaDeposit = booking.ota_deposit ?? 0;
    const otaService = booking.ota_service ?? 0;

    if ((service === 0 || service === otaService) && (deposit === 0 || deposit === otaDeposit) && status <= BookingStatus.booked) {
        return true;
    } else {
        return false;
    }
}

async function cancelReservation(hotel: string, reservation: any, isDeleted: boolean): Promise<string> {
    const firestore = admin.firestore();
    const cmSource = reservation.BookingSource.Name;
    // const source = await getSource(hotel, cmSource);

    let sID = reservation.ExtBookingRef ?? '';

    const hasSlashSid = /\/.*/.test(sID);
    if (hasSlashSid && cmSource == "Mytour.vn") {
        sID = sID.split("/")[0];
        console.log("Chuỗi chứa dấu '/'");
    }

    const hotelRef = firestore.collection('hotels').doc(hotel);
    const hotelDoc = await hotelRef.get();
    const timeZone = hotelDoc.get('timezone');
    const hotelPackage = hotelDoc.get('package') ?? HotelPackage.basic;

    console.log("NameHotel:" + hotelDoc.get('name') + "SID" + sID);

    const hotelMappingId: string | undefined = hotelDoc.get('mapping_hotel_id');
    const hotelMappingKey: string | undefined = hotelDoc.get('mapping_hotel_key');

    const nowServer: Date = new Date();
    const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timeZone);
    const now12hOfTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);

    const transactionResult = await fireStore.runTransaction(async (t) => {

        let message = '';
        const bookingsDoc = await t.get(hotelRef.collection('bookings').where('sid', '==', sID));

        if (bookingsDoc.empty) {
            message += 'Failed to cancel booking (sid: ' + sID + ', pms source: ' + bookingsDoc.docs[0].get('source') + ', cmSource:' + cmSource + ', in: ' + reservation.CheckIn + ', out: ' + reservation.CheckOut + ' because snapshot empty, is deleted: ' + isDeleted + ' );';
            return message;
        }

        const inDayTimezone = DateUtil.convertUpSetTimezone(bookingsDoc.docs[0].get('in_date').toDate(), timeZone);
        const outDayTimezone = DateUtil.convertUpSetTimezone(bookingsDoc.docs[0].get('out_date').toDate(), timeZone);
        const stayDayTimezone: Date[] = DateUtil.getStayDates(inDayTimezone, outDayTimezone);
        const dailyAllotments = await NeutronUtil.getDailyAllotmentByStayDates(hotelRef, stayDayTimezone, t);
        const lastDocumentActivity = (await t.get(hotelRef.collection('activities').orderBy('id', 'asc').limitToLast(1))).docs[0];

        console.log(816);
        let idDocument;
        let lengthOfActivity;
        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            idDocument = -1;
            lengthOfActivity = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            lengthOfActivity = lastDocumentActivity.data()['activities'].length;
        }
        const dataUpdate: { [key: string]: any } = {};

        for (const bookingDoc of bookingsDoc.docs) {
            const id = bookingDoc.id;
            const booking = bookingDoc.data();
            const isGroup = booking.group;
            const name = booking.name;


            const cin = DateUtil.dateToShortString(inDayTimezone);
            const cout = DateUtil.dateToShortString(outDayTimezone);

            // check if status of booking < booked then continue
            if (isGroup) {
                const bookingInfo = '(sid: ' + sID + ', source: ' + booking.source + ',name: ' + name + ', room: Group' + ', in: ' + cin + ', out: ' + cout + ')';
                if (isCancellable(booking)) {
                    // cancel basic booking here
                    const almRoomBooked: Map<string, { cmID: string, num: number }> = new Map();
                    const almRoomCancelled: Map<string, { cmID: string }> = new Map();
                    const arrayRemoveRoomBooked: string[] = [];
                    const arrayHlsRoomTypeCancelled: string[] = [];

                    //Delete ota services
                    const otaServices = await t.get(bookingDoc.ref.collection('services').where('type', "==", 'ota'));
                    //Delete ota deposits
                    const otaDeposits = await t.get(bookingDoc.ref.collection('deposits').where('method', "==", 'ota'));

                    // change function here
                    // almRoom Booked
                    for (const idBooking in booking.sub_bookings) {
                        const roomType: string = booking.sub_bookings[idBooking]['room_type'];
                        const room: string = booking.sub_bookings[idBooking]['room'];
                        const hlsRoomType: string = booking.sub_bookings[idBooking]['hls_room_type_id'] ?? roomType;

                        // update logic here
                        if (booking.sub_bookings[idBooking]['status'] === BookingStatus.booked || booking.sub_bookings[idBooking]['status'] === BookingStatus.unconfirmed) {

                            if (isDeleted) {
                                // delete here
                                t.delete(hotelRef.collection('basic_bookings').doc(idBooking));

                            } else {
                                // cancel here
                                t.update(hotelRef.collection('basic_bookings').doc(idBooking), { 'status': BookingStatus.cancel, 'cancelled': new Date() });
                                dataUpdate['sub_bookings.' + idBooking + '.status'] = BookingStatus.cancel;
                                dataUpdate['sub_bookings.' + idBooking + '.cancelled'] = new Date();

                                if (hotelPackage !== HotelPackage.basic) {
                                    const activityData: { [key: string]: any } = {
                                        'email': 'Cancel Booking From HotelLink - By OnePMS',
                                        'id': idBooking,
                                        'booking_id': idBooking,
                                        'type': 'booking',
                                        'desc': name + NeutronUtil.specificChar + booking.sub_bookings[idBooking]['room'] + NeutronUtil.specificChar + 'cancel',
                                        'created_time': nowServer
                                    };
                                    if (idDocument === -1) {
                                        idDocument = 0;
                                        t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                            'activities': [activityData],
                                            'id': idDocument
                                        });
                                        lengthOfActivity++;
                                    } else {
                                        if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                            idDocument++;
                                            t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                                'activities': [activityData],
                                                'id': idDocument
                                            });
                                            lengthOfActivity = 0;
                                            if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                                t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                            }
                                        } else {
                                            t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                                'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                            });
                                            lengthOfActivity++;
                                        }
                                    }
                                }
                            }

                            arrayRemoveRoomBooked.push(room);
                            if (almRoomBooked.has(roomType)) {
                                const numOld: number = almRoomBooked.get(roomType)?.num ?? 0;
                                const cmIDOld: string = almRoomBooked.get(roomType)?.cmID ?? '';
                                almRoomBooked.set(roomType, {
                                    cmID: cmIDOld,
                                    num: numOld + 1
                                })
                            } else {
                                const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);
                                almRoomBooked.set(roomType, {
                                    cmID: mappingRoomType['id'],
                                    num: 1
                                })
                            }

                            if (roomType !== hlsRoomType && !almRoomBooked.has(hlsRoomType) && (arrayHlsRoomTypeCancelled.indexOf(hlsRoomType) === -1)) {
                                arrayHlsRoomTypeCancelled.push(hlsRoomType);
                            }

                        } else {
                            if (isDeleted) {
                                t.delete(hotelRef.collection('basic_bookings').doc(idBooking));
                            }


                            if (!almRoomBooked.has(roomType) && (arrayHlsRoomTypeCancelled.indexOf(roomType) === -1)) {
                                arrayHlsRoomTypeCancelled.push(roomType);
                            }

                            if (roomType !== hlsRoomType && !almRoomBooked.has(hlsRoomType) && (arrayHlsRoomTypeCancelled.indexOf(hlsRoomType) === -1)) {
                                arrayHlsRoomTypeCancelled.push(hlsRoomType);
                            }
                        }
                    }

                    for (const hlsRoomTypeInLoop of arrayHlsRoomTypeCancelled) {
                        if (!almRoomBooked.has(hlsRoomTypeInLoop)) {
                            const mappingRoomType = await NeutronUtil.getCmRoomType(hotelRef.id, hlsRoomTypeInLoop);
                            almRoomCancelled.set(hlsRoomTypeInLoop, { cmID: mappingRoomType['id'] });
                        }
                    }

                    for (const service of otaServices.docs) {
                        t.delete(service.ref);
                    }

                    // log deposit
                    for (const deposit of otaDeposits.docs) {
                        t.delete(deposit.ref);
                    }

                    if (isDeleted) {
                        t.delete(bookingDoc.ref);
                    } else {
                        dataUpdate['status'] = BookingStatus.cancel;
                        t.update(bookingDoc.ref, dataUpdate);
                    }

                    // update hls here
                    console.log(`Cancel booking group ${sID} - cmSource ${cmSource} - ${hotelDoc.get('name')}`);
                    NeutronUtil.updateDailyAllotmentAndHlsBookingGroupWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, false, dailyAllotments, almRoomBooked, almRoomCancelled, arrayRemoveRoomBooked, hotelMappingId, hotelMappingKey);
                    message += 'Cancelled booking group' + bookingInfo + '.\\n ';
                } else {
                    message += 'Failed to cancel booking ' + bookingInfo + ' because it has deposit or service or not in Booked status.\\n';
                }
            } else {
                const bookingInfo = '(sid: ' + sID + ', source: ' + booking.source + ',name: ' + name + ', room: ' + booking.room + ', in: ' + cin + ', out: ' + cout + ')';
                if (isCancellable(booking)) {
                    //Delete ota services
                    const otaServices = await t.get(bookingDoc.ref.collection('services').where('type', "==", 'ota'));
                    //Delete ota deposits
                    const otaDeposits = await t.get(bookingDoc.ref.collection('deposits').where('method', "==", 'ota'));

                    for (const service of otaServices.docs) {
                        t.delete(service.ref);
                    }

                    for (const deposit of otaDeposits.docs) {
                        // if (isDeleted) {
                        //     t.update(deposit.ref, { 'allow_deleted': false });
                        // }
                        t.delete(deposit.ref);
                    }
                    const roomType = booking.room_type;
                    const room = booking.room;
                    const hlsRoomType = booking.hls_room_type_id ?? booking.room_type;

                    // if different room type here 
                    // cancel booking
                    if (isDeleted) {
                        console.log(`Delete booking ${sID} - cmSource ${cmSource} - ${hotelDoc.get('name')} - status: ${booking.status}`);
                        // t.update(bookingDoc.ref, { 'allow_deleted': false });
                        t.delete(bookingDoc.ref);
                        t.delete(hotelRef.collection('basic_bookings').doc(id));
                    } else {
                        console.log(`Cancel booking ${sID} - cmSource ${cmSource} - ${hotelDoc.get('name')} - status: ${booking.status}`);
                        if (booking.status !== BookingStatus.cancel && booking.status !== BookingStatus.noshow) {
                            t.update(bookingDoc.ref, { 'status': BookingStatus.cancel });
                            t.update(hotelRef.collection('basic_bookings').doc(id), { 'status': BookingStatus.cancel, 'cancelled': new Date() });
                            if (hotelPackage !== HotelPackage.basic) {
                                const activityData: { [key: string]: any } = {
                                    'email': 'Cancel Booking From HotelLink - By OnePMS',
                                    'id': id,
                                    'booking_id': id,
                                    'type': 'booking',
                                    'desc': name + NeutronUtil.specificChar + booking.room + NeutronUtil.specificChar + 'cancel',
                                    'created_time': nowServer
                                };

                                if (idDocument === -1) {
                                    idDocument = 0;
                                    t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                        'activities': [activityData],
                                        'id': idDocument
                                    });
                                    lengthOfActivity++;
                                } else {
                                    if (lengthOfActivity >= NeutronUtil.maxActivitiesPerArray) {
                                        idDocument++;
                                        t.set(hotelRef.collection('activities').doc(idDocument.toString()), {
                                            'activities': [activityData],
                                            'id': idDocument
                                        });
                                        lengthOfActivity = 0;
                                        if (idDocument >= NeutronUtil.maxActivitiesDoc) {
                                            t.delete(hotelRef.collection('activities').doc((idDocument - NeutronUtil.maxActivitiesDoc).toString()));
                                        }
                                    } else {
                                        t.update(hotelRef.collection('activities').doc(idDocument.toString()), {
                                            'activities': admin.firestore.FieldValue.arrayUnion(activityData)
                                        });
                                        lengthOfActivity++;
                                    }
                                }
                            }
                        }
                    }

                    let almRoomBooked: { pmsID: string, cmId: string } | null = null;
                    let almRoomCancelled: Map<string, { cmId: string }> | null = null;
                    const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomType);

                    if (hlsRoomType !== roomType) {
                        const mappedRoomTypeHls: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, hlsRoomType);
                        almRoomCancelled = new Map();
                        almRoomCancelled.set(hlsRoomType, { cmId: mappedRoomTypeHls['id'] });
                    }

                    if (booking.status !== BookingStatus.cancel && booking.status !== BookingStatus.noshow) {
                        almRoomBooked = { pmsID: roomType, cmId: mappedRoomType['id'] };
                    } else {
                        if (almRoomCancelled === null) {
                            almRoomCancelled = new Map();
                            almRoomCancelled.set(hlsRoomType, { cmId: mappedRoomType['id'] });
                        } else {
                            almRoomCancelled.set(hlsRoomType, { cmId: mappedRoomType['id'] });
                        }
                    }

                    NeutronUtil.updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(t, hotelRef, stayDayTimezone, false, almRoomBooked, room, almRoomCancelled, hotelMappingId, hotelMappingKey, dailyAllotments, now12hOfTimezone);

                    message += 'Cancelled booking ' + bookingInfo + '.\\n';
                } else {
                    message += 'Failed to cancel booking ' + bookingInfo + ' because it has deposit or service or not in Booked status.\\n';
                }
            }
        }
        return message;
    });

    return transactionResult;
}

async function updateReservation(hotel: string, reservation: any): Promise<string> {
    let result = '';
    const firestore = admin.firestore();
    const hotelRef = firestore.collection('hotels').doc(hotel);
    const hotelDoc = await hotelRef.get();
    const timeZone = hotelDoc.get('timezone');
    const cmSource = reservation.BookingSource.Name;
    // const source = await getSource(hotel, cmSource);
    const sID = reservation.ExtBookingRef ?? '';
    console.log("NameHotel ALL END UPDATE:" + hotelDoc.get('name') + "SID" + sID);
    const bookings = (await hotelRef.collection('bookings').where('sid', '==', sID).get()).docs;
    console.log(`update reservation with sid ${sID} - cmSource:${cmSource} - booking num: ${bookings.length}: - hotel: ${hotelDoc.get('name')}`);
    if (bookings.length === 0) {
        result += await addReservation(hotel, reservation);
    } else {
        const isUpdatable = bookings.every((booking) => isCancellable(booking.data()));
        if (isUpdatable) {
            console.log(`delete booking with sid: ${sID} - pms source: ${bookings[0].get('source')} - cmsource: ${cmSource} `);
            result += await cancelReservation(hotel, reservation, true);
            result += await addReservation(hotel, reservation);
        } else {
            let bookingInfo;
            if (bookings.length > 0) {
                const booking = bookings[0].data();
                const sid = booking.sid;
                const src = booking.source;
                const name = booking.name;
                const cin = DateUtil.dateToShortString(DateUtil.convertUpSetTimezone(booking.in_date.toDate(), timeZone));
                const cout = DateUtil.dateToShortString(DateUtil.convertUpSetTimezone(booking.out_date.toDate(), timeZone));
                bookingInfo = '(sid: ' + sid + ', source: ' + src + ',name: ' + name + ', in: ' + cin + ', out: ' + cout + ')';
            } else {
                const cin = reservation.CheckIn;
                const cout = reservation.CheckOut;
                const name = reservation.Guests.FirstName + " " + reservation.Guests.LastName;
                const src = reservation.BookingSource.Name;
                const sid = reservation.BookingSource.ID;
                bookingInfo = '(sid: ' + sid + ', source: ' + src + ', name: ' + name + ', in: ' + cin + ', out: ' + cout + ')';
            }
            result = 'Failed to update booking ' + bookingInfo + ' because it has deposit or service or not in Booked status.\\n';
        }
    }

    return result;
};

exports.updateinventory = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    const hotelID = mappingHotelInfo.id;
    const hotelKey = mappingHotelInfo.key;

    const roomID = data.roomID;
    const from = data.from;
    const to = data.to;
    const ratePlanID = data.ratePlanID;
    const type = data.type;
    const value = data.value;

    const result = await HLSUtil.updateInventory(hotelID, hotelKey, roomID, from, to, ratePlanID, type, value);
    if (result === null) {
        return { error: MessageUtil.CM_UPDATE_INVENTORY_FAIL, result: false };
    }

    return { result: true };
});

exports.getbookings = functions.https.onCall(async (data, context) => {

    const hotel = data.hotel;
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    const hotelID = mappingHotelInfo.id;
    const hotelKey = mappingHotelInfo.key;
    const startDate = data.startDate;
    const endDate = data.endDate;
    const dateFilter = data.dateFilter;
    const bookingStatus = data.bookingStatus;
    const numberBookings = data.numberBookings;
    const result = await HLSUtil.getReservationsFromCM(hotelID, hotelKey, startDate, endDate, dateFilter, bookingStatus, numberBookings);
    if (result === null) {
        return { error: MessageUtil.CM_GET_BOOKINGS_FAIL, result: false };
    }
    return {
        result: true,
        reservation: result.Bookings
    };

});

exports.updateReleasePeriod = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    if (data.value === null) {
        return { error: MessageUtil.CM_UPDATE_AVAIBILITY_RATE_FAIL, result: false };
    }
    const hotelID = mappingHotelInfo.id;
    const hotelKey = mappingHotelInfo.key;
    const value: number = data.value;
    const roomId = data.roomID;
    const from = data.from;
    const to = data.to;
    const result = await HLSUtil.updateAvaibilityToCM(hotelID, hotelKey, roomId, from, to, 'ReleasePeriod', 'Set', value);
    if (result === null) {
        return { error: MessageUtil.CM_UPDATE_AVAIBILITY_FAIL, result: false };
    }
    return { result: true };

});

exports.updateavaibility = functions.runWith({ timeoutSeconds: 150 }).https.onCall(async (data, context) => {
    const hotelID = data.hotel;
    const hotelRef = fireStore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotelID);
    const auto_rate: boolean = hotelDoc.get('auto_rate') ?? true;
    const timezone = mappingHotelInfo.timezone;
    const roomType = data.roomType;
    const from = data.from;
    const to = data.to;
    const chooseDay: number[] = data.chooseDay;
    const rate: number | null = data.rate;
    const value: number | null = data.value;
    const startDay = new Date(from);
    const endDay = new Date(to);
    let staysDay = DateUtil.getStayDates(startDay, endDay);
    const nowTimezone = DateUtil.convertUpSetTimezone(new Date, timezone);
    const now12Timezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
    staysDay.push(endDay);
    staysDay = staysDay.filter((e) => e.getTime() >= now12Timezone.getTime());
    const batch = fireStore.batch();
    let monthID = DateUtil.dateToShortStringYearMonth(staysDay[0]);
    const almMap: { [key: string]: any } = {};
    let roomTypeCm;

    if (mappingHotelInfo.id !== null) {
        roomTypeCm = await NeutronUtil.getCmRoomType(hotelID, roomType);
        almMap[roomTypeCm.id] = {};
    }

    if (chooseDay.length === 0 || chooseDay.length === 7) {
        let dataUpdate: { [key: string]: any } = {};
        for (const date of staysDay) {
            if (DateUtil.dateToShortStringYearMonth(date) !== monthID) {
                batch.update(fireStore.collection('hotels').doc(hotelID).collection('daily_allotment').doc(monthID), dataUpdate);
                monthID = DateUtil.dateToShortStringYearMonth(date);
                dataUpdate = {};
            }
            if (value !== null) {
                dataUpdate['data.' + date.getDate() + '.' + roomType + '.num'] = value;
            }

            if (rate !== null) {
                dataUpdate['data.' + date.getDate() + '.' + roomType + '.price'] = rate;
            }
        }
        batch.update(fireStore.collection('hotels').doc(hotelID).collection('daily_allotment').doc(monthID), dataUpdate);
        await batch.commit();
    } else {
        // update daily allotment base on stay days
        staysDay = staysDay.filter((e) => chooseDay.indexOf(e.getDay()) !== -1);
        let dataUpdate: { [key: string]: any } = {};
        for (const date of staysDay) {
            if (DateUtil.dateToShortStringYearMonth(date) !== monthID) {
                batch.update(fireStore.collection('hotels').doc(hotelID).collection('daily_allotment').doc(monthID), dataUpdate);
                monthID = DateUtil.dateToShortStringYearMonth(date);
                dataUpdate = {};
            }
            if (value !== null) {
                dataUpdate['data.' + date.getDate() + '.' + roomType + '.num'] = value;
                if (roomTypeCm !== undefined) {
                    const dateHls = monthID.substring(0, 4) + '-' + monthID.substring(4, 6) + '-' + (date.getDate() >= 10 ? date.getDate() : '0' + date.getDate());
                    almMap[roomTypeCm.id][dateHls] = {};
                    almMap[roomTypeCm.id][dateHls]['num'] = value;
                    almMap[roomTypeCm.id][dateHls]['ratePlanID'] = '';
                }
            }
            if (rate !== null) {
                dataUpdate['data.' + date.getDate() + '.' + roomType + '.price'] = rate;
                if (roomTypeCm !== undefined) {
                    const dateHls = monthID.substring(0, 4) + '-' + monthID.substring(4, 6) + '-' + (date.getDate() >= 10 ? date.getDate() : '0' + date.getDate());
                    if (almMap[roomTypeCm.id][dateHls] === undefined) {
                        almMap[roomTypeCm.id][dateHls] = {};
                    }
                    if (almMap[roomTypeCm.id][dateHls]['num'] === undefined) {
                        almMap[roomTypeCm.id][dateHls]['num'] = ''
                    }
                    almMap[roomTypeCm.id][dateHls]['price'] = rate;
                    almMap[roomTypeCm.id][dateHls]['ratePlanID'] = roomTypeCm.ratePlanID;
                }
            }
        }
        if (DateUtil.dateToShortStringYearMonth(staysDay[staysDay.length - 1]) === monthID) {
            batch.update(fireStore.collection('hotels').doc(hotelID).collection('daily_allotment').doc(monthID), dataUpdate);
        }
        await batch.commit();
    }
    if (mappingHotelInfo.id !== null && roomTypeCm !== undefined) {
        if (chooseDay.length === 0 || chooseDay.length === 7) {
            const fromHls: string = DateUtil.dateToShortStringHls(startDay);
            const endHls: string = DateUtil.dateToShortStringHls(endDay);
            if (value !== null && rate !== null) {
                almMap[roomTypeCm.id]['num'] = value;
                almMap[roomTypeCm.id]['ratePlanID'] = roomTypeCm.ratePlanID;
                almMap[roomTypeCm.id]['price'] = rate;
            } else if (value === null) {
                almMap[roomTypeCm.id]['num'] = '';
                almMap[roomTypeCm.id]['ratePlanID'] = roomTypeCm.ratePlanID;
                almMap[roomTypeCm.id]['price'] = rate;
            } else if (rate === null) {
                almMap[roomTypeCm.id]['num'] = value;
                almMap[roomTypeCm.id]['ratePlanID'] = '';
            }
            const result = await HLSUtil.updateAvaibilityWithNewMonthToCM(mappingHotelInfo.id, mappingHotelInfo.key, almMap, fromHls, endHls, auto_rate);
            if (result === null) {
                console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
            }
        } else {
            const result = await HLSUtil.updateMultipleAvaibility(mappingHotelInfo.id, mappingHotelInfo.key, almMap, auto_rate);
            if (result === null) {
                console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
            }
        }
    }

    return MessageUtil.SUCCESS;
});

exports.reservationlistener = functions.runWith({ minInstances: 1 }).https.onRequest(async (request, respond) => {
    const body = JSON.parse(request.rawBody.toString());

    const hotelID = body.HotelId;
    const bookingID = body.BookingId;

    if (hotelID === undefined || bookingID === undefined) {
        respond.end();
        return;
    }

    const reservationInfo = "(HotelId: " + hotelID + ", BookingId: " + bookingID + ")";

    const hotel = await getHotel(hotelID);
    if (hotel === '') {
        console.log("HotelId " + hotelID + " has not been mapped to CM!");
        respond.end();
        return;
    }

    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "HotelId " + hotelID + " has not been mapped to CM!", 'error');
        respond.end();
        return;
    }

    const hotelKey = mappingHotelInfo.key;

    const data = await HLSUtil.getReservationFromCM(hotelID, hotelKey, bookingID, hotel);

    console.log("Data", data);

    if (data === null) {
        console.log(`Failed to get reservation ${reservationInfo}`);
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "Failed to get reservation " + reservationInfo + " from CM!", 'error');
        respond.end();
        return;
    }

    const reservations = data.Bookings;

    if (reservations.length === 0) {
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "No reservation to get from " + reservationInfo + " of CM!", 'error');
        respond.end();
        return;
    }

    const reservation = reservations[0];
    let log = '';
    console.log('Status ' + reservation.NotificationType);
    if (reservation.NotificationType === 'Cancelled') {
        console.log(1365);
        log = await cancelReservation(hotel, reservation, false);
    } else if (reservation.NotificationType === 'Modified' || reservation.NotificationType === 'New') {
        console.log(1368);
        log = await updateReservation(hotel, reservation);
    }

    const logResult = log.includes('Failed') ? 'Failed' : 'Passed';
    const logStatus = log.includes('Failed') ? 'error' : 'info';
    await LogUtil.logCM(hotel, 'update_booking', 'CM - ' + logResult + ' - Sync Notification - ' + reservationInfo, log, logStatus);

    if (logResult === 'Passed') { await HLSUtil.notifyCM(hotelID, hotelKey, bookingID); }

    console.log(1378);
    respond.end();
});

exports.notifybooking = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const bookingID = data.bookingID;

    if (hotel === undefined || hotel === '') {
        return { result: false, error: MessageUtil.CM_HOTEL_EMPTY };
    }

    if (bookingID === undefined || bookingID === '') {
        return { result: false, error: MessageUtil.CM_BOOKING_EMPTY };
    }

    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    const hotelID = mappingHotelInfo.id;
    const hotelKey = mappingHotelInfo.key;

    const result = await HLSUtil.notifyCM(hotelID, hotelKey, data.bookingID);
    return { result: result };
});

exports.syncbooking = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const reservation = data.booking;

    if (hotel === undefined || hotel === '') {
        return { result: false, error: MessageUtil.CM_HOTEL_EMPTY };
    }

    if (reservation === undefined || reservation === '') {
        return { result: false, error: MessageUtil.CM_BOOKING_EMPTY };
    }

    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    const hotelID = mappingHotelInfo.id;
    const hotelKey = mappingHotelInfo.key;

    let log = '';
    if (reservation.NotificationType === 'Cancelled') {
        log = await cancelReservation(hotel, reservation, false);
    } else if (reservation.NotificationType === 'Modified' || reservation.NotificationType === 'New') {
        log = await updateReservation(hotel, reservation);
    }
    const result = log.includes('Failed') ? false : true;

    if (result) {
        await HLSUtil.notifyCM(hotelID, hotelKey, reservation.BookingId);
    }

    return { result: result, error: log };
});

exports.syncchannelmanager = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    console.log(mappingHotelInfo);
    
    if (mappingHotelInfo === null) {
        return { error: MessageUtil.CM_NOT_MAP_HOTEL, result: false };
    }
    const firestore = admin.firestore();
    const batch = firestore.batch();
    const hotelRef = firestore.collection('hotels').doc(hotel);
    const cmsType = mappingHotelInfo.type;
    if (cmsType === CmsType.hotellink) {
        const hotelID = mappingHotelInfo.id;
        const hotelKey = mappingHotelInfo.key;

        const result = await HLSUtil.getRatePlansFromHotelLink(hotelID, hotelKey);
        if (result !== null) {

            const roomTypes = result.Rooms;
            for (const roomType of roomTypes) {
                batch.set(hotelRef.collection('cm_room_types').doc(roomType.RoomId), {
                    'name': roomType.Name
                }, { merge: true });

                const ratePlans = roomType.RatePlans;
                for (const ratePlan of ratePlans) {
                    batch.set(hotelRef.collection('cm_room_types').doc(roomType.RoomId).collection('cm_rate_plans').doc(ratePlan.RatePlanId), {
                        'name': ratePlan.Name,
                        'room_type_id': roomType.RoomId,
                        'breakfast': ratePlan.MealsIncluded.Breakfast,
                        'lunch': ratePlan.MealsIncluded.Lunch,
                        'dinner': ratePlan.MealsIncluded.Dinner,
                    }, { merge: true });
                }
            }
            await batch.commit();
            return MessageUtil.SUCCESS;
        }
        else {
            return MessageUtil.CM_SYNC_FAIL;
        }
    } else {
        const propertyId = mappingHotelInfo.propertyId;
        const romeTypes = await HLSUtil.getRoomTypesFromChannex(propertyId);
        const ratePlans = await HLSUtil.getRatePlansFromChannex(propertyId);
        console.log('romeTypes', romeTypes);
        console.log('---------------');
        
        console.log('ratePlans', ratePlans);
        
        if (romeTypes !== null || ratePlans !== null) {
            for (const roomType of romeTypes) {
                console.log(roomType.id);
                
                batch.set(hotelRef.collection('cm_room_types').doc(roomType.id), {
                    'name': roomType.attributes.title
                }, { merge: true });
            }
            for (const ratePlan of ratePlans) {
                const roomTypeId: string = ratePlan.relationships.room_type.data.id;
                let breakfast = false;
                let lunch = false;
                let dinner = false;
                switch (ratePlan.meal_type) {
                    case ChannexMealTypes.breakfast:
                        breakfast = true;
                        break;
                    case ChannexMealTypes.lunch: lunch = true; break;
                    case ChannexMealTypes.dinner: dinner = true; break;
                    case ChannexMealTypes.lunchAndDinner: lunch = true; dinner = true; break;
                    case ChannexMealTypes.all: lunch = true; breakfast = true; dinner = true; break;
                    case ChannexMealTypes.breakfastAndLunch: breakfast = true; lunch = true; break;
                }
                console.log(roomTypeId, '----', ratePlan.id);
                
                batch.set(hotelRef.collection('cm_room_types').doc(roomTypeId).collection('cm_rate_plans').doc(ratePlan.id), {
                    'name': ratePlan.attributes.title,
                    'room_type_id': roomTypeId,
                    'breakfast': breakfast,
                    'lunch': lunch,
                    'dinner': dinner,
                }, { merge: true });
            }
            await batch.commit();
            return MessageUtil.SUCCESS;
        } else {
            {
                return MessageUtil.CM_SYNC_FAIL;
            }
        }
    }


});

exports.getreservationjson = functions.https.onRequest(async (request, respond) => {
    const body = JSON.parse(request.rawBody.toString());

    const hotelID = body.HotelId;
    const bookingID = body.BookingId;

    if (hotelID === undefined || bookingID === undefined) {
        console.log('HotelId or BookingId is undefined');
        respond.end();
        return;
    }

    const reservationInfo = "(HotelId: " + hotelID + ", BookingId: " + bookingID + ")";

    const hotel = await getHotel(hotelID);
    if (hotel === '') {
        console.log("HotelId " + hotelID + " has not been mapped to CM!");
        respond.end();
        return;
    }

    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
    if (mappingHotelInfo === null) {
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "HotelId " + hotelID + " has not been mapped to CM!", 'error');
        respond.end();
        return;
    }

    const hotelKey = mappingHotelInfo.key;

    const data = await HLSUtil.getReservationFromCM(hotelID, hotelKey, bookingID, hotel);
    if (data === null) {
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "Failed to get reservation " + reservationInfo + " from CM!", 'error');
        respond.end();
        return;
    }

    const reservations = data.Bookings;
    if (reservations.length === 0) {
        await LogUtil.logCM(hotel, 'update_booking', 'CM - Failed - Sync Notification - ' + reservationInfo, "No reservation to get from " + reservationInfo + " of CM!", 'error');
        respond.end();
        return;
    }

    const reservation = reservations[0];

    respond.send(reservation);
});
// deploy here - need test more
exports.syncavaibility = functions.https.onCall(async (data, context) => {
    const hotel = data.hotel;
    const from = data.from;
    const to = data.to;

    const fromDate = DateUtil.shortStringToDate(from);
    const toDate = DateUtil.shortStringToDate(to);
    const stayDays = DateUtil.getStayDates(fromDate, toDate);
    stayDays.push(toDate);
    if (stayDays.length > 500) {
        return { error: MessageUtil.CM_MAXIMUM_DATE_RANGE, result: false };
    }

    const mappedRoomTypes = await NeutronUtil.getMappedRoomTypes(hotel);

    if (mappedRoomTypes.length === 0) {
        return { error: MessageUtil.CM_NOT_MAP_ROOMTYPE, result: false };
    }

    // update num of cm room type ID
    const result = await NeutronUtil.updateAvaibilityToHLS(hotel, mappedRoomTypes, stayDays);
    if (result) {
        return { result: true };
    } else {
        return { error: MessageUtil.UNDEFINED_ERROR, result: false };
    }

});

exports.saveMappingHotelID = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
    if (!hotelRef.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = [UserRole.admin];
    //roles of user who make this request
    const roleOfUser: string[] = hotelRef.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }
    if(data.cms_type == CmsType.hotellink){
        await hotelRef.ref.update({ 'mapping_hotel_id': data.mapping_hotel_id, 'mapping_hotel_key': data.mapping_hotel_key,'cms': CmsType.hotellink  });
    }else{
        await hotelRef.ref.update({ 'property_id': data.property_id, 'cms': CmsType.oneCms });
    }
    return true;
})

exports.saveMappingRoomTypeToCloud = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
    if (!hotelRef.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = [UserRole.admin];
    //roles of user who make this request
    const roleOfUser: string[] = hotelRef.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    await hotelRef.ref.collection('cm_room_types').doc(data.cm_room_type_id).update({ 'mapping_room_type': data.mapping_room_type });

    return true;
})

exports.saveMappingRatePlanToCloud = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
    if (!hotelRef.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = [UserRole.admin];
    //roles of user who make this request
    const roleOfUser: string[] = hotelRef.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    await hotelRef.ref.collection('cm_room_types').doc(data.cm_room_type_id).update({ 'mapping_rate_plan': data.rate_plan_id });

    return true;
})

exports.clearAllCmRoomType = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('permission-denied', MessageUtil.UNAUTHORIZED);

    const hotelRef = await fireStore.collection('hotels').doc(data.hotel_id).get();
    if (!hotelRef.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    //roles allow to change database
    const rolesAllowed: string[] = [UserRole.admin];
    //roles of user who make this request
    const roleOfUser: string[] = hotelRef.get('role')[context.auth.uid];

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const batch = fireStore.batch();
    const cmRoomTypesRef = await hotelRef.ref.collection('cm_room_types').get();
    for (const cmRoomType of cmRoomTypesRef.docs) {
        const ratePlanOfRoomTypes = await cmRoomType.ref.collection('cm_rate_plans').get();
        for (const ratePlan of ratePlanOfRoomTypes.docs) {
            batch.delete(ratePlan.ref);
        }
        batch.delete(cmRoomType.ref);
    }

    await batch.commit();
    return true;
})

exports.onCreateDailyAllotment = functions.firestore.document('hotels/{hotelID}/daily_allotment/{monthID}').onCreate(async (snap, context) => {
    const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(context.params.hotelID);
    // todo if hotel not contain key no update for channel
    if (mappingHotelInfo.id === null) return;
    const monthID = context.params.monthID;
    const dailyAllotment: { [key: string]: any } = snap.data();
    const almMap: { [key: string]: { [key: string]: number | string } } = {};
    const lastDayInMonth: number = new Date(parseInt(monthID.substring(0, 4)), parseInt(monthID.substring(4, 6)), 0).getDate();
    const decreaseMonth: number = parseInt(monthID.substring(4, 6)) - 1;
    const from = monthID.substring(0, 4) + '-' + (decreaseMonth < 10 ? '0' + decreaseMonth : decreaseMonth) + '-01';
    const to = monthID.substring(0, 4) + '-' + (decreaseMonth < 10 ? '0' + decreaseMonth : decreaseMonth) + '-' + lastDayInMonth;
    for (const roomType in dailyAllotment[lastDayInMonth]) {
        const cmRoomType = await getCmRoomType(context.params.hotelID, roomType);
        almMap[cmRoomType.id] = {};
        almMap[cmRoomType.id]['num'] = dailyAllotment[lastDayInMonth][roomType]['num'];
        almMap[cmRoomType.id]['price'] = dailyAllotment['default'][roomType]['price'];
        almMap[cmRoomType.id]['ratePlanID'] = cmRoomType.ratePlanID
    }

    const result = await HLSUtil.updateAvaibilityWithNewMonthToCM(mappingHotelInfo.id, mappingHotelInfo.key, almMap, from, to, true);
    if (result === null) {
        console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
    }

})