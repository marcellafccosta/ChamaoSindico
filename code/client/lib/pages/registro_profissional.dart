import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:logger/logger.dart';
import 'package:client/utils/api_url.dart';

final Logger logger = Logger();

class RegistroProfissionalPage extends StatefulWidget {
  const RegistroProfissionalPage({super.key});

  @override
  State<RegistroProfissionalPage> createState() =>
      _RegistroProfissionalPageState();
}

class _RegistroProfissionalPageState extends State<RegistroProfissionalPage> {
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  bool _carregandoUsuario = true;
  Map<String, dynamic>? _profissionalParaEditar;
  final Color primaryColor = const Color(0xFF33477A);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _profissionalParaEditar = arguments;
    }
  }

  Future<void> _init() async {
    await _carregarUsuario();
    setState(() {
      _carregandoUsuario = false;
    });
  }

  Future<void> _carregarUsuario() async {
    try {
      _usuario = await _utils.carregarUsuario();
      logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
    } catch (e) {
      logger.e('Erro ao carregar usuário: $e');
    }
  }

  bool get _isEditMode => _profissionalParaEditar != null;

  @override
  Widget build(BuildContext context) {
    if (_carregandoUsuario) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _isEditMode ? 'Editar Profissional' : 'Registro de Profissional',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProfissionalForm(
          usuario: _usuario,
          profissionalParaEditar: _profissionalParaEditar,
        ),
      ),
    );
  }
}

class ProfissionalForm extends StatefulWidget {
  final UsuarioModel? usuario;
  final Map<String, dynamic>? profissionalParaEditar;

  const ProfissionalForm({
    super.key,
    required this.usuario,
    this.profissionalParaEditar,
  });

  @override
  State<ProfissionalForm> createState() => _ProfissionalFormState();
}

class _ProfissionalFormState extends State<ProfissionalForm> {
  final _formKey = GlobalKey<FormState>();
  final Utils _utils = Utils();
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _areaAtuacaoController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();

  final Color primaryColor = const Color(0xFF33477A);

  @override
  void initState() {
    super.initState();
    _preencherCamposParaEdicao();
  }

  void _preencherCamposParaEdicao() {
    if (widget.profissionalParaEditar != null) {
      final profissional = widget.profissionalParaEditar!;
      _nomeController.text = profissional['nome'] ?? '';
      _areaAtuacaoController.text = profissional['areaAtuacao'] ?? '';
      _contatoController.text = profissional['contato'] ?? '';
    }
  }

  bool get _isEditMode => widget.profissionalParaEditar != null;

  @override
  void dispose() {
    _nomeController.dispose();
    _areaAtuacaoController.dispose();
    _contatoController.dispose();
    super.dispose();
  }

  Future<void> _enviarProfissional() async {
    if (widget.usuario == null) {
      _showErrorSnackBar('Sessão inválida. Por favor, faça login novamente.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final token = await _utils.obterToken();

        final Uri url = _isEditMode
            ? Uri.parse('${getApiBaseUrl()}/profissional/${widget.profissionalParaEditar!['id']}')
            : Uri.parse('${getApiBaseUrl()}/profissional');

        final body = jsonEncode({
          'nome': _nomeController.text.trim(),
          'areaAtuacao': _areaAtuacaoController.text.trim(),
          'contato': _contatoController.text.trim(),
        });

        logger.i(
            '${_isEditMode ? 'Atualizando' : 'Enviando'} profissional: $body');

        final response = _isEditMode
            ? await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        )
            : await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSuccessSnackBar(_isEditMode
              ? 'Profissional atualizado com sucesso!'
              : 'Profissional registrado com sucesso!');

          if (!_isEditMode) {
            _nomeController.clear();
            _areaAtuacaoController.clear();
            _contatoController.clear();
          }

          Navigator.pop(context, true);
        } else {
          String errorMessage = _isEditMode
              ? 'Erro ao atualizar profissional'
              : 'Erro ao registrar profissional';

          try {
            if (response.body.isNotEmpty) {
              final responseBody = jsonDecode(response.body);
              if (responseBody is Map) {
                errorMessage = responseBody['message'] ??
                    responseBody['error'] ??
                    errorMessage;
              } else if (responseBody is String) {
                errorMessage = responseBody;
              }
            }
          } catch (jsonError) {
            logger.e('Erro ao decodificar resposta de erro: $jsonError');
            errorMessage = 'Erro de comunicação com o servidor';
          }

          logger.e(
              'Erro ao ${_isEditMode ? 'atualizar' : 'registrar'} profissional: ${response.statusCode} - ${response.body}');
          _showErrorSnackBar(errorMessage);
        }
      } catch (e) {
        logger.e(
            'Erro ao ${_isEditMode ? 'atualizar' : 'registrar'} profissional: $e');
        if (!mounted) return;
        _showErrorSnackBar('Falha na comunicação: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.usuario != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(width: 6, color: primaryColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _isEditMode
                                        ? Icons.edit_rounded
                                        : Icons.person_add_rounded,
                                    color: primaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isEditMode
                                            ? 'Editar Indicação'
                                            : 'Nova Indicação',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isEditMode
                                            ? 'Editando: ${widget.profissionalParaEditar!['nome'] ?? 'Profissional'}'
                                            : 'Registrado por: ${widget.usuario!.name}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            _buildFormCard(
              title: 'Dados do Profissional',
              icon: Icons.business_center_rounded,
              children: [
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome do Profissional',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do profissional';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _areaAtuacaoController,
                  label: 'Área de Atuação',
                  icon: Icons.work_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira a área de atuação';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contatoController,
                  label: 'Contato (Telefone/WhatsApp)',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o contato do profissional';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF33477A).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _enviarProfissional,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Icon(
                    _isEditMode ? Icons.update_rounded : Icons.save_rounded,
                    color: Colors.white),
                label: Text(
                  _isLoading
                      ? (_isEditMode ? 'ATUALIZANDO...' : 'REGISTRANDO...')
                      : (_isEditMode
                      ? 'ATUALIZAR PROFISSIONAL'
                      : 'REGISTRAR PROFISSIONAL'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FormFieldValidator<String?>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}