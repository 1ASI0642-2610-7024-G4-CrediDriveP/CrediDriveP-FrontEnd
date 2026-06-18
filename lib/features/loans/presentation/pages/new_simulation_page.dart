import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/mobile_shell.dart';
import '../../data/datasources/loan_remote_data_source.dart';
import '../../domain/entities/loan_plan.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/simulation_result.dart';
import '../widgets/help_field.dart';
import '../widgets/help_text.dart';
import '../widgets/validators.dart';
import 'results_page.dart';

class NewSimulationPage extends StatefulWidget {
  final LoanRemoteDataSource dataSource;
  const NewSimulationPage({super.key, required this.dataSource});

  @override
  State<NewSimulationPage> createState() => _NewSimulationPageState();
}

class _NewSimulationPageState extends State<NewSimulationPage> {
  LoanRemoteDataSource get _remote => widget.dataSource;

  final _nameCtrl = TextEditingController();
  final _downCtrl = TextEditingController();
  final _incomeCtrl = TextEditingController();
  final _exchangeCtrl = TextEditingController();

  List<Vehicle> _vehicles = [];
  List<LoanPlan> _plans = [];
  Vehicle? _selectedVehicle;
  LoanPlan? _selectedPlan;
  bool _loading = true;
  bool _submitting = false;

