import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../utils/formatadores.dart';
import '../widgets/componentes.dart';

class DecisoesPage extends StatelessWidget {
  const DecisoesPage({super.key});

  Future<void> _confirmarExclusao(
      BuildContext context, AppState app, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar decisão?'),
        content: const Text('O registro será removido deste aparelho.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true) await app.removerDecisao(id);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.decisoes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma decisão registrada ainda. Abra um alerta e registre a sua decisão.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: app.decisoes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = app.decisoes[i];
        final pendente = d.status.startsWith('Pendente');
        return CartaoBase(
          borda: pendente ? const Color(0xFFC24E00) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(d.titulo,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    tooltip: 'Apagar decisão',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmarExclusao(context, app, d.id),
                  ),
                ],
              ),
              Text(d.acao),
              const SizedBox(height: 4),
              Text(d.justificativa),
              const SizedBox(height: 8),
              Text(
                  '${d.responsavel} - ${dataHora(d.data)}\nStatus: ${d.status}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
