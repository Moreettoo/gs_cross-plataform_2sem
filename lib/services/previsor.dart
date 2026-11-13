import '../models/modelos.dart';

class _Reg {
  final double m;
  final double b;
  final double r2;

  _Reg(this.m, this.b, this.r2);
}

class Previsor {
  static const int janela = 14;
  static const int horizonte = 7;

  static _Reg _regressao(List<double> y) {
    final n = y.length;
    double sx = 0, sy = 0, sxx = 0, sxy = 0;
    for (var i = 0; i < n; i++) {
      sx += i;
      sy += y[i];
      sxx += i * i;
      sxy += i * y[i];
    }
    final m = (n * sxy - sx * sy) / (n * sxx - sx * sx);
    final b = (sy - m * sx) / n;
    final media = sy / n;
    double ssRes = 0, ssTot = 0;
    for (var i = 0; i < n; i++) {
      final prev = b + m * i;
      ssRes += (y[i] - prev) * (y[i] - prev);
      ssTot += (y[i] - media) * (y[i] - media);
    }
    final r2 = ssTot == 0 ? 0.0 : (1 - ssRes / ssTot).clamp(0.0, 1.0).toDouble();
    return _Reg(m, b, r2);
  }

  static Analise analisar(Serie serie, ClimaResumo clima) {
    final recentes = serie.valores.sublist(serie.valores.length - janela);
    final reg = _regressao(recentes);

    double fator = 1.0;
    String nota = '';
    if ((serie.metrica == Metrica.agua || serie.metrica == Metrica.energia) &&
        clima.tMaxMediaPrevisao >= 30) {
      fator = 1.03;
      nota = 'Previsão de calor: projeção +3%.';
    } else if ((serie.metrica == Metrica.residuos ||
            serie.metrica == Metrica.servicos) &&
        clima.chuvaPrevisao >= 40) {
      fator = 1.03;
      nota = 'Previsão de chuva forte: projeção +3%.';
    }

    final projecao = <double>[];
    for (var i = 0; i < horizonte; i++) {
      projecao.add((reg.b + reg.m * (janela + i)) * fator);
    }

    var confianca = reg.r2 * 100;
    if (clima.sintetico) confianca -= 5;
    confianca = confianca.clamp(0.0, 100.0).toDouble();

    return Analise(serie, projecao, confianca, fator, nota);
  }

  static List<Analise> analisarTudo(List<Serie> series, ClimaResumo clima) {
    return series.map((s) => analisar(s, clima)).toList();
  }

  static Alerta? gerarAlerta(Analise a, ClimaResumo clima) {
    final razao = a.razaoLimite;
    Nivel nivel;
    if (razao >= 1.1) {
      nivel = Nivel.alto;
    } else if (razao >= 1.0) {
      nivel = Nivel.medio;
    } else if (razao >= 0.92) {
      nivel = Nivel.atencao;
    } else {
      return null;
    }

    final s = a.serie;
    final ultimos = s.valores.sublist(s.valores.length - janela);
    final cresc = (ultimos.last / ultimos.first - 1) * 100;
    final un = s.metrica.unidade;

    var just =
        '${s.metrica.nome} variou ${cresc.toStringAsFixed(1)}% em $janela dias. '
        'Em $horizonte dias deve chegar a ${a.projetado.toStringAsFixed(1)} $un (${(razao * 100).toStringAsFixed(0)}% do limite de ${s.limite.toStringAsFixed(1)}).';
    if (a.notaClima.isNotEmpty) just += ' ${a.notaClima}';

    final lim = <String>[
      'Modelo simples (reta com $janela dias): não vê feriados nem eventos.',
      'Dados sintéticos, só para demonstração.',
    ];
    if (a.confianca < 50) {
      lim.add('Confiança baixa: confirme em campo antes de agir.');
    }
    if (clima.sintetico) {
      lim.add('Clima simulado (sem internet).');
    }

    return Alerta(a, nivel, just, lim);
  }
}
