/// Reglas de validación electrónica en tiempo real.
///
/// Cada función devuelve `null` si el valor es válido, o un mensaje de error
/// para mostrar bajo el campo (Material `errorText`).
class FieldValidators {
  static String? tea(String v) {
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Ingresa un número válido';
    if (n <= 0) return 'Debe ser mayor a 0';
    if (n > 100) return 'TEA no puede superar 100%';
    return null;
  }

  static String? termMonths(String v) {
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Ingresa un entero';
    if (n < 12) return 'Mínimo 12 meses';
    if (n > 84) return 'Máximo 84 meses';
    return null;
  }

  static String? graceMonths(String v, int term) {
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null) return 'Ingresa un entero';
    if (n < 0) return 'No puede ser negativo';
    if (n > term ~/ 3) return 'Máx ${term ~/ 3} meses (1/3 del plazo)';
    return null;
  }

  static String? amount(String v) {
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Ingresa un número';
    if (n <= 0) return 'Debe ser positivo';
    return null;
  }

  static String? downPayment(String v, double vehiclePrice) {
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Ingresa un número';
    if (n < 0) return 'No puede ser negativo';
    if (n > vehiclePrice) return 'No puede superar el precio del vehículo';
    if (n < vehiclePrice * 0.20) {
      return 'Mínimo 20% del precio (S/ ${(vehiclePrice * 0.20).toStringAsFixed(2)})';
    }
    return null;
  }

  static String? dni(String v) {
    if (v.isEmpty) return null;
    if (!RegExp(r'^\d{8}$').hasMatch(v)) return 'Debe ser 8 dígitos numéricos';
    return null;
  }

  static String? installmentVsIncome(double cuota, double income) {
    if (income <= 0) return null;
    if (cuota / income > 0.30) {
      return 'Cuota supera el 30% del ingreso (riesgo)';
    }
    return null;
  }

  static String? balloon(String v) {
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Ingresa un número';
    if (n <= 0 || n >= 1) return 'Debe ser entre 0 y 1 (ej: 0.30)';
    return null;
  }
}
