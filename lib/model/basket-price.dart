class BasketPriceModel {
  final int SellingType;
  final String SellingTypeDesc;
  final int Carat;
  final double Price;

  const BasketPriceModel(
      {required this.SellingType,
      required this.SellingTypeDesc,
      required this.Carat,
      required this.Price});

  factory BasketPriceModel.formJson(Map<String, dynamic> json) {
    return BasketPriceModel(
      SellingType: json['SellingType'],
      SellingTypeDesc: json['SellingTypeDesc'],
      Carat: json['Carat'],
      Price: json['Price'],
    );
  }

  static fromJson(e) {}
}
