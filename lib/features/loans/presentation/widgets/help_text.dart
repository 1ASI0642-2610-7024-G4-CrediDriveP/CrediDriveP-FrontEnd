/// Mensajes de ayuda contextual reutilizados en todos los formularios.
/// Centralizados aquí pa que el copy financiero quede consistente.
class HelpText {
  static const tea =
      'Tasa Efectiva Anual. Incluye la capitalización de intereses. '
      'Ingresa valores entre 0 y 100. Ej: 14.50';
  static const tcea =
      'Tasa de Costo Efectivo Anual. Es el costo total del crédito incluyendo '
      'TEA, seguros y comisiones. Se calcula automáticamente.';
  static const cok =
      'Costo de Oportunidad del Capital. Tasa de descuento usada para calcular '
      'el VAN desde tu perspectiva como deudor.';
  static const term =
      'Duración total del crédito en meses. Mínimo 12, máximo 84.';
  static const graceType =
      'Tipo de periodo de gracia:\n'
      '• TOTAL: no pagas nada, los intereses se capitalizan.\n'
      '• PARCIAL: pagas solo intereses, el capital no baja.\n'
      '• SIN GRACIA: empiezas a pagar cuota completa desde el mes 1.';
  static const graceMonths =
      'Meses iniciales con condición especial. Máx 1/3 del plazo total.';
  static const downPayment =
      'Cuota inicial. Mínimo 20% del valor del vehículo. '
      'Mientras más alta, menor será tu cuota mensual.';
  static const amountToFinance =
      'Monto que el banco te presta = Precio del vehículo - Cuota inicial.';
  static const monthlyPayment =
      'Cuota mensual estimada calculada bajo el método francés vencido ordinario.';
  static const paymentMethod =
      'Método de amortización:\n'
      '• FRANCÉS: cuotas iguales todo el plazo.\n'
      '• FRANCÉS BALLOON: cuotas menores + un pago final grande (Compra Inteligente).';
  static const balloonPercentage =
      'Porcentaje del valor del vehículo que se difiere a la cuota final. '
      'Típico: 25-35%. Ej: 0.30 = 30%.';
  static const currency =
      'PEN (Soles) o USD (Dólares). Si eliges USD, ingresa el tipo de cambio aplicable.';
  static const exchangeRate =
      'Tipo de cambio Sol/Dólar al inicio del crédito (referencia BCRP).';
  static const dni =
      'Documento Nacional de Identidad. Debe ser 8 dígitos numéricos.';
  static const monthlyIncome =
      'Ingreso mensual neto. Se usa pa validar capacidad de pago: '
      'tu cuota no debe exceder el 30% de este ingreso.';
}
