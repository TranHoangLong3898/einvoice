import { API_KEY} from '../constant/cms';
import { NumberUtil } from './numberutil';
import { RestUtil } from "./restutil";
let is_admin_initialize = false;
let access_token: string | null = null;
let created_token: Date | null = null;

export class HLSUtil {

    static async getAccessTokenWithGlobalStartVariable() {
        const now = new Date();
        if (access_token !== null && created_token !== null) {
            if ((now.getTime() - created_token.getTime()) > 1 * 60 * 60 * 1000) {
                access_token = await this.getAccessTokenFromCM();
                created_token = now;
            }
        } else {
            access_token = await this.getAccessTokenFromCM();
            created_token = now;
        }
    }

    static async getRatePlansFromHotelLink(hotelID: string, hotelKey: string): Promise<any> {
        await this.getAccessTokenWithGlobalStartVariable();

        const postData = JSON.stringify({
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        });

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/getRatePlans',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);

        if (typeof respond === 'string') {
            return null;
        }

        if (respond.result) {
            return respond.data;
        } else {
            return null;
        }
    }

    
    static async getRoomTypesFromChannex(propertyId: string): Promise<any> {
        const options = {
            hostname: 'staging.channex.io',
            path: '/api/v1/room_types',
            method: 'GET',
            headers: {
                "user-api-key": API_KEY,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.getRequest(options);
        console.log(respond);

        if (typeof respond === 'string') {
            return null;
        }else{

            return respond.data.filter((roomType: any)=> roomType.relationships.property.data.id == propertyId);
        }
    }

    static async getRatePlansFromChannex(propertyId: string): Promise<any> {
        const options = {
            hostname: 'staging.channex.io',
            path: '/api/v1/rate_plans',
            method: 'GET',
            headers: {
                "user-api-key": API_KEY,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.getRequest(options);

        if (typeof respond === 'string') {
            return null;
        }else{
            return  respond.data.filter((roomType: any)=> roomType.relationships.property.data.id == propertyId);

        }
    }

    static async updateAvaibilityToCM(hotelID: string, hotelKey: string, roomID: string, from: string, to: string, type: string, action: string, value: number): Promise<any> {

        await this.getAccessTokenWithGlobalStartVariable();

        let postData;

        if (type === 'Avaibility') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "Availabilities": [
                            {
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                },
                                "Quantity": value,
                                "Action": action
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'ReleasePeriod') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "Availabilities": [
                            {
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                },
                                "ReleasePeriod": value,
                                "Action": action
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else { return null; }

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/saveInventory',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);

        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data;
        } else {
            return null;
        }
    }

    static async updateAvaibilityWithNewMonthToCM(hotelID: string, hotelKey: string, almMap: { [key: string]: { [key: string]: number | string } }, from: string, to: string, autoRate: boolean): Promise<any> {

        await this.getAccessTokenWithGlobalStartVariable();

        const result: {}[] = [];
        for (const roomID in almMap) {
            const dataUpdate: { [key: string]: any } = {};
            dataUpdate["RoomId"] = roomID;
            if (almMap[roomID]['num'] !== '') {
                dataUpdate['Availabilities'] = [
                    {
                        "DateRange": {
                            "From": from,
                            "To": to
                        },
                        "Quantity": almMap[roomID]['num'],
                        "Action": 'Set'
                    }
                ]
            };
            if (almMap[roomID]['ratePlanID'] !== '' && autoRate) {
                dataUpdate['RatePackages'] = [
                    {
                        'RatePlanId': almMap[roomID]['ratePlanID'],
                        'Rate': {
                            'Amount': {
                                "Type": "FIXED_AMOUNT",
                                "Value": almMap[roomID]['price'],
                                "Currency": "VND"
                            },
                            "Action": "Set"
                        },
                        'DateRange': {
                            "From": from,
                            "To": to
                        }
                    }
                ]
            }
            result.push(dataUpdate);
        }

        const postData = JSON.stringify({
            "Inventories": result,
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        })

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/saveInventory',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);
        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data;
        } else {
            return null;
        }
    }

    static async updateMultipleAvaibility(hotelID: string, hotelKey: string, almMap: { [key: string]: { [key: string]: { [key: string]: number | string } } }, autoRate: boolean): Promise<boolean> {

        await this.getAccessTokenWithGlobalStartVariable();

        const result: any[] = [];
        for (const roomID in almMap) {
            const roomData: { [key: string]: any } = {};
            roomData["RoomId"] = roomID;
            const lstDateData = [];
            const ratesData = [];
            for (const date in almMap[roomID]) {
                if (almMap[roomID][date]['num'] !== '') {
                    const dateData = {
                        "DateRange": {
                            "From": date,
                            "To": date
                        },
                        "Quantity": almMap[roomID][date]['num'],
                        "Action": 'Set'
                    };
                    lstDateData.push(dateData);
                }
                if (almMap[roomID][date]['ratePlanID'] !== '' && autoRate) {
                    const ratePlanData = {
                        'RatePlanId': almMap[roomID][date]['ratePlanID'],
                        'Rate': {
                            'Amount': {
                                'Type': 'FIXED_AMOUNT',
                                'Value': almMap[roomID][date]['price'],
                                'Currency': 'VND'
                            },
                            'Action': 'Set'
                        },
                        "DateRange": {
                            "From": date,
                            "To": date
                        }
                    };
                    ratesData.push(ratePlanData);
                };
            }
            if (lstDateData.length !== 0) {
                roomData['Availabilities'] = lstDateData;
            }
            if (ratesData.length !== 0) {
                roomData['RatePackages'] = ratesData;
            }
            result.push(roomData);
        }

        const postData = JSON.stringify({
            Inventories: result,
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        });

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/saveInventory',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };
        const respond = await RestUtil.postRequest(options, postData);

        if (typeof respond === 'string') {
            return false;
        }
        if (respond.result) {
            return true;
        } else {
            return false;
        }
    }

    static async getAccessTokenFromCM(): Promise<any> {
        const account = 'onepms:N3JQyEg08U';
        const userPasswordString = Buffer.from(account);
        const base64String = userPasswordString.toString('base64');
        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/oAuth/token',
            method: 'POST',
            headers: {
                "Authorization": "Basic " + base64String
            }
        };
        const respond = await RestUtil.postRequest(options, JSON.stringify({}));
        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data.access_token;
        } else {
            return null;
        }
    }

    static async notifyCM(hotelID: string, hotelKey: string, bookingID: string): Promise<boolean> {
        await this.getAccessTokenWithGlobalStartVariable();

        const postData = JSON.stringify({
            Bookings: {
                "item": bookingID
            },
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        });

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/readNotification',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const res = await RestUtil.postRequest(options, postData);
        if (typeof res === 'string') {
            return false;
        }
        if (res.result) {
            return true;
        } else {
            return false;
        }
    }



    static async getReservationFromCM(hotelID: string, hotelKey: String, bookingID: string, hotelID_firestore: string): Promise<any> {
        await this.getAccessTokenWithGlobalStartVariable();


        const postData = JSON.stringify({
            BookingId: bookingID,
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        });

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/getBookings',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);
        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data;
        } else {
            const admin = await import('firebase-admin');
            if (!is_admin_initialize) {
                admin.initializeApp();
                is_admin_initialize = true;
            }
            const firestore = admin.firestore();
            const id = NumberUtil.getRandomID();
            const hotelRef = firestore.collection('admin_logs').doc(id);
            await hotelRef.set({
                'hotel': hotelID_firestore,
                'booking_id': bookingID,
                'result': respond,
                'retry_quantity': 1,
                'created': new Date()
            });
            return null;
        }

        // let respond;
        // let retry_quantity = 0;
        // for (let index = 0; index < 2; index++) {
        //     respond = await RestUtil.postRequest(options, postData);
        //     if (typeof respond === 'string') {
        //         return null;
        //     }
        //     if (respond.result) {
        //         return respond.data;
        //     } else {
        //         retry_quantity++;
        //         HLSUtil.accessToken = await HLSUtil.getAccessTokenFromCM();
        //         options['headers'] = {
        //             "Authorization": "Bearer " + HLSUtil.accessToken,
        //             "Content-Type": "application/json"
        //         }
        //     }
        // }

        // const admin = await import('firebase-admin');
        // if (!is_admin_initialize) {
        //     admin.initializeApp();
        //     is_admin_initialize = true;
        // }
        // const firestore = admin.firestore();
        // const id = NumberUtil.getRandomID();
        // const hotelRef = firestore.collection('admin_logs').doc(id);
        // await hotelRef.set({
        //     'hotel': hotelID_firestore,
        //     'booking_id': bookingID,
        //     'result': respond,
        //     'retry_quantity': 1,
        //     'created': new Date()
        // });
        // return null;

    }

