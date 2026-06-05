class Vehicle {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String condition;
  final double price;
  final String priceCurrency;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.condition,
    required this.price,
    required this.priceCurrency,
  });

  String get label => '$brand $model $year';
}
