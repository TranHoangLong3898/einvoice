import 'package:ihotel/manager/generalmanager.dart';
import 'package:sprintf/sprintf.dart';

class MessageCodeUtil {
  MessageCodeUtil._();

  static const String ALL = 'all';
  static const String NO = 'no';
  static const String IN_PROGRESS = 'in-progress';
  static const String SUCCESS = '';
  static const String FAILED = 'failed';
  static const String UNAUTHORIZED = 'unauthorized';
  static const String USER_NOT_BE_AUTHORIZED = 'user-not-be-authorized';
  static const String INTERNAL = 'internal';
  static const String FORBIDDEN = 'forbidden';
  static const String DEADLINE_EXCEEDED = 'deadline-exceeded';
  static const String DUPLICATED_NAME = 'duplicated-name';
  static const String DUPLICATED_ID = 'duplicated-id';
  static const String DUPLICATED_ITEM = 'duplicated-item';
  static const String DUPLICATED_MAPPING_SOURCE = 'duplicated-mapping-source';
  static const String UNDEFINED_ERROR = 'undefined-error';
  static const String NOT_BELONG_TO_ANY_HOTEL = 'not-belong-to-any-hotel';
  static const String STILL_NOT_BE_AUTHORIZED = 'still-not-be-authorized';
  static const String DIRECT_TO_DELETE_BUTTON = 'direct-to-delete-button';
  static const String SERVICE_NOT_FOUND = 'service-not-found';
  static const String ITEMTYPE_NOT_FOUND = 'itemtype-not-found';
  static const String INPUT_RATE_ROOM_CHANNEL = 'input-rate-room-channel';
  static const String ONLY_ALLOWED_TO_MODIFY_WITHIN_24H =
      'only-allowed-to-edit-within-24-hours';
  static const String ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS =
      'only-allowed-to-edit-within-45-days';
  static const String
      NOT_ALLOWED_TO_BE_MODIFIED_PRIOR_TO_THE_FINANCIAL_CLOSING_DATE =
      'not-allowed-to-be-modified-prior-to-the-financial-closing-date';
  static const String NOT_ALLOWED_TO_CREATE_BEFORE_THE_FINANCIAL_CLOSING_DATE =
      'not-allowed-to-create-before-the-financial-closing-date';
  static const String INVENTORY_CONFIRM_COMPLETE_CHECKING =
      'inventory-confirm-complete-checking';
  static const String NOT_HAVE_PERMISSION_EXPORT_WAREHOUSE =
      'no-permission-for-export-lost-liquidation-warehouse';
  static const String NOT_HAVE_PERMISSION_IMPORT_WAREHOUSE =
      'no-permission-for-import-warehouse';
  static const String WAREHOUSE_NOTE_HAS_BEEN_DELETED_UNABLE_TO_DISPLAY =
      'warehouse-note-has-been-deleted-unable-to-display';
  static const String CONFIRM_EDIT_iMPORT_NOTE = 'confirm-edit-import-note';
  static const String CONFIRM_DELETE_iMPORT_NOTE = 'confirm-delete-import-note';
  static const String CONFIRM_DEACTIVE_STILL_HAVE_ITEMS =
      'confirm-deactive-still-have-item';
  static const String INVOICE_NUMBER_DUPLICATED = 'invoice-number-duplicated';
  static const String CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE =
      'cannot-find-the-corresponding-warehouse-import-note';
  static const String CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_RETURN_NOTE =
      'cannot-find-the-corresponding-warehouse-return-note';

  static const String CAN_NOT_CHANGE_THE_YEAR_OF_WAREHOUSE_NOTE =
      'can-not-change-the-year-of-warehouse-note';
  static const String CAN_NOT_FIND_INVOICE_NUMBER =
      'can-not-find-invoice-number';
  static const String INVOICE_NUMBER_CAN_NOT_BE_EMPTY =
      'invoice-number-can-not-be-empty';
  static const String CAN_NOT_FOUND_INVOICE = 'can-not-found-invoice';
  static const String
      TEXTALERT_ITEMS_HAVE_NOT_BEEN_SET_DEFAULT_WAREHOUSE_FOR_INGREDIENTS =
      'textalert-items-have-not-been-set-default-warehouse-for-ingredients';
  static const String OVER_MAXIMUM_ROOM_OF_ROOMTYPE =
      'over-maximum-room-of-roomtype';
  static const String ROOM_HAVE_BOOKING_PLEASE_MOVE_BOOKING_BEFORE_DELETE_ROOM =
      'room-have-booking-please-move-booking-before-delete-room';
  static const String ACTIVE_IS_NOT_ACTIVATED_CAN_UPDATE =
      'active-is-not-activated-can-update';
  static const String ACTIVE_ALREADY_IN_AN_INACTIVE_STATE =
      'active-already-in-an-inactive-state';

  static const String PRICE_MUST_BIGGER_THAN_MIN_PRICE =
      'price-must-bigger-than-min-price';
  static const String QUANTITY_ROOMTYPE_SMALLER_THAN_MAX_ROOMTYPE =
      'quantity-roomtype-smaller-than-max-roomtype';
  static const String JUST_FOR_CHECKIN_OR_REPAIR_BOOKING =
      'just-for-checkin-or-repair-booking';
  static const String MIN_PRICE_MUST_SMALLER_THAN_PRICE =
      'min-price-must-smaller-than-price';
  static const String NEED_TO_ADD_USER_TO_HOTEL_FIRST =
      'need-to-add-user-to-hotel-first';
  static const String NEED_TO_UPDATE_INFO = 'need-to-update-info';
  static const String NEED_TO_CHOOSE_ATLEAST_ONE_SERVICE =
      'need-to-choose-atleast-one-service';
  static const String CAN_NOT_AUTHORIZE_BY_YOURSELF =
      'can-not-authorize-by-yourself';
  static const String CAN_NOT_AUTHORIZE_YOUR_BOSS =
      'can-not-authorize-your-boss';
  static const String OVER_PERCENTAGE_RANGE = 'over-percentage-range';
  static const String CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER =
      'can-not-deactive-default-supplier';
  static const String NEED_TO_ADD_BIKE_RENTAL_TO_SUPPLIER_FIRST =
      'need-to-add-bike-rental-to-supplier-first';
  static const String CONFIGURATION_NOT_FOUND = 'configuration-not-found';
  static const String ALL_CHECKED_ROOM = 'all-checked-room';

  static const String GENDER_MALE = 'male';
  static const String GENDER_FEMALE = 'female';
  static const String GENDER_OTHER = 'other';

  static const String CHOOSE_COUNTRY = 'choose-country';
  static const String CHOOSE_CITY = 'choose-city';
  static const String CHOOSE_TIMEZONE = 'choose-timezone';
  static const String CHOOSE_CURRENCY = 'choose-currency';
  static const String CHOOSE_UNIT = 'choose-unit';
  static const String CHOOSE_ITEM = 'choose-item';

  static const String PLEASE_CHOOSE_CHECKBOX = 'please-choose-checkbox';
  static const String PLEASE_CHOOSE_NATIONALITY = 'please-choose-nationality';
  static const String PLEASE_CHOOSE_ADDRESS = 'please-choose-address';
  static const String PLEASE_CHOOSE_COUNTRY = 'please-choose-country';
  static const String PLEASE_CHOOSE_WAREHOUSE = 'please-choose-warehouse';
  static const String PLEASE_CHOOSE_RIGHT_COUNTRY =
      'please-choose-right-country';

  static const String PLEASE_INPUT_DOC_ID_FOR_GUEST_DECLARATION =
      'please-input-doc-id-for-guest-declaration';
  static const String PLEASE_RESCAN = 'please-rescan';
  static const String PLEASE_CHOOSE_REASON = 'please-choose-reason';
  static const String PLEASE_INPUT_PASSPORT_FOR_FOREINGER =
      'please-input-passport-for-foreigner';
  static const String PLEASE_CLICK_REFRESH_BUTTON_FIRST =
      'please-click-refresh-button-first';

  //email
  static const String EMAIL_NOT_FOUND = 'email-not-found';
  static const String EMAIL_EXISTED = 'email-duplicated';
  static const String EMAIL_REGISTED = 'email-registed';
  static const String UNAUTHENTICATED_USER = 'unauthenticated-user';
  static const String CAN_NOT_REMOVE_YOURSELFT = 'can-not-remove-yourself';
  static const String NATIONAL_ID_DUPLICATED = 'national-id-duplicated';

  //confirm
  static const String CONFIRM_ACTIVE = 'confirm-active';
  static const String CONFIRM_DEACTIVE = 'confirm-deactive';
  static const String CONFIRM_SET_DEFAULT_RATE_PLAN =
      'confirm-set-default-rate-plan';
  static const String CONFIRM_SHOW_PRICE = 'confirm-show-price';
  static const String CONFIRM_SHOW_NOTES = 'confirm-show-notes';
  static const String CONFIRM_SHOW_DAILY_RATE = 'confirm-show-daily-rate';
  static const String CONFIRM_SHOW_MONTHLY_RATE = 'confirm-show-monthly-rate';
  static const String CONFIRM_SHOW_ROOM_PRICE = 'confirm-show-room-price';
  static const String CONFIRM_SHOW_SERVICE = 'confirm-show-service';
  static const String CONFIRM_SHOW_PAYMENT = 'confirm-show-payment';
  static const String CONFIRM_SHOW_REMAINING = 'confirm-show-remaining';
  static const String CONFIRM_DELETE = 'confirm-delete';
  static const String CONFIRM_DELETE_X = 'confirm-delete-x';
  static const String CONFIRM_STOP_WORKING = 'confirm-stop-working';
  static const String CONFIRM_DELETE_INVOICE_WITH_AMOUNT =
      'confirm-delete-invoice-with-amount';
  static const String CONFIRM_DELETE_PAYMENT_WITH_AMOUNT =
      'confirm-delete-payment-with-amount';
  static const String CONFIRM_DELETE_EXTRA_SERVICE =
      'confirm-delete-extra-service';
  static const String CONFIRM_DELETE_DISCOUNT_WITH_AMOUNT =
      'confirm-delete-discount-with-amount';
  static const String CONFIRM_SELECT_BOOKING = 'confirm-select-booking';
  static const String CONFIRM_BOOKING_CHECKIN_AT_ROOM =
      'confirm-booking-checkin-at-room';
  static const String CONFIRM_BOOKING_CHECKOUT_AT_ROOM =
      'confirm-booking-checkout-at-room';
  static const String CONFIRM_BOOKING_CHECKOUT = 'confirm-booking-checkout';
  static const String CONFIRM_BOOKING_CANCEL_AT_ROOM =
      'confirm-booking-cancel-at-room';
  static const String CONFIRM_BOOKING_NO_SHOW_AT_ROOM =
      'confirm-booking-no-show-at-room';
  static const String CONFIRM_BOOKING_UNDO_CHECKIN_AT_ROOM =
      'confirm-booking-undo-checkin-at-room';
  static const String CONFIRM_BOOKING_UNDO_CHECKOUT_AT_ROOM =
      'confirm-booking-undo-checkout-at-room';
  static const String CONFIRM_BOOKING_CHANGE_ROOM =
      'confirm-booking-change-room';
  static const String CONFIRM_UPDATE_PRICE_BOOKING_WHEN_CHANGE_ROOM_TYPE =
      'confirm-update-price-booking-when-change-room-type';
  static const String CONFIRM_REMOVE_USER_FROM_HOTEL =
      'confirm-remove-user-from-hotel';
  static const String CONFIRM_BIKERENTAL_CHECKOUT =
      'confirm-bikerental-checkout';
  static const String CONFIRM_CANCEL_BOOKING_GROUP_X =
      'confirm-cancel-booking-group-x';
  static const String CONFIRM_EXPORT_MUCH_THAN_IN_STOCK =
      'confirm-export-much-than-in-stock';
  static const String CONFIRM_LIQUIDATION_MUCH_THAN_IN_STOCK =
      'confirm-liquidation-much-than-in-stock';
  static const String CONFIRM_TRANSFER_MUCH_THAN_IN_STOCK =
      'confirm-transfer-much-than-in-stock';
  static const String CONFIRM_CREATE_COST_MANAGEMENT_AFTER_IMPORT =
      'confirm-create-cost-management-after-import';
  static const String CONFIRM_YOU_ARE_SURE = 'confirm-you-are-sure';
  static const String
      CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE =
      'cannot-create-and-edit-or-delete-before-the-financial-settlement-date';

  // electronic invoice
  static const String SOFTWARE_CAN_NOT_BE_EMPTY = 'software-can-not-be-empty';
  static const String USERNAME_CAN_NOT_BE_EMPTY = 'username-can-not-be-empty';
  static const String PASSWORD_CAN_NOT_BE_EMPTY = 'password-can-not-be-empty';
  static const String OTHER_PAYMENT_METHOD_CAN_NOT_BE_EMPTY =
      'other_payment-method-can-not-be-empty';
  static const String OTHER_VAT_CAN_NOT_BE_EMPTY = 'other_vat-can-not-be-empty';
  static const String OTHER_VAT_CAN_NOT_GREATER_THAN_100 =
      'other_vat-can-not-greater-than-100';
  static const String AMOUNT_IN_WORD_CAN_NOT_BE_EMPTY =
      'amount-in-word-can-not-be-empty';

  //hotel
  static const String HOTEL_CAN_NOT_EDIT_INFO = 'hotel-can-not-edit-info';
  static const String REVENUE_DOC_NOT_FOUND = 'revenue-doc-not-found';
  static const String REVENUE_MANAGEMENT_NOT_FOUND =
      'revenue-management-not-found';

  //booking
  static const String END_TIME_CAN_NOT_BEFORE_START_TIME =
      'end-time-can-not-before-start-time';
  static const String ADD_GROUP_FIRST = 'add-group-first';
  static const String ADD_BOOKING_AT_ROOM_SUCCESS = 'add-booking-at-room';
  static const String ALREADY_EXIST_OTA_IN_BOOKING =
      'already-exist-ota-in-booking';
  static const String BOOKING_FROM_OTA_CAN_NOT_EDIT =
      'booking-from-ota-can-not-edit';
  static const String SET_NONE_ROOM_CAN_NOT_EDIT_INFORMATION =
      'set-none-room-can-not-edit-information';
  static const String BOOKING_ALREADY_SET_NONE_ROOM =
      'booking-already-set-none-room';
  static const String BOOKING_NOT_FOUND = 'booking-not-found';
  static const String BOOKING_NOT_CHECKIN = 'booking-not-checkin';
  static const String BOOKING_NOT_CHECKOUT = 'booking-not-checkout';
  static const String BOOKING_NOT_REPAIR = 'booking-not-repair';
  static const String BOOKING_WAS_CHECKEDIN = 'booking-was-checkedin';
  static const String BOOKING_WAS_UNDO_CHECKOUT = 'booking-was-undo-checkout';
  static const String BOOKING_CAN_NOT_UNDO_CHECKOUT_AFTER_24HOURS =
      'booking-can-not-undo-check-out-after-24hours';
  static const String BOOKING_CAN_NOT_EDIT_RATE_PLAN =
      'booking-can-not-edit-rate-plan';
  static const String BOOKING_CAN_NOT_EDIT_PRICE_OF_CHECKED_IN_BOOKING =
      'booking-can-not-price-of-checked-in-booking';
  static const String BOOKING_CHECKOUT_BEFORE = 'booking-checkout-before';
  static const String BOOKING_CHECKIN_CAN_NOT_MODIFY_INDAY =
      'booking-checkin-can-not-modify-inday';
  static const String BOOKING_WAS_CANCELLED_OR_CHECKED_OUT =
      'booking-was-cancelled-or-checked-out';
  static const String BOOKING_HAS_DEPOSIT_OR_SERVICE =
      'booking-has-deposit-or-service';
  static const String BOOKING_RENTING_BIKES = 'booking-renting-bikes';
  static const String BOOKING_CAN_NOT_BE_UPDATE = 'booking-can-not-be-update';
  static const String BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT =
      'booking-must-pay-remaining-before-checkout';
  static const String BOOKING_GROUP_HAVE_REMAINING_BEFORE_CHECKOUT =
      'booking-group-have-remaining-before-checkout';
  static const String BOOKING_CONFLIX_ROOM = 'booking-conflix-room';
  static const String BOOKING_CHECKIN_SUCCESS = 'booking-checkin-success';
  static const String BOOKING_CHECKOUT_SUCCESS = 'booking-checkout-success';
  static const String BOOKING_CANCEL_SUCCESS = 'booking-cancel-success';
  static const String BOOKING_VIRTUAL_DUPLICATED = 'booking-virtual=duplicated';
  static const String BOOKING_UNDO_CHECKIN_SUCCESS =
      'booking-undo-checkin-success';
  static const String BOOKING_UNDO_CHECKOUT_SUCCESS =
      'booking-undo-checkout-success';
  static const String BOOKING_CHANGE_TO_ROOM = 'booking-change-to-room';
  static const String BOOKING_NOT_TODAY_BOOKING = 'booking-not-today-booking';
  static const String BOOKING_OVER_TIME_CHECKOUT = 'booking-over-time-checkout';
  static const String BOOKING_OVER_TIME_UNDO_CHECKOUT =
      'booking-over-time-undo-checkout';
  static const String BOOKING_NOT_IN_BOOKED_STATUS =
      'booking-not-in-booked-status';
  static const String BOOKING_OVER_TIME_CHANGE_ROOM =
      'booking-over-time-change-room';
  static const String BOOKING_OVER_TIME_UNDO_CHECKIN =
      'booking-over-time-undo-checkin';
  static const String BOOKING_MUST_CHECKOUT_BIKES =
      'booking-must-checkout-bikes';
  static const String BOOKING_CAN_NOT_UNDO_CHECKOUT_BECAUSE_CONFLIX_ROOM =
      'booking-can-not-undo-checkout-because-conflix-room';
  static const String BOOKING_GROUP_CREATE_SUCCESS =
      'booking-group-create-success';
  static const String BOOKING_GROUP_CANNOT_CHANGE_RATE_PLAN =
      'booking-group-cannot-change-rate-plan';
  static const String BOOKING_GROUP_CANNOT_CHANGE_SID =
      'booking-group-cannot-change-sid';
  static const String BOOKING_DELETE_REPAIR_SUCCESS =
      'booking-delete-repair-success';
  static const String BOOKING_DELETE_REPAIR_FAIL = 'booking-delete-repair-fail';
  static const String BOOKING_AT_ROOM_UPDATE_SUCCESS =
      'booking-at-room-update-success';
  static const String BOOKING_WRONG_TRANSFERRED = 'booking-wrong-transferred';
  static const String BOOKING_GROUP_NOT_ENOUGH_ROOM =
      'booking-group-not-enough-room';
  static const String BOOKING_GROUP_ROOM_PICK_INVALID =
      'booking-group-room-pick-invalid';
  static const String BOOKING_OVERDUE_TO_CHECKIN = 'booking-overdue-to-checkin';
  static const String BOOKING_OVERDUE_TO_CHECKOUT =
      'booking-overdue-to-checkout';

  static const String CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN =
      'cant-not-add-update-booking-local-with-ota-rate-plan';
  static const String CAM_NOT_CHAGE_BOOKING_TYPE =
      "can-not-change-booking-type";

  //payment
  static const String PAYMENT_MUST_GREATER_THAN_REMAINING =
      'payment-must-greater-than-remaining';
  static const String PAYMENT_WAS_DELETE = 'payment-was-delete';
  static const String CAN_NOT_DELETE_PAYMENT = 'can-not-delete-payment';
  static const String ID_PAYMENT_DUPLICATED = 'id-payment-duplicated';
  static const String NAME_PAYMENT_DUPLICATED = 'name-payment-duplicated';
  static const String PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED =
      'payment-transfer-id-or-bid-undefined';
  static const String YOU_DO_NOT_UPDATE_OTHER_PEOPLE_PAYMENT =
      'You-do-not-update-other-people-payemet';
  static const String YOU_DO_NOT_DELETE_OTHER_PEOPLE_PAYMENT =
      'You-do-not-delete-other-people-payemet';
  static const String YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED =
      'You-do-not-delete-payemet-status-passed';
  static const String THE_SAME_ROOM = 'the-same-room';
  static const String CAN_NOT_CANCEL_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT =
      'can-not-cancel-booking-when-group-have-booking-out';
  static const String CAN_NOT_NO_SHOW_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT =
      'can-not-no-show-booking-when-group-have-booking-out';
  static const DEPOSIT_HAS_BEEN_FEFUND_CANNOT_BE_CHANGHED =
      'deposit-has-been-refund-cannot-be-changed';
  static const DEPOSIT_HAS_BEEN_FEFUND_CANNOT_DELETE =
      'deposit-has-been-refund-cannot-delete';
  static const THE_REMAINING_DEPOSIT_IS_NOT_ENOUGH =
      'the-remaining-deposit-is-not-enough';
  static const PLEASE_REFUND_THE_DEPOSIT_TO_THE_GUEST =
      'please-refund-the-deposit-to-the-guest';

  static const String UPDATE_ACTUAL_PAYMENT_FOR = 'update-actual-payment-for';
  static const String CREATE_ACTUAL_PAYMENT_FOR = 'create-actual-payment-for';
  static const String DELETE_ACTUAL_PAYMENT_FOR = 'delete-actual-payment-for';

  //bike
  static const String BIKE_RENTAL_NOT_FOUND = 'bike-rental-not-found';
  static const String CHANGE_BIKE_FAIL = 'change-bike-fail';
  static const String CHANGE_BIKE_SUCCESS = 'change-bike-success';
  static const String CAN_NOT_EDIT_BIKE_RENTAL = 'can-not-edit-bike-rental';
  static const String CAN_NOT_TRANSFER_FOR_YOURSELF =
      'can-not-transfer-for-yourself';
  static const String MOVE_TO_ANOTHER_BOOKING = 'move-to-another-booking';
  static const String NO_AVAILABLE_BIKE_TO_CHANGE =
      'no-available-bike-to-change';
  static const String BIKE_RENTAL_CAN_NOT_DEACTIVE =
      'bike-rental-can-not-deactive';
  static const String BIKE_WAS_CHECKED_IN = 'bike-was-checked-in';
  static const String BIKE_WAS_CHECKED_OUT = 'bike-was-checked-out';
  static const String BIKE_WAS_RENTED = 'bike-was-rented';
  static const String BIKE_PROGRESS_BOOKED = 'bike-progress-booked';
  static const String BIKE_PROGRESS_IN = 'bike-progress-in';
  static const String BIKE_PROGRESS_OUT = 'bike-progress-out';

