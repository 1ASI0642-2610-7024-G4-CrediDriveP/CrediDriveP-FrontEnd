import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/mobile_shell.dart';
import '../../domain/entities/simulation_result.dart';
import '../widgets/help_text.dart';

class ResultsPage extends StatelessWidget {
  final SimulationResult result;
  const ResultsPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(result.name)),
      body: MobileShell(
        addBottomInset: true,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _heroCuota(),
          const SizedBox(height: 16),
          _summaryCard(),
          const SizedBox(height: 16),
          _indicatorsCard(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Cronograma de pagos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Método francés vencido ordinario',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _scheduleTable(),
        ],
      ),
      ),
    );
  }

  Widget _heroCuota() {
    final cur = result.currency;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.brandPrimary, AppTheme.brandPrimaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandPrimary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'Cuota mensual base',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: '$cur ',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: result.monthlyPaymentBase.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monto financiado: $cur ${result.amountFinanced.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Resumen del crédito', Icons.receipt_long_rounded),
            const SizedBox(height: 10),
            _row('Moneda', result.currency),
            _row('Estado', result.status,
                valueColor: AppTheme.brandAccent, bold: true),
            if (result.loanId != null) _row('ID', '#${result.loanId}'),
          ],
        ),
      ),
    );
  }

  Widget _indicatorsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded,
                    color: AppTheme.brandPrimary, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Indicadores financieros',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message:
                      'VAN y TIR se calculan desde tu perspectiva como deudor (cliente): '
                      'recibes el préstamo en t=0 y devuelves los pagos en cada periodo. '
                      'NO es la perspectiva del inversionista.',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 8),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Perspectiva del deudor',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _indicatorTile(
                  'TCEA',
                  '${(result.indicators.tcea * 100).toStringAsFixed(2)}%',
                  HelpText.tcea,
                  AppTheme.brandPrimary,
                ),
                _indicatorTile(
                  'TIR anual',
                  '${(result.indicators.tirAnnual * 100).toStringAsFixed(2)}%',
                  'TIR anualizada de los flujos del deudor.',
                  AppTheme.brandAccent,
                ),
                _indicatorTile(
                  'VAN',
                  '${result.currency} ${result.indicators.van.toStringAsFixed(0)}',
                  'Valor Actual Neto descontado al COK.',
                  AppTheme.brandWarning,
                ),
                _indicatorTile(
                  'COK',
                  '${(result.indicators.cokUsed * 100).toStringAsFixed(2)}%',
                  HelpText.cok,
                  AppTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicatorTile(String label, String value, String help, Color color) {
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.help_outline_rounded, size: 11, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(
            v,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleTable() {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 18,
            horizontalMargin: 14,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Vence')),
              DataColumn(label: Text('Gracia')),
              DataColumn(label: Text('Saldo ini')),
              DataColumn(label: Text('Interés')),
              DataColumn(label: Text('Amort.')),
              DataColumn(label: Text('Seg. desg.')),
              DataColumn(label: Text('Seg. veh.')),
              DataColumn(label: Text('Comisión')),
              DataColumn(label: Text('Balloon')),
              DataColumn(label: Text('Cuota')),
              DataColumn(label: Text('Saldo fin')),
            ],
            rows: result.schedule
                .map((r) => DataRow(cells: [
                      DataCell(Text('${r.periodNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(r.dueDate)),
                      DataCell(_GracePill(grace: r.graceApplied)),
                      DataCell(Text(r.openingBalance.toStringAsFixed(2))),
                      DataCell(Text(r.interest.toStringAsFixed(2))),
                      DataCell(Text(r.principal.toStringAsFixed(2))),
                      DataCell(Text(r.insuranceDesgravamen.toStringAsFixed(2))),
                      DataCell(Text(r.insuranceVehicular.toStringAsFixed(2))),
                      DataCell(Text(r.commission.toStringAsFixed(2))),
                      DataCell(Text(r.balloon.toStringAsFixed(2),
                          style: r.balloon > 0
                              ? const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.brandWarning)
                              : null)),
                      DataCell(Text(
                        r.totalPayment.toStringAsFixed(2),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandPrimary),
                      )),
                      DataCell(Text(r.closingBalance.toStringAsFixed(2))),
                    ]))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.brandPrimary, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _GracePill extends StatelessWidget {
  final String grace;
  const _GracePill({required this.grace});

  @override
  Widget build(BuildContext context) {
    if (grace == 'NONE') {
      return const Text('—', style: TextStyle(color: AppTheme.textSecondary));
    }
    final color = grace == 'TOTAL' ? AppTheme.brandDanger : AppTheme.brandWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grace,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
