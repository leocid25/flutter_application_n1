import 'package:flutter/material.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';
import '../routes/app_routes.dart';

class ListarCobrancaPeriodoScreen extends StatefulWidget {
  const ListarCobrancaPeriodoScreen({super.key});

  @override
  State<ListarCobrancaPeriodoScreen> createState() => _ListarCobrancaPeriodoScreenState();
}

class _ListarCobrancaPeriodoScreenState extends State<ListarCobrancaPeriodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _pixService = PixService();
  
  bool _isLoading = false;
  List<Map<String, dynamic>>? _listaCobrancas;
  String? _erro;
  DateTime? _dataInicio;
  DateTime? _dataFim;

  Future<void> _listarCobrancas() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_dataInicio == null || _dataFim == null) {
      setState(() {
        _erro = 'Por favor, selecione ambas as datas';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _listaCobrancas = null;
      _erro = null;
    });

    try {
      final resultado = await _pixService.listarCobrancasPorPeriodo(_dataInicio!, _dataFim!);
      
      if (mounted) {
        setState(() {
          _listaCobrancas = resultado;
          _isLoading = false;
        });
      }
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      
      if (mounted) {
        setState(() {
          _erro = message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selecionarData(bool isDataInicio) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100, 12, 31), // Permite datas futuras até 2030
      helpText: isDataInicio ? 'Selecione a data inicial' : 'Selecione a data final',
    );

    if (pickedDate != null) {
      setState(() {
        if (isDataInicio) {
          _dataInicio = pickedDate;
          // Formato: aaaa/mm/dd
          _dataInicioController.text = '${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}';
        } else {
          _dataFim = pickedDate;
          // Formato: aaaa/mm/dd
          _dataFimController.text = '${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}';
        }
      });
    }
  }

  @override
  void dispose() {
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobranças por Período'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _dataInicioController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data Inicial',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: () => _selecionarData(true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione a data inicial';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataFimController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data Final',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: () => _selecionarData(false),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione a data final';
                      }
                      if (_dataInicio != null && _dataFim != null && _dataInicio!.isAfter(_dataFim!)) {
                        return 'Data inicial deve ser anterior à data final';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _listarCobrancas,
              icon: const Icon(Icons.search),
              label: const Text('Consultar Período'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_erro != null)
              _buildErro()
            else if (_listaCobrancas != null)
              _buildLista(),
          ],
        ),
      ),
    );
  }

  Widget _buildErro() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Erro na consulta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_erro!),
          ],
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (_listaCobrancas!.isEmpty) {
      return Expanded(
        child: Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma cobrança encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Não há cobranças no período selecionado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.list, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Cobranças Encontradas (${_listaCobrancas!.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _listaCobrancas!.length,
                itemBuilder: (context, index) {
                  final cobranca = _listaCobrancas![index];
                  return _buildItemCobranca(cobranca);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCobranca(Map<String, dynamic> cobranca) {
    final txid = cobranca['txid']?.toString() ?? 'N/A';
    final status = cobranca['status']?.toString() ?? 'N/A';
    final valor = cobranca['valor']?.toString() ?? 'N/A';
    final criacao = cobranca['criacao']?.toString() ?? 'N/A';
    final dataVencimento = cobranca['dataVencimento']?.toString() ?? 'N/A';
    final validadeAposVencimento = cobranca['validadeAposVencimento']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
          ),
        ),
        title: Text(
          'TxID: ${txid.length > 20 ? '${txid.substring(0, 20)}...' : txid}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            Text('Valor: R\$ $valor'),
            Text('Criação: $criacao'),
            Text(dataVencimento.isNotEmpty ? 'Vencimento: $dataVencimento' : 'Vencimento: N/A'),
            Text(validadeAposVencimento.isNotEmpty ? 'Validade após vencimento: $validadeAposVencimento' : 'Validade após vencimento: N/A'),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.consultarCobranca,
            );
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.gerarQRCode,
            arguments: {'txid': txid},
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pago':
      case 'concluida':
        return Colors.green;
      case 'pendente':
      case 'ativa':
        return Colors.orange;
      case 'cancelada':
      case 'expirada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pago':
      case 'concluida':
        return Icons.check_circle;
      case 'pendente':
      case 'ativa':
        return Icons.access_time;
      case 'cancelada':
      case 'expirada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}