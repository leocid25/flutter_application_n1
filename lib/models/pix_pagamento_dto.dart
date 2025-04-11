class PixPagamentoDTO {
  String? endToEndId;
  double valorPago;
  String? infoPagador;

  PixPagamentoDTO({
    this.endToEndId,
    required this.valorPago,
    this.infoPagador,
  });

  Map<String, dynamic> toJson() => {
        'endToEndId': endToEndId,
        'valorPago': valorPago,
        'infoPagador': infoPagador,
      };
}
