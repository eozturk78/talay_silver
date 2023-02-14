class City {
  final String CityId;
  final String CityName;

  City({required this.CityId, required this.CityName});

  factory City.formJson(Map<String, dynamic> json) {
    return City(CityId: json['CityId'], CityName: json['CityName']);
  }
}
