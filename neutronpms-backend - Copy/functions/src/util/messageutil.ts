export class MessageUtil {
    static SUCCESS = '';
    static FAIL = 'failed';
    static UNDEFINED_ERROR = 'undefined-error';
    static UNAUTHORIZED = 'unauthorized';
    static FORBIDDEN = 'forbidden';
    static DUPLICATED_ID = 'duplicated-id';
    static DUPLICATED_NAME = 'duplicated-name';
    static DUPLICATED_NAME_AND_UNIT = 'duplicated-name-and-unit';
    static DUPLICATED_MAPPING_SOURCE = 'duplicated-mapping-source';
    static BAD_REQUEST = 'bad-request';
    static STILL_NOT_CHANGE_VALUE = 'still-not-change-value';
    static CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER = 'textalert-can-not-deactive-default-supplier';
    static CAN_NOT_AUTHORIZE_BY_YOURSELF = 'can-not-authorize-by-yourself';
    static ACTIVE_IS_NOT_ACTIVATED_CAN_UPDATE = 'active-is-not-activated-can-update';
    static ACTIVE_ALREADY_IN_AN_INACTIVE_STATE = 'active-already-in-an-inactive-state';

    static CONFIGURATION_NOT_FOUND = 'configuration-not-found';

    static NOT_SAME_LENGTH_PRICE_STAYSDAY = 'not-same-length-price-staysday';
    static CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN = 'cant-not-add-update-booking-local-with-ota-rate-plan';

    static CAN_NOT_UPDATE_RATE_PLAN_BOOKING_GROUP = 'can-not-update-rate-plan-booking-group';
    static CAN_NOT_UPDATE_DATE_IN_OUT_WITH_BOOKING_FROM_OTA = 'can-not-update-date-in-out-with-booking-from-ota';
    static EMAIL_NOT_FOUND = 'email-not-found';
    static EMAIL_DUPLICATED = 'email-duplicated';
    static NATIONAL_ID_DUPLICATED = 'national-id-duplicated';
    static EMAIL_REGISTED = 'email-registed';
    static UNAUTHENTICATED_USER = 'unauthenticated-user';
    static CAN_NOT_REMOVE_YOURSELFT = 'can-not-remove-yourself';

    static ITEMTYPE_NOT_FOUND = 'itemtype-not-found';

    static HOTEL_NOT_FOUND = 'hotel-not-found';
    static NOT_CONNECTED_TO_E_INVOICE_SOFTWARE = 'not-connected-to-electronic-invoice-software';
    static PLEASE_UPDATE_PACKAGE_HOTEL = 'please-update-package-hotel';
    static PLEASE_CHOOSE_RIGHT_COUNTRY =
        'please-choose-right-country';
    static HOTEL_CAN_NOT_EDIT_INFO = 'hotel-can-not-edit-info';

    static BOOKING_ALREADY_EXIST_OTA = 'already-exist-ota-in-booking';
    static BOOKING_CHECKOUT_BEFORE = 'booking-checkout-before';
    static BOOKING_NOT_CHECKOUT = 'booking-not-checkout';
    static BOOKING_CAN_NOT_EDIT_RATE_PLAN = 'booking-can-not-edit-rate-plan';
    static BOOKING_WAS_CHECKIN_CANNOT_SET_NONE_ROOM = 'booking-was-checkin-cannot-set-none-room';
    static BOOKING_CAN_NOT_EDIT_PRICE_OF_CHECKED_IN_BOOKING = 'booking-can-not-price-of-checked-in-booking';
    static BOOKING_CAN_NOT_UNDO_CHECKOUT_AFTER_24HOURS = 'booking-can-not-undo-check-out-after-24hours';
    static BOOKING_CAN_NOT_UNDO_CHECKOUT_BECAUSE_CONFLIX_ROOM = 'booking-can-not-undo-checkout-because-conflix-room';
    static BOOKING_CHECKIN_CAN_NOT_MODIFY_INDAY = 'booking-checkin-can-not-modify-inday';
    static BOOKING_HAS_DEPOSIT_OR_SERVICE = 'booking-has-deposit-or-service';
    static BOOKING_FROM_OTA_CAN_NOT_EDIT = 'booking-from-ota-can-not-edit';
    static BOOKING_NOT_CHECKIN = 'booking-not-checkin';
    static BOOKING_WAS_BOOKED = 'booking-was-booked';
    static BOOKING_NOT_FOUND = 'booking-not-found';
    static BOOKING_NOT_IN_BOOKED_STATUS = 'booking-not-in-booked-status';
    static BOOKING_NOT_TODAY_BOOKING = 'booking-not-today-booking';
    static BOOKING_NOT_REPAIR = 'booking-not-repair';
    static BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT = 'booking-must-pay-remaining-before-checkout';
    static BOOKING_MUST_CHECKOUT_BIKES = 'booking-must-checkout-bikes';
    static BOOKING_RENTING_BIKES = 'booking-renting-bikes';
    static BOOKING_OVER_TIME_CHECKOUT = 'booking-over-time-checkout';
    static BOOKING_OVER_TIME_UNDO_CHECKOUT = 'booking-over-time-undo-checkout';
    static BOOKING_OVER_TIME_UNDO_CHECKIN = 'booking-over-time-undo-checkin';
    static BOOKING_VIRTUAL_DUPLICATED = 'booking-virtual=duplicated';
    static BOOKING_WAS_CHECKEDIN = 'booking-was-checkedin';
    static BOOKING_WAS_UNDO_CHECKOUT = 'booking-was-undo-checkout';
    static BOOKING_WAS_CANCELLED_OR_CHECKED_OUT = 'booking-was-cancelled-or-checked-out';
    static BOOKING_WRONG_TRANSFERRED = 'booking-wrong-transferred';
    static BOOKING_GROUP_CANNOT_TRANSFERRED = 'booking-group-cannot-transferred';
    static BOOKING_GROUP_CANNOT_CHANGE_RATE_PLAN = 'booking-group-cannot-change-rate-plan';
    static BOOKING_GROUP_CANNOT_CHANGE_SID = 'booking-group-cannot-change-sid';
    static BOOKING_ALREADY_SET_NONE_ROOM = 'booking-already-set-none-room';
    static SET_NONE_ROOM_CAN_NOT_EDIT_INFORMATION = 'set-none-room-can-not-edit-information';

    static PAYMENT_NOT_FOUND = 'payment-not-found';
    static PAYMENT_WAS_DELETE = 'payment-was-delete';
    static PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED = 'payment-transfer-id-or-bid-undefined';
    static YOU_DO_NOT_UPDATE_OTHER_PEOPLE_PAYMENT = 'You-do-not-update-other-people-payemet'
    static YOU_DO_NOT_DELETE_OTHER_PEOPLE_PAYMENT = 'You-do-not-delete-other-people-payemet'
    static YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED = 'You-do-not-delete-payemet-status-passed'

    static ROOM_NOT_FOUND = 'room-not-found';
    static ROOM_ALREADY_HAVE_BOOKING_PLEASE_CHOOSE_ANOTHER_ROOM = 'room-already-have-booking-please-choose-another-room';
    static PLEASE_SELECT_THE_CORRECR_ROOM_TO_UPDATE = 'please-select-the-correct-room-to-update';

    static ROOM_TYPE_OF_ROOM_CANNOT_EDIT = 'room-type-of-room-cannot-edit';
    static ROOM_NAME_DUPICATED = 'room-name-duplicated';
    static ROOM_STILL_NOT_CHECKOUT = 'room-still-not-checkout';
    static ROOM_MUST_CLEAN = 'room-must-clean';
    static ROOM_ID_DUPLICATED = 'room-id-duplicated';
    static ROOM_NAME_DUPLICATED = 'room-name-duplicated';
    static ROOM_HAS_BOOKING_CHECKIN = 'room-has-booking-checkin';
    static ROOM_WAS_DELETE = 'room-was-delete';
    static ROOM_HAVE_BOOKING_PLEASE_MOVE_BOOKING_BEFORE_DELETE_ROOM = 'room-have-booking-please-move-booking-before-delete-room';

    static ROOMTYPE_ID_DUPICATED = 'roomtype-id-duplicated';
    static ROOMTYPE_NAME_DUPICATED = 'roomtype-name-duplicated';
    static ROOMTYPE_NOT_FOUND = 'roomtype-not-found';
    static ROOMTYPE_MUST_CHOOSE_BED = 'roomtype-must-choose-bed';
    static ROOMTYPE_MUST_DELETE_ALL_ROOM = 'roomtype-must-delete-all-room';
    static ROOMTYPE_MIN_PRICE = 'minprice-must-bigger-than-price';
    static ROOMTYPE_DONT_HAVE_ENOUGH_QUATITY = 'roomtype-dont-have-enough-quatity';

    static RATE_PLAN_NOT_FOUND = 'rateplan-not-found';
    static RATE_PLAN_DUPLICATED = 'rateplan-duplicated';
    static THIS_RATE_PLAN_CANNOT_BE_EDITED = 'this-rate-plan-cannot-be-edited';
    static RATE_PLAN_WAS_DELETED = 'rateplan-was-deleted';
    static CAN_NOT_DEACTIVE_DEFAULT_RATE_PLAN = 'can-not-deactive-default-rateplan';

    static CM_NOT_MAP_HOTEL = 'cm-not-map-hotel';
    static CM_NOT_MAP_ROOMTYPE = 'cm-not-map-roomtype';
    static CM_UPDATE_AVAIBILITY_FAIL = 'cm-update-avaibility-fail';
    static CM_UPDATE_AVAIBILITY_RATE_FAIL = 'cm-update-avaibility-rate-fail';
    static CM_UPDATE_INVENTORY_FAIL = 'cm-update-inventory-fail';
    static CM_GET_BOOKINGS_FAIL = 'cm-get-bookings-fail';
    static CM_HOTEL_EMPTY = 'cm-hotel-empty';
    static CM_BOOKING_EMPTY = 'cm-booking-empty';
    static CM_MAXIMUM_DATE_RANGE = 'cm-maximum-date-range';
    static CM_SYNC_FAIL = 'cm-sync-fail';

    static SERVICE_NOT_FOUND = 'service-not-found';
    static INPUT_TYPE_OF_BED = 'input-type-of-bed';

    static OVER_MAX_LENGTHDAY_31 = 'over-max-lengthday-31';
    static OVER_MAX_LENGTHDAY_365 = 'over-max-lengthday-365';
    static CAM_NOT_CHAGE_BOOKING_TYPE = "can-not-change-booking-type";
    static INDATE_MUST_NOT_IN_PAST = 'indate-must-not-in-past';
    static INPUT_NAME = 'input-name';
    static INPUT_PHONE = 'input-phone';
    static INPUT_PRICE = 'input-price';
    static INPUT_POSITIVE_PRICE = 'input-positive-price';
    static INPUT_ADULT_AND_CHILD = 'input-adult-and-child';
    static THIS_ROOM_NOT_AVAILABLE = 'this-room-not-available';
    static JUST_FOR_CHECKIN_OR_REPAIR_BOOKING = 'just-for-checkin-or-repair-booking';
    static MIN_PRICE_MUST_SMALLER_THAN_PRICE = 'min-price-must-smaller-than-price';

    static NEED_TO_ADD_USER_TO_HOTEL_FIRST = 'need-to-add-user-to-hotel-first';
    static NEED_TO_CHOOSE_ATLEAST_ONE_SERVICE = 'need-to-choose-atleast-one-service';

    static DISCOUNT_NOT_FOUND = 'discount-not-found';
    static DISCOUNT_DUPLICATED_DESC = 'discount-duplicated-desc';
    static PRICE_MUST_BIGGER_THAN_MIN_PRICE = 'price-must-bigger-than-min-price';
    static NUM_MUST_SMALLER_THAN_MAX_ROOMTYPE = 'num-must-smaller-than-max-roomtype';
    static NAME_PAYMENT_DUPLICATED = 'name-payment-duplicated';
    static ID_PAYMENT_DUPLICATED = 'id-payment-duplicated';

    static BIKE_RENTAL_NOT_FOUND = 'bike-rental-not-found';
    static BIKE_RENTAL_CAN_NOT_EDIT = 'can-not-edit-bike-rental';
    static BIKE_RENTAL_CAN_NOT_DEACTIVE = 'bike-rental-can-not-deactive';
    static BIKE_WAS_CHECKED_IN = 'bike-was-checked-in';
    static BIKE_WAS_CHECKED_OUT = 'bike-was-checked-out';
    static BIKE_WAS_RENTED = 'bike-was-rented';

    static CAN_NOT_CANCEL_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT = 'can-not-cancel-booking-when-group-have-booking-out';
    static CAN_NOT_NO_SHOW_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT = 'can-not-no-show-booking-when-group-have-booking-out';
    static WAREHOUSE_NOT_FOUND = 'warehouse-not-found';
    static WAREHOUSE_NOTE_NOT_FOUND = 'warehouse-note-not-found';
    static EMAIL_NOT_VERIFIED = 'email-not-verified';
    static WAREHOUSE_CAN_NOT_BE_EMPTY = 'textalert-warehouse-can-not-be-empty';
    static AMOUNT_MUST_BE_POSITIVE = 'textalert-amount-must-be-positive';

    static ITEM_NOT_FOUND = 'item-not-found';
    static DUPLICATE_NAME_AND_UNIT = 'duplicated-name-and-unit';

    // restaurant
    static PLEASE_LOGIN_HOTEL_TO_ACCEPT_REQUEST = 'please-login-hotel-to-accept-request-for-connect-successful';
    static HAVE_MANY_HOTEL_HAVE_THIS_NAME = 'have-many-hotel-have-this-name-or-empty-hotel';
    static PLEASE_WAIT_TO_HOTEL_ACCEPT_CONNECT = 'please-wait-to-hotel-accept-connect';
    static RESTAURANT_NOT_FOUND = 'restaurant-not-found';
    static WAS_ACCEPT_LINKED = 'was-accpet-linked';
    static NOT_ALLOWED_TO_CREATE_BEFORE_THE_FINANCIAL_CLOSING_DATE =
        'not-allowed-to-create-before-the-financial-closing-date';

    // revenue
    static REVENUE_DOC_NOT_FOUND = 'revenue-doc-not-found';
    static INVALID_TYPE_REVENUE_LOG = 'invalid-type-revenue-log';
    static REVENUE_MANAGEMENT_NOT_FOUND = 'revenue-management-not-found';


    // cost_management
    static COST_MANAGEMENT_NOT_FOUND = 'cost-management-not-found';
    static TYPE_COST_NOT_FOUND = 'type-not-found';
    static SUPPLIER_NOT_FOUND = 'supplier-not-found';
    static ACTUAL_PAYMENT_NOT_FOUND = 'actual-payment-not-found';
    static SAME_STATUS_ACTUAL_PAYMENT = 'same-status-actual-payment';
    static AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST = 'amount-can-not-less-than-actual-payment-please-delete-actual-payment-first';

    static METHOD_PAYMENT_NOT_FOUND = 'method-payment-not-found';
    static MUST_DELETE_ACTUAL_PAYMENT_COLLECTION = 'must-delete-actual-payment-collection';
    static MUST_CONFIGURE_ACCOUNTING_TYPE_FIRST = 'must-configure-accounting-type-first';
    static INVALID_STATUS = 'invalid-status';
    static OTA_RATE_PLAN_CANNOT_BE_SET_DEFAULT = 'ota-rate-plan-cannot-be-set-default';
    static CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE = 'cannot-create-and-edit-or-delete-before-the-financial-settlement-date';

    static HOTELS_USING_THIS_THIS_PACKAGE_CANNOT_BE_DELETED = 'hotels-using-this-package-cannot-be-deleted'
    static THE_PACKAGE_IS_STILL_EXPIRED = 'the-package-is-still-expired';

    // warehouse
    static INVOICE_NUMBER_DUPLICATED = 'invoice-number-duplicated';
    static CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE = 'cannot-find-the-corresponding-warehouse-import-note';
    static CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_RETURN_NOTE = 'cannot-find-the-corresponding-warehouse-return-note';
    static TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY = 'textalert-warehouse-can-not-be-empty';
    static TEXTALERT_AMOUNT_MUST_BE_POSITIVE = 'textalert-amount-must-be-positive';
    static AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE = 'textalert-amount-can-not-more-than-amount-in-import-note';
    static NO_PERMISSION_FOR_IMPORT_WAREHOUSE = 'no-permission-for-import-warehouse';
    static NO_PERMISSION_FOR_EXPORT_LOST_LIQUIDATION_WAREHOUSE = 'no-permission-for-export-lost-liquidation-warehouse';
    static CAN_NOT_CHANGE_THE_YEAR_OF_WAREHOUSE_NOTE = 'can-not-change-the-year-of-warehouse-note';
    static NOT_ALLOWED_TO_BE_MODIFIED_PRIOR_TO_THE_FINANCIAL_CLOSING_DATE =
        'not-allowed-to-be-modified-prior-to-the-financial-closing-date';
    static ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS =
        'only-allowed-to-edit-within-45-days';
    static ONLY_ALLOWED_TO_MODIFY_WITHIN_24H =
        'only-allowed-to-edit-within-24-hours';
    static CAN_NOT_FIND_INVOICE_NUMBER = 'can-not-find-invoice-number';
    static CAN_NOT_FOUND_INVOICE = 'can-not-found-invoice';

}