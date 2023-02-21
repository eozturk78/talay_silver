class DetailedDare {
  final double Weight;
  final int Quantity;

  DetailedDare({required this.Weight, required this.Quantity});

  factory DetailedDare.formJson(Map<String, dynamic> json) {
    return DetailedDare(
      Weight: json['Weight'],
      Quantity:
          json['Quantity'] != null ? (json['Quantity'] as double).toInt() : 0,
    );
  }
}
