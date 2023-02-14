import 'package:talay_mobile/model/file.dart';

class StockVariant {
  final String StockVariantId;
  final String StockVariantCode;
  final String StockVariantName;
  List<File>? Files;

  StockVariant(
      {required this.StockVariantId,
      required this.StockVariantCode,
      required this.StockVariantName,
      this.Files});

  factory StockVariant.fromJson(Map<String, dynamic> json) {
    return StockVariant(
      StockVariantId: json['StockVariantId'],
      StockVariantCode: json['StockVariantCode'],
      StockVariantName: json['StockVariantName'],
      Files: json['Files'] != null
          ? (json['Files'] as List)
              .map(
                (e) => File.fromJson(e),
              )
              .toList()
          : null,
    );
  }
}
