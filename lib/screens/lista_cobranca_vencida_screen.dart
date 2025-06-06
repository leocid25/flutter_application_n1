import 'package:flutter/material.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';
import '../routes/app_routes.dart';

class ListarCobrancaVencidaScreen extends StatefulWidget {
  const ListarCobrancaVencidaScreen({super.key});

  @override
  State<ListarCobrancaVencidaScreen> createState() => _ListarCobrancaVencidaScreenState();
}

class _ListarCobrancaVencidaScreenState extends State<ListarCobrancaVencidaScreen> {
  final _pixService = PixService();
  
  bool _isLoading = false;
  List<Map<String, dynamic>>? _listaCobrancas;
  String? _erro;
  bool _primeiraConsulta = true;

  @override
  void initState() {
    super.initState();
    // Carrega automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listarCobrancasVencidas();
    });
  }

  Future<void> _listarCobrancasVencidas() async {
    setState(() {
      _isLoading = true;
      _listaCobrancas = null;
      _erro = null;
      _primeiraConsulta = false;
    });

    try {
      final resultado = await _pixService.listarCobrancasVencidas();
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobranças Vencidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _listarCobrancasVencidas,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cobranças Vencidas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lista de cobranças que passaram da data de vencimento',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _listarCobrancasVencidas,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
              label: Text(_isLoading ? 'Carregando...' : 'Atualizar Lista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading && _primeiraConsulta)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_erro != null)
              Expanded(child: _buildErro())
            else if (_listaCobrancas != null)
              Expanded(child: _buildLista()),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar cobranças',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _erro!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _listarCobrancasVencidas,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista() {
    if (_listaCobrancas!.isEmpty) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, size: 64, color: Colors.green.shade400),
              const SizedBox(height: 16),
              Text(
                'Parabéns!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Não há cobranças vencidas',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Todas as cobranças estão em dia',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Cobranças Vencidas (${_listaCobrancas!.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
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
                return _buildItemCobranca(cobranca, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCobranca(Map<String, dynamic> cobranca, int index) {
    final txid = cobranca['txid']?.toString() ?? 'N/A';
    final status = cobranca['status']?.toString() ?? 'N/A';
    final valor = cobranca['valor']?.toString() ?? 'N/A';
    final expiracao = cobranca['expiracao']?.toString() ?? 'N/A';
    final criacao = cobranca['criacao']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: index % 2 == 0 ? Colors.red.shade100 : Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade600,
          child: const Icon(
            Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          'TxID: ${txid.length > 20 ? '${txid.substring(0, 20)}...' : txid}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: R\$ $valor'),
            Text(
              'Vencida em: $expiracao',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('TxID Completo', txid),
                _buildDetailItem('Status', status),
                _buildDetailItem('Valor', 'R\$ $valor'),
                _buildDetailItem('Data de Criação', criacao),
                _buildDetailItem('Data de Expiração', expiracao),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.consultarCobranca,
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Consultar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.gerarQRCode,
                            arguments: {'txid': txid},
                          );
                        },
                        icon: const Icon(Icons.qr_code, size: 16),
                        label: const Text('QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}