  String? _nameErr, _downErr, _exchangeErr;
  double? _previewCuota;
  String? _previewWarning;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await _remote.getVehicles();
      final p = await _remote.getPlans();
      setState(() {
        _vehicles = v;
        _plans = p;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando catálogo: $e')),
        );
      }
    }
  }

  void _recomputePreview() {
    if (_selectedVehicle == null || _selectedPlan == null) {
      setState(() => _previewCuota = null);
      return;
    }
    final down = double.tryParse(_downCtrl.text) ?? 0;
    final principal = _selectedVehicle!.price - down;
    if (principal <= 0) {
      setState(() => _previewCuota = null);
      return;
    }
    final tea = _selectedPlan!.interestRate;
    final tem = math.pow(1 + tea, 1 / 12) - 1;
    final n = _selectedPlan!.termMonths - _selectedPlan!.graceMonths;
    final cuota = tem == 0
        ? principal / n
        : principal * tem / (1 - math.pow(1 + tem, -n));
    final income = double.tryParse(_incomeCtrl.text) ?? 0;
    final warn = income > 0
        ? FieldValidators.installmentVsIncome(cuota.toDouble(), income)
        : null;
    setState(() {
      _previewCuota = cuota.toDouble();
      _previewWarning = warn;
    });
  }

  Future<void> _submit({required bool persist}) async {
    if (_selectedVehicle == null || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona vehículo y plan')),
      );
      return;
    }
    final down = double.tryParse(_downCtrl.text) ?? 0;
    setState(() {
      _nameErr = _nameCtrl.text.isEmpty ? 'Requerido' : null;
      _downErr =
          FieldValidators.downPayment(_downCtrl.text, _selectedVehicle!.price);
      _exchangeErr = _selectedPlan!.currency == 'USD' && _exchangeCtrl.text.isEmpty
          ? 'Requerido para USD'
          : null;
    });
    if (_nameErr != null || _downErr != null || _exchangeErr != null) return;

    setState(() => _submitting = true);
    final payload = {
      'name': _nameCtrl.text,
      'vehicle_id': _selectedVehicle!.id,
      'plan_id': _selectedPlan!.id,
      'down_payment': down,
      'start_date': DateTime.now().toIso8601String().substring(0, 10),
      if (_exchangeCtrl.text.isNotEmpty)
        'exchange_rate': double.tryParse(_exchangeCtrl.text),
    };
    try {
      final SimulationResult result = persist
          ? await _remote.createLoan(payload)
          : await _remote.simulate(payload);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsPage(result: result)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva simulación')),
      body: MobileShell(
        addBottomInset: true,
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _stepHeader(1, 'Datos generales'),
                HelpField(
                  label: 'Nombre de la simulación',
                  controller: _nameCtrl,
                  helpMessage: 'Etiqueta libre, ej "Toyota Yaris 2026".',
                  errorText: _nameErr,
                  onChanged: (_) => setState(() => _nameErr = null),
                ),
                HelpDropdown<Vehicle>(
                  label: 'Vehículo',
                  helpMessage:
                      'Selecciona del catálogo. El precio se usa como base para calcular el monto a financiar.',
                  value: _selectedVehicle,
                  items: _vehicles
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                                '${v.label} — ${v.priceCurrency} ${v.price.toStringAsFixed(2)}'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedVehicle = v);
                    _recomputePreview();
                  },
                ),
                HelpDropdown<LoanPlan>(
                  label: 'Plan de financiamiento',
                  helpMessage:
                      'Cada plan define la TEA, plazo, gracia, seguros y comisiones del crédito.',
                  value: _selectedPlan,
                  items: _plans
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(_planLabel(p)),
                          ))
                      .toList(),
                  onChanged: (p) {
                    setState(() => _selectedPlan = p);
                    _recomputePreview();
                  },
                ),
                if (_selectedPlan != null) _planDetailCard(_selectedPlan!),
                const SizedBox(height: 16),
                _stepHeader(2, 'Capacidad de pago'),
                HelpField(
                  label: 'Ingreso mensual',
                  controller: _incomeCtrl,
                  helpMessage: HelpText.monthlyIncome,
                  helperExample:
                      'Sirve para validar que la cuota ≤ 30% del ingreso',
                  keyboardType: TextInputType.number,
                  suffix: _selectedPlan?.currency ?? 'PEN',
                  onChanged: (_) => _recomputePreview(),
                ),
                HelpField(
                  label: 'Cuota inicial',
                  controller: _downCtrl,
                  helpMessage: HelpText.downPayment,
                  helperExample: 'Mínimo 20% del precio del vehículo',
                  keyboardType: TextInputType.number,
                  suffix: _selectedPlan?.currency ?? 'PEN',
                  errorText: _downErr ??
                      (_selectedVehicle != null
                          ? FieldValidators.downPayment(
                              _downCtrl.text, _selectedVehicle!.price)
                          : null),
                  onChanged: (_) => _recomputePreview(),
                ),
                if (_selectedPlan?.currency == 'USD')
                  HelpField(
                    label: 'Tipo de cambio',
                    controller: _exchangeCtrl,
                    helpMessage: HelpText.exchangeRate,
                    keyboardType: TextInputType.number,
                    errorText: _exchangeErr,
                    onChanged: (_) => setState(() => _exchangeErr = null),
                  ),
                const SizedBox(height: 16),
                _previewCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _submitting ? null : () => _submit(persist: false),
                        icon: const Icon(Icons.calculate),
                        label: const Text('Simular'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _submitting ? null : () => _submit(persist: true),
                        icon: const Icon(Icons.save),
                        label: Text(
                            _submitting ? 'Guardando…' : 'Simular y guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  String _planLabel(LoanPlan p) {
    final teaPct = (p.interestRate * 100).toStringAsFixed(2);
    return '${p.name} | TEA $teaPct% | ${p.termMonths}m | ${p.currency}';
  }

  Widget _planDetailCard(LoanPlan p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_rounded,
                    size: 18, color: AppTheme.brandPrimary),
                SizedBox(width: 6),
                Text('Resumen del plan',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('TEA', '${(p.interestRate * 100).toStringAsFixed(2)}%',
                    HelpText.tea),
                _chip('Plazo', '${p.termMonths} meses', HelpText.term),
                _chip('Gracia', '${p.graceType} (${p.graceMonths}m)',
                    HelpText.graceType),
                _chip('Método', p.paymentMethod, HelpText.paymentMethod),
                if (p.balloonPercentage != null)
                  _chip(
                      'Balloon',
                      '${(p.balloonPercentage! * 100).toStringAsFixed(1)}%',
                      HelpText.balloonPercentage),
                _chip('COK', '${(p.cokAnnual * 100).toStringAsFixed(2)}%',
                    HelpText.cok),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, String help) {
    return Tooltip(
      message: help,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.brandPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.brandPrimary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline_rounded,
                size: 14, color: AppTheme.brandPrimaryDark),
            const SizedBox(width: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: AppTheme.brandPrimaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: '$label '),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(int n, String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.brandPrimary, AppTheme.brandPrimaryDark],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );

  Widget _previewCard() {
    if (_previewCuota == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded,
                color: AppTheme.textSecondary.withOpacity(0.6)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Completa vehículo, plan y cuota inicial para ver una vista previa.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }
    final currency = _selectedPlan?.currency ?? 'PEN';
    final isWarning = _previewWarning != null;
    final accent = isWarning ? AppTheme.brandWarning : AppTheme.brandAccent;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.16), accent.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              const Text(
                'Vista previa',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cuota base',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$currency ${_previewCuota!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estimación sin seguros ni comisiones. El detalle completo aparece tras simular.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          if (isWarning) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, size: 14, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _previewWarning!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
