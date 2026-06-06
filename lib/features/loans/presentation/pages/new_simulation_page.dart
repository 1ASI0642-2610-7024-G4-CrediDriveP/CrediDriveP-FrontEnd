import 'dart:math' as math;

import 'package:flutter/material.dart';

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
      body: _loading
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
                      'Sirve pa validar que la cuota ≤ 30% del ingreso',
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
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
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
      ),
    );
  }

  Widget _chip(String label, String value, String help) {
    return Tooltip(
      message: help,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 6),
      child: Chip(
        label: Text('$label: $value'),
        backgroundColor: Colors.blue.shade50,
        avatar: const Icon(Icons.help_outline, size: 16),
      ),
    );
  }

  Widget _stepHeader(int n, String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(radius: 14, child: Text('$n')),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );

  Widget _previewCard() {
    if (_previewCuota == null) {
      return Card(
        color: Colors.grey.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
              'Completa vehículo, plan y cuota inicial pa ver una vista previa.'),
        ),
      );
    }
    final currency = _selectedPlan?.currency ?? 'PEN';
    return Card(
      color:
          _previewWarning == null ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vista previa',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Cuota base estimada: $currency ${_previewCuota!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estimación sin seguros ni comisiones. El detalle aparecerá tras simular.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            if (_previewWarning != null) ...[
              const SizedBox(height: 8),
              Text(_previewWarning!,
                  style: const TextStyle(color: Colors.deepOrange)),
            ],
          ],
        ),
      ),
    );
  }
}
