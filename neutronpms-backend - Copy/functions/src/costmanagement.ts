import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { CostType, HotelPackage, RevenueLogType } from './constant/type';
import { UserRole } from './constant/userrole';
import { DateUtil } from './util/dateutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import { NumberUtil } from './util/numberutil';

const Firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.createCostManagement = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const desc: string = data.desc;
    const supplierID: string = data.supplier_id;
    const typeCostID: string = data.type_cost_id;
    const amount: number = data.amount;

    const mapData: { [key: string]: string } = data.map_data;
    const invoiceNum: string = data.invoice_num ?? '';
    const nowServer: Date = new Date();


    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }

    const timezone: string = hotelDoc.get('timezone');
    const uidOfUser: string = context.auth.uid;
    const author: string = context.auth.token.email ?? 'unknown email';

    const createdTimezone: Date = (data.created !== '' && data.created !== null) ? new Date(data.created) : DateUtil.convertUpSetTimezone(nowServer, timezone);
    const createdServer: Date = DateUtil.convertOffSetTimezone(createdTimezone, timezone);
    const monthID: string = DateUtil.dateToShortStringYearMonth(createdTimezone);
    if (hotelDoc.get('financial_date') !== undefined) {
        const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
        const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
        if (financialDateTimezone.getTime() > createdServer.getTime()) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
        }
    }

    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const res = Firestore.runTransaction(async (t) => {

        const configurationInCloud = (await t.get(hotelRef.collection('management').doc('configurations'))).get("data");
        const IdCost = NumberUtil.getRandomID();
        if (configurationInCloud['accounting_type'] === undefined) {
            throw new functions.https.HttpsError('not-found', MessageUtil.MUST_CONFIGURE_ACCOUNTING_TYPE_FIRST);
        }

        if (!Object.keys(configurationInCloud['accounting_type']).includes(typeCostID)) {
            throw new functions.https.HttpsError('not-found', MessageUtil.TYPE_COST_NOT_FOUND);
        }

        if (!Object.keys(configurationInCloud['suppliers']).includes(supplierID)) {
            throw new functions.https.HttpsError('not-found', MessageUtil.SUPPLIER_NOT_FOUND);
        }

        const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
        if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
            throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
        }

        const importNoteDocs = await t.get(hotelDoc.ref.collection('warehouse_notes').where('invoice', '==', invoiceNum));
        const costManagementDocs = await t.get(hotelDoc.ref.collection('cost_management').where('invoice_num', '==', invoiceNum));

        if (importNoteDocs.docs.length === 0 && invoiceNum !== '') {
            throw new functions.https.HttpsError('not-found', MessageUtil.CAN_NOT_FIND_INVOICE_NUMBER);
        }

        const dataUpdate: { [key: string]: any } = {};
        const dataUpdateCosForBooking: { [key: string]: any } = {};
        let typecost: number = CostType.accounting;
        if (mapData["sid"] !== undefined && mapData["id"] !== undefined) {
            const docBasicBooking = await t.get(hotelRef.collection('basic_bookings').doc(mapData["id"]));
            typecost = CostType.booked;
            dataUpdate['sid'] = mapData["sid"];
            dataUpdate['id'] = mapData["id"];
            dataUpdateCosForBooking['cost_details.' + IdCost] = typeCostID + NeutronUtil.specificChar + amount + NeutronUtil.specificChar + docBasicBooking.get('room') + NeutronUtil.specificChar + IdCost;
            console.log('fieldValue  ', admin.firestore.FieldValue);

            t.update(hotelDoc.ref.collection('basic_bookings').doc(mapData["id"]), {
                "total_cost": FieldValue.increment(amount)
            });
            if (docBasicBooking.get('group')) {
                t.update(hotelDoc.ref.collection('bookings').doc(mapData["sid"]), dataUpdateCosForBooking);
            } else {
                t.update(hotelDoc.ref.collection('bookings').doc(mapData["id"]), dataUpdateCosForBooking);
            }
        }
        if (mapData["roomtype"] !== undefined && mapData["room"] !== undefined) {
            typecost = CostType.room;
            dataUpdate['room_type'] = mapData["roomtype"];
            dataUpdate['room'] = mapData["room"];
        }

        dataUpdate['author'] = author;
        dataUpdate['created'] = createdServer;
        dataUpdate['desc'] = desc;
        dataUpdate['status'] = 'open';
        dataUpdate['actual_payment'] = 0;
        dataUpdate['supplier'] = supplierID;
        dataUpdate['type'] = typeCostID;
        dataUpdate['amount'] = amount;
        dataUpdate['cost_type'] = typecost;


        if (invoiceNum !== '') {
            dataUpdate['invoice_num'] = invoiceNum;
        }
        const importNoteData = importNoteDocs.docs[0];
        var totalCost = 0;
        if (invoiceNum !== '') {
            if (importNoteData.get('total_cost') == undefined) {
                for (const cost of costManagementDocs.docs) {
                    totalCost += cost.get('amount');
                }
                totalCost += amount;
                t.update(hotelDoc.ref.collection('warehouse_notes').doc(importNoteData.id), {
                    'total_cost': FieldValue.increment(totalCost)
                })
            } else {
                t.update(hotelDoc.ref.collection('warehouse_notes').doc(importNoteData.id), {
                    'total_cost': FieldValue.increment(amount)
                });
            }
        }

        // create document
        t.create(hotelDoc.ref.collection('cost_management').doc(IdCost), dataUpdate);
        // create for daily data
        const dataUpdateDaily: { [key: string]: any } = {};
        // cost management . supplier . type cost . status
        dataUpdateDaily['data.' + DateUtil.dateToShortStringDay(createdTimezone) + '.cost_management.' + typeCostID + '.' + supplierID + '.open'] = FieldValue.increment(amount);
        try {
            t.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);
        } catch (error) {
            t.create(hotelDoc.ref.collection('daily_data').doc(monthID), {});
            t.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);
        }
        return MessageUtil.SUCCESS;
    });
    return res;

});

