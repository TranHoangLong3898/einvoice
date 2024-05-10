export class ServiceCategory {
    static minibarCat = 'minibar';
    static restaurantCat = 'restaurant';
    static insideRestaurantCat = 'inside_restaurant';
    static extraGuestCat = 'extra_guest';
    static extraHourCat = 'extra_hour';
    static laundryCat = 'laundry';
    static bikeRentalCat = 'bike_rental';
    static otherCat = 'other';
    static extraServiceCat = 'extra_service';
    static extraBedCat = 'extra_bed';
    static electricityWaterCat = 'electricity_water';
}

export class WarehouseNoteType {
    static import: string = "import";
    static export: string = "export";
    static transfer: string = "transfer";
    static lost: string = "lost";
    static liquidation: string = "liquidation";
    static returnToSupplier: string = "return";
    static inventoryCheck: string = "inventory_check";
    static importBalance: string = "import_balance";
    static exportBalance: string = "export_balance";
}

export class ItemType {
    static minibar: string = "minibar";
    static restaurant: string = "restaurant";
    static other: string = "other";
}

export class RevenueLogType {
    static typeAdd: number = 1;
    static typeMinus: number = 2;
    static typeTransfer: number = 3;
    static typeActualPayment: number = 4;
}

export class HotelPackage {
    static basic = "basic";
    static advanced = "adv";
    static pro = "pro";
}

export class CostType {
    static accounting: number = 0;
    static booked: number = 1;
    static room: number = 2;
}

export class BookingType {
    static dayly: number = 0;
    static monthly: number = 1;
    static hourly: number = 2;
}
