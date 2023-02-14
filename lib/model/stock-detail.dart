import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/file.dart';
import 'package:talay_mobile/model/stock-variants.dart';

import 'currency.dart';

class StockDetail {
  final String StockName;
  final String StockId;
  final String StockCode;
  final int Carat;
  final double WorkmanshipPrice;
  final double MetalGRPrice;
  final bool WorkmanshipPriceAuth;
  final bool MetalGRPriceAuth;

  final double Price;
  final CurrencyModel Currency;
  final List<StockVariant>? StockVariants;
  final List<File> Files;
  StockDetail({
    required this.StockName,
    required this.StockId,
    required this.StockCode,
    required this.Carat,
    required this.WorkmanshipPrice,
    required this.MetalGRPrice,
    required this.Price,
    required this.Currency,
    required this.StockVariants,
    required this.Files,
    required this.MetalGRPriceAuth,
    required this.WorkmanshipPriceAuth,
  });
  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      StockName: json['StockName'],
      StockId: json['StockId'],
      Price: json['Price'],
      Carat: json['Carat'],
      WorkmanshipPrice: json['WorkmanshipPrice'],
      WorkmanshipPriceAuth: json['WorkmanshipPriceAuth'],
      MetalGRPriceAuth: json['MetalGRPriceAuth'],
      MetalGRPrice: json['MetalGRPrice'],
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
    );
  }
}