exports.updateCostManagement = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;
    const newDesc: string = data.desc;
    const newSupllierID: string = data.supplier_id;
    const newTypeCostID: string = data.type_cost_id;
    const newAmount: number = data.amount;
    const newInvoiceNum: string = data.invoice_num;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');
    const uidOfUser: string = context.auth.uid;
    const IdCost = NumberUtil.getRandomID();

    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const configurationInCloud = (await hotelRef.collection('management').doc('configurations').get()).get('data');

    if (!Object.keys(configurationInCloud['accounting_type']).includes(newTypeCostID)) {
        throw new functions.https.HttpsError('not-found', MessageUtil.TYPE_COST_NOT_FOUND);
    }

    if (!Object.keys(configurationInCloud['suppliers']).includes(newSupllierID)) {
        throw new functions.https.HttpsError('not-found', MessageUtil.SUPPLIER_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction = await Firestore.runTransaction(async (transaction) => {
        let docBasicBooking;
        let newImportNoteDoc;
        let oldImportNoteDoc;
        let newCostOfImportNote;
        let oldCostOfImportNote;

        const costManagementDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID));
        const oldAmount = costManagementDoc.get('amount');
        const oldInvoiceNum = costManagementDoc.get('invoice_num');

        if (newInvoiceNum != undefined) {
            newImportNoteDoc = await transaction.get(hotelDoc.ref.collection('warehouse_notes').where('invoice', '==', newInvoiceNum));
            if (newImportNoteDoc.docs.length === 0) {
                throw new functions.https.HttpsError('not-found', MessageUtil.CAN_NOT_FIND_INVOICE_NUMBER);
            }
            if (newImportNoteDoc.docs[0].get('total_cost') == undefined) {
                newCostOfImportNote = await transaction.get(hotelDoc.ref.collection('cost_management').where('invoice_num', '==', newInvoiceNum));
            }
        }

        if (oldInvoiceNum != undefined && oldInvoiceNum != newInvoiceNum) {
            oldImportNoteDoc = await transaction.get(hotelDoc.ref.collection('warehouse_notes').where('invoice', '==', oldInvoiceNum));
            if (oldImportNoteDoc.docs[0].get('total_cost') == undefined) {
                oldCostOfImportNote = await transaction.get(hotelDoc.ref.collection('cost_management').where('invoice_num', '==', newInvoiceNum));
            }
        }

        if (costManagementDoc.get("sid") !== undefined && costManagementDoc.get("id") !== undefined) {
            docBasicBooking = await transaction.get(hotelRef.collection('basic_bookings').doc(costManagementDoc.get('id')));
        }
        if (!costManagementDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.COST_MANAGEMENT_NOT_FOUND);
        }

        if (newAmount < costManagementDoc.get('actual_payment')) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST);
        }

        const createdServerCostDoc: Date = costManagementDoc.get('created').toDate();
        const createdTimezoneCostDoc: Date = DateUtil.convertUpSetTimezone(createdServerCostDoc, timezone);
        const monthID: string = DateUtil.dateToShortStringYearMonth(createdTimezoneCostDoc);
        createdTimezoneCostDoc.setHours(23, 59, 59);

        if (hotelDoc.get('financial_date') !== undefined) {
            const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
            const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
            if (financialDateTimezone.getTime() > createdTimezoneCostDoc.getTime()) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
            }
        }

        if (!roleOfUser.some((role) => [UserRole.owner, UserRole.manager, UserRole.admin].includes(role))) {
            const nowServer: Date = new Date();
            const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
            if (nowTimezone.getTime() > createdTimezoneCostDoc.getTime()) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.FORBIDDEN);
            }
        }

        // check amount to update status
        const dataUpdateCostManagement: { [key: string]: any } = {};

        let isHaveUpdateStatus: boolean = false;
        if (costManagementDoc.get('status') === 'partial') {
            if (newAmount === costManagementDoc.get('actual_payment')) {
                dataUpdateCostManagement['status'] = 'done';
                isHaveUpdateStatus = true;
            }
        } else if (costManagementDoc.get('status') === 'done') {
            if (newAmount !== costManagementDoc.get('actual_payment')) {
                dataUpdateCostManagement['status'] = 'partial';
                isHaveUpdateStatus = true;
            }
        }

        dataUpdateCostManagement['supplier'] = newSupllierID;
        dataUpdateCostManagement['type'] = newTypeCostID;
        dataUpdateCostManagement['amount'] = newAmount;
        dataUpdateCostManagement['desc'] = newDesc;
        dataUpdateCostManagement['invoice_num'] = newInvoiceNum === undefined ? FieldValue.delete() : newInvoiceNum;

        if (costManagementDoc.get('amount') !== newAmount || costManagementDoc.get('type') !== newTypeCostID || costManagementDoc.get('supplier') !== newSupllierID || isHaveUpdateStatus) {
            if (costManagementDoc.get('type') !== newTypeCostID || costManagementDoc.get('supplier') !== newSupllierID) {
                const actualPaymentDocs = await transaction.get(costManagementDoc.ref.collection('actual_payment'));
                let dataDailyActualPayment: { [key: string]: any } = {};

                for (const actualPayment of actualPaymentDocs.docs) {
                    const createdServerActualPayment: Date = actualPayment.get('created').toDate();
                    const createdTimezoneActualPayment: Date = DateUtil.convertUpSetTimezone(createdServerActualPayment, timezone);
                    const monthIDActualPayment = DateUtil.dateToShortStringYearMonth(createdTimezoneActualPayment);
                    const methodActualPayment: string = actualPayment.get('method');

                    dataDailyActualPayment[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPayment.get('type')}.${actualPayment.get('supplier')}.${methodActualPayment}.${actualPayment.get('status')}`] = FieldValue.increment(- actualPayment.get('amount'));
                    dataDailyActualPayment[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${newTypeCostID}.${newSupllierID}.${methodActualPayment}.${actualPayment.get('status')}`] = FieldValue.increment(actualPayment.get('amount'));

                    transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDActualPayment), dataDailyActualPayment);
                    transaction.update(actualPayment.ref, { 'type': newTypeCostID, 'supplier': newSupllierID });
                    dataDailyActualPayment = {};
                }
            }

            let dataUpdateDaily: { [key: string]: any } = {};
            dataUpdateDaily['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostDoc) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.' + costManagementDoc.get('status')] = FieldValue.increment(-costManagementDoc.get('amount'));
            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);
            dataUpdateDaily = {};
            if (isHaveUpdateStatus) {
                dataUpdateDaily['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostDoc) + '.cost_management.' + newTypeCostID + '.' + newSupllierID + '.' + dataUpdateCostManagement['status']] = FieldValue.increment(newAmount);
            } else {
                dataUpdateDaily['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostDoc) + '.cost_management.' + newTypeCostID + '.' + newSupllierID + '.' + costManagementDoc.get('status')] = FieldValue.increment(newAmount);
            }
            if (costManagementDoc.get("sid") !== undefined && costManagementDoc.get("id") !== undefined) {
                const dataUpdateCosForBooking: { [key: string]: any } = {};
                if (costManagementDoc.get("amount") > newAmount) {
                    transaction.update(hotelDoc.ref.collection('basic_bookings').doc(costManagementDoc.get("id")), {
                        "total_cost": FieldValue.increment(-(costManagementDoc.get("amount") - newAmount))
                    });
                } else {
                    transaction.update(hotelDoc.ref.collection('basic_bookings').doc(costManagementDoc.get("id")), {
                        "total_cost": FieldValue.increment((newAmount - costManagementDoc.get("amount")))
                    });
                }
                dataUpdateCosForBooking['cost_details.' + costManagementID] = newTypeCostID + NeutronUtil.specificChar + newAmount + NeutronUtil.specificChar + docBasicBooking?.get('room') + NeutronUtil.specificChar + IdCost;
                if (docBasicBooking?.get('group')) {
                    transaction.update(hotelDoc.ref.collection('bookings').doc(costManagementDoc.get("sid")), dataUpdateCosForBooking);
                } else {
                    transaction.update(hotelDoc.ref.collection('bookings').doc(costManagementDoc.get("id")), dataUpdateCosForBooking);
                }
            }
            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);

        }

        if (oldInvoiceNum != undefined && newInvoiceNum != undefined) {
            if (oldInvoiceNum == newInvoiceNum && newImportNoteDoc != undefined) {
                if (newImportNoteDoc.docs[0].get('total_cost') == undefined && newCostOfImportNote != undefined) {
                    let total_cost = 0;
                    for (const cost of newCostOfImportNote.docs) {
                        total_cost += cost.get('amount');
                    }
                    total_cost += (newAmount - oldAmount);
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(total_cost)
                    });
                }

                if (newImportNoteDoc.docs[0].get('total_cost') != undefined) {
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(newAmount - oldAmount)
                    });
                }
            }

            if (oldInvoiceNum != newInvoiceNum && newImportNoteDoc != undefined && oldImportNoteDoc != undefined) {
                if (newImportNoteDoc.docs[0].get('total_cost') == undefined && newCostOfImportNote != undefined) {
                    let total_cost = 0;
                    for (const cost of newCostOfImportNote.docs) {
                        total_cost += cost.get('amount');
                    }
                    total_cost += newAmount;
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(total_cost)
                    });
                }

                if (newImportNoteDoc.docs[0].get('total_cost') != undefined) {
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(newAmount)
                    });
                }

                if (oldImportNoteDoc.docs[0].get('total_cost') == undefined && oldCostOfImportNote != undefined) {
                    let total_cost = 0;
                    for (const cost of oldCostOfImportNote.docs) {
                        total_cost += cost.get('amount');
                    }
                    total_cost -= oldAmount;
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(oldImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(total_cost)
                    });
                }

                if (oldImportNoteDoc.docs[0].get('total_cost') != undefined) {
                    transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(oldImportNoteDoc.docs[0].id), {
                        'total_cost': FieldValue.increment(-oldAmount)
                    });
                }
            }
        } else if (oldInvoiceNum != undefined && oldImportNoteDoc != undefined) {
            if (oldImportNoteDoc.docs[0].get('total_cost') == undefined && oldCostOfImportNote != undefined) {
                let total_cost = 0;
                for (const cost of oldCostOfImportNote.docs) {
                    total_cost += cost.get('amount');
                }
                total_cost -= oldAmount;
                transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(oldImportNoteDoc.docs[0].id), {
                    'total_cost': FieldValue.increment(total_cost)
                });
            }

            if (oldImportNoteDoc.docs[0].get('total_cost') != undefined) {
                transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(oldImportNoteDoc.docs[0].id), {
                    'total_cost': FieldValue.increment(-oldAmount)
                });
            }
        } else if (newInvoiceNum != undefined && newImportNoteDoc != undefined) {
            if (newImportNoteDoc.docs[0].get('total_cost') == undefined && newCostOfImportNote != undefined) {
                let total_cost = 0;
                for (const cost of newCostOfImportNote.docs) {
                    total_cost += cost.get('amount');
                }
                total_cost += (newAmount);
                transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                    'total_cost': FieldValue.increment(total_cost)
                });
            }

            if (newImportNoteDoc.docs[0].get('total_cost') != undefined) {
                transaction.update(hotelDoc.ref.collection('warehouse_notes').doc(newImportNoteDoc.docs[0].id), {
                    'total_cost': FieldValue.increment(newAmount)
                });
            }
        }

        transaction.update(hotelDoc.ref.collection('cost_management').doc(costManagementID), dataUpdateCostManagement);

        return MessageUtil.SUCCESS;
    }).catch((error) => {
        console.log(error);
        throw new functions.https.HttpsError('cancelled', error.message);
    });

    return resultTransaction;
});

