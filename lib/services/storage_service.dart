import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/modelos.dart';

class StorageService {
  static const _kDecisoes = 'decisoes';
  static const _kClima = 'clima_cache';
  static const _kContraste = 'alto_contraste';
  static const _kTexto = 'texto_grande';

  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  Future<List<Decisao>> lerDecisoes() async {
    final p = await _p;
    final s = p.getString(_kDecisoes);
    if (s == null) return [];
    final lista = jsonDecode(s) as List;
    return lista
        .map((e) => Decisao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarDecisoes(List<Decisao> decisoes) async {
    final p = await _p;
    await p.setString(
        _kDecisoes, jsonEncode(decisoes.map((d) => d.toJson()).toList()));
  }

  Future<String?> lerClima() async {
    final p = await _p;
    return p.getString(_kClima);
  }

  Future<void> salvarClima(String json) async {
    final p = await _p;
    await p.setString(_kClima, json);
  }

  Future<bool> lerContraste() async => (await _p).getBool(_kContraste) ?? false;

  Future<void> salvarContraste(bool v) async =>
      (await _p).setBool(_kContraste, v);

  Future<bool> lerTextoGrande() async => (await _p).getBool(_kTexto) ?? false;

  Future<void> salvarTextoGrande(bool v) async => (await _p).setBool(_kTexto, v);

  Future<void> apagarTudo() async {
    final p = await _p;
    await p.clear();
  }
}
