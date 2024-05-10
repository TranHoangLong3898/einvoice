import * as CryptoJS from 'crypto-js';

export class NumberUtil {
    static getRandomID(): string {
        const timeStamp = (new Date()).getTime();
        return timeStamp.toString() + Math.floor(Math.random() * 1000).toString();
    }


    static getSidByConvertToBase62(): string {
        const timeStamp = (new Date()).getTime();
        const base62Chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        let result = [];
        let decimalNumbers = parseInt(timeStamp.toString() + Math.floor(Math.random() * 1000).toString())
        if (decimalNumbers === 0) {
            return '0';
        }

        while (decimalNumbers > 0) {
            const remainder = decimalNumbers % 62;
            result.unshift(base62Chars[remainder]);
            decimalNumbers = Math.floor(decimalNumbers / 62);
        }
        return result.join('');
    }

    static generateResult(nameHotel: string, sidHotel: string): { [key: string]: any } {
        const base62Chars: string[] = nameHotel.split(' ');
        let result: string = '';
        const mapData: { [key: string]: any } = {};

        for (const word of base62Chars) {
            if (word.trim().length > 0) {
                result += word[0];
            }
        }

        let number: number = parseInt(sidHotel, 10);
        number++;
        let resultString: string = number.toString();
        resultString = resultString.padStart(sidHotel.length, '0');
        mapData["code"] = resultString.padStart(sidHotel.length, '0');
        result = result + resultString;
        mapData["sid"] = result;
        return mapData;
    }


    static async getSidBookingBySidHotel(hotelRefGet: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData>, hotelRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>, t: FirebaseFirestore.Transaction, sid: string): Promise<{ [key: string]: any }> {
        let sidBooking = "";
        const mapData: { [key: string]: any } = {};
        const codeBookinghHotel = hotelRefGet.get('sid_booking') ?? "000000";
        if (sid == "") {
            sidBooking = NumberUtil.generateResult(hotelRefGet.get("name"), codeBookinghHotel)["sid"];
            mapData["code"] = NumberUtil.generateResult(hotelRefGet.get("name"), codeBookinghHotel)["code"];
            const bookingRef = await t.get(hotelRef.collection('bookings').where("sid", "==", sidBooking));
            if (bookingRef.size > 0) {
                sidBooking = NumberUtil.generateResult(hotelRefGet.get("name"), mapData["code"])["sid"];
                mapData["code"] = NumberUtil.generateResult(hotelRefGet.get("name"), mapData["code"])["code"];
            }
        } else {
            const bookingRef = await t.get(hotelRef.collection('bookings').where("sid", "==", sid));
            if (bookingRef.size > 0) {
                sidBooking = NumberUtil.generateResult(hotelRefGet.get("name"), codeBookinghHotel)["sid"];
                mapData["code"] = NumberUtil.generateResult(hotelRefGet.get("name"), codeBookinghHotel)["code"];
                const bookingRefs = await t.get(hotelRef.collection('bookings').where("sid", "==", sidBooking));
                if (bookingRefs.size > 0) {
                    sidBooking = NumberUtil.generateResult(hotelRefGet.get("name"), mapData["code"])["sid"];
                    mapData["code"] = NumberUtil.generateResult(hotelRefGet.get("name"), mapData["code"])["code"];
                }
            } else {
                sidBooking = sid;
                mapData["code"] = NumberUtil.generateResult(hotelRefGet.get("name"), codeBookinghHotel)["code"];
            }
        }
        mapData["sid"] = sidBooking;
        return mapData;
    }

    static formatMoney(money: string): string {
        let result = '';
        let count = 1;
        for (let i = money.length - 1; i >= 0; i--) {
            if (count % 3 === 1 && count > 3) {
                result = money[i] + ',' + result;
            } else {
                result = money[i] + result;
            }
            count++;
        }
        return result;
    }

    static generateAuthenticationStringForEasyInvoice(username: string, password: string, httpMethod: string) : string {
        const now: Date = new Date();
        const timeStamp: number = Math.floor(now.getTime() / 1000);
        const nonce = NumberUtil.generateNonce();
        const signatureRawData = `${httpMethod.toUpperCase()}${timeStamp}${nonce}`;
        var signature = CryptoJS.enc.Base64.stringify(
            CryptoJS.MD5(signatureRawData)
          );
        
        return `${signature}:${nonce}:${timeStamp}:${username}:${password}`;
    }

    static generateNonce() : string{
        let result: string = '';
        const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        while(result.length < 32){
            result += chars[ Math.floor(Math.random() * 36)]
        }
        return result;
    }

    static generateIKey():string{
        const timeStamp = (new Date()).getTime();
        const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        let randomString = '';
        while(randomString.length< 10){
            randomString += chars[ Math.floor(Math.random() * 62)]
        }
        return CryptoJS.MD5(`${timeStamp}${randomString}`).toString(CryptoJS.enc.Hex);
    }
}