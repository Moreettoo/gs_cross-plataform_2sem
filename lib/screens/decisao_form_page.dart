import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelos.dart';
import '../providers/app_state.dart';
import '../utils/formatadores.dart';
import '../widgets/componentes.dart';

class DecisaoFormPage extends StatefulWidget {
  final Alerta alerta;

  const DecisaoFormPage({super.key, required this.alerta});

  @override
  State<DecisaoFormPage> createState() => _DecisaoFormPageState();
}

class _DecisaoFormPageState extends State<DecisaoFormPage> {
  final _form = GlobalKey<FormState>();
  final _justificativa = TextEditingController();
  final _responsavel = TextEditingController();
  String? _acao;

  @override
  void dispose() {
    _justificativa.dispose();
    _responsavel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    final msg = ScaffoldMessenger.of(context);
    final alto = _acao == acoesDecisao.last;
    await app.registrarDecisao(
      alerta: widget.alerta,
      acao: _acao!,
      justificativa: _justificativa.text.trim(),
      responsavel: _responsavel.text.trim(),
    );
    nav.pop();
    msg.showSnackBar(SnackBar(
      content: Text(alto
          ? 'Decisão registrada como pendente de validação superior.'
          : 'Decisão registrada.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alerta;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar decisão')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CartaoBase(
              borda: a.nivel.cor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  SeloNivel(a.nivel),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _form,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _acao,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Ação escolhida',
                        prefixIcon: Icon(Icons.flag)),
                    items: acoesDecisao
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e, softWrap: true)))
                        .toList(),
                    onChanged: (v) => setState(() => _acao = v),
                    validator: (v) => v == null ? 'Escolha uma ação' : null,
                  ),
                  if (_acao == acoesDecisao.last)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                          'Fica só como proposta até outra pessoa validar.',
                          style: TextStyle(fontSize: 13)),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _justificativa,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                        labelText: 'Justificativa da decisão',
                        alignLabelWithHint: true),
                    validator: validarJustificativa,
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _responsavel,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: 'Responsável',
                        prefixIcon: Icon(Icons.person)),
                    validator: validarNome,
                  ),
                  const SizedBox(height: 12),
                  FormField<bool>(
                    initialValue: false,
                    validator: (v) => v == true
                        ? null
                        : 'Confirme a leitura para continuar',
                    builder: (campo) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: campo.value,
                          onChanged: (v) => campo.didChange(v),
                          title: const Text(
                              'Li a justificativa e as limitações.'),
                        ),
                        if (campo.hasError)
                          Text(campo.errorText!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar decisão'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
