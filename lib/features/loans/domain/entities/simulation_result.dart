class ScheduleItem {
  final int periodNumber;
  final String dueDate;
  final String graceApplied;
  final double openingBalance;
  final double interest;
  final double principal;
  final double insuranceDesgravamen;
  final double insuranceVehicular;
  final double commission;
  final double balloon;
  final double totalPayment;
  final double closingBalance;

  const ScheduleItem({
    required this.periodNumber,
    required this.dueDate,
    required this.graceApplied,
    required this.openingBalance,
    required this.interest,
    required this.principal,
    required this.insuranceDesgravamen,
    required this.insuranceVehicular,
    required this.commission,
    required this.balloon,
    required this.totalPayment,
    required this.closingBalance,
  });
}

class Indicators {
  final double van;
  final double tirMonthly;
  final double tirAnnual;
  final double tcea;
  final double cokUsed;

  const Indicators({
    required this.van,
    required this.tirMonthly,
    required this.tirAnnual,
    required this.tcea,
    required this.cokUsed,
  });
}

class SimulationResult {
  final int? loanId;
  final String name;
  final String currency;
  final double amountFinanced;
  final double monthlyPaymentBase;
  final List<ScheduleItem> schedule;
  final Indicators indicators;
  final String status;

  const SimulationResult({
    required this.loanId,
    required this.name,
    required this.currency,
    required this.amountFinanced,
    required this.monthlyPaymentBase,
    required this.schedule,
    required this.indicators,
    required this.status,
  });
}
