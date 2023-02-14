import 'package:talay_mobile/model/basket-price.dart';
import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/file.dart';
import 'package:talay_mobile/model/stock-variants.dart';

class StockBasketDetail {
  final String StockId;
  final String StockName;
  final String StockCode;
  final int SellingType;
  final CurrencyModel Currency;
  final List<File> Files;
  final List<BasketPriceModel> Prices;
  final List<StockVariant>? StockVariants;
  StockBasketDetail(
      {required this.SellingType,
      required this.Prices,
      required this.StockName,
      required this.StockId,
      required this.StockCode,
      required this.Currency,
      required this.StockVariants,
      required this.Files});
  factory StockBasketDetail.fromJson(Map<String, dynamic> json) {
    return StockBasketDetail(
      StockName: json['StockName'],
      StockId: json['StockId'],
      Currency: CurrencyModel.fromJson(json['Currency'][0]),
      StockCode: json['StockCode'],
      SellingType: json['SellingType'],
      StockVariants: json['StockVariants'] != null
          ? (json['StockVariants'] as List)
              .map((e) => StockVariant.fromJson(e))
              .toList()
          : [],
      Files: json['Files'] != null
          ? (json['Files'] as List).map((e) => File.fromJson(e)).toList()
          : [],
      Prices: json['Prices'] != null
          ? (json['Prices'] as List)
              .map((e) => BasketPriceModel.formJson(e))
              .toList()
          : [],
    );
  }
}
