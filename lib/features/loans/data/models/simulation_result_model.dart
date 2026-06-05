import '../../domain/entities/simulation_result.dart';

class SimulationResultModel extends SimulationResult {
  const SimulationResultModel({
    required super.loanId,
    required super.name,
    required super.currency,
    required super.amountFinanced,
    required super.monthlyPaymentBase,
    required super.schedule,
    required super.indicators,
    required super.status,
  });

  factory SimulationResultModel.fromJson(Map<String, dynamic> json) {
    final scheduleList = (json['schedule'] as List<dynamic>)
        .map((e) => ScheduleItem(
              periodNumber: e['period_number'] as int,
              dueDate: e['due_date'] as String,
              graceApplied: e['grace_applied'] as String,
              openingBalance: (e['opening_balance'] as num).toDouble(),
              interest: (e['interest'] as num).toDouble(),
              principal: (e['principal'] as num).toDouble(),
              insuranceDesgravamen: (e['insurance_desgravamen'] as num).toDouble(),
              insuranceVehicular: (e['insurance_vehicular'] as num).toDouble(),
              commission: (e['commission'] as num).toDouble(),
              balloon: (e['balloon'] as num).toDouble(),
              totalPayment: (e['total_payment'] as num).toDouble(),
              closingBalance: (e['closing_balance'] as num).toDouble(),
            ))
        .toList();
    final ind = json['indicators'] as Map<String, dynamic>;
    return SimulationResultModel(
      loanId: json['loan_id'] as int?,
      name: json['name'] as String,
      currency: json['currency'] as String,
      amountFinanced: (json['amount_financed'] as num).toDouble(),
      monthlyPaymentBase: (json['monthly_payment_base'] as num).toDouble(),
      schedule: scheduleList,
      indicators: Indicators(
        van: (ind['van'] as num).toDouble(),
        tirMonthly: (ind['tir_monthly'] as num).toDouble(),
        tirAnnual: (ind['tir_annual'] as num).toDouble(),
        tcea: (ind['tcea'] as num).toDouble(),
        cokUsed: (ind['cok_used'] as num).toDouble(),
      ),
      status: json['status'] as String,
    );
  }
}
