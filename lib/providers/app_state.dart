import 'package:flutter/material.dart';

import '../models/modelos.dart';
import '../services/clima_service.dart';
import '../services/gerador_dados.dart';
import '../services/previsor.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  late final ClimaService _clima = ClimaService(_storage);

  bool carregando = true;
  bool atualizandoClima = false;
  bool altoContraste = false;
  bool textoGrande = false;
  List<Decisao> decisoes = [];
  List<Serie> series = [];
  List<Analise> analises = [];
  List<Alerta> alertas = [];
  ClimaResumo? clima;
  String bairroId = GeradorDados.bairros.first.id;
  Metrica metricaSelecionada = Metrica.agua;

  Future<void> iniciar() async {
    decisoes = await _storage.lerDecisoes();
    altoContraste = await _storage.lerContraste();
    textoGrande = await _storage.lerTextoGrande();
    series = GeradorDados.gerar();
    clima = await _clima.buscar();
    _recalcular();
    carregando = false;
    notifyListeners();
  }

  void _recalcular() {
    final c = clima!;
    analises = Previsor.analisarTudo(series, c);
    final lista = <Alerta>[];
    for (final a in analises) {
      final al = Previsor.gerarAlerta(a, c);
      if (al != null) lista.add(al);
    }
    lista.sort((a, b) {
      final p = b.nivel.peso.compareTo(a.nivel.peso);
      if (p != 0) return p;
      return b.analise.confianca.compareTo(a.analise.confianca);
    });
    alertas = lista;
  }

  Future<void> atualizarClima() async {
    atualizandoClima = true;
    notifyListeners();
    clima = await _clima.buscar();
    _recalcular();
    atualizandoClima = false;
    notifyListeners();
  }

  Bairro get bairro =>
      GeradorDados.bairros.firstWhere((b) => b.id == bairroId);

  void selecionarBairro(String id) {
    bairroId = id;
    notifyListeners();
  }

  void selecionarMetrica(Metrica m) {
    metricaSelecionada = m;
    notifyListeners();
  }

  Analise analiseDe(String bairro, Metrica m) {
    return analises
        .firstWhere((a) => a.serie.bairro.id == bairro && a.serie.metrica == m);
  }

  List<Alerta> alertasDoBairro(String id) =>
      alertas.where((a) => a.bairro.id == id).toList();

  Decisao? decisaoDoAlerta(String alertaId) {
    for (final d in decisoes) {
      if (d.alertaId == alertaId) return d;
    }
    return null;
  }

  Future<void> registrarDecisao({
    required Alerta alerta,
    required String acao,
    required String justificativa,
    required String responsavel,
  }) async {
    final alto = acao == acoesDecisao.last;
    final d = Decisao(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      alertaId: alerta.id,
      titulo: alerta.titulo,
      acao: acao,
      justificativa: justificativa,
      responsavel: responsavel,
      data: DateTime.now(),
      status: alto ? 'Pendente de validação superior' : 'Registrada',
    );
    decisoes = [d, ...decisoes];
    await _storage.salvarDecisoes(decisoes);
    notifyListeners();
  }

  Future<void> removerDecisao(String id) async {
    decisoes = decisoes.where((d) => d.id != id).toList();
    await _storage.salvarDecisoes(decisoes);
    notifyListeners();
  }

  Future<void> setAltoContraste(bool v) async {
    altoContraste = v;
    await _storage.salvarContraste(v);
    notifyListeners();
  }

  Future<void> setTextoGrande(bool v) async {
    textoGrande = v;
    await _storage.salvarTextoGrande(v);
    notifyListeners();
  }

  Future<void> apagarDadosLocais() async {
    await _storage.apagarTudo();
    decisoes = [];
    altoContraste = false;
    textoGrande = false;
    notifyListeners();
  }
}
