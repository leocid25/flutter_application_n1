import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'utils/error_handler.dart';

void main() {
  // Capturar erros não tratados
  ErrorHandler.initializeErrorHandling();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pix Client Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      
      // ← CONFIGURAÇÕES DE LOCALIZAÇÃO ADICIONADAS:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),  // Português do Brasil
        Locale('en', 'US'),  // Inglês (fallback)
      ],
      locale: const Locale('pt', 'BR'),  // Define português como padrão
      
      // Configuração de rotas nomeadas
      initialRoute: AppRoutes.menu,
      routes: AppRoutes.routes,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}