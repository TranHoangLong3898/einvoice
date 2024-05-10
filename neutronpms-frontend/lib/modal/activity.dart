import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/manager/paymentmethodmanager.dart';
import 'package:ihotel/manager/roommanager.dart';
import 'package:ihotel/util/messageulti.dart';
import 'package:ihotel/util/numberutil.dart';

import '../constants.dart';

class Activity {
  String type;
  String id;
  String sid;
  String bookingId;
  String desc;
  String email;
  Timestamp createdTime;

  Activity(this.type, this.id, this.bookingId, this.desc, this.email,
      this.createdTime, this.sid);

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      json['type'] ?? '',
      json['id'] ?? '',
      json['booking_id'] ?? '',
      json['desc'] ?? '',
      json['email'] ?? '',
      json['created_time'],
      json['sid'] ?? '',
    );
  }

  String decodeDesc() {
    String result = '';
    List<String> descArr = desc.split(specificCharacter);
    try {
      String room = descArr[1].isEmpty
          ? MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_NONE_ROOM)
          : RoomManager().getNameRoomById(descArr[1]);
      //book or cancel room
      if (room == '') {
        switch (descArr[1]) {
          case 'book_room':
            return '${descArr[0]} ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_BOOK_ROOM_X, [
                  RoomManager().getNameRoomById(descArr[2])
                ])}';
          default:
            return descArr.toString();
        }
      }

      //update booking, CRUD service, CRUD deposit
      result += '${descArr[0]} ($room) ';
      switch (descArr[2]) {
        case 'create':
          if (descArr[3] == 'bike_rental') {
            result += MessageUtil.getMessageByCode(
                MessageCodeUtil.ACTIVITY_CREATE_NEW_BIKE_X, [descArr[4]]);
          } else {
            result += MessageUtil.getMessageByCode(
                MessageCodeUtil.ACTIVITY_CREATE_NEW_X_WITH_AMOUNT, [
              MessageUtil.getMessageByCode(descArr[3]),
              NumberUtil.numberFormat.format(num.tryParse(descArr[4]))
            ]);
          }
          break;
        case 'update':
          if (descArr[3] == 'deposit_description') {
            result += MessageUtil.getMessageByCode(
                MessageCodeUtil.ACTIVITY_UPDATE_X,
                [MessageUtil.getMessageByCode(descArr[3])]);
          } else {
            if (descArr.length >= 8) {
              result +=
                  '${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_UPDATE_X, [
                    MessageUtil.getMessageByCode(descArr[3])
                  ])}, ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_UPDATE_X, [
                    MessageUtil.getMessageByCode(descArr[7])
                  ])}';
              if (descArr.length >= 12) {
                result +=
                    ', ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_UPDATE_X, [
                      MessageUtil.getMessageByCode(descArr[11])
                    ])}';
              }
            } else {
              String descA = num.tryParse(descArr[4]) == null
                  ? PaymentMethodManager().getPaymentMethodNameById(descArr[4])
                  : NumberUtil.numberFormat.format(num.parse(descArr[4]));
              String descB = num.tryParse(descArr[5]) == null
                  ? PaymentMethodManager().getPaymentMethodNameById(descArr[5])
                  : NumberUtil.numberFormat.format(num.parse(descArr[5]));
              result += MessageUtil.getMessageByCode(
                  MessageCodeUtil.ACTIVITY_UPDATE_X_FROM_A_TO_B,
                  [MessageUtil.getMessageByCode(descArr[3]), descA, descB]);
            }
          }
          break;
        case 'delete':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_DELETE_X,
              [MessageUtil.getMessageByCode(descArr[3])]);
          break;
        case 'checked_in_bike':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHECKIN_BIKE_X, [descArr[3]]);
          break;
        case 'checked_out_bike':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHECKOUT_BIKE_X, [descArr[3]]);
          break;
        case 'change_bike':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHANGE_BIKE_FROM_A_TO_B,
              [descArr[3], descArr[4]]);
          break;
        case 'checkin':
          result +=
              MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHECKIN);
          break;
        case 'checkout':
          result +=
              MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHECKOUT);
          break;
        case 'undo_checkin':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_UNDO_CHECKIN);
          break;
        case 'undo_checkout':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_UNDO_CHECKOUT);
          break;
        case 'change_name':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHANGE_NAME_TO_X, [descArr[3]]);
          if (descArr[4] == 'change_room') {
            result +=
                ', ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHANGE_ROOM_TO_X, [
                  RoomManager().getNameRoomById(descArr[5])
                ])}';
            if (descArr[6] == 'change_date') {
              result +=
                  ', ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHANGE_DATE)}';
            }
          } else if (descArr[4] == 'change_date') {
            result +=
                ', ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHANGE_DATE)}';
          }
          break;
        case 'change_room':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHANGE_ROOM_TO_X,
              [RoomManager().getNameRoomById(descArr[3])]);
          if (descArr[4] == 'change_date') {
            result +=
                ', ${MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CHANGE_DATE)}';
          }
          break;
        case 'change_date':
          result += MessageUtil.getMessageByCode(
              MessageCodeUtil.ACTIVITY_CHANGE_DATE);
          break;
        case 'cancel':
          result +=
              MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_CANCEL);
          break;
        case 'noshow':
          result +=
              MessageUtil.getMessageByCode(MessageCodeUtil.ACTIVITY_NOSHOW);
          break;
        default:
          return descArr.toString();
      }
      return result;
    } catch (e) {
      return descArr.toString();
    }
  }
}
