import 'package:flutter/material.dart';

enum Metrica { agua, energia, residuos, servicos }

extension MetricaInfo on Metrica {
  String get nome {
    switch (this) {
      case Metrica.agua:
        return 'Consumo de água';
      case Metrica.energia:
        return 'Consumo de energia';
      case Metrica.residuos:
        return 'Resíduos coletados';
      case Metrica.servicos:
        return 'Demanda por serviços';
    }
  }

  String get unidade {
    switch (this) {
      case Metrica.agua:
        return 'L/hab/dia';
      case Metrica.energia:
        return 'kWh/hab/dia';
      case Metrica.residuos:
        return 'kg/hab/dia';
      case Metrica.servicos:
        return 'chamados/mil hab';
    }
  }

  IconData get icone {
    switch (this) {
      case Metrica.agua:
        return Icons.water_drop;
      case Metrica.energia:
        return Icons.bolt;
      case Metrica.residuos:
        return Icons.delete_outline;
      case Metrica.servicos:
        return Icons.support_agent;
    }
  }
}

enum Nivel { atencao, medio, alto }

extension NivelInfo on Nivel {
  String get nome {
    switch (this) {
      case Nivel.atencao:
        return 'Atenção';
      case Nivel.medio:
        return 'Risco médio';
      case Nivel.alto:
        return 'Risco alto';
    }
  }

  Color get cor {
    switch (this) {
      case Nivel.atencao:
        return const Color(0xFF8A5A00);
      case Nivel.medio:
        return const Color(0xFFC24E00);
      case Nivel.alto:
        return const Color(0xFFB3261E);
    }
  }

  IconData get icone {
    switch (this) {
      case Nivel.atencao:
        return Icons.info_outline;
      case Nivel.medio:
        return Icons.warning_amber_rounded;
      case Nivel.alto:
        return Icons.error_outline;
    }
  }

  int get peso {
    switch (this) {
      case Nivel.atencao:
        return 1;
      case Nivel.medio:
        return 2;
      case Nivel.alto:
        return 3;
    }
  }
}

class Bairro {
  final String id;
  final String nome;
  final String tipo;
  final int populacao;

  const Bairro(this.id, this.nome, this.tipo, this.populacao);
}

class Serie {
  final Bairro bairro;
  final Metrica metrica;
  final List<double> valores;
  final double limite;

  const Serie(this.bairro, this.metrica, this.valores, this.limite);

  double get atual => valores.last;

  double get variacaoSemanal {
    final antes = valores[valores.length - 8];
    return (atual / antes - 1) * 100;
  }
}

class ClimaDia {
  final DateTime data;
  final double tMax;
  final double chuva;

  const ClimaDia(this.data, this.tMax, this.chuva);
}

class ClimaResumo {
  final List<ClimaDia> dias;
  final String fonte;
  final DateTime atualizadoEm;

  const ClimaResumo(this.dias, this.fonte, this.atualizadoEm);

  bool get sintetico => fonte.startsWith('Sint');

  List<ClimaDia> get previsao => dias.length > 7 ? dias.sublist(7) : dias;

  double get tMaxMediaPrevisao {
    final p = previsao;
    if (p.isEmpty) return 0;
    return p.map((d) => d.tMax).reduce((a, b) => a + b) / p.length;
  }

  double get chuvaPrevisao {
    final p = previsao;
    if (p.isEmpty) return 0;
    return p.map((d) => d.chuva).reduce((a, b) => a + b);
  }
}

class Analise {
  final Serie serie;
  final List<double> projecao;
  final double confianca;
  final double fatorClima;
  final String notaClima;

  const Analise(
      this.serie, this.projecao, this.confianca, this.fatorClima, this.notaClima);

  double get projetado => projecao.last;

  double get razaoLimite => projetado / serie.limite;

  String get id => '${serie.bairro.id}-${serie.metrica.name}';
}

class Alerta {
  final Analise analise;
  final Nivel nivel;
  final String justificativa;
  final List<String> limitacoes;

  const Alerta(this.analise, this.nivel, this.justificativa, this.limitacoes);

  String get id => analise.id;

  Bairro get bairro => analise.serie.bairro;

  Metrica get metrica => analise.serie.metrica;

  String get titulo => '${metrica.nome} - ${bairro.nome}';

  String get nivelConfianca {
    final c = analise.confianca;
    if (c >= 75) return 'Alta';
    if (c >= 50) return 'Média';
    return 'Baixa';
  }
}

const List<String> acoesDecisao = [
  'Monitorar por mais 7 dias',
  'Enviar equipe de vistoria',
  'Comunicar a população (aviso preventivo)',
  'Solicitar mais dados / validar sensores',
  'Descartar alerta (falso positivo)',
  'Propor medida de alto impacto (exige validação superior)',
];

class Decisao {
  final String id;
  final String alertaId;
  final String titulo;
  final String acao;
  final String justificativa;
  final String responsavel;
  final DateTime data;
  final String status;

  const Decisao({
    required this.id,
    required this.alertaId,
    required this.titulo,
    required this.acao,
    required this.justificativa,
    required this.responsavel,
    required this.data,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'alertaId': alertaId,
        'titulo': titulo,
        'acao': acao,
        'justificativa': justificativa,
        'responsavel': responsavel,
        'data': data.toIso8601String(),
        'status': status,
      };

  factory Decisao.fromJson(Map<String, dynamic> j) => Decisao(
        id: j['id'] as String,
        alertaId: j['alertaId'] as String,
        titulo: j['titulo'] as String,
        acao: j['acao'] as String,
        justificativa: j['justificativa'] as String,
        responsavel: j['responsavel'] as String,
        data: DateTime.parse(j['data'] as String),
        status: j['status'] as String,
      );
}
