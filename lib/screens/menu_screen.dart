import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Pix'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    'Gerar Cobrança Pix',
                    Icons.payments_outlined,
                    Colors.blue.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.criarCobranca),
                  ),
                  _buildMenuCard(
                    context,
                    'Pagar Cobrança Pix',
                    Icons.payment,
                    Colors.green.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.pagarCobranca),
                  ),
                  _buildMenuCard(
                    context,
                    'Verificar Cobrança',
                    Icons.search,
                    Colors.orange.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.consultarCobranca),
                  ),
                  _buildMenuCard(
                    context,
                    'Gerar QR Code',
                    Icons.qr_code,
                    Colors.purple.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.gerarQRCode),
                  ),
                  _buildMenuCard(
                    context,
                    'Listar Cobranças Por Período',
                    Icons.list,
                    Colors.blue.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.listarCobrancasPorPeriodo),
                  ),
                  _buildMenuCard(
                    context,
                    'Listar Cobranças Vencidas',
                    Icons.warning,
                    Colors.red.shade700,
                    () => Navigator.pushNamed(context, AppRoutes.listarCobrancasVencidas),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.pix,
            size: 50,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sistema de Gestão Pix',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecione uma opção para continuar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(25), // Substituí withOpacity por withAlpha
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}