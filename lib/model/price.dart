class PriceModel {
  final String PriceTypeId;
  final int PriceTypeGroup;
  final String PriceTypeGroupDesc;
  final String PriceTypeName;
  final int Carat;
  final double Price;

  const PriceModel(
      {required this.PriceTypeGroupDesc,
      required this.PriceTypeName,
      required this.Carat,
      required this.Price,
      required this.PriceTypeId,
      required this.PriceTypeGroup});

  factory PriceModel.formJson(Map<String, dynamic> json) {
    return PriceModel(
      PriceTypeGroupDesc: json['PriceTypeGroupDesc'],
      PriceTypeName: json['PriceTypeName'],
      Carat: json['Carat'],
      Price: json['Price'],
      PriceTypeId: json['PriceTypeId'],
      PriceTypeGroup: json['PriceTypeGroup'],
    );
  }

  static fromJson(e) {}
}
