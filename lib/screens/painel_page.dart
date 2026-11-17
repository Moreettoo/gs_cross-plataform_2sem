import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelos.dart';
import '../providers/app_state.dart';
import '../services/gerador_dados.dart';
import '../utils/formatadores.dart';
import '../widgets/componentes.dart';
import '../widgets/grafico_linha.dart';
import 'alertas_page.dart';

class PainelPage extends StatelessWidget {
  const PainelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final analise = app.analiseDe(app.bairroId, app.metricaSelecionada);
    final serie = analise.serie;
    final alertasBairro = app.alertasDoBairro(app.bairroId);
    final clima = app.clima!;
    final largura = (MediaQuery.of(context).size.width - 32 - 12) / 2;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SecaoTitulo('Território'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GeradorDados.bairros
              .map((b) => ChoiceChip(
                    label: Text(b.nome),
                    selected: b.id == app.bairroId,
                    onSelected: (_) => app.selecionarBairro(b.id),
                  ))
              .toList(),
        ),
        const SecaoTitulo('Indicadores (hoje)'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: Metrica.values.map((m) {
            final s = app.analiseDe(app.bairroId, m).serie;
            return SizedBox(
              width: largura,
              child: CartaoIndicador(
                serie: s,
                selecionado: m == app.metricaSelecionada,
                onTap: () => app.selecionarMetrica(m),
              ),
            );
          }).toList(),
        ),
        SecaoTitulo(serie.metrica.nome),
        CartaoBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GraficoLinha(
                historico: serie.valores,
                projecao: analise.projecao,
                limite: serie.limite,
                unidade: serie.metrica.unidade,
              ),
              const Divider(height: 24),
              BarraConfianca(
                  confianca: analise.confianca,
                  rotulo: _rotuloConfianca(analise.confianca)),
            ],
          ),
        ),
        SecaoTitulo('Alertas (${alertasBairro.length})'),
        if (alertasBairro.isEmpty)
          const CartaoBase(child: Text('Nenhum alerta.'))
        else
          ...alertasBairro.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CartaoAlerta(alerta: a),
              )),
        const SecaoTitulo('Clima (próximos 7 dias)'),
        CartaoBase(
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    '${numero(clima.tMaxMediaPrevisao)} °C de máxima - ${numero(clima.chuvaPrevisao)} mm de chuva'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _rotuloConfianca(double c) {
    if (c >= 75) return 'alta';
    if (c >= 50) return 'média';
    return 'baixa';
  }
}
