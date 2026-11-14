import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../models/ocorrencia.dart';
import '../providers/ocorrencia_provider.dart';
import '../widgets/info_row.dart';
import '../widgets/ocorrencia_actions.dart';

/// Tela 3 — Formulário de cadastro e edição.
///
/// Recebe [ocorrencia] pela rota: se vier preenchida, a tela abre em modo
/// edição com os campos carregados.
class OcorrenciaFormScreen extends StatefulWidget {
  const OcorrenciaFormScreen({super.key, this.ocorrencia});

  final Ocorrencia? ocorrencia;

  @override
  State<OcorrenciaFormScreen> createState() => _OcorrenciaFormScreenState();
}

class _OcorrenciaFormScreenState extends State<OcorrenciaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _referenciaController;

  CategoriaOcorrencia? _categoria;
  Periodo? _periodo;
  NivelRisco _nivelRisco = NivelRisco.medio;
  bool _anonima = false;
  bool _resolvida = false;
  bool _salvando = false;

  bool get _isEdicao => widget.ocorrencia != null;

  @override
  void initState() {
    super.initState();
    final o = widget.ocorrencia;
    _tituloController = TextEditingController(text: o?.titulo ?? '');
    _descricaoController = TextEditingController(text: o?.descricao ?? '');
    _bairroController = TextEditingController(text: o?.bairro ?? '');
    _referenciaController = TextEditingController(text: o?.referencia ?? '');
    if (o != null) {
      _categoria = o.categoria;
      _periodo = o.periodo;
      _nivelRisco = o.nivelRisco;
      _anonima = o.anonima;
      _resolvida = o.resolvida;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _bairroController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      showAppSnackBar(context, 'Corrija os campos destacados antes de salvar.',
          erro: true);
      return;
    }

    setState(() => _salvando = true);

    final referencia = _referenciaController.text.trim();
    final ocorrencia = Ocorrencia(
      id: widget.ocorrencia?.id,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoria!,
      bairro: _bairroController.text.trim(),
      referencia: referencia.isEmpty ? null : referencia,
      nivelRisco: _nivelRisco,
      periodo: _periodo!,
      anonima: _anonima,
      resolvida: _resolvida,
      dataRegistro: widget.ocorrencia?.dataRegistro ?? DateTime.now(),
    );

    final provider = context.read<OcorrenciaProvider>();
    final ok = _isEdicao
        ? await provider.updateOcorrencia(ocorrencia)
        : await provider.addOcorrencia(ocorrencia);

    if (!mounted) return;
    setState(() => _salvando = false);

    if (ok) {
      showAppSnackBar(
        context,
        _isEdicao
            ? 'Ocorrência atualizada com sucesso!'
            : 'Ocorrência registrada! Obrigado por ajudar sua comunidade.',
      );
      Navigator.pop(context, true);
    } else {
      showAppSnackBar(context, 'Não foi possível salvar. Tente novamente.',
          erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar ocorrência' : 'Nova ocorrência'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle('O que está acontecendo?'),
              TextFormField(
                controller: _tituloController,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppTheme.inputDecoration(
                  label: 'Título *',
                  hint: 'Ex.: Rua sem iluminação',
                  icon: Icons.title,
                ),
                validator: OcorrenciaValidators.titulo,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoriaOcorrencia>(
                value: _categoria,
                isExpanded: true,
                decoration: AppTheme.inputDecoration(
                  label: 'Categoria *',
                  icon: Icons.category_outlined,
                ),
                items: [
                  for (final c in CategoriaOcorrencia.values)
                    DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _categoria = value),
                validator: OcorrenciaValidators.categoria,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLength: 500,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: AppTheme.inputDecoration(
                  label: 'Descrição *',
                  hint: 'Conte o que acontece, desde quando e quem é afetado',
                  icon: Icons.notes,
                ),
                validator: OcorrenciaValidators.descricao,
              ),
              const SectionTitle('Onde e quando?'),
              TextFormField(
                controller: _bairroController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: AppTheme.inputDecoration(
                  label: 'Bairro *',
                  hint: 'Ex.: Capão Redondo',
                  icon: Icons.location_city,
                ),
                validator: OcorrenciaValidators.bairro,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenciaController,
                textInputAction: TextInputAction.next,
                decoration: AppTheme.inputDecoration(
                  label: 'Ponto de referência (opcional)',
                  hint: 'Ex.: Em frente ao ponto de ônibus',
                  icon: Icons.place_outlined,
                ),
                validator: OcorrenciaValidators.referencia,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Periodo>(
                value: _periodo,
                isExpanded: true,
                decoration: AppTheme.inputDecoration(
                  label: 'Período mais crítico *',
                  icon: Icons.schedule,
                ),
                items: [
                  for (final p in Periodo.values)
                    DropdownMenuItem(value: p, child: Text(p.label)),
                ],
                onChanged: (value) => setState(() => _periodo = value),
                validator: OcorrenciaValidators.periodo,
              ),
              const SectionTitle('Nível de risco'),
              SegmentedButton<NivelRisco>(
                segments: [
                  for (final n in NivelRisco.values)
                    ButtonSegment(value: n, label: Text(n.label)),
                ],
                selected: {_nivelRisco},
                onSelectionChanged: (selecao) =>
                    setState(() => _nivelRisco = selecao.first),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.person_off_outlined),
                      title: const Text('Registrar anonimamente'),
                      subtitle:
                          const Text('Seu nome não será exibido no relato'),
                      value: _anonima,
                      onChanged: (v) => setState(() => _anonima = v),
                    ),
                    if (_isEdicao)
                      CheckboxListTile(
                        secondary: const Icon(Icons.check_circle_outline),
                        title: const Text('Problema já foi resolvido'),
                        value: _resolvida,
                        onChanged: (v) =>
                            setState(() => _resolvida = v ?? false),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Checkbox obrigatório validado pelo próprio Form.
              FormField<bool>(
                initialValue: _isEdicao,
                validator: OcorrenciaValidators.confirmacao,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                          'Declaro que as informações são verdadeiras'),
                      value: field.value ?? false,
                      onChanged: field.didChange,
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isEdicao ? 'Salvar alterações' : 'Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