  //date
  static const String INDATE_MUST_NOT_IN_PAST = 'indate-must-not-in-past';
  static const String OVER_MAX_LENGTHDAY_31 = 'over-max-lengthday-31';
  static const String OVER_MAX_LENGTHDAY_365 = 'over-max-lengthday-365';
  static const String OUTDATE_MUST_LARGER_THAN_INDATE =
      'outdate-must-larger-than-indate';
  static const String OUTDATE_CAN_NOT_IN_PAST = 'outdate-can-not-in-past';
  static const String OVER_X_DAYS = 'over-x-days';

  //invalid
  static const String ADULT_MUST_BE_NUMBER = 'adult-must-be-number';
  static const String CHILD_MUST_BE_NUMBER = 'child-must-be-number';
  static const String DUPLICATED_HOUR = 'duplicated-hour';
  static const String INVALID_DATA = 'invalid-data';
  static const String INVALID_EMAIL = 'invalid-email';
  static const String INVALID_COUNTRY = 'invalid-country';
  static const String INVALID_CITY = 'invalid-city';
  static const String INVALID_DAY = 'invalid-day';
  static const String INVALID_VERSION = 'invalid-version';
  static const String INVALID_PRICE = 'invalid-price';
  static const String INVALID_CMND_CCCD = 'invalid-cmnd-cccd';
  static const String INVALID_NATIONAL_ADDRESS = 'invalid-national-address';
  static const String INVALID_CITY_ADDRESS = 'invalid-city-address';
  static const String INVALID_DISTRICT_ADDRESS = 'invalid-district-address';
  static const String INVALID_COMMUNE_ADDRESS = 'invalid-commune-address';
  static const String INVALID_ITEM = 'invalid-item';
  static const String INVALID_SALER = 'invalid-saler';
  static const String INVALID_DATA_WRONG_FILE = 'invalid-data-wrong-file';
  static const String INVALID_DATA_DOWNLOAD_TO_FIX =
      'invalid-data-download-to-fix';
  static const String STILL_NOT_CHANGE_VALUE = 'still-not-change-value';
  static const String SID_MUST_NOT_CONTAIN_SPECIFIC_CHAR =
      'sid-must-not-contain-specific-char';
  static const String SID_CAN_NOT_BE_EMPTY = 'sid-can-not-be-empty';
  static const String CAN_NOT_CHANGE_DATA_AND_STATUS_AT_THE_SAME_TIME =
      'can-not-change-data-and-status-at-the-same-time';
  static const String PAYMENT_METHOD_CAN_NOT_BE_EMPTY =
      'payment-method-can-not-be-empty';
  static const String NATIONAL_ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR =
      'national-id-must-not-contain-specific-char';
  static const String NAME_MUST_NOT_CONTAIN_SPECIFIC_CHAR =
      'name-must-not-contain-specific-char';
  static const String STREET_MUST_NOT_CONTAIN_SPECIFIC_CHAR =
      'street-must-not-contain-specific-char';
  static const String NAME_CAN_NOT_BE_BLANK = 'name-can-not-be-blank';
  static const String STREET_CAN_NOT_BE_BLANK = 'street-can-not-be-blank';
  static const String ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR =
      'id-must-not-contain-specific-char';
  static const String ID_CAN_NOT_BE_BLANK = 'id-can-not-be-blank';
  static const String SID_OVER_MAXIMUM_CHARACTERS =
      'sid-over-maximum-characters';
  static const String PHONE_OVER_MAXIMUM_NUMBER = 'phone-over-maximum-number';
  static const String PRICE_OVER_MAXIMUM_NUMBER = 'price-over-maximum-number';
  static const String ID_OVER_MAXIMUM_CHARACTERS = 'id-over-maximum-characters';
  static const String PHONE_SMALLER_THAN_MINIMUM_LENGTH =
      'phone-smaller-than-minimum-length';
  static const String NATIONAL_ID_OVER_MAXIMUM_CHARACTERS =
      'national-id-over-maximum-characters';
  static const String PHONE_MUST_BE_NUMBER = 'phone-must-be-number';
  static const String PHONE_CAN_NOT_CONTAIN_WORD = 'phone-can-not-contain-word';
  static const String PRICE_MUST_BE_NUMBER = 'price-must-be-number';
  static const String OVER_ID_MAX_LENGTH = 'over-id-max-length';
  static const String OVER_SUPPLIER_ID_MAX_LENGTH =
      'over-supplier-id-max-length';
  static const String OVER_ID_RATE_LAN_MAX_LENGTH =
      'over-id-rate-lan-max-length';
  static const String OVER_NAME_MAX_LENGTH = 'over-name-max-length';
  static const String OVER_STATUS_MAX_LENGTH = 'over-stutus-max-length';
  static const String OVER_CMND_CCCD_MAX_LENGTH = 'over-cmnd-cccd-max-length';
  static const String OVER_PASSPORT_MAX_LENGTH = 'over-passport-max-length';
  static const String OVER_OTHER_DOCUMENT_MAX_LENGTH =
      'over-other-document-max-length';
  static const String ADD_PRESS_BELOW_BUTTON = "add-by-press-below-button";
  static const String OVER_NAME_INVOICE_MAX_LENGTH =
      'over-name-invoice-max-length';
  static const String OVER_TAX_CODE_INVOICE_MAX_LENGTH =
      'over-tax-code-invoice-max-length';
  static const String OVER_ADDRESS_INVOICE_MAX_LENGTH =
      'over-address-invoice-max-length';
  static const String
      THE_BIGINGING_OF_THE_PERIOD_CANNOT_BE_GTEATER_THAN_THE_END_OF_THE_THE_PERIOD =
      'the-beginning-of-the-period-cannot-be-greater-than-the-end-of-the-period';

  //no-data
  static const String NO_DATA = 'no-data';
  static const String NO_DATA_AND_PRESS_PREVIOUS_TO_GET_BACK =
      'no-data-press-previous';
  static const String NO_DATA_AND_PRESS_NEXT_TO_GET_BACK = 'no-data-press-next';
  static const String NO_ITEM_ADDED = 'no-item-added';
  static const String NO_DEPOSIT_ADDED = 'no-deposit-added';
  static const String NO_ROOM_EXTRA_CONFIGS = 'no-room-extra-configs';
  static const String CAN_NOT_BE_EMPTY = 'can-not-be-empty';

  //tax
  static const String OVER_RANGE_SERVICE_FEE_PERCENTAGE =
      'over-range-service-fee-number';
  static const String OVER_RANGE_VAT_PERCENTAGE = 'over-range-vat-number';

  // lost status
  static const String LOST = 'lost';
  static const String BROKEN = 'broken';
  static const String EXPIRED = 'expired';

  //require to input
  static const String INPUT_ADDRESS = 'input-address';
  static const String INPUT_NATIONAL_ID = 'input-national-id';
  static const String INPUT_AT_LEAST_ONE_ROLE = 'input-at-least-one-role';
  static const String INPUT_ADULT_AND_CHILD = 'input-adult-and-child';
  static const String INPUT_CITY_NAME = 'input-city-name';
  static const String INPUT_DESCRIPTION = 'input-description';
  static const String INPUT_EMAIL = 'input-email';
  static const String INPUT_ID = 'input-id';
  static const String INPUT_SID = 'input-sid';
  static const String INPUT_IMAGE = 'input-image';
  static const String INPUT_NUMBER = 'input-number';
  static const String INPUT_NAME = 'input-name';
  static const String INPUT_FIRST_NAME = 'input-first-name';
  static const String INPUT_FULL_NAME = 'input-full-name';
  static const String INPUT_ONLY_LETTERS = 'input-only-letters';
  static const String INPUT_LAST_NAME = 'input-last-name';
  static const String INPUT_AMOUNT = 'input-amount';
  static const String INPUT_STREET = 'input-street';
  static const String INPUT_ROOMTYPE = 'input-roomtype';
  static const String INPUT_ROOM = 'input-room';
  static const String INPUT_ROOM_ID_DUPLICATED_ROOM_TYPE =
      'input-room-id-duplicated-room-type';
  static const String INPUT_VALID_ROOM = 'input-valid-room';
  static const String INPUT_TYPE_OF_BED = 'input-type-of-bed';
  static const String INPUT_PASSWORD = 'input-password';
  static const String INPUT_POSITIVE_NUMBER = 'input-positive-number';
  static const String INPUT_POSITIVE_PRICE = 'input-positive-price';
  static const String INPUT_POSITIVE_TOTAL = 'input-positive-total';
  static const String INPUT_POSITIVE_AMOUNT = 'input-positive-amount';
  static const String AMOUNT_TRANSFER_BIGGER_THAN_CURRENT_AMOUNT =
      'amount-transfer-bigger-than-current-amount';

  static const String INPUT_PHONE = 'input-phone';
  static const String INPUT_PRICE = 'input-price';
  static const String INPUT_PAYMENT = 'input-payment';
  static const String INPUT_NUM_GUEST = 'input-num-guest';
  static const String INPUT_SERVICE_FEE = 'input-service-fee';
  static const String INPUT_VAT = 'input-vat';
  static const String INPUT_NON_NEGATIVE_NUMBER = 'input-non-negative-number';
  static const String INPUT_ADULT_PRICE = 'input-adult-price';
  static const String INPUT_CHILD_PRICE = 'input-child-price';
  static const String INPUT_EXTRA_BED_FROM_0_TO_9 =
      'input-extra-bed-from-0-to-9';
  static const String INPUT_TAX_CODE = 'input-tax-code';
  static const String INPUT_INVOICE_ADDRESS = 'input-invoice-address';
  static const String INPUT_INVOICE_EMAIL = 'input-invoice-email';
  static const String INPUT_INVOICE_NAME = 'input-invoice-name';
  static const String INPUT_DETAIL_ADDRESS = 'input-detail-address';

  //room
  static const String ROOM_NOT_FOUND = 'room-not-found';
  static const String ROOM_ALREADY_HAVE_BOOKING_PLEASE_CHOOSE_ANOTHER_ROOM =
      'room-already-have-booking-please-choose-another-room';
  static const String PLEASE_SELECT_THE_CORRECR_ROOM_TO_UPDATE =
      'please-select-the-correct-room-to-update';

  static const String ROOM_TYPE_OF_ROOM_CANNOT_EDIT =
      'room-type-of-room-cannot-edit';
  static const String ROOM_CAN_NOT_CHANGE = 'room-can-not-change';
  static const String ROOM_MUST_CLEAN = 'room-must-clean';
  static const String NO_AVAILABLE_ROOM = 'no-available-room';
  static const String THIS_ROOM_NOT_AVAILABLE = 'this-room-not-available';
  static const String ROOM_STILL_NOT_CHECKOUT = 'room-still-not-checkout';
  static const String ROOM_ID_DUPLICATED = 'room-id-duplicated';
  static const String ROOM_NAME_DUPLICATED = 'room-name-duplicated';
  static const String ROOM_HAS_BOOKING_CHECKIN = 'room-has-booking-checkin';
  static const String ROOM_WAS_DELETE = 'room-was-delete';
  static const String NO_ROOM = 'no-room-data';

  //roomtype
  static const String ROOMTYPE_ID_DUPICATED = 'roomtype-id-duplicated';
  static const String ROOMTYPE_NAME_DUPICATED = 'roomtype-name-duplicated';
  static const String ROOMTYPE_NOT_FOUND = 'roomtype-not-found';
  static const String ROOMTYPE_MUST_CHOOSE_BED = 'roomtype-must-choose-bed';
  static const String ROOMTYPE_MUST_DELETE_ALL_ROOM =
      'roomtype-must-delete-all-room';
  static const String ROOMTYPE_MIN_PRICE = 'minprice-must-bigger-than-price';
  static const String ROOMTYPE_DONT_HAVE_ENOUGH_QUATITY =
      'roomtype-dont-have-enough-quatity';

// rate plan
  static const String RATE_PLAN_NOT_FOUND = 'rateplan-not-found';
  static const String RATE_PLAN_DUPLICATED = 'rateplan-duplicated';
  static const String RATE_PLAN_WAS_DELETED = 'rateplan-was-deleted';
  static const String CAN_NOT_DEACTIVE_DEFAULT_RATE_PLAN =
      'can-not-deactive-default-rateplan';
  static const String THIS_RATE_PLAN_CANNOT_BE_EDITED =
      'this-rate-plan-cannot-be-edited';
  static const String OTA_RATE_PLAN_CANNOT_BE_SET_DEFAULT =
      'ota-rate-plan-cannot-be-set-default';

  //image
  static const String IMAGE_OVER_MAX_SIZE = 'image-over-max-size';
  static const String IMAGE_SIZE_MUST_EQUAL_64X64 = 'size-must-equal-64x64';

  //request
  static const String NO_REQUEST = 'no-request';
  static const String WRONG_APPROVAL_REQUEST = 'wrong-approval-request';
  static const String FAIL_TO_GET_DATA_FROM_CLOUD =
      'fail-to-get-data-from-cloud';

  //package
  static const HOTELS_USING_THIS_THIS_PACKAGE_CANNOT_BE_DELETED =
      'hotels-using-this-package-cannot-be-deleted';
  static const THE_PACKAGE_IS_STILL_EXPIRED = 'the-package-is-still-expired';

  //cm
  static const String CM_GET_BOOKINGS_FAIL = 'cm-get-bookings-fail';
  static const String CM_UPDATE_AVAIBILITY_RATE_FAIL =
      'cm-update-avaibility-rate-fail';
  static const String CM_SYNC_BOOKING_SUCCESS = 'cm-sync-booking-success';
  static const String CM_SYNC_ROOMTYPE_SUCCESS = 'cm-sync-roomtype-success';
  static const String CM_SYNC_AVAIBILITY_FROM_PMS_SUCCESS =
      'cm-sync-avaibility-from-pms-success';
  static const String CM_SYNC_AVAIBILITY_FROM_PMS_FAIL =
      'cm-sync-avaibility-from-pms-fail';
  static const String CM_SYNC_FAIL = 'cm-sync-fail';
  static const String CM_NOT_MAP_HOTEL = 'cm-not-map-hotel';
  static const String CM_NOT_MAP_ROOMTYPE = 'cm-not-map-roomtype';
  static const String CM_NOTIFY_SUCCESS = 'cm-notify-success';
  static const String CM_NOTIFY_FAIL = 'cm-notify-fail';
  static const String CM_SAVE_MAPPING_HOTEL_ID_SUCCESS =
      'cm-save-mapping-hotel-id-success';
  static const String CM_SAVE_MAPPING_HOTEL_ID_FAIL =
      'cm-save-mapping-hotel-id-fail';
  static const String CM_WAIT_FOR_PRE_ACTION = 'cm-wait-for-pre-action';
  static const String CM_CLEAR_ALL_ROOMTYPE_SUCCESS =
      'cm-clear-all-roomtype-success';
  static const String CM_UPDATE_INVENTORY_SUCCESS =
      'cm-update-intentory-success';
  static const String CM_UPDATE_INVENTORY_FAIL = 'cm-update-inventory-fail';
  static const String CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_SUCCESS =
      'cm-update-avaibility-and-release-period-success';
  static const String CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_FAIL =
      'cm-update-avaibility-and-release-period-fail';
  static const String CM_UPDATE_AVAIBILITY_FAIL = 'cm-update-avaibility-fail';
  static const String CM_MAXIMUM_DATE_RANGE = 'cm-maximum-date-range';
  static const String CM_HOTEL_EMPTY = 'cm-hotel-empty';
  static const String CM_BOOKING_EMPTY = 'cm-booking-empty';

  //extra_hour
  static const String HOUR_AND_PRICE_MUST_BE_POSITIVE =
      "hour-and-price-must-be-positive";
  static const String RATIO_MUST_BE_FROM_0_TO_100 =
      "ratio-must-be-from-0-to-100";

  //invoice
  static const String INVOICE_DELETE_SUCCESS = 'invoice-delete-success';

  static const String NO_GUEST_IN_ROOM = 'no-guest-in-room';
  static const String OVER_RANGE_GUEST_NUMBER = 'over-range-guest-number';

  //discount
  static const String DISCOUNT_NOT_FOUND = 'discount-not-found';
  static const String DISCOUNT_DUPLICATED_DESC = 'discount-duplicated-desc';
  // restaurant
  static const String RESTAURANT_NOT_FOUND = 'restaurant-not-found';
  static const String WAS_ACCEPT_LINKED = 'was-accpet-linked';
  static const String PLEASE_DELETE_LINKED_FIRST = 'please-delete-linked-first';
  static const String WAS_LINKED_HOTEL = 'was-linked-hotel';

  //login
  static const String PASSWORD_MIN_LENGTH = 'password-min-length';
  static const String WRONG_PASSWORD = 'wrong-password';
  static const String USER_NOT_FOUND = 'user-not-found';
  static const String TO_MANY_REQUESTS = 'too-many-requests';
  static const String EMAIL_ALREADY_IN_USE = 'email-already-in-use';

  //text alert
  static const String TEXTALERT_THIS_HAD_BEEN_DELETE =
      'textalert-this-had-been-delete';
  static const String TEXTALERT_NO_AVATAR = 'textalert-no-avatar';
  static const String TEXTALERT_CHOOSE_YOUR_HOTEL =
      'textalert-choose-your-hotel';
  static const String TEXTALERT_VERSION = 'textalert-version';
  static const String TEXTALERT_IF_YOU_ARE_HOTEL_MANAGER =
      'textalert-if-you-are-hotel-manager';
  static const String TEXTALERT_FOR_INSTRUCTION_VIDEO =
      'textalert-for-instruction-video';
  static const String TEXTALERT_FOR_INSTRUCTION_VIDEO_DETAIL =
      'textalert-for-instruction-video-detail';
  static const String TEXTALERT_HERE = 'textalert-here';
  static const String TEXTALERT_CLICK_HERE = 'textalert-click-here';
  static const String TEXTALERT_CLICK_HERE_TO_CHECKIN =
      'textalert-click-here-to-checkin';
  static const String TEXTALERT_CLICK_HERE_TO_CHECKOUT =
      'textalert-click-here-to-checkout';
  static const String TEXTALERT_TO_CREATE_YOUR_HOTEL =
      'textalert-to-create-your-hotel';
  static const String TEXTALERT_SIGN_OUT = 'textalert-sign-out';
  static const String TEXTALERT_NO_PERMISSION = 'textalert-no-permission';
  static const String TEXTALERT_NO_INFORMATION = 'textalert-no-information';
  static const String TEXTALERT_LOADING_HOTELS = 'textalert-loading-hotels';
  static const String TEXTALERT_LOADING_ROOMS = 'textalert-loading-rooms';
  static const String TEXTALERT_LOADING_CONFIGS = 'textalert-loading-configs';
  static const String TEXTALERT_CLEAN = 'textalert-clean';
  static const String TEXTALERT_DIRTY = 'textalert-dirty';
  static const String TEXTALERT_MINIBAR = 'textalert-minibar';
  static const String TEXTALERT_MOVED = 'textalert-moved';
  static const String TEXTALERT_LAUNDRY = 'textalert-laundry';
  static const String TEXTALERT_BED = 'textalert-bed';
  static const String TEXTALERT_EXTRA_BED = 'textalert-extra-bed';
  static const String TEXTALERT_NO_BOOKINGS = 'textalert-no-bookings';
  static const String TEXTALERT_NO = 'textalert-no';
  static const String TEXTALERT_YES = 'textalert-yes';
  static const String TEXTALERT_NOBREAKFAST = 'textalert-nobreakfast';
  static const String TEXTALERT_YESBREAKFAST = 'textalert-yesbreakfast';
  static const String TEXTALERT_NOLUNCH = 'textalert-nolunch';
  static const String TEXTALERT_YESLUNCH = 'textalert-yeslunch';
  static const String TEXTALERT_NODINNER = 'textalert-nodinner';
  static const String TEXTALERT_YESDINNER = 'textalert-yesdinner';
  static const String TEXTALERT_EMPTY = 'textalert-empty';
  static const String TEXTALERT_X_RENTING_BIKES = 'textalert-renting-bikes';
  static const String TEXTALERT_SIGN_UP = 'textalert-sign-up';
  static const String TEXTALERT_REMEMBER_ME = 'textalert-remember-me';
  static const String TEXTALERT_FORGET_PASSWORD = 'textalert-forget-password';
  static const String TEXTALERT_LOGIN = 'textalert-login';
  static const String TEXTALERT_CHOOSE_JOB = 'textalert-choose-job';
  static const String TEXTALERT_CHOOSE_COUNTRY = 'textalert-choose-country';
  static const String TEXTALERT_CHOOSE_CITY = 'textalert-choose-city';
  static const String TEXTALERT_CHOOSE_CURRENCY = 'textalert-choose-currency';
  static const String TEXTALERT_CHOOSE_TIMEZONE = 'textalert-choose-timezone';
  static const String TEXTALERT_CHOOSE_ROOM = 'textalert-choose-room';
  static const String TEXTALERT_DELETED = 'textalert-deleted';
  static const String TEXTALERT_FOR_HOTEL_TO_USE = 'textalert-for-hotel-to-use';
  static const String TEXTALERT_TO_CREATE_ROOMTYPE_AND_ROOM =
      'textalert-to-create-roomtype-and-room';
  static const String TEXTALERT_PLEASE = 'textalert-please';
  static const String TEXTALERT_YOU_CAN = 'textalert-you-can';

  static const String TEXTALERT_BEFORE_CREATING_NEW_BOOKING =
      'textalert-before-creating-new-booking';
  static const String TEXTALERT_NEED_TO_CONFIG_X_FIRST =
      'textalert-need-to-config-x-first';
  static const String TEXTALERT_VERIFIED = 'textalert-verified';
  static const String TEXTALERT_UNVERIFIED = 'textalert-unverified';
  static const String TEXTALERT_TO_RESEND_EMAIL = 'textalert-to-resend-email';
  static const String TEXTALERT_CHECK_EMAIL = 'textalert-check-email';
  static const String TEXTALERT_TO_VERIFY = 'textalert-to-verify';
  static const String TEXTALERT_YOU_CAN_REQUIRE_TO_RESEND_EMAIL_AFTER =
      'textalert-you-can-resend-email-after';
  static const String TEXTALERT_TOO_MANY_REQUIREMENTS_IN_SHORT_TIME =
      'textalert-too-many-requirements-in-short-time';
  static const String TEXTALERT_MOVED_TO = 'textalert-moved-to';
  static const String TEXTALERT_ADULT = 'adult';
  static const String TEXTALERT_CHILD = 'child';
  static const String TEXTALERT_MANUAL = 'manual';
  static const String TEXTALERT_AUTO = 'auto';
  static const String TEXTALERT_STAYING_ROOM = 'textalert-staying-room';
  static const String TEXTALERT_VIRTUAL_BOOKING = 'textalert-virtual-booking';
  static const String TEXTALERT_CHANGE_COLOR_SUCCESS_AND_RELOAD =
      'textalert-change-color-success-and-reload';
  static const String TEXTALERT_CHANGE_HOUR_SUCCESS_AND_RELOAD =
      'textalert-change-hour-success-and-reload';
  static const String TEXTALERT_CHANGE_POLICY_SUCCESS_AND_RELOAD =
      'textalert-change-policy-success-and-reload';
  static const String TEXTALERT_OTHER_NATIONALITY =
      'textalert-other-nationality';
  static const String TEXTALERT_EXPORT_FILE_FROM_X_TO_Y =
      'textalert-export-file-from-x-to-y';
  static const String TEXTALERT_EXPORT_FILE_OF_MONTH =
      'textalert-export-file-of-month';
  static const String TEXTALERT_MUST_UPGRADE_TO_ADV_OR_PRO =
      'textalert-must-upgrade-to-adv-or-pro';
  static const String TEXTALERT_LAST_CLEAN = 'textalert-last-clean';
  static const String TEXTALERT_AMOUNT_MUST_BE_POSITIVE =
      'textalert-amount-must-be-positive';
  static const String TEXTALERT_MONEY_AMOUNT_MUST_BE_POSITIVE =
      'textalert-money-amount-must-be-positive';
  static const String TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY =
      'textalert-warehouse-can-not-be-empty';
  static const String TEXTALERT_SUPPLIER_CAN_NOT_BE_EMPTY =
      'textalert-supplier-can-not-be-empty';
  static const String TEXTALERT_INVALID_SUPPLIER = 'textalert-invalid-supplier';
  static const String TEXTALERT_INVALID_WAREHOUSE =
      'textalert-invalid-warehouse';
  static const String TEXTALERT_ONLY_SELECTED_ITEMS =
      'textalert-oly-selected-items';
  static const String TEXTALERT_ALL_ITEMS = 'textalert-all-items';

