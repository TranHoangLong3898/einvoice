import functions = require('firebase-functions');
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import admin = require('firebase-admin');
import { NumberUtil } from './util/numberutil';
import xml = require('xml');
import { DateUtil } from './util/dateutil';
import { RestUtil } from './util/restutil';

const Firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.updateEInvoiceData = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    const hotelID: string = data.hotel_id;
    const software: { [key: string]: any } = data.software;
    const generateOption: string = data.generate_option;
    const serviceOption: string = data.service_option;

    const uidOfUser: string = context.auth.uid;
    const rolesAllowed = NeutronUtil.rolesCRUDEInvoice;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);


    const res = await Firestore.runTransaction(async (t) => {
        const hotelDoc = await t.get(hotelRef);
        if (hotelDoc === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
        }
        const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
        if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const dataToUpdate = { 'software': software, 'generate_option': generateOption, 'service_option': serviceOption };
        t.update(hotelRef, { 'e_invoice': software == undefined ? {} : dataToUpdate });
        return MessageUtil.SUCCESS;
    })
    return res;
})

exports.generateElectronicInvoice = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }
    
    const bookingId: string = data.booking_id;
    const hotelID: string = data.hotel_id;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
     //roles allow to change database
     const rolesAllowed: string[] = NeutronUtil.rolesCheckOut;
     //roles of user who make this request
     const roleOfUser: string[] = hotelDoc.get('role')[context.auth.uid];
 
     if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
         throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
     }

    const timezone = hotelDoc.get('timezone');
    const nowServer = new Date();
    const nowTimezone = DateUtil.convertUpSetTimezone(nowServer, timezone);

    const eInvoiceData: { [key: string]: any } = hotelDoc.get('e_invoice');
    if (eInvoiceData == undefined || Object.keys(eInvoiceData).length === 0) {
        throw new functions.https.HttpsError("not-found", MessageUtil.NOT_CONNECTED_TO_E_INVOICE_SOFTWARE);
    }
    const authenticationString = NumberUtil.generateAuthenticationStringForEasyInvoice(eInvoiceData['software']['username'], eInvoiceData['software']['password'], 'POST')
    console.log(authenticationString);
    
    const iKey = NumberUtil.generateIKey();
    const jsonData = {
        'Invoices':
            [{
                'Inv':
                    [{
                        'Invoice': [
                            { 'Ikey': iKey },
                            { 'InvNo': 10 },
                            { 'CusCode': data.CusCode },
                            { 'Buyer': data.Buyer },
                            { 'CusName': data.CusName },
                            { 'Email': data.Email },
                            { 'CusAddress': data.CusAddress },
                            { 'CusBankName': data.CusBankName },
                            { 'CusBankNo': data.CusBankNo },
                            { 'CusPhone': data.CusPhone },
                            { 'CusTaxCode': data.CusTaxCode },
                            { 'PaymentMethod': data.PaymentMethod },
                            { 'ArisingDate': DateUtil.dateToDayMonthYearString(new Date()) },
                            { 'ExchangeRate': data.ExchangeRate },
                            { 'CurrencyUnit': data.CurrencyUnit },
                            { 'Products': data.Products },
                            { 'Total': data.Total },
                            { 'VATRate': data.VATRate },
                            { 'VATRateOther': data.VATRateOther },
                            { 'Amount': data.Amount },
                            { 'AmountInWords': data.AmountInWords },
                        ]
                    }]
            }]
    }

    const postData = JSON.stringify({
        'XmlData': xml(jsonData)
    });
    console.log(authenticationString);
    console.log(postData);
    
    
    const options = {
        hostname: '0402123756.softdreams.vn',
        path: '/api/publish/importInvoice',
        method: 'POST',
        headers: {
            "Authentication": authenticationString,
        },
    };

    const respond = await RestUtil.postRequest(options, postData);
    if (typeof respond === 'string') {
        return respond;
    }

    if (respond.Data['Status'] == 2) {
        const res = await Firestore.runTransaction(async (t) => {
             const bookingDoc = await t.get(hotelRef.collection('bookings').doc(data.booking_id));
        if (!bookingDoc.exists) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const booking = bookingDoc.data();
        if (booking === null || booking === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.BOOKING_NOT_FOUND);
        }
        const monthId = DateUtil.dateToShortStringYearMonth(nowTimezone);
        const dayId = DateUtil.dateToShortStringDay(nowTimezone);
        const dataUpdate: { [key: string]: any } = {};

        dataUpdate['data.' + dayId + '.revenue.einvoice'] = FieldValue.increment(data.Amount);
        t.update(hotelRef.collection('daily_data').doc(monthId), dataUpdate);

        const dataBookingToUpdate = {'einvoice': true};
        t.update(hotelRef.collection('bookings').doc(bookingId), dataBookingToUpdate);

        return  MessageUtil.SUCCESS;
        })

        return res;
    } else {
     return  respond.Data['Message'];
    }
})