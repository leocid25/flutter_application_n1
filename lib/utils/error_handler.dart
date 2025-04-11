import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Classe para tratamento centralizado de erros
class ErrorHandler {
  /// Inicializa o tratamento de erros não capturados
  static void initializeErrorHandling() {
    // Capturar erros de Flutter não gerenciados
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };

    // Capturar erros assíncronos não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }

  /// Reporta um erro para serviços de monitoramento (implementação futura)
  static void _reportError(dynamic error, StackTrace? stack) {
    // Aqui você pode implementar a integração com serviços como Sentry, Crashlytics, etc.
    if (kDebugMode) {
      print('ERRO CAPTURADO:');
      print('Erro: $error');
      print('Stack trace: $stack');
    }
  }

  /// Exibe um diálogo de erro
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Ocorreu um erro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Exibe um SnackBar de erro
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

/// Tipos de erros específicos da aplicação para melhor tratamento
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// Erro de conexão com a rede
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

/// Erro de autenticação (ex: token expirado)
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

/// Erro nos dados da API
class ApiException extends AppException {
  ApiException(super.message, {super.code, super.details});
}

/// Erro de validação
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, super.details});
}

/// Extensão para tratar exceções específicas da API PIX
extension PixErrorHandler on Exception {
  /// Converte exceções genéricas em exceções específicas da aplicação
  AppException toAppException() {
    if (this is AppException) return this as AppException;

    // Analisar a mensagem de erro para determinar o tipo
    final errorMessage = toString();

    if (errorMessage.contains('Connection') ||
        errorMessage.contains('Network') ||
        errorMessage.contains('SocketException')) {
      return NetworkException(
        'Erro de conexão. Verifique sua internet e tente novamente.',
        details: this,
      );
    }

    if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
      return AuthException(
        'Erro de autenticação. Por favor, faça login novamente.',
        details: this,
      );
    }

    if (errorMessage.contains('404') || errorMessage.contains('Not Found')) {
      return ApiException(
        'Recurso não encontrado. Verifique os dados e tente novamente.',
        details: this,
      );
    }

    if (errorMessage.contains('txid')) {
      return ValidationException(
        'TxID inválido ou não encontrado.',
        details: this,
      );
    }

    // Exceção genérica
    return AppException(
      'Ocorreu um erro inesperado. Tente novamente mais tarde.',
      details: this,
    );
  }
}