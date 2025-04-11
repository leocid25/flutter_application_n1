import 'package:flutter/material.dart';
import '../models/pix_pagamento_dto.dart';
import '../models/pix_pagamento_response_dto.dart';
import '../services/pix_service.dart';
import '../utils/error_handler.dart';
import '../routes/app_routes.dart';

class PagamentoFormScreen extends StatefulWidget {
  const PagamentoFormScreen({super.key});

  @override
  State<PagamentoFormScreen> createState() => _PagamentoFormScreenState();
}

class _PagamentoFormScreenState extends State<PagamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _txidCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _infoCtrl = TextEditingController();

  bool _carregando = false;

  void _registrarPagamento() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        // Validação dos dados
        final txid = _txidCtrl.text;
        if (txid.isEmpty) {
          throw ApiException('TxID não pode estar vazio');
        }
        
        double valor;
        try {
          valor = double.parse(_valorCtrl.text);
          if (valor <= 0) {
            throw ApiException('O valor deve ser maior que zero');
          }
        } catch (e) {
          throw ApiException('Valor inválido');
        }
        
        final dto = PixPagamentoDTO(
          valorPago: valor,
          infoPagador: _infoCtrl.text.isEmpty ? null : _infoCtrl.text,
        );

        final service = PixService();
        final response = await service.registrarPagamento(txid, dto);
        final pagamento = PixPagamentoResponseDTO.fromJson(response);

        // Adicionando verificação mounted antes de acessar context
        if (mounted) {
          Navigator.pushReplacementNamed(
            context, 
            AppRoutes.pagamentoConfirmado,
            arguments: pagamento,
          );
        }
      } catch (e) {
        // Adicionando verificação mounted antes de acessar context
        if (mounted) {
          // Usando o tratamento de erro mais robusto
          final message = e is AppException ? e.message : e.toString();
          ErrorHandler.showErrorSnackBar(context, message);
        }
      } finally {
        // Adicionando verificação mounted antes de setState
        if (mounted) {
          setState(() => _carregando = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _txidCtrl.dispose();
    _valorCtrl.dispose();
    _infoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagamento Pix")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo("TxID", _txidCtrl),
              _campo("Valor Pago", _valorCtrl, teclado: TextInputType.number),
              _campo("Informação do Pagador", _infoCtrl, obrigatorio: false),
              const SizedBox(height: 16),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registrarPagamento,
                      child: const Text("Registrar Pagamento"),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {bool obrigatorio = true, TextInputType teclado = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: obrigatorio
            ? (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }
}