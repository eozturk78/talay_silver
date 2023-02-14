class DetailedDare {
  final double Weight;
  final double Quantity;

  DetailedDare({required this.Weight, required this.Quantity});

  factory DetailedDare.formJson(Map<String, dynamic> json) {
    return DetailedDare(
      Weight: json['Weight'],
      Quantity: json['Quantity'],
    );
  }
}
