import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ihotel/modal/staydeclaration/countrydeclaration.dart';

class StayDeclaration {
  String? bookingId;
  String? name;
  DateTime? dateOfBirth;
  String? accuracyOfDob; //ngaythangnam, thangnam, nam
  String? gender; //Chưa có thông tin, Giới tính nam, Giới tính nữ, Khác
  String? nationalId;
  String? passport;
  String? otherDocId;
  String? nationality;
  String? nationalAddress;
  String? cityAddress;
  String? districtAddress;
  String? communeAddress;
  String? detailAddress;
  String? stayType;
  DateTime? inDate;
  DateTime? outDate;
  String? roomId;
  String? reason;

  StayDeclaration({
    this.bookingId,
    this.name,
    this.dateOfBirth,
    this.accuracyOfDob,
    this.gender,
    this.nationalId,
    this.passport,
    this.otherDocId,
    this.nationality,
    this.nationalAddress,
    this.cityAddress,
    this.districtAddress,
    this.communeAddress,
    this.detailAddress,
    this.stayType,
    this.inDate,
    this.outDate,
    this.roomId,
    this.reason,
  });

  factory StayDeclaration.fromJson(dynamic json) {
    return StayDeclaration(
      name: json['name'],
      dateOfBirth: (json['date_of_birth'] as Timestamp).toDate(),
      accuracyOfDob: json['accuracy'],
      gender: json['gender'],
      nationalId: json['national_id'] ?? "",
      passport: json['passport'] ?? "",
      otherDocId: json['other_doc'] ?? "",
      nationality: json['nationality'] ?? "",
      nationalAddress: json['national_address'] ?? "",
      cityAddress: json['city_address'] ?? "",
      districtAddress: json['district_address'] ?? "",
      communeAddress: json['commune_address'] ?? "",
      detailAddress: json['detail_address'] ?? "",
      stayType: json['stay_type'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date_of_birth': dateOfBirth.toString(),
      'accuracy': accuracyOfDob,
      'gender': gender,
      'national_id': nationalId,
      'passport': passport,
      'other_doc': otherDocId,
      'nationality': nationality,
      'national_address': nationalAddress,
      if (nationalAddress == CountryDeclaration.VIETNAM)
        'city_address': cityAddress,
      if (nationalAddress == CountryDeclaration.VIETNAM)
        'district_address': districtAddress,
      if (nationalAddress == CountryDeclaration.VIETNAM)
        'commune_address': communeAddress,
      if (nationalAddress == CountryDeclaration.VIETNAM)
        'detail_address': detailAddress,
      'stay_type': stayType,
      'reason': reason,
    };
  }

  bool equalTo(StayDeclaration other) =>
      name == other.name &&
      dateOfBirth!.isAtSameMomentAs(other.dateOfBirth!) &&
      accuracyOfDob == other.accuracyOfDob &&
      gender == other.gender &&
      nationalId == other.nationalId &&
      passport == other.passport &&
      otherDocId == other.otherDocId &&
      nationality == other.nationality &&
      nationalAddress == other.nationalAddress &&
      cityAddress == other.cityAddress &&
      districtAddress == other.districtAddress &&
      communeAddress == other.communeAddress &&
      reason == other.reason;
}
