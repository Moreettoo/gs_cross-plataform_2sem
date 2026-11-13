String doisDigitos(int n) => n.toString().padLeft(2, '0');

String dataHora(DateTime d) =>
    '${doisDigitos(d.day)}/${doisDigitos(d.month)}/${d.year} ${doisDigitos(d.hour)}:${doisDigitos(d.minute)}';

String diaMes(DateTime d) => '${doisDigitos(d.day)}/${doisDigitos(d.month)}';

String numero(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

String? validarNome(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Informe o nome completo';
  if (t.split(RegExp(r'\s+')).length < 2) return 'Digite nome e sobrenome';
  if (t.length < 5) return 'Nome muito curto';
  return null;
}

String? validarJustificativa(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Explique o motivo da decisão';
  if (t.length < 15) return 'Escreva pelo menos 15 caracteres';
  if (t.length > 300) return 'Máximo de 300 caracteres';
  return null;
}
