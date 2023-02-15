class Basket {
  final String BasketId;
  final String BasketNo;
  final String UserTitle;
  final String Currency;
  final double TotalItemCount;
  final double TotalGrossWeight;
  final double TotalTareWeight;
  final double TotalNetWeight;
  final int LastItemIndex;
  final int BasketStatus;
  final String BasketStatusDesc;
  final bool AllowUse;

  const Basket(
      {required this.BasketId,
      required this.BasketNo,
      required this.UserTitle,
      required this.Currency,
      required this.TotalItemCount,
      required this.TotalGrossWeight,
      required this.TotalTareWeight,
      required this.TotalNetWeight,
      required this.LastItemIndex,
      required this.BasketStatus,
      required this.BasketStatusDesc,
      required this.AllowUse});

  factory Basket.formJson(Map<String, dynamic> json) {
    return Basket(
        BasketId: json['BasketId'],
        BasketNo: json['BasketNo'],
        UserTitle: json['UserTitle'],
        Currency: json['Currency'],
        TotalItemCount: json['TotalItemCount'],
        TotalGrossWeight: json['TotalGrossWeight'],
        TotalTareWeight: json['TotalTareWeight'],
        TotalNetWeight: json['TotalNetWeight'],
        LastItemIndex: json['LastItemIndex'],
        BasketStatus: json['BasketStatus'],
        BasketStatusDesc: json['BasketStatusDesc'],
        AllowUse: json['AllowUse']);
  }
}