  static const String TEXTALERT_TYPE_CAN_NOT_BE_EMPTY =
      'textalert-type-can-not-be-empty';
  static const String TEXTALERT_ACCOUNTING_ID_CAN_NOT_BE_EMPTY =
      'textalert-accounting-id-can-not-be-empty';
  static const String TEXTALERT_METHOD_CAN_NOT_BE_EMPTY =
      'textalert-method-can-not-be-empty';
  static const String TEXTALERT_YOU_SWAP_SCREEN_TOO_FAST =
      'textalert-you-swap-screen-to-fast';
  static const String TEXTALERT_TRY_AGAIN = 'textalert-try-again';
  static const String TEXTALERT_PLEASE_CHOOSE_UNIT =
      'textalert-please-choose-unit';
  static const String TEXTALERT_BOTH_OF_PRICE_CAN_NOT_BE_ZERO =
      'textalert-both-of-price-can-not-be-zero';
  static const String
      TEXTALERT_WE_HAVE_SENT_A_PASSWORD_RESET_LINK_TO_YOUR_EMAIL =
      'textalert-we-have-sent-a-password-reset-link-to-your-email';
  static const String COST_PRICE_MUST_BE_A_POSITIVE_NUMBER =
      'cost-price-must-be-a-positive-number';
  static const String TEXTALERT_CREATE_NEW_ACCOUNTING_TYPE =
      'textalert-create-new-accounting-type';
  static const String TEXTALERT_CREATE_NEW_SUPPLIER =
      'textalert-create-new-supplier';
  static const String TEXTALERT_AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE =
      'textalert-amount-can-not-more-than-amount-in-import-note';
  //activities
  static const String ACTIVITY_CREATE_NEW_X_WITH_AMOUNT =
      'activity-create-new-x-with-amount';
  static const String ACTIVITY_CREATE_NEW_BIKE_X = 'activity-create-new-bike-x';
  static const String ACTIVITY_UPDATE_X = 'activity-update-x';
  static const String ACTIVITY_UPDATE_X_FROM_A_TO_B =
      'activity-update-x-from-a-to-b';
  static const String ACTIVITY_DELETE_X = 'activity-delete-x';
  static const String ACTIVITY_CHECKIN_BIKE_X = 'activity-checkin-bike-x';
  static const String ACTIVITY_CHECKOUT_BIKE_X = 'activity-checkout-bike-x';
  static const String ACTIVITY_CHANGE_BIKE_FROM_A_TO_B =
      'activity-change-bike-from-a-to-b';
  static const String ACTIVITY_CHECKIN = 'activity-checkin';
  static const String ACTIVITY_CHECKOUT = 'activity-checkout';
  static const String ACTIVITY_CHANGE_DATE = 'activity-change-date';
  static const String ACTIVITY_CHANGE_ROOM_TO_X = 'activity-change-room-to-x';
  static const String ACTIVITY_CHANGE_NAME_TO_X = 'activity-change-name-to-x';
  static const String ACTIVITY_BOOK_ROOM_X = 'activity-book-room-x';
  static const String ACTIVITY_CANCEL = 'activity-cancel';
  static const String ACTIVITY_NOSHOW = 'activity-noshow';
  static const String ACTIVITY_MINIBAR_SERVICE = 'minibar_service';
  static const String ACTIVITY_RESTAURANT_SERVICE = 'restaurant_service';
  static const String ACTIVITY_ELECTRICITY_SERVICE = 'electricity_service';
  static const String ACTIVITY_WATER_SERVICE = 'water_service';
  static const String ACTIVITY_INSIDE_RESTAURANT_SERVICE =
      'inside_restaurant_service';
  static const String ACTIVITY_LAUNDRY_SERVICE = 'laundry_service';
  static const String ACTIVITY_OTHER_SERVICE = 'other_service';
  static const String ACTIVITY_EXTRA_GUEST_SERVICE = 'extra_guest_service';
  static const String ACTIVITY_EXTRA_HOUR_SERVICE = 'extra_hour_service';
  static const String ELECTRICITY_WATER_SERVICE = 'electricity_water_service';
  static const String ACTIVITY_DEPOSIT = 'deposit';
  static const String ACTIVITY_DEPOSIT_AMOUNT = 'deposit_amount';
  static const String ACTIVITY_DEPOSIT_DESCRIPTION = 'deposit_description';
  static const String ACTIVITY_DEPOSIT_METHOD = 'deposit_method';
  static const String ACTIVITY_UNDO_CHECKIN = 'activity-undo-checkin';
  static const String ACTIVITY_UNDO_CHECKOUT = 'activity-undo-checkout';
  static const String ACTIVITY_NONE_ROOM = 'activity-none-room';
  static const String ACTIVITY_SECONDS_AGO = 'activity-seconds-ago';
  static const String ACTIVITY_MINUTES_AGO = 'activity-minutes-ago';
  static const String ACTIVITY_HOURS_AGO = 'activity-hours-ago';
  static const String ACTIVITY_DAYS_AGO = 'activity-days-ago';

  //job
  static const String JOB_ACCOUNTANT = 'job-accountant';
  static const String JOB_ADMIN = 'job-admin';
  static const String JOB_MANAGER = 'job-manager';
  static const String JOB_RECEPTIONIST = 'job-receptionist';
  static const String JOB_GUARD = 'job-guard';
  static const String JOB_MAINTAINER = 'job-maintainer';
  static const String JOB_HOUSEKEEPING = 'job-housekeeping';
  static const String JOB_SALE = 'job-sale';
  static const String JOB_MARKETING = 'job-marketing';
  static const String JOB_CHEF = 'job-chef';
  static const String JOB_WAITER_WAITRESS = 'job-waiter-waitress';
  static const String JOB_STEPWARD = 'job-stepward';
  static const String JOB_OWNER = 'job-owner';
  static const String JOB_HR = 'job-hr';
  static const String JOB_OTHER = 'job-other';
  static const String JOB_CHOOSE = 'job-choose';
  static const String JOB_PARTNER = 'job-partner';
  static const String JOB_INTERNAL_PARTNER = 'job-internal-partner';
  static const String JOB_APPROVER = 'job-approver';
  static const String JOB_WAREHOUSE_MANAGER = 'role-warehouse manager';
  static const String JOB_E_INVOICE_MANAGER = 'role-e invoice manager';

  //statistic
  static const String STATISTIC_ALL = 'statistic-all';
  static const String STATISTIC_OCCUPANCY = 'statistic-occupancy';
  static const String STATISTIC_REVENUE = 'statistic-revenue';
  static const String STATISTIC_REVENUE_BY_DATE = 'statistic-revenue-by-date';
  static const String STATISTIC_REVENUE_BY_CHECKOUT_DATE =
      'statistic-revenue-by-checkout-date';
  static const String STATISTIC_REVENUE_BY_ROOM_TYPE =
      'statistic-revenue-by-room-type';
  static const String STATISTIC_ROOM_USED = 'statistic-room-used';
  static const String STATISTIC_ROOM_STILL_EMPTY = 'statistic-room-still-empty';
  static const String STATISTIC_ROOM_CHARGE = 'statistic-room-charge';
  static const String STATISTIC_DEPOSIT = 'statistic-deposit';
  static const String STATISTIC_DISCOUNT = 'statistic-discount';
  static const String STATISTIC_SERVICE = 'statistic-service';
  static const String STATISTIC_NEW_BOOKING = 'statistic-new-booking';
  static const String STATISTIC_MEALS = 'statistic-mael';
  static const String STATISTIC_BREAKFAST = 'statistic-breakfast';
  static const String STATISTIC_LUNCH = 'statistic-lunch';
  static const String STATISTIC_DINNER = 'statistic-dinner';
  static const String STATISTIC_GUEST = 'statistic-guest';
  static const String STATISTIC_ADULT = 'statistic-adult';
  static const String STATISTIC_CHILD = 'statistic-child';
  static const String STATISTIC_PAY_AT_HOTEL = 'statistic-pay-at-hotel';
  static const String STATISTIC_PREPAID = 'statistic-prepaid';
  static const String STATISTIC_NIGHT = 'statistic-night';
  static const String STATISTIC_AVERAGE_RATE = 'statistic-average-rate';
  static const String STATISTIC_TOTAL_HOTELS = 'statistic-total-hotels';
  static const String STATISTIC_TOTAL_USERS = 'statistic-total-users';
  static const String STATISTIC_TOTAL_MEMBER = 'statistic-total-member';
  static const String STATISTIC_LIQUIDATION = 'statistic-liquidation';
  static const String STATISTIC_ACCOUNTING = 'statistic-accounting';
  static const String STATISTIC_ACTUAL_PLAYMENT = 'statistic-actual-payment';
  static const String STATISTIC_COUNTRY = 'statistic-country';
  static const String STATISTIC_TYPE_TOURISTS = 'statistic-type-tourists';
  static const String STATISTIC_ROOM_AMOUNT = 'statistic-room-amount';

  //service cat
  static const String SERVICE_CATEGORY_MINIBAR = 'service-cat-minibar';
  static const String SERVICE_CATEGORY_RESTAURANT = 'service-cat-restaurant';
  static const String SERVICE_CATEGORY_INSIDE_RESTAURANT =
      'service-cat-inside-restaurant';
  static const String SERVICE_CATEGORY_OUTSIDE_RESTAURANT =
      'service-cat-outside-restaurant';
  static const String SERVICE_CATEGORY_EXTRA_GUEST = 'service-cat-extra-guest';
  static const String SERVICE_CATEGORY_LAUNDRY = 'service-cat-laundry';
  static const String SERVICE_CATEGORY_BIKE_RENTAL = 'service-cat-bike-rental';
  static const String SERVICE_CATEGORY_OTHER = 'service-cat-other';
  static const String SERVICE_CATEGORY_EXTRA_HOUR = 'service-cat-extra-hour';
  static const String SERVICE_CATEGORY_ELECTRICITY = 'service-cat-electricity';
  static const String SERVICE_CATEGORY_WATER = 'service-cat-water';

  //language
  static const String LANGUAGE_ENGLISH = 'language-english';
  static const String LANGUAGE_VIETNAMESE = 'language-vietnamese';

  static const String TOTAL_PAYMENT_IN_CASH = 'total-payment-in-cash';
  // ota rate plan
  static const String CAN_NOT_UPDATE_RATE_PLAN_BOOKING_GROUP =
      'can-not-update-rate-plan-booking-group';
  static const String CAN_NOT_UPDATE_DATE_IN_OUT_WITH_BOOKING_FROM_OTA =
      'can-not-update-date-in-out-with-booking-from-ota';

  //unit
  static const String UNIT_KG = 'kg';
  static const String UNIT_HOUR = 'hour';
  static const String UNIT_PCS = 'pcs';
  static const String UNIT_CAN = 'can';
  static const String UNIT_CUP = 'cup';
  static const String UNIT_PLATE = 'plate';
  static const String UNIT_LITER = 'liter';
  static const String UNIT_JAR = 'jar';
  static const String UNIT_BOTTLE = 'bottle';
  static const String UNIT_GLASS = 'glass';
  static const String UNIT_PACKAGE = 'package';
  static const String UNIT_BOX = 'box';
  static const String UNIT_TUBE = 'tube';
  static const String UNIT_PORTION = 'portion';
  static const String UNIT_SET = 'set';
  static const String UNIT_ROLL = 'roll';

  static const String UNIT_ERRO_AT_LINE = 'unit-error-at-line';
  static const String NAME_ITEM_ISEMPTY = 'name-item-isemty-at-line';
  //cost management
  static const String MUST_CONFIGURE_ACCOUNTING_TYPE_FIRST =
      'must-configure-accounting-type-first';
  static const String SUPPLIER_NOT_FOUND = 'supplier-not-found';
  static const String ACTUAL_PAYMENT_NOT_FOUND = 'actual-payment-not-found';
  static const String SAME_STATUS_ACTUAL_PAYMENT = 'same-status-actual-payment';
  static const String
      AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST =
      'amount-can-not-less-than-actual-payment-please-delete-actual-payment-first';
  static const String METHOD_PAYMENT_NOT_FOUND = 'method-payment-not-found';
  static const String MUST_DELETE_ACTUAL_PAYMENT_COLLECTION =
      'must-delete-actual-payment-collection';
  static const String COST_MANAGEMENT_NOT_FOUND = 'cost-management-not-found';
  static const String INVALID_STATUS = 'invalid-status';
  static const String COPIED_TO_CLIPBOARD = 'copied-to-clipboard';
  static const String PLEASE_UPDATE_PACKAGE_HOTEL =
      'please-update-package-hotel';
  static const String SLIDE_TO_ADJUST_SIZE = 'slide-to-adjust-size';
  static const String TODAY_PROGRESS = 'today-progress';
  static const String PAGE_AND_TOTAL = 'page-and-total';
  static const String PERFORMED_BY = 'performed-by';
  static const String CREATE_OVERHOUR_BOOKING =
      'you-create-a-booking-than-24-hours-please-create-a-booking-daily';

  //content thankyou
  static const String CONTENT_THANKYOU = 'content-thankyou';
}

class MessageUtil {
  MessageUtil._();

