import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelos.dart';
import '../providers/app_state.dart';
import '../utils/formatadores.dart';

class CartaoBase extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borda;
  final EdgeInsets padding;

  const CartaoBase({
    super.key,
    required this.child,
    this.onTap,
    this.borda,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final alto = context.watch<AppState>().altoContraste;
    final cor = borda ?? (alto ? Colors.black : const Color(0xFFD5E0E1));
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cor, width: alto || borda != null ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SecaoTitulo extends StatelessWidget {
  final String texto;
  final Widget? acao;

  const SecaoTitulo(this.texto, {super.key, this.acao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                texto,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (acao != null) acao!,
        ],
      ),
    );
  }
}

class SeloNivel extends StatelessWidget {
  final Nivel nivel;

  const SeloNivel(this.nivel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: nivel.cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(nivel.icone, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            nivel.nome,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CartaoIndicador extends StatelessWidget {
  final Serie serie;
  final bool selecionado;
  final VoidCallback onTap;

  const CartaoIndicador({
    super.key,
    required this.serie,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final variacao = serie.variacaoSemanal;
    final sobe = variacao >= 0;
    final primaria = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selecionado,
      label:
          '${serie.metrica.nome}: ${numero(serie.atual)} ${serie.metrica.unidade}, ${sobe ? 'alta' : 'queda'} de ${numero(variacao.abs())} por cento na semana',
      child: ExcludeSemantics(
        child: CartaoBase(
          onTap: onTap,
          borda: selecionado ? primaria : null,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(serie.metrica.icone, color: primaria, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(serie.metrica.nome,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(numero(serie.atual),
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              Text(serie.metrica.unidade, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(sobe ? Icons.trending_up : Icons.trending_down,
                      size: 18),
                  const SizedBox(width: 4),
                  Text('${sobe ? '+' : '-'}${numero(variacao.abs())}% na semana',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarraConfianca extends StatelessWidget {
  final double confianca;
  final String rotulo;

  const BarraConfianca({super.key, required this.confianca, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    final cor = confianca >= 75
        ? const Color(0xFF1B6E3C)
        : confianca >= 50
            ? const Color(0xFF8A5A00)
            : const Color(0xFFB3261E);
    return Semantics(
      label: 'Nível de confiança $rotulo, ${confianca.round()} por cento',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confiança $rotulo (${confianca.round()}%)',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: confianca / 100,
                minHeight: 10,
                color: cor,
                backgroundColor: const Color(0xFFE0E6E7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
