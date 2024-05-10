import functions = require('firebase-functions');
import { WarehouseNoteType } from './constant/type';
import { DateUtil } from './util/dateutil';
import { MessageUtil } from './util/messageutil';
import { NeutronUtil } from './util/neutronutil';
import admin = require('firebase-admin');
import { InventoryCheckStatus } from './constant/status';
import { NumberUtil } from './util/numberutil';
import { HotelItem, ItemInBooking } from './model/item';

const fireStore = admin.firestore();
const fieldValue = admin.firestore.FieldValue;
// const fieldPath = admin.firestore.FieldPath;

exports.onCreateWarehouseNote = functions.firestore.document('hotels/{hotelId}/warehouse_notes/{warehouseNoteId}')
    .onCreate(async (doc, _) => {
        const hotelRef = doc.ref.parent.parent;
        if (hotelRef === undefined || hotelRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
        }
        const warehouseNoteRef = doc.ref;
        if (warehouseNoteRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOTE_NOT_FOUND);
        }

        const batch = fireStore.batch();
        const warehouseNoteData = doc.data();
        const type: string = warehouseNoteData['type'];
        const list: Map<string, any> = warehouseNoteData['list'] === undefined ? new Map() : new Map(Object.entries(warehouseNoteData['list']));
        const createdTime: Date = warehouseNoteData['created_time'].toDate();
        const monthId: string = DateUtil.dateToShortStringYearMonth(createdTime);
        const dayId = DateUtil.dateToShortStringDay(createdTime);

        if (type === WarehouseNoteType.import) {
            list.forEach((value, itemId) => {

                let itemTotalMoney: number = 0;
                let itemTotalAmount: number = 0;
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    itemTotalMoney += amount * price;
                    itemTotalAmount += amount;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    // Update amount of item to warehouse
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });

                });

                batch.set(hotelRef.collection('daily_data').doc(monthId), {
                    'data': {
                        [dayId]: {
                            'expense': {
                                [itemId]: {
                                    'total': fieldValue.increment(itemTotalMoney),
                                    'num': fieldValue.increment(itemTotalAmount)
                                }
                            }
                        }
                    }
                }, { merge: true });
            });
        } else if (type === WarehouseNoteType.export) {
            list.forEach((warehouseMap, itemId) => {
                new Map<string, number>(Object.entries(warehouseMap)).forEach((amount, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                });
            });
        } else if (type === WarehouseNoteType.lost) {
            list.forEach((warehouseMap, itemId) => {
                new Map<string, any>(Object.entries(warehouseMap)).forEach((data, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    new Map<string, any>(Object.entries(data)).forEach((amount, status) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.transfer) {
            list.forEach((value, itemId) => {
                new Map<string, number>(Object.entries(value)).forEach((value2, fromWarehouse) => {
                    new Map<string, number>(Object.entries(value2)).forEach((amount, toWarehouse) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${fromWarehouse}.items.${itemId}`]: fieldValue.increment(-amount),
                            [`data.${toWarehouse}.items.${itemId}`]: fieldValue.increment(amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.liquidation) {
            let totalMoney: number = 0;

            list.forEach((value, itemId) => {
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalMoney += amount * price;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                });
            });

            batch.set(hotelRef.collection('daily_data').doc(monthId), {
                'data': {
                    [dayId]: {
                        'revenue': {
                            [WarehouseNoteType.liquidation]: fieldValue.increment(totalMoney),
                            'total': fieldValue.increment(totalMoney)
                        }
                    }
                }
            }, { merge: true });
        } else if (type === WarehouseNoteType.returnToSupplier) {
            list.forEach((value, itemId) => {
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const warehouseId = map['warehouse'];
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    // Update amount of item to warehouse
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });

                });
            })
        }
        await batch.commit();

    });

exports.onUpdateWarehouseNote = functions.firestore.document('hotels/{hotelId}/warehouse_notes/{warehouseNoteId}')
    .onUpdate(async (doc, _) => {

        const hotelRef = doc.after.ref.parent.parent;
        if (hotelRef === undefined || hotelRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
        }
        const warehouseNoteRef = doc.after;
        if (warehouseNoteRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOTE_NOT_FOUND);
        }

        const afterData = doc.after.data();
        const beforeData = doc.before.data();
        const batch = fireStore.batch();
        const type = afterData['type'];
        const afterList: Map<string, any> = afterData['list'] === undefined ? new Map() : new Map(Object.entries(afterData['list']));
        const beforeList: Map<string, any> = beforeData['list'] === undefined ? new Map() : new Map(Object.entries(beforeData['list']));

        const createdTimeBefore = beforeData['created_time'].toDate();
        const monthIdBefore: string = DateUtil.dateToShortStringYearMonth(createdTimeBefore);
        const dayIdBefore = DateUtil.dateToShortStringDay(createdTimeBefore);

        const createdTimeAfter = afterData['created_time'].toDate();
        const monthIdAfter: string = DateUtil.dateToShortStringYearMonth(createdTimeAfter);
        const dayIdAfter = DateUtil.dateToShortStringDay(createdTimeAfter);

        if (type === WarehouseNoteType.import) {
            beforeList.forEach((value, itemId) => {
                let totalPriceBefore: number = 0;
                let totalAmountBefore: number = 0;
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalPriceBefore += amount * price;
                    totalAmountBefore += amount;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                    batch.update(hotelRef.collection('daily_data').doc(monthIdBefore), {
                        [`data.${dayIdBefore}.warehouse.${warehouseId}.${itemId}.import.num`]: fieldValue.increment(-amount),
                        [`data.${dayIdBefore}.warehouse.${warehouseId}.${itemId}.import.price`]: fieldValue.increment(-amount * price)
                    });
                });

                //update daily_data
                batch.update(hotelRef.collection('daily_data').doc(monthIdBefore), {
                    [`data.${dayIdBefore}.expense.${itemId}.total`]: fieldValue.increment(-totalPriceBefore),
                    [`data.${dayIdBefore}.expense.${itemId}.num`]: fieldValue.increment(-totalAmountBefore)
                });
            });
            afterList.forEach((value, itemId) => {
                let totalPriceAfter: number = 0;
                let totalAmountAfter: number = 0;
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalPriceAfter += amount * price;
                    totalAmountAfter += amount;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
                batch.set(hotelRef.collection('daily_data').doc(monthIdAfter), {
                    'data': {
                        [dayIdAfter]: {
                            'expense': {
                                [itemId]: {
                                    'total': fieldValue.increment(totalPriceAfter),
                                    'num': fieldValue.increment(totalAmountAfter)
                                }
                            }
                        }
                    }
                }, { merge: true });
            });
        } else if (type === WarehouseNoteType.export) {
            afterList.forEach((warehouseMap, itemId) => {
                new Map<string, number>(Object.entries(warehouseMap)).forEach((amount, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                });
            });
            beforeList.forEach((warehouseMap, itemId) => {
                new Map<string, number>(Object.entries(warehouseMap)).forEach((amount, warehouseId) => {
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
            });
        } else if (type === WarehouseNoteType.lost) {
            afterList.forEach((warehouseMap, itemId) => {
                new Map<string, any>(Object.entries(warehouseMap)).forEach((data, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    new Map<string, any>(Object.entries(data)).forEach((amount, status) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                        });
                    });
                });
            });
            beforeList.forEach((warehouseMap, itemId) => {
                new Map<string, any>(Object.entries(warehouseMap)).forEach((data, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    new Map<string, any>(Object.entries(data)).forEach((amount, status) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.transfer) {
            afterList.forEach((value, itemId) => {
                new Map<string, number>(Object.entries(value)).forEach((value2, fromWarehouse) => {
                    new Map<string, number>(Object.entries(value2)).forEach((amount, toWarehouse) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${fromWarehouse}.items.${itemId}`]: fieldValue.increment(-amount),
                            [`data.${toWarehouse}.items.${itemId}`]: fieldValue.increment(amount)
                        });
                    });
                });
            });
            beforeList.forEach((value, itemId) => {
                new Map<string, number>(Object.entries(value)).forEach((value2, fromWarehouse) => {
                    new Map<string, number>(Object.entries(value2)).forEach((amount, toWarehouse) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${fromWarehouse}.items.${itemId}`]: fieldValue.increment(amount),
                            [`data.${toWarehouse}.items.${itemId}`]: fieldValue.increment(-amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.liquidation) {
            let totalBefore: number = 0;
            let totalAfter: number = 0;
            //update warehouse
            afterList.forEach((value, itemId) => {
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalAfter += amount * price;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                });
            });
            beforeList.forEach((value, itemId) => {
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalBefore += amount * price;
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
            });
            batch.update(hotelRef.collection('daily_data').doc(monthIdBefore), {
                [`data.${dayIdBefore}.revenue.${WarehouseNoteType.liquidation}`]: fieldValue.increment(-totalBefore),
                [`data.${dayIdBefore}.revenue.total`]: fieldValue.increment(-totalBefore)
            });
            batch.set(hotelRef.collection('daily_data').doc(monthIdAfter), {
                'data': {
                    [dayIdAfter]: {
                        'revenue': {
                            [WarehouseNoteType.liquidation]: fieldValue.increment(totalAfter),
                            total: fieldValue.increment(totalAfter)
                        }
                    }
                }
            }, { merge: true });
        } else if (type === WarehouseNoteType.returnToSupplier) {
            //update warehouse
            afterList.forEach((value, itemId) => {
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const warehouseId = map['warehouse'];
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-parseFloat(amount.toFixed(6)))
                    });
                });
            });
            beforeList.forEach((value, itemId) => {
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const warehouseId = map['warehouse'];
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(parseFloat(amount.toFixed(6)))
                    });
                });
            });
        }
        await batch.commit();
    });

exports.onDeleteWarehouseNote = functions.firestore.document('hotels/{hotelId}/warehouse_notes/{warehouseNoteId}')
    .onDelete(async (doc, _) => {
        const hotelRef = doc.ref.parent.parent;
        if (hotelRef === undefined || hotelRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
        }
        const warehouseNoteRef = doc.ref;
        if (warehouseNoteRef === null) {
            throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOTE_NOT_FOUND);
        }
        const batch = fireStore.batch();
        const warehouseNoteData = doc.data();
        const type = warehouseNoteData['type'];
        const list: Map<string, any> = warehouseNoteData['list'] === undefined ? new Map() : new Map(Object.entries(warehouseNoteData['list']));

        const createdTime = warehouseNoteData['created_time'].toDate();
        const monthId: string = DateUtil.dateToShortStringYearMonth(createdTime);
        const dayId = DateUtil.dateToShortStringDay(createdTime);

        if (type === WarehouseNoteType.import) {
            list.forEach((value, itemId) => {
                let itemTotalMoney: number = 0;
                let itemTotalAmount: number = 0;
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    itemTotalMoney += amount * price;
                    itemTotalAmount += amount;

                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(-amount)
                    });
                });
                batch.update(hotelRef.collection('daily_data').doc(monthId), {
                    [`data.${dayId}.expense.${itemId}.total`]: fieldValue.increment(-itemTotalMoney),
                    [`data.${dayId}.expense.${itemId}.num`]: fieldValue.increment(-itemTotalAmount)
                });
            });

        } else if (type === WarehouseNoteType.export) {
            list.forEach((warehouseMap, itemId) => {
                new Map<string, number>(Object.entries(warehouseMap)).forEach((amount, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
            });
        } else if (type === WarehouseNoteType.lost) {
            list.forEach((warehouseMap, itemId) => {
                new Map<string, any>(Object.entries(warehouseMap)).forEach((data, warehouseId) => {
                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }

                    new Map<string, any>(Object.entries(data)).forEach((amount, status) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.transfer) {
            list.forEach((value, itemId) => {
                new Map<string, number>(Object.entries(value)).forEach((value2, fromWarehouse) => {
                    new Map<string, number>(Object.entries(value2)).forEach((amount, toWarehouse) => {
                        batch.update(hotelRef.collection('management').doc('warehouses'), {
                            [`data.${fromWarehouse}.items.${itemId}`]: fieldValue.increment(amount),
                            [`data.${toWarehouse}.items.${itemId}`]: fieldValue.increment(-amount)
                        });
                    });
                });
            });
        } else if (type === WarehouseNoteType.liquidation) {
            let totalMoney: number = 0;

            list.forEach((value, itemId) => {
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const price: number = map['price'];
                    const warehouseId = map['warehouse'];
                    totalMoney += amount * price;

                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
            });

            batch.update(hotelRef.collection('daily_data').doc(monthId), {
                [`data.${dayId}.revenue.${WarehouseNoteType.liquidation}`]: fieldValue.increment(-totalMoney),
                [`data.${dayId}.revenue.total`]: fieldValue.increment(-totalMoney)
            });
        } else if (type === WarehouseNoteType.returnToSupplier) {

            list.forEach((value, itemId) => {
                //value is array => In array, each element is a Map, contains amount, price, supplier, warehouse
                value.forEach((map: any) => {
                    const amount: number = map['amount'];
                    const warehouseId = map['warehouse'];

                    if (warehouseId === NeutronUtil.noneWarehouse) {
                        return;
                    }
                    batch.update(hotelRef.collection('management').doc('warehouses'), {
                        [`data.${warehouseId}.items.${itemId}`]: fieldValue.increment(amount)
                    });
                });
            });
        }
        await batch.commit();
    });

exports.createWarehouse = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }
    const warehouseId = data.warehouse_id ?? null;

    if (warehouseId === NeutronUtil.noneWarehouse) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
    }

    const hotelId = data.hotel_id;
    const warehouseName = data.warehouse_name ?? null;
    const permissionImport: string[] = data.permission_import;
    const permissionExport: string[] = data.permission_export;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouse;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const warehouseInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('warehouses'))).data();

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(warehouseInCloud!['data']));
        sourcesDataInCloud.forEach((value, key) => {
            if (key === warehouseId) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_ID)
            }
            if (value['name'] === warehouseName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        })
        const dataWarehouse: { [key: string]: any } = {
            'name': warehouseName,
            'active': true,
            'permission': {
                'import': permissionImport,
                'export': permissionExport
            }
        }
        t.update(hotelRef.collection('management').doc('warehouses'), { ['data.' + warehouseId]: dataWarehouse });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.updateWarehouse = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const warehouseId = data.warehouse_id ?? null;
    const warehouseName = data.warehouse_name ?? null;

    const hotelRef = fireStore.collection('hotels').doc(hotelId);
    const hotelDoc = await hotelRef.get();
    const permissionImport: string[] = data.permission_import;
    const permissionExport: string[] = data.permission_export;

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouse;
    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const warehouseInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('warehouses'))).data();

        if (warehouseInCloud!['data'][warehouseId] === undefined) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.WAREHOUSE_NOT_FOUND);
        }

        const sourcesDataInCloud: Map<String, any> = new Map(Object.entries(warehouseInCloud!['data']));
        sourcesDataInCloud.forEach((value, key) => {
            if (key !== warehouseId && value['name'] === warehouseName) {
                throw new functions.https.HttpsError('already-exists', MessageUtil.DUPLICATED_NAME)
            }
        })
        t.update(hotelRef.collection('management').doc('warehouses'), {
            ['data.' + warehouseId + '.name']: warehouseName,
            ['data.' + warehouseId + '.permission']: {
                'import': permissionImport,
                'export': permissionExport
            }
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.toggleWarehouseActivation = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === null || context.auth?.uid === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const warehouseId = data.warehouse_id ?? null;
    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouse;

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        throw new functions.https.HttpsError('permission-denied', MessageUtil.FORBIDDEN);
    }

    const res = await fireStore.runTransaction(async (t) => {
        const warehouseInCloud: { [key: string]: any } | undefined = (await t.get(hotelRef.collection('management').doc('warehouses'))).data();

        if (warehouseInCloud!['data'][warehouseId] === undefined) {
            throw new functions.https.HttpsError('already-exists', MessageUtil.WAREHOUSE_NOT_FOUND);
        }

        const currentStatus: boolean = warehouseInCloud!['data'][warehouseId]['active'];

        t.update(hotelRef.collection('management').doc('warehouses'), {
            ['data.' + warehouseId + '.active']: !currentStatus
        });
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.createWarehouseNote = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined || context.auth?.token === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const id = data.id;
    const creator = context.auth.token.email;
    const createdTime: Date = new Date(data.created_time);
    const type: string = data.type;
    const invoice: string = data.invoice;

    // checkWarehouse, note, status => just use for inventory checking.
    const checkWarehouse: string = data.warehouse;
    const note: string = data.note ?? '';
    const status: string = data.status;


    /** Just use for return to supplier note */
    const importInvoiceNumber = data.import_invoice_number;

    /** Just use for compensation */
    const returnInvoiceNumber = data.return_invoice_number;

    const isCompensation = returnInvoiceNumber != undefined;
    const list: Map<string, any> = data.list !== undefined ? new Map(Object.entries(data.list)) : new Map();

    if (list.size <= 0) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
    }

    if (creator === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.EMAIL_NOT_VERIFIED);
    }

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const noteDocsToCheck = await admin.firestore().collection('hotels').doc(hotelId).collection('warehouse_notes').where('invoice', '==', invoice).get();
    if (noteDocsToCheck.docs.length != 0) {
        throw new functions.https.HttpsError("not-found", MessageUtil.INVOICE_NUMBER_DUPLICATED);
    }

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const timezone: string = hotelDoc.get('timezone');
    const createdTimeInServer = DateUtil.convertOffSetTimezone(createdTime, timezone);
    const financialClosingDate = hotelDoc.get('financial_date');

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouseNote;

    if (financialClosingDate != undefined && financialClosingDate.toDate().getTime() - createdTimeInServer.getTime() > 0) {
        return MessageUtil.NOT_ALLOWED_TO_CREATE_BEFORE_THE_FINANCIAL_CLOSING_DATE;
    }

    const dataNote: { [key: string]: any } = {
        'created_time': createdTimeInServer,
        'creator': creator,
        'type': type,
        'invoice': invoice,
        'actual_created': new Date(),
    };

    if (type == WarehouseNoteType.inventoryCheck) {
        dataNote['note'] = note;
        dataNote['status'] = status;
        dataNote['warehouse'] = checkWarehouse;
    }

    if (type == WarehouseNoteType.import) {

        dataNote['total_cost'] = 0;
        if (isCompensation) {
            dataNote['return_invoice_number'] = returnInvoiceNumber;
        }
    }

    if (type == WarehouseNoteType.returnToSupplier && importInvoiceNumber != undefined) {
        dataNote['import_invoice_number'] = importInvoiceNumber;
    }

    const wareHouseIds: string[] = [];
    const wareHouseTransferExportIds: string[] = [];
    // let totalPrice: number = 0;
    switch (type) {
        case WarehouseNoteType.import:
            const returnNote = await hotelRef.collection('warehouse_notes').where('invoice', '==', returnInvoiceNumber ?? '').get();
            let importInvoiceNumberToCompensation: string = '';
            if (returnNote.empty && isCompensation) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_RETURN_NOTE);
            }
            if (!returnNote.empty) {
                importInvoiceNumberToCompensation = returnNote.docs[0].data()['import_invoice_number'];
            }
            const importNoteToCompensation = await hotelRef.collection('warehouse_notes').where('invoice', '==', importInvoiceNumberToCompensation ?? '').get();
            if (importNoteToCompensation.empty && isCompensation) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE);
            }

            if (list.size > 0) {
                const temp: { [key: string]: Array<any> } = {};
                list.forEach((value, itemId) => {
                    temp[itemId] = [];
                    value.forEach((map: any) => {
                        if (isCompensation) {
                            const importListToCompensation: { [key: string]: any } = importNoteToCompensation.docs[0].data()['list'];
                            const importItemToCompensation = (importListToCompensation[itemId] as [{ [key: string]: any }]).find(element => element['warehouse'] === map['warehouse']
                                && element['supplier'] === map['supplier']);
                            if (importItemToCompensation === undefined) {
                                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
                            }
                        }
                        temp[itemId].push(map);
                        // totalPrice += map['amount'] * map['price'];
                        if (wareHouseIds.indexOf(map['warehouse']) === -1) {
                            wareHouseIds.push(map['warehouse']);
                        }
                    });
                })
                dataNote['list'] = temp;
            }
            break;
        case WarehouseNoteType.liquidation:
            if (list.size > 0) {
                const temp: { [key: string]: Array<any> } = {};

                list.forEach((value, itemId) => {
                    temp[itemId] = [];
                    value.forEach((map: any) => {
                        temp[itemId].push(map);
                        if (wareHouseIds.indexOf(map['warehouse']) === -1) {
                            wareHouseIds.push(map['warehouse']);
                        }
                    });
                })
                dataNote['list'] = temp;
            }
            break;
        case WarehouseNoteType.export:
        case WarehouseNoteType.lost:
            if (list.size > 0) {
                const temp: { [key: string]: any } = {};
                list.forEach((value, key) => {
                    temp[key] = {};
                    const warehouseMap: Map<string, any> = new Map(Object.entries(value));
                    if (warehouseMap.size === 0) {
                        throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY);
                    }
                    warehouseMap.forEach((amount, warehouseId) => {
                        if (amount <= 0) {
                            throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE);
                        }
                        if (wareHouseIds.indexOf(warehouseId) === -1) {
                            wareHouseIds.push(warehouseId);
                        }
                        temp[key][warehouseId] = amount;
                    });
                })
                dataNote['list'] = temp;
            }
            break;
        case WarehouseNoteType.transfer:
            if (list.size > 0) {
                const temp: { [key: string]: any } = {};
                list.forEach((value, key) => {
                    temp[key] = {};
                    const warehouseMap: Map<string, any> = new Map(Object.entries(value));
                    if (warehouseMap.size === 0) {
                        throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY);
                    }
                    warehouseMap.forEach((amount, warehouseId) => {
                        if (amount <= 0) {
                            throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE);
                        }

                        if (wareHouseTransferExportIds.indexOf(warehouseId) === -1) {
                            wareHouseTransferExportIds.push(warehouseId)
                        }

                        if (wareHouseIds.indexOf(Object.keys(amount)[0]) === -1) {
                            wareHouseIds.push(Object.keys(amount)[0])
                        }

                        temp[key][warehouseId] = amount;
                    });
                })
                dataNote['list'] = temp;
            }
            break;
        case WarehouseNoteType.returnToSupplier:

            if (importInvoiceNumber === undefined) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
            }

            const importNote = await hotelRef.collection('warehouse_notes').where('invoice', '==', importInvoiceNumber).get();

            if (importNote.empty) {
                throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE);
            }
            const importList: { [key: string]: any } = importNote.docs[0].data()['list'];
            if (list.size > 0) {
                const temp: { [key: string]: Array<any> } = {};

                list.forEach((value, itemId) => {
                    temp[itemId] = [];
                    value.forEach((map: any) => {

                        const importItem = (importList[itemId] as [{ [key: string]: any }]).find(element => element['warehouse'] === map['warehouse']);

                        if (importItem === undefined) {
                            throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
                        }
                        if (map['amount'] > importItem['amount']) {
                            throw new functions.https.HttpsError("invalid-argument", MessageUtil.AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE);
                        }
                        temp[itemId].push(map);
                        if (wareHouseIds.indexOf(map['warehouse']) === -1) {
                            wareHouseIds.push(map['warehouse']);
                        }
                    });
                })
                dataNote['list'] = temp;
            }

            break;
        case WarehouseNoteType.inventoryCheck:
            const temp: { [key: string]: Array<any> } = {};
            list.forEach((value, itemId) => {
                temp[itemId] = value;
            })
            dataNote['list'] = temp;
            break;
        default:
            console.log(`Wrong type: ${type}`);
            throw new functions.https.HttpsError("not-found", MessageUtil.BAD_REQUEST);
    }

    if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
        const validateRoleWarehouse: { result: boolean, message: string } = await NeutronUtil.validateRoleInWareHouse(hotelDoc, context.auth.uid, wareHouseIds, wareHouseTransferExportIds, type);
        if (!validateRoleWarehouse.result) {
            return validateRoleWarehouse.message;
        }
    }

    await hotelRef.collection('warehouse_notes').doc(id).create(dataNote);
    return MessageUtil.SUCCESS;
});

exports.editWarehouseNote = functions.https.onCall(async (data, context) => {
    if (context.auth?.uid === undefined || context.auth?.token === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const id = data.note_id;
    const creator = context.auth.token.email;
    const createdTime: Date = new Date(data.created_time);
    const type = data.type;
    const invoice = data.invoice;
    const afterList: Map<string, any> = data.list !== undefined ? new Map(Object.entries(data.list)) : new Map();

    // checkWarehouse, note, status, checker => just use for inventory checking.
    const checkWarehouse: string = data.warehouse;
    const note: string = data.note ?? '';
    const status: string = data.status;

    const checker = context.auth.token.email;
    const isCreateNote: boolean = data.is_create_note;
    if (afterList.size <= 0) {
        throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
    }

    if (creator === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.EMAIL_NOT_VERIFIED);
    }

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    const noteDocsToCheck = await admin.firestore().collection('hotels').doc(hotelId).collection('warehouse_notes').where('invoice', '==', invoice).get();
    if (noteDocsToCheck.docs.length > 1 || (noteDocsToCheck.docs.length == 1 && noteDocsToCheck.docs[0].id != id)) {
        throw new functions.https.HttpsError("not-found", MessageUtil.INVOICE_NUMBER_DUPLICATED);
    }

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }
    const timezone: string = hotelDoc.get('timezone');

    const financialClosingDate = hotelDoc.get('financial_date');

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouseNote;
    const res = fireStore.runTransaction(async (t) => {
        const warehouseNoteRef = hotelRef.collection('warehouse_notes').doc(id);
        const warehouseNoteDoc = (await t.get(warehouseNoteRef)).data();
        if (warehouseNoteDoc === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOTE_NOT_FOUND);
        }

        const dataNote: { [key: string]: any } = {};
        dataNote['creator'] = creator;
        dataNote['created_time'] = DateUtil.convertOffSetTimezone(createdTime, timezone);;
        dataNote['invoice'] = invoice;
        if (type == WarehouseNoteType.inventoryCheck) {
            dataNote['note'] = note;
            dataNote['status'] = status;
            dataNote['warehouse'] = checkWarehouse;
            dataNote['checker'] = checker;
            dataNote['check_time'] = new Date();
            if (status === 'balanced') {
                dataNote['creator'] = warehouseNoteDoc['creator'];
            }
        }


        const oldYear: Date = warehouseNoteDoc['created_time'].toDate().getFullYear();
        const newYear: Date = dataNote['created_time'].getFullYear();

        if (oldYear !== newYear) {
            throw new functions.https.HttpsError("not-found", MessageUtil.CAN_NOT_CHANGE_THE_YEAR_OF_WAREHOUSE_NOTE);
        }

        const wareHouseImportIds: string[] = [];
        const wareHouseExportIds: string[] = [];
        /// just use for inventory checking 
        const noteDataToBalance: { [key: string]: any } = {};
        let warehouseData: { [key: string]: any } = {};
        switch (type) {
            case WarehouseNoteType.import:
                /** Just use for compensation */
                const returnInvoiceNumber = data.return_invoice_number;
                const isCompensation = returnInvoiceNumber != undefined;
                const returnNote = await hotelRef.collection('warehouse_notes').where('invoice', '==', returnInvoiceNumber ?? '').get();
                let importInvoiceNumberToCompensation: string = '';
                if (returnNote.empty && isCompensation) {
                    throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_RETURN_NOTE);
                }
                if (!returnNote.empty) {
                    importInvoiceNumberToCompensation = returnNote.docs[0].data()['import_invoice_number'];
                }
                const importNoteToCompensation = await hotelRef.collection('warehouse_notes').where('invoice', '==', importInvoiceNumberToCompensation ?? '').get();
                if (importNoteToCompensation.empty && isCompensation) {
                    throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE);
                }
                // let totalBefore = 0;
                // let tottalAfter = 0
                if (afterList.size > 0) {
                    const temp: { [key: string]: Array<any> } = {};
                    afterList.forEach((value, itemId) => {
                        temp[itemId] = [];
                        value.forEach((map: any) => {
                            if (isCompensation) {
                                const importListToCompensation: { [key: string]: any } = importNoteToCompensation.docs[0].data()['list'];
                                const importItemToCompensation = (importListToCompensation[itemId] as [{ [key: string]: any }]).find(element => element['warehouse'] === map['warehouse']
                                    && element['supplier'] === map['supplier']);
                                if (importItemToCompensation === undefined) {
                                    throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
                                }
                            }
                            temp[itemId].push(map);
                            // tottalAfter += map['amount'] * map['price'];
                            if (wareHouseImportIds.indexOf(map['warehouse']) === -1) {
                                wareHouseImportIds.push(map['warehouse']);
                            }
                        })

                    })

                    dataNote['list'] = temp;
                }

                const beforeList: Map<string, any> = warehouseNoteDoc['list'];
                for (const value of Object.values(beforeList)) {
                    value.forEach((map: any) => {
                        // totalBefore += map['amount'] * map['price'];
                    })
                }
                // update cost_management if that cost_management has invoice_num = invoice number of this note
                if (warehouseNoteDoc['invoice'] != invoice) {
                    const costManagementDocs = ((await t.get(hotelRef.collection('cost_management').where('invoice_num', '==', warehouseNoteDoc['invoice']))).docs);
                    costManagementDocs.forEach(doc => {
                        t.update(hotelRef.collection('cost_management').doc(doc.id), { 'invoice_num': invoice });
                    })
                }
                break;
            case WarehouseNoteType.liquidation:
                if (afterList.size > 0) {
                    const temp: { [key: string]: Array<any> } = {};
                    afterList.forEach((value, itemId) => {
                        temp[itemId] = [];
                        value.forEach((map: any) => {
                            temp[itemId].push(map);
                            if (wareHouseImportIds.indexOf(map['warehouse']) === -1) {
                                wareHouseImportIds.push(map['warehouse']);
                            }
                        })

                    })
                    dataNote['list'] = temp;
                }
                break;
            case WarehouseNoteType.export:
            case WarehouseNoteType.lost:
                if (afterList.size > 0) {
                    const temp: { [key: string]: any } = {};
                    afterList.forEach((value, key) => {
                        temp[key] = {};
                        const warehouseMap: Map<string, any> = new Map(Object.entries(value));
                        if (warehouseMap.size === 0) {
                            throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY);
                        }
                        warehouseMap.forEach((amount, warehouseId) => {
                            if (amount <= 0) {
                                throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE);
                            }

                            if (wareHouseExportIds.indexOf(warehouseId) === -1) {
                                wareHouseExportIds.push(warehouseId);
                            }
                            temp[key][warehouseId] = amount;
                        });
                    })
                    dataNote['list'] = temp;
                }
                break;
            case WarehouseNoteType.transfer:
                if (afterList.size > 0) {
                    const temp: { [key: string]: any } = {};
                    afterList.forEach((value, key) => {
                        temp[key] = {};
                        const warehouseMap: Map<string, any> = new Map(Object.entries(value));
                        if (warehouseMap.size === 0) {
                            throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY);
                        }
                        warehouseMap.forEach((amount, warehouseId) => {
                            if (amount <= 0) {
                                throw new functions.https.HttpsError('invalid-argument', MessageUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE);
                            }

                            if (wareHouseExportIds.indexOf(warehouseId) === -1) {
                                wareHouseExportIds.push(warehouseId)
                            }

                            if (wareHouseImportIds.indexOf(Object.keys(amount)[0]) === -1) {
                                wareHouseImportIds.push(Object.keys(amount)[0])
                            }
                            temp[key][warehouseId] = amount;
                        });
                    })
                    dataNote['list'] = temp;
                }
                break;
            case WarehouseNoteType.returnToSupplier:
                const importInvoiceNumber: string = data.import_invoice_number;

                if (importInvoiceNumber === undefined) {
                    throw new functions.https.HttpsError("invalid-argument", MessageUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE);
                }

                const importNote = await hotelRef.collection('warehouse_notes').where('invoice', '==', importInvoiceNumber).get();

                if (importNote.empty) {
                    throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
                }
                const importList: { [key: string]: any } = importNote.docs[0].data()['list'];
                if (afterList.size > 0) {
                    const temp: { [key: string]: Array<any> } = {};

                    afterList.forEach((value, itemId) => {
                        temp[itemId] = [];
                        value.forEach((map: any) => {
                            const importItem = (importList[itemId] as [{ [key: string]: any }]).find(element => element['warehouse'] === map['warehouse']);
                            if (importItem === undefined) {
                                throw new functions.https.HttpsError("invalid-argument", MessageUtil.BAD_REQUEST);
                            }
                            if (map['amount'] > importItem['amount']) {
                                throw new functions.https.HttpsError("invalid-argument", MessageUtil.AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE);
                            }
                            temp[itemId].push(map);
                            if (wareHouseExportIds.indexOf(map['warehouse']) === -1) {
                                wareHouseExportIds.push(map['warehouse']);
                            }
                        });
                    })
                    dataNote['list'] = temp;
                }
                break;
            case WarehouseNoteType.inventoryCheck:
                const temp: { [key: string]: Array<any> } = {};
                const warehouseDoc = (await t.get(hotelRef.collection('management').doc('warehouses'))).data();
                if (warehouseDoc === undefined) {
                    throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOT_FOUND);
                }
                warehouseData = warehouseDoc['data'];
                const items = warehouseData[checkWarehouse]['items'];

                afterList.forEach((value, itemId) => {
                    if (status === 'balanced') {
                        value['amount'] = items[itemId];
                    }
                    value['actual_amount'] = parseFloat((value['actual_amount']??0).toFixed(6));
                    temp[itemId] = value;
                })
                dataNote['list'] = temp;

                const now = new Date();


                const listImport: { [key: string]: Array<any> } = {};
                const listExport: { [key: string]: any } = {};
                afterList.forEach((value, itemId) => {
                    const difference: number = parseFloat((items[itemId] - (value['actual_amount'] ?? 0)).toFixed(6));
                    if (difference < 0) {
                        if (!wareHouseImportIds.includes(checkWarehouse)) {
                            wareHouseImportIds.push(checkWarehouse);
                        }
                        warehouseData[checkWarehouse]['items'][itemId] -= difference;
                        listImport[itemId] = [];
                        const tempMap: { [key: string]: any } = {
                            'amount': -difference,
                            'warehouse': checkWarehouse
                        }
                        if (isCreateNote) {
                            tempMap['price'] = value['price'];
                            tempMap['supplier'] = value['supplier'];
                        }
                        listImport[itemId].push(tempMap);
                    }
                    if (difference > 0) {
                        if (!wareHouseExportIds.includes(checkWarehouse)) {
                            wareHouseExportIds.push(checkWarehouse);
                        }
                        warehouseData[checkWarehouse]['items'][itemId] -= difference;

                        listExport[itemId] = { [`${checkWarehouse}`]: difference }
                    }
                })
                if (Object.keys(listImport).length != 0) {
                    noteDataToBalance['import'] = {
                        'created_time': now,
                        'creator': creator,
                        'type': isCreateNote ? WarehouseNoteType.import : WarehouseNoteType.importBalance,
                        'invoice': `BL_IP${invoice}`,
                        'actual_created': now,
                        'list': listImport,
                        'total_cost': 0
                    }
                }
                if (Object.keys(listExport).length != 0) {
                    noteDataToBalance['export'] = {
                        'created_time': now,
                        'creator': creator,
                        'type': isCreateNote ? WarehouseNoteType.export : WarehouseNoteType.exportBalance,
                        'invoice': `BL_EP${invoice}`,
                        'actual_created': now,
                        'list': listExport,
                    }
                }
                // }
                break;
            default:
                throw new functions.https.HttpsError("not-found", MessageUtil.BAD_REQUEST);
        }

        if (type != WarehouseNoteType.inventoryCheck && status === InventoryCheckStatus.balanced) {
            const checkAccountingPermissionResult = NeutronUtil.checkWarehouseModifyPermission(roleOfUser, context.auth?.token.email, financialClosingDate, warehouseNoteDoc);
            if (checkAccountingPermissionResult != MessageUtil.SUCCESS) {
                throw new functions.https.HttpsError('permission-denied', checkAccountingPermissionResult);
            }
        }

        if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
            const validateRoleWarehouse: { result: boolean, message: string } = await NeutronUtil.validateRoleInWareHouse(hotelDoc, context.auth!.uid, wareHouseImportIds, wareHouseExportIds, type);
            if (!validateRoleWarehouse.result) {
                return validateRoleWarehouse.message;
            }
        }

        if (type === WarehouseNoteType.inventoryCheck && status === InventoryCheckStatus.balanced) {
            if (noteDataToBalance['import'] != undefined) {
                const importNoteId = NumberUtil.getRandomID();
                t.create(hotelRef.collection('warehouse_notes').doc(importNoteId), noteDataToBalance['import']);
            }
            if (noteDataToBalance['export'] != undefined) {
                const exportNoteId = NumberUtil.getRandomID();
                t.create(hotelRef.collection('warehouse_notes').doc(exportNoteId), noteDataToBalance['export']);
            }
            if (!isCreateNote) {
                t.update(hotelRef.collection('management').doc('warehouses'), {
                    [`data.${checkWarehouse}.items`]: warehouseData[checkWarehouse]['items']
                })
            }
        }

        t.update(warehouseNoteRef, dataNote);
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.deleteWarehouseNote = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', MessageUtil.UNAUTHORIZED);

    if (context.auth.token.email === undefined) {
        throw new functions.https.HttpsError("unauthenticated", MessageUtil.UNAUTHORIZED);
    }

    const hotelId = data.hotel_id;
    const docId = data.id;

    const hotelRef = admin.firestore().collection('hotels').doc(hotelId);
    const hotelDoc = (await hotelRef.get());

    if (!hotelDoc.exists) {
        throw new functions.https.HttpsError("not-found", MessageUtil.HOTEL_NOT_FOUND);
    }

    const roleOfUser: string[] = hotelDoc.get('role.' + context.auth.uid);
    //list of roles which can execute this function
    const rolesAllowed = NeutronUtil.rolesCRUDWarehouseNote;
    const financialClosingDate = hotelDoc.get('financial_date');
    const wareHouseIds: string[] = [];
    const wareHouseTransferExportIds: string[] = [];
    const res = fireStore.runTransaction(async (t) => {
        const warehouseNoteRef = hotelRef.collection('warehouse_notes').doc(docId);
        const warehouseNoteDoc = (await t.get(warehouseNoteRef)).data();
        if (warehouseNoteDoc === undefined) {
            throw new functions.https.HttpsError("not-found", MessageUtil.WAREHOUSE_NOTE_NOT_FOUND);
        }

        const list: Map<string, any> = warehouseNoteDoc['list'];
        // let total = 0;
        switch (warehouseNoteDoc['type']) {
            case WarehouseNoteType.import:
                for (const value of Object.values(list)) {
                    value.forEach((map: any) => {
                        // total += map['amount'] * map['price'];
                        if (wareHouseIds.indexOf(map['warehouse']) === -1) {
                            wareHouseIds.push(map['warehouse']);
                        }
                    })
                }
                break;
            case WarehouseNoteType.liquidation:
                for (const value of Object.values(list)) {
                    value.forEach((map: any) => {
                        if (wareHouseIds.indexOf(map['warehouse']) === -1) {
                            wareHouseIds.push(map['warehouse']);
                        }
                    })
                }
                break;
            case WarehouseNoteType.export:
            case WarehouseNoteType.returnToSupplier:
            case WarehouseNoteType.lost:
                Object.values(list).forEach(listData => {
                    for (const warehouse of Object.keys(listData)) {
                        if (!wareHouseIds.includes(warehouse)) {
                            wareHouseIds.push(warehouse);
                        }
                    }
                })
                break;
            case WarehouseNoteType.transfer:
                Object.values(list).forEach(listData => {
                    for (const [fromWarehouse, map] of Object.entries(listData)) {
                        if (!wareHouseIds.includes(fromWarehouse)) {
                            wareHouseIds.push(fromWarehouse);
                        }
                        for (const toWarehouse of Object.keys(map as Map<string, any>)) {
                            if (!wareHouseIds.includes(toWarehouse)) {
                                wareHouseIds.push(toWarehouse);
                            }
                        }
                    }
                })
                break;
        }

        if (!roleOfUser.some((role) => rolesAllowed.includes(role))) {
            const validateRoleWarehouse: { result: boolean, message: string } = await NeutronUtil.validateRoleInWareHouse(hotelDoc, context.auth!.uid, wareHouseIds, wareHouseTransferExportIds, warehouseNoteDoc['type']);

            if (!validateRoleWarehouse.result) {
                throw new functions.https.HttpsError('permission-denied', validateRoleWarehouse.message);
            }
        }
        const checkAccountingPermissionResult = NeutronUtil.checkWarehouseModifyPermission(roleOfUser, context.auth?.token.email, financialClosingDate, warehouseNoteDoc);
        if (checkAccountingPermissionResult != MessageUtil.SUCCESS) {
            throw new functions.https.HttpsError('permission-denied', checkAccountingPermissionResult);
        }
        // update cost_management if that cost_management has invoice_num = invoice number of this note
        if (warehouseNoteDoc['type'] === WarehouseNoteType.import) {
            const costManagementDocs = ((await t.get(hotelRef.collection('cost_management').where('invoice_num', '==', warehouseNoteDoc['invoice']))).docs);
            costManagementDocs.forEach(doc => {
                t.update(hotelRef.collection('cost_management').doc(doc.id), { 'invoice_num': fieldValue.delete() });
            })
        }
        t.delete(warehouseNoteRef);
        return MessageUtil.SUCCESS;
    });
    return res;
});

exports.autoExportItemsByBookingService = functions.pubsub
    .schedule('0 * * * *').onRun(async (context) => {
        const now: Date = new Date();
        now.setSeconds(0, 0);

        const hour: number = now.getHours() > 12 ? 24 - now.getHours() : - now.getHours();
        const timezones: string[] = DateUtil.getTimeZonesByHour(hour);

        let batch = fireStore.batch();
        const batchs: FirebaseFirestore.WriteBatch[] = [];
        let count: number = 0;


        // const hotelDocs =  await fireStore.collection('hotels').where('auto_export_items', 'in', ['2', '1']).get();
        const hotelDocs = await fireStore.collection('hotels').where('timezone', 'in', timezones).where('auto_export_items', 'in', ['2', '1']).get();
        for (const hotel of hotelDocs.docs) {
            console.log(hotel.get('name'));
            const hotelAutoExportItemStatus: string = hotel.get('auto_export_items');
            const hotelTimezone: string = hotel.get('timezone');
            console.log('now -- ', now);
            let nowServer: Date = DateUtil.convertUpSetTimezone(now, hotelTimezone);
            console.log(nowServer);

            // get item in hotel
            const hotelItems: HotelItem[] = [];
            const itemsInHotel: { [key: string]: { [key: string]: any } } = (await fireStore.collection('hotels').doc(hotel.id).collection('management').doc('items').get()).get('data');
            for (const itemInHotelMap of Object.keys(itemsInHotel)) {
                hotelItems.push(new HotelItem(itemInHotelMap, itemsInHotel[itemInHotelMap]['warehouse'], itemsInHotel[itemInHotelMap]['auto_export'] ?? false));
            }

            // get bookings that check out in 1 day
            const bookingDocs = await fireStore.collection('hotels').doc(hotel.id).collection('bookings').where('status', '==', 2).where('out_time', '<', nowServer).where('out_time', '>=', DateUtil.addDate(nowServer, -1)).get();
            const itemInBooking: ItemInBooking[] = [];
            for (const booking of bookingDocs.docs) {
                console.log(booking.get('sid'));

                const serviceDocs = await fireStore.collection('hotels').doc(hotel.id).collection('bookings').doc(booking.id).collection('services').get();
                for (const service of serviceDocs.docs) {
                    const serviceItems: { [key: string]: { [key: string]: any } } = service.get('items');
                    if (serviceItems != undefined) {
                        for (const serviceItemId of Object.keys(serviceItems)) {
                            const item = hotelItems.find(element => element.id == serviceItemId);
                            if (hotelAutoExportItemStatus == '1' || (hotelAutoExportItemStatus == '2' && item?.isAutoExport)) {
                                const currentItemInBooking = itemInBooking.find(element => element.id == serviceItemId && element.warehouse == item?.warehouse);
                                if (currentItemInBooking == undefined) {
                                    itemInBooking.push(new ItemInBooking(serviceItemId, serviceItems[serviceItemId]['amount'], item?.warehouse ?? ''))
                                } else {
                                    currentItemInBooking.amount += serviceItems[serviceItemId]['amount'];
                                }
                            }

                        }
                    }
                }
            }

            if (itemInBooking.length != 0) {
                const listDataToCreateNote: { [key: string]: any } = {};
                for (const item of itemInBooking) {
                    if (listDataToCreateNote[item.id] == undefined) {
                        listDataToCreateNote[item.id] = {};
                    }
                    listDataToCreateNote[item.id][item.warehouse] = item.amount;
                }

                const dataNote: { [key: string]: any } = {
                    'created_time': now,
                    'creator': 'auto',
                    'type': 'export',
                    'invoice': `auto-${DateUtil.dateToShortString(DateUtil.addDate(nowServer, -1))}`,
                    'actual_created': now,
                    'list': listDataToCreateNote
                };

                if (count < 500) {
                    count++;
                    batch.create(fireStore.collection('hotels').doc(hotel.id).collection('warehouse_notes').doc(NumberUtil.getRandomID()), dataNote);
                    batchs.push(batch);
                } else {
                    batch = fireStore.batch();
                    batchs.push(batch);
                    batch.create(fireStore.collection('hotels').doc(hotel.id).collection('warehouse_notes').doc(NumberUtil.getRandomID()), dataNote);
                    count = 1;
                }
            }
        }

        for (const b of batchs) {
            await b.commit();
        }
    })