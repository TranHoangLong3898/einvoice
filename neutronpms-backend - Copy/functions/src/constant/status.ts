export class BookingStatus {
    static unconfirmed = 5;
    static checkin = 1;
    static checkout = 2;
    static booked = 0;
    static cancel = -1;
    static repair = 3;
    static moved = 4;
    static noshow = -2;
}

export class BikeRentalProgress {
    static checkin = 1;
    static checkout = 2;
    static booked = 0;
}

export class PaymentStatus {
    static done = 2;
    static partial = 1;
    static unpaid = 0;
}

export class InventoryCheckStatus{
    static checking: String = 'checking';
    static balanced: String = 'balanced';
}