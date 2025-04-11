import 'package:flutter/material.dart';
import '../models/pix_cobranca_dto.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';
import '../routes/app_routes.dart';
import 'package:flutter/services.dart';

class PixFormScreen extends StatefulWidget {
  const PixFormScreen({super.key}); // Adicionar o parâmetro key
  
  @override
  State<PixFormScreen> createState() => _PixFormScreenState(); // Usar State<T>
}

class _PixFormScreenState extends State<PixFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pixService = PixService();

  // Controllers dos campos
  final _chaveCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _expiracaoCtrl = TextEditingController(text: "3600");
  final _dataVencCtrl = TextEditingController();
  final _bancoCtrl = TextEditingController(text: "127");
  final _tipoCobCtrl = TextEditingController(text: "cob");
  final _msgCtrl = TextEditingController();

  Uint8List? qrCodeBytes;
  String? resultado;

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        resultado = "Processando...";
        qrCodeBytes = null;
      });
      
      try {
        // Validações adicionais
        if (_chaveCtrl.text.isEmpty) {
          throw ApiException('Chave Pix não pode estar vazia');
        }
        
        if (_valorCtrl.text.isEmpty || double.tryParse(_valorCtrl.text) == null) {
          throw ApiException('Valor inválido');
        }
        
        final dto = PixCobrancaDTO(
          chave: _chaveCtrl.text,
          valor: _valorCtrl.text,
          nome: _nomeCtrl.text,
          cpf: _cpfCtrl.text.isEmpty ? null : _cpfCtrl.text,
          cnpj: _cnpjCtrl.text.isEmpty ? null : _cnpjCtrl.text,
          expiracao: int.tryParse(_expiracaoCtrl.text),
          dataVencimento: _dataVencCtrl.text.isEmpty ? null : _dataVencCtrl.text,
          banco: _bancoCtrl.text,
          tipoCob: _tipoCobCtrl.text,
          solicitacaoPagador: _msgCtrl.text,
        );

        final response = await _pixService.criarCobranca(dto);
        final txid = response['txid'];

        // Verificar se o widget ainda está montado antes de continuar
        if (!mounted) return;
        
        try {
          final qrBytes = await _pixService.gerarQrCode(txid);
          
          if (mounted) {
            setState(() {
              resultado = "Cobrança criada com sucesso! TxID: $txid";
              qrCodeBytes = qrBytes;
            });
          }
        } catch (qrError) {
          // Erro apenas na geração do QR code, mas a cobrança foi criada
          if (mounted) {
            setState(() {
              resultado = "Cobrança criada com sucesso, mas não foi possível gerar o QR Code. TxID: $txid";
            });
            
            // Mostrar opção para tentar gerar o QR code novamente
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Erro ao gerar QR Code'),
                content: const Text('A cobrança foi criada com sucesso, mas ocorreu um erro ao gerar o QR Code. Deseja tentar novamente?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Não'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.gerarQRCode,
                        arguments: {'txid': txid},
                      );
                    },
                    child: const Text('Sim'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          final message = e is AppException ? e.message : e.toString();
          
          setState(() {
            resultado = "Erro: $message";
            qrCodeBytes = null;
          });
          
          // Mostrar mensagem de erro mais amigável
          ErrorHandler.showErrorSnackBar(context, message);
        }
      }
    }
  }

  @override
  void dispose() {
    _chaveCtrl.dispose();
    _valorCtrl.dispose();
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _cnpjCtrl.dispose();
    _expiracaoCtrl.dispose();
    _dataVencCtrl.dispose();
    _bancoCtrl.dispose();
    _tipoCobCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Cobrança Pix')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Chave Pix", _chaveCtrl),
                _buildTextField("Valor", _valorCtrl),
                _buildTextField("Nome", _nomeCtrl),
                _buildTextField("CPF", _cpfCtrl, required: false),
                _buildTextField("CNPJ", _cnpjCtrl, required: false),
                _buildTextField("Expiração (segundos)", _expiracaoCtrl, required: false),
                _buildTextField("Data Vencimento (YYYY-MM-DD)", _dataVencCtrl, required: false),
                _buildTextField("Banco", _bancoCtrl),
                _buildTextField("Tipo (cob ou cobv)", _tipoCobCtrl),
                _buildTextField("Solicitação ao Pagador", _msgCtrl, required: false),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _enviarFormulario,
                  child: const Text("Criar cobrança e gerar QR Code"),
                ),
                if (resultado != null) ...[
                  const SizedBox(height: 16),
                  Text(resultado!),
                ],
                if (qrCodeBytes != null) ...[
                  const SizedBox(height: 16),
                  // Extrair o TxID do resultado
                  _buildTxIdDisplay(),
                  const SizedBox(height: 8),
                  Image.memory(qrCodeBytes!),
                ]
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // Método para extrair e exibir o TxID em um formato destacado
  Widget _buildTxIdDisplay() {
    // Tenta extrair o TxID da mensagem de resultado
    String? txid;
    if (resultado != null && resultado!.contains("TxID:")) {
      txid = resultado!.split("TxID:").last.trim();
    }
    
    if (txid == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "TxID da Cobrança",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              txid,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copiar TxID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: txid ?? ""));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('TxID copiado para a área de transferência'))
                    );
                  },
                ),
                const Text("Copiar", style: TextStyle(fontSize: 12))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }
}