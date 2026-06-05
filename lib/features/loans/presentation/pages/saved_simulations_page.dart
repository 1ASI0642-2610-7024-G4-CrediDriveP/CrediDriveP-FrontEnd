import 'package:flutter/material.dart';
import 'package:credidrivep_frontend_flutter/core/api/api_client.dart';

import '../../data/datasources/loan_remote_data_source_impl.dart';
import 'new_simulation_page.dart';

class SavedSimulationsPage extends StatefulWidget {
  final ApiClient apiClient;
  const SavedSimulationsPage({super.key, required this.apiClient});

  @override
  State<SavedSimulationsPage> createState() => _SavedSimulationsPageState();
}

class _SavedSimulationsPageState extends State<SavedSimulationsPage> {
  late final LoanRemoteDataSourceImpl _remote =
      LoanRemoteDataSourceImpl(client: widget.apiClient);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulaciones guardadas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewSimulationPage(apiClient: widget.apiClient),
            ),
          );
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva simulación'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                            child: Text(
                                'Aún no tienes simulaciones. Toca + para crear una.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final it = _items[i];
                        return ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text('${it['name']}'),
                          subtitle: Text(
                              '${it['currency']} ${it['amount_financed']} · ${it['status']}'),
                          trailing: Text('#${it['id']}'),
                        );
                      },
                    ),
            ),
    );
  }
}
