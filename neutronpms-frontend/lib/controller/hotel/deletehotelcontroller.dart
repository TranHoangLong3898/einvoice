import 'package:flutter/cupertino.dart';

class DeleteHotelController extends ChangeNotifier {
  late TextEditingController teNameHotel;
  late String errorMessage;
  DeleteHotelController() {
    teNameHotel = TextEditingController(text: '');
  }
  bool isLoading = false;

  deleteHotel() async {
    // print(this.teNameHotel.text);
    // if (this.teNameHotel.text == '') {
    //   this.errorMessage =
    //       MessageUtil.getMessageByCode(MessageCodeUtil.INPUT_NAME);
    //   return false;
    // }
    // isLoading = true;
    // notifyListeners();
    // try {
    //   final callbale =
    //       FirebaseFunctions.instance.httpsCallable('hotelmanager-deleteHotel');
    //   final result = await callbale({'hotelName': this.teNameHotel.text});
    //   print(result.data);
    //   // isLoading = false;
    //   // notifyListeners();
    //   // return true;
    // } on FirebaseFunctionsException catch (e) {
    //   print(e.message);
    //   this.errorMessage = e.message;
    //   isLoading = false;
    //   notifyListeners();
    //   return false;
    // }
  }
}
