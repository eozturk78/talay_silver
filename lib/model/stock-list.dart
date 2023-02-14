import 'package:talay_mobile/model/currency.dart';
import 'package:talay_mobile/model/file.dart';

class StockList {
  final String StockName;
  final String StockId;
  final String StockCode;
  final String AccountTitle;
  final int SellingType;
  final int StockType;
  final bool UseVariantsOnSell;
  final bool UseVariantsOnBuy;
  final List<File> Files;

  const StockList(
      {required this.StockName,
      required this.StockId,
      required this.StockCode,
      required this.StockType,
      required this.SellingType,
      required this.AccountTitle,
      required this.UseVariantsOnBuy,
      required this.UseVariantsOnSell,
      required this.Files});
  factory StockList.fromJson(Map<String, dynamic> json) {
    return StockList(
      StockName: json['StockName'] ?? "",
      StockId: json['StockId'],
      StockCode: json['StockCode'],
      Files: json['Files'] != null
          ? (json['Files'] as List).map((e) => File.fromJson(e)).toList()
          : [],
      AccountTitle: json['AccountTitle'] ?? "",
      StockType: json['StockType'] ?? 0,
      SellingType: json['SellingType'] ?? 0,
      UseVariantsOnBuy: json['UseVariantOnBuy'] ?? false,
      UseVariantsOnSell: json['UseVariantOnSell'] ?? false,
    );
  }
}
