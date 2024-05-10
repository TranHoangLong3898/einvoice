import admin = require('firebase-admin');
import { NumberUtil } from "./numberutil";

export class LogUtil {
    static async logCM(hotel: string, type: string, title: string, desc: string, status: string): Promise<void> {
        const firestore = admin.firestore();
        const hotelRef = firestore.collection('hotels').doc(hotel);
        const id = NumberUtil.getRandomID();
        await hotelRef.collection('cm_logs').doc(id).set({
            'type': type,
            'title': title,
            'desc': desc,
            'status': status,
            'hotel': hotel,
            'created': new Date()
        });
    }
}