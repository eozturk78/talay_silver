import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/file.dart';
import 'package:talay_mobile/model/price.dart';
import 'package:talay_mobile/model/stock-variants.dart';

class StockAnalyse {
  final String StockName;
  final String StockId;
  final String StockCode;
  final List<PriceModel> Prices;
  final CurrencyModel Currency;
  final List<StockVariant>? StockVariants;
  final List<File> Files;
  StockAnalyse({
    required this.StockName,
    required this.StockId,
    required this.StockCode,
    required this.Prices,
    required this.Currency,
    required this.StockVariants,
    required this.Files,
  });
  factory StockAnalyse.fromJson(Map<String, dynamic> json) {
    return StockAnalyse(
      StockName: json['StockName'],
      StockId: json['StockId'],
      Currency: CurrencyModel.fromJson(json['Currency'][0]),
      StockCode: json['StockCode'],
      StockVariants: json['StockVariants'] != null
          ? (json['StockVariants'] as List)
              .map((e) => StockVariant.fromJson(e))
              .toList()
          : [],
      Files: json['Files'] != null
          ? (json['Files'] as List).map((e) => File.fromJson(e)).toList()
          : [],
      Prices: json['Prices'] != null
          ? (json['Prices'] as List).map((e) => PriceModel.formJson(e)).toList()
          : [],
    );
  }
}
