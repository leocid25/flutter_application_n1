class PixPagamentoResponseDTO {
  final String txid;
  final String status;
  final double valorPago;
  final String endToEndId;
  final DateTime horarioPagamento;

  PixPagamentoResponseDTO({
    required this.txid,
    required this.status,
    required this.valorPago,
    required this.endToEndId,
    required this.horarioPagamento,
  });

  factory PixPagamentoResponseDTO.fromJson(Map<String, dynamic> json) {
    return PixPagamentoResponseDTO(
      txid: json['txid'],
      status: json['status'],
      valorPago: double.parse(json['valorPago'].toString()),
      endToEndId: json['endToEndId'],
      horarioPagamento: DateTime.parse(json['horarioPagamento']),
    );
  }

  @override
  String toString() {
    return '''
Pagamento Pix:
- TxID: $txid
- Status: $status
- Valor Pago: R\$${valorPago.toStringAsFixed(2)}
- EndToEndId: $endToEndId
- Horário do Pagamento: $horarioPagamento
''';
  }
}
