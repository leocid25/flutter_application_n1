import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pix_cobranca_dto.dart';
import '../models/pix_pagamento_dto.dart';
import '../utils/error_handler.dart';

class PixService {
  final String baseUrl = 'http://localhost:8080/pix';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Método para tratar resposta HTTP
  T _handleResponse<T>(http.Response response, T Function(dynamic data) onSuccess) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (T == Uint8List) {
        return response.bodyBytes as T;
      } else if (response.body.isNotEmpty) {
        final dynamic data = json.decode(response.body);
        return onSuccess(data);
      }
      throw ApiException('Resposta vazia do servidor');
    } else {
      _throwAppropriateException(response);
      // Esta linha nunca será alcançada pois _throwAppropriateException sempre lança uma exceção
      throw ApiException('Erro desconhecido'); // Para satisfazer o tipo de retorno não-nulo
    }
  }

  // Método para lançar exceções específicas
  void _throwAppropriateException(http.Response response) {
    String message = 'Erro na requisição';
    String code = response.statusCode.toString();
    
    try {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('message')) {
        message = data['message'];
      }
    } catch (_) {
      message = response.body;
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException('Requisição inválida: $message', code: code);
      case 401:
        throw AuthException('Não autorizado: $message', code: code);
      case 403:
        throw AuthException('Acesso negado: $message', code: code);
      case 404:
        throw ApiException('Recurso não encontrado: $message', code: code);
      case 409:
        throw ApiException('Conflito: $message', code: code);
      case 422:
        throw ValidationException('Validação falhou: $message', code: code);
      case 500:
      case 502:
      case 503:
      case 504:
        throw ApiException('Erro no servidor: $message', code: code);
      default:
        throw ApiException('Erro inesperado: $message', code: code);
    }
  }

  // Método para tratar erros de rede
  Future<T> _executeWithErrorHandling<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException catch (e) {
      throw NetworkException('Falha na conexão com o servidor: ${e.message}', details: e);
    } on HttpException catch (e) {
      throw NetworkException('Erro HTTP: ${e.message}', details: e);
    } on FormatException catch (e) {
      throw ApiException('Erro no formato da resposta: ${e.message}', details: e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Erro inesperado: ${e.toString()}', details: e);
    }
  }

  // Criar cobrança Pix
  Future<Map<String, dynamic>> criarCobranca(PixCobrancaDTO dto) async {
    return _executeWithErrorHandling(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/cobranca'),
        headers: _headers,
        body: json.encode(dto.toJson()),
      );
      
      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    });
  }

  // Gerar QR Code
  Future<Uint8List> gerarQrCode(String txid) async {
    return _executeWithErrorHandling(() async {
      // É importante NÃO incluir o header Content-Type: application/json aqui, 
      // já que esperamos uma resposta em formato de imagem
      final headers = {'Accept': 'image/png'};
      
      final response = await http.get(
        Uri.parse('$baseUrl/cobranca/$txid/qrcode'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        // Retorna diretamente os bytes, sem tentar fazer decode de JSON
        return response.bodyBytes;
      } else {
        // Para respostas de erro que provavelmente são JSON
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['erro'] ?? 'Erro ao gerar QR Code';
          throw ApiException(errorMessage, code: response.statusCode.toString());
        } catch (e) {
          // Se não for possível decodificar como JSON, use a mensagem genérica
          if (e is ApiException) rethrow;
          throw ApiException(
            'Erro ao gerar QR Code: ${response.statusCode}', 
            code: response.statusCode.toString()
          );
        }
      }
    });
  }
  
  // Listar cobranças
  Future<List<Map<String, dynamic>>> listarCobrancas({int limite = 10}) async {
    return _executeWithErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/cobranca?limite=$limite'),
        headers: _headers,
      );
      
      return _handleResponse(response, (data) {
        final List<dynamic> list = data;
        return list.cast<Map<String, dynamic>>();
      });
    });
  }

  // Consultar cobrança
  Future<Map<String, dynamic>> consultarCobranca(String txid) async {
    if (txid.isEmpty) {
      throw ValidationException('TxID não pode estar vazio');
    }
    
    return _executeWithErrorHandling(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/cobranca/$txid'),
        headers: _headers,
      );
      
      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    });
  }

  // Pagar cobrança
  // Future<Map<String, dynamic>> pagarCobranca(String txid, PixPagamentoDTO dto) async {
  //   if (txid.isEmpty) {
  //     throw ValidationException('TxID não pode estar vazio');
  //   }
    
  //   if (dto.valorPago <= 0) {
  //     throw ValidationException('Valor do pagamento deve ser maior que zero');
  //   }
    
  //   return _executeWithErrorHandling(() async {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/cobranca/{txid}/pagar'),
  //       headers: _headers,
  //       body: json.encode(dto.toJson()),
  //     );
      
  //     return _handleResponse(response, (data) => data as Map<String, dynamic>);
  //   });
  // }

  // Cancelar cobrança
  Future<Map<String, dynamic>> cancelarCobranca(String txid) async {
    if (txid.isEmpty) {
      throw ValidationException('TxID não pode estar vazio');
    }
    
    return _executeWithErrorHandling(() async {
      final response = await http.delete(
        Uri.parse('$baseUrl/cobranca/$txid'),
        headers: _headers,
      );
      
      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    });
  }

  // Registrar pagamento
  Future<Map<String, dynamic>> registrarPagamento(String txid, PixPagamentoDTO dto) async {
    if (txid.isEmpty) {
      throw ValidationException('TxID não pode estar vazio');
    }
    
    if (dto.valorPago <= 0) {
      throw ValidationException('Valor do pagamento deve ser maior que zero');
    }
    
    return _executeWithErrorHandling(() async {
      final response = await http.post(
        Uri.parse('$baseUrl/cobranca/$txid/pagar'),
        headers: _headers,
        body: json.encode(dto.toJson()),
      );
      
      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    });
  }
}