exports.deleteCostManagement = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');
    const uidOfUser: string = context.auth.uid;
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const batch: admin.firestore.WriteBatch = Firestore.batch();

    const costManagementDoc = await hotelDoc.ref.collection('cost_management').doc(costManagementID).get();
    let docBasicBooking;
    if (costManagementDoc.get("sid") !== undefined && costManagementDoc.get("id") !== undefined) {
        docBasicBooking = await hotelRef.collection('basic_bookings').doc(costManagementDoc.get('id')).get();
    }
    if (!costManagementDoc.exists) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.COST_MANAGEMENT_NOT_FOUND);
    }

    if (costManagementDoc.get('actual_payment') !== 0) {
        throw new functions.https.HttpsError('cancelled', MessageUtil.MUST_DELETE_ACTUAL_PAYMENT_COLLECTION);
    }

    const createdServerCostDoc: Date = costManagementDoc.get('created').toDate();
    const createdTimezoneCostDoc: Date = DateUtil.convertUpSetTimezone(createdServerCostDoc, timezone);
    const monthID: string = DateUtil.dateToShortStringYearMonth(createdTimezoneCostDoc);
    createdTimezoneCostDoc.setHours(23, 59, 59);

    const importInvoiceNum = costManagementDoc.get('invoice_num');
    let importNoteDoc;
    if (importInvoiceNum != undefined) {
        const importNoteDocs = (await hotelDoc.ref.collection('warehouse_notes').where('invoice', '==', importInvoiceNum).get()).docs;
        if (importNoteDocs.length == 0) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.CAN_NOT_FOUND_INVOICE);
        } else {
            importNoteDoc = importNoteDocs[0];
        }
    }

    if (hotelDoc.get('financial_date') !== undefined) {
        const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
        const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
        if (financialDateTimezone.getTime() > createdTimezoneCostDoc.getTime()) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
        }
    }

    if (!roleOfUser.some((role) => [UserRole.owner, UserRole.manager, UserRole.admin].includes(role))) {
        const nowServer: Date = new Date();
        const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
        if (nowTimezone.getTime() > createdTimezoneCostDoc.getTime()) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.FORBIDDEN);
        }
    }
    if (costManagementDoc.get("sid") !== undefined && costManagementDoc.get("id") !== undefined) {
        const dataUpdateCosForBooking: { [key: string]: any } = {};
        batch.update(hotelDoc.ref.collection('basic_bookings').doc(costManagementDoc.get("id")), {
            "total_cost": FieldValue.increment(-costManagementDoc.get("amount"))
        });
        dataUpdateCosForBooking['cost_details.' + costManagementID] = FieldValue.delete();
        if (docBasicBooking?.get('group')) {
            batch.update(hotelDoc.ref.collection('bookings').doc(costManagementDoc.get("sid")), dataUpdateCosForBooking);
        } else {
            batch.update(hotelDoc.ref.collection('bookings').doc(costManagementDoc.get("id")), dataUpdateCosForBooking);
        }
    }

    if (importNoteDoc != undefined) {
        if (importNoteDoc.get('total_cost') == undefined) {
            let totalCost = 0;
            const costsOfImportNote = await hotelDoc.ref.collection('cost_management').where('invoice_num', '==', importNoteDoc.get('invoice')).get();
            for (const cost of costsOfImportNote.docs) {
                totalCost += cost.get('amount');
            }
            totalCost -= costManagementDoc.get('amount');
            batch.update(hotelDoc.ref.collection('warehouse_notes').doc(importNoteDoc.id), { 'total_cost': FieldValue.increment(totalCost) })
        } else {
            batch.update(hotelDoc.ref.collection('warehouse_notes').doc(importNoteDoc.id), { 'total_cost': FieldValue.increment(- costManagementDoc.get('amount')) })
        }
    }

    batch.delete(costManagementDoc.ref);
    const dataUpdateDaily: { [key: string]: any } = {};
    dataUpdateDaily[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostDoc)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.${costManagementDoc.get('status')}`] = FieldValue.increment(-costManagementDoc.get('amount'));
    batch.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);

    await batch.commit();
    return MessageUtil.SUCCESS;
});

// create sub collection actual payment for each cost_management doc
exports.createActual = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;
    const methodActualPaymentID: string = data.method_actual_payment_id;
    const amountActualPayment: number = data.amount_actual_payment;
    const descActualPayment: string = data.desc_actual_payment;
    const nowServer: Date = new Date();

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');

    const createdTimezone: Date = (data.created !== '' && data.created !== null) ? new Date(data.created) : DateUtil.convertUpSetTimezone(nowServer, timezone);

    const createdServer: Date = DateUtil.convertOffSetTimezone(createdTimezone, timezone);

    const monthID: string = DateUtil.dateToShortStringYearMonth(createdTimezone);

    const uidOfUser: string = context.auth.uid;
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    if (hotelDoc.get('financial_date') !== undefined) {
        const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
        const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
        if (financialDateTimezone.getTime() > createdServer.getTime()) {
            throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
        }
    }


    const systemConfiguration = await hotelRef.collection('management').doc('payment_methods').get();
    if (!Object.keys(systemConfiguration.get('data')).includes(methodActualPaymentID)) {
        throw new functions.https.HttpsError('not-found', MessageUtil.METHOD_PAYMENT_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const dailyDataUpdate: { [key: string]: any } = {};

    const resultTransaction: string = await Firestore.runTransaction(async (transaction) => {
        const costManagementDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID));
        if (!costManagementDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.COST_MANAGEMENT_NOT_FOUND);
        }

        const revenueDoc = await transaction.get(hotelDoc.ref.collection('management').doc('revenue'));
        if (!revenueDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.REVENUE_DOC_NOT_FOUND);
        }

        dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezone) + '.actual_payment.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.' + methodActualPaymentID + '.open'] = FieldValue.increment(amountActualPayment);

        const newTotalActualPaymentAmount = amountActualPayment + costManagementDoc.get('actual_payment');
        if (costManagementDoc.get('amount') < 0) {
            if (newTotalActualPaymentAmount > 0) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST);
            }
        } else {
            if (newTotalActualPaymentAmount > costManagementDoc.get('amount')) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST);
            }
        }

        transaction.create(hotelDoc.ref.collection('cost_management').doc(costManagementID).collection('actual_payment').doc(NumberUtil.getRandomID()), {
            'hotel_id': hotelID,
            'cost_management_id': costManagementID,
            'amount': amountActualPayment,
            'method': methodActualPaymentID,
            'created': createdServer,
            'status': 'open',
            'email': context.auth?.token.email,
            'type': costManagementDoc.get('type'),
            'supplier': costManagementDoc.get('supplier'),
            'desc': descActualPayment
        });

        // create revenue_logs for actual payments
        transaction.create(hotelDoc.ref.collection('revenue_logs').doc(NumberUtil.getRandomID()), {
            'amount': amountActualPayment,
            'method': methodActualPaymentID,
            'desc': `create-actual-payment-for${NeutronUtil.specificChar}${costManagementDoc.get('type')}${NeutronUtil.specificChar}${costManagementDoc.get('supplier')}`,
            'type': RevenueLogType.typeActualPayment,
            'created': nowServer,
            'email': context.auth?.token.email,
            'data': revenueDoc.data()
        });

        // update revenue Doc
        const dataRevenue: { [key: string]: any } = {};
        dataRevenue[methodActualPaymentID] = FieldValue.increment(- amountActualPayment);
        transaction.update(hotelDoc.ref.collection('management').doc('revenue'), dataRevenue);

        const createdServerCostManagement: Date = costManagementDoc.get('created').toDate();
        const createdTimezoneCostManagement: Date = DateUtil.convertUpSetTimezone(createdServerCostManagement, timezone);
        const monthIDCostManagement: string = DateUtil.dateToShortStringYearMonth(createdServerCostManagement);
        if (costManagementDoc.get('status') === 'open') {
            // to do update daily data here
            const dailyDataCostManagement: { [key: string]: any } = {};
            const dataCostManagement: { [key: string]: any } = {};
            dailyDataCostManagement['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.open'] = FieldValue.increment(- costManagementDoc.get('amount'));
            if (newTotalActualPaymentAmount === costManagementDoc.get('amount')) {
                dataCostManagement['status'] = 'done';
                dailyDataCostManagement['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.done'] = FieldValue.increment(costManagementDoc.get('amount'));
            } else {
                dataCostManagement['status'] = 'partial';
                dailyDataCostManagement['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.partial'] = FieldValue.increment(costManagementDoc.get('amount'));
            }
            dataCostManagement['actual_payment'] = FieldValue.increment(amountActualPayment);
            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDCostManagement), dailyDataCostManagement);
            transaction.update(hotelDoc.ref.collection('cost_management').doc(costManagementID), dataCostManagement);
        } else {
            //this case is when status = partial
            const dataCostManagement: { [key: string]: any } = {};
            dataCostManagement['actual_payment'] = FieldValue.increment(amountActualPayment)

            if ((amountActualPayment + costManagementDoc.get('actual_payment')) === costManagementDoc.get('amount')) {
                dataCostManagement['status'] = 'done';

                const dailyDataCostManagement: { [key: string]: any } = {};
                dailyDataCostManagement['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.partial'] = FieldValue.increment(- costManagementDoc.get('amount'));
                dailyDataCostManagement['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.done'] = FieldValue.increment(costManagementDoc.get('amount'));
                transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDCostManagement), dailyDataCostManagement);
            }
            transaction.update(hotelDoc.ref.collection('cost_management').doc(costManagementID), dataCostManagement);
        }
        return MessageUtil.SUCCESS;
    });

    try {
        await hotelDoc.ref.collection('daily_data').doc(monthID).update(dailyDataUpdate);
    } catch (error) {
        await hotelDoc.ref.collection('daily_data').doc(monthID).create({});
        await hotelDoc.ref.collection('daily_data').doc(monthID).update(dailyDataUpdate);
    }

    return resultTransaction;
});

exports.updateActual = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;
    const actualPaymentID: string = data.actual_payment_id;
    const newAmount: number = data.amount_actual_payment;
    const newMethodID: string = data.method_actual_payment_id;
    const newDescActualPayment: string = data.desc_actual_payment;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');

    const uidOfUser: string = context.auth.uid;
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const systemConfiguration = await hotelRef.collection('management').doc('payment_methods').get();
    if (!Object.keys(systemConfiguration.get('data')).includes(newMethodID)) {
        throw new functions.https.HttpsError('not-found', MessageUtil.METHOD_PAYMENT_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction: string = await Firestore.runTransaction(async (transaction) => {

        const costManagementDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID));

        const actualPaymentDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID).collection('actual_payment').doc(actualPaymentID));
        if (!actualPaymentDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.ACTUAL_PAYMENT_NOT_FOUND);
        };

        const createdServerActualPayment: Date = actualPaymentDoc.get('created').toDate();
        const createdTimezoneActualPayment: Date = DateUtil.convertUpSetTimezone(createdServerActualPayment, timezone);
        const monthIDActualPayment = DateUtil.dateToShortStringYearMonth(createdTimezoneActualPayment);
        createdTimezoneActualPayment.setHours(23, 59, 59);


        if (hotelDoc.get('financial_date') !== undefined) {
            const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
            const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
            if (financialDateTimezone.getTime() > createdTimezoneActualPayment.getTime()) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
            }
        }

        if (!roleOfUser.some((role) => [UserRole.owner, UserRole.manager, UserRole.admin].includes(role))) {
            const nowServer: Date = new Date();
            const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
            if (nowTimezone.getTime() > createdTimezoneActualPayment.getTime()) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.FORBIDDEN);
            }
        }

        const revenueDoc = await transaction.get(hotelDoc.ref.collection('management').doc('revenue'));
        if (!revenueDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.REVENUE_DOC_NOT_FOUND);
        }

        const newTotalActualPaymentAmount = costManagementDoc.get('actual_payment') + newAmount - actualPaymentDoc.get('amount');
        if (costManagementDoc.get('amount') < 0) {
            if (newTotalActualPaymentAmount > 0) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST);
            }
        } else {
            if (newTotalActualPaymentAmount > costManagementDoc.get('amount')) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST);
            }
        }

        transaction.update(actualPaymentDoc.ref, {
            'amount': newAmount,
            'method': newMethodID,
            'desc': newDescActualPayment
        });

        //update daily data
        if (actualPaymentDoc.get('method') !== newMethodID || actualPaymentDoc.get('amount') !== newAmount) {
            const dailyDataUpdate: { [key: string]: any } = {};

            dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezoneActualPayment) + '.actual_payment.' + actualPaymentDoc.get('type') + '.' + actualPaymentDoc.get('supplier') + '.' + actualPaymentDoc.get('method') + '.' + actualPaymentDoc.get('status')] = FieldValue.increment(- actualPaymentDoc.get('amount'));

            if (dailyDataUpdate[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${newMethodID}.${actualPaymentDoc.get('status')}`] !== undefined) {
                dailyDataUpdate[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${newMethodID}.${actualPaymentDoc.get('status')}`] = FieldValue.increment(newAmount + dailyDataUpdate[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${newMethodID}.${actualPaymentDoc.get('status')}`]['operand']);
            } else {
                dailyDataUpdate[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${newMethodID}.${actualPaymentDoc.get('status')}`] = FieldValue.increment(newAmount);
            }

            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDActualPayment), dailyDataUpdate);

            // create revenue_logs for actual payments
            transaction.create(hotelDoc.ref.collection('revenue_logs').doc(NumberUtil.getRandomID()), {
                'amount': newAmount,
                'method': newMethodID,
                'desc': `update-actual-payment-for${NeutronUtil.specificChar}${costManagementDoc.get('type')}${NeutronUtil.specificChar}${costManagementDoc.get('supplier')}`,
                'type': RevenueLogType.typeActualPayment,
                'created': new Date(),
                'email': context.auth?.token.email,
                'data': revenueDoc.data(),
                'old_method': actualPaymentDoc.get('method'),
                'old_amount': actualPaymentDoc.get('amount')
            });

            // update revenue Doc
            const dataRevenue: { [key: string]: any } = {};
            if (actualPaymentDoc.get('method') !== newMethodID) {
                dataRevenue[actualPaymentDoc.get('method')] = FieldValue.increment(actualPaymentDoc.get('amount'));
                dataRevenue[newMethodID] = FieldValue.increment(- newAmount);
            } else {
                dataRevenue[actualPaymentDoc.get('method')] = FieldValue.increment(- (newAmount - actualPaymentDoc.get('amount')));
            }
            transaction.update(hotelDoc.ref.collection('management').doc('revenue'), dataRevenue);
        };

        // check actual_payment in cost management
        const createdServerCostMangement: Date = costManagementDoc.get('created').toDate();
        const createdTimezoneCostManagement: Date = DateUtil.convertUpSetTimezone(createdServerCostMangement, timezone);
        const monthID: string = DateUtil.dateToShortStringYearMonth(createdTimezoneCostManagement);
        if (newTotalActualPaymentAmount === costManagementDoc.get('amount')) {
            transaction.update(hotelDoc.ref.collection('cost_management').doc(costManagementID), {
                'actual_payment': FieldValue.increment(newAmount - actualPaymentDoc.get('amount')),
                'status': 'done'
            });

            const dailyDataUpdate: { [key: string]: any } = {};
            dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.partial'] = FieldValue.increment(-costManagementDoc.get('amount'));
            dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.done'] = FieldValue.increment(costManagementDoc.get('amount'));
            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthID), dailyDataUpdate);
        } else {
            //this case is when actual_payment < amount in costManagement document
            transaction.update(hotelDoc.ref.collection('cost_management').doc(costManagementID), {
                'actual_payment': FieldValue.increment(newAmount - actualPaymentDoc.get('amount')),
                'status': 'partial'
            });
            if (costManagementDoc.get('status') === 'done') {
                const dailyDataUpdate: { [key: string]: any } = {};
                dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.partial'] = FieldValue.increment(+costManagementDoc.get('amount'));
                dailyDataUpdate['data.' + DateUtil.dateToShortStringDay(createdTimezoneCostManagement) + '.cost_management.' + costManagementDoc.get('type') + '.' + costManagementDoc.get('supplier') + '.done'] = FieldValue.increment(-costManagementDoc.get('amount'));
                transaction.update(hotelDoc.ref.collection('daily_data').doc(monthID), dailyDataUpdate);
            }

        }
        return MessageUtil.SUCCESS;
    })
    return resultTransaction;
});

exports.deleteActual = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);
    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;
    const actualPaymentID: string = data.actual_payment_id;

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');

    const uidOfUser: string = context.auth.uid;
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction = await Firestore.runTransaction(async (transaction) => {
        const costManagementDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID));
        if (!costManagementDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.COST_MANAGEMENT_NOT_FOUND);
        }

        const actualPaymentDoc = await transaction.get(costManagementDoc.ref.collection('actual_payment').doc(actualPaymentID));
        if (!actualPaymentDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.ACTUAL_PAYMENT_NOT_FOUND);
        }

        const createdServerActualPayment: Date = actualPaymentDoc.get('created').toDate();
        const createdTimezoneActualPayment: Date = DateUtil.convertUpSetTimezone(createdServerActualPayment, timezone);
        const monthIDActualPayment = DateUtil.dateToShortStringYearMonth(createdTimezoneActualPayment);
        createdTimezoneActualPayment.setHours(23, 59, 59);

        if (hotelDoc.get('financial_date') !== undefined) {
            const financialDateServer: Date = hotelDoc.get('financial_date').toDate();
            const financialDateTimezone: Date = DateUtil.convertUpSetTimezone(financialDateServer, timezone);
            if (financialDateTimezone.getTime() > createdTimezoneActualPayment.getTime()) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE);
            }
        }

        if (!roleOfUser.some((role) => [UserRole.owner, UserRole.manager, UserRole.admin].includes(role))) {
            const nowServer: Date = new Date();
            const nowTimezone: Date = DateUtil.convertUpSetTimezone(nowServer, timezone);
            if (nowTimezone.getTime() > createdTimezoneActualPayment.getTime()) {
                throw new functions.https.HttpsError('cancelled', MessageUtil.FORBIDDEN);
            }
        }

        const revenueDoc = await transaction.get(hotelDoc.ref.collection('management').doc('revenue'));
        if (!revenueDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.REVENUE_DOC_NOT_FOUND);
        }

        transaction.delete(costManagementDoc.ref.collection('actual_payment').doc(actualPaymentID));

        const dailyDataUpdate: { [key: string]: any } = {};
        dailyDataUpdate[`data.${DateUtil.dateToShortStringDay(createdTimezoneActualPayment)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${actualPaymentDoc.get('method')}.${actualPaymentDoc.get('status')}`] = FieldValue.increment(-actualPaymentDoc.get('amount'));
        transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDActualPayment), dailyDataUpdate);

        // create revenue_logs for actual payments
        transaction.create(hotelDoc.ref.collection('revenue_logs').doc(NumberUtil.getRandomID()), {
            'amount': actualPaymentDoc.get('amount'),
            'method': actualPaymentDoc.get('method'),
            'desc': `delete-actual-payment-for${NeutronUtil.specificChar}${costManagementDoc.get('type')}${NeutronUtil.specificChar}${costManagementDoc.get('supplier')}`,
            'type': RevenueLogType.typeActualPayment,
            'created': new Date(),
            'email': context.auth?.token.email,
            'data': revenueDoc.data()
        });

        // update revenue Doc
        const dataRevenue: { [key: string]: any } = {};
        dataRevenue[actualPaymentDoc.get('method')] = FieldValue.increment(actualPaymentDoc.get('amount'));
        transaction.update(hotelDoc.ref.collection('management').doc('revenue'), dataRevenue);

        const createdServerCostManagement: Date = costManagementDoc.get('created').toDate();
        const createdTimezoneCostManagement: Date = DateUtil.convertUpSetTimezone(createdServerCostManagement, timezone);
        const monthIDCostManagement: string = DateUtil.dateToShortStringYearMonth(createdTimezoneCostManagement);
        if (costManagementDoc.get('status') === 'done') {
            const dailyDataUpdateCost: { [key: string]: any } = {};
            dailyDataUpdateCost[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostManagement)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.done`] = FieldValue.increment(-costManagementDoc.get('amount'));

            if (costManagementDoc.get('amount') === actualPaymentDoc.get('amount')) {
                transaction.update(costManagementDoc.ref, { 'actual_payment': FieldValue.increment(- actualPaymentDoc.get('amount')), 'status': 'open' });
                dailyDataUpdateCost[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostManagement)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.open`] = FieldValue.increment(costManagementDoc.get('amount'));
            } else {
                transaction.update(costManagementDoc.ref, { 'actual_payment': FieldValue.increment(- actualPaymentDoc.get('amount')), 'status': 'partial' });
                dailyDataUpdateCost[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostManagement)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.partial`] = FieldValue.increment(costManagementDoc.get('amount'));
            }

            transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDCostManagement), dailyDataUpdateCost);
        } else if (costManagementDoc.get('status') === 'partial') {
            if (costManagementDoc.get('actual_payment') === actualPaymentDoc.get('amount')) {
                transaction.update(costManagementDoc.ref, { 'actual_payment': FieldValue.increment(- actualPaymentDoc.get('amount')), 'status': 'open' });
                const dailyDataUpdateCost: { [key: string]: any } = {};
                dailyDataUpdateCost[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostManagement)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.partial`] = FieldValue.increment(-costManagementDoc.get('amount'));
                dailyDataUpdateCost[`data.${DateUtil.dateToShortStringDay(createdTimezoneCostManagement)}.cost_management.${costManagementDoc.get('type')}.${costManagementDoc.get('supplier')}.open`] = FieldValue.increment(costManagementDoc.get('amount'));
                transaction.update(hotelDoc.ref.collection('daily_data').doc(monthIDCostManagement), dailyDataUpdateCost);
            } else {
                transaction.update(costManagementDoc.ref, { 'actual_payment': FieldValue.increment(- actualPaymentDoc.get('amount')) });
            }
        }
        return MessageUtil.SUCCESS;
    })
    return resultTransaction;
});

exports.updateStatusActual = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelID: string = data.hotel_id;
    const costManagementID: string = data.cost_management_id;
    const actualPaymentID: string = data.actual_payment_id;
    const newStatus: string = data.status;

    if (newStatus !== 'open' && newStatus !== 'passed' && newStatus !== 'failed') {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.INVALID_STATUS);
    }

    const rolesAllowed = NeutronUtil.rolesCRUDCostManagement;
    const hotelRef = Firestore.collection('hotels').doc(hotelID);
    const hotelDoc = await hotelRef.get();
    if (hotelDoc.get('package') !== HotelPackage.pro) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.PLEASE_UPDATE_PACKAGE_HOTEL);
    }
    const timezone: string = hotelDoc.get('timezone');

    const uidOfUser: string = context.auth.uid;
    if (hotelDoc === undefined) {
        throw new functions.https.HttpsError('not-found', MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + uidOfUser);
    if (roleOfUser === undefined || roleOfUser.length === 0 || !roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const resultTransaction = await Firestore.runTransaction(async (transaction) => {

        const actualPaymentDoc = await transaction.get(hotelDoc.ref.collection('cost_management').doc(costManagementID).collection('actual_payment').doc(actualPaymentID));
        if (!actualPaymentDoc.exists) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.ACTUAL_PAYMENT_NOT_FOUND);
        };

        if (actualPaymentDoc.get('status') === newStatus) {
            throw new functions.https.HttpsError('cancelled', MessageUtil.SAME_STATUS_ACTUAL_PAYMENT);
        };

        transaction.update(actualPaymentDoc.ref, {
            'status': newStatus
        });

        const createdActualPaymentServer: Date = actualPaymentDoc.get('created').toDate();
        const createdActualPaymentTimezone: Date = DateUtil.convertUpSetTimezone(createdActualPaymentServer, timezone);
        const monthID: string = DateUtil.dateToShortStringYearMonth(createdActualPaymentTimezone);
        const dataUpdateDaily: { [key: string]: any } = {};
        dataUpdateDaily[`data.${DateUtil.dateToShortStringDay(createdActualPaymentTimezone)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${actualPaymentDoc.get('method')}.${actualPaymentDoc.get('status')}`] = FieldValue.increment(- actualPaymentDoc.get('amount'));
        dataUpdateDaily[`data.${DateUtil.dateToShortStringDay(createdActualPaymentTimezone)}.actual_payment.${actualPaymentDoc.get('type')}.${actualPaymentDoc.get('supplier')}.${actualPaymentDoc.get('method')}.${newStatus}`] = FieldValue.increment(actualPaymentDoc.get('amount'));
        transaction.update(hotelDoc.ref.collection('daily_data').doc(monthID), dataUpdateDaily);
        return MessageUtil.SUCCESS;
    });
    return resultTransaction;
});

exports.createAccountingType = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelId = data.hotel_id;
    const id = data.id;
    const name = data.name;

    const hotelRef = Firestore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const res = await Firestore.runTransaction(async (t) => {
        const accountingTypeInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();

        if (accountingTypeInCloud!['data']['accounting_type'] !== undefined) {
            const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(accountingTypeInCloud!['data']['accounting_type']));
            sourcesDataInCloud.forEach((value, key) => {
                if (key === id) {
                    throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
                }
                if (value['name'] === name) {
                    throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
                }
            });
        }

        t.update(hotelRef.collection('management').doc('configurations'), {
            ['data.' + 'accounting_type.' + id]: {
                'name': name,
                'active': true
            }
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.updateAccountingType = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelId = data.hotel_id;
    const id = data.id;
    const name = data.name;

    const hotelRef = Firestore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const res = await Firestore.runTransaction(async (t) => {

        const accountingTypeInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(accountingTypeInCloud!['data']['accounting_type']));

        sourcesDataInCloud.forEach((value, key) => {
            if (key === id && !value['active']) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.ACTIVE_IS_NOT_ACTIVATED_CAN_UPDATE)
            }
            if (value['name'] === name) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        })

        t.update(hotelRef.collection('management').doc('configurations'), {
            [`data.accounting_type.${id}.name`]: name
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});


exports.toggleAccountingTypeActivation = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    const hotelId = data.hotel_id;
    const id = data.id;

    const hotelRef = Firestore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const res = await Firestore.runTransaction(async (t) => {
        const accountingTypeInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('configurations'))).data();

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(accountingTypeInCloud!['data']['accounting_type']));

        const currentStatus = sourcesDataInCloud.get(id)['active'];

        t.update(hotelRef.collection('management').doc('configurations'), {
            [`data.accounting_type.${id}.active`]: !currentStatus
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

