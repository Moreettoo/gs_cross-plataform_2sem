import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/componentes.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  Future<void> _apagar(BuildContext context, AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar dados locais?'),
        content: const Text(
            'Decisões e preferências serão removidas deste aparelho.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Apagar tudo')),
        ],
      ),
    );
    if (ok == true) await app.apagarDadosLocais();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SecaoTitulo('Acessibilidade'),
        CartaoBase(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Texto maior'),
                subtitle: const Text('Aumenta o tamanho das letras do app'),
                value: app.textoGrande,
                onChanged: app.setTextoGrande,
              ),
              SwitchListTile(
                title: const Text('Alto contraste'),
                subtitle: const Text('Bordas e cores mais fortes'),
                value: app.altoContraste,
                onChanged: app.setAltoContraste,
              ),
            ],
          ),
        ),
        const SecaoTitulo('Privacidade'),
        const CartaoBase(
          child: Text(
              'Dados agregados por bairro, sem informação de moradores. Decisões salvas só neste aparelho.'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _apagar(context, app),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Apagar meus dados locais'),
        ),
        const SecaoTitulo('Sobre os dados'),
        const CartaoBase(
          child: Text(
              'Clima: Open-Meteo. Consumo, resíduos e serviços: dados sintéticos de demonstração.'),
        ),
      ],
    );
  }
}
