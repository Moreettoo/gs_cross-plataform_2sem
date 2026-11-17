import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelos.dart';
import '../providers/app_state.dart';
import '../widgets/componentes.dart';
import 'alerta_detalhe_page.dart';

class CartaoAlerta extends StatelessWidget {
  final Alerta alerta;

  const CartaoAlerta({super.key, required this.alerta});

  @override
  Widget build(BuildContext context) {
    final decisao = context.watch<AppState>().decisaoDoAlerta(alerta.id);
    return Semantics(
      button: true,
      label:
          '${alerta.nivel.nome}. ${alerta.titulo}. Confiança ${alerta.nivelConfianca}. ${decisao == null ? 'Aguardando decisão' : 'Decisão registrada'}',
      child: ExcludeSemantics(
        child: CartaoBase(
          borda: alerta.nivel.cor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AlertaDetalhePage(alertaId: alerta.id)),
          ),
          child: Row(
            children: [
              Icon(alerta.metrica.icone, size: 32, color: alerta.nivel.cor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alerta.titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SeloNivel(alerta.nivel),
                        Text('Confiança ${alerta.nivelConfianca}',
                            style: const TextStyle(fontSize: 12)),
                        if (decisao != null)
                          const Text('- decisão registrada',
                              style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class AlertasPage extends StatelessWidget {
  const AlertasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (app.alertas.isEmpty)
          const CartaoBase(child: Text('Nenhum alerta.'))
        else
          ...app.alertas.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CartaoAlerta(alerta: a),
              )),
      ],
    );
  }
}
