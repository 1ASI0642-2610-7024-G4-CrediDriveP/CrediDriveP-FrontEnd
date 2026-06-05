class LoanPlan {
  final int id;
  final String name;
  final String currency;
  final String rateType;
  final double interestRate;
  final String capitalization;
  final int termMonths;
  final String graceType;
  final int graceMonths;
  final String paymentMethod;
  final double? balloonPercentage;
  final double cokAnnual;

  const LoanPlan({
    required this.id,
    required this.name,
    required this.currency,
    required this.rateType,
    required this.interestRate,
    required this.capitalization,
    required this.termMonths,
    required this.graceType,
    required this.graceMonths,
    required this.paymentMethod,
    required this.balloonPercentage,
    required this.cokAnnual,
  });
}
