// import 'package:flutter/material.dart';
// import '../services/pix_service.dart';
// import '../models/pix_cobranca_dto.dart';
// import '../models/pix_pagamento_dto.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key}); // Adicionado o parâmetro key

//   @override
//   State<HomeScreen> createState() => _HomeScreenState(); // Corrigido para usar State<T>
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final PixService _pixService = PixService();
//   String resultado = '';

//   void _criarCobranca() async {
//     try {
//       final dto = PixCobrancaDTO(
//         chave: "email@teste.com",
//         valor: "150.00",
//         nome: "Cliente Teste",
//         banco: "127",
//         tipoCob: "cob",
//       );

//       final resposta = await _pixService.criarCobranca(dto);
//       setState(() => resultado = resposta.toString());
//     } catch (e) {
//       setState(() => resultado = e.toString());
//     }
//   }

//   void _listarCobrancas() async {
//     try {
//       final resposta = await _pixService.listarCobrancas(limite: 5);
//       setState(() => resultado = resposta.toString());
//     } catch (e) {
//       setState(() => resultado = e.toString());
//     }
//   }

//   void _pagarCobranca() async {
//     try {
//       final pagamento = PixPagamentoDTO(valorPago: 150.0);
//       final resposta = await _pixService.pagarCobranca("txid123", pagamento);
//       setState(() => resultado = resposta.toString());
//     } catch (e) {
//       setState(() => resultado = e.toString());
//     }
//   }

//   void _consultarCobranca() async {
//     try {
//       final resposta = await _pixService.consultarCobranca("txid123");
//       setState(() => resultado = resposta.toString());
//     } catch (e) {
//       setState(() => resultado = e.toString());
//     }
//   }

//   void _cancelarCobranca() async {
//     try {
//       final resposta = await _pixService.cancelarCobranca("txid123");
//       setState(() => resultado = resposta.toString());
//     } catch (e) {
//       setState(() => resultado = e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pix Client Flutter')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ElevatedButton(onPressed: _criarCobranca, child: const Text("Criar Cobrança")),
//             ElevatedButton(onPressed: _consultarCobranca, child: const Text("Consultar Cobrança")),
//             ElevatedButton(onPressed: _pagarCobranca, child: const Text("Pagar Cobrança")),
//             ElevatedButton(onPressed: _cancelarCobranca, child: const Text("Cancelar Cobrança")),
//             ElevatedButton(onPressed: _listarCobrancas, child: const Text("Listar Cobranças")),
//             const SizedBox(height: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(resultado, style: const TextStyle(fontSize: 14)),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }