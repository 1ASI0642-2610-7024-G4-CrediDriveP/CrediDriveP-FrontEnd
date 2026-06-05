import 'package:flutter/material.dart';

import '../../domain/entities/simulation_result.dart';
import '../widgets/help_text.dart';

class ResultsPage extends StatelessWidget {
  final SimulationResult result;
  const ResultsPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cur = result.currency;
    return Scaffold(
      appBar: AppBar(title: Text('Resultados — ${result.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(cur),
          const SizedBox(height: 16),
          _indicatorsCard(),
          const SizedBox(height: 16),
          const Text('Cronograma de pagos (método francés vencido ordinario)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _scheduleTable(cur),
        ],
      ),
    );
  }

  Widget _summaryCard(String cur) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _row('Monto financiado',
                '$cur ${result.amountFinanced.toStringAsFixed(2)}'),
            _row('Cuota mensual base',
                '$cur ${result.monthlyPaymentBase.toStringAsFixed(2)}'),
            _row('Estado', result.status),
            if (result.loanId != null) _row('ID crédito', '${result.loanId}'),
          ],
        ),
      ),
    );
  }

  Widget _indicatorsCard() {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('Indicadores financieros (perspectiva deudor)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Tooltip(
                  message:
                      'VAN y TIR se calculan desde tu perspectiva (cliente): '
                      'recibes el préstamo en t=0 y devuelves los pagos en cada periodo. '
                      'No es la perspectiva del inversionista.',
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: Duration(seconds: 8),
                  child: Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _row('VAN',
                result.currency + ' ' + result.indicators.van.toStringAsFixed(2),
                tooltip: 'Suma de flujos descontados al COK'),
            _row('TIR mensual',
                '${(result.indicators.tirMonthly * 100).toStringAsFixed(4)}%'),
            _row('TIR anual',
                '${(result.indicators.tirAnnual * 100).toStringAsFixed(4)}%'),
            _row('TCEA',
                '${(result.indicators.tcea * 100).toStringAsFixed(4)}%',
                tooltip: HelpText.tcea),
            _row('COK usado',
                '${(result.indicators.cokUsed * 100).toStringAsFixed(4)}%',
                tooltip: HelpText.cok),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {String? tooltip}) {
    final label = Text(k, style: const TextStyle(color: Colors.black54));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tooltip == null
              ? label
              : Tooltip(
                  message: tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Row(children: [
                    label,
                    const SizedBox(width: 4),
                    const Icon(Icons.help_outline, size: 14),
                  ]),
                ),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _scheduleTable(String cur) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
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
                  DataCell(Text('${r.periodNumber}')),
                  DataCell(Text(r.dueDate)),
                  DataCell(Text(r.graceApplied)),
                  DataCell(Text(r.openingBalance.toStringAsFixed(2))),
                  DataCell(Text(r.interest.toStringAsFixed(2))),
                  DataCell(Text(r.principal.toStringAsFixed(2))),
                  DataCell(Text(r.insuranceDesgravamen.toStringAsFixed(2))),
                  DataCell(Text(r.insuranceVehicular.toStringAsFixed(2))),
                  DataCell(Text(r.commission.toStringAsFixed(2))),
                  DataCell(Text(r.balloon.toStringAsFixed(2))),
                  DataCell(Text(r.totalPayment.toStringAsFixed(2))),
                  DataCell(Text(r.closingBalance.toStringAsFixed(2))),
                ]))
            .toList(),
      ),
    );
  }
}
