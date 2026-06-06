import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/brand_header.dart';
import '../../data/datasources/loan_remote_data_source.dart';
import 'new_simulation_page.dart';

class SavedSimulationsPage extends StatefulWidget {
  final LoanRemoteDataSource dataSource;
  const SavedSimulationsPage({super.key, required this.dataSource});

  @override
  State<SavedSimulationsPage> createState() => _SavedSimulationsPageState();
}

class _SavedSimulationsPageState extends State<SavedSimulationsPage> {
  LoanRemoteDataSource get _remote => widget.dataSource;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final list = await _remote.listLoans();
      setState(() => _items = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNew() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewSimulationPage(dataSource: widget.dataSource),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNew,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva simulación'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: BrandHeader(
                title: 'Mis simulaciones',
                subtitle: _loading
                    ? 'Cargando…'
                    : '${_items.length} simulación${_items.length == 1 ? "" : "es"} guardada${_items.length == 1 ? "" : "s"}',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: _refresh,
                  ),
                ],
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 48,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aún no tienes simulaciones',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Crea tu primera simulación de crédito vehicular y compara escenarios.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _openNew,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nueva simulación'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                sliver: SliverList.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final it = _items[i];
                    return _SimulationTile(item: it);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SimulationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _SimulationTile({required this.item});

  Color _statusColor(String s) {
    switch (s) {
      case 'APPROVED':
      case 'ACTIVE':
        return AppTheme.brandAccent;
      case 'PAID':
        return Colors.grey;
      case 'REJECTED':
      case 'CANCELLED':
        return AppTheme.brandDanger;
      default:
        return AppTheme.brandPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cur = item['currency']?.toString() ?? 'PEN';
    final amount = item['amount_financed'];
    final status = item['status']?.toString() ?? 'DRAFT';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: AppTheme.brandPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['name']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Financiado: $cur ${amount is num ? amount.toStringAsFixed(2) : amount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(status),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#${item['id']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
