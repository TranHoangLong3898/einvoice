import admin = require('firebase-admin');
import { UserRole } from '../constant/userrole';
import { DateUtil } from "./dateutil";
import { HLSUtil } from './hlsutil';
import { MessageUtil } from './messageutil';
import { PaymentStatus } from '../constant/status';
import { BookingType, WarehouseNoteType } from '../constant/type';
import { CmsType } from '../constant/cms';
const firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
// const FieldPath = admin.firestore.FieldPath;

export class NeutronUtil {
    static kZero = 0.01;
    static maxActivitiesPerArray = 100;
    static maxActivitiesDoc = 30;
    static specificChar = String.fromCharCode(3);
    static noneWarehouse: string = 'none';
    static uidAdmin = 'NInD8909g6Vln9OEnqeKcKrcoEA2'; //admin@onepms.net  ---   Admin!@#123
    static uidSupport = 'lrC8ZIK0cQZHdIcGiTinj2vr2G33'; //marketing.onepms@gmail.com   

    static rolesCheckOut = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesUndoCheckout = [UserRole.receptionist, UserRole.owner, UserRole.manager, UserRole.support, UserRole.admin, UserRole.sale];

    static rolesCheckIn = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesUndoCheckIn = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesUpdateStatus = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.approver];
    static rolesAddOrUpdateBooking = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.partner, UserRole.internalPartner];
    static rolesUpdateTaxDeclare = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.accountant];
    static rolesCancelBooking = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.partner, UserRole.internalPartner, UserRole.approver];

    static rolesSetNoneRoom = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesDeleteRepair = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesSaveNotesBooking = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.partner, UserRole.approver, UserRole.internalPartner];
    static rolesAddOrUpdateOrDeleteDiscountBooking = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesAddOrUpdateVirtualBooking = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesUpdateStatusInvoice = [UserRole.admin, UserRole.manager, UserRole.owner, UserRole.sale, UserRole.accountant];

    static rolesAddOrUpdatePayment = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.receptionist, UserRole.sale, UserRole.internalPartner];
    static rolesDeleteOrPayment = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.accountant, UserRole.internalPartner];
    static rolesUpdateStatusPayment = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.accountant];

    static rolesAddServiceForBooking = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.housekeeping, UserRole.receptionist, UserRole.sale, UserRole.internalPartner];
    static rolesUpdateServiceForBooking = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.receptionist, UserRole.sale, UserRole.internalPartner];
    static rolesUpdateStatusService = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.receptionist, UserRole.sale];
    static rolesDeleteServiceForBooking = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.receptionist, UserRole.sale, UserRole.internalPartner];
    static rolesDeleteRestaurantService = [UserRole.admin, UserRole.owner, UserRole.manager];

    static rolesCreateOrUpdateHotelService = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];
    static rolesUpdateExtraBedOrExtraHour = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.sale, UserRole.receptionist, UserRole.internalPartner];
    static rolesUpdateStaticService = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner, UserRole.accountant];
    static rolesAddOrUpdateExtraService = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner];
    static rolesUpdateBikeRentalProgress = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner, UserRole.receptionist, , UserRole.sale];
    static rolesChangeBike = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner, UserRole.receptionist, UserRole.sale];
    static rolesAddOrUpdateItemType = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner];
    static rolesAddCashLog = [UserRole.manager, UserRole.support, UserRole.admin, UserRole.owner, UserRole.receptionist];
    static rolesUpdateStatusCashLog = [...NeutronUtil.rolesAddCashLog, UserRole.accountant];

    static rolesConfigColor = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];
    static rolesConfigBikePrice = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];
    static rolesConfigTax = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];

    static rolesUpdateHotelOrCrudRoomTypeOrCrudRoom = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];
    static rolesUpdateRoomType = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.internalPartner];
    static rolesCrudRatePlan = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support];

    static rolesUpdateCleanRoom = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.housekeeping];
    static rolesUpdateExtraBed = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.housekeeping];

    static rolesCRUDSourceOfHotel = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.sale];
    static rolesManageUserOfHotel = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner];
    static rolesUserOfHotel = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.receptionist, UserRole.sale, UserRole.partner, UserRole.internalPartner];

    static rolesCRUDWarehouse = [UserRole.admin, UserRole.manager, UserRole.support, UserRole.owner, UserRole.accountant];
    static rolesCRUDWarehouseNote = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.accountant];
    static rolesCRUDSupplier = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.support, UserRole.accountant];
    static rolesCRUDItem = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.accountant];

    static rolesCRUDCostManagement = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.accountant];
    static rolesPolicy = [UserRole.admin, UserRole.owner, UserRole.manager];
    static rolesVacantCleanOvernight = [UserRole.admin, UserRole.owner, UserRole.manager];
    static rolesCRUDPaymetMethod = [UserRole.admin, UserRole.owner, UserRole.manager];
    static rolesCRUDEInvoice = [UserRole.admin, UserRole.owner, UserRole.manager, UserRole.eInvoiceManager];
    static rolesPackageVersion = [UserRole.admin];

    static timezoneForNegative12h: string[] = ['(UTC-12:00) International Date Line West'];
    static timezoneForNegative11h: string[] = ['(UTC-11:00) Coordinated Universal Time-11'];
    static timezoneForNegative10h: string[] = ['(UTC-10:00) Hawaii'];
    static timezoneForNegative9h: string[] = ['(UTC-09:00) Alaska'];
    static timezoneForNegative8h: string[] = ['(UTC-08:00) Baja California', '(UTC-08:00) Pacific Time (US & Canada)'];
    static timezoneForNegative7h: string[] = ['(UTC-07:00) Pacific Time (US & Canada)', '(UTC-07:00) Arizona', '(UTC-07:00) Chihuahua, La Paz, Mazatlan', '(UTC-07:00) Mountain Time (US & Canada)'];
    static timezoneForNegative6h: string[] = ['(UTC-06:00) Central America', '(UTC-06:00) Central Time (US & Canada)', '(UTC-06:00) Guadalajara, Mexico City, Monterrey', '(UTC-06:00) Saskatchewan'];
    static timezoneForNegative5h: string[] = ['(UTC-05:00) Bogota, Lima, Quito', '(UTC-05:00) Eastern Time (US & Canada)', '(UTC-05:00) Indiana (East)'];
    static timezoneForNegative4h: string[] = ['(UTC-04:30) Caracas', '(UTC-04:00) Asuncion', '(UTC-04:00) Atlantic Time (Canada)', '(UTC-04:00) Cuiaba', '(UTC-04:00) Georgetown, La Paz, Manaus, San Juan', '(UTC-04:00) Santiago'];
    static timezoneForNegative3h: string[] = ['(UTC-03:30) Newfoundland', '(UTC-03:00) Brasilia', '(UTC-03:00) Buenos Aires', '(UTC-03:00) Cayenne, Fortaleza', '(UTC-03:00) Greenland', '(UTC-03:00) Montevideo', '(UTC-03:00) Salvador'];
    static timezoneForNegative2h: string[] = ['(UTC-02:00) Coordinated Universal Time-02'];
    static timezoneForNegative1h: string[] = ['(UTC-01:00) Azores', '(UTC-01:00) Cape Verde Is.'];
    static timezoneFor0h: string[] = ['(UTC) Casablanca', '(UTC) Coordinated Universal Time', '(UTC) Edinburgh, London', '(UTC) Dublin, Lisbon', '(UTC) Monrovia, Reykjavik'];
    static timezoneForPositive1h: string[] = ['(UTC+01:00) Edinburgh, London', '(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna', '(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague', '(UTC+01:00) Brussels, Copenhagen, Madrid, Paris', '(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb', '(UTC+01:00) West Central Africa', '(UTC+01:00) Windhoek'];
    static timezoneForPositive2h: string[] = ['(UTC+02:00) Athens, Bucharest', '(UTC+02:00) Beirut', '(UTC+02:00) Cairo', '(UTC+02:00) Damascus', '(UTC+02:00) E. Europe', '(UTC+02:00) Harare, Pretoria', '(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius', '(UTC+02:00) Jerusalem', '(UTC+02:00) Tripoli', '(UTC+02:00) Kaliningrad'];
    static timezoneForPositive3h: string[] = ['(UTC+03:00) Istanbul', '(UTC+03:00) Amman', '(UTC+03:00) Baghdad', '(UTC+03:00) Kuwait, Riyadh', '(UTC+03:00) Nairobi', '(UTC+03:00) Moscow, St. Petersburg, Volgograd, Minsk', '(UTC+03:30) Tehran'];
    static timezoneForPositive4h: string[] = ['(UTC+04:00) Samara, Ulyanovsk, Saratov', '(UTC+04:00) Abu Dhabi, Muscat', '(UTC+04:00) Baku', '(UTC+04:00) Port Louis', '(UTC+04:00) Tbilisi', '(UTC+04:00) Yerevan', '(UTC+04:30) Kabul'];
    static timezoneForPositive5h: string[] = ['(UTC+05:00) Ashgabat, Tashkent', '(UTC+05:00) Yekaterinburg', '(UTC+05:00) Islamabad, Karachi', '(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi', '(UTC+05:30) Sri Jayawardenepura', '(UTC+05:45) Kathmandu'];
    static timezoneForPositive6h: string[] = ['(UTC+06:00) Nur-Sultan (Astana)', '(UTC+06:00) Dhaka', '(UTC+06:30) Yangon (Rangoon)'];
    static timezoneForPositive7h: string[] = ['(UTC+07:00) Bangkok, Hanoi, Jakarta', '(UTC+07:00) Novosibirsk'];
    static timezoneForPositive8h: string[] = ['(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi', '(UTC+08:00) Krasnoyarsk', '(UTC+08:00) Kuala Lumpur, Singapore', '(UTC+08:00) Perth', '(UTC+08:00) Taipei', '(UTC+08:00) Ulaanbaatar', '(UTC+08:00) Irkutsk'];
    static timezoneForPositive9h: string[] = ['(UTC+09:00) Osaka, Sapporo, Tokyo', '(UTC+09:00) Seoul', '(UTC+09:00) Yakutsk', '(UTC+09:30) Adelaide', '(UTC+09:30) Darwin'];
    static timezoneForPositive10h: string[] = ['(UTC+10:00) Brisbane', '(UTC+10:00) Canberra, Melbourne, Sydney', '(UTC+10:00) Guam, Port Moresby', '(UTC+10:00) Hobart'];
    static timezoneForPositive11h: string[] = ['(UTC+11:00) Solomon Is., New Caledonia', '(UTC+11:00) Vladivostok'];
    static timezoneForPositive12h: string[] = ['(UTC+12:00) Auckland, Wellington', '(UTC+12:00) Coordinated Universal Time+12', '(UTC+12:00) Fiji', '(UTC+12:00) Magadan'];

    static getTimezoneArrayByHour(hour: number): string[] {
        switch (hour) {
            case -12:
                return this.timezoneForNegative12h;
            case -11:
                return this.timezoneForNegative11h;
            case -10:
                return this.timezoneForNegative10h;
            case -9:
                return this.timezoneForNegative9h;
            case -8:
                return this.timezoneForNegative8h;
            case -7:
                return this.timezoneForNegative7h;
            case -6:
                return this.timezoneForNegative6h;
            case -5:
                return this.timezoneForNegative5h;
            case -4:
                return this.timezoneForNegative4h;
            case -3:
                return this.timezoneForNegative3h;
            case -2:
                return this.timezoneForNegative2h;
            case -1:
                return this.timezoneForNegative1h;
            case 0:
                return this.timezoneFor0h;
            case 1:
                return this.timezoneForPositive1h;
            case 2:
                return this.timezoneForPositive2h;
            case 3:
                return this.timezoneForPositive3h;
            case 4:
                return this.timezoneForPositive4h;
            case 5:
                return this.timezoneForPositive5h;
            case 6:
                return this.timezoneForPositive6h;
            case 7:
                return this.timezoneForPositive7h;
            case 8:
                return this.timezoneForPositive8h;
            case 9:
                return this.timezoneForPositive9h;
            case 10:
                return this.timezoneForPositive10h;
            case 11:
                return this.timezoneForPositive11h;
            case 12:
                return this.timezoneForPositive12h;
            default:
                return [];
        }
    }

    static regExpName(name: String): boolean {
        if (name === undefined || name === null) return false;
        const result = name.replace(/\s+/g, ' ');
        const regex = new RegExp('^[a-zA-Z0-9_-_ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễếệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹý\\s]+$');
        return regex.test(result);
    }

    static async getCmRoomType(hotelID: string, roomTypeID: any): Promise<{ [key: string]: string }> {
        try {
            const hotelRef = firestore.collection('hotels').doc(hotelID);
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

    static regExpPhone(phone: String): boolean {
        if (phone === undefined || phone === null) return false;
        const result = phone.replace(/\s+/g, '');
        const regex = new RegExp('^[+_0-9]{0,20}$');
        return regex.test(result);
    }

    static getServiceCharge(booking: FirebaseFirestore.DocumentData | { [key: string]: any }): number {
        const minibar = booking.minibar ?? 0;
        const restaurant = booking.restaurant ?? 0;
        const insideRestaurant = booking.inside_restaurant ?? 0;
        const laundry = booking.laundry ?? 0;
        const extraGuest = booking.extra_guest ?? 0;
        const bikeRental = booking.bike_rental ?? 0;
        const other = booking.other ?? 0;
        const extraHour = booking.group ? booking.extra_hour ?? 0 : booking.extra_hours?.total ?? 0;
        const electricityWater = booking.group ? booking.electricity_water ?? 0 : booking.electricity_water?.total ?? 0;
        const serviceCharge = minibar + restaurant + insideRestaurant + laundry + extraGuest + extraHour + bikeRental + other + electricityWater;
        return serviceCharge;
    }

    static getRoomCharge(booking: FirebaseFirestore.DocumentData): number {
        const bookingPrice: number[] = booking.price ?? [];
        if (bookingPrice.length === 0) {
            return 0;
        }
        return bookingPrice.reduce((previousValue, currentValue) => previousValue + currentValue);
    }

    static getLengthStay(booking: FirebaseFirestore.DocumentData): number {
        return (booking.out_date.toDate().getTime() - booking.in_date.toDate().getTime()) / (24 * 60 * 60 * 1000);
    }

    static getRevenue(booking: FirebaseFirestore.DocumentData): number {
        return NeutronUtil.getRoomCharge(booking) + NeutronUtil.getServiceCharge(booking) - NeutronUtil.getDiscount(booking);
    }

    static getDiscount(booking: FirebaseFirestore.DocumentData): number {
        return booking.discount?.total ?? 0;
    }

    static async getMappingHotelInfo(hotel: string): Promise<any> {
        const doc = await firestore.collection('hotels').doc(hotel).get();
        const cmsType = doc.get('cms') ?? CmsType.hotellink;
        if(cmsType ==  CmsType.hotellink){
            const id = doc.get('mapping_hotel_id');
            const key = doc.get('mapping_hotel_key');
            const timezone = doc.get('timezone');
            if (key === undefined || id === undefined) return { id: null, timezone: timezone }; 
            return { id: id, key: key, timezone: timezone,type: cmsType };
        }else{
            const propertyId = doc.get('property_id');
            const timezone = doc.get('timezone');
            return {propertyId: propertyId??null, timezone: timezone,type: cmsType }
        }
    }

    // new functions
    static async getDailyAllotmentByStayDates(hotelRef: admin.firestore.DocumentReference, stayDates: Date[], transaction: admin.firestore.Transaction): Promise<admin.firestore.DocumentSnapshot[]> {
        let dateDynamic: Date = DateUtil.addDate(stayDates[0], 0);
        const dailyAllotments: admin.firestore.DocumentSnapshot[] = [];
        const inMonthID = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        const outMonthID = DateUtil.dateToShortStringYearMonth(stayDates[stayDates.length - 1]);

        const dailyAllotmentInMonthDoc = await transaction.get(hotelRef.collection('daily_allotment').doc(inMonthID));
        dailyAllotments.push(dailyAllotmentInMonthDoc);

        if (inMonthID !== outMonthID) {
            while (true) {
                dateDynamic = DateUtil.addMonth(dateDynamic, 1);
                const dailyAllotmentDoc = await transaction.get(hotelRef.collection('daily_allotment').doc(DateUtil.dateToShortStringYearMonth(dateDynamic)));
                dailyAllotments.push(dailyAllotmentDoc);
                if (DateUtil.dateToShortStringYearMonth(dateDynamic) === outMonthID) {
                    break;
                }
            }
        }
        return dailyAllotments;
    }

    // new functions
    static getAvailableRoomsWithDailyAllotments(stayDates: Date[], dailyAllotments: admin.firestore.DocumentSnapshot[], roomOfRoomType: string[]): string[] {
        const roomBooked: string[] = this.getBookedRoomsWithDailyAllotments(stayDates, dailyAllotments);
        return roomOfRoomType.filter((room) => roomBooked.indexOf(room) === -1);
    }

    // new functions
    static getBookedRoomsWithDailyAllotments(stayDates: Date[], dailyAllotments: admin.firestore.DocumentSnapshot[]): string[] {
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;
        const result: string[] = [];
        for (const date of stayDates) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
            };
            if (dailyAllotment.get('data')[date.getDate()]['booked'] !== undefined) {
                const roomBooked: string[] = dailyAllotment.get('data')[date.getDate()]['booked'];
                if (roomBooked.length !== 0) {
                    for (const room of roomBooked) {
                        if (result.indexOf(room) === -1) {
                            result.push(room);
                        }
                    }
                };
            }

        }
        return result;
    }

    // new func 
    static getQuantityRoomOfRoomTypeWithDailyAllotments(stayDates: Date[], dailyAllotments: admin.firestore.DocumentSnapshot[], roomType: string): number[] {
        const result: number[] = [];
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;
        for (const date of stayDates) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
            };
            result.push(dailyAllotment.get('data')[date.getDate()][roomType]['num'])
        }
        return result;
    }

    // new func 
    static getBookedRoomOfRoomTypeWithDailyAllotments(stayDates: Date[], dailyAllotments: admin.firestore.DocumentSnapshot[], room: string): boolean {
        let result: boolean = false;
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;
        for (const date of stayDates) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
            };
            for (const rooms of dailyAllotment.get('data')[date.getDate()]['booked']) {
                if (room == rooms) {
                    result = true;
                }
            }
        }
        return result;
    }

    static async updateAvaibilityToHLS(hotel: string, mappedRoomTypes: { [key: string]: any }[], stayDates: Date[]): Promise<boolean> {
        const mappingHotelInfo = await NeutronUtil.getMappingHotelInfo(hotel);
        const hotelDoc = await firestore.collection('hotels').doc(hotel).get();
        const auto_rate: boolean = hotelDoc.get('auto_rate') ?? true;
        if (mappingHotelInfo === null) {
            return false;
        }
        const hotelID = mappingHotelInfo.id;
        const hotelKey = mappingHotelInfo.key;
        const timezone = mappingHotelInfo.timezone;
        const nowServer = new Date();
        const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);
        const now12hTimezone = new Date(nowTimezone.getFullYear(), nowTimezone.getMonth(), nowTimezone.getDate(), 12, 0, 0);
        const stayDays = stayDates.filter(date => date.getTime() >= now12hTimezone.getTime());
        if (stayDays.length === 0) {
            return true;
        }
        const inMonthID = DateUtil.dateToShortStringYearMonth(stayDays[0]);
        const outMonthID = DateUtil.dateToShortStringYearMonth(stayDays[stayDays.length - 1]);
        const inDayID = DateUtil.dateToShortStringDay(stayDays[0]);
        const outDayID = DateUtil.dateToShortStringDay(stayDays[stayDays.length - 1]);
        const almMap: { [key: string]: { [key: string]: { [key: string]: number } } } = {};

        const inMonthParse = inMonthID.substring(0, 4) + '-' + inMonthID.substring(4, 6) + '-';
        if (inMonthID === outMonthID) {
            const dailyAllotmentRef = await firestore.collection('hotels').doc(hotel).collection('daily_allotment').doc(inMonthID).get();
            for (const mappedRoomType of mappedRoomTypes) {
                almMap[mappedRoomType.id] = {};
                let dayData = '';
                Object.keys(dailyAllotmentRef.get('data')).map((day) => {
                    if (Number.parseInt(day) >= Number.parseInt(inDayID) && Number.parseInt(day) <= Number.parseInt(outDayID)) {
                        if (Number.parseInt(day) < 10) {
                            dayData = inMonthParse + '0' + day;
                        } else {
                            dayData = inMonthParse + day;
                        }
                        almMap[mappedRoomType.id][dayData] = {};
                        almMap[mappedRoomType.id][dayData]['num'] = dailyAllotmentRef.get('data')[day][mappedRoomType.roomType]['num'];
                        almMap[mappedRoomType.id][dayData]['price'] = dailyAllotmentRef.get('data')[day][mappedRoomType.roomType]['price'] !== undefined ? dailyAllotmentRef.get('data')[day][mappedRoomType.roomType]['price'] : dailyAllotmentRef.get('data')['default'][mappedRoomType.roomType]['price'];
                        almMap[mappedRoomType.id][dayData]['ratePlanID'] = mappedRoomType.ratePlan;
                    }
                })
            }
        } else {
            // change daily allotment here
            let dateDynamic = stayDates[0];
            const dailyAllotments: admin.firestore.DocumentSnapshot[] = [];
            const dailyAllotmentInMonthDoc = await firestore.collection('hotels').doc(hotel).collection('daily_allotment').doc(inMonthID).get();
            dailyAllotments.push(dailyAllotmentInMonthDoc);
            while (true) {
                dateDynamic = DateUtil.addMonth(dateDynamic, 1);
                const dailyAllotmentDoc = await firestore.collection('hotels').doc(hotel).collection('daily_allotment').doc(DateUtil.dateToShortStringYearMonth(dateDynamic)).get();
                dailyAllotments.push(dailyAllotmentDoc);
                if (DateUtil.dateToShortStringYearMonth(dateDynamic) === outMonthID) {
                    break;
                }
            }

            for (const mappedRoomType of mappedRoomTypes) {
                almMap[mappedRoomType.id] = {};
                let dayData = '';
                for (const dailyAllotment of dailyAllotments) {

                    const monthParse = dailyAllotment.id.substring(0, 4) + '-' + dailyAllotment.id.substring(4, 6) + '-';
                    for (const dayId in dailyAllotment.get('data')) {

                        if (dayId === 'default') {
                            continue;
                        }

                        if (dailyAllotment.id === inMonthID && Number.parseInt(dayId) < Number.parseInt(inDayID)) {
                            continue;
                        }

                        if (dailyAllotment.id === outMonthID && Number.parseInt(dayId) > Number.parseInt(outDayID)) {
                            break;
                        }

                        if (Number.parseInt(dayId) < 10) {
                            dayData = monthParse + '0' + dayId;
                        } else {
                            dayData = monthParse + dayId;
                        }

                        almMap[mappedRoomType.id][dayData] = {};
                        almMap[mappedRoomType.id][dayData]['num'] = dailyAllotment.get('data')[dayId][mappedRoomType.roomType]['num'] > 0 ? dailyAllotment.get('data')[dayId][mappedRoomType.roomType]['num'] : 0;
                        almMap[mappedRoomType.id][dayData]['price'] = dailyAllotment.get('data')[dayId][mappedRoomType.roomType]['price'] !== undefined ? dailyAllotment.get('data')[dayId][mappedRoomType.roomType]['price'] : dailyAllotment.get('data')['default'][mappedRoomType.roomType]['price'];
                        almMap[mappedRoomType.id][dayData]['ratePlanID'] = mappedRoomType.ratePlan;
                    }
                }
            }
        }
        return await HLSUtil.updateMultipleAvaibility(hotelID, hotelKey, almMap, auto_rate);
    }

    static async getMappedRoomTypes(hotel: string): Promise<{ [key: string]: string }[]> {
        const hotelRef = firestore.collection('hotels').doc(hotel);
        const snapshots = await hotelRef.collection('cm_room_types').where('mapping_room_type', '!=', '').get();
        const result: { [key: string]: string }[] = [];
        for (const doc of snapshots.docs) {
            if (doc.get('mapping_rate_plan') === '') {
                continue;
            }
            const data: { [key: string]: string } = {};
            data['id'] = doc.id;
            data['roomType'] = doc.get('mapping_room_type');
            data['ratePlan'] = doc.get('mapping_rate_plan');
            result.push(data);
        }
        return result;
    }

    static updateRevenueCollectionDailyData(transaction: FirebaseFirestore.Transaction, booking: FirebaseFirestore.DocumentData, hotelRef: FirebaseFirestore.DocumentReference, isAdded: boolean, timeUpdate: Date) {
        const monthId = DateUtil.dateToShortStringYearMonth(timeUpdate);
        const dayId = DateUtil.dateToShortStringDay(timeUpdate);
        const dataUpdateDaily: { [key: string]: any } = {};
        const sign = isAdded ? 1 : -1;
        dataUpdateDaily['data.' + dayId + '.revenue.total'] = FieldValue.increment(sign * NeutronUtil.getRevenue(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.service_charge'] = FieldValue.increment(sign * NeutronUtil.getServiceCharge(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.room_charge'] = FieldValue.increment(sign * NeutronUtil.getRoomCharge(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.discount'] = FieldValue.increment(sign * NeutronUtil.getDiscount(booking));
        transaction.update(hotelRef.collection('daily_data').doc(monthId), dataUpdateDaily);
    }

    static updateRevenueCollectionDailyDataWithBatch(batch: FirebaseFirestore.WriteBatch, booking: FirebaseFirestore.DocumentData, hotelRef: FirebaseFirestore.DocumentReference, isAdded: boolean, timeUpdate: Date) {
        const monthId = DateUtil.dateToShortStringYearMonth(timeUpdate);
        const dayId = DateUtil.dateToShortStringDay(timeUpdate);
        const dataUpdateDaily: { [key: string]: any } = {};
        const sign = isAdded ? 1 : -1;
        dataUpdateDaily['data.' + dayId + '.revenue.total'] = FieldValue.increment(sign * NeutronUtil.getRevenue(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.service_charge'] = FieldValue.increment(sign * NeutronUtil.getServiceCharge(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.room_charge'] = FieldValue.increment(sign * NeutronUtil.getRoomCharge(booking));
        dataUpdateDaily['data.' + dayId + '.revenue.discount'] = FieldValue.increment(sign * NeutronUtil.getDiscount(booking));
        batch.update(hotelRef.collection('daily_data').doc(monthId), dataUpdateDaily);
    }

    static updateBreakfastGuestCollectionDailyData(transaction: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, stayDates: Date[], basicBooking: FirebaseFirestore.DocumentData, isAdded: boolean, now12hTimezone: Date, typeTourists: string, country: string) {
        const sign = isAdded ? 1 : -1;
        let dataUpdate: { [key: string]: any } = {};
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        for (const date of stayDates) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                transaction.update(hotelRef.collection('daily_data').doc(monthDynamicID), dataUpdate);
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dataUpdate = {};
            }
            const dateString = DateUtil.dateToShortString(date);

            const dayId = DateUtil.dateToShortStringDay(date);
            const conditionGuest = date.getTime() > now12hTimezone.getTime();
            const conditionBreakfast =
                date.getTime() >= now12hTimezone.getTime() && basicBooking.breakfast;
            const conditionLunch =
                date.getTime() >= now12hTimezone.getTime() && (basicBooking.lunch ?? false);
            const conditionDinner =
                date.getTime() >= now12hTimezone.getTime() && (basicBooking.dinner ?? false);

            const extraAdult = basicBooking.extra_adult?.['' + dateString] ?? 0;
            const extraChild = basicBooking.extra_child?.['' + dateString] ?? 0;
            const totalGuest: number = conditionGuest ? (basicBooking?.adult + extraAdult + basicBooking?.child + extraChild) : 0;
            dataUpdate['data.' + dayId + '.breakfast.adult'] = FieldValue.increment(sign * (conditionBreakfast ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.breakfast.child'] = FieldValue.increment(sign * (conditionBreakfast ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.lunch.adult'] = FieldValue.increment(sign * (conditionLunch ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.lunch.child'] = FieldValue.increment(sign * (conditionLunch ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.dinner.adult'] = FieldValue.increment(sign * (conditionDinner ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.dinner.child'] = FieldValue.increment(sign * (conditionDinner ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.guest.adult'] = FieldValue.increment(sign * (conditionGuest ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.guest.child'] = FieldValue.increment(sign * (conditionGuest ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(sign * totalGuest);
            dataUpdate['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(sign * totalGuest);
        }
        transaction.update(hotelRef.collection('daily_data').doc(monthDynamicID), dataUpdate);
    }

    static updateBreakfastGuestCollectionDailyDataWithBatch(batch: FirebaseFirestore.WriteBatch, hotelRef: FirebaseFirestore.DocumentReference, stayDates: Date[], basicBooking: FirebaseFirestore.DocumentData, isAdded: boolean, now12hTimezone: Date, typeTourists: string, country: string) {
        const sign = isAdded ? 1 : -1;
        let dataUpdate: { [key: string]: any } = {};
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDates[0]);
        for (const date of stayDates) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                batch.update(hotelRef.collection('daily_data').doc(monthDynamicID), dataUpdate);
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dataUpdate = {};
            }
            const dateString = DateUtil.dateToShortString(date);
            const dayId = DateUtil.dateToShortStringDay(date);
            const conditionGuest = date.getTime() > now12hTimezone.getTime();
            const conditionBreakfast =
                date.getTime() >= now12hTimezone.getTime() && basicBooking.breakfast;
            const conditionLunch =
                date.getTime() >= now12hTimezone.getTime() && (basicBooking.lunch ?? false);
            const conditionDinner =
                date.getTime() >= now12hTimezone.getTime() && (basicBooking.dinner ?? false);
            const extraAdult = basicBooking.extra_adult?.['' + dateString] ?? 0;
            const extraChild = basicBooking.extra_child?.['' + dateString] ?? 0;
            const totalGuest: number = conditionGuest ? (basicBooking?.adult + extraAdult + basicBooking?.child + extraChild) : 0;
            dataUpdate['data.' + dayId + '.breakfast.adult'] = FieldValue.increment(sign * (conditionBreakfast ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.breakfast.child'] = FieldValue.increment(sign * (conditionBreakfast ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.lunch.adult'] = FieldValue.increment(sign * (conditionLunch ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.lunch.child'] = FieldValue.increment(sign * (conditionLunch ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.dinner.adult'] = FieldValue.increment(sign * (conditionDinner ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.dinner.child'] = FieldValue.increment(sign * (conditionDinner ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.guest.adult'] = FieldValue.increment(sign * (conditionGuest ? basicBooking?.adult + extraAdult : 0));
            dataUpdate['data.' + dayId + '.guest.child'] = FieldValue.increment(sign * (conditionGuest ? basicBooking?.child + extraChild : 0));
            dataUpdate['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(sign * totalGuest);
            dataUpdate['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(sign * totalGuest);
        }
        batch.update(hotelRef.collection('daily_data').doc(monthDynamicID), dataUpdate);
    }

    static async updateExtraGuestCollectionDailyDataWithBatch(t: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, service: FirebaseFirestore.DocumentData, isAdded: boolean, timezone: string, isUpdateTotalService: boolean) {
        const sign = isAdded ? 1 : -1;
        const end = DateUtil.convertUpSetTimezone(service.end.toDate(), timezone);
        const start = DateUtil.convertUpSetTimezone(service.start.toDate(), timezone);
        const lengthStay = DateUtil.getStayDates(start, end);
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(lengthStay[0]);

        const basicBookingDoc = await hotelRef.collection('basic_bookings').doc(service.bid).get();
        const breakfast: boolean = basicBookingDoc.get('breakfast');
        const lunch: boolean = basicBookingDoc.get('lunch') ?? false;
        const dinner: boolean = basicBookingDoc.get('dinner') ?? false;
        const typeTourists: string = basicBookingDoc.data()?.type_tourists ?? '';
        const country: string = basicBookingDoc.data()?.country ?? '';
        let dailyGuestBreakfastData: { [key: string]: any } = {};
        const basicBookingData: { [key: string]: any } = {};

        if (isUpdateTotalService) {
            const dayBooked = DateUtil.dateToShortStringDay(start);
            dailyGuestBreakfastData['data.' + dayBooked + '.service.extra_guest.total'] = FieldValue.increment(sign * service.total);
        }

        for (const date of lengthStay) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                t.update(hotelRef.collection('daily_data').doc(monthDynamicID), dailyGuestBreakfastData);
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyGuestBreakfastData = {};
            }

            const dateString = DateUtil.dateToShortString(date);
            const dayId = DateUtil.dateToShortStringDay(date);
            dailyGuestBreakfastData['data.' + dayId + '.guest.' + service.type] = FieldValue.increment(sign * service.number);
            dailyGuestBreakfastData['data.' + dayId + '.breakfast.' + service.type] = FieldValue.increment(sign * (breakfast ? service.number : 0));
            dailyGuestBreakfastData['data.' + dayId + '.lunch.' + service.type] = FieldValue.increment(sign * (lunch ? service.number : 0));
            dailyGuestBreakfastData['data.' + dayId + '.dinner.' + service.type] = FieldValue.increment(sign * (dinner ? service.number : 0));
            dailyGuestBreakfastData['data.' + dayId + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment(sign * service.number);
            dailyGuestBreakfastData['data.' + dayId + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment(sign * service.number);

            basicBookingData['extra_' + service.type + '.' + dateString] =
                FieldValue.increment(sign * service.number);
        }
        t.update(hotelRef.collection('daily_data').doc(monthDynamicID), dailyGuestBreakfastData);
        t.update(basicBookingDoc.ref, basicBookingData);

    }

    static async updateCollectionDailyData(booking: FirebaseFirestore.DocumentData, isAdded: boolean, hotelRef: FirebaseFirestore.DocumentReference) {
        const inDate = DateUtil.convertUpSetTimezone(booking.in_date.toDate(), booking.time_zone);
        const outDate = DateUtil.convertUpSetTimezone(booking.out_date.toDate(), booking.time_zone);
        const created = DateUtil.convertUpSetTimezone(booking.created.toDate(), booking.time_zone);
        const stayDays: Date[] = DateUtil.getStayDates(inDate, outDate);
        const inMonthId = DateUtil.dateToShortStringYearMonth(stayDays[0]);
        const outMonthId = DateUtil.dateToShortStringYearMonth(stayDays[stayDays.length - 1]);
        const price: number[] = booking.price;
        const adult = booking.adult;
        const child = booking.child;
        const breakfast = booking.breakfast;
        const lunch: boolean = booking.lunch ?? false;
        const dinner: boolean = booking.dinner ?? false;
        const payAtHotel = booking.pay_at_hotel;
        const roomType = booking.room_type;
        const source = booking.source;
        const typeTourists: string = booking.type_tourists ?? '';
        const country: string = booking.country ?? '';
        let priceToMonth: number = 0;
        let isMonthly: boolean = false;
        if (booking.booking_type == BookingType.monthly && booking?.booking_type != undefined) {
            isMonthly = true
            priceToMonth = (price[0] / stayDays.length);
        }
        console.log(priceToMonth);
        const sign = isAdded ? 1 : -1;
        if (inMonthId === outMonthId) {
            const data: { [key: string]: any } = {};
            const dataDailyBooked: { [key: string]: any } = {};
            for (const [index, date] of stayDays.entries()) {
                const inDay = DateUtil.dateToShortStringDay(date);
                const dateString = DateUtil.dateToShortString(date);
                const extraAdult = booking.extra_adult?.['' + dateString] ?? 0;
                const extraChild = booking.extra_child?.['' + dateString] ?? 0;
                data['data.' + inDay + '.type_tourists.' + (typeTourists !== '' ? typeTourists : 'unknown')] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.country.' + (country !== '' ? country : 'unknown')] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.guest.adult'] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.guest.child'] = FieldValue.increment((child + extraChild) * sign);
                data['data.' + inDay + '.breakfast.adult'] = FieldValue.increment(breakfast ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.breakfast.child'] = FieldValue.increment(breakfast ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.lunch.adult'] = FieldValue.increment(lunch ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.lunch.child'] = FieldValue.increment(lunch ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.dinner.adult'] = FieldValue.increment(dinner ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.dinner.child'] = FieldValue.increment(dinner ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.current_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.room_charge'] = FieldValue.increment((isMonthly ? priceToMonth : price[index]) * sign);
                data['data.' + inDay + '.current_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.num'] = FieldValue.increment(sign);
                dataDailyBooked['data.' + date.getDate() + '.' + roomType + '.' + 'occ'] = FieldValue.increment(sign);
            }
            await hotelRef.collection('daily_allotment').doc(inMonthId).update(dataDailyBooked);
            if ((await hotelRef.collection('daily_data').doc(inMonthId).get()).exists) {
                await hotelRef.collection('daily_data').doc(inMonthId).update(data);
            } else {
                await hotelRef.collection('daily_data').doc(inMonthId).create({});
                await hotelRef.collection('daily_data').doc(inMonthId).update(data);
            }
        } else {
            // outMonthId !=== inMonthId
            let idMonth: string = inMonthId;
            let data: { [key: string]: any } = {};
            let dataDailyBooked: { [key: string]: any } = {};
            let inDay: string;
            for (const [index, date] of stayDays.entries()) {
                inDay = DateUtil.dateToShortStringDay(date);
                const dateString = DateUtil.dateToShortString(date);
                if (DateUtil.dateToShortStringYearMonth(date) !== idMonth) {
                    await hotelRef.collection('daily_allotment').doc(idMonth).update(dataDailyBooked);
                    if ((await hotelRef.collection('daily_data').doc(idMonth).get()).exists) {
                        await hotelRef.collection('daily_data').doc(idMonth).update(data);
                    } else {
                        await hotelRef.collection('daily_data').doc(idMonth).create({});
                        await hotelRef.collection('daily_data').doc(idMonth).update(data);
                    }
                    idMonth = DateUtil.dateToShortStringYearMonth(date);
                    data = {};
                    dataDailyBooked = {};
                }
                const extraAdult = booking.extra_adult?.['' + dateString] ?? 0;
                const extraChild = booking.extra_child?.['' + dateString] ?? 0;
                data['data.' + inDay + '.guest.adult'] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.guest.child'] = FieldValue.increment((child + extraChild) * sign);
                data['data.' + inDay + '.type_tourists.' + (typeTourists === '' ? 'unknown' : typeTourists)] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.country.' + (country === '' ? 'unknown' : country)] = FieldValue.increment((adult + extraAdult) * sign);
                data['data.' + inDay + '.breakfast.adult'] = FieldValue.increment(breakfast ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.breakfast.child'] = FieldValue.increment(breakfast ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.lunch.adult'] = FieldValue.increment(lunch ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.lunch.child'] = FieldValue.increment(lunch ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.dinner.adult'] = FieldValue.increment(dinner ? (adult + extraAdult) * sign : 0);
                data['data.' + inDay + '.dinner.child'] = FieldValue.increment(dinner ? (child + extraChild) * sign : 0);
                data['data.' + inDay + '.current_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.room_charge'] = FieldValue.increment((isMonthly ? priceToMonth : price[index]) * sign);
                data['data.' + inDay + '.current_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.num'] = FieldValue.increment(sign);
                dataDailyBooked['data.' + date.getDate() + '.' + roomType + '.occ'] = FieldValue.increment(sign);
            }
            await hotelRef.collection('daily_allotment').doc(idMonth).update(dataDailyBooked);
            if ((await hotelRef.collection('daily_data').doc(idMonth).get()).exists) {
                await hotelRef.collection('daily_data').doc(idMonth).update(data);
            } else {
                await hotelRef.collection('daily_data').doc(idMonth).create({});
                await hotelRef.collection('daily_data').doc(idMonth).update(data);
            }
        }
        console.log(655);
        const newBookingData: { [key: string]: any } = {};
        newBookingData['data.' + DateUtil.dateToShortStringDay(created) + '.new_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.num'] = FieldValue.increment(NeutronUtil.getLengthStay(booking) * sign);
        newBookingData['data.' + DateUtil.dateToShortStringDay(created) + '.new_booking.' + (payAtHotel ? 'pay_at_hotel' : 'prepaid') + '.' + roomType + '.' + source + '.room_charge'] = FieldValue.increment(NeutronUtil.getRoomCharge(booking) * sign);
        if ((await hotelRef.collection('daily_data').doc(DateUtil.dateToShortStringYearMonth(created)).get()).exists) {
            await hotelRef.collection('daily_data').doc(DateUtil.dateToShortStringYearMonth(created)).update(newBookingData);
        } else {
            await hotelRef.collection('daily_data').doc(DateUtil.dateToShortStringYearMonth(created)).create({});
            await hotelRef.collection('daily_data').doc(DateUtil.dateToShortStringYearMonth(created)).update(newBookingData);
        }

    }

    static async updateHlsWithDateAndRoomType(hotelRef: FirebaseFirestore.DocumentReference, almDate: { [key: string]: { [key: string]: number } }, hotelMappingId: string, hotelMappingKey: string, now12hTimezone: Date) {
        const almMap: { [key: string]: any } = {};
        for (const roomTypeID in almDate) {
            const mappedRoomType: { [key: string]: string } = await NeutronUtil.getCmRoomType(hotelRef.id, roomTypeID);
            almMap[mappedRoomType['id']] = {};
            for (const date in almDate[roomTypeID]) {
                const hlsDate: Date = DateUtil.getDateFromHLSDateStringNew(date);
                if (hlsDate.getTime() >= now12hTimezone.getTime()) {
                    almMap[mappedRoomType['id']][date] = {};
                    almMap[mappedRoomType['id']][date]['num'] = almDate[roomTypeID][date] >= 0 ? almDate[roomTypeID][date] : 0;
                    almMap[mappedRoomType['id']][date]['ratePlanID'] = '';
                    console.log(`update allotment hls with day ${date} num : ${almDate[roomTypeID][date]}`);
                }
            }
        }
        const result = await HLSUtil.updateMultipleAvaibility(hotelMappingId, hotelMappingKey, almMap, true);
        if (result === null) {
            console.log(MessageUtil.CM_UPDATE_AVAIBILITY_FAIL);
        }
    }

    static updateDailyAllotmentAndHlsWithDailyAllotmentChangeAll(transaction: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, stayDays: Date[], isAdded: boolean, almRoomBooked: { pmsID: string, cmId: string } | null, roomID: string, almRoomCancelled: Map<string, { cmId: string }> | null, hotelMappingId: string | undefined, hotelMappingKey: string | undefined, dailyAllotments: admin.firestore.DocumentSnapshot[], now12hTimezone: Date): void {
        const almMap: { [key: string]: any } = {};
        const sign = isAdded ? 1 : -1;
        let dataUpdate: { [key: string]: any } = {};
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDays[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;

        for (const date of stayDays) {
            const dateHls = DateUtil.dateToShortStringHls(date);
            if (almRoomBooked !== null) {
                if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                    transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
                    monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                    dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
                    dataUpdate = {};
                }
                if (roomID !== '') dataUpdate['data.' + date.getDate() + '.booked'] = isAdded ? FieldValue.arrayUnion(roomID) : FieldValue.arrayRemove(roomID);
                dataUpdate['data.' + date.getDate() + '.' + almRoomBooked.pmsID + '.num'] = FieldValue.increment(-sign);
                if (date.getTime() >= now12hTimezone.getTime()) {
                    if (almMap[almRoomBooked.cmId] === undefined) {
                        almMap[almRoomBooked.cmId] = {};
                    }
                    almMap[almRoomBooked.cmId][dateHls] = {};
                    almMap[almRoomBooked.cmId][dateHls]['num'] = dailyAllotment.get('data')[date.getDate()][almRoomBooked.pmsID]['num'] - sign;
                    almMap[almRoomBooked.cmId][dateHls]['ratePlanID'] = '';
                    console.log(`update allotment with ${almRoomBooked.pmsID} day ${dateHls} : before ${dailyAllotment.get('data')[date.getDate()][almRoomBooked.pmsID]['num']} - after : ${almMap[almRoomBooked.cmId][dateHls]['num']}`);
                }

            } else {
                if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                    monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                    dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
                }
            }
            if (almRoomCancelled !== null) {
                for (const element of almRoomCancelled.entries()) {
                    if (date.getTime() > now12hTimezone.getTime()) {
                        if (almMap[element[1].cmId] === undefined) {
                            almMap[element[1].cmId] = {};
                        }
                        almMap[element[1].cmId][dateHls] = {};
                        almMap[element[1].cmId][dateHls]['num'] = dailyAllotment.get('data')[date.getDate()][element[0]]['num'];
                        almMap[element[1].cmId][dateHls]['ratePlanID'] = '';
                        console.log(`update allotment cancelled with ${element[0]} day ${dateHls} : before ${dailyAllotment.get('data')[date.getDate()][element[0]]['num']} - after : ${almMap[element[1].cmId][dateHls]['num']}`);
                    }

                }
            }
        }

        if (almRoomBooked !== null) {
            transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
        }

        if (hotelMappingId !== undefined && hotelMappingKey !== undefined && Object.keys(almMap).length !== 0) {
            HLSUtil.updateMultipleAvaibility(hotelMappingId, hotelMappingKey, almMap, true).then((value) => {
                console.log("After success hls: " + value);
            }).catch((err) => {
                console.log("After failed hls: " + err);
            });
        }
    }
    //todo
    static updateDailyAllotmentAndHlsBookingGroupWithDailyAllotmentChangeAll(transaction: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, stayDays: Date[], isAdded: boolean, dailyAllotments: admin.firestore.DocumentSnapshot[], almRoomBooked: Map<string, { cmID: string, num: number }>, almRoomCancelled: Map<string, { cmID: string }> | null, roomBooked: string[], hotelMappingId: string | undefined, hotelMappingKey: string | undefined): void {
        const sign = isAdded ? 1 : -1;
        let dataUpdate: { [key: string]: any } = {};
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDays[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;
        const almMap: { [key: string]: any } = {};
        for (const date of stayDays) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                if (Object.keys(dataUpdate).length !== 0) {
                    transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
                }
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
                dataUpdate = {};
            }
            if (roomBooked.length !== 0) dataUpdate['data.' + date.getDate() + '.booked'] = isAdded ? FieldValue.arrayUnion(...roomBooked) : FieldValue.arrayRemove(...roomBooked);
            const dateHls = DateUtil.dateToShortStringHls(date);

            for (const element of almRoomBooked.entries()) {
                dataUpdate['data.' + date.getDate() + '.' + element[0] + '.num'] = FieldValue.increment(-sign * element[1].num);
                if (almMap[element[1].cmID] === undefined) {
                    almMap[element[1].cmID] = {};
                }
                almMap[element[1].cmID][dateHls] = {};
                almMap[element[1].cmID][dateHls]['num'] = dailyAllotment.get('data')[date.getDate()][element[0]]['num'] - (sign * element[1].num);
                almMap[element[1].cmID][dateHls]['ratePlanID'] = '';
                console.log(`update allotment with day ${dateHls} and room type ${element[0]} : before ${dailyAllotment.get('data')[date.getDate()][element[0]]['num']} - after : ${almMap[element[1].cmID][dateHls]['num']}`);
            }
            // alm 
            if (almRoomCancelled !== null) {
                for (const elementHls of almRoomCancelled.entries()) {
                    if (almMap[elementHls[1].cmID] === undefined) {
                        almMap[elementHls[1].cmID] = {};
                    }
                    almMap[elementHls[1].cmID][dateHls] = {};
                    almMap[elementHls[1].cmID][dateHls]['num'] = dailyAllotment.get('data')[date.getDate()][elementHls[0]]['num'];
                    almMap[elementHls[1].cmID][dateHls]['ratePlanID'] = '';
                }
            }
        }

        if (Object.keys(dataUpdate).length !== 0) {
            transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
        }


        if (hotelMappingId !== undefined && hotelMappingKey !== undefined) {
            HLSUtil.updateMultipleAvaibility(hotelMappingId, hotelMappingKey, almMap, true).then((value) => {
                console.log("After success hls: " + value);
            }).catch((err) => {
                console.log("After failed hls: " + err);
            });
        }
    }
    //todo
    // function new
    static updateDailyAllotmentSingleBookingWithDailyAllotmentsChangeAll(transaction: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, stayDays: Date[], pmsRoomType: string, roomID: string, isAdded: boolean, justForRoomBooked: boolean) {
        const sign = isAdded ? 1 : -1;
        let dataUpdate: { [key: string]: any } = {};
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDays[0]);

        for (const date of stayDays) {
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                if (Object.keys(dataUpdate).length !== 0) {
                    transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
                }
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dataUpdate = {};
            }
            if (roomID !== '') {
                dataUpdate['data.' + date.getDate() + '.booked'] = isAdded ? FieldValue.arrayUnion(roomID) : FieldValue.arrayRemove(roomID);
            }
            if (!justForRoomBooked) {
                dataUpdate['data.' + date.getDate() + '.' + pmsRoomType + '.num'] = FieldValue.increment(-sign);
                console.log(`update daily allotment at ${DateUtil.dateToShortStringHls(date)} increase num: ${-sign}`);
            }
        }
        if (Object.keys(dataUpdate).length !== 0) {
            transaction.update(hotelRef.collection('daily_allotment').doc(monthDynamicID), dataUpdate);
        }
    }

    // function new
    //todo
    static updateHlsToAlm(stayDays: Date[], pmsRoomType: string, isAdded: boolean, dailyAllotments: admin.firestore.DocumentSnapshot[], alm: { [key: string]: any }) {
        const sign = isAdded ? 1 : -1;
        let monthDynamicID: string = DateUtil.dateToShortStringYearMonth(stayDays[0]);
        let dailyAllotment: admin.firestore.DocumentSnapshot = dailyAllotments.find((e) => e.id === monthDynamicID)!;
        if (alm[pmsRoomType] === undefined) {
            alm[pmsRoomType] = {};
        }
        for (const date of stayDays) {
            const dateHls = DateUtil.dateToShortStringHls(date);
            if (monthDynamicID !== DateUtil.dateToShortStringYearMonth(date)) {
                monthDynamicID = DateUtil.dateToShortStringYearMonth(date);
                dailyAllotment = dailyAllotments.find((e) => e.id === monthDynamicID)!;
            }
            if (alm[pmsRoomType][dateHls] === undefined) {
                alm[pmsRoomType][dateHls] = dailyAllotment.get('data')[date.getDate()][pmsRoomType]['num'] - sign;
            } else {
                alm[pmsRoomType][dateHls] += (- sign);
            }

        }
    }

    static isMapFieldEmpty(map: Map<string, any>): boolean {
        let result: boolean = true; //true if all fields are empty
        const values = map.values();
        while (true) {
            const temp = values.next().value;
            if (temp === undefined) {
                break;
            }
            if (temp !== '' && temp !== 0) {
                result = false;
                break;
            }
        }
        return result;
    }

    static async getIdActivityDocument(hotelId: string): Promise<{ [key: string]: any }> {
        let idDocument: number;
        let isNewDocument: boolean = false;

        const lastDocumentActivity = (await firestore.collection('hotels').doc(hotelId).collection('activities').orderBy('id', 'asc').limitToLast(1).get()).docs[0];
        if (lastDocumentActivity === null || lastDocumentActivity === undefined) {
            isNewDocument = true;
            idDocument = 0;
        } else {
            idDocument = lastDocumentActivity.data().id;
            if (lastDocumentActivity.data()['activities'].length >= NeutronUtil.maxActivitiesPerArray) {
                isNewDocument = true;
                idDocument++;
            }
        }
        return {
            'idDocument': idDocument,
            'isNewDocument': isNewDocument
        };
    }

    static getServiceChargeAndRoomCharge(booking: FirebaseFirestore.DocumentData | { [key: string]: any }, isUpdateBooking: boolean): number {
        let priceRoom: number = 0;
        const minibar = booking.get("minibar") ?? 0;
        const transferred = booking.get("transferred") ?? 0;
        const restaurant = booking.get("restaurant") ?? 0;
        const inside_restaurant = booking.get("inside_restaurant") ?? 0;
        const laundry = booking.get("laundry") ?? 0;
        const extra_guest = booking.get("extra_guest") ?? 0;
        const bike_rental = booking.get("bike_rental") ?? 0;
        const other = booking.get("other") ?? 0;
        const extraHour = booking.get('group') ? booking.get('extra_hour') ?? 0 : booking.get('extra_hours') == undefined ? 0 : booking.get('extra_hours')["total"] ?? 0;
        const electricity_water = booking.get('group') ? booking.get('electricity_water') ?? 0 : booking.get('electricity_water') == undefined ? 0 : booking.get('electricity_water')["total"] ?? 0;
        const discount = booking.get('discount') == undefined ? 0 : booking.get('discount')['total'] ?? 0;
        const price: number[] = isUpdateBooking ? [] : booking.get("price") ?? [];

        for (const priceR of price) {
            priceRoom += priceR;
        }
        console.log(bike_rental, "---", inside_restaurant, "---", extraHour, "---", extra_guest, "---", laundry, "---", minibar, "---", other, "---", restaurant, "---", priceRoom, "---", discount, "----", transferred, "----", electricity_water);
        const serviceCharge = (minibar + restaurant + inside_restaurant + laundry + extra_guest + extraHour + bike_rental + other + priceRoom + transferred + electricity_water) - discount;
        return serviceCharge;
    }


    static async updateStatusPaymentOfBasicBooking(t: FirebaseFirestore.Transaction, hotelRef: FirebaseFirestore.DocumentReference, isGroup: boolean, totalAllDeposits: number, totalServiceChargeAndRoomCharge: number, sub_bookings: { [key: string]: any }, idBooking: string, isCheckBooking: boolean,) {
        if (isGroup) {
            if (totalAllDeposits == 0 && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                for (const key in sub_bookings) {
                    t.update(hotelRef.collection('basic_bookings').doc(key), { "status_payment": PaymentStatus.unpaid });
                }
            }
            if (totalAllDeposits == totalServiceChargeAndRoomCharge) {
                for (const key in sub_bookings) {
                    t.update(hotelRef.collection('basic_bookings').doc(key), { "status_payment": PaymentStatus.done });
                }
            }
            if (0 < totalAllDeposits && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                for (const key in sub_bookings) {
                    t.update(hotelRef.collection('basic_bookings').doc(key), { "status_payment": PaymentStatus.partial });
                }
            }
            if (totalServiceChargeAndRoomCharge < totalAllDeposits) {
                for (const key in sub_bookings) {
                    t.update(hotelRef.collection('basic_bookings').doc(key), { "status_payment": PaymentStatus.done });
                }
            }
        } else {
            if (isCheckBooking) {
                if (totalAllDeposits == 0 && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                    t.update(hotelRef.collection('basic_bookings').doc(idBooking), { "status_payment": PaymentStatus.unpaid });
                }
                if (totalAllDeposits == totalServiceChargeAndRoomCharge) {
                    t.update(hotelRef.collection('basic_bookings').doc(idBooking), { "status_payment": PaymentStatus.done });
                }
                if (0 < totalAllDeposits && totalAllDeposits < totalServiceChargeAndRoomCharge) {
                    t.update(hotelRef.collection('basic_bookings').doc(idBooking), { "status_payment": PaymentStatus.partial });
                }
                if (totalServiceChargeAndRoomCharge < totalAllDeposits) {
                    t.update(hotelRef.collection('basic_bookings').doc(idBooking), { "status_payment": PaymentStatus.done });

                }
            }
        }
    }

    static async validateRoleInWareHouse(restaurantDoc: FirebaseFirestore.DocumentSnapshot, uid: string, wareHouseImportIds: string[], wareHouseExportIds: string[], type: string): Promise<{ result: boolean, message: string }> {
        const managementWarehouseDoc = await restaurantDoc.ref.collection('management').doc('warehouses').get();

        const wareHouses: Map<string, WareHouse> = new Map();

        for (const idWarehouse in managementWarehouseDoc.get('data')) {
            wareHouses.set(idWarehouse, managementWarehouseDoc.get('data')[idWarehouse]);
        };

        switch (type) {
            case WarehouseNoteType.import:
                for (const warehouseId of wareHouseImportIds) {
                    if (wareHouses.get(warehouseId)?.permission !== undefined) {
                        if (wareHouses.get(warehouseId)?.permission?.import.indexOf(uid) === -1) {
                            return { result: false, message: MessageUtil.NO_PERMISSION_FOR_IMPORT_WAREHOUSE };
                        }
                    } else {
                        return { result: false, message: MessageUtil.NO_PERMISSION_FOR_IMPORT_WAREHOUSE };
                    }
                }
                break;
            case WarehouseNoteType.lost:
            case WarehouseNoteType.liquidation:
            case WarehouseNoteType.returnToSupplier:
            case WarehouseNoteType.export:
                for (const warehouseId of wareHouseExportIds) {

                    if (wareHouses.get(warehouseId)?.permission !== undefined) {

                        if (wareHouses.get(warehouseId)?.permission?.export.indexOf(uid) === -1) {
                            return { result: false, message: MessageUtil.NO_PERMISSION_FOR_EXPORT_LOST_LIQUIDATION_WAREHOUSE };
                        }
                    } else {
                        return { result: false, message: MessageUtil.NO_PERMISSION_FOR_EXPORT_LOST_LIQUIDATION_WAREHOUSE };
                    }
                }
                break;
            case WarehouseNoteType.transfer:
            case WarehouseNoteType.inventoryCheck:

                for (const warehouseId of wareHouseImportIds) {
                    if (wareHouses.get(warehouseId)?.permission !== undefined) {
                        if (wareHouses.get(warehouseId)?.permission?.import.indexOf(uid) === -1) {
                            return { result: false, message: MessageUtil.NO_PERMISSION_FOR_IMPORT_WAREHOUSE };
                        }
                    } else {
                        return { result: false, message: MessageUtil.NO_PERMISSION_FOR_IMPORT_WAREHOUSE };
                    }
                }

                for (const warehouseId of wareHouseExportIds) {
                    if (wareHouses.get(warehouseId)?.permission !== undefined) {
                        if (wareHouses.get(warehouseId)?.permission?.export.indexOf(uid) === -1) {
                            return { result: false, message: MessageUtil.NO_PERMISSION_FOR_EXPORT_LOST_LIQUIDATION_WAREHOUSE };
                        }
                    } else {
                        return { result: false, message: MessageUtil.NO_PERMISSION_FOR_EXPORT_LOST_LIQUIDATION_WAREHOUSE };
                    }
                }

            default:
                break;
        }

        return { result: true, message: MessageUtil.SUCCESS };
    }


    static checkWarehouseModifyPermission(roleOfUser: string[], email: any, financialClosingDate: any, warehouseNoteDoc: FirebaseFirestore.DocumentData): string {

        const actual_created = warehouseNoteDoc['actual_created'];
        const created = warehouseNoteDoc['created'];

        if (financialClosingDate != undefined && created != undefined && financialClosingDate.toDate().getTime() - created.toDate().getTime() > 0) {
            return MessageUtil.NOT_ALLOWED_TO_BE_MODIFIED_PRIOR_TO_THE_FINANCIAL_CLOSING_DATE;
        }
        if (roleOfUser.some((role) => NeutronUtil.rolesCRUDWarehouseNote.includes(role))) {
            if (actual_created == undefined) {
                if ((new Date().getTime() - warehouseNoteDoc['created_time'].toDate().getTime()) > 45 * 24 * 60 * 60 * 1000) {
                    return MessageUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS;
                }
            } else {
                if ((new Date().getTime() - actual_created.toDate().getTime()) > 45 * 24 * 60 * 60 * 1000) {
                    return MessageUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS;
                }
            }
        } else {
            if (warehouseNoteDoc['creator'] != email) {
                return MessageUtil.FORBIDDEN;
            }
            if (actual_created == undefined || (new Date().getTime() - actual_created.toDate().getTime()) > 24 * 60 * 60 * 1000) {
                return MessageUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_24H;
            }
        }

        return MessageUtil.SUCCESS;
    }


}