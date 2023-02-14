class Account {
  String? AccountId;
  String? AccountCode;
  final String Title;
  final String? PhoneNumber;
  final String? CountryName;
  final String? CityName;
  final String? Email;
  Account({
    this.AccountId,
    this.AccountCode,
    required this.Title,
    this.PhoneNumber,
    this.CountryName,
    this.CityName,
    this.Email,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      AccountId: json['AccountId'],
      AccountCode: json['AccountCode'],
      Title: json['Title'],
      PhoneNumber: json['PhoneNumber'],
      Email: json['Email'],
      CountryName: json['CountryName'],
      CityName: json['CityName'],
    );
  }
}
