class PriceType {
  final String PriceTypeId;
  final String PriceTypeCode;
  final String PriceTypeName;
  final int PriceTypeGroup;

  const PriceType(
      {required this.PriceTypeId,
      required this.PriceTypeCode,
      required this.PriceTypeName,
      required this.PriceTypeGroup});
  factory PriceType.fromJson(Map<String, dynamic> json) {
    return PriceType(
        PriceTypeId: json['PriceTypeId'],
        PriceTypeCode: json['PriceTypeCode'],
        PriceTypeName: json['PriceTypeName'],
        PriceTypeGroup: json['PriceTypeGroup']);
  }
}
