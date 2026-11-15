import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/formatadores.dart';

class GraficoLinha extends StatelessWidget {
  final List<double> historico;
  final List<double> projecao;
  final double limite;
  final String unidade;
  final double altura;

  const GraficoLinha({
    super.key,
    required this.historico,
    required this.projecao,
    required this.limite,
    required this.unidade,
    this.altura = 200,
  });

  static const Color corHistorico = Color(0xFF0B5C63);
  static const Color corProjecao = Color(0xFF7B3FA0);
  static const Color corLimite = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    final resumo =
        'Gráfico de linha. Valor atual ${numero(historico.last)} $unidade. Projeção para 7 dias ${numero(projecao.last)} $unidade. Limite de referência ${numero(limite)} $unidade.';
    return Column(
      children: [
        Semantics(
          label: resumo,
          image: true,
          child: ExcludeSemantics(
            child: SizedBox(
              height: altura,
              width: double.infinity,
              child: CustomPaint(
                painter: _Pintor(historico, projecao, limite),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _Legenda(corHistorico, 'Histórico', false),
            _Legenda(corProjecao, 'Projeção 7 dias', true),
            _Legenda(corLimite, 'Limite de referência', true),
          ],
        ),
      ],
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String texto;
  final bool tracejada;

  const _Legenda(this.cor, this.texto, this.tracejada);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 0,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cor, width: 3),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(tracejada ? '$texto (tracejada)' : texto,
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _Pintor extends CustomPainter {
  final List<double> historico;
  final List<double> projecao;
  final double limite;

  _Pintor(this.historico, this.projecao, this.limite);

  void _tracejado(Canvas canvas, Offset a, Offset b, Paint p) {
    const traco = 6.0;
    const vazio = 4.0;
    final dist = (b - a).distance;
    if (dist == 0) return;
    final dir = (b - a) / dist;
    var d = 0.0;
    while (d < dist) {
      final fim = min(d + traco, dist);
      canvas.drawLine(a + dir * d, a + dir * fim, p);
      d += traco + vazio;
    }
  }

  void _texto(Canvas canvas, String t, Offset pos, Color cor) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(fontSize: 11, color: cor)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final todos = [...historico, ...projecao, limite];
    var minV = todos.reduce(min);
    var maxV = todos.reduce(max);
    final margem = (maxV - minV) * 0.1;
    minV -= margem;
    maxV += margem;
    if (maxV == minV) maxV = minV + 1;

    const esq = 40.0;
    final largura = size.width - esq;
    final total = historico.length + projecao.length;

    double x(int i) => esq + largura * i / (total - 1);
    double y(double v) => size.height - (v - minV) / (maxV - minV) * size.height;

    final grade = Paint()
      ..color = const Color(0xFFD5E0E1)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final yy = size.height * i / 3;
      canvas.drawLine(Offset(esq, yy), Offset(size.width, yy), grade);
      final v = maxV - (maxV - minV) * i / 3;
      _texto(canvas, v.toStringAsFixed(v < 10 ? 1 : 0), Offset(0, yy - 6),
          const Color(0xFF445558));
    }

    final pLimite = Paint()
      ..color = GraficoLinha.corLimite
      ..strokeWidth = 2;
    _tracejado(
        canvas, Offset(esq, y(limite)), Offset(size.width, y(limite)), pLimite);

    final pHist = Paint()
      ..color = GraficoLinha.corHistorico
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final caminho = Path()..moveTo(x(0), y(historico[0]));
    for (var i = 1; i < historico.length; i++) {
      caminho.lineTo(x(i), y(historico[i]));
    }
    canvas.drawPath(caminho, pHist);

    final pProj = Paint()
      ..color = GraficoLinha.corProjecao
      ..strokeWidth = 3;
    var anterior = Offset(x(historico.length - 1), y(historico.last));
    for (var i = 0; i < projecao.length; i++) {
      final atual = Offset(x(historico.length + i), y(projecao[i]));
      _tracejado(canvas, anterior, atual, pProj);
      anterior = atual;
    }

    canvas.drawCircle(Offset(x(historico.length - 1), y(historico.last)), 4,
        Paint()..color = GraficoLinha.corHistorico);
    canvas.drawCircle(anterior, 4, Paint()..color = GraficoLinha.corProjecao);
  }

  @override
  bool shouldRepaint(covariant _Pintor old) =>
      old.historico != historico ||
      old.projecao != projecao ||
      old.limite != limite;
}
