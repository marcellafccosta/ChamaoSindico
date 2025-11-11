import 'package:client/models/usuario_model.dart';
import 'package:client/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/utils/api_url.dart';

class NovoPostItDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const NovoPostItDialog({super.key, required this.onSuccess});

  @override
  State<NovoPostItDialog> createState() => _NovoPostItDialogState();
}

class _NovoPostItDialogState extends State<NovoPostItDialog> {
  final _formKey = GlobalKey<FormState>();
  bool isImportant = false;
  bool isReuniao = false;
  DateTime? dataReuniao;
  String assunto = '';
  String aviso = '';
  bool loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (isReuniao && dataReuniao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data da reunião')),
      );
      return;
    }
    setState(() => loading = true);
    final usuarioJson = await StorageHelper.instance.getItem('usuario');

    if (usuarioJson == null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado')),
      );
      return;
    }

    final usuario = UsuarioModel.fromJson(jsonDecode(usuarioJson));

    final url = Uri.parse('${getApiBaseUrl()}/aviso');

    final body = {
      "isImportant": isImportant,
      "isReuniao": isReuniao,
      "dataReuniao": dataReuniao?.toIso8601String(),
      "assunto": assunto,
      "aviso": aviso,
      "autor": usuario.id,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        widget.onSuccess();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar aviso (${response.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar aviso: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF59D),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Column(
                          children: const [
                            Icon(Icons.push_pin, color: Colors.red, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Criar novo aviso',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Fechar',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Importante'),
                    value: isImportant,
                    onChanged: (v) => setState(() => isImportant = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('É reunião?'),
                    value: isReuniao,
                    onChanged: (v) => setState(() {
                      isReuniao = v ?? false;
                      if (!isReuniao) dataReuniao = null;
                    }),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (isReuniao)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dataReuniao == null
                                ? 'Data da reunião'
                                : DateFormat('dd/MM/yyyy').format(dataReuniao!),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                              DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) {
                              setState(() => dataReuniao = picked);
                            }
                          },
                          child: const Text('Escolher'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Assunto',
                      prefixIcon: const Icon(Icons.subject),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLength: 50,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o assunto'
                        : null,
                    onChanged: (v) => assunto = v,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Aviso',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    minLines: 3,
                    maxLines: 7,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o aviso'
                        : null,
                    onChanged: (v) => aviso = v,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.add),
                    label: const Text('Criar aviso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF33477A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}