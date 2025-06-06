import 'package:flutter/material.dart';
import '../screens/menu_screen.dart';
import '../screens/pix_form_screen.dart';
import '../screens/pagamento_form_screen.dart';
import '../screens/consulta_cobranca_screen.dart';
import '../screens/qrcode_generator_screen.dart';
import '../screens/pagamento_pix_screen.dart';
import '../screens/lista_cobranca_periodo_screen.dart';
import '../screens/lista_cobranca_vencida_screen.dart';
import '../models/pix_pagamento_response_dto.dart';

class AppRoutes {
  // Definição de rotas
  static const String menu = '/';
  static const String criarCobranca = '/criar-cobranca';
  static const String pagarCobranca = '/pagar-cobranca';
  static const String consultarCobranca = '/consultar-cobranca';
  static const String gerarQRCode = '/gerar-qrcode';
  static const String listarCobrancasPorPeriodo = '/listar-cobrancas-periodo';
  static const String listarCobrancasVencidas = '/listar-cobrancas-vencidas';
  static const String pagamentoConfirmado = '/pagamento-confirmado';

  // Mapa de rotas
  static Map<String, WidgetBuilder> get routes {
    return {
      menu: (context) => const MenuScreen(),
      criarCobranca: (context) => const PixFormScreen(),
      pagarCobranca: (context) => const PagamentoFormScreen(),
      consultarCobranca: (context) => const ConsultaCobrancaScreen(),
      gerarQRCode: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        String? txidInicial;
        if (arguments != null && arguments is Map<String, dynamic>) {
          txidInicial = arguments['txid'] as String?;
        }
        return QRCodeGeneratorScreen(txidInicial: txidInicial);
      },
      listarCobrancasPorPeriodo: (context) => const ListarCobrancaPeriodoScreen(),
      listarCobrancasVencidas: (context) => const ListarCobrancaVencidaScreen(),
      pagamentoConfirmado: (context) {
        final resposta = ModalRoute.of(context)!.settings.arguments;
        if (resposta == null) {
          // Tratar o caso em que não há resposta
          return const MenuScreen();
        }
        return PagamentoPixScreen(resposta: resposta as PixPagamentoResponseDTO);
      },
    };
  }

  // Tratamento de rotas desconhecidas
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (ctx) => Scaffold(
        appBar: AppBar(title: const Text('Página não encontrada')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro de navegação',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('A rota "${settings.name}" não foi encontrada.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pushReplacementNamed(menu),
                child: const Text('Voltar para o menu principal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}