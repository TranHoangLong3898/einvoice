import functions = require('firebase-functions');
import moment = require('moment');
import { ParsedQs } from 'qs';
import { MessageUtil } from './util/messageutil';
import admin = require('firebase-admin');
import { NumberUtil } from './util/numberutil';
const firestore = admin.firestore();


exports.PayemntVnPay = functions.https.onCall(async (req, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    }

    const expirationDate = new Date(); // Định dạng ISO 8601

    // Số ngày cần cộng thêm
    const daysToAdd = 30;
    // Sao chép ngày hết hạn để không ảnh hưởng đến ngày gốc
    const newExpirationDate = new Date(expirationDate);
    newExpirationDate.setDate(expirationDate.getDate() + daysToAdd);



    console.log('Ngày hết hạn mới:', newExpirationDate);


    const hotelID: string = req.hotel_id;

    const hotelRef = firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const dataUpdate: { [key: string]: any } = hotelDoc.get("package_version");

    const os = require('os');
    let ipAddr = "";
    // Lấy thông tin về các giao diện mạng
    const networkInterfaces = os.networkInterfaces();
    // Lặp qua các giao diện mạng và lấy địa chỉ IPv4
    Object.keys(networkInterfaces).forEach(interfaceName => {
        const interfaceData = networkInterfaces[interfaceName];
        interfaceData.forEach((entry: { family: string; internal: any; address: any; }) => {
            // Chỉ lấy địa chỉ IPv4 và không phải là địa chỉ loopback
            if (entry.family === 'IPv4' && !entry.internal) {
                ipAddr = entry.address;
            }
        });
    });

    const config = require('config');
    const tmnCode = config.get('vnp_TmnCode');
    const secretKey = config.get('vnp_HashSecret');
    let vnpUrl = config.get('vnp_Url');
    const returnUrl = config.get('vnp_ReturnUrl');
    const date: Date = new Date();

    const createDate = moment(date).format('YYYYMMDDHHmmss');
    const orderId = moment(date).format('DDHHmmss');
    const amount: number = dataUpdate[dataUpdate["default"]]["price"] ?? 10000;
    const bankCode: string = req.bankCode;

    let locale = req.language;
    if (locale === null || locale === '' || locale === undefined) {
        locale = 'vn';
    }
    const currCode: string = 'VND';
    const vnp_Params: Record<string, string | number> = {};
    vnp_Params['vnp_Version'] = '2.1.0';
    vnp_Params['vnp_Command'] = 'pay';
    vnp_Params['vnp_TmnCode'] = tmnCode;
    vnp_Params['vnp_Locale'] = locale;
    vnp_Params['vnp_CurrCode'] = currCode;
    vnp_Params['vnp_TxnRef'] = orderId;
    vnp_Params['vnp_OrderInfo'] = 'Thanh toan cho ma GD:' + orderId + "-" + hotelID;
    vnp_Params['vnp_OrderType'] = "other";
    vnp_Params['vnp_Amount'] = amount * 100;
    vnp_Params['vnp_ReturnUrl'] = returnUrl;
    vnp_Params['vnp_IpAddr'] = ipAddr;
    vnp_Params['vnp_CreateDate'] = createDate;
    if (bankCode !== null && bankCode !== '' && bankCode !== undefined) {
        vnp_Params['vnp_BankCode'] = bankCode;
    }

    // Sorting the parameters
    const sortedParams = sortObject(vnp_Params);
    const querystring = require('qs');
    // Creating a query string
    const signData: string = querystring.stringify(sortedParams, { encode: false });

    // Creating a HMAC signature
    const crypto = require("crypto");
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');

    // Adding the signature to the parameters
    sortedParams['vnp_SecureHash'] = signed;

    // Constructing the final URL
    vnpUrl += '?' + querystring.stringify(sortedParams, { encode: false });

    return vnpUrl;

});

exports.returnPaymentlistener = functions.https.onRequest(async (request, respond) => {
    let vnp_Params = request.query;

    const secureHash = vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHash'];
    delete vnp_Params['vnp_SecureHashType'];
    vnp_Params = sortObjectsOnRequest(vnp_Params);

    const config = require('config');
    const secretKey = config.get('vnp_HashSecret');

    const querystring = require('qs');
    const signData = querystring.stringify(vnp_Params, { encode: false });
    const crypto = require("crypto");
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    if (secureHash === signed) {
        console.log(vnp_Params['vnp_TransactionStatus']);
        //Kiem tra xem du lieu trong db co hop le hay khong va thong bao ket qua
        if (vnp_Params['vnp_TransactionStatus'] === "00") {
            const nowServer = new Date();
            await firestore.runTransaction(async (t) => {
                const id_hotel: string = request.query['vnp_OrderInfo']?.toString().split('-')[1]!;
                const hotelRef = await t.get(firestore.collection('hotels').doc(id_hotel));
                if (!hotelRef.exists) {
                    respond.send(MessageUtil.HOTEL_NOT_FOUND);
                }
                const timezone = hotelRef.get('timezone');
                const dataUpdateHotel: { [key: string]: any } = {};
                const endDayServer: Date = hotelRef.get("package_version")[hotelRef.get("package_version")["default"]]['end_date'].toDate();
                let newExpirationDate: Date;

                if (hotelRef.get("package_version")[hotelRef.get("package_version")["default"]]["package"] === 0) {
                    newExpirationDate = new Date(Date.UTC(endDayServer.getFullYear(), endDayServer.getMonth() + 1, endDayServer.getDate(), endDayServer.getHours(), endDayServer.getMinutes()));
                    dataUpdateHotel['package_version.' + hotelRef.get("package_version")["default"] + '.end_date'] = newExpirationDate;

                } else if (hotelRef.get("package_version")[hotelRef.get("package_version")["default"]]["package"] === 1) {

                    newExpirationDate = new Date(Date.UTC(endDayServer.getFullYear(), endDayServer.getMonth() + 12, endDayServer.getDate(), endDayServer.getHours(), endDayServer.getMinutes()));
                    dataUpdateHotel['package_version.' + hotelRef.get("package_version")["default"] + '.end_date'] = newExpirationDate;
                }
                const dataUpdate: { [key: string]: any } = {
                    'amount': (Number(request.query['vnp_Amount']) / 100),
                    'method': "ba",
                    'desc': "Auto OnePms VnPay",
                    'nameBank': request.query['vnp_BankCode'],
                    'created': nowServer,
                    'creater': "Auto OnePms VnPay",
                    'hotel': id_hotel,
                    'name_hotel': hotelRef.get('name'),
                    'package': hotelRef.get("package_version")["default"],
                    "code_bank": request.query['vnp_TxnRef'],
                    'status': "open",
                    'expired_date': endDayServer,
                    'stillIn_debt': (Number(request.query['vnp_Amount']) / 100),
                    'time_zone': timezone
                };
                t.update(firestore.collection('hotels').doc(id_hotel), dataUpdateHotel);
                t.create(firestore.collection('hotels').doc(id_hotel).collection("package_payments").doc(NumberUtil.getRandomID()), dataUpdate);
            })

            respond.send('<style> body{ background: #373a3f; } #hellobar-bar { position:absolute; left:50%; top:10%; transform:translate(-50%,-50%); background:#232b36; font-family: "Open Sans", sans-serif; width: 30%; margin: 0; height: 30px; display: table; font-size: 17px; font-weight: 400; -webkit-font-smoothing: antialiased; color: #5c5e60; position: fixed; background-color: white; box-shadow: 0 1px 3px 2px rgba(0,0,0,0.15); } #hellobar-bar.regular { height: 90px; font-size: 14px; margin: 10px; border-radius: 14px; } .hb-content-wrapper { text-align: center; position: relative; display: table-cell; vertical-align: middle; } .hb-content-wrapper p { margin-top: 0; margin-bottom: 0; } .hb-text-wrapper { display: inline-block; line-height: 1.3; } .hb-text-wrapper .hb-headline-text { font-size: 1em; display: inline-block; vertical-align: middle; } #hellobar-bar .hb-cta { display: inline-block; vertical-align: middle; margin: 5px 0; color: #ffffff; background-color: #22af73; border-color: #22af73, } .hb-cta-button { opacity: 1; color: #fff; display: block; cursor: pointer; line-height: 1.5; max-width: 22.5em; text-align: center; position: relative; border-radius: 15px; white-space: nowrap; text-decoration: none; padding: 0; overflow: hidden; } .hb-cta-button .hb-text-holder { border-radius: inherit; padding: 5px 15px; } </style> <div id="hellobar-bar" class="regular closable"> <div class="hb-content-wrapper"> <div class="hb-text-wrapper"> <div class="hb-headline-text"> <p><span>Giao dịch thành công Bạn Có thể truy cập vào hệ thống</span></p> </div> </div> <a href="https://app.onepms.net/" target="_blank" class="hb-cta hb-cta-button"> <div class="hb-text-holder"> <p>Truy Cập Ngay</p> </div> </a> </div> </div>')
        } else {
            respond.send('<style> body{ background: #373a3f; } #hellobar-bar { position:absolute; left:50%; top:10%; transform:translate(-50%,-50%); background:#232b36; font-family: "Open Sans", sans-serif; width: 30%; margin: 0; height: 30px; display: table; font-size: 17px; font-weight: 400; -webkit-font-smoothing: antialiased; color: #5c5e60; position: fixed; background-color: white; box-shadow: 0 1px 3px 2px rgba(0,0,0,0.15); } #hellobar-bar.regular { height: 90px; font-size: 14px; margin: 10px; border-radius: 14px; } .hb-content-wrapper { text-align: center; position: relative; display: table-cell; vertical-align: middle; } .hb-content-wrapper p { margin-top: 0; margin-bottom: 0; } .hb-text-wrapper { display: inline-block; line-height: 1.3; } .hb-text-wrapper .hb-headline-text { font-size: 1em; display: inline-block; vertical-align: middle; } #hellobar-bar .hb-cta { display: inline-block; vertical-align: middle; margin: 5px 0; color: #ffffff; background-color: #22af73; background-color: rgba(175, 34, 34, 0.987); border-color: rgba(175, 34, 34, 0.987) } .hb-cta-button { opacity: 1; color: #fff; display: block; cursor: pointer; line-height: 1.5; max-width: 22.5em; text-align: center; position: relative; border-radius: 15px; white-space: nowrap; text-decoration: none; padding: 0; overflow: hidden; } .hb-cta-button .hb-text-holder { border-radius: inherit; padding: 5px 15px; } </style> <div id="hellobar-bar" class="regular closable"> <div class="hb-content-wrapper"> <div class="hb-text-wrapper"> <div class="hb-headline-text"> <p><span>Giao dịch thất bại Bạn Có thể quay lại hệ thống để thử lại</span></p> </div> </div> <a href="https://app.onepms.net/" target="_blank" class="hb-cta hb-cta-button"> <div class="hb-text-holder"> <p>Truy Cập Ngay</p> </div> </a> </div> </div>')
        }
    } else {
        respond.send('Thất bại! - code: 97');
    }
});

function sortObject(obj: Record<string, string | number>): Record<string, string> {
    const sorted: Record<string, string> = {};
    const str: string[] = [];
    let key;

    for (key in obj) {
        if (obj.hasOwnProperty(key)) {
            str.push(encodeURIComponent(key));
        }
    }
    str.sort();
    for (key = 0; key < str.length; key++) {
        sorted[str[key]] = encodeURIComponent(obj[str[key]] as string).replace(/%20/g, "+");
    }

    return sorted;
}

function sortObjectsOnRequest(obj: ParsedQs): Record<string, string> {
    const sorted: Record<string, string> = {};
    const str: string[] = [];
    let key;

    for (key in obj) {
        if (obj.hasOwnProperty(key)) {
            str.push(encodeURIComponent(key));
        }
    }

    str.sort();

    for (key = 0; key < str.length; key++) {
        sorted[str[key]] = encodeURIComponent(obj[str[key]] as string).replace(/%20/g, "+");
    }

    return sorted;
}