  static final Map<String, Map<String, String>?> messageMap = {
    MessageCodeUtil.INTERNAL: {'en': 'Error server!', 'vi': 'Lỗi máy chủ!'},
    "Null": {'en': 'Successfully!', 'vi': 'Thành công!'},
    '': {'en': 'Successfully!', 'vi': 'Thành công!'},
    MessageCodeUtil.UNAUTHORIZED: {
      'en': 'You must sign in first!',
      'vi': 'Bạn cần phải đăng nhập!'
    },
    MessageCodeUtil.USER_NOT_BE_AUTHORIZED: {
      'en': 'You have not been authorized yet to do this action .',
      'vi': 'Bạn không có quyền hạn cho chức năng này .'
    },
    MessageCodeUtil
        .NOT_ALLOWED_TO_BE_MODIFIED_PRIOR_TO_THE_FINANCIAL_CLOSING_DATE: {
      'en': "Not allowed to be modified prior to the financial settlement date",
      'vi': 'Không được chỉnh sửa(xóa) trước ngày quyết toán tài chính'
    },
    MessageCodeUtil.NOT_ALLOWED_TO_CREATE_BEFORE_THE_FINANCIAL_CLOSING_DATE: {
      'en': "Not allowed to create before the financial closing date",
      'vi': 'Không được tạo mới phiếu trước ngày quyết toán tài chính'
    },
    MessageCodeUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_45DAYS: {
      'en': "Only allowed to modify within 45 days",
      'vi': 'Chỉ cho phép thay đổi dữ liệu trong vòng 45 ngày'
    },
    MessageCodeUtil.ONLY_ALLOWED_TO_MODIFY_WITHIN_24H: {
      'en': "Only allowed to modify within 24 hours",
      'vi': 'Chỉ cho phép thay đổi dữ liệu trong vòng 24 giờ'
    },
    MessageCodeUtil.INVENTORY_CONFIRM_COMPLETE_CHECKING: {
      'en':
          'There are items that have not been entered into the actual inventory. You can either remove these items from the inventory checklist or continue to enter them into the actual inventory',
      'vi':
          'Có những mặt hàng chưa được nhập tồn kho thực tế. Bạn có thể chọn loại bỏ những mặt hàng này khỏi danh sách kiểm tra tồn kho hoặc tiếp tục nhập tồn kho thực tế'
    },
    MessageCodeUtil.NOT_HAVE_PERMISSION_EXPORT_WAREHOUSE: {
      'en': 'Need to grant role for export ware house',
      'vi': 'Cần được cấp quyền để tạo phiếu xuất'
    },
    MessageCodeUtil.NOT_HAVE_PERMISSION_IMPORT_WAREHOUSE: {
      'en': 'Need to grant role for import ware house',
      'vi': 'Cần được cấp quyền để tạo phiếu nhập'
    },
    MessageCodeUtil.WAREHOUSE_NOTE_HAS_BEEN_DELETED_UNABLE_TO_DISPLAY: {
      'en': 'Warehouse note has been deleted, unable to display',
      'vi': 'Phiếu nhập tương ứng đã bị xóa, không thể hiển thị'
    },
    MessageCodeUtil.CONFIRM_EDIT_iMPORT_NOTE: {
      'en':
          'The total amount is less than the total cost. Are you sure you want to proceed or not?',
      'vi':
          'Tổng tiền nhỏ hơn tổng chi phí, bạn có chắc chắn muốn tiếp tục thao tác không?'
    },
    MessageCodeUtil.CONFIRM_DELETE_iMPORT_NOTE: {
      'en':
          'This import note has incurred costs. Are you sure you want to delete it?',
      'vi':
          'Phiếu nhập kho này đã được tạo chi phí, bạn có chắc chắn muốn xóa không?'
    },
    MessageCodeUtil.CONFIRM_DEACTIVE_STILL_HAVE_ITEMS: {
      'en': 'Still have items in warehouse, Are you sure to deactivate %s?',
      'vi': 'Vẫn còn hàng trong kho, Bạn có muốn vô hiệu hóa %s?'
    },
    MessageCodeUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_IMPORT_NOTE: {
      'en': 'Cannot find the corresponding warehouse import note',
      'vi': 'Không thể tìm thấy phiếu nhập kho tương ứng'
    },
    MessageCodeUtil.CANNOT_FIND_THE_CORRESPONDING_WAREHOUSE_RETURN_NOTE: {
      'en': 'Cannot find the corresponding warehouse return note',
      'vi': 'Không thể tìm thấy phiếu trả hàng tương ứng'
    },
    MessageCodeUtil.CAN_NOT_FIND_INVOICE_NUMBER: {
      'en': 'Can not find invoice number',
      'vi': 'Không thể tìm thấy mã hóa đơn'
    },
    MessageCodeUtil.INVOICE_NUMBER_CAN_NOT_BE_EMPTY: {
      'en': 'Invoice number can not be empty',
      'vi': 'Mã hóa đơn không được để trống'
    },
    MessageCodeUtil.CAN_NOT_FOUND_INVOICE: {
      'en': 'Can not find invoice',
      'vi': 'Không thể tìm thấy hóa đơn'
    },
    MessageCodeUtil.INVOICE_NUMBER_DUPLICATED: {
      'en': "Invoice number has been duplicated",
      'vi': 'Mã hóa đơn trùng lặp'
    },
    MessageCodeUtil
        .TEXTALERT_ITEMS_HAVE_NOT_BEEN_SET_DEFAULT_WAREHOUSE_FOR_INGREDIENTS: {
      'en':
          'Several items have not been set with a default warehouse. Click on the item below to navigate to the [configuration - item] page.',
      'vi':
          'Một vài mặt hàng chưa thiết lập kho mặc định. Click vào mặt hàng bên dưới để chuyển tiếp đến trang [Cấu hình - mặt hàng].'
    },
    MessageCodeUtil.UNDEFINED_ERROR: {
      'en': 'Undefined error!',
      'vi': 'Lỗi không xác định!'
    },
    MessageCodeUtil.FAILED: {'en': 'Failed!', 'vi': 'Thất bại!'},
    'hotel-not-found': {
      'en': 'Hotel is not found!',
      'vi': 'Không tìm thấy khách sạn!'
    },
    MessageCodeUtil.FORBIDDEN: {
      'en': 'You have no permission to do!',
      'vi': 'Bạn không đủ quyền hạn!'
    },
    MessageCodeUtil.DEADLINE_EXCEEDED: {
      'en': 'Time out!',
      'vi': 'Quá thời gian!'
    },
    MessageCodeUtil.DUPLICATED_ID: {
      'en': 'ID is duplicated!',
      'vi': 'Trùng ID!'
    },
    MessageCodeUtil.DUPLICATED_NAME: {
      'en': 'Name is duplicated!',
      'vi': 'Trùng tên!'
    },
    MessageCodeUtil.DUPLICATED_ITEM: {
      'en': 'Item is duplicated!',
      'vi': 'Trùng mặt hàng!'
    },
    MessageCodeUtil.DUPLICATED_MAPPING_SOURCE: {
      'en': 'Source (CMS) is duplicated!',
      'vi': 'Nguồn (CMS) bị trùng!'
    },
    'bad-request': {'en': 'Invalid argument!', 'vi': 'Tham số không hợp lệ!'},
    MessageCodeUtil.BOOKING_NOT_IN_BOOKED_STATUS: {
      'en': '%s was not in Booked status!',
      'vi': '%s không ở trạng thái Booked!'
    },
    MessageCodeUtil.THE_SAME_ROOM: {
      'en': 'This room is the same as before!',
      'vi': 'Phòng trùng với phòng cũ!'
    },
    MessageCodeUtil.BOOKING_OVER_TIME_CHANGE_ROOM: {
      'en': 'Time over to change room.',
      'vi': 'Quá thời gian đổi phòng.'
    },
    MessageCodeUtil.CAN_NOT_CANCEL_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT: {
      'en': 'Have booking was checkout, please not cancel this booking.',
      'vi': 'Có booking đã checkout, vui lòng không hủy booking này.'
    },
    MessageCodeUtil.CAN_NOT_NO_SHOW_BOOKING_WHEN_GROUP_HAVE_BOOKING_OUT: {
      'en': 'Have booking was checkout, please not no show this booking.',
      'vi': 'Có booking đã checkout, vui lòng không no show booking này.'
    },
    MessageCodeUtil.DEPOSIT_HAS_BEEN_FEFUND_CANNOT_BE_CHANGHED: {
      'en': 'Deposit has been refund cannot be changed SID.',
      'vi': 'Tiền đặt cọc đã được hoàn trả không thể thay đổi SID.'
    },
    MessageCodeUtil.DEPOSIT_HAS_BEEN_FEFUND_CANNOT_DELETE: {
      'en': 'Deposit has been refund cannot delete.',
      'vi': 'Tiền đặt cọc đã được hoàn trả không thể xóa.'
    },
    MessageCodeUtil.THE_REMAINING_DEPOSIT_IS_NOT_ENOUGH: {
      'en': 'The remaining deposit is not enough.',
      'vi': 'Số tiền cọc còn lại không đủ.'
    },
    MessageCodeUtil.PLEASE_REFUND_THE_DEPOSIT_TO_THE_GUEST: {
      'en': 'Please refund the deposit to the guest.',
      'vi': 'Vui lòng hoàn lại tiền đặt cọc cho khách.'
    },
    MessageCodeUtil.BOOKING_OVER_TIME_UNDO_CHECKIN: {
      'en': 'Time over to undo check-in the booking!',
      'vi': 'Quá thời gian hoàn tác nhận phòng!'
    },
    MessageCodeUtil.BOOKING_MUST_PAY_REMAINING_BEFORE_CHECKOUT: {
      'en': 'Must pay %s of the remaining before checking out!',
      'vi': 'Vui lòng thanh toán số tiền %s còn thiếu!'
    },
    MessageCodeUtil.BOOKING_GROUP_HAVE_REMAINING_BEFORE_CHECKOUT: {
      'en':
          'Group still have %s of the remaining, do you want checkout for %s!',
      'vi':
          'Đoàn này chưa thanh toán số tiền %s còn thiếu, bạn có muốn checkout cho %s!'
    },
    MessageCodeUtil.TOTAL_PAYMENT_IN_CASH: {
      'en': 'Total payment in cash from %s to %s',
      'vi': 'Tổng thanh toán tiền mặt từ ngày %s đến ngày %s'
    },
    MessageCodeUtil.BOOKING_MUST_CHECKOUT_BIKES: {
      'en': 'All bike rentals of booking must be checked out!',
      'vi': 'Vui lòng trả xe trước khi Trả phòng!'
    },
    MessageCodeUtil.BOOKING_CAN_NOT_UNDO_CHECKOUT_BECAUSE_CONFLIX_ROOM: {
      'en':
          'Cannot undo check-out because this room was checked-in by another booking!',
      'vi':
          'Không thể hoàn tác trả phòng vì phòng đang được thuê bởi người khác!'
    },
    MessageCodeUtil.BOOKING_WRONG_TRANSFERRED: {
      'en': 'Choose transferred booking',
      'vi': 'Chọn đặt phòng sẽ thanh toán hộ'
    },
    MessageCodeUtil.ALREADY_EXIST_OTA_IN_BOOKING: {
      'en': 'There is already OTA payment in %s!',
      'vi': '%s đã có khoản thanh toán từ OTA!'
    },
    MessageCodeUtil.OVER_MAX_LENGTHDAY_31: {
      'en':
          'Please not create booking with length stay > ${GeneralManager.maxLengthStay} days!',
      'vi':
          'Bạn không được tạo đặt phòng có số ngày lớn hơn ${GeneralManager.maxLengthStay}!'
    },
    MessageCodeUtil.OVER_MAX_LENGTHDAY_365: {
      'en': 'Please not create booking with length stay > 365 days!',
      'vi': 'Bạn không được tạo đặt phòng có số ngày lớn hơn 365!'
    },
    MessageCodeUtil.OUTDATE_MUST_LARGER_THAN_INDATE: {
      'en': 'Out date must be larger than in date!',
      'vi': 'Ngày trả phòng phải lớn hơn ngày nhận phòng!'
    },
    MessageCodeUtil.INDATE_MUST_NOT_IN_PAST: {
      'en': 'In date must not be in the past!',
      'vi': 'Ngày nhận phòng không được là ngày quá khứ!'
    },
    MessageCodeUtil.OUTDATE_CAN_NOT_IN_PAST: {
      'en': 'Out date can not be in the past!',
      'vi': 'Ngày trả phòng không thể ở quá khứ!'
    },
    MessageCodeUtil.IN_PROGRESS: {'en': 'In progress!', 'vi': 'Đang xử lý!'},
    MessageCodeUtil.ALL: {'en': 'All', 'vi': 'Tất cả'},
    MessageCodeUtil.NO: {'en': 'No', 'vi': 'Không'},
    MessageCodeUtil.INVALID_DAY: {
      'en': 'Invalid date!',
      'vi': 'Ngày không hợp lệ!'
    },
    MessageCodeUtil.INVALID_VERSION: {
      'en': 'Invalid version!',
      'vi': 'Phiên bản không hợp lệ!'
    },
    MessageCodeUtil.INVALID_PRICE: {
      'en': 'Invalid price!',
      'vi': 'Giá tiền không hợp lệ!'
    },
    MessageCodeUtil.INVALID_CMND_CCCD: {
      'en': 'CMND/CCCD must have 9 or 12 characters',
      'vi': 'CMND/CCCD phải chứa 9 hoặc 12 kí tự'
    },
    MessageCodeUtil.INVALID_NATIONAL_ADDRESS: {
      'en': 'Invalid national address',
      'vi': 'Địa chỉ quốc gia không hợp lệ'
    },
    MessageCodeUtil.INVALID_CITY_ADDRESS: {
      'en': 'Invalid city address',
      'vi': 'Địa chỉ thành phố không hợp lệ'
    },
    MessageCodeUtil.INVALID_DISTRICT_ADDRESS: {
      'en': 'Invalid district address',
      'vi': 'Địa chỉ quận huyện không hợp lệ'
    },
    MessageCodeUtil.INVALID_COMMUNE_ADDRESS: {
      'en': 'Invalid commune address',
      'vi': 'Địa chỉ phường xã không hợp lệ'
    },
    MessageCodeUtil.INVALID_ITEM: {
      'en': 'Invalid item',
      'vi': 'Mặt hàng không hợp lệ'
    },
    MessageCodeUtil.INVALID_EMAIL: {
      'en': 'Please input valid email!',
      'vi': 'Vui lòng nhập email hợp lệ!'
    },
    MessageCodeUtil.DIRECT_TO_DELETE_BUTTON: {
      'en':
          'Do you want to delete all items? Please click Delete button if you want.',
      'vi': 'Bạn đang muốn xoá hết hoá đơn này? Hãy bấm vào nút Xoá.'
    },
    MessageCodeUtil.EMAIL_NOT_FOUND: {
      'en': 'Cannot find email!',
      'vi': 'Không thể tìm thấy email!'
    },
    MessageCodeUtil.EMAIL_EXISTED: {
      'en': 'Employee with this email has existed in the hotel!',
      'vi': 'Nhân viên với email này đã có trong khách sạn!'
    },
    MessageCodeUtil.EMAIL_REGISTED: {
      'en': 'Email has been registed!',
      'vi': 'Email đã được đăng ký!'
    },
    MessageCodeUtil.UNAUTHENTICATED_USER: {
      'en': 'Unauthenticated user!',
      'vi': 'Người dùng chưa xác thực!'
    },
    MessageCodeUtil.CAN_NOT_REMOVE_YOURSELFT: {
      'en': 'Cannot remove yourself!',
      'vi': 'Không thể tự xóa tài khoản của bạn khỏi khách sạn!'
    },
    MessageCodeUtil.NATIONAL_ID_DUPLICATED: {
      'en': 'National ID is duplicated!',
      'vi': 'Số CCCD bị trùng!'
    },
    MessageCodeUtil.SERVICE_NOT_FOUND: {
      'en': 'Cannot find service!',
      'vi': 'Không thể tìm thấy dịch vụ!'
    },
    MessageCodeUtil.ITEMTYPE_NOT_FOUND: {
      'en': 'Cannot find item type!',
      'vi': 'Không thể tìm thấy loại mặt hàng!'
    },
    MessageCodeUtil.JUST_FOR_CHECKIN_OR_REPAIR_BOOKING: {
      'en': 'Just for checked-in or repaired booking',
      'vi': 'Chỉ dành cho đặt phòng đã nhận phòng hoặc sửa chữa!'
    },
    MessageCodeUtil.MIN_PRICE_MUST_SMALLER_THAN_PRICE: {
      'en': 'Min rate must be smaller than rack rate',
      'vi': 'Giá tối thiểu phải bé hơn giá công bố!'
    },
    MessageCodeUtil.NEED_TO_ADD_USER_TO_HOTEL_FIRST: {
      'en': 'You need to add empployee to your hotel first!',
      'vi': 'Bạn phải thêm nhân viên vào khách sạn trước!'
    },
    MessageCodeUtil.NEED_TO_UPDATE_INFO: {
      'en': 'You need to update your profile first!',
      'vi': 'Bạn cần phải cập nhật hồ sơ của bạn trước!'
    },
    MessageCodeUtil.NEED_TO_CHOOSE_ATLEAST_ONE_SERVICE: {
      'en': 'Please choose at least one service!',
      'vi': 'Bạn hãy chọn ít nhất một dịch vụ!'
    },
    MessageCodeUtil.CAN_NOT_AUTHORIZE_BY_YOURSELF: {
      'en': 'You cannot grant roles to yourself!',
      'vi': 'Bạn không thể tự phân quyền cho chính mình!'
    },
    MessageCodeUtil.CAN_NOT_AUTHORIZE_YOUR_BOSS: {
      'en': 'You cannot grant role to your manager!',
      'vi': 'Bạn không thể phân quyền cho cấp trên!'
    },
    MessageCodeUtil.OVER_PERCENTAGE_RANGE: {
      'en': 'Percentage must be from -100 to 100!',
      'vi': 'Phần trăm phải trong khoảng -100 tới 100!'
    },
    MessageCodeUtil.GENDER_MALE: {'en': 'Male', 'vi': 'Nam'},
    MessageCodeUtil.GENDER_FEMALE: {'en': 'Female', 'vi': 'Nữ'},
    MessageCodeUtil.GENDER_OTHER: {'en': 'Other', 'vi': 'Khác'},
    MessageCodeUtil.CHOOSE_COUNTRY: {
      'en': 'Choose country',
      'vi': 'Chọn quốc gia'
    },
    MessageCodeUtil.CHOOSE_CITY: {'en': 'Choose city', 'vi': 'Chọn thành phố'},
    MessageCodeUtil.CHOOSE_TIMEZONE: {
      'en': 'Choose timezone',
      'vi': 'Chọn múi giờ'
    },
    MessageCodeUtil.CHOOSE_CURRENCY: {
      'en': 'Choose currency',
      'vi': 'Chọn tiền tệ'
    },
    MessageCodeUtil.CHOOSE_UNIT: {'en': 'Choose unit', 'vi': 'Chọn đơn vị'},
    MessageCodeUtil.CHOOSE_ITEM: {'en': 'Choose item', 'vi': 'Chọn mặt hàng'},
    MessageCodeUtil.PLEASE_CHOOSE_CHECKBOX: {
      'en': 'Please choose at least one',
      'vi': 'Vui lòng chọn ít nhất một'
    },
    MessageCodeUtil.PLEASE_CHOOSE_NATIONALITY: {
      'en': 'Please choose valid nationality',
      'vi': 'Vui lòng chọn quốc tịch hợp lệ'
    },
    MessageCodeUtil.PLEASE_CHOOSE_ADDRESS: {
      'en': 'Please choose valid address',
      'vi': 'Vui lòng chọn địa chỉ hợp lệ'
    },
    MessageCodeUtil.PLEASE_CHOOSE_COUNTRY: {
      'en': 'Please choose country',
      'vi': 'Vui lòng chọn quốc gia'
    },
    MessageCodeUtil.PLEASE_CHOOSE_WAREHOUSE: {
      'en': 'Please choose warehouse',
      'vi': 'Vui lòng chọn Kho'
    },
    MessageCodeUtil.PLEASE_CHOOSE_RIGHT_COUNTRY: {
      'en': 'Please choose right country',
      'vi': 'Vui lòng chọn đúng quốc gia'
    },
    MessageCodeUtil.PLEASE_INPUT_DOC_ID_FOR_GUEST_DECLARATION: {
      'en':
          'Please input at least 1 of 3: CMND/CCCD or Passport or Other document',
      'vi':
          'Vui lòng nhập ít nhất 1 trong 3: CMND/CCCD hoặc Số hộ chiếu hoặc Giấy tờ khác'
    },
    MessageCodeUtil.PLEASE_RESCAN: {
      'en': 'Please re-scan!',
      'vi': 'Vui lòng quét lại'
    },
    MessageCodeUtil.ADD_BOOKING_AT_ROOM_SUCCESS: {
      'en': 'Added booking %s at room %s!',
      'vi': 'Đã thêm đặt phòng %s tại phòng %s!'
    },
    MessageCodeUtil.BOOKING_AT_ROOM_UPDATE_SUCCESS: {
      'en': 'Updated booking %s at room %s!',
      'vi': 'Đã cập nhật đặt phòng %s tại phòng %s!'
    },
    MessageCodeUtil.BOOKING_CHECKIN_SUCCESS: {
      'en': 'Checked in booking %s successfully!',
      'vi': '%s nhận phòng thành công!'
    },
    MessageCodeUtil.BOOKING_CHECKOUT_SUCCESS: {
      'en': 'Checked out booking %s successfully!',
      'vi': '%s trả phòng thành công!'
    },
    MessageCodeUtil.BOOKING_CANCEL_SUCCESS: {
      'en': 'Cancelled booking %s successfully!',
      'vi': 'Hủy đặt phòng %s thành công!'
    },
    MessageCodeUtil.BOOKING_VIRTUAL_DUPLICATED: {
      'en': 'Virtual booking is duplicated!',
      'vi': 'Trùng đặt phòng ảo!'
    },
    MessageCodeUtil.BOOKING_UNDO_CHECKIN_SUCCESS: {
      'en': 'Undo check-in booking %s successfully!',
      'vi': '%s hoàn tác nhận phòng thành công!'
    },
    MessageCodeUtil.BOOKING_UNDO_CHECKOUT_SUCCESS: {
      'en': 'Undo check-out booking %s successfully!',
      'vi': '%s hoàn tác trả phòng thành công!'
    },
    MessageCodeUtil.BOOKING_FROM_OTA_CAN_NOT_EDIT: {
      'en': 'Cannot edit OTA booking!',
      'vi': 'Không thể chỉnh sửa đặt phòng từ OTA!'
    },
    MessageCodeUtil.BOOKING_ALREADY_SET_NONE_ROOM: {
      'en': 'Booking already set none room!',
      'vi': 'Đã chuyển booking vào trạng thái chưa xếp phòng'
    },
    MessageCodeUtil.SET_NONE_ROOM_CAN_NOT_EDIT_INFORMATION: {
      'en': 'Cannot edit informatin when set none room',
      'vi':
          'Không thể chỉnh sửa thông tin của booking khi chuyển booking vào trạng thái chưa xếp phòng'
    },
    MessageCodeUtil.BOOKING_NOT_FOUND: {
      'en': 'Booking is not found!',
      'vi': 'Không tìm thấy đặt phòng!'
    },
    MessageCodeUtil.BOOKING_NOT_CHECKIN: {
      'en': '%s was not checked in!',
      'vi': '%s chưa nhận phòng!'
    },
    MessageCodeUtil.BOOKING_NOT_CHECKOUT: {
      'en': '%s was not checked out!',
      'vi': '%s chưa trả phòng!'
    },
    MessageCodeUtil.BOOKING_NOT_REPAIR: {
      'en': '%s was not in repair status!',
      'vi': '%s không trong tình trạng sửa chữa!'
    },
    MessageCodeUtil.BOOKING_WAS_CHECKEDIN: {
      'en': 'Booking %s was checked in!',
      'vi': '%s đã nhận phòng!'
    },
    MessageCodeUtil.BOOKING_WAS_UNDO_CHECKOUT: {
      'en': 'Booking %s was undo check-out!',
      'vi': '%s đã hoàn tác trả phòng!'
    },
    MessageCodeUtil.BOOKING_CAN_NOT_UNDO_CHECKOUT_AFTER_24HOURS: {
      'en': 'Cannot undo check-out booking in previous days!',
      'vi': 'Không thể hoàn tác trả phòng cho đặt phòng ở ngày trước!'
    },
    MessageCodeUtil.BOOKING_CAN_NOT_EDIT_RATE_PLAN: {
      'en': 'Cannot edit rate plan!',
      'vi': 'Không thể thay đổi mức giá!'
    },
    MessageCodeUtil.BOOKING_CAN_NOT_EDIT_PRICE_OF_CHECKED_IN_BOOKING: {
      'en': 'Cannot edit rate of checked-in booking!',
      'vi': 'Không thể thay đổi giá tiền của đặt phòng đã nhận phòng!'
    },
    MessageCodeUtil.BOOKING_CHECKOUT_BEFORE: {
      'en': '%s was checked out before!',
      'vi': '%s đã trả phòng rồi!'
    },
    MessageCodeUtil.BOOKING_CHECKIN_CAN_NOT_MODIFY_INDAY: {
      'en': 'Cannot modify in-date of checked-in booking!',
      'vi': 'Không thể chỉnh sửa ngày nhận phòng của đặt phòng đã nhận phòng!'
    },
    MessageCodeUtil.BOOKING_WAS_CANCELLED_OR_CHECKED_OUT: {
      'en': '%s was cancelled or checked out!',
      'vi': '%s đã hủy hoặc đã trả phòng!'
    },
    MessageCodeUtil.BOOKING_HAS_DEPOSIT_OR_SERVICE: {
      'en': '%s is having payments or services!',
      'vi': '%s đang có thanh toán hoặc dịch vụ!'
    },
    MessageCodeUtil.BOOKING_RENTING_BIKES: {
      'en': '%s is renting bike(s)!',
      'vi': '%s đang thuê xe máy!'
    },
    MessageCodeUtil.BOOKING_CAN_NOT_BE_UPDATE: {
      'en': '%s cannot be update!',
      'vi': '%s không thể cập nhật!'
    },
    MessageCodeUtil.BOOKING_GROUP_CREATE_SUCCESS: {
      'en': 'Create group booking %s successfully!',
      'vi': 'Tạo đặt phòng cho đoàn %s thành công!'
    },
    MessageCodeUtil.BOOKING_GROUP_CANNOT_CHANGE_RATE_PLAN: {
      'en': 'Cannot change rate plan of group booking!',
      'vi': 'Không thể đổi mức giá cho đặt phòng của đoàn!'
    },
    MessageCodeUtil.BOOKING_GROUP_CANNOT_CHANGE_SID: {
      'en': 'Cannot change SID booking group!',
      'vi': 'Không đổi SID cho đặt phòng đoàn!'
    },
    MessageCodeUtil.BOOKING_DELETE_REPAIR_SUCCESS: {
      'en': "Deleted repair for room %s successfully!",
      'vi': 'Xóa trạng thái sửa chữa phòng %s thành công!'
    },
    MessageCodeUtil.BOOKING_DELETE_REPAIR_FAIL: {
      'en': 'Failed to delete repair!',
      'vi': 'Xóa trạng thái sửa chữa thất bại!'
    },
    MessageCodeUtil.INVALID_SALER: {
      'en': 'Please check email saler have exist!',
      'vi': 'Vui lòng kiểm tra email người bán có tồn tại!'
    },
    MessageCodeUtil.INVALID_DATA_WRONG_FILE: {
      'en': 'Your data is invalid (wrong file)!',
      'vi': 'Dữ liệu của bạn không hợp lệ, file không hợp lệ!'
    },
    MessageCodeUtil.INVALID_DATA_DOWNLOAD_TO_FIX: {
      'en': 'Download file below to fix!',
      'vi': 'Tải file bên dưới để chỉnh sửa!'
    },
    MessageCodeUtil.STILL_NOT_CHANGE_VALUE: {
      'en': 'You have not changed values yet!',
      'vi': 'Bạn chưa thay đổi dữ liệu!'
    },
    MessageCodeUtil.ROOMTYPE_MIN_PRICE: {
      'en': 'Min rate must be smaller than rack rate!',
      'vi': 'Giá thấp nhất phải bé hơn giá công bố!'
    },
    MessageCodeUtil.ROOMTYPE_DONT_HAVE_ENOUGH_QUATITY: {
      'en': 'Not enough room!',
      'vi': 'Số lượng phòng ko đủ!'
    },
    MessageCodeUtil.NO_ITEM_ADDED: {
      'en': 'No item to be added!',
      'vi': 'Bạn chưa thêm các mặt hàng!'
    },
    MessageCodeUtil.CAN_NOT_BE_EMPTY: {
      'en': 'The required fields (*) must not be empty!',
      'vi': 'Các trường bắt buộc (*) không được để trống!'
    },
    MessageCodeUtil.NOT_BELONG_TO_ANY_HOTEL: {
      'en':
          'There is not any hotel to choose. Please request your hotel owner or manager to add you to their hotels!',
      'vi':
          'Không có khách sạn nào để chọn. Vui lòng yêu cầu chủ khách sạn hoặc quản lý của bạn để thêm vào khách sạn!'
    },
    MessageCodeUtil.STILL_NOT_BE_AUTHORIZED: {
      'en':
          'You have not been authorized yet. Please contact your hotel owner or manager!',
      'vi': 'Bạn vẫn chưa được cấp quyền. Vui lòng liên hệ quản lý của bạn!'
    },
    MessageCodeUtil.SID_MUST_NOT_CONTAIN_SPECIFIC_CHAR: {
      'en': 'SID must not contain special characters!',
      'vi': 'SID không được chứa kí tự đặc biệt!'
    },
    MessageCodeUtil.SID_CAN_NOT_BE_EMPTY: {
      'en': 'SID can not be empty',
      'vi': 'SID không được để trống'
    },
    MessageCodeUtil.PAYMENT_METHOD_CAN_NOT_BE_EMPTY: {
      'en': 'Payment method can not be empty',
      'vi': 'Phương thức thanh toán không được để trống'
    },
    MessageCodeUtil.CAN_NOT_CHANGE_DATA_AND_STATUS_AT_THE_SAME_TIME: {
      'en': 'Can not change data and change status at the same time',
      'vi': 'Không thể chỉnh sửa dữ liệu và tình trạng cùng lúc'
    },
    MessageCodeUtil.NATIONAL_ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR: {
      'en': 'National ID must not contain special characters!',
      'vi': 'CCCD không được chứa kí tự đặc biệt!'
    },
    MessageCodeUtil.NAME_MUST_NOT_CONTAIN_SPECIFIC_CHAR: {
      'en': 'Name must not contain special characters!',
      'vi': 'Tên không được chứa kí tự đặc biệt!'
    },
    MessageCodeUtil.STREET_MUST_NOT_CONTAIN_SPECIFIC_CHAR: {
      'en': 'Street must not contain special characters!',
      'vi': 'Đường không được chứa kí tự đặc biệt!'
    },
    MessageCodeUtil.NAME_CAN_NOT_BE_BLANK: {
      'en': 'Name must not be blank!',
      'vi': 'Tên không được để trống!'
    },
    MessageCodeUtil.STREET_CAN_NOT_BE_BLANK: {
      'en': 'Street must not be blank!',
      'vi': 'Đường không được để trống!'
    },
    MessageCodeUtil.ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR: {
      'en': 'ID must not contain special characters!',
      'vi': 'ID không được chứa kí tự đặc biệt!'
    },
    MessageCodeUtil.ID_CAN_NOT_BE_BLANK: {
      'en': 'ID must not be blank!',
      'vi': 'ID không được để trống!'
    },
    MessageCodeUtil.SID_OVER_MAXIMUM_CHARACTERS: {
      'en': 'Maximum length of SID is 16 characters!',
      'vi': 'SID không được vượt quá 16 kí tự!'
    },
    MessageCodeUtil.PHONE_OVER_MAXIMUM_NUMBER: {
      'en': 'Maximum length of phone is 16 number!',
      'vi': 'Số điện thoại không được vượt quá 16 số!'
    },
    MessageCodeUtil.PRICE_OVER_MAXIMUM_NUMBER: {
      'en': 'Maximum length of price is 12 number!',
      'vi': 'Số tiền không được vượt quá 12 số!'
    },
    MessageCodeUtil.ID_OVER_MAXIMUM_CHARACTERS: {
      'en': 'Maximum length of ID is 16 characters!',
      'vi': 'ID không được vượt quá 16 kí tự!'
    },
    MessageCodeUtil.PHONE_SMALLER_THAN_MINIMUM_LENGTH: {
      'en': 'Phone must contain more than 6 numbers!',
      'vi': 'Điện thoại phải nhập nhiều hơn 6 số!'
    },
    MessageCodeUtil.NATIONAL_ID_OVER_MAXIMUM_CHARACTERS: {
      'en': 'Maximum length of national-ID is 64 characters!',
      'vi': 'CCCD không được vượt quá 64 kí tự!'
    },
    MessageCodeUtil.INPUT_NUMBER: {
      'en': 'Please input a number!',
      'vi': 'Vui lòng nhập kiểu số!'
    },
    MessageCodeUtil.INPUT_PASSWORD: {
      'en': 'Please input password!',
      'vi': 'Vui lòng nhập mật khẩu!'
    },
    MessageCodeUtil.INPUT_POSITIVE_NUMBER: {
      'en': 'Please input a positive number!',
      'vi': 'Vui lòng nhập số dương!'
    },
    MessageCodeUtil.INPUT_ID: {
      'en': 'Please input ID!',
      'vi': 'Vui lòng nhập ID!'
    },
    MessageCodeUtil.INPUT_SID: {
      'en': 'Please input SID!',
      'vi': 'Vui lòng nhập SID!'
    },
    MessageCodeUtil.INPUT_NAME: {
      'en': 'Please input name!',
      'vi': 'Vui lòng nhập tên!'
    },
    MessageCodeUtil.INPUT_FIRST_NAME: {
      'en': 'Please input first name!',
      'vi': 'Vui lòng nhập tên!'
    },
    MessageCodeUtil.INPUT_FULL_NAME: {
      'en': 'Please input full name!',
      'vi': 'Vui lòng nhập họ và tên!'
    },
    MessageCodeUtil.INPUT_ONLY_LETTERS: {
      'en': 'Input only letters!',
      'vi': 'Chỉ nhập chữ cái!'
    },
    MessageCodeUtil.INPUT_LAST_NAME: {
      'en': 'Please input last name!',
      'vi': 'Vui lòng nhập họ!'
    },
    MessageCodeUtil.INPUT_AMOUNT: {
      'en': 'Please input amount!',
      'vi': 'Vui lòng nhập số lượng!'
    },
    MessageCodeUtil.INPUT_STREET: {
      'en': 'Please input street!',
      'vi': 'Vui lòng nhập tên đường!'
    },
    MessageCodeUtil.INPUT_PHONE: {
      'en': 'Please input phone!',
      'vi': 'Vui lòng nhập số điện thoại!'
    },
    MessageCodeUtil.INPUT_ADDRESS: {
      'en': 'Please input address!',
      'vi': 'Vui lòng nhập địa chỉ!'
    },
    MessageCodeUtil.INPUT_NATIONAL_ID: {
      'en': 'Please input national ID!',
      'vi': 'Vui lòng nhập CCCD!'
    },
    MessageCodeUtil.INPUT_AT_LEAST_ONE_ROLE: {
      'en': 'Please choose at least one role!',
      'vi': 'Vui lòng chọn ít nhất một vai trò!'
    },
    MessageCodeUtil.INPUT_ADULT_AND_CHILD: {
      'en': 'Please input numeber of adult and child!',
      'vi': 'Vui lòng nhập số người lớn và trẻ em!'
    },
    MessageCodeUtil.INPUT_PRICE: {
      'en': 'Please input rate!',
      'vi': 'Vui lòng nhập giá tiền!'
    },
    MessageCodeUtil.INPUT_PAYMENT: {
      'en': 'Please input payment!',
      'vi': 'Vui lòng nhập số tiền thanh toán!'
    },
    MessageCodeUtil.INPUT_NUM_GUEST: {
      'en': 'Please input guest number!',
      'vi': 'Vui lòng nhập số lượng khách!'
    },
    MessageCodeUtil.INPUT_SERVICE_FEE: {
      'en': 'Please input service fee!',
      'vi': 'Vui lòng nhập phí dịch vụ!'
    },
    MessageCodeUtil.INPUT_VAT: {
      'en': 'Please input VAT.',
      'vi': 'Vui lòng nhập VAT.'
    },
    MessageCodeUtil.INPUT_NON_NEGATIVE_NUMBER: {
      'en': 'Please input non-negative number!',
      'vi': 'Vui lòng nhập số không âm!'
    },
    MessageCodeUtil.INPUT_ADULT_PRICE: {
      'en': 'Please input price of extra adult!',
      'vi': 'Vui lòng nhập giá phụ thu người lớn!'
    },
    MessageCodeUtil.INPUT_CHILD_PRICE: {
      'en': 'Please input price of extra child!',
      'vi': 'Vui lòng nhập giá phụ thu trẻ em!'
    },
    MessageCodeUtil.INPUT_EXTRA_BED_FROM_0_TO_9: {
      'en': 'Extra bed must be from 0 to 9',
      'vi': 'Số giường phải từ 0 đến 9'
    },
    MessageCodeUtil.INPUT_TAX_CODE: {
      'en': 'Please input national ID/Tax code',
      'vi': 'Vui lòng nhập CCCD/Mã số thuế'
    },
    MessageCodeUtil.INPUT_INVOICE_ADDRESS: {
      'en': 'Please input address of invoice',
      'vi': 'Vui lòng nhập địa chỉ hóa đơn'
    },
    MessageCodeUtil.INPUT_INVOICE_EMAIL: {
      'en': 'Please input email of invoice',
      'vi': 'Vui lòng nhập email hóa đơn'
    },
    MessageCodeUtil.INPUT_INVOICE_NAME: {
      'en': 'Please input Guest/Company name',
      'vi': 'Vui lòng nhập tên khách hàng/công ty'
    },
    MessageCodeUtil.INPUT_DETAIL_ADDRESS: {
      'en': 'Please input detail address',
      'vi': 'Vui lòng nhập địa chỉ chi tiết'
    },
    MessageCodeUtil.PLEASE_CHOOSE_REASON: {
      'en': 'Please choose reason',
      'vi': 'Vui lòng chọn lý do'
    },
    MessageCodeUtil.PLEASE_INPUT_PASSPORT_FOR_FOREINGER: {
      'en': 'Please input Passport for foreigner',
      'vi': 'Vui lòng nhập Hộ chiếu cho người nước ngoài'
    },
    MessageCodeUtil.PLEASE_CLICK_REFRESH_BUTTON_FIRST: {
      'en': 'Please click refresh button before export excel file.',
      'vi': 'Vui lòng nhấn nút làm mới trước khi xuất File excel.'
    },

    MessageCodeUtil.INPUT_IMAGE: {
      'en': 'Please choose image!',
      'vi': 'Vui lòng chọn ảnh!'
    },
    MessageCodeUtil.INPUT_ROOMTYPE: {
      'en': 'Please input room type!',
      'vi': 'Vui lòng chọn hạng phòng!'
    },
    MessageCodeUtil.INPUT_ROOM: {
      'en': 'Please choose room!',
      'vi': 'Vui lòng chọn phòng!'
    },
    MessageCodeUtil.INPUT_ROOM_ID_DUPLICATED_ROOM_TYPE: {
      'en': 'Room id duplicated room type id!',
      'vi': 'Id phòng bị trùng id hạng phòng!'
    },
    MessageCodeUtil.INPUT_VALID_ROOM: {
      'en': 'Please choose valid room!',
      'vi': 'Vui lòng chọn phòng hợp lệ!'
    },
    MessageCodeUtil.INPUT_TYPE_OF_BED: {
      'en': 'Please input type of bed!',
      'vi': 'Vui lòng chọn loại giường!'
    },
    MessageCodeUtil.INPUT_DESCRIPTION: {
      'en': 'Please input description!',
      'vi': 'Vui lòng nhập mô tả!'
    },
    MessageCodeUtil.INPUT_EMAIL: {
      'en': 'Please input email!',
      'vi': 'Vui lòng nhập email!'
    },
    MessageCodeUtil.INPUT_CITY_NAME: {
      'en': 'Please input city!',
      'vi': 'Vui lòng nhập thành phố!'
    },
    MessageCodeUtil.INPUT_POSITIVE_PRICE: {
      'en': 'Rate must be a positive number!',
      'vi': 'Giá tiền phải là số dương!'
    },
    MessageCodeUtil.INPUT_POSITIVE_TOTAL: {
      'en': 'Total field must contain a positive number!',
      'vi': 'Tổng tiền phải là số dương!'
    },
    MessageCodeUtil.INPUT_POSITIVE_AMOUNT: {
      'en': 'Amount must be a positive number!',
      'vi': 'Số lượng phải là số dương!'
    },
    MessageCodeUtil.AMOUNT_TRANSFER_BIGGER_THAN_CURRENT_AMOUNT: {
      'en':
          'Amount bigger than current amount, Are you sure still continue process?',
      'vi': 'Số tiền chuyển lớn hơn số tiền trong két, bạn có muốn tiếp tục'
    },
    MessageCodeUtil.OVER_RANGE_GUEST_NUMBER: {
      'en': 'Guest number must be from 0 to 100!',
      'vi': 'Số lượng khách chỉ từ 0 đến 100!'
    },
    MessageCodeUtil.OVER_RANGE_SERVICE_FEE_PERCENTAGE: {
      'en': 'Service fee must be from 0 to 100 percents!',
      'vi': 'Phí dịnh vụ phải từ 0 đến 100%!'
    },
    MessageCodeUtil.OVER_RANGE_VAT_PERCENTAGE: {
      'en': 'VAT must be from 0 to 100 percents',
      'vi': 'Thuế VAT phải từ 0 đến 100%!'
    },
    MessageCodeUtil.LOST: {'en': 'Lost', 'vi': 'Mất mát'},
    MessageCodeUtil.BROKEN: {'en': 'Broken', 'vi': 'Hư hỏng'},
    MessageCodeUtil.EXPIRED: {'en': 'Expired', 'vi': 'Hết hạn'},
    MessageCodeUtil.PAYMENT_MUST_GREATER_THAN_REMAINING: {
      'en': 'Booking has full payment or new payment is larger than remaining!',
      'vi':
          'Đặt phòng đã thanh toán đủ tiền hoặc số tiền đang thanh toán lớn hơn số tiền còn lại!'
    },
    MessageCodeUtil.ID_PAYMENT_DUPLICATED: {
      'en': 'Payment method\'s ID is duplicated!',
      'vi': 'ID của phương thức thanh toán bị trùng'
    },
    MessageCodeUtil.NAME_PAYMENT_DUPLICATED: {
      'en': 'Payment method\'s name is duplicated!',
      'vi': 'Tên của phương thức thanh toán bị trùng!'
    },
    MessageCodeUtil.PAYMENT_WAS_DELETE: {
      'en': 'Payment method was deleted!',
      'vi': 'Phương thức thanh toán này đã bị xóa!'
    },
    MessageCodeUtil.CAN_NOT_DELETE_PAYMENT: {
      'en': 'Payment method cannot be deleted!',
      'vi': 'Phương thức thanh toán này không thể xóa!'
    },
    MessageCodeUtil.PAYMENT_TRANSFER_ID_OR_BID_UNDEFINED: {
      'en': 'Transferred booking is undefined!',
      'vi': 'Đặt phòng nhận thanh toán hộ chưa được xác định!'
    },
    MessageCodeUtil.YOU_DO_NOT_UPDATE_OTHER_PEOPLE_PAYMENT: {
      'en': 'You do not update other people payemet!',
      'vi': 'Bạn không thể cập nhập thanh toán của người khác!'
    },

    MessageCodeUtil.YOU_DO_NOT_DELETE_OTHER_PEOPLE_PAYMENT: {
      'en': 'You do not delete other people payemet!',
      'vi': 'Bạn không thể xóa thanh toán của người khác!'
    },

    MessageCodeUtil.YOU_DO_NOT_DELETE_PAYMENT_STATUS_PASSED: {
      'en': 'You do not delete payemet status passed!',
      'vi': 'Bạn không thể xóa thanh toán trạng thái hoàn thành!'
    },
    MessageCodeUtil.NO_DEPOSIT_ADDED: {
      'en': 'No payment to add!',
      'vi': 'Không có thanh toán nào được thêm vào!'
    },
    MessageCodeUtil.NO_ROOM_EXTRA_CONFIGS: {
      'en':
          'There is no configuration for extra guest/hour service! Please update it in Configuration.',
      'vi':
          'Chưa có cấu hình cho Phụ thu khách & giờ! Vui lòng tuỳ chỉnh ở Cấu hình.'
    },
    MessageCodeUtil.ADD_GROUP_FIRST: {
      'en': 'Please add group first!',
      'vi': 'Vui lòng tạo đặt phòng đoàn trước!'
    },
    MessageCodeUtil.END_TIME_CAN_NOT_BEFORE_START_TIME: {
      'en': 'End time can not before start time',
      'vi': 'Thời điểm kết thúc không thể trước thời điểm bắt đầu'
    },
    MessageCodeUtil.BOOKING_GROUP_NOT_ENOUGH_ROOM: {
      'en': 'Not enough room!',
      'vi': 'Không đủ phòng!'
    },
    MessageCodeUtil.BOOKING_GROUP_ROOM_PICK_INVALID: {
      'en': 'Can not pick over the quantities of room that be entered .',
      'vi': 'Bạn không thể chọn quá số lượng phòng đã nhập .'
    },
    MessageCodeUtil.BOOKING_CONFLIX_ROOM: {
      'en': 'There are other bookings in %s!',
      'vi': 'Phòng %s đã có đặt phòng khác từ trước!'
    },
    MessageCodeUtil.BOOKING_OVERDUE_TO_CHECKIN: {
      'en': 'Over time to check in %s!',
      'vi': '%s đã quá giờ nhận phòng!'
    },
    MessageCodeUtil.BOOKING_OVERDUE_TO_CHECKOUT: {
      'en': 'Over time to check out %s!',
      'vi': '%s quá giờ trả phòng!'
    },
    MessageCodeUtil.CANT_NOT_ADD_UPDATE_BOOKING_LOCAL_WITH_OTA_RATE_PLAN: {
      'en': 'Can not add or update booking with ota rate plate',
      'vi': 'Không thể tạo hoặc cập nhật booking với rate plate là OTA'
    },

    MessageCodeUtil.CAM_NOT_CHAGE_BOOKING_TYPE: {
      'en': 'Can not chage booking type',
      'vi': 'Không thể thay đổi loại đặt phòng'
    },
    MessageCodeUtil.TEXTALERT_MOVED_TO: {
      'en': '(Moved to)',
      'vi': '(Đã di chuyển)'
    },
    MessageCodeUtil.TEXTALERT_ADULT: {'en': 'Adult', 'vi': 'Người lớn'},
    MessageCodeUtil.TEXTALERT_CHILD: {'en': 'Child', 'vi': 'Trẻ em'},
    MessageCodeUtil.TEXTALERT_MANUAL: {'en': 'Manual', 'vi': 'Xe số'},
    MessageCodeUtil.TEXTALERT_AUTO: {'en': 'Auto', 'vi': 'Xe ga'},
    MessageCodeUtil.TEXTALERT_STAYING_ROOM: {
      'en': 'Staying room',
      'vi': 'Phòng đang ở'
    },
    MessageCodeUtil.TEXTALERT_VIRTUAL_BOOKING: {
      'en': 'Virtual booking',
      'vi': 'Booking ảo'
    },
    MessageCodeUtil.TEXTALERT_CHANGE_COLOR_SUCCESS_AND_RELOAD: {
      'en': 'Change color successfully! Do you want to reload?',
      'vi': 'Đổi màu thành công. Bạn có muốn tải lại hay không?'
    },
    MessageCodeUtil.TEXTALERT_CHANGE_HOUR_SUCCESS_AND_RELOAD: {
      'en': 'Change hour successfully! Do you want to reload?',
      'vi': 'Đổi giờ thành công. Bạn có muốn tải lại hay không?'
    },

    MessageCodeUtil.TEXTALERT_CHANGE_POLICY_SUCCESS_AND_RELOAD: {
      'en': 'Change policy successfully! Do you want to reload?',
      'vi': 'Đổi chính sách thành công. Bạn có muốn tải lại hay không?'
    },
    MessageCodeUtil.TEXTALERT_OTHER_NATIONALITY: {
      'en': 'Other nationality',
      'vi': 'Quốc gia khác'
    },
    MessageCodeUtil.TEXTALERT_EXPORT_FILE_FROM_X_TO_Y: {
      'en': 'Export file from %s to %s',
      'vi': 'Xuất file từ %s đến %s'
    },
    MessageCodeUtil.TEXTALERT_EXPORT_FILE_OF_MONTH: {
      'en': 'Export file of month %s',
      'vi': 'Xuất file tháng %s'
    },
    MessageCodeUtil.TEXTALERT_MUST_UPGRADE_TO_ADV_OR_PRO: {
      'en': 'You must upgrade your plan to Advance or Professor',
      'vi': 'Bạn phải nâng cấp gói của bạn lên Advance hoặc Professor'
    },
    MessageCodeUtil.TEXTALERT_LAST_CLEAN: {
      'en': 'Last clean',
      'vi': 'Lần dọn cuối'
    },
    MessageCodeUtil.TEXTALERT_AMOUNT_MUST_BE_POSITIVE: {
      'en': 'Amount must be positive number',
      'vi': 'Số lượng phải là số dương'
    },
    MessageCodeUtil.TEXTALERT_MONEY_AMOUNT_MUST_BE_POSITIVE: {
      'en': 'Amount must be positive number',
      'vi': 'Số tiền phải là số dương'
    },
    MessageCodeUtil.TEXTALERT_WAREHOUSE_CAN_NOT_BE_EMPTY: {
      'en': 'Warehouse can not be empty',
      'vi': 'Kho không được để trống'
    },
    MessageCodeUtil.TEXTALERT_SUPPLIER_CAN_NOT_BE_EMPTY: {
      'en': 'Supplier can not be empty',
      'vi': 'Nhà cung cấp không được để trống'
    },
    MessageCodeUtil.TEXTALERT_INVALID_WAREHOUSE: {
      'en': 'Invalid warehouse',
      'vi': 'Kho không hợp lệ'
    },
    MessageCodeUtil.TEXTALERT_ONLY_SELECTED_ITEMS: {
      'en': 'Only selected items',
      'vi': 'Chỉ những vật phẩm được chọn'
    },
    MessageCodeUtil.TEXTALERT_ALL_ITEMS: {
      'en': 'All items',
      'vi': 'Tất cả mặt hàng'
    },
    MessageCodeUtil.TEXTALERT_INVALID_SUPPLIER: {
      'en': 'Invalid supplier',
      'vi': 'Nhà cung cấp không hợp lệ'
    },
    MessageCodeUtil.TEXTALERT_TYPE_CAN_NOT_BE_EMPTY: {
      'en': 'Type can not be empty',
      'vi': 'Loại không được để trống'
    },
    MessageCodeUtil.TEXTALERT_ACCOUNTING_ID_CAN_NOT_BE_EMPTY: {
      'en': 'Accounting id can not be empty',
      'vi': 'Mã accounting không được để trống'
    },
    MessageCodeUtil.TEXTALERT_METHOD_CAN_NOT_BE_EMPTY: {
      'en': 'Method can not be empty',
      'vi': 'Phương thức không được để trống'
    },
    MessageCodeUtil.TEXTALERT_YOU_SWAP_SCREEN_TOO_FAST: {
      'en': 'You swap screen too fast',
      'vi': 'Bạn chuyển màn hình quá nhanh'
    },
    MessageCodeUtil.TEXTALERT_TRY_AGAIN: {'en': 'Try again', 'vi': 'Thử lại'},
    MessageCodeUtil.TEXTALERT_PLEASE_CHOOSE_UNIT: {
      'en': 'Please choose unit',
      'vi': 'Vui lòng chọn đơn vị'
    },
    MessageCodeUtil.TEXTALERT_BOTH_OF_PRICE_CAN_NOT_BE_ZERO: {
      'en': 'Both of prices can not be zero',
      'vi': 'Cả 2 giá tiền không thể bằng 0'
    },
    MessageCodeUtil.TEXTALERT_WE_HAVE_SENT_A_PASSWORD_RESET_LINK_TO_YOUR_EMAIL:
        {
      'en': 'We have sent a password reset link to your email',
      'vi': 'Chúng tôi đã gửi link đặt lại mật khẩu về email của bạn'
    },

    MessageCodeUtil.COST_PRICE_MUST_BE_A_POSITIVE_NUMBER: {
      'en': 'Cost price must be a positive number',
      'vi': 'Giá vốn phải là 1 số dương'
    },
    MessageCodeUtil.TEXTALERT_CREATE_NEW_ACCOUNTING_TYPE: {
      'en': 'Create new accouting type',
      'vi': 'Tạo loại chi phí mới'
    },
    MessageCodeUtil.TEXTALERT_CREATE_NEW_SUPPLIER: {
      'en': 'Create new supplier',
      'vi': 'Tạo nhà cung cấp mới'
    },
    MessageCodeUtil.TEXTALERT_AMOUNT_CAN_NOT_MORE_THAN_AMOUNT_IN_IMPORT_NOTE: {
      'en': 'Amount can not more than amount in import note',
      'vi': 'Số lượng không được lớn hơn số lượng trong phiếu nhập'
    },
    MessageCodeUtil.PRICE_MUST_BE_NUMBER: {
      'en': 'Rate must not be empty and a non-negative number!',
      'vi': 'Giá tiền không được để trống và là một số không âm!'
    },
    MessageCodeUtil.ADULT_MUST_BE_NUMBER: {
      'en': 'Number of adult must not be empty and a non-negative number!',
      'vi': 'Số lượng người lớn không được để trống và là một số không âm!'
    },
    MessageCodeUtil.CHILD_MUST_BE_NUMBER: {
      'en': 'Number of child must not be empty and a non-negative number!',
      'vi': 'Số lượng trẻ em không được để trống và là một số không âm!'
    },
    MessageCodeUtil.PHONE_MUST_BE_NUMBER: {
      'en': 'Phone must not be empty and a number!',
      'vi': 'Số điện thoại không được để trống và là một số!'
    },
    MessageCodeUtil.PHONE_CAN_NOT_CONTAIN_WORD: {
      'en': 'Phone can not contain word',
      'vi': 'Số điện thoại không được chứa chữ cái'
    },
    MessageCodeUtil.ROOM_NOT_FOUND: {
      'en': 'Room is not found!',
      'vi': 'Không tìm thấy phòng!'
    },
    MessageCodeUtil.ROOM_ALREADY_HAVE_BOOKING_PLEASE_CHOOSE_ANOTHER_ROOM: {
      'en': 'Please choose another room, room already have book .',
      'vi': 'Vui lòng chọn phòng khác, phòng đã có booking .'
    },
    MessageCodeUtil.PLEASE_SELECT_THE_CORRECR_ROOM_TO_UPDATE: {
      'en': 'Please select the correct room to update!',
      'vi': 'Vui lòng chọn đúng phòng để cập nhật!'
    },
    MessageCodeUtil.ROOM_TYPE_OF_ROOM_CANNOT_EDIT: {
      'en': 'Must not change room type of room!',
      'vi': 'Không được cập nhật hạng phòng cho phòng!'
    },
    MessageCodeUtil.ROOM_CAN_NOT_CHANGE: {
      'en': 'Room of %s cannot be changed!',
      'vi': 'Phòng của %s không thể thay đổi!'
    },
    MessageCodeUtil.NO_AVAILABLE_ROOM: {
      'en': 'There is no available room!',
      'vi': 'Không có phòng trống!'
    },
    MessageCodeUtil.THIS_ROOM_NOT_AVAILABLE: {
      'en': 'Room %s is not available!',
      'vi': 'Phòng %s không khả dụng!'
    },
    MessageCodeUtil.ROOM_MUST_CLEAN: {
      'en': 'You must clean room first!',
      'vi': 'Vui lòng dọn phòng trước!'
    },
    MessageCodeUtil.BOOKING_CHANGE_TO_ROOM: {
      'en': 'Change %s to room %s successfully!',
      'vi': 'Đổi %s sang phòng %s thành công!'
    },
    MessageCodeUtil.BOOKING_NOT_TODAY_BOOKING: {
      'en': 'Not today booking!',
      'vi': 'Không phải nhận phòng ngày hôm nay!'
    },
    MessageCodeUtil.BOOKING_OVER_TIME_CHECKOUT: {
      'en': 'Time is over to check out!',
      'vi': 'Quá thời gian trả phòng!'
    },
    MessageCodeUtil.BOOKING_OVER_TIME_UNDO_CHECKOUT: {
      'en': 'Time is over to undo check out!',
      'vi': 'Quá thời gian hoàn tác trả phòng!'
    },
    MessageCodeUtil.ROOM_STILL_NOT_CHECKOUT: {
      'en': 'Room %s is still not checked out!',
      'vi': 'Phòng %s vẫn chưa trả phòng!'
    },
    MessageCodeUtil.ROOM_ID_DUPLICATED: {
      'en': 'Duplicated room ID!',
      'vi': 'Trùng ID phòng!'
    },
    MessageCodeUtil.ROOM_NAME_DUPLICATED: {
      'en': 'Duplicated room name!',
      'vi': 'Trùng tên phòng!'
    },
    MessageCodeUtil.ROOM_HAS_BOOKING_CHECKIN: {
      'en': 'This room is being used by another booking!',
      'vi': 'Phòng có khách đang ở!'
    },
    MessageCodeUtil.ROOM_WAS_DELETE: {
      'en': 'This room was deleted!',
      'vi': 'Phòng đã bị xóa!'
    },
    MessageCodeUtil.NO_ROOM: {'en': 'No room!', 'vi': 'Không có phòng!'},
    MessageCodeUtil.ROOMTYPE_ID_DUPICATED: {
      'en': 'Duplicated room type ID!',
      'vi': 'Trùng ID hạng phòng!'
    },
    MessageCodeUtil.ROOMTYPE_NAME_DUPICATED: {
      'en': 'Duplicated room type name!',
      'vi': 'Trùng tên hạng phòng!'
    },
    MessageCodeUtil.ROOMTYPE_NOT_FOUND: {
      'en': 'Room type not found!',
      'vi': 'Không tìm thấy hạng phòng!'
    },
    MessageCodeUtil.ROOMTYPE_MUST_CHOOSE_BED: {
      'en': 'Please choose bed!',
      'vi': 'Vui lòng chọn giường!'
    },
    MessageCodeUtil.ROOMTYPE_MUST_DELETE_ALL_ROOM: {
      'en': 'Please delete all rooms of this room type before deleting!',
      'vi': 'Vui lòng xóa toàn bộ phòng trước khi xoá hạng phòng!'
    },
    MessageCodeUtil.IMAGE_OVER_MAX_SIZE: {
      'en': 'Image size must be smaller than 100Kb!',
      'vi': 'Kích thước ảnh phải nhỏ hơn 100Kb!'
    },
    MessageCodeUtil.IMAGE_SIZE_MUST_EQUAL_64X64: {
      'en': 'Size of image must be 64x64!',
      'vi': 'Kích thước ảnh phải là 64x64!'
    },
    MessageCodeUtil.OVER_X_DAYS: {
      'en': 'Date range must not be larger than %s days!',
      'vi': 'Khoảng thời gian không được lớn hơn %s ngày!'
    },
    MessageCodeUtil.INVALID_DATA: {
      'en': 'Invalid data!',
      'vi': 'Dữ liệu không hợp lệ!'
    },
    MessageCodeUtil.NO_REQUEST: {
      'en': 'There is no request!',
      'vi': 'Không có yêu cầu!'
    },
    MessageCodeUtil.WRONG_APPROVAL_REQUEST: {
      'en': 'Wrong approval request!',
      'vi': 'Yều cầu không phù hợp để chấp thuận!'
    },
    MessageCodeUtil.CHANGE_BIKE_SUCCESS: {
      'en': 'Change bike successfully!',
      'vi': 'Đổi xe thành công!'
    },
    MessageCodeUtil.CHANGE_BIKE_FAIL: {
      'en': 'Failed to change bike!',
      'vi': 'Đổi xe thất bại!'
    },
    MessageCodeUtil.BIKE_RENTAL_NOT_FOUND: {
      'en': 'Bike rental is not found!',
      'vi': 'Không tìm thấy dịch vụ thuê xe!'
    },
    MessageCodeUtil.CAN_NOT_EDIT_BIKE_RENTAL: {
      'en': 'Cannot move the bike rental! %s was checked out or cancelled!',
      'vi': 'Không thể chuyển hoá đơn thuê xe! %s đã trả phòng hoặc đã hủy!'
    },
    MessageCodeUtil.CAN_NOT_TRANSFER_FOR_YOURSELF: {
      'en': 'Can not transfer for yourself!',
      'vi': 'Không thể chuyển cho chính bạn!'
    },
    MessageCodeUtil.MOVE_TO_ANOTHER_BOOKING: {
      'en': 'Moved to booking %s!',
      'vi': 'Đã được chuyển tới %s!'
    },
    MessageCodeUtil.NO_AVAILABLE_BIKE_TO_CHANGE: {
      'en': 'No available bike to change!',
      'vi': 'Không còn xe máy để đổi!'
    },
    MessageCodeUtil.BIKE_RENTAL_CAN_NOT_DEACTIVE: {
      'en': 'Cannot deactive Bike rental service!',
      'vi': 'Không thể tắt dịch vụ thuê xe máy!'
    },
    MessageCodeUtil.BIKE_WAS_CHECKED_IN: {
      'en': 'Bike was checked in',
      'vi': 'Đã nhận xe'
    },
    MessageCodeUtil.BIKE_WAS_CHECKED_OUT: {
      'en': 'Bike was checked out',
      'vi': 'Đã trả xe'
    },
    MessageCodeUtil.BIKE_WAS_RENTED: {
      'en': 'Bike was rented',
      'vi': 'Xe đã được thuê'
    },
    MessageCodeUtil.BIKE_PROGRESS_BOOKED: {'en': 'Booked', 'vi': 'Đặt xe'},
    MessageCodeUtil.BIKE_PROGRESS_IN: {'en': 'Get bike', 'vi': 'Nhận xe'},
    MessageCodeUtil.BIKE_PROGRESS_OUT: {'en': 'Return bike', 'vi': 'Trả xe'},
    MessageCodeUtil.FAIL_TO_GET_DATA_FROM_CLOUD: {
      'en': 'Failed to get data from cloud!',
      'vi': 'Lấy dữ liệu từ Cloud thất bại!'
    },

    MessageCodeUtil.HOTELS_USING_THIS_THIS_PACKAGE_CANNOT_BE_DELETED: {
      'en': 'Hotels using this package cannot be deleted!',
      'vi': 'Khách sạn đang sử dụng gói này không thể xóa!'
    },

    MessageCodeUtil.THE_PACKAGE_IS_STILL_EXPIRED: {
      'en': 'The package is still expired!',
      'vi': 'Gói còn hạn sử dụng!'
    },
    MessageCodeUtil.NO_DATA: {'en': 'No data!', 'vi': 'Không có dữ liệu!'},
    MessageCodeUtil.NO_DATA_AND_PRESS_PREVIOUS_TO_GET_BACK: {
      'en': 'No data. Press "Previous" to get back!',
      'vi': 'Không có dữ liệu. Nhấn "Trang trước" to quay lại!'
    },
    MessageCodeUtil.NO_DATA_AND_PRESS_NEXT_TO_GET_BACK: {
      'en': 'No data. Press "Next" to get back!',
      'vi': 'Không có dữ liệu. Nhấn "Trang sau" to quay lại!'
    },
    MessageCodeUtil.DUPLICATED_HOUR: {
      'en': 'Duplicated hour!',
      'vi': 'Trùng thời gian!'
    },
    MessageCodeUtil.CM_SYNC_BOOKING_SUCCESS: {
      'en': "Sync-ed bookings to CMS!",
      'vi': 'Đồng bộ đặt phòng lên CMS thành công!'
    },
    MessageCodeUtil.CM_SYNC_ROOMTYPE_SUCCESS: {
      'en': "Sync-ed room type to CMS!",
      'vi': 'Đồng bộ hạng phòng lên CMS thành công!'
    },
    MessageCodeUtil.CM_NOTIFY_SUCCESS: {
      'en': "Notified to CMS successfully!",
      'vi': 'Thông báo cho CMS thành công!'
    },
    MessageCodeUtil.CM_NOTIFY_FAIL: {
      'en': "Failed to notify to CMS!",
      'vi': 'Thông báo cho CMS thất bại!'
    },
    MessageCodeUtil.CM_UPDATE_INVENTORY_SUCCESS: {
      'en': "Updated inventory to CMS!",
      'vi': 'Cập nhật inventory thành công!'
    },
    MessageCodeUtil.CM_UPDATE_INVENTORY_FAIL: {
      'en': "Failed to update inventory to CM!",
      'vi': 'Cập nhật inventory thất bại!'
    },
    MessageCodeUtil.CM_NOT_MAP_HOTEL: {
      'en': "Hotel is not mapped!",
      'vi': 'Khách sạn chưa được kết nối với CMS!'
    },
    MessageCodeUtil.CM_NOT_MAP_ROOMTYPE: {
      'en': "Room type is not mapped!",
      'vi': 'Hạng phòng chưa kết nối với CMS!'
    },
    MessageCodeUtil.CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_SUCCESS: {
      'en': "Updated successfully!",
      'vi': 'Cập nhật thành công!'
    },
    MessageCodeUtil.CM_UPDATE_AVAIBILITY_AND_RELEASE_PERIOD_FAIL: {
      'en': "Failed to update!",
      'vi': 'Cập nhật thất bại!'
    },
    MessageCodeUtil.CM_UPDATE_AVAIBILITY_FAIL: {
      'en': "Failed to update avaibility!",
      'vi': 'Cập nhật phòng trống thất bại!'
    },
    MessageCodeUtil.CM_MAXIMUM_DATE_RANGE: {
      'en': "Maximum date range is 500 days!",
      'vi': 'Khoảng thời gian tối đa là 500 ngày!'
    },
    MessageCodeUtil.CM_HOTEL_EMPTY: {
      'en': "Empty hotel!",
      'vi': 'Khách sạn trống!'
    },
    MessageCodeUtil.CM_BOOKING_EMPTY: {
      'en': "Empty booking!",
      'vi': 'Đặt phòng trống!'
    },
    MessageCodeUtil.CM_GET_BOOKINGS_FAIL: {
      'en': "Failed to get bookings from CMS!",
      'vi': 'Cập nhật đặt phòng từ CMS thất bại!'
    },
    MessageCodeUtil.CM_SAVE_MAPPING_HOTEL_ID_SUCCESS: {
      'en': "Saved mapping hotel ID!",
      'vi': 'Lưu ID thành công!'
    },
    MessageCodeUtil.CM_SAVE_MAPPING_HOTEL_ID_FAIL: {
      'en': "Failed to save mapping hotel ID!",
      'vi': 'Lưu ID thất bại!'
    },
    MessageCodeUtil.CM_WAIT_FOR_PRE_ACTION: {
      'en': 'Waiting for previous action to complete!',
      'vi': 'Đang chờ hành động trước xử lý xong!'
    },
    MessageCodeUtil.CM_CLEAR_ALL_ROOMTYPE_SUCCESS: {
      'en': 'Clear all room types complete!',
      'vi': 'Xóa tất cả hạng phòng thành công!'
    },
    MessageCodeUtil.CM_SYNC_AVAIBILITY_FROM_PMS_SUCCESS: {
      'en': "Sync avaibility from PMS to CMS!",
      'vi': 'Đồng bộ phòng trống từ PMS sang CMS thành công!'
    },
    MessageCodeUtil.CM_SYNC_AVAIBILITY_FROM_PMS_FAIL: {
      'en': "Fail to avaibility from PMS to CMS!",
      'vi': 'Đồng bộ phòng trống từ PMS sang CMS thất bại!'
    },
    MessageCodeUtil.CM_SYNC_FAIL: {
      'en': "Failed to sync with CMS!",
      'vi': 'Đồng bộ với CMS thất bại!'
    },
    MessageCodeUtil.OVER_ID_MAX_LENGTH: {
      'en': 'Max length of ID is 16 characters!',
      'vi': 'Độ dài tối đa của ID là 16 kí tự!'
    },
    MessageCodeUtil.OVER_SUPPLIER_ID_MAX_LENGTH: {
      'en': 'Max length of ID is 16 characters!',
      'vi': 'Độ dài tối đa của ID là 16 kí tự!'
    },
    MessageCodeUtil.OVER_ID_RATE_LAN_MAX_LENGTH: {
      'en': 'Max length of ID is 64 characters!',
      'vi': 'Độ dài tối đa của ID là 64 kí tự!'
    },
    MessageCodeUtil.OVER_NAME_MAX_LENGTH: {
      'en': 'Max length of NAME is 64 characters!',
      'vi': 'Độ dài tối đa của tên là 64 kí tự!'
    },
    MessageCodeUtil.OVER_STATUS_MAX_LENGTH: {
      'en': 'Max length of Status is 30 characters!',
      'vi': 'Độ dài tối đa của tình trạng là 30 kí tự!'
    },
    MessageCodeUtil.OVER_CMND_CCCD_MAX_LENGTH: {
      'en': 'Max length of CMND/CCCD is 32 characters!',
      'vi': 'Độ dài tối đa của CMND/CCCD là 32 kí tự!'
    },
    MessageCodeUtil.OVER_PASSPORT_MAX_LENGTH: {
      'en': 'Max length of Passport is 32 characters!',
      'vi': 'Độ dài tối đa của số hộ chiếu là 32 kí tự!'
    },
    MessageCodeUtil.OVER_OTHER_DOCUMENT_MAX_LENGTH: {
      'en': 'Max length of Other document is 32 characters!',
      'vi': 'Độ dài tối đa của giấy tờ khác là 32 kí tự!'
    },
    MessageCodeUtil.ADD_PRESS_BELOW_BUTTON: {
      'en': "Please click on below button to add!",
      'vi': 'Vui lòng nhấn nút bên dưới để thêm mới!'
    },
    MessageCodeUtil.OVER_NAME_INVOICE_MAX_LENGTH: {
      'en': "Max length of Guest/Company name is 256 characters",
      'vi': 'Độ dài tối đa của tên Khách/Công ty là 256 kí tự'
    },
    MessageCodeUtil.OVER_TAX_CODE_INVOICE_MAX_LENGTH: {
      'en': "Max length of tax code is 64 characters",
      'vi': 'Độ dài tối đa của mã số thuế là 256 kí tự'
    },
    MessageCodeUtil.OVER_ADDRESS_INVOICE_MAX_LENGTH: {
      'en': "Max length of address is 256 characters",
      'vi': 'Độ dài tối đa của địa chỉ là 256 kí tự'
    },
    MessageCodeUtil
        .THE_BIGINGING_OF_THE_PERIOD_CANNOT_BE_GTEATER_THAN_THE_END_OF_THE_THE_PERIOD: {
      'en':
          "The beginning of the period cannot be greater than the end of the period!",
      'vi': 'Đầu kỳ không được lớn hơn cuối kỳ!'
    },
    MessageCodeUtil.HOUR_AND_PRICE_MUST_BE_POSITIVE: {
      'en': 'Hours and price must be positive numbers!',
      'vi': 'Giờ và giá tiền phải là số dương!'
    },
    MessageCodeUtil.RATIO_MUST_BE_FROM_0_TO_100: {
      'en': 'Ratio must be in range from 0 to 100!',
      'vi': 'Tỷ giá phải trong khoảng từ 0 đến 100!'
    },
    MessageCodeUtil.INVOICE_DELETE_SUCCESS: {
      'en': 'Deleted invoice with amount %s!',
      'vi': 'Đã xóa hoá đơn dịch vụ với giá %s!'
    },
    MessageCodeUtil.NO_GUEST_IN_ROOM: {
      'en': 'No guest in room!',
      'vi': 'Không có khách trong phòng!'
    },
    MessageCodeUtil.DISCOUNT_NOT_FOUND: {
      'en': 'Discount not found!',
      'vi': 'Không tìm thấy giảm giá!'
    },
    // restaurant
    MessageCodeUtil.RESTAURANT_NOT_FOUND: {
      'en': 'Restaurant not found',
      'vi': 'Không tìm thấy nhà hàng'
    },
    MessageCodeUtil.WAS_ACCEPT_LINKED: {
      'en': 'Was accept linked',
      'vi': 'Đã kết nối với nhà hàng'
    },
    MessageCodeUtil.PLEASE_DELETE_LINKED_FIRST: {
      'en': 'Please delete linked first',
      'vi': 'Hãy xóa liên kết nhà hàng này trước'
    },
    MessageCodeUtil.WAS_LINKED_HOTEL: {
      'en': 'Was linked this hotel',
      'vi': 'Đã liên kết khách sạn'
    },
    MessageCodeUtil.PASSWORD_MIN_LENGTH: {
      'en': 'Length of password must be more than 6 charaters!',
      'vi': 'Mật khẩu phải dài hơn 6 kí tự!'
    },
    MessageCodeUtil.WRONG_PASSWORD: {
      'en': 'Incorrect password!',
      'vi': 'Mật khẩu không chính xác!'
    },
    MessageCodeUtil.USER_NOT_FOUND: {
      'en': 'Cannot find your account!',
      'vi': 'Không thể tìm thấy tài khoản!'
    },
    MessageCodeUtil.TO_MANY_REQUESTS: {
      'en': 'You are request too much Please resubmit your request later!',
      'vi': 'Bạn yêu cầu quá nhiều Vui lòng gửi lại yêu cầu sau!'
    },
    MessageCodeUtil.EMAIL_ALREADY_IN_USE: {
      'en': 'Email was used by others!',
      'vi': 'Email đã được sử dụng!'
    },
    MessageCodeUtil.INPUT_RATE_ROOM_CHANNEL: {
      'en': 'Please input rate or avaibility',
      'vi': 'Vui lòng nhập giá hoặc số lượng phòng'
    },
    MessageCodeUtil.CONFIRM_ACTIVE: {
      'en': 'Do you want activate %s?',
      'vi': 'Bạn có muốn kích hoạt %s?'
    },
    MessageCodeUtil.CONFIRM_DEACTIVE: {
      'en': 'Are you sure to deactivate %s?',
      'vi': 'Bạn có muốn vô hiệu hóa %s?'
    },
    MessageCodeUtil.CONFIRM_SET_DEFAULT_RATE_PLAN: {
      'en': 'Are you sure to set %s default rate plan?',
      'vi': 'Bạn có muốn đặt %s làm chính sách giá mặc định?'
    },
    MessageCodeUtil.CONFIRM_DELETE: {
      'en': 'Are you sure to delete?',
      'vi': 'Bạn chắc chắn muốn xóa?'
    },
    MessageCodeUtil.CONFIRM_DELETE_X: {
      'en': 'Do you want to delete %s?',
      'vi': 'Bạn có muốn xóa %s?'
    },
    MessageCodeUtil.CONFIRM_STOP_WORKING: {
      'en': 'Do you want to deactive %s?',
      'vi': 'Bạn có muốn ngừng hoạt động %s?'
    },
    MessageCodeUtil.CONFIRM_SHOW_PRICE: {
      'en': 'Do you want to show rate?',
      'vi': 'Bạn có muốn hiển thị giá tiền?'
    },
    MessageCodeUtil.CONFIRM_SHOW_NOTES: {
      'en': 'Do you want to show notes?',
      'vi': 'Bạn có muốn hiển thị ghi chú?'
    },
    MessageCodeUtil.CONFIRM_SHOW_DAILY_RATE: {
      'en': 'Show daily rate?',
      'vi': 'Hiển thị giá hàng ngày?'
    },
    MessageCodeUtil.CONFIRM_SHOW_MONTHLY_RATE: {
      'en': 'Show monthly rate?',
      'vi': 'Hiển thị giá hàng tháng?'
    },
    MessageCodeUtil.CONFIRM_SHOW_ROOM_PRICE: {
      'en': 'Show room rate?',
      'vi': 'Hiển thị giá tiền phòng?'
    },
    MessageCodeUtil.CONFIRM_SHOW_SERVICE: {
      'en': 'Show service?',
      'vi': 'Hiển thị dịch vụ?'
    },
    MessageCodeUtil.CONFIRM_SHOW_PAYMENT: {
      'en': 'Show payment?',
      'vi': 'Hiển thị thanh toán?'
    },
    MessageCodeUtil.CONFIRM_SHOW_REMAINING: {
      'en': 'Show remaining?',
      'vi': 'Hiển thị còn lại?'
    },
    MessageCodeUtil.CONFIRM_DELETE_INVOICE_WITH_AMOUNT: {
      'en': "Are you sure to delete invoice with amount %s?",
      'vi': 'Bạn có muốn xóa hoá đơn dịch vụ có tổng tiền là %s?'
    },
    MessageCodeUtil.CONFIRM_DELETE_PAYMENT_WITH_AMOUNT: {
      'en': "Are you sure to delete deposit with amount %s?",
      'vi': 'Bạn có muốn xóa tiền cọc với số tiền là %s?'
    },
    MessageCodeUtil.CONFIRM_DELETE_EXTRA_SERVICE: {
      'en': 'Are you sure to delete extra service of %s with amount %s?',
      'vi': 'Bạn có muốn xóa hoá đơn dịch vụ %s có giá trị là %s?'
    },
    MessageCodeUtil.CONFIRM_DELETE_DISCOUNT_WITH_AMOUNT: {
      'en': 'Do you want to delete discount with amount %s?',
      'vi': 'Bạn có muốn xóa giảm giá với số tiền là %s?'
    },
    MessageCodeUtil.CONFIRM_SELECT_BOOKING: {
      'en': 'Do you want to select the booking %s?',
      'vi': 'Bạn muốn chọn booking %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_CHECKIN_AT_ROOM: {
      'en': 'Do you want to check in booking %s at room %s?',
      'vi': 'Xác nhận %s nhận phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_CHECKOUT_AT_ROOM: {
      'en': 'Do you want to check out booking %s at room %s?',
      'vi': 'Xác nhận %s trả phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_CHECKOUT: {
      'en': 'Do you want to check out booking %s?',
      'vi': 'Xác nhận %s trả phòng?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_CANCEL_AT_ROOM: {
      'en': 'Are you sure to cancel booking %s at room %s?',
      'vi': 'Xác nhận hủy đặt phòng %s tại phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_NO_SHOW_AT_ROOM: {
      'en': 'Are you sure to no show booking %s at room %s?',
      'vi': 'Xác nhận khách không đến phòng %s tại phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_UNDO_CHECKIN_AT_ROOM: {
      'en': 'Are you sure to undo check-in booking %s at room %s?',
      'vi': 'Xác nhận hoàn tác nhận phòng của %s tại phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_UNDO_CHECKOUT_AT_ROOM: {
      'en': 'Are you sure to undo check-out booking %s at room %s?',
      'vi': 'Xác nhận hoàn tác trả phòng của %s tại phòng %s?'
    },
    MessageCodeUtil.CONFIRM_BOOKING_CHANGE_ROOM: {
      'en': 'Do you want to change room from %s to %s?',
      'vi': 'Xác nhận đổi phòng từ %s qua %s?'
    },
    MessageCodeUtil.CONFIRM_UPDATE_PRICE_BOOKING_WHEN_CHANGE_ROOM_TYPE: {
      'en':
          'Are you want to update price booking when change room type from %s to %s?',
      'vi':
          'Xác nhận cập nhật lại giá tiền của booking khi chuyển từ %s qua %s?'
    },
    MessageCodeUtil.CONFIRM_REMOVE_USER_FROM_HOTEL: {
      'en': 'Are you sure to remove %s?',
      'vi': 'Xác nhận loại %s khỏi khách sạn?'
    },
    MessageCodeUtil.CONFIRM_BIKERENTAL_CHECKOUT: {
      'en': 'Are you sure to checkout bike %s?',
      'vi': 'Xác nhận trả xe %s?'
    },
    MessageCodeUtil.CONFIRM_CANCEL_BOOKING_GROUP_X: {
      'en': 'Are you sure to cancel group %s?',
      'vi': 'Xác nhận hủy đoàn %s?'
    },
    MessageCodeUtil.CONFIRM_EXPORT_MUCH_THAN_IN_STOCK: {
      'en': 'Are you sure to export more than in-stock amount?',
      'vi': 'Bạn có chắc muốn xuất nhiều hơn số lượng trong kho?'
    },
    MessageCodeUtil.CONFIRM_LIQUIDATION_MUCH_THAN_IN_STOCK: {
      'en': 'Are you sure to liquidation more than in-stock amount?',
      'vi': 'Bạn có chắc muốn thanh lý nhiều hơn số lượng trong kho?'
    },
    MessageCodeUtil.CONFIRM_TRANSFER_MUCH_THAN_IN_STOCK: {
      'en': 'Are you sure to transfer more than in-stock amount?',
      'vi': 'Bạn có chắc muốn chuyển nhiều hơn số lượng trong kho?'
    },
    MessageCodeUtil.CONFIRM_CREATE_COST_MANAGEMENT_AFTER_IMPORT: {
      'en': 'Import successfully! Do you want to create cost-management-bill?',
      'vi': 'Nhập kho thành công! Bạn có muốn tạo hóa đơn quản lí chi phí?'
    },
    MessageCodeUtil.CONFIRM_YOU_ARE_SURE: {
      'en': 'You are sure %s?',
      'vi': 'Bạn đã chắc chắn %s?'
    },
    MessageCodeUtil
        .CANNOT_CREATE_AND_EDIT_OR_DELETE_BEFORE_THE_FINANCIAL_SETTLEMENT_DATE: {
      'en':
          'Cannot create and edit or delete before the financial settlement date!',
      'vi':
          'Không thể tạo và chỉnh sửa hoặc xóa trước ngày quyết toán tài chính!'
    },
    MessageCodeUtil.OTHER_PAYMENT_METHOD_CAN_NOT_BE_EMPTY: {
      'en': 'Other payemt method can not be empty!',
      'vi': 'Phương thức thanh toán khác không được để trống!'
    },
    MessageCodeUtil.OTHER_VAT_CAN_NOT_BE_EMPTY: {
      'en': 'VAT can not be empty!',
      'vi': 'VAT không được để trống!'
    },
    MessageCodeUtil.OTHER_VAT_CAN_NOT_GREATER_THAN_100: {
      'en': 'VAT can not greater than 100%!',
      'vi': 'VAT không được lớn hơn 100%!'
    },
    MessageCodeUtil.AMOUNT_IN_WORD_CAN_NOT_BE_EMPTY: {
      'en': 'Amounts in word can not be empty!',
      'vi': 'tổng tiền bằng chữ không được để trống!'
    },
    MessageCodeUtil.PASSWORD_CAN_NOT_BE_EMPTY: {
      'en': 'Password can not be empty!',
      'vi': 'Mật khẩu không dược để trống!'
    },
    MessageCodeUtil.USERNAME_CAN_NOT_BE_EMPTY: {
      'en': 'Username can not be empty!',
      'vi': 'Tên đăng nhập không dược để trống!'
    },
    MessageCodeUtil.SOFTWARE_CAN_NOT_BE_EMPTY: {
      'en': 'Electronic invoice software can not be empty!',
      'vi': 'Phần mềm hóa đơn điện tử không dược để trống!'
    },
    MessageCodeUtil.HOTEL_CAN_NOT_EDIT_INFO: {
      'en': 'Cannot edit information of hotel!',
      'vi': 'Không thể thay đổi thông tin khách sạn!'
    },
    MessageCodeUtil.REVENUE_DOC_NOT_FOUND: {
      'en': 'Revenue not found, please contac Neutron IT to support',
      'vi':
          'Không tìm thấy dữ liệu, vui lòng liên hệ với đội ngũ Neutron để hỗ trợ.'
    },
    MessageCodeUtil.TEXTALERT_THIS_HAD_BEEN_DELETE: {
      'en': 'This had been deleted!',
      'vi': 'Đã bị xóa!'
    },
    MessageCodeUtil.TEXTALERT_NO_AVATAR: {
      'en': 'No avatar!',
      'vi': 'Không ảnh đại diện!'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_YOUR_HOTEL: {
      'en': 'Choose your hotel',
      'vi': 'Chọn khách sạn của bạn'
    },
    MessageCodeUtil.TEXTALERT_VERSION: {
      'en': 'Version: %s',
      'vi': 'Phiên bản: %s'
    },
    MessageCodeUtil.TEXTALERT_IF_YOU_ARE_HOTEL_MANAGER: {
      'en': 'If you are hotel owner, please click',
      'vi': 'Nếu bạn là chủ khách sạn, vui lòng nhấn'
    },
    MessageCodeUtil.TEXTALERT_FOR_INSTRUCTION_VIDEO: {
      'en': 'for instruction video',
      'vi': 'để xem video hướng dẫn'
    },
    MessageCodeUtil.TEXTALERT_FOR_INSTRUCTION_VIDEO_DETAIL: {
      'en': 'for detail instruction video.',
      'vi': 'để xem video hướng dẫn chi tiết.'
    },
    MessageCodeUtil.TEXTALERT_HERE: {'en': 'here', 'vi': 'vào đây'},
    MessageCodeUtil.TEXTALERT_CLICK_HERE: {
      'en': 'Click here',
      'vi': 'Nhấn vào đây'
    },
    MessageCodeUtil.TEXTALERT_CLICK_HERE_TO_CHECKIN: {
      'en': 'Click here to check in',
      'vi': 'Nhấn vào đây để nhận phòng'
    },
    MessageCodeUtil.TEXTALERT_CLICK_HERE_TO_CHECKOUT: {
      'en': 'Click here to check out',
      'vi': 'Nhấn vào đây để trả phòng'
    },
    MessageCodeUtil.TEXTALERT_TO_RESEND_EMAIL: {
      'en': 'to resend email',
      'vi': 'để gửi lại email'
    },
    MessageCodeUtil.TEXTALERT_CHECK_EMAIL: {
      'en': 'check your email',
      'vi': 'kiểm tra hòm thư'
    },
    MessageCodeUtil.TEXTALERT_TO_VERIFY: {
      'en': 'to verify',
      'vi': 'để xác thực'
    },
    MessageCodeUtil.TEXTALERT_YOU_CAN_REQUIRE_TO_RESEND_EMAIL_AFTER: {
      'en': 'You can require to resend email after',
      'vi': 'Bạn có thể yêu cầu gửi lại email sau'
    },
    MessageCodeUtil.TEXTALERT_TOO_MANY_REQUIREMENTS_IN_SHORT_TIME: {
      'en': 'Too many requirements in a short time. Please wait a second.',
      'vi': 'Quá nhiều yêu cầu trong thời gian ngắn. Vui lòng đợi giây lát.'
    },
    MessageCodeUtil.TEXTALERT_TO_CREATE_YOUR_HOTEL: {
      'en': 'to create your hotel.',
      'vi': 'để tạo khách sạn.'
    },
    MessageCodeUtil.TEXTALERT_SIGN_OUT: {'en': 'Sign out', 'vi': 'Đăng xuất'},
    MessageCodeUtil.TEXTALERT_NO_PERMISSION: {
      'en': "No permission!",
      'vi': 'Không đủ quyền hạn!'
    },
    MessageCodeUtil.TEXTALERT_NO_INFORMATION: {
      'en': "No information!",
      'vi': 'Không có thông tin!'
    },
    MessageCodeUtil.PRICE_MUST_BIGGER_THAN_MIN_PRICE: {
      'en': "Rate must bigger than min rate",
      'vi': 'Giá công bố phải lớn hơn giá tối thiểu'
    },
    MessageCodeUtil.QUANTITY_ROOMTYPE_SMALLER_THAN_MAX_ROOMTYPE: {
      'en': "Quantity room type must smaller than  max quantity room type",
      'vi': 'Số lượng phòng phải nhỏ hơn số lượng tối đa của phòng'
    },
    MessageCodeUtil.OVER_MAXIMUM_ROOM_OF_ROOMTYPE: {
      'en': "Over maximum rooms of room type",
      'vi': 'Vượt quá số phòng tối đa của hạng phòng'
    },
    MessageCodeUtil.ROOM_HAVE_BOOKING_PLEASE_MOVE_BOOKING_BEFORE_DELETE_ROOM: {
      'en': "Room have booking please move booking before delete room",
      'vi':
          'Vui lòng chuyển booking ra khỏi phòng này trước khi bạn muốn xóa phòng này'
    },
    MessageCodeUtil.ACTIVE_IS_NOT_ACTIVATED_CAN_UPDATE: {
      'en':
          "You can not update an accounting type when it is at inactive status",
      'vi':
          "Bạn không thể cập nhật Loại chi phí khi nó đang ở trạng thái ngừng hoạt động"
    },
    MessageCodeUtil.ACTIVE_ALREADY_IN_AN_INACTIVE_STATE: {
      'en':
          "You can not delete an accounting type when it is at inactive status",
      'vi':
          "Bạn không thể xóa Loại chi phí khi nó đang ở trạng thái ngừng hoạt động"
    },
    MessageCodeUtil.TEXTALERT_LOADING_HOTELS: {
      'en': 'Loading hotels ...',
      'vi': 'Đang tải dữ liệu khách sạn ...'
    },
    MessageCodeUtil.TEXTALERT_LOADING_CONFIGS: {
      'en': 'Loading configs ...',
      'vi': 'Đang tải các thiết lập ...'
    },
    MessageCodeUtil.TEXTALERT_LOADING_ROOMS: {
      'en': 'Loading rooms...',
      'vi': 'Đang tải dữ liệu phòng...'
    },
    MessageCodeUtil.TEXTALERT_CLEAN: {'en': 'Clean', 'vi': 'Sạch'},
    MessageCodeUtil.TEXTALERT_DIRTY: {'en': 'Dirty', 'vi': 'Bẩn'},
    MessageCodeUtil.TEXTALERT_MINIBAR: {'en': 'Minibar', 'vi': 'Minibar'},
    MessageCodeUtil.TEXTALERT_LAUNDRY: {'en': 'Laundry', 'vi': 'Giặt ủi'},
    MessageCodeUtil.TEXTALERT_BED: {'en': 'Bed: ', 'vi': 'Giường: '},
    MessageCodeUtil.TEXTALERT_EXTRA_BED: {
      'en': 'Extra bed: ',
      'vi': 'Giường phụ: '
    },
    MessageCodeUtil.TEXTALERT_NO_BOOKINGS: {
      'en': 'No booking!',
      'vi': 'Không có đặt phòng!'
    },

    MessageCodeUtil.TEXTALERT_NOBREAKFAST: {
      'en': ' No breakfast included',
      'vi': ' Không bao gồm ăn sáng'
    },
    MessageCodeUtil.TEXTALERT_YESBREAKFAST: {
      'en': ' Breakfast included',
      'vi': ' Bao gồm ăn sáng'
    },
    MessageCodeUtil.TEXTALERT_NOLUNCH: {
      'en': ' No lunch included',
      'vi': ' Không bao gồm ăn trưa'
    },
    MessageCodeUtil.TEXTALERT_YESLUNCH: {
      'en': ' Lunch included',
      'vi': ' Bao gồm ăn trưa'
    },
    MessageCodeUtil.TEXTALERT_NODINNER: {
      'en': ' No dinner included',
      'vi': ' Không bao gồm ăn tối'
    },
    MessageCodeUtil.TEXTALERT_YESDINNER: {
      'en': ' Dinner included',
      'vi': ' Bao gồm ăn tối'
    },

    MessageCodeUtil.TEXTALERT_NO: {'en': 'No', 'vi': 'Không'},
    MessageCodeUtil.TEXTALERT_EMPTY: {'en': 'Empty!', 'vi': 'Trống!'},
    MessageCodeUtil.TEXTALERT_YES: {'en': 'Yes', 'vi': 'Có'},
    MessageCodeUtil.TEXTALERT_MOVED: {'en': 'Moved!', 'vi': 'Đã di chuyển!'},
    MessageCodeUtil.TEXTALERT_X_RENTING_BIKES: {
      'en': '%s renting bikes.',
      'vi': '%s xe đang thuê'
    },
    MessageCodeUtil.CM_UPDATE_AVAIBILITY_RATE_FAIL: {
      'en': 'Invalid rate or avaibility!',
      'vi': 'Số lượng phòng hoặc giá sai!'
    },
    MessageCodeUtil.TEXTALERT_SIGN_UP: {
      'en': 'Create new account',
      'vi': 'Đăng ký tài khoản'
    },
    MessageCodeUtil.TEXTALERT_REMEMBER_ME: {
      'en': 'Remember me',
      'vi': 'Ghi nhớ đăng nhập'
    },
    MessageCodeUtil.TEXTALERT_FORGET_PASSWORD: {
      'en': 'Forgot password?',
      'vi': 'Quên mật khẩu?'
    },
    MessageCodeUtil.TEXTALERT_LOGIN: {'en': 'Login', 'vi': 'Đăng nhập'},
    MessageCodeUtil.TEXTALERT_CHOOSE_JOB: {
      'en': 'Please choose your job',
      'vi': 'Vui lòng chọn nghề nghiệp'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_COUNTRY: {
      'en': 'Please choose country',
      'vi': 'Vui lòng chọn quốc gia'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_CITY: {
      'en': 'Please choose city',
      'vi': 'Vui lòng chọn thành phố'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_CURRENCY: {
      'en': 'Please choose currency',
      'vi': 'Vui lòng chọn tiền tệ'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_TIMEZONE: {
      'en': 'Please choose timezone',
      'vi': 'Vui lòng chọn múi giờ'
    },
    MessageCodeUtil.TEXTALERT_CHOOSE_ROOM: {
      'en': 'Choose room',
      'vi': 'Chọn phòng'
    },
    MessageCodeUtil.TEXTALERT_DELETED: {'en': 'deleted', 'vi': 'đã xóa'},
    MessageCodeUtil.TEXTALERT_TO_CREATE_ROOMTYPE_AND_ROOM: {
      'en': 'create room type and room',
      'vi': 'tạo hạng phòng và phòng'
    },
    MessageCodeUtil.TEXTALERT_FOR_HOTEL_TO_USE: {
      'en': ' for hotel to use',
      'vi': ' trước khi sử dụng'
    },
    MessageCodeUtil.TEXTALERT_PLEASE: {'en': 'Please ', 'vi': 'Vui lòng '},
    MessageCodeUtil.TEXTALERT_YOU_CAN: {
      'en': '. You can',
      'vi': '. Bạn có thể'
    },
    MessageCodeUtil.TEXTALERT_BEFORE_CREATING_NEW_BOOKING: {
      'en': ' before creating new booking.',
      'vi': ' trước khi tạo booking.'
    },
    MessageCodeUtil.TEXTALERT_NEED_TO_CONFIG_X_FIRST: {
      'en': 'You need to config %s first.',
      'vi': 'Bạn cần cấu hình %s trước.'
    },
    MessageCodeUtil.TEXTALERT_VERIFIED: {'en': 'Verified', 'vi': 'Đã xác thực'},
    MessageCodeUtil.TEXTALERT_UNVERIFIED: {
      'en': 'Unverified',
      'vi': 'Chưa xác thực'
    },
    MessageCodeUtil.CAN_NOT_DEACTIVE_DEFAULT_SUPPLIER: {
      'en': 'Cannot deactive the default supplier',
      'vi': 'Không thể tắt nhà cung cấp mặc định'
    },
    MessageCodeUtil.NEED_TO_ADD_BIKE_RENTAL_TO_SUPPLIER_FIRST: {
      'en': 'You need to add Bike rental service to this supplier first',
      'vi': 'Bạn cần thêm dịch vụ thuê xe máy cho nhà cung cấp này trước'
    },
    MessageCodeUtil.CONFIGURATION_NOT_FOUND: {
      'en': 'Configuration not be found',
      'vi': 'Không tìm thấy cấu hình'
    },
    MessageCodeUtil.ALL_CHECKED_ROOM: {
      'en': 'All checked room',
      'vi': 'Tất cả phòng đã kiểm tra'
    },
    MessageCodeUtil.INVALID_CITY: {
      'en': 'Invalid city',
      'vi': 'Thành phố không hợp lệ'
    },
    MessageCodeUtil.INVALID_COUNTRY: {
      'en': 'Invalid country',
      'vi': 'Quốc gia không hợp lệ'
    },
    MessageCodeUtil.ACTIVITY_CREATE_NEW_X_WITH_AMOUNT: {
      'en': 'has created new %s with amount %s',
      'vi': 'vừa thêm mới %s với giá %s'
    },
    MessageCodeUtil.ACTIVITY_CREATE_NEW_BIKE_X: {
      'en': 'has booked bike %s',
      'vi': 'vừa thuê xe %s'
    },
    MessageCodeUtil.ACTIVITY_UPDATE_X: {
      'en': 'has updated %s',
      'vi': 'vừa cập nhật %s'
    },
    MessageCodeUtil.ACTIVITY_UPDATE_X_FROM_A_TO_B: {
      'en': 'has updated %s from %s to %s',
      'vi': 'vừa cập nhật %s từ %s thành %s'
    },
    MessageCodeUtil.ACTIVITY_DELETE_X: {
      'en': 'has deleted %s',
      'vi': 'vừa xóa %s'
    },
    MessageCodeUtil.ACTIVITY_CHECKIN_BIKE_X: {
      'en': 'has checked in bike %s',
      'vi': 'vừa nhận xe %s'
    },
    MessageCodeUtil.ACTIVITY_CHECKOUT_BIKE_X: {
      'en': 'has checked out bike %s',
      'vi': 'vừa trả xe %s'
    },
    MessageCodeUtil.ACTIVITY_CHANGE_BIKE_FROM_A_TO_B: {
      'en': 'has changed bike from %s to %s',
      'vi': 'vừa đổi xe %s sang xe %s'
    },
    MessageCodeUtil.ACTIVITY_CHECKIN: {
      'en': 'has checked in',
      'vi': 'vừa nhận phòng'
    },
    MessageCodeUtil.ACTIVITY_CHECKOUT: {
      'en': 'has checked out',
      'vi': 'vừa trả phòng'
    },
    MessageCodeUtil.ACTIVITY_CHANGE_DATE: {
      'en': 'has changed date',
      'vi': 'vừa thay đổi ngày'
    },
    MessageCodeUtil.ACTIVITY_CHANGE_ROOM_TO_X: {
      'en': 'has changed room to %s',
      'vi': 'vừa thay đổi phòng sang %s'
    },
    MessageCodeUtil.ACTIVITY_CHANGE_NAME_TO_X: {
      'en': 'has changed name to %s',
      'vi': 'vừa thay đổi tên thành %s'
    },
    MessageCodeUtil.ACTIVITY_BOOK_ROOM_X: {
      'en': 'has booked room %s',
      'vi': 'vừa đặt phòng %s'
    },
    MessageCodeUtil.ACTIVITY_CANCEL: {
      'en': 'has cancelled',
      'vi': 'vừa hủy đặt phòng'
    },
    MessageCodeUtil.ACTIVITY_NOSHOW: {'en': 'No show', 'vi': 'Khách không đến'},
    MessageCodeUtil.ACTIVITY_MINIBAR_SERVICE: {
      'en': 'minibar service',
      'vi': 'dịch vụ minibar'
    },
    MessageCodeUtil.ACTIVITY_RESTAURANT_SERVICE: {
      'en': 'restaurant service',
      'vi': 'dịch vụ nhà hàng'
    },
    MessageCodeUtil.ACTIVITY_ELECTRICITY_SERVICE: {
      'en': 'Electricity',
      'vi': 'Điện'
    },
    MessageCodeUtil.ACTIVITY_WATER_SERVICE: {'en': 'Water', 'vi': 'Nước'},
    MessageCodeUtil.ACTIVITY_INSIDE_RESTAURANT_SERVICE: {
      'en': 'restaurant service (inside hotel)',
      'vi': 'dịch vụ nhà hàng (trong khách sạn)'
    },
    MessageCodeUtil.ACTIVITY_LAUNDRY_SERVICE: {
      'en': 'laundry service',
      'vi': 'dịch vụ giặt ủi'
    },
    MessageCodeUtil.ACTIVITY_EXTRA_GUEST_SERVICE: {
      'en': 'extra guest service',
      'vi': 'phụ thu khách'
    },
    MessageCodeUtil.ACTIVITY_EXTRA_HOUR_SERVICE: {
      'en': 'extra hour service',
      'vi': 'phụ thu giờ'
    },
    MessageCodeUtil.ELECTRICITY_WATER_SERVICE: {
      'en': 'Electricity water service',
      'vi': 'Điện nước'
    },
    MessageCodeUtil.ACTIVITY_OTHER_SERVICE: {
      'en': 'other service',
      'vi': 'dịch vụ khác'
    },
    MessageCodeUtil.ACTIVITY_DEPOSIT: {'en': 'payment', 'vi': 'thanh toán'},
    MessageCodeUtil.ACTIVITY_DEPOSIT_AMOUNT: {
      'en': 'payment amount',
      'vi': 'số tiền thanh toán'
    },
    MessageCodeUtil.ACTIVITY_DEPOSIT_DESCRIPTION: {
      'en': 'payment description',
      'vi': 'mô tả thanh toán'
    },
    MessageCodeUtil.ACTIVITY_DEPOSIT_METHOD: {
      'en': 'payment method',
      'vi': 'phương thức thanh toán'
    },
    MessageCodeUtil.ACTIVITY_UNDO_CHECKIN: {
      'en': 'has undo check-in',
      'vi': 'vừa hoàn tác nhận phòng'
    },
    MessageCodeUtil.ACTIVITY_UNDO_CHECKOUT: {
      'en': 'has undo check-out',
      'vi': 'vừa hoàn tác trả phòng'
    },
    MessageCodeUtil.ACTIVITY_NONE_ROOM: {
      'en': 'None room',
      'vi': 'Phòng trống'
    },
    MessageCodeUtil.ACTIVITY_SECONDS_AGO: {
      'en': 'seconds ago',
      'vi': 'giây trước'
    },
    MessageCodeUtil.ACTIVITY_MINUTES_AGO: {
      'en': 'minutes ago',
      'vi': 'phút trước'
    },
    MessageCodeUtil.ACTIVITY_HOURS_AGO: {'en': 'hours ago', 'vi': 'giờ trước'},
    MessageCodeUtil.ACTIVITY_DAYS_AGO: {'en': 'days ago', 'vi': 'ngày trước'},
    MessageCodeUtil.JOB_ACCOUNTANT: {'en': 'Accountant', 'vi': 'Kế toán'},
    MessageCodeUtil.JOB_ADMIN: {'en': 'Admin', 'vi': 'Quản trị viên'},
    MessageCodeUtil.JOB_CHEF: {'en': 'Chef', 'vi': 'Đầu bếp'},
    MessageCodeUtil.JOB_CHOOSE: {'en': 'Choose', 'vi': 'Chọn nghề nghiệp'},
    MessageCodeUtil.JOB_MANAGER: {'en': 'Manager', 'vi': 'Quản lý'},
    MessageCodeUtil.JOB_PARTNER: {'en': 'Partner', 'vi': 'Đối tác'},
    MessageCodeUtil.JOB_E_INVOICE_MANAGER: {
      'en': 'Electronic invoice manager',
      'vi': 'Quản lý hóa đơn điện tử'
    },
    MessageCodeUtil.JOB_WAREHOUSE_MANAGER: {
      'en': 'Warehouse manager',
      'vi': 'Quản lý kho'
    },
    MessageCodeUtil.JOB_INTERNAL_PARTNER: {
      'en': 'Internal partner',
      'vi': 'Đối tác nội bộ'
    },
    MessageCodeUtil.JOB_APPROVER: {'en': 'Approver', 'vi': 'Người phê duyệt'},
    MessageCodeUtil.JOB_GUARD: {'en': 'Guard', 'vi': 'Bảo vệ'},
    MessageCodeUtil.JOB_HOUSEKEEPING: {
      'en': 'Housekeeping',
      'vi': 'Buồng phòng'
    },
    MessageCodeUtil.JOB_HR: {'en': 'HR', 'vi': 'HR'},
    MessageCodeUtil.JOB_MAINTAINER: {'en': 'Maintainer', 'vi': 'Bảo trì'},
    MessageCodeUtil.JOB_MARKETING: {'en': 'Marketing', 'vi': 'Marketing'},
    MessageCodeUtil.JOB_OTHER: {'en': 'Other', 'vi': 'Khác'},
    MessageCodeUtil.JOB_OWNER: {'en': 'Owner', 'vi': 'Chủ khách sạn'},
    MessageCodeUtil.JOB_RECEPTIONIST: {'en': 'Receptionist', 'vi': 'Lễ tân'},
    MessageCodeUtil.JOB_SALE: {'en': 'Sale', 'vi': 'Kinh doanh'},
    MessageCodeUtil.JOB_STEPWARD: {
      'en': 'Steward',
      'vi': 'Chăm sóc khách hàng'
    },
    MessageCodeUtil.JOB_WAITER_WAITRESS: {
      'en': 'Waiter/Waitress',
      'vi': 'Phục vụ'
    },
    MessageCodeUtil.STATISTIC_ALL: {'en': 'All', 'vi': 'Tất cả'},
    MessageCodeUtil.STATISTIC_OCCUPANCY: {
      'en': 'Occupancy',
      'vi': 'Công suất phòng'
    },
    MessageCodeUtil.STATISTIC_REVENUE: {'en': 'Revenue', 'vi': 'Doanh thu'},
    MessageCodeUtil.STATISTIC_REVENUE_BY_DATE: {
      'en': 'Revenue by date',
      'vi': 'Doanh thu theo ngày'
    },
    MessageCodeUtil.STATISTIC_REVENUE_BY_CHECKOUT_DATE: {
      'en': 'Revenue by check-out date',
      'vi': 'Doanh thu theo ngày trả phòng'
    },
    MessageCodeUtil.STATISTIC_REVENUE_BY_ROOM_TYPE: {
      'en': 'Revenue by room type',
      'vi': 'Doanh thu theo hạng phòng'
    },
    MessageCodeUtil.STATISTIC_ROOM_USED: {
      'en': 'Room use',
      'vi': 'Phòng đã sử dụng'
    },
    MessageCodeUtil.STATISTIC_ROOM_STILL_EMPTY: {
      'en': 'Room still empty',
      'vi': 'Phòng vẫn trống'
    },
    MessageCodeUtil.STATISTIC_ROOM_CHARGE: {
      'en': 'Room charge',
      'vi': 'Tiền phòng'
    },
    MessageCodeUtil.STATISTIC_DEPOSIT: {'en': 'Payment', 'vi': 'Thanh toán'},
    MessageCodeUtil.STATISTIC_DISCOUNT: {'en': 'Discount', 'vi': 'Giảm giá'},
    MessageCodeUtil.STATISTIC_SERVICE: {'en': 'Service', 'vi': 'Dịch vụ'},
    MessageCodeUtil.STATISTIC_NEW_BOOKING: {
      'en': 'New booking',
      'vi': 'Đặt phòng mới'
    },
    MessageCodeUtil.STATISTIC_MEALS: {'en': 'Meals', 'vi': 'Bữa ăn'},
    MessageCodeUtil.STATISTIC_BREAKFAST: {'en': 'Breakfast', 'vi': 'Ăn sáng'},
    MessageCodeUtil.STATISTIC_LUNCH: {'en': 'Lunch', 'vi': 'Ăn trưa'},
    MessageCodeUtil.STATISTIC_DINNER: {'en': 'Dinner', 'vi': 'Ăn tối'},
    MessageCodeUtil.STATISTIC_GUEST: {'en': 'Guest', 'vi': 'Lượng khách'},
    MessageCodeUtil.STATISTIC_ADULT: {'en': 'Adult', 'vi': 'Người lớn'},
    MessageCodeUtil.STATISTIC_CHILD: {'en': 'Child', 'vi': 'Trẻ em'},
    MessageCodeUtil.STATISTIC_PAY_AT_HOTEL: {
      'en': 'Pay at hotel',
      'vi': 'Thanh toán tại quầy'
    },
    MessageCodeUtil.STATISTIC_PREPAID: {'en': 'Prepaid', 'vi': 'Trả trước'},
    MessageCodeUtil.STATISTIC_NIGHT: {'en': 'Night', 'vi': 'Đêm'},
    MessageCodeUtil.STATISTIC_AVERAGE_RATE: {
      'en': 'Average rate',
      'vi': 'Giá trung bình'
    },
    MessageCodeUtil.STATISTIC_TOTAL_HOTELS: {
      'en': 'Total hotels',
      'vi': 'Tổng khách sạn'
    },
    MessageCodeUtil.STATISTIC_TOTAL_USERS: {
      'en': 'Total users',
      'vi': 'Tổng người dùng'
    },
    MessageCodeUtil.STATISTIC_TOTAL_MEMBER: {
      'en': 'Total member',
      'vi': 'Tổng thành viên'
    },
    MessageCodeUtil.STATISTIC_LIQUIDATION: {
      'en': 'Liquidation',
      'vi': 'Thanh lý'
    },
    MessageCodeUtil.STATISTIC_ACCOUNTING: {'en': 'Accounting', 'vi': 'Chi phí'},
    MessageCodeUtil.STATISTIC_ACTUAL_PLAYMENT: {
      'en': 'Actual payment',
      'vi': 'Thực chi'
    },
    MessageCodeUtil.STATISTIC_COUNTRY: {'en': 'Country', 'vi': 'Quốc gia'},
    MessageCodeUtil.STATISTIC_TYPE_TOURISTS: {
      'en': 'Type tourists',
      'vi': 'Loại du khách'
    },
    MessageCodeUtil.STATISTIC_ROOM_AMOUNT: {
      'en': 'Room amount',
      'vi': 'Số lượng phòng'
    },
    MessageCodeUtil.SERVICE_CATEGORY_MINIBAR: {
      'en': 'Minibar',
      'vi': 'Minibar'
    },
    MessageCodeUtil.SERVICE_CATEGORY_RESTAURANT: {
      'en': 'Restaurant',
      'vi': 'Nhà hàng'
    },
    MessageCodeUtil.SERVICE_CATEGORY_INSIDE_RESTAURANT: {
      'en': 'Inside restaurant',
      'vi': 'Nhà hàng thuộc kh.s'
    },
    MessageCodeUtil.SERVICE_CATEGORY_OUTSIDE_RESTAURANT: {
      'en': 'Outside restaurant',
      'vi': 'Nhà hàng'
    },
    MessageCodeUtil.SERVICE_CATEGORY_EXTRA_GUEST: {
      'en': 'Extra guest',
      'vi': 'Phụ thu khách'
    },
    MessageCodeUtil.SERVICE_CATEGORY_LAUNDRY: {
      'en': 'Laundry',
      'vi': 'Giặt ủi'
    },
    MessageCodeUtil.SERVICE_CATEGORY_BIKE_RENTAL: {
      'en': 'Bike rental',
      'vi': 'Thuê xe'
    },
    MessageCodeUtil.SERVICE_CATEGORY_OTHER: {'en': 'Other', 'vi': 'Khác'},
    MessageCodeUtil.SERVICE_CATEGORY_EXTRA_HOUR: {
      'en': 'Extra hour',
      'vi': 'Phụ thu giờ'
    },
    MessageCodeUtil.SERVICE_CATEGORY_ELECTRICITY: {
      'en': 'Electricity',
      'vi': 'Điện',
    },
    MessageCodeUtil.SERVICE_CATEGORY_WATER: {
      'en': 'Water',
      'vi': 'Nước',
    },
    MessageCodeUtil.LANGUAGE_ENGLISH: {'en': 'English', 'vi': 'Tiếng Anh'},
    MessageCodeUtil.LANGUAGE_VIETNAMESE: {
      'en': 'Vietnamese',
      'vi': 'Tiếng Việt'
    },
    MessageCodeUtil.CAN_NOT_UPDATE_RATE_PLAN_BOOKING_GROUP: {
      'en': 'Can not update rate plan booking group',
      'vi': 'Không được cập nhật rate plan của booking'
    },
    MessageCodeUtil.CAN_NOT_UPDATE_DATE_IN_OUT_WITH_BOOKING_FROM_OTA: {
      'en':
          'Can not update date in or date out with booking with rate plan ota',
      'vi': 'Không thể cập nhật ngày in hoặc out của booking từ CMS'
    },
    MessageCodeUtil.RATE_PLAN_DUPLICATED: {
      'en': 'Rate plan duplicated',
      'vi': 'Trùng id chính sách giá'
    },
    MessageCodeUtil.RATE_PLAN_NOT_FOUND: {
      'en': 'Rate plan not found',
      'vi': 'Không thể tìm thấy chính sách giá này'
    },
    MessageCodeUtil.RATE_PLAN_WAS_DELETED: {
      'en': 'Rate plan was deleted',
      'vi': 'Chính sách giá đã bị xóa'
    },
    MessageCodeUtil.CAN_NOT_DEACTIVE_DEFAULT_RATE_PLAN: {
      'en': 'Can not deactive default rate plan',
      'vi': 'Không thể xóa chính sách giá mặc định'
    },
    MessageCodeUtil.THIS_RATE_PLAN_CANNOT_BE_EDITED: {
      'en': 'This rate plan cannot be edited',
      'vi': 'Không thể chỉnh sửa gói giá này'
    },
    MessageCodeUtil.OTA_RATE_PLAN_CANNOT_BE_SET_DEFAULT: {
      'en': 'Ota rate plan cannot be default',
      'vi': 'Không thể cài đặt ota rate plan làm mặc định'
    },

    //unit
    MessageCodeUtil.UNIT_CAN: {'en': 'Can', 'vi': 'Lon'},
    MessageCodeUtil.UNIT_CUP: {'en': 'Cup', 'vi': 'Cốc'},
    MessageCodeUtil.UNIT_HOUR: {'en': 'Hour', 'vi': 'Giờ'},
    MessageCodeUtil.UNIT_KG: {'en': 'Kilogram', 'vi': 'Cân/Ký'},
    MessageCodeUtil.UNIT_PCS: {'en': 'Pcs', 'vi': 'Cái/Chiếc'},
    MessageCodeUtil.UNIT_PLATE: {'en': 'Plate', 'vi': 'Dĩa'},
    MessageCodeUtil.UNIT_LITER: {'en': 'Liter', 'vi': 'Lít'},
    MessageCodeUtil.UNIT_JAR: {'en': 'Jar', 'vi': 'Lọ/hũ'},
    MessageCodeUtil.UNIT_BOTTLE: {'en': 'Bottle', 'vi': 'Chai'},
    MessageCodeUtil.UNIT_GLASS: {'en': 'Glass', 'vi': 'Ly'},
    MessageCodeUtil.UNIT_PACKAGE: {'en': 'Package', 'vi': 'Túi/gói'},
    MessageCodeUtil.UNIT_BOX: {'en': 'Box', 'vi': 'Thùng/hộp'},
    MessageCodeUtil.UNIT_TUBE: {'en': 'Tube', 'vi': 'Tuýp'},
    MessageCodeUtil.UNIT_PORTION: {'en': 'Portion', 'vi': 'Phần/xuất'},
    MessageCodeUtil.UNIT_ROLL: {'en': 'Roll', 'vi': 'Cuộn'},
    MessageCodeUtil.UNIT_SET: {'en': 'Set', 'vi': 'Bộ'},

    MessageCodeUtil.UNIT_ERRO_AT_LINE: {
      'en': 'Unit error at line %s',
      'vi': 'Lỗi đơn vị tại dòng %s'
    },

    MessageCodeUtil.NAME_ITEM_ISEMPTY: {
      'en': 'Name item isEmpty at line %s',
      'vi': 'Tên món bị trống tại dòng %s'
    },
    //cost management
    MessageCodeUtil.MUST_CONFIGURE_ACCOUNTING_TYPE_FIRST: {
      'en': 'You must configure accounting type first',
      'vi': 'Trước tiên bạn phải cấu hình các loại chi phí'
    },
    MessageCodeUtil.SUPPLIER_NOT_FOUND: {
      'en': 'Supplier is not found',
      'vi': 'Không tìm thấy nhà cung cấp'
    },
    MessageCodeUtil.ACTUAL_PAYMENT_NOT_FOUND: {
      'en': 'Actual payment not be found',
      'vi': 'Không tìm thấy thực chi'
    },
    MessageCodeUtil.SAME_STATUS_ACTUAL_PAYMENT: {
      'en': 'Status of actual payment are the same',
      'vi': 'Trạng thái của thực chi giống nhau'
    },
    MessageCodeUtil
        .AMOUNT_CAN_NOT_LESS_THAN_ACTUAL_PAYMENT_PLEASE_DELETE_ACTUAL_PAYMENT_FIRST: {
      'en': 'Actual expense can not be bigger than total bill',
      'vi': 'Thực chi không thể lơn hơn tổng hóa đơn'
    },
    MessageCodeUtil.METHOD_PAYMENT_NOT_FOUND: {
      'en': 'Method of payment not found',
      'vi': 'Không tìm thấy phương thức thanh toán'
    },
    MessageCodeUtil.MUST_DELETE_ACTUAL_PAYMENT_COLLECTION: {
      'en': 'You need to delete actual payment collection',
      'vi': 'Bạn cần xóa các khoản thực chi trước'
    },
    MessageCodeUtil.COST_MANAGEMENT_NOT_FOUND: {
      'en': 'Cost management is not found',
      'vi': 'Không thể tìm thấy quản lý chi phí'
    },
    MessageCodeUtil.INVALID_STATUS: {
      'en': 'Invalid status',
      'vi': 'Trạng thái không hợp lệ'
    },
    MessageCodeUtil.COPIED_TO_CLIPBOARD: {
      'en': 'Copied to clipboard',
      'vi': 'Đã sao chép vào clipboard'
    },
    MessageCodeUtil.PLEASE_UPDATE_PACKAGE_HOTEL: {
      'en': 'Please update package hotel to use.',
      'vi': 'Vui lòng nâng cấp phần mềm lên gói adv hoặc pro để sử dụng.'
    },
    MessageCodeUtil.REVENUE_MANAGEMENT_NOT_FOUND: {
      'en': 'Not found data with revenue, please contact Neutron IT to fix.',
      'vi':
          'Không tìm thấy dữ liệu doanh thu này, vui lòng liên hệ đội ngũ Neutron để xử lý'
    },
    MessageCodeUtil.CREATE_ACTUAL_PAYMENT_FOR: {
      'en': 'Create actual payment for',
      'vi': 'Thêm thanh toán thực chi cho'
    },
    MessageCodeUtil.UPDATE_ACTUAL_PAYMENT_FOR: {
      'en': 'Update actual payment for',
      'vi': 'Cập nhật thanh toán thực chi cho'
    },
    MessageCodeUtil.DELETE_ACTUAL_PAYMENT_FOR: {
      'en': 'Delete actual payment for',
      'vi': 'Xóa thanh toán thực chi cho'
    },
    MessageCodeUtil.SLIDE_TO_ADJUST_SIZE: {
      'en': 'Slide to adjust size',
      'vi': 'Trượt để chỉnh kích thước'
    },
    MessageCodeUtil.TODAY_PROGRESS: {
      'en': 'Today progress',
      'vi': 'Tiến độ hôm nay'
    },
    MessageCodeUtil.PAGE_AND_TOTAL: {'en': 'Page/Total', 'vi': 'Trang/Tổng'},
    MessageCodeUtil.PERFORMED_BY: {
      'en': 'Performed by',
      'vi': 'Được thực hiện bởi'
    },
    MessageCodeUtil.CREATE_OVERHOUR_BOOKING: {
      'en': 'You create a booking than 24 hours, please create a booking daily',
      'vi': 'Bạn tạo booking hơn 24h, vui lòng tạo booking hàng ngày'
    },
    MessageCodeUtil.CONTENT_THANKYOU: {
      'en':
          'We would like to sincerely thank you for your interest in %s .We are pleased to confirm your booking as follows:',
      'vi':
          'Xin chân thành cảm ơn sự quan tâm của quý khách đối với %s . Chúng tôi xin xác nhận đơn đặt phòng của quý khách như sau:'
    },
  };

  static String getMessageByCode(String? errorCode,
      [List<String>? inputArgument, String? localeCode]) {
    localeCode ??= GeneralManager.locale?.languageCode;
    if (!messageMap.containsKey(errorCode)) {
      print(errorCode);
      return messageMap['undefined-error']?[localeCode] ?? "";
    }
    return inputArgument != null
        ? sprintf(messageMap[errorCode]![localeCode]!, inputArgument)
        : messageMap[errorCode]![localeCode]?.replaceAll(RegExp(r'%s'), '') ??
            "";
  }
}
