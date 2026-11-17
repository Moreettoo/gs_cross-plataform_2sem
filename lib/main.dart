import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_page.dart';
import 'theme/tema.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..iniciar(),
      child: const PainelApp(),
    ),
  );
}

class PainelApp extends StatelessWidget {
  const PainelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final Widget inicio = app.carregando
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : const HomePage();
    return MaterialApp(
      title: 'Painel Territorial',
      debugShowCheckedModeBanner: false,
      theme: Tema.criar(app.altoContraste),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(app.textoGrande ? 1.3 : 1.0),
          ),
          child: child!,
        );
      },
      home: inicio,
    );
  }
}
