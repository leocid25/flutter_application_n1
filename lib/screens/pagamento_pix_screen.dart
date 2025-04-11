import 'package:flutter/material.dart';
import '../models/pix_pagamento_response_dto.dart';

class PagamentoPixScreen extends StatelessWidget {
  final PixPagamentoResponseDTO resposta;

  const PagamentoPixScreen({super.key, required this.resposta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagamento Pix Registrado")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detalhes do Pagamento",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _info("TxID", resposta.txid),
                _info("Status", resposta.status),
                _info("Valor Pago", "R\$ ${resposta.valorPago.toStringAsFixed(2)}"),
                _info("EndToEnd ID", resposta.endToEndId),
                _info("Horário", resposta.horarioPagamento.toString()),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("OK"),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          text: "$titulo: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [TextSpan(text: valor, style: const TextStyle(fontWeight: FontWeight.normal))],
        ),
      ),
    );
  }
}
