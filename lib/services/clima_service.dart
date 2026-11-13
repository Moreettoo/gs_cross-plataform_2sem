import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/modelos.dart';
import 'gerador_dados.dart';
import 'storage_service.dart';

class ClimaService {
  static const String _url =
      'https://api.open-meteo.com/v1/forecast?latitude=-23.55&longitude=-46.63'
      '&daily=temperature_2m_max,precipitation_sum&past_days=7&forecast_days=7'
      '&timezone=America%2FSao_Paulo';

  final StorageService storage;

  ClimaService(this.storage);

  Future<ClimaResumo> buscar() async {
    try {
      final resp =
          await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        throw Exception('status ${resp.statusCode}');
      }
      final resumo = _converter(resp.body, 'Open-Meteo (ao vivo)');
      await storage.salvarClima(resp.body);
      return resumo;
    } catch (_) {
      final cache = await storage.lerClima();
      if (cache != null) {
        try {
          return _converter(cache, 'Open-Meteo (último dado salvo)');
        } catch (_) {}
      }
      return GeradorDados.climaSintetico();
    }
  }

  ClimaResumo _converter(String corpo, String fonte) {
    final daily = jsonDecode(corpo)['daily'];
    final tempos = List<String>.from(daily['time']);
    final tmax = daily['temperature_2m_max'] as List;
    final chuva = daily['precipitation_sum'] as List;
    final dias = <ClimaDia>[];
    for (var i = 0; i < tempos.length; i++) {
      dias.add(ClimaDia(
        DateTime.parse(tempos[i]),
        (tmax[i] as num?)?.toDouble() ?? 0,
        (chuva[i] as num?)?.toDouble() ?? 0,
      ));
    }
    return ClimaResumo(dias, fonte, DateTime.now());
  }
}
