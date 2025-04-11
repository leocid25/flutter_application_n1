import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  const QRCodeGeneratorScreen({super.key, this.txidInicial});

  final String? txidInicial;

  @override
  State<QRCodeGeneratorScreen> createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txidController = TextEditingController();
  final _pixService = PixService();
  
  bool _isLoading = false;
  Uint8List? _qrCodeBytes;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget.txidInicial != null) {
      _txidController.text = widget.txidInicial!;
      // Gerar QR Code automaticamente se o txid foi fornecido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Bypass da validação no primeiro carregamento
        _gerarQRCodeSemValidar();
      });
    }
  }

  Future<void> _gerarQRCodeSemValidar() async {
  try {
    setState(() {
      _isLoading = true;
      _qrCodeBytes = null;
      _erro = null;
    });

    final qrBytes = await _pixService.gerarQrCode(_txidController.text.trim());

    if (mounted) {
      setState(() {
        _qrCodeBytes = qrBytes;
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

  Future<void> _gerarQRCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _qrCodeBytes = null;
      _erro = null;
    });

    try {
      // Validação adicional do TxID
      final txid = _txidController.text.trim();
      if (txid.isEmpty) {
        throw ApiException('TxID não pode estar vazio');
      }
      
      final qrBytes = await _pixService.gerarQrCode(txid);
      
      if (mounted) {
        setState(() {
          _qrCodeBytes = qrBytes;
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

  Future<void> _copiarQRCodeComoTexto() async {
    // Implementação futura - exigiria decodificar o QR code como texto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade ainda não implementada')),
    );
  }

  Future<void> _compartilharQRCode() async {
    // Implementação futura - exigiria compartilhar a imagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade ainda não implementada')),
    );
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
        title: const Text('Gerar QR Code Pix'),
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
                  prefixIcon: Icon(Icons.qr_code),
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
              onPressed: _isLoading ? null : _gerarQRCode,
              icon: const Icon(Icons.qr_code),
              label: const Text('Gerar QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_erro != null)
              _buildErro()
            else if (_qrCodeBytes != null)
              _buildQRCode(),
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
              'Erro ao gerar QR Code',
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

  Widget _buildQRCode() {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.memory(
                _qrCodeBytes!,
                width: 250,
                height: 250,
              ),
            ),
            const Text(
              'QR Code Pix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copiar como texto',
                  onPressed: _copiarQRCodeComoTexto,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Compartilhar',
                  onPressed: _compartilharQRCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}