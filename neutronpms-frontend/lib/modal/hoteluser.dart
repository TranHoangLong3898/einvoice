import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/util/messageulti.dart';

class HotelUser {
  String? id;
  String? firstName;
  String? lastName;
  String? fullname;
  String? phone;
  String? email;
  String? gender;
  // String? address;
  // String? country;
  // String? city;
  // String? nationalId;
  // String? job;
  DateTime? dateOfBirth;
  bool? isAdminSystem;

  HotelUser(
      {this.firstName,
      this.lastName,
      this.phone,
      this.gender,
      // this.address,
      // this.country,
      // this.city,
      // this.nationalId,
      // this.job,
      this.dateOfBirth,
      this.id,
      this.email,
      this.isAdminSystem}) {
    fullname = '${firstName ?? ""} ${lastName ?? ""}';
  }

  factory HotelUser.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> docData = (doc.data() as Map<String, dynamic>);
    DateTime? dob = docData['date_of_birth'] == null
        ? null
        : (docData['date_of_birth'] as Timestamp).toDate();
    return HotelUser(
      id: doc.id,
      email: docData['email'],
      gender: docData['gender'],

      firstName: docData['first_name'],
      lastName: docData['last_name'],
      // job: docData['job'],
      // address: docData['address'],
      // nationalId: docData['national_id'],
      // country: docData['country'],
      // city: docData['city'],
      dateOfBirth: dob,
      phone: docData['phone'],
      isAdminSystem: docData['admin'] ?? false,
    );
  }

  //render result from API
  factory HotelUser.fromMap(dynamic data) => HotelUser(
      id: data['id'],
      email: data['email'],
      gender: data['gender'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      // address: data['address'],
      // job: data['job'],
      // nationalId: data['national_id'],
      // country: data['country'],
      // city: data['city'],
      dateOfBirth: Timestamp.fromMillisecondsSinceEpoch(
              data['date_of_birth']['_seconds'] * 1000)
          .toDate(),
      phone: data['phone']);

  factory HotelUser.empty(String uid) => HotelUser(
      id: uid,
      // address: null,
      //    job: null,
      // nationalId: null,
      // country: null,
      // city: null,
      dateOfBirth: null,
      gender: MessageCodeUtil.GENDER_MALE,
      firstName: null,
      lastName: null,
      phone: null,
      isAdminSystem: false);

  factory HotelUser.emptyWithoutUid() => HotelUser(
      id: null,
      // address: null,
      // nationalId: null,
      // job: null,
      // country: null,
      // city: null,
      dateOfBirth: null,
      gender: MessageCodeUtil.GENDER_MALE,
      firstName: null,
      lastName: null,
      phone: null);

  bool isFullOfInformation() =>
      firstName != null &&
      lastName != null &&
      phone != null &&
      gender != null &&
      // country != null &&
      // city != null &&
      // address != null &&
      // nationalId != null &&
      // job != null &&
      dateOfBirth != null;
}
