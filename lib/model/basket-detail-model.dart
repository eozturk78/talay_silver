import 'dart:ffi';

import 'package:talay_mobile/model/basket-row.dart';
import 'package:talay_mobile/model/currency.dart';

class BasketDetailModel {
  final String BasketId;
  final String BasketNo;
  final String UserTitle;
  final String CurrencyId;
   double? TotalItemCount;
   double? TotalGrossWeight;
   double? TotalTareWeight;
   double? TotalNetWeight;
   int? LastItemIndex;
  final int BasketStatus;
  final String BasketStatusDesc;
  final String PriceType;
  final List<BasketRow> BasketDetails;
  
  BasketDetailModel({
    required this.BasketId,
    required this.BasketNo,
    required this.UserTitle,
    required this.CurrencyId,
    required this.TotalItemCount,
     this.TotalGrossWeight,
     this.TotalTareWeight,
     this.TotalNetWeight,
     this.LastItemIndex,
    required this.BasketStatus,
    required this.BasketStatusDesc,
    required this.PriceType,
    required this.BasketDetails,
  });

  factory BasketDetailModel.formJson(Map<String, dynamic> json) {
    return BasketDetailModel(
        BasketId: json['BasketId'],
        BasketNo: json['BasketNo'],
        UserTitle: json['UserTitle'],
        CurrencyId: json['CurrencyId'],
        TotalItemCount: json['TotalItemCount'],
        TotalGrossWeight: json['TotalGrossWeight'],
        TotalTareWeight: json['TotalTareWeight'],
        TotalNetWeight: json['TotalNetWeight'],
        LastItemIndex: json['LastItemIndex'],
        BasketStatus: json['BasketStatus'],
        BasketStatusDesc: json['BasketStatusDesc'],
        PriceType: json['PriceType'],
        BasketDetails: json['BasketDetails'] != null
            ? (json['BasketDetails'] as List)
                .map((e) => BasketRow.formJson(e))
                .toList()
            : []);
  }
}
