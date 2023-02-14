class ExchangeRate {
  final String CurrencyId;
  final String CurrencyCode;
  final String CurrencyName;
  final String Symbol;
  final double Buying;
  final double Selling;
  final double BuyingRateCrossRate;
  final double SellingRateCrossRate;
  const ExchangeRate(
      {required this.CurrencyId,
      required this.CurrencyCode,
      required this.CurrencyName,
      required this.Symbol,
      required this.Buying,
      required this.Selling,
      required this.BuyingRateCrossRate,
      required this.SellingRateCrossRate});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
        CurrencyId: json['CurrencyId'],
        CurrencyCode: json['CurrencyCode'],
        Symbol: json['Symbol'],
        CurrencyName: json['CurrencyName'],
        Buying: json['Buying'],
        Selling: json['Selling'],
        BuyingRateCrossRate: json['BuyingRateCrossRate'],
        SellingRateCrossRate: json['SellingRateCrossRate']);
  }
}
