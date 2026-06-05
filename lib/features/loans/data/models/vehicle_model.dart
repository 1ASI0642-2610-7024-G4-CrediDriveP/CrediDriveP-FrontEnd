import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.brand,
    required super.model,
    required super.year,
    required super.condition,
    required super.price,
    required super.priceCurrency,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as int,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        condition: json['condition'] as String,
        price: (json['price'] as num).toDouble(),
        priceCurrency: json['price_currency'] as String,
      );
}
