import 'package:talay_mobile/model/detailed-dare.dart';

class BasketRow {
  final String BasketDetailId;
  final int OrderIndex;
  final String StockCode;
  final String StockName;
  final String? StockImage;
  int? OfferCarat;
  double? OfferUnitPrice;
  final int Carat;
  final double UnitPrice;
  double? Quantity;
  final double? GrossWeight;
  final double? TareWeight;
  final double? NetWeight;
  final List<DetailedDare>? DetailedTare;
  BasketRow(
      {required this.BasketDetailId,
      required this.OrderIndex,
      required this.StockCode,
      required this.StockName,
      required this.StockImage,
      this.OfferCarat,
      this.OfferUnitPrice,
      required this.Carat,
      required this.UnitPrice,
      required this.Quantity,
      required this.GrossWeight,
      required this.TareWeight,
      required this.NetWeight,
      required this.DetailedTare});

  factory BasketRow.formJson(Map<String, dynamic> json) {
    return BasketRow(
        BasketDetailId: json['BasketDetailId'],
        OrderIndex: json['OrderIndex'],
        StockCode: json['StockCode'],
        StockName: json['StockName'],
        OfferCarat: json['OfferCarat'],
        OfferUnitPrice: json['OfferUnitPrice'],
        Carat: json['Carat'],
        UnitPrice: json['UnitPrice'],
        Quantity: json['Quantity'],
        GrossWeight: json['GrossWeight'],
        TareWeight: json['TareWeight'],
        NetWeight: json['NetWeight'],
        StockImage: json['StockImage'],
        DetailedTare: json['DetailedTare'] != null
            ? (json['DetailedTare'] as List)
                .map((e) => DetailedDare.formJson(e))
                .toList()
            : []);
  }
}
