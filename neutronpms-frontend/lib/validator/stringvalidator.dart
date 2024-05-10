import 'package:ihotel/util/messageulti.dart';

class StringValidator {
  static final sidRegex = RegExp(r'^[a-zA-Z0-9\_]*$');
  // ngoại trừ kí tự -._'
  static final specificCharactersRegex =
      RegExp(r'[!@#$&*+=<>,;:|/?[\]{\}\\"]]*');
  // ngoại trừ kí tự -/'
  static final streetRegex = RegExp(r'[!@#$&*+=<>.;:|?[\]{\}\_\\"]]*');
  static final emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  static String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_STREET);
    }
    value = value.trim();
    if (streetRegex.hasMatch(value)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STREET_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
    }
    if (value.trim().isEmpty) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.STREET_CAN_NOT_BE_BLANK);
    }
    return null;
  }

  static String? validateSid(String value) {
    if (value.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_SID);
    }
    if (value.length > 16) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.SID_OVER_MAXIMUM_CHARACTERS);
    }
    if (value.contains("/")) {
      return "${MessageUtil.getMessageByCode(MessageCodeUtil.SID_MUST_NOT_CONTAIN_SPECIFIC_CHAR)} /";
    }
    return null;
  }

  static String? validatePhone(String value) {
    if (value.length > 17 && value.isNotEmpty) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PHONE_OVER_MAXIMUM_NUMBER);
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PHONE_CAN_NOT_CONTAIN_WORD);
    }

    return null;
  }

  static String? validatePrice(String value) => (value.length > 16)
      ? MessageUtil.getMessageByCode(MessageCodeUtil.PRICE_OVER_MAXIMUM_NUMBER)
      : null;

  static String? validateNationalId(String value) {
    if (value.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NATIONAL_ID);
    }
    if (value.length > 64) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NATIONAL_ID_OVER_MAXIMUM_CHARACTERS);
    }
    if (!sidRegex.hasMatch(value)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NATIONAL_ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
    }
    return null;
  }

  static String? validateRequiredNonSpecificCharacterName(String? name) {
    if (name == null || name.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
    }
    if (name.trim().isEmpty) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NAME_CAN_NOT_BE_BLANK);
    }
    if (specificCharactersRegex.hasMatch(name)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.NAME_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
    }
    return null;
  }

  static String? validateRequiredEmail(String? email) {
    if (email == null || email.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_EMAIL);
    }
    if (!emailRegex.hasMatch(email)) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_EMAIL);
    }
    return null;
  }

  static String? validateNonRequiredEmail(String? email) {
    if (email != null && email.isNotEmpty && !emailRegex.hasMatch(email)) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INVALID_EMAIL);
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_PASSWORD);
    }
    if (password.length < 6) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.PASSWORD_MIN_LENGTH);
    }
    return null;
  }

  static String? validateRequiredId(String? id) {
    pragma(id ?? "");
    if (id == null || id.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_ID);
    }
    if (id.trim().isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.ID_CAN_NOT_BE_BLANK);
    }
    if (id.length > 16) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.OVER_ID_MAX_LENGTH);
    }
    if (!sidRegex.hasMatch(id)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.ID_MUST_NOT_CONTAIN_SPECIFIC_CHAR);
    }
    return null;
  }

  static String? validateRequiredName(String? name) {
    if (name == null || name.isEmpty) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
    }
    if (name.length > 64) {
      return MessageUtil.getMessageByCode(MessageCodeUtil.OVER_NAME_MAX_LENGTH);
    }
    return null;
  }

  static String? validateRequiredStatus(String status) {
    if (status.length > 30) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.OVER_STATUS_MAX_LENGTH);
    }
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone == '') {
      return MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_PHONE);
    }
    if (phone.length < 6 || phone.length > 64) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PHONE_SMALLER_THAN_MINIMUM_LENGTH);
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(phone)) {
      return MessageUtil.getMessageByCode(
          MessageCodeUtil.PHONE_CAN_NOT_CONTAIN_WORD);
    }
    return null;
  }
}
