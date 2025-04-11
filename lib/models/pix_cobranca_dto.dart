class PixCobrancaDTO {
  String chave;
  String valor;
  String nome;
  String? cpf;
  String? cnpj;
  int? expiracao;
  String? dataVencimento;
  String banco;
  String tipoCob;
  String? solicitacaoPagador;

  PixCobrancaDTO({
    required this.chave,
    required this.valor,
    required this.nome,
    this.cpf,
    this.cnpj,
    this.expiracao,
    this.dataVencimento,
    required this.banco,
    required this.tipoCob,
    this.solicitacaoPagador,
  });

  Map<String, dynamic> toJson() => {
        'chave': chave,
        'valor': valor,
        'nome': nome,
        'cpf': cpf,
        'cnpj': cnpj,
        'expiracao': expiracao,
        'dataVencimento': dataVencimento,
        'banco': banco,
        'tipoCob': tipoCob,
        'solicitacaoPagador': solicitacaoPagador,
      };
}
