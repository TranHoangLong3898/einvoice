export class HotelItem {
    public id: string;

    public warehouse: string;

    public isAutoExport: boolean;

    public constructor(id: string, warehouse: string, isAutoExport: boolean) {
        this.id = id;
        this.warehouse = warehouse;
        this.isAutoExport = isAutoExport;
    }
}

export class ItemInBooking {
    public id: string;

    public amount: number;

    public warehouse: string;

    public constructor(id: string, amount: number, warehouse: string) {
        this.id = id;
        this.amount = amount;
        this.warehouse = warehouse;
    }
}