    static async getReservationsFromCM(hotelID: string, hotelKey: string, startDate: string, endDate: string, dateFilter: string, bookingStatus: string, numberBookings: string): Promise<any> {
        await this.getAccessTokenWithGlobalStartVariable();

        const postData = JSON.stringify({
            StartDate: startDate,
            EndDate: endDate,
            DateFilter: dateFilter,
            BookingStatus: bookingStatus,
            NumberBookings: numberBookings,
            Credential: {
                "HotelId": hotelID,
                "HotelAuthenticationChannelKey": hotelKey
            },
            Lang: "en"
        });

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/getBookings',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);

        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data;
        } else {
            return null;
        }
    }

    static async updateInventory(hotelID: string, hotelKey: string, roomID: string, from: string, to: string, ratePlanID: string, type: string, value: number): Promise<any> {
        await this.getAccessTokenWithGlobalStartVariable();

        let postData;
        if (type === 'Rate') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "Rate": {
                                    "Amount": {
                                        "Type": "FIXED_AMOUNT",
                                        "Value": value,
                                        "Currency": "VND"
                                    },
                                    "Action": "Set"
                                },
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'ExtraAdultRate') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "ExtraAdultRate": {
                                    "Amount": {
                                        "Type": "FIXED_AMOUNT",
                                        "Value": value,
                                        "Currency": "VND"
                                    },
                                    "Action": "Set"
                                },
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'ExtraChildRate') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "ExtraChildRate": {
                                    "Amount": {
                                        "Type": "FIXED_AMOUNT",
                                        "Value": value,
                                        "Currency": "VND"
                                    },
                                    "Action": "Set"
                                },
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'MinNights') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "MinNights": value,
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'MaxNights') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "MaxNights": value,
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'CloseToArrival') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "CloseToArrival": value,
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'CloseToDeparture') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "CloseToDeparture": value,
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        } else if (type === 'StopSell') {
            postData = JSON.stringify({
                "Inventories": [
                    {
                        "RoomId": roomID,
                        "RatePackages": [
                            {
                                "RatePlanId": ratePlanID,
                                "StopSell": value,
                                "DateRange": {
                                    "From": from,
                                    "To": to
                                }
                            }
                        ]
                    }
                ],
                Credential: {
                    "HotelId": hotelID,
                    "HotelAuthenticationChannelKey": hotelKey
                },
                Lang: "en"
            });
        }

        const options = {
            hostname: 'api.hotellinksolutions.com',
            path: '/external/pms/saveInventory',
            method: 'POST',
            headers: {
                "Authorization": "Bearer " + access_token,
                "Content-Type": "application/json"
            }
        };

        const respond = await RestUtil.postRequest(options, postData);
        if (typeof respond === 'string') {
            return null;
        }
        if (respond.result) {
            return respond.data;
        } else {
            return null;
        }
    }
}