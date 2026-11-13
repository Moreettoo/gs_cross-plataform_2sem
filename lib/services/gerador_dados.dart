import 'dart:math';

import '../models/modelos.dart';

class GeradorDados {
  static const List<Bairro> bairros = [
    Bairro('centro', 'Centro Histórico', 'Urbano', 18500),
    Bairro('vila', 'Vila Nova', 'Residencial', 24200),
    Bairro('rural', 'Comunidade Rural Sul', 'Rural', 3100),
  ];

  static const Map<Metrica, double> _base = {
    Metrica.agua: 150,
    Metrica.energia: 5,
    Metrica.residuos: 0.9,
    Metrica.servicos: 40,
  };

  static const Map<String, double> _escala = {
    'centro': 1.0,
    'vila': 0.9,
    'rural': 1.1,
  };

  static const Map<String, Map<Metrica, double>> _crescimento = {
    'centro': {
      Metrica.agua: 0.28,
      Metrica.energia: 0.03,
      Metrica.residuos: 0.10,
      Metrica.servicos: 0.04,
    },
    'vila': {
      Metrica.agua: 0.02,
      Metrica.energia: 0.30,
      Metrica.residuos: 0.05,
      Metrica.servicos: 0.22,
    },
    'rural': {
      Metrica.agua: 0.18,
      Metrica.energia: -0.02,
      Metrica.residuos: 0.26,
      Metrica.servicos: 0.01,
    },
  };

  static List<Serie> gerar() {
    final rnd = Random(2026);
    final lista = <Serie>[];
    for (final b in bairros) {
      for (final m in Metrica.values) {
        final base = _base[m]! * _escala[b.id]!;
        final cresc = _crescimento[b.id]![m]!;
        final valores = <double>[];
        for (var i = 0; i < 30; i++) {
          final tendencia = 1 + cresc * i / 30;
          final semana = 1 + 0.03 * sin(i * 2 * pi / 7);
          final ruido = 1 + (rnd.nextDouble() - 0.5) * 0.04;
          valores.add(base * tendencia * semana * ruido);
        }
        lista.add(Serie(b, m, valores, base * 1.2));
      }
    }
    return lista;
  }

  static ClimaResumo climaSintetico() {
    final rnd = Random(7);
    final hoje = DateTime.now();
    final dias = <ClimaDia>[];
    for (var i = -7; i < 7; i++) {
      final data = DateTime(hoje.year, hoje.month, hoje.day + i);
      dias.add(ClimaDia(
        data,
        26 + rnd.nextDouble() * 7,
        rnd.nextDouble() < 0.3 ? rnd.nextDouble() * 15 : 0,
      ));
    }
    return ClimaResumo(dias, 'Sintético (sem conexão)', DateTime.now());
  }
}
