import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import 'alertas_page.dart';
import 'config_page.dart';
import 'decisoes_page.dart';
import 'painel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _aba = 0;

  static const _titulos = ['Painel', 'Alertas', 'Decisões', 'Ajustes'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final paginas = const [
      PainelPage(),
      AlertasPage(),
      DecisoesPage(),
      ConfigPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_aba]),
        actions: [
          if (_aba == 0)
            IconButton(
              tooltip: 'Atualizar dados do clima',
              onPressed:
                  app.atualizandoClima ? null : () => app.atualizarClima(),
              icon: app.atualizandoClima
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SafeArea(child: paginas[_aba]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Painel'),
          NavigationDestination(
              icon: Badge(
                isLabelVisible: app.alertas.isNotEmpty,
                label: Text('${app.alertas.length}'),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications),
              label: 'Alertas'),
          const NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Decisões'),
          const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ajustes'),
        ],
      ),
    );
  }
}
