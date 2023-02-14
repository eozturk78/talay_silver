class CurrencyModel {
  late final String CurrencyId;
  int? CurrentType;
  final String CurrencyCode;
  final String Symbol;
  bool? SysCurrency;
  int? IsLocalCurrency;
  int? IsDefault;
  String? ExchangeRateCurrencyId;

  CurrencyModel(
      {required this.CurrencyId,
      this.CurrentType,
      required this.CurrencyCode,
      required this.Symbol,
      this.SysCurrency,
      this.IsLocalCurrency,
      this.IsDefault,
      this.ExchangeRateCurrencyId});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
        CurrencyId: json['CurrencyId'],
        CurrentType: json['CurrentType'],
        CurrencyCode: json['CurrencyCode'],
        Symbol: json['Symbol'],
        SysCurrency: json['SysCurrency'],
        IsLocalCurrency: json['IsLocalCurrency'],
        IsDefault: json['IsDefault'],
        ExchangeRateCurrencyId: json['ExchangeRateCurrencyId']);
  }
}
