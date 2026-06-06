import 'dart:math' as math;

import '../models/vehicle_model.dart';
import '../models/loan_plan_model.dart';
import '../models/simulation_result_model.dart';
import '../../domain/entities/simulation_result.dart';
import 'loan_remote_data_source.dart';

/// Implementación mock pa demo sin backend ni MySQL.
///
/// Permite ver el diseño completo del Cap 5 con datos hardcodeados.
/// Para producción usar [LoanRemoteDataSourceImpl].
class LoanMockDataSource implements LoanRemoteDataSource {
  static int _nextLoanId = 1;
  final List<Map<String, dynamic>> _savedLoans = [];

  @override
  Future<List<VehicleModel>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      VehicleModel(
          id: 1, brand: 'Toyota', model: 'Yaris GLi', year: 2026,
          condition: 'NEW', price: 65000, priceCurrency: 'PEN'),
      VehicleModel(
          id: 2, brand: 'Kia', model: 'Rio Hatchback', year: 2026,
          condition: 'NEW', price: 58000, priceCurrency: 'PEN'),
      VehicleModel(
          id: 3, brand: 'Hyundai', model: 'Accent', year: 2025,
          condition: 'USED', price: 52000, priceCurrency: 'PEN'),
      VehicleModel(
          id: 4, brand: 'Mazda', model: 'CX-5', year: 2026,
          condition: 'NEW', price: 18500, priceCurrency: 'USD'),
      VehicleModel(
          id: 5, brand: 'Volkswagen', model: 'Tiguan', year: 2026,
          condition: 'NEW', price: 22000, priceCurrency: 'USD'),
    ];
  }

  @override
  Future<List<LoanPlanModel>> getPlans() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      LoanPlanModel(
        id: 1, name: 'CrediClásico Soles 36m', currency: 'PEN',
        rateType: 'TEA', interestRate: 0.1450, capitalization: 'MONTHLY',
        termMonths: 36, graceType: 'NONE', graceMonths: 0,
        paymentMethod: 'FRENCH', balloonPercentage: null, cokAnnual: 0.10,
      ),
      LoanPlanModel(
        id: 2, name: 'CrediClásico Soles 60m con gracia parcial', currency: 'PEN',
        rateType: 'TEA', interestRate: 0.1525, capitalization: 'MONTHLY',
        termMonths: 60, graceType: 'PARTIAL', graceMonths: 3,
        paymentMethod: 'FRENCH', balloonPercentage: null, cokAnnual: 0.10,
      ),
      LoanPlanModel(
        id: 3, name: 'Compra Inteligente Soles 36m', currency: 'PEN',
        rateType: 'TEA', interestRate: 0.1380, capitalization: 'MONTHLY',
        termMonths: 36, graceType: 'NONE', graceMonths: 0,
        paymentMethod: 'FRENCH_BALLOON', balloonPercentage: 0.30,
        cokAnnual: 0.10,
      ),
      LoanPlanModel(
        id: 4, name: 'CrediDólares 48m', currency: 'USD',
        rateType: 'TEA', interestRate: 0.0995, capitalization: 'MONTHLY',
        termMonths: 48, graceType: 'NONE', graceMonths: 0,
        paymentMethod: 'FRENCH', balloonPercentage: null, cokAnnual: 0.07,
      ),
    ];
  }

  @override
  Future<SimulationResultModel> simulate(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _calculate(payload, loanId: null, status: 'SIMULATED');
  }

  @override
  Future<SimulationResultModel> createLoan(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final r = _calculate(payload, loanId: _nextLoanId++, status: 'SIMULATED');
    _savedLoans.add({
      'id': r.loanId,
      'name': r.name,
      'currency': r.currency,
      'amount_financed': r.amountFinanced,
      'status': r.status,
    });
    return r;
  }

  @override
  Future<List<Map<String, dynamic>>> listLoans() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<Map<String, dynamic>>.from(_savedLoans);
  }

  // --- núcleo financiero (replica el del backend) -----------------------

  SimulationResultModel _calculate(Map<String, dynamic> payload,
      {required int? loanId, required String status}) {
    final vehicles = const [
      {'id': 1, 'price': 65000.0, 'currency': 'PEN'},
      {'id': 2, 'price': 58000.0, 'currency': 'PEN'},
      {'id': 3, 'price': 52000.0, 'currency': 'PEN'},
      {'id': 4, 'price': 18500.0, 'currency': 'USD'},
      {'id': 5, 'price': 22000.0, 'currency': 'USD'},
    ];
    final plans = _plansSync();
    final vehicle = vehicles.firstWhere((v) => v['id'] == payload['vehicle_id']);
    final plan = plans.firstWhere((p) => p.id == payload['plan_id']);
    final down = (payload['down_payment'] as num).toDouble();
    final vehiclePrice = (vehicle['price'] as num).toDouble();
    final principal = vehiclePrice - down;
    final tea = plan.interestRate;
    final tem = math.pow(1 + tea, 1 / 12).toDouble() - 1;
    final n = plan.termMonths;
    final gm = plan.graceMonths;
    final payingPeriods = n - gm;
    final isBalloon = plan.paymentMethod == 'FRENCH_BALLOON';
    final balloonAmt =
        isBalloon ? vehiclePrice * (plan.balloonPercentage ?? 0) : 0.0;

    final principalPostGrace = plan.graceType == 'TOTAL' && gm > 0
        ? principal * math.pow(1 + tem, gm).toDouble()
        : principal;

    final basePayment = _frenchPayment(
        principalPostGrace, tem, payingPeriods, isBalloon, balloonAmt);

    // Seguro desgravamen 0.028% mensual sobre saldo
    const desgRate = 0.00028;
    // Seguro vehicular 0.30% mensual sobre valor del vehículo
    const vehicRate = 0.0030;
    // Comisión envío estado de cuenta mensual
    const monthlyCommission = 8.0;

    final rows = <ScheduleItem>[];
    var opening = principal;
    final startDate = DateTime.parse(payload['start_date']);
    for (var k = 1; k <= n; k++) {
      final due = DateTime(startDate.year, startDate.month + k, startDate.day);
      final inGrace = k <= gm;
      final graceApplied = inGrace ? plan.graceType : 'NONE';
      final interest = opening * tem;
      double principalPay;
      double closing;
      double cuotaCI;

      if (inGrace && plan.graceType == 'TOTAL') {
        principalPay = 0;
        closing = opening + interest;
        cuotaCI = 0;
      } else if (inGrace && plan.graceType == 'PARTIAL') {
        principalPay = 0;
        closing = opening;
        cuotaCI = interest;
      } else {
        principalPay = math.max(0.0, basePayment - interest);
        closing = opening - principalPay;
        cuotaCI = basePayment;
      }

      var balloonPay = 0.0;
      if (k == n && isBalloon) {
        balloonPay = closing;
        principalPay += closing;
        closing = 0;
      }

      final desg = opening * desgRate;
      final vehic = vehiclePrice * vehicRate;
      final total = cuotaCI + balloonPay + desg + vehic + monthlyCommission;

      rows.add(ScheduleItem(
        periodNumber: k,
        dueDate: '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
        graceApplied: graceApplied,
        openingBalance: opening,
        interest: interest,
        principal: principalPay,
        insuranceDesgravamen: desg,
        insuranceVehicular: vehic,
        commission: monthlyCommission,
        balloon: balloonPay,
        totalPayment: total,
        closingBalance: closing,
      ));
      opening = closing;
    }

    // Flujos + VAN/TIR/TCEA desde perspectiva deudor
    final flows = <double>[principal];
    for (final r in rows) {
      flows.add(-r.totalPayment);
    }
    final cokMonthly = math.pow(1 + plan.cokAnnual, 1 / 12).toDouble() - 1;
    double van = 0;
    for (var t = 0; t < flows.length; t++) {
      van += flows[t] / math.pow(1 + cokMonthly, t);
    }
    final tir = _irr(flows);
    final tirAnnual = math.pow(1 + tir, 12).toDouble() - 1;

    final monthlyBase =
        rows.firstWhere((r) => r.graceApplied == 'NONE').totalPayment;

    return SimulationResultModel(
      loanId: loanId,
      name: payload['name'] as String,
      currency: plan.currency,
      amountFinanced: principal,
      monthlyPaymentBase: monthlyBase,
      schedule: rows,
      indicators: Indicators(
        van: van,
        tirMonthly: tir,
        tirAnnual: tirAnnual,
        tcea: tirAnnual,
        cokUsed: plan.cokAnnual,
      ),
      status: status,
    );
  }

  double _frenchPayment(
      double p, double i, int n, bool isBalloon, double balloon) {
    if (i == 0) return isBalloon ? (p - balloon) / n : p / n;
    final pvBalloon = balloon / math.pow(1 + i, n);
    final base = isBalloon ? p - pvBalloon : p;
    return base * i / (1 - math.pow(1 + i, -n));
  }

  double _irr(List<double> flows, {double guess = 0.01}) {
    var r = guess;
    for (var iter = 0; iter < 200; iter++) {
      double f = 0, df = 0;
      for (var t = 0; t < flows.length; t++) {
        f += flows[t] / math.pow(1 + r, t);
        df += -t * flows[t] / math.pow(1 + r, t + 1);
      }
      if (df == 0) break;
      final next = r - f / df;
      if ((next - r).abs() < 1e-10) return next;
      r = next;
    }
    return r;
  }

  List<LoanPlanModel> _plansSync() => const [
        LoanPlanModel(
          id: 1, name: 'CrediClásico Soles 36m', currency: 'PEN',
          rateType: 'TEA', interestRate: 0.1450, capitalization: 'MONTHLY',
          termMonths: 36, graceType: 'NONE', graceMonths: 0,
          paymentMethod: 'FRENCH', balloonPercentage: null, cokAnnual: 0.10,
        ),
        LoanPlanModel(
          id: 2, name: 'CrediClásico Soles 60m con gracia parcial',
          currency: 'PEN', rateType: 'TEA', interestRate: 0.1525,
          capitalization: 'MONTHLY', termMonths: 60, graceType: 'PARTIAL',
          graceMonths: 3, paymentMethod: 'FRENCH', balloonPercentage: null,
          cokAnnual: 0.10,
        ),
        LoanPlanModel(
          id: 3, name: 'Compra Inteligente Soles 36m', currency: 'PEN',
          rateType: 'TEA', interestRate: 0.1380, capitalization: 'MONTHLY',
          termMonths: 36, graceType: 'NONE', graceMonths: 0,
          paymentMethod: 'FRENCH_BALLOON', balloonPercentage: 0.30,
          cokAnnual: 0.10,
        ),
        LoanPlanModel(
          id: 4, name: 'CrediDólares 48m', currency: 'USD',
          rateType: 'TEA', interestRate: 0.0995, capitalization: 'MONTHLY',
          termMonths: 48, graceType: 'NONE', graceMonths: 0,
          paymentMethod: 'FRENCH', balloonPercentage: null, cokAnnual: 0.07,
        ),
      ];
}
