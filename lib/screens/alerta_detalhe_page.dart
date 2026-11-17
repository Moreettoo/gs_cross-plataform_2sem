import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelos.dart';
import '../providers/app_state.dart';
import '../utils/formatadores.dart';
import '../widgets/componentes.dart';
import '../widgets/grafico_linha.dart';
import 'decisao_form_page.dart';

class AlertaDetalhePage extends StatelessWidget {
  final String alertaId;

  const AlertaDetalhePage({super.key, required this.alertaId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.alertas.where((a) => a.id == alertaId).toList();
    if (lista.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alerta')),
        body: const Center(child: Text('Este alerta não está mais ativo.')),
      );
    }
    final alerta = lista.first;
    final a = alerta.analise;
    final s = a.serie;
    final decisao = app.decisaoDoAlerta(alerta.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(alerta.titulo,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerLeft,
                child: SeloNivel(alerta.nivel)),
            const SizedBox(height: 16),
            CartaoBase(
              child: GraficoLinha(
                historico: s.valores,
                projecao: a.projecao,
                limite: s.limite,
                unidade: s.metrica.unidade,
              ),
            ),
            const SecaoTitulo('Por quê'),
            CartaoBase(child: Text(alerta.justificativa)),
            const SecaoTitulo('Confiança'),
            CartaoBase(
              child: BarraConfianca(
                  confianca: a.confianca,
                  rotulo: alerta.nivelConfianca.toLowerCase()),
            ),
            const SecaoTitulo('Limitações'),
            CartaoBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: alerta.limitacoes
                    .map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(l)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SecaoTitulo('Decisão'),
            if (decisao != null)
              CartaoBase(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(decisao.acao,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(decisao.justificativa),
                    const SizedBox(height: 4),
                    Text(
                        '${decisao.responsavel} - ${dataHora(decisao.data)}\nStatus: ${decisao.status}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )
            else
              const CartaoBase(child: Text('Ainda sem decisão.')),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DecisaoFormPage(alerta: alerta)),
              ),
              icon: const Icon(Icons.edit_note),
              label: Text(decisao == null
                  ? 'Registrar decisão'
                  : 'Nova decisão'),
            ),
          ],
        ),
      ),
    );
  }
}
