import 'package:talay_mobile/model/city.dart';

class Country {
  final String CountryId;
  final String CountryName;
  final String? CountryCode;
  final String? AreaCode;
  final int IsDefault;
  List<City>? Cities;

  Country(
      {required this.CountryId,
      required this.CountryName,
      required this.CountryCode,
      required this.AreaCode,
      required this.IsDefault,
      this.Cities});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      CountryId: json['CountryId'],
      CountryCode: json['CountryCode'],
      CountryName: json['CountryName'],
      AreaCode: json['AreaCode'],
      IsDefault: json['IsDefault'],
      Cities: json['Cities'] != null
          ? (json['Cities'] as List).map((e) => City.formJson(e)).toList()
          : null,
    );
  }
}
