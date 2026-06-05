import '../../domain/entities/loan_plan.dart';

class LoanPlanModel extends LoanPlan {
  const LoanPlanModel({
    required super.id,
    required super.name,
    required super.currency,
    required super.rateType,
    required super.interestRate,
    required super.capitalization,
    required super.termMonths,
    required super.graceType,
    required super.graceMonths,
    required super.paymentMethod,
    required super.balloonPercentage,
    required super.cokAnnual,
  });

  factory LoanPlanModel.fromJson(Map<String, dynamic> json) => LoanPlanModel(
        id: json['id'] as int,
        name: json['name'] as String,
        currency: json['currency'] as String,
        rateType: json['rate_type'] as String,
        interestRate: (json['interest_rate'] as num).toDouble(),
        capitalization: json['capitalization'] as String,
        termMonths: json['term_months'] as int,
        graceType: json['grace_type'] as String,
        graceMonths: json['grace_months'] as int,
        paymentMethod: json['payment_method'] as String,
        balloonPercentage: json['balloon_percentage'] == null
            ? null
            : (json['balloon_percentage'] as num).toDouble(),
        cokAnnual: (json['cok_annual'] as num).toDouble(),
      );
}
