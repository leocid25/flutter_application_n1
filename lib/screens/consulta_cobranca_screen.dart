import 'package:flutter/material.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';
import '../routes/app_routes.dart';

class ConsultaCobrancaScreen extends StatefulWidget {
  const ConsultaCobrancaScreen({super.key});

  @override
  State<ConsultaCobrancaScreen> createState() => _ConsultaCobrancaScreenState();
}

class _ConsultaCobrancaScreenState extends State<ConsultaCobrancaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txidController = TextEditingController();
  final _pixService = PixService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _resultadoConsulta;
  String? _erro;

  Future<void> _consultarCobranca() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _resultadoConsulta = null;
      _erro = null;
    });

    try {
      // Validação adicional do TxID
      final txid = _txidController.text.trim();
      if (txid.isEmpty) {
        throw ApiException('TxID não pode estar vazio');
      }
      
      final resultado = await _pixService.consultarCobranca(txid);
      
      if (mounted) {
        setState(() {
          _resultadoConsulta = resultado;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Usando nosso tratamento de erros mais robusto
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
  void dispose() {
    _txidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar Cobrança Pix'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _txidController,
                decoration: const InputDecoration(
                  labelText: 'TxID da Cobrança',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o TxID';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _consultarCobranca,
              icon: const Icon(Icons.search),
              label: const Text('Consultar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_erro != null)
              _buildErro()
            else if (_resultadoConsulta != null)
              _buildResultado(),
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

  Widget _buildResultado() {
    return Expanded(
      child: Card(
        elevation: 2,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalhes da Cobrança',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              _buildInfoItem('TxID', _resultadoConsulta!['txid'].toString()),
              _buildInfoItem('Status', _resultadoConsulta!['status'].toString()),
              if (_resultadoConsulta!.containsKey('valor'))
                _buildInfoItem('Valor', 'R\$ ${_resultadoConsulta!['valor']}'),
              if (_resultadoConsulta!.containsKey('criacao'))
                _buildInfoItem('Criação', _resultadoConsulta!['criacao'].toString()),
              if (_resultadoConsulta!.containsKey('expiracao'))
                _buildInfoItem('Expiração', _resultadoConsulta!['expiracao'].toString()),
              
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar para geração de QR Code com o TxID atual
                  final txid = _resultadoConsulta!['txid'].toString();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.gerarQRCode,
                    arguments: {'txid': txid},
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text('Gerar